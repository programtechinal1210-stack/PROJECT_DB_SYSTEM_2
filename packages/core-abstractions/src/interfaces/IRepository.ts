 
import { BaseEntity } from '../base/BaseEntity';

/**
 * Generic repository interface
 * Follows the Repository pattern
 */
export interface IRepository<T extends BaseEntity, TId = string> {
  /**
   * Gets an entity by its ID
   */
  getById(id: TId): Promise<T | null>;

  /**
   * Gets all entities
   */
  getAll(): Promise<T[]>;

  /**
   * Adds a new entity
   */
  add(entity: T): Promise<T>;

  /**
   * Updates an existing entity
   */
  update(entity: T): Promise<T>;

  /**
   * Deletes an entity by its ID
   */
  delete(id: TId): Promise<boolean>;

  /**
   * Checks if an entity exists
   */
  exists(id: TId): Promise<boolean>;

  /**
   * Saves changes (if needed for the implementation)
   */
  saveChanges(): Promise<void>;
}

/**
 * Specification pattern for queries
 */
export interface ISpecification<T extends BaseEntity> {
  /**
   * Checks if an entity satisfies the specification
   */
  isSatisfiedBy(entity: T): boolean;

  /**
   * Converts the specification to a query expression
   */
  toExpression(): (entity: T) => boolean;
}

/**
 * Query repository with specification support
 */
export interface IQueryRepository<T extends BaseEntity, TId = string> extends IRepository<T, TId> {
  /**
   * Finds entities matching the specification
   */
  find(specification: ISpecification<T>): Promise<T[]>;

  /**
   * Finds a single entity matching the specification
   */
  findOne(specification: ISpecification<T>): Promise<T | null>;

  /**
   * Counts entities matching the specification
   */
  count(specification: ISpecification<T>): Promise<number>;
}

/**
 * Unit of Work pattern
 */
export interface IUnitOfWork {
  /**
   * Begins a transaction
   */
  beginTransaction(): Promise<void>;

  /**
   * Commits the transaction
   */
  commitTransaction(): Promise<void>;

  /**
   * Rolls back the transaction
   */
  rollbackTransaction(): Promise<void>;

  /**
   * Saves all changes
   */
  saveChanges(): Promise<void>;
}