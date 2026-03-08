import { apiClient } from '../client';
import { 
  UserDto, 
  CreateUserRequest, 
  UpdateUserRequest,
  PagedResult,
  UserFilters,
  UserRole 
} from '../../types/user.types';

class UsersService {
  private static instance: UsersService;
  private baseUrl = '/users';

  private constructor() {}

  public static getInstance(): UsersService {
    if (!UsersService.instance) {
      UsersService.instance = new UsersService();
    }
    return UsersService.instance;
  }

  async getUsers(filters?: UserFilters): Promise<PagedResult<UserDto>> {
    const params = new URLSearchParams();
    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          params.append(key, value.toString());
        }
      });
    }
    return apiClient.get<PagedResult<UserDto>>(`${this.baseUrl}?${params.toString()}`);
  }

  async getUserById(id: number): Promise<UserDto> {
    return apiClient.get<UserDto>(`${this.baseUrl}/${id}`);
  }

  async getUserByUsername(username: string): Promise<UserDto> {
    return apiClient.get<UserDto>(`${this.baseUrl}/by-username/${username}`);
  }

  async getUserByEmail(email: string): Promise<UserDto> {
    return apiClient.get<UserDto>(`${this.baseUrl}/by-email/${email}`);
  }

  async getUsersByRole(roleId: number): Promise<UserDto[]> {
    return apiClient.get<UserDto[]>(`${this.baseUrl}/by-role/${roleId}`);
  }

  async createUser(request: CreateUserRequest): Promise<UserDto> {
    return apiClient.post<UserDto>(this.baseUrl, request);
  }

  async updateUser(id: number, request: UpdateUserRequest): Promise<UserDto> {
    return apiClient.put<UserDto>(`${this.baseUrl}/${id}`, request);
  }

  async deleteUser(id: number): Promise<void> {
    return apiClient.delete(`${this.baseUrl}/${id}`);
  }

  async activateUser(id: number): Promise<void> {
    return apiClient.post(`${this.baseUrl}/${id}/activate`);
  }

  async deactivateUser(id: number): Promise<void> {
    return apiClient.post(`${this.baseUrl}/${id}/deactivate`);
  }

  async assignRole(userId: number, roleId: number): Promise<void> {
    return apiClient.post(`${this.baseUrl}/${userId}/roles/${roleId}`);
  }

  async removeRole(userId: number, roleId: number): Promise<void> {
    return apiClient.delete(`${this.baseUrl}/${userId}/roles/${roleId}`);
  }

  async getUserRoles(userId: number): Promise<UserRole[]> {
    return apiClient.get<UserRole[]>(`${this.baseUrl}/${userId}/roles`);
  }
}

export const usersService = UsersService.getInstance();