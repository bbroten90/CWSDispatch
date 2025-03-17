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

// Select components
interface SelectProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
  onValueChange?: (value: string) => void;
  disabled?: boolean;
}

export const Select: React.FC<SelectProps> = ({ 
  className = '', 
  onValueChange, 
  onChange,
  children, 
  ...props 
}) => {
  const handleChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    if (onChange) {
      onChange(e);
    }
    if (onValueChange) {
      onValueChange(e.target.value);
    }
  };

  return (
    <select
      className={`w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent ${className}`}
      onChange={handleChange}
      {...props}
    >
      {children}
    </select>
  );
};

// Simplified versions of the other components
export const SelectTrigger: React.FC<React.HTMLAttributes<HTMLDivElement>> = ({ 
  className = '', 
  ...props 
}) => (
  <div
    className={`flex items-center justify-between w-full px-3 py-2 border border-gray-300 rounded-md cursor-pointer ${className}`}
    {...props}
  />
);

export const SelectValue: React.FC<React.HTMLAttributes<HTMLSpanElement> & { placeholder?: string }> = ({ 
  className = '', 
  placeholder,
  children,
  ...props 
}) => (
  <span className={`text-sm ${className}`} {...props}>
    {children || placeholder}
  </span>
);

export const SelectContent: React.FC<React.HTMLAttributes<HTMLDivElement>> = ({ 
  className = '', 
  ...props 
}) => (
  <div
    className={`absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg ${className}`}
    {...props}
  />
);

export const SelectItem: React.FC<React.HTMLAttributes<HTMLDivElement> & { value: string }> = ({ 
  className = '', 
  ...props 
}) => (
  <div
    className={`px-3 py-2 text-sm cursor-pointer hover:bg-gray-100 ${className}`}
    {...props}
  />
);

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

// Dialog components
interface DialogProps extends React.HTMLAttributes<HTMLDivElement> {
  open?: boolean;
  onOpenChange?: (open: boolean) => void;
}

export const Dialog: React.FC<DialogProps> = ({ 
  ...props 
}) => (
  <div {...props} />
);

export const DialogTrigger: React.FC<React.ButtonHTMLAttributes<HTMLButtonElement> & { asChild?: boolean }> = ({ 
  className = '', 
  ...props 
}) => (
  <button className={className} {...props} />
);

export const DialogContent: React.FC<React.HTMLAttributes<HTMLDivElement>> = ({ 
  className = '', 
  ...props 
}) => (
  <div
    className={`bg-white rounded-lg shadow-lg max-w-md w-full max-h-[85vh] overflow-auto ${className}`}
    {...props}
  />
);

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

export const DialogClose: React.FC<React.ButtonHTMLAttributes<HTMLButtonElement> & { asChild?: boolean }> = ({ 
  className = '', 
  ...props 
}) => (
  <button className={className} {...props} />
);

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
