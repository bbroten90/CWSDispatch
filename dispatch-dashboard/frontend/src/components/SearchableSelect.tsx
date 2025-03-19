// src/components/SearchableSelect.tsx
import React, { useState, useEffect, useRef } from 'react';
import { 
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
  Input
} from './ui';
import { Search, X } from 'lucide-react';

interface Option {
  value: string;
  label: string;
  searchText?: string; // Additional text to search against (e.g., customer number)
}

interface SearchableSelectProps {
  options: Option[];
  value: string;
  onValueChange: (value: string) => void;
  placeholder?: string;
  label?: string;
  className?: string;
  required?: boolean;
  showOptionValue?: boolean; // Whether to show the value alongside the label
  disabled?: boolean;
}

const SearchableSelect: React.FC<SearchableSelectProps> = ({
  options,
  value,
  onValueChange,
  placeholder = 'Select an option',
  label,
  className = '',
  required = false,
  showOptionValue = false,
  disabled = false
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [filteredOptions, setFilteredOptions] = useState<Option[]>(options);
  const searchInputRef = useRef<HTMLInputElement | null>(null);
  
  // Reset filtered options when options change
  useEffect(() => {
    setFilteredOptions(options);
  }, [options]);
  
  // Focus search input when dropdown opens
  useEffect(() => {
    if (isOpen && searchInputRef.current) {
      setTimeout(() => {
        searchInputRef.current?.focus();
      }, 100);
    } else {
      setSearchTerm('');
      setFilteredOptions(options);
    }
  }, [isOpen, options]);
  
  // Filter options based on search term
  const handleSearch = (e: React.ChangeEvent<HTMLInputElement>) => {
    const term = e.target.value.toLowerCase();
    setSearchTerm(term);
    
    if (!term) {
      setFilteredOptions(options);
      return;
    }
    
    const filtered = options.filter(option => 
      option.label.toLowerCase().includes(term) || 
      (typeof option.value === 'string' && option.value.toLowerCase().includes(term)) ||
      (option.searchText && option.searchText.toLowerCase().includes(term))
    );
    
    setFilteredOptions(filtered);
  };
  
  // Clear search term
  const clearSearch = () => {
    setSearchTerm('');
    setFilteredOptions(options);
    searchInputRef.current?.focus();
  };
  
  // Get selected option label
  const getSelectedLabel = () => {
    const selected = options.find(option => option.value === value);
    if (!selected) return placeholder;
    
    return showOptionValue 
      ? `${selected.label} (${selected.value})` 
      : selected.label;
  };
  
  return (
    <div className={className}>
      {label && (
        <label className="text-sm font-medium mb-1 block">{label}</label>
      )}
      
      <Select
        value={value}
        onValueChange={(newValue) => {
          onValueChange(newValue);
          setIsOpen(false);
        }}
        required={required}
        disabled={disabled}
        open={isOpen}
        onOpenChange={setIsOpen}
      >
        <SelectTrigger className="w-full">
          <SelectValue placeholder={placeholder}>
            {getSelectedLabel()}
          </SelectValue>
        </SelectTrigger>
        
        <SelectContent className="w-full">
          <div className="p-2 sticky top-0 bg-white z-10 border-b">
            <div className="relative">
              <Search className="absolute left-2 top-2.5 h-4 w-4 text-gray-400" />
              <input
                ref={searchInputRef}
                type="text"
                placeholder="Search..."
                value={searchTerm}
                onChange={handleSearch}
                className="w-full px-3 py-2 pl-8 pr-8 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
              {searchTerm && (
                <button
                  type="button"
                  onClick={clearSearch}
                  className="absolute right-2 top-2.5 text-gray-400 hover:text-gray-600"
                >
                  <X className="h-4 w-4" />
                </button>
              )}
            </div>
          </div>
          
          <div className="max-h-60 overflow-auto">
            {filteredOptions.length === 0 ? (
              <div className="p-2 text-center text-gray-500">No results found</div>
            ) : (
              filteredOptions.map((option) => (
                <SelectItem key={option.value} value={option.value}>
                  {showOptionValue 
                    ? `${option.label} (${option.value})` 
                    : option.label}
                </SelectItem>
              ))
            )}
          </div>
        </SelectContent>
      </Select>
    </div>
  );
};

export default SearchableSelect;
