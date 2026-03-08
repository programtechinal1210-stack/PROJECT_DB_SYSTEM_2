export interface User {
  id: number;
  username: string;
  email: string;
  isActive: boolean;
  lastLogin?: string;
  employeeId?: number;
  createdAt: string;
  updatedAt: string;
  roles: string[];
}

export interface UserDto {
  id: number;
  username: string;
  email: string;
  isActive: boolean;
  lastLogin?: string;
  employeeId?: number;
  createdAt: string;
  updatedAt: string;
  roles: string[];
}

export interface CreateUserRequest {
  username: string;
  email: string;
  password: string;
  confirmPassword: string;
  employeeId?: number;
  roleIds?: number[];
}

export interface UpdateUserRequest {
  username?: string;
  email?: string;
  password?: string;
  confirmPassword?: string;
  isActive?: boolean;
}

export interface PagedResult<T> {
  items: T[];
  totalCount: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface UserFilters {
  pageNumber?: number;
  pageSize?: number;
  searchTerm?: string;
  isActive?: boolean;
  sortBy?: string;
  sortDescending?: boolean;
}

export interface UserRole {
  userId: number;
  roleId: number;
  roleName: string;
  assignedAt: string;
}