// src/components/ui/index.tsx
import React from 'react';

// Card components
export const Card: React.FC<React.HTMLAttributes<HTMLDivElement>> = ({ 
  className = '', 
  ...props 
}) => (
  <div className={`bg-white rounded-lg shadow-sm ${className}`} {...props} />
);

export const CardHeader: React.FC<React.HTMLAttributes<HTMLDivElement>> = ({ 
  className = '', 
  ...props 
}) => (
  <div className={`p-6 ${className}`} {...props} />
);

export const CardTitle: React.FC<React.HTMLAttributes<HTMLHeadingElement>> = ({ 
  className = '', 
  children,
  ...props 
}) => (
  <h3 className={`text-lg font-medium ${className}`} {...props}>{children}</h3>
);

export const CardContent: React.FC<React.HTMLAttributes<HTMLDivElement>> = ({ 
  className = '', 
  ...props 
}) => (
  <div className={`p-6 pt-0 ${className}`} {...props} />
);

// Button component
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'default' | 'outlined' | 'text' | 'ghost' | 'outline';
  size?: 'default' | 'sm' | 'lg' | 'icon';
}

export const Button: React.FC<ButtonProps> = ({ 
  className = '', 
  variant = 'default', 
  size = 'default',
  ...props 
}) => {
  // Map 'outline' to 'outlined' for backward compatibility
  const mappedVariant = variant === 'outline' ? 'outlined' : variant;
  
  const variantClasses = {
    default: 'bg-blue-600 hover:bg-blue-700 text-white',
    outlined: 'border border-gray-300 hover:bg-gray-50 text-gray-700',
    text: 'hover:bg-gray-100 text-gray-700',
    ghost: 'hover:bg-gray-100 text-gray-700'
  };
  
  const sizeClasses = {
    default: 'px-4 py-2',
    sm: 'px-2 py-1 text-sm',
    lg: 'px-6 py-3 text-lg',
    icon: 'p-2'
  };

  return (
    <button
      className={`rounded-md font-medium transition-colors ${variantClasses[mappedVariant]} ${sizeClasses[size]} ${className}`}
      {...props}
    />
  );
};

// Input component
export const Input: React.FC<React.InputHTMLAttributes<HTMLInputElement>> = ({ 
  className = '', 
  ...props 
}) => (
  <input
    className={`w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent ${className}`}
    {...props}
  />
);

// Label component
export const Label: React.FC<React.LabelHTMLAttributes<HTMLLabelElement>> = ({ 
  className = '', 
  ...props 
}) => (
  <label className={`block text-sm font-medium text-gray-700 ${className}`} {...props} />
);

// InputLabel component for compatibility
export const InputLabel = Label;

// Create a context for the Select component
interface SelectContextType {
  value: string;
  onValueChange: (value: string) => void;
  isOpen: boolean;
  setIsOpen: React.Dispatch<React.SetStateAction<boolean>>;
  disabled: boolean;
  required?: boolean;
}

const SelectContext = React.createContext<SelectContextType | undefined>(undefined);

// Select components
interface SelectProps {
  value?: string;
  onValueChange?: (value: string) => void;
  disabled?: boolean;
  children: React.ReactNode;
  className?: string;
  required?: boolean;
  // Add any other HTML attributes that might be needed
  [x: string]: any;
}

export const Select: React.FC<SelectProps> = ({ 
  className = '', 
  value = '',
  onValueChange,
  children, 
  disabled = false,
  required = false,
  ...rest
}) => {
  // State for dropdown open/close
  const [isOpen, setIsOpen] = React.useState(false);
  // State for selected value
  const [selectedValue, setSelectedValue] = React.useState(value);
  // Reference to the select container for click outside detection
  const selectRef = React.useRef<HTMLDivElement>(null);

  // Update internal state when value prop changes
  React.useEffect(() => {
    setSelectedValue(value);
  }, [value]);

  // Handle click outside to close dropdown
  React.useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (selectRef.current && !selectRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };

    // Add event listener
    document.addEventListener('mousedown', handleClickOutside);
    
    // Clean up
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  // Handle value change
  const handleValueChange = React.useCallback((newValue: string) => {
    setSelectedValue(newValue);
    if (onValueChange) {
      onValueChange(newValue);
    }
    setIsOpen(false);
  }, [onValueChange]);

  // Context value for child components
  const contextValue = React.useMemo(() => ({
    value: selectedValue,
    onValueChange: handleValueChange,
    isOpen,
    setIsOpen,
    disabled,
    required
  }), [selectedValue, handleValueChange, isOpen, disabled, required]);

  // Render the select component
  return (
    <SelectContext.Provider value={contextValue}>
      <div 
        ref={selectRef} 
        className={`relative ${className}`}
        role="combobox"
        aria-expanded={isOpen}
        aria-haspopup="listbox"
        aria-disabled={disabled}
        aria-required={required}
        {...rest}
      >
        {children}
      </div>
    </SelectContext.Provider>
  );
};

// Hook to use select context
const useSelectContext = () => {
  const context = React.useContext(SelectContext);
  if (context === undefined) {
    throw new Error('useSelectContext must be used within a Select component');
  }
  return context;
};

// SelectTrigger component
interface SelectTriggerProps extends React.HTMLAttributes<HTMLDivElement> {
  className?: string;
  children?: React.ReactNode;
}

export const SelectTrigger: React.FC<SelectTriggerProps> = ({ 
  className = '', 
  children,
  ...props 
}) => {
  // Use a safe context consumer pattern that works with SSR
  return (
    <SelectContext.Consumer>
      {(context) => {
        if (!context) {
          // Fallback for when used outside Select
          return (
            <div
              className={`flex items-center justify-between w-full px-3 py-2 border border-gray-300 rounded-md cursor-pointer ${className}`}
              {...props}
            >
              {children}
            </div>
          );
        }

        const { isOpen, setIsOpen, disabled } = context;

        return (
          <div
            className={`flex items-center justify-between w-full px-3 py-2 border border-gray-300 rounded-md cursor-pointer ${isOpen ? 'ring-2 ring-blue-500 border-transparent' : ''} ${disabled ? 'opacity-50 cursor-not-allowed' : ''} ${className}`}
            onClick={() => !disabled && setIsOpen(!isOpen)}
            aria-expanded={isOpen}
            role="button"
            tabIndex={disabled ? -1 : 0}
            {...props}
          >
            {children}
            <svg 
              xmlns="http://www.w3.org/2000/svg" 
              width="16" 
              height="16" 
              viewBox="0 0 24 24" 
              fill="none" 
              stroke="currentColor" 
              strokeWidth="2" 
              strokeLinecap="round" 
              strokeLinejoin="round"
              className={`ml-2 transition-transform ${isOpen ? 'transform rotate-180' : ''}`}
              aria-hidden="true"
            >
              <polyline points="6 9 12 15 18 9"></polyline>
            </svg>
          </div>
        );
      }}
    </SelectContext.Consumer>
  );
};

// SelectValue component
interface SelectValueProps extends React.HTMLAttributes<HTMLSpanElement> {
  placeholder?: string;
  children?: React.ReactNode;
}

export const SelectValue: React.FC<SelectValueProps> = ({ 
  className = '', 
  placeholder,
  children,
  ...props 
}) => {
  // Use a safe context consumer pattern that works with SSR
  return (
    <SelectContext.Consumer>
      {(context) => {
        if (!context) {
          // Fallback for when used outside Select
          return (
            <span className={`text-sm ${className}`} {...props}>
              {children || placeholder}
            </span>
          );
        }

        const { value } = context;
        let selectedLabel = value;
        
        // Find the selected item's label from children if available
        if (children) {
          React.Children.forEach(children, child => {
            if (React.isValidElement(child)) {
              const childProps = child.props as any;
              if (childProps && childProps.value === value) {
                selectedLabel = childProps.children;
              }
            }
          });
        }

        return (
          <span 
            className={`text-sm ${!value ? 'text-gray-500' : ''} ${className}`} 
            {...props}
          >
            {value ? selectedLabel : placeholder}
          </span>
        );
      }}
    </SelectContext.Consumer>
  );
};

// SelectContent component
interface SelectContentProps extends React.HTMLAttributes<HTMLDivElement> {
  className?: string;
  children?: React.ReactNode;
}

export const SelectContent: React.FC<SelectContentProps> = ({ 
  className = '', 
  children,
  ...props 
}) => {
  // Use a safe context consumer pattern that works with SSR
  return (
    <SelectContext.Consumer>
      {(context) => {
        if (!context) {
          // Fallback for when used outside Select
          return (
            <div
              className={`absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg ${className}`}
              role="listbox"
              {...props}
            >
              {children}
            </div>
          );
        }

        const { isOpen } = context;

        // Don't render if not open
        if (!isOpen) return null;

        return (
          <div
            className={`absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg max-h-60 overflow-auto ${className}`}
            role="listbox"
            {...props}
          >
            {children}
          </div>
        );
      }}
    </SelectContext.Consumer>
  );
};

// SelectItem component
interface SelectItemProps extends React.HTMLAttributes<HTMLDivElement> {
  value: string;
  className?: string;
  children?: React.ReactNode;
}

export const SelectItem: React.FC<SelectItemProps> = ({ 
  className = '', 
  value,
  children,
  ...props 
}) => {
  // Use a safe context consumer pattern that works with SSR
  return (
    <SelectContext.Consumer>
      {(context) => {
        if (!context) {
          // Fallback for when used outside Select
          return (
            <div
              className={`px-3 py-2 text-sm cursor-pointer hover:bg-gray-100 ${className}`}
              role="option"
              {...props}
            >
              {children}
            </div>
          );
        }

        const { value: selectedValue, onValueChange } = context;
        const isSelected = selectedValue === value;

        return (
          <div
            className={`px-3 py-2 text-sm cursor-pointer ${isSelected ? 'bg-blue-50 text-blue-600' : 'hover:bg-gray-100'} ${className}`}
            onClick={() => onValueChange(value)}
            role="option"
            aria-selected={isSelected}
            {...props}
          >
            {children}
          </div>
        );
      }}
    </SelectContext.Consumer>
  );
};

// Tabs components
interface TabsProps extends React.HTMLAttributes<HTMLDivElement> {
  defaultValue?: string;
}

export const Tabs: React.FC<TabsProps> = ({ 
  className = '', 
  ...props 
}) => (
  <div className={className} {...props} />
);

export const TabsList: React.FC<React.HTMLAttributes<HTMLDivElement>> = ({ 
  className = '', 
  ...props 
}) => (
  <div className={`flex space-x-1 border-b ${className}`} {...props} />
);

export const TabsTrigger: React.FC<React.ButtonHTMLAttributes<HTMLButtonElement> & { value: string }> = ({ 
  className = '', 
  ...props 
}) => (
  <button
    className={`px-4 py-2 text-sm font-medium transition-colors ${className}`}
    {...props}
  />
);

export const TabsContent: React.FC<React.HTMLAttributes<HTMLDivElement> & { value: string }> = ({ 
  className = '', 
  ...props 
}) => (
  <div className={`py-4 ${className}`} {...props} />
);

// Create a context for the Dialog component
interface DialogContextType {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

const DialogContext = React.createContext<DialogContextType | undefined>(undefined);

// Dialog components
interface DialogProps {
  open?: boolean;
  onOpenChange?: (open: boolean) => void;
  children?: React.ReactNode;
  className?: string;
  [x: string]: any; // Allow any other props
}

export const Dialog: React.FC<DialogProps> = ({ 
  open = false,
  onOpenChange,
  children,
  ...props 
}) => {
  // Use state if no controlled value is provided
  const [internalOpen, setInternalOpen] = React.useState(open);
  
  // Update internal state when open prop changes
  React.useEffect(() => {
    setInternalOpen(open);
  }, [open]);
  
  // Handle open state changes
  const handleOpenChange = React.useCallback((newOpen: boolean) => {
    setInternalOpen(newOpen);
    if (onOpenChange) {
      onOpenChange(newOpen);
    }
  }, [onOpenChange]);
  
  // Context value for child components
  const contextValue = React.useMemo(() => ({
    open: internalOpen,
    onOpenChange: handleOpenChange
  }), [internalOpen, handleOpenChange]);
  
  // Filter out the onOpenChange prop before passing to DOM element
  const { onOpenChange: _, ...filteredProps } = props;
  
  return (
    <DialogContext.Provider value={contextValue}>
      <div {...filteredProps}>
        {children}
      </div>
    </DialogContext.Provider>
  );
};

interface DialogTriggerProps {
  className?: string;
  onClick?: React.MouseEventHandler<HTMLButtonElement>;
  asChild?: boolean;
  children?: React.ReactNode;
  [x: string]: any; // Allow any other props
}

export const DialogTrigger: React.FC<DialogTriggerProps> = ({ 
  className = '', 
  onClick,
  asChild,
  ...props 
}) => {
  // Use context consumer to avoid hooks conditionally
  return (
    <DialogContext.Consumer>
      {(context) => {
        const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
          if (onClick) {
            onClick(e);
          }
          if (context) {
            context.onOpenChange(true);
          }
        };
        
        // Filter out the asChild prop before passing to DOM element
        const { asChild: _, ...filteredProps } = props;
        
        return (
          <button 
            className={className} 
            onClick={handleClick}
            {...filteredProps} 
          />
        );
      }}
    </DialogContext.Consumer>
  );
};

export const DialogContent: React.FC<React.HTMLAttributes<HTMLDivElement>> = ({ 
  className = '', 
  children,
  ...props 
}) => {
  return (
    <DialogContext.Consumer>
      {(context) => {
        if (!context || !context.open) {
          return null;
        }
        
        return (
          <div
            className={`fixed inset-0 z-50 flex items-center justify-center p-4 bg-black bg-opacity-50`}
            onClick={(e) => {
              if (e.target === e.currentTarget) {
                context.onOpenChange(false);
              }
            }}
          >
            <div
              className={`bg-white rounded-lg shadow-lg max-w-md w-full max-h-[85vh] overflow-auto ${className}`}
              onClick={(e) => e.stopPropagation()}
              {...props}
            >
              {children}
            </div>
          </div>
        );
      }}
    </DialogContext.Consumer>
  );
};

export const DialogHeader: React.FC<React.HTMLAttributes<HTMLDivElement>> = ({ 
  className = '', 
  ...props 
}) => (
  <div className={`p-6 pb-3 ${className}`} {...props} />
);

export const DialogTitle: React.FC<React.HTMLAttributes<HTMLHeadingElement>> = ({ 
  className = '', 
  children,
  ...props 
}) => (
  <h2 className={`text-lg font-medium ${className}`} {...props}>{children}</h2>
);

export const DialogFooter: React.FC<React.HTMLAttributes<HTMLDivElement>> = ({ 
  className = '', 
  ...props 
}) => (
  <div className={`flex justify-end space-x-2 p-6 pt-3 ${className}`} {...props} />
);

interface DialogCloseProps {
  className?: string;
  onClick?: React.MouseEventHandler<HTMLButtonElement>;
  asChild?: boolean;
  children?: React.ReactNode;
  [x: string]: any; // Allow any other props
}

export const DialogClose: React.FC<DialogCloseProps> = ({ 
  className = '', 
  onClick,
  asChild,
  ...props 
}) => {
  return (
    <DialogContext.Consumer>
      {(context) => {
        const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
          if (onClick) {
            onClick(e);
          }
          if (context) {
            context.onOpenChange(false);
          }
        };
        
        // Filter out the asChild prop before passing to DOM element
        const { asChild: _, ...filteredProps } = props;
        
        return (
          <button 
            className={className} 
            onClick={handleClick}
            {...filteredProps} 
          />
        );
      }}
    </DialogContext.Consumer>
  );
};

// Alert components
interface AlertProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: 'default' | 'destructive';
}

export const Alert: React.FC<AlertProps> = ({ 
  className = '', 
  variant = 'default',
  ...props 
}) => {
  const variantClasses = {
    default: 'bg-gray-50 border-gray-200',
    destructive: 'bg-red-50 border-red-200 text-red-800'
  };

  return (
    <div
      className={`p-4 rounded-md border ${variantClasses[variant]} ${className}`}
      role="alert"
      {...props}
    />
  );
};

export const AlertTitle: React.FC<React.HTMLAttributes<HTMLHeadingElement>> = ({ 
  className = '', 
  children,
  ...props 
}) => (
  <h5 className={`font-medium mb-1 ${className}`} {...props}>{children}</h5>
);

export const AlertDescription: React.FC<React.HTMLAttributes<HTMLParagraphElement>> = ({ 
  className = '', 
  ...props 
}) => (
  <p className={`text-sm ${className}`} {...props} />
);
