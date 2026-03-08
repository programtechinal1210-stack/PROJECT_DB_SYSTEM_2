 
export class DateUtils {
  /**
   * Formats a date to ISO string without milliseconds
   */
  static toISOString(date: Date): string {
    return date.toISOString().split('.')[0] + 'Z';
  }

  /**
   * Adds days to a date
   */
  static addDays(date: Date, days: number): Date {
    const result = new Date(date);
    result.setDate(result.getDate() + days);
    return result;
  }

  /**
   * Adds months to a date
   */
  static addMonths(date: Date, months: number): Date {
    const result = new Date(date);
    result.setMonth(result.getMonth() + months);
    return result;
  }

  /**
   * Adds years to a date
   */
  static addYears(date: Date, years: number): Date {
    const result = new Date(date);
    result.setFullYear(result.getFullYear() + years);
    return result;
  }

  /**
   * Gets the start of the day
   */
  static startOfDay(date: Date): Date {
    const result = new Date(date);
    result.setHours(0, 0, 0, 0);
    return result;
  }

  /**
   * Gets the end of the day
   */
  static endOfDay(date: Date): Date {
    const result = new Date(date);
    result.setHours(23, 59, 59, 999);
    return result;
  }

  /**
   * Gets the start of the month
   */
  static startOfMonth(date: Date): Date {
    const result = new Date(date);
    result.setDate(1);
    result.setHours(0, 0, 0, 0);
    return result;
  }

  /**
   * Gets the end of the month
   */
  static endOfMonth(date: Date): Date {
    const result = new Date(date);
    result.setMonth(result.getMonth() + 1);
    result.setDate(0);
    result.setHours(23, 59, 59, 999);
    return result;
  }

  /**
   * Calculates difference in days between two dates
   */
  static diffInDays(date1: Date, date2: Date): number {
    const diffTime = Math.abs(date2.getTime() - date1.getTime());
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  }

  /**
   * Checks if a date is between two dates
   */
  static isBetween(date: Date, start: Date, end: Date): boolean {
    return date >= start && date <= end;
  }

  /**
   * Formats a date to a string
   */
  static format(date: Date, format: string = 'YYYY-MM-DD'): string {
    const map: { [key: string]: string } = {
      YYYY: date.getFullYear().toString(),
      MM: String(date.getMonth() + 1).padStart(2, '0'),
      DD: String(date.getDate()).padStart(2, '0'),
      HH: String(date.getHours()).padStart(2, '0'),
      mm: String(date.getMinutes()).padStart(2, '0'),
      ss: String(date.getSeconds()).padStart(2, '0')
    };

    return format.replace(/YYYY|MM|DD|HH|mm|ss/g, matched => map[matched]);
  }

  /**
   * Parses a date string
   */
  static parse(dateString: string, format: string = 'YYYY-MM-DD'): Date | null {
    // Simple implementation - in production, use a library like date-fns
    const parts = dateString.split(/[-/ :]/);
    const formatParts = format.split(/[-/ :]/);
    
    if (parts.length !== formatParts.length) {
      return null;
    }

    const dateValues: any = {};
    
    for (let i = 0; i < formatParts.length; i++) {
      dateValues[formatParts[i]] = parseInt(parts[i], 10);
    }

    const year = dateValues['YYYY'] || new Date().getFullYear();
    const month = (dateValues['MM'] || 1) - 1;
    const day = dateValues['DD'] || 1;
    const hour = dateValues['HH'] || 0;
    const minute = dateValues['mm'] || 0;
    const second = dateValues['ss'] || 0;

    return new Date(year, month, day, hour, minute, second);
  }
}