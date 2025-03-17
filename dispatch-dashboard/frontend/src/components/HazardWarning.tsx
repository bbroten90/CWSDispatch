// src/components/HazardWarning.tsx
import React from 'react';
import { AlertTriangle } from 'lucide-react';

// Since we can't find the UI components, let's create a simple version
// of the tooltip functionality without using the UI components
const HazardWarning: React.FC<{
  hazardCode: string;
  hazardDescription1?: string;
  hazardDescription2?: string;
  hazardDescription3?: string;
}> = ({
  hazardCode,
  hazardDescription1,
  hazardDescription2,
  hazardDescription3
}) => {
  if (!hazardCode) return null;
  
  return (
    <div className="relative group">
      <div className="inline-flex items-center px-2 py-1 bg-yellow-100 text-yellow-800 rounded text-xs cursor-help">
        <AlertTriangle className="h-3 w-3 mr-1" />
        <span>{hazardCode}</span>
      </div>
      
      {/* Tooltip content - shows on hover */}
      <div className="absolute z-10 invisible group-hover:visible bg-black text-white p-2 rounded shadow-lg mt-1 w-48">
        <div className="space-y-1">
          <p className="font-bold">Hazardous Material</p>
          {hazardDescription1 && <p className="text-xs">{hazardDescription1}</p>}
          {hazardDescription2 && <p className="text-xs">{hazardDescription2}</p>}
          {hazardDescription3 && <p className="text-xs">{hazardDescription3}</p>}
        </div>
      </div>
    </div>
  );
};


export default HazardWarning;
