export interface Role {
  id: number;
  roleName: string;
  roleDescription?: string;
  isSystemRole: boolean;
  createdAt: string;
  updatedAt: string;
  usersCount: number;
  permissionsCount: number;
}

export interface RoleDetail extends Role {
  users: RoleUser[];
  permissions: RolePermission[];
}

export interface RoleUser {
  userId: number;
  username: string;
  email: string;
  assignedAt: string;
}

export interface RolePermission {
  permissionId: number;
  permissionCode: string;
  permissionName: string;
  moduleName: string;
  grantedAt: string;
}

export interface CreateRoleRequest {
  roleName: string;
  description?: string;
  isSystemRole?: boolean;
  permissionIds?: number[];
}

export interface UpdateRoleRequest {
  roleName?: string;
  description?: string;
}

export interface Permission {
  id: number;
  permissionCode: string;
  permissionName: string;
  permissionDescription?: string;
  moduleId: number;
  moduleName: string;
  actionType: string;
}