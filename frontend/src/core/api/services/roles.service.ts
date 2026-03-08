import { apiClient } from '../client';
import { Role, RoleDetail, CreateRoleRequest, UpdateRoleRequest, Permission } from '../../types/role.types';

class RolesService {
  private static instance: RolesService;
  private baseUrl = '/roles';

  private constructor() {}

  public static getInstance(): RolesService {
    if (!RolesService.instance) {
      RolesService.instance = new RolesService();
    }
    return RolesService.instance;
  }

  async getRoles(includeSystem?: boolean, searchTerm?: string): Promise<Role[]> {
    const params = new URLSearchParams();
    if (includeSystem !== undefined) params.append('includeSystemRoles', includeSystem.toString());
    if (searchTerm) params.append('searchTerm', searchTerm);
    
    return apiClient.get<Role[]>(`${this.baseUrl}?${params.toString()}`);
  }

  async getRoleById(id: number): Promise<RoleDetail> {
    return apiClient.get<RoleDetail>(`${this.baseUrl}/${id}`);
  }

  async getRoleByName(name: string): Promise<Role> {
    return apiClient.get<Role>(`${this.baseUrl}/by-name/${name}`);
  }

  async createRole(request: CreateRoleRequest): Promise<Role> {
    return apiClient.post<Role>(this.baseUrl, request);
  }

  async updateRole(id: number, request: UpdateRoleRequest): Promise<Role> {
    return apiClient.put<Role>(`${this.baseUrl}/${id}`, request);
  }

  async deleteRole(id: number): Promise<void> {
    return apiClient.delete(`${this.baseUrl}/${id}`);
  }

  async assignPermission(roleId: number, permissionId: number): Promise<void> {
    return apiClient.post(`${this.baseUrl}/${roleId}/permissions/${permissionId}`);
  }

  async removePermission(roleId: number, permissionId: number): Promise<void> {
    return apiClient.delete(`${this.baseUrl}/${roleId}/permissions/${permissionId}`);
  }

  async getRolePermissions(roleId: number): Promise<Permission[]> {
    return apiClient.get<Permission[]>(`${this.baseUrl}/${roleId}/permissions`);
  }
}

export const rolesService = RolesService.getInstance();