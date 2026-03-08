 
/**
 * Base Domain Exception
 * Thrown when domain rules are violated
 */
export class DomainException extends Error {
  public readonly code: string;
  public readonly details?: Record<string, any>;

  constructor(message: string, code: string = 'DOMAIN_ERROR', details?: Record<string, any>) {
    super(message);
    this.name = 'DomainException';
    this.code = code;
    this.details = details;
    
    // Maintains proper stack trace
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, DomainException);
    }
  }
}

/**
 * Business rule violation exception
 */
export class BusinessRuleViolationException extends DomainException {
  constructor(message: string, details?: Record<string, any>) {
    super(message, 'BUSINESS_RULE_VIOLATION', details);
    this.name = 'BusinessRuleViolationException';
  }
}

/**
 * Entity not found exception
 */
export class EntityNotFoundException extends DomainException {
  constructor(entityName: string, entityId: string | number) {
    super(
      `${entityName} with id ${entityId} not found`,
      'ENTITY_NOT_FOUND',
      { entityName, entityId }
    );
    this.name = 'EntityNotFoundException';
  }
}

/**
 * Invalid state exception
 */
export class InvalidStateException extends DomainException {
  constructor(message: string, details?: Record<string, any>) {
    super(message, 'INVALID_STATE', details);
    this.name = 'InvalidStateException';
  }
}