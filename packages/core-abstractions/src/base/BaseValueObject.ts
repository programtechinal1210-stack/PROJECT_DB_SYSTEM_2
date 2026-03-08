 
/**
 * Base Value Object class following DDD principles
 * All value objects should inherit from this class
 */
export abstract class BaseValueObject {
  /**
   * Compares two value objects for equality
   */
  public abstract equals(other: BaseValueObject): boolean;

  /**
   * Returns the atomic values of the value object
   */
  protected abstract getAtomicValues(): any[];

  /**
   * Checks if this value object is equal to another
   */
  protected isEqual(other: BaseValueObject): boolean {
    if (other == null || other.constructor !== this.constructor) {
      return false;
    }

    const thisValues = this.getAtomicValues();
    const otherValues = other.getAtomicValues();

    if (thisValues.length !== otherValues.length) {
      return false;
    }

    for (let i = 0; i < thisValues.length; i++) {
      if (thisValues[i] !== otherValues[i]) {
        return false;
      }
    }

    return true;
  }
}