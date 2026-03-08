 
/**
 * Base Entity class following DDD principles
 * All domain entities should inherit from this class
 */
export abstract class BaseEntity<TId = string> {
  public readonly id: TId;
  public readonly createdAt: Date;
  public updatedAt: Date;
  private _domainEvents: DomainEvent[] = [];

  constructor(id: TId) {
    this.id = id;
    this.createdAt = new Date();
    this.updatedAt = new Date();
  }

  /**
   * Compares entities by their IDs
   */
  public equals(other: BaseEntity<TId>): boolean {
    if (other == null || other.constructor !== this.constructor) {
      return false;
    }
    return this.id === other.id;
  }

  /**
   * Adds a domain event to be dispatched
   */
  protected addDomainEvent(event: DomainEvent): void {
    this._domainEvents.push(event);
  }

  /**
   * Gets and clears all domain events
   */
  public getDomainEvents(): DomainEvent[] {
    const events = [...this._domainEvents];
    this.clearDomainEvents();
    return events;
  }

  /**
   * Clears all domain events
   */
  public clearDomainEvents(): void {
    this._domainEvents = [];
  }
}

/**
 * Base Domain Event interface
 */
export interface DomainEvent {
  readonly eventId: string;
  readonly occurredOn: Date;
  readonly eventType: string;
  readonly aggregateId: string;
}