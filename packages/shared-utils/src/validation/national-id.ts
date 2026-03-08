export interface NationalIdValidationResult {
  isValid: boolean;
  errors: string[];
  details?: {
    birthDate?: Date;
    gender?: 'male' | 'female';
    governorate?: string;
  };
}

export class NationalIdValidator {
  /**
   * Validates Egyptian National ID
   * Format: 2 99 01 01 1234 5
   * - Century: 2 (2000+), 3 (1900-1999)
   * - Birth year: 99 (last 2 digits)
   * - Birth month: 01-12
   * - Birth day: 01-31
   * - Governorate code: 01-99
   * - Sequence: 0001-9999
   * - Check digit: 0-9
   */
  static validateEgyptianNationalId(id: string): NationalIdValidationResult {
    const errors: string[] = [];
    
    // Check length
    if (!id || id.length !== 14) {
      errors.push('National ID must be exactly 14 digits');
      return { isValid: false, errors };
    }
    
    // Check if all digits
    if (!/^\d+$/.test(id)) {
      errors.push('National ID must contain only digits');
      return { isValid: false, errors };
    }
    
    // Parse parts
    const century = parseInt(id.substring(0, 1), 10);
    const year = parseInt(id.substring(1, 3), 10);
    const month = parseInt(id.substring(3, 5), 10);
    const day = parseInt(id.substring(5, 7), 10);
    const governorate = id.substring(7, 9);
    const sequence = id.substring(9, 13);
    const checkDigit = parseInt(id.substring(13, 14), 10);
    
    // Validate century
    if (century !== 2 && century !== 3) {
      errors.push('Century must be 2 (2000+) or 3 (1900-1999)');
    }
    
    // Validate month
    if (month < 1 || month > 12) {
      errors.push('Month must be between 01 and 12');
    }
    
    // Validate day based on month
    const fullYear = century === 2 ? 2000 + year : 1900 + year;
    const date = new Date(fullYear, month - 1, day);
    
    if (date.getFullYear() !== fullYear || 
        date.getMonth() !== month - 1 || 
        date.getDate() !== day) {
      errors.push('Invalid birth date');
    }
    
    // Validate governorate code (basic range)
    const govCode = parseInt(governorate, 10);
    if (govCode < 1 || govCode > 99) {
      errors.push('Invalid governorate code');
    }
    
    // Validate sequence
    const seqNum = parseInt(sequence, 10);
    if (seqNum < 1 || seqNum > 9999) {
      errors.push('Invalid sequence number');
    }
    
    // Validate check digit (simple algorithm)
    const calculatedCheckDigit = this.calculateEgyptianCheckDigit(id);
    if (checkDigit !== calculatedCheckDigit) {
      errors.push('Invalid check digit');
    }
    
    if (errors.length > 0) {
      return { isValid: false, errors };
    }
    
    // Build details
    const details = {
      birthDate: new Date(fullYear, month - 1, day),
      gender: seqNum % 2 === 0 ? 'female' : 'male',
      governorate: this.getEgyptianGovernorateName(governorate)
    };
    
    return {
      isValid: true,
      errors: [],
      details
    };
  }
  
  /**
   * Validates Saudi National ID
   * Format: 1 01 01 0101 (10 digits for nationals)
   * Format: 2 01 01 0101 (10 digits for residents)
   */
  static validateSaudiNationalId(id: string): NationalIdValidationResult {
    const errors: string[] = [];
    
    if (!id || id.length !== 10) {
      errors.push('Saudi National ID must be exactly 10 digits');
      return { isValid: false, errors };
    }
    
    if (!/^\d+$/.test(id)) {
      errors.push('National ID must contain only digits');
      return { isValid: false, errors };
    }
    
    const type = parseInt(id.substring(0, 1), 10);
    
    if (type !== 1 && type !== 2) {
      errors.push('First digit must be 1 (Saudi) or 2 (Resident)');
    }
    
    // Luhn algorithm check
    if (!this.validateLuhn(id)) {
      errors.push('Invalid ID number (checksum failed)');
    }
    
    return {
      isValid: errors.length === 0,
      errors,
      details: {
        gender: parseInt(id.substring(9, 10), 10) % 2 === 0 ? 'female' : 'male',
        type: type === 1 ? 'citizen' : 'resident'
      }
    };
  }
  
  /**
   * Validates UAE National ID
   * Format: 784-XXXX-XXXXXXX-X
   */
  static validateUaeNationalId(id: string): NationalIdValidationResult {
    const errors: string[] = [];
    
    // Remove dashes and spaces
    const cleanId = id.replace(/[-\s]/g, '');
    
    if (cleanId.length !== 15) {
      errors.push('UAE National ID must be 15 digits (784-XXXX-XXXXXXX-X)');
      return { isValid: false, errors };
    }
    
    if (!/^\d+$/.test(cleanId)) {
      errors.push('National ID must contain only digits');
      return { isValid: false, errors };
    }
    
    const countryCode = cleanId.substring(0, 3);
    
    if (countryCode !== '784') {
      errors.push('Invalid country code (must be 784 for UAE)');
    }
    
    // Validate checksum
    const checkDigit = parseInt(cleanId.substring(14, 15), 10);
    const calculatedCheck = this.calculateUaeCheckDigit(cleanId);
    
    if (checkDigit !== calculatedCheck) {
      errors.push('Invalid check digit');
    }
    
    return {
      isValid: errors.length === 0,
      errors,
      details: {
        nationality: 'UAE',
        birthYear: parseInt(cleanId.substring(7, 11), 10)
      }
    };
  }
  
  /**
   * Calculate check digit for Egyptian ID (simplified)
   */
  private static calculateEgyptianCheckDigit(id: string): number {
    // This is a simplified implementation
    // Real implementation would use government algorithm
    let sum = 0;
    for (let i = 0; i < 13; i++) {
      sum += parseInt(id[i], 10) * (i + 1);
    }
    return sum % 10;
  }
  
  /**
   * Validate using Luhn algorithm
   */
  private static validateLuhn(number: string): boolean {
    let sum = 0;
    let alternate = false;
    
    for (let i = number.length - 1; i >= 0; i--) {
      let n = parseInt(number[i], 10);
      
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      
      sum += n;
      alternate = !alternate;
    }
    
    return sum % 10 === 0;
  }
  
  /**
   * Calculate UAE check digit
   */
  private static calculateUaeCheckDigit(id: string): number {
    // Simplified implementation
    let sum = 0;
    for (let i = 0; i < 14; i++) {
      sum += parseInt(id[i], 10) * (i + 1);
    }
    return sum % 10;
  }
  
  /**
   * Get Egyptian governorate name from code
   */
  private static getEgyptianGovernorateName(code: string): string {
    const governorates: { [key: string]: string } = {
      '01': 'Cairo',
      '02': 'Alexandria',
      '03': 'Port Said',
      '04': 'Suez',
      '11': 'Damietta',
      '12': 'Dakahlia',
      '13': 'Ash Sharqia',
      '14': 'Qalyubia',
      '15': 'Kafr El Sheikh',
      '16': 'Gharbia',
      '17': 'Monufia',
      '18': 'Beheira',
      '19': 'Ismailia',
      '21': 'Giza',
      '22': 'Beni Suef',
      '23': 'Fayoum',
      '24': 'Minya',
      '25': 'Asyut',
      '26': 'Sohag',
      '27': 'Qena',
      '28': 'Aswan',
      '29': 'Luxor',
      '31': 'Red Sea',
      '32': 'New Valley',
      '33': 'Matrouh',
      '34': 'North Sinai',
      '35': 'South Sinai'
    };
    
    return governorates[code] || 'Unknown';
  }
}