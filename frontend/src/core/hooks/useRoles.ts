import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { rolesService } from '../api/services/roles.service';
import { CreateRoleRequest, UpdateRoleRequest } from '../types/role.types';

export const useRoles = (includeSystem?: boolean, searchTerm?: string) => {
  return useQuery({
    queryKey: ['roles', { includeSystem, searchTerm }],
    queryFn: () => rolesService.getRoles(includeSystem, searchTerm),
  });
};

export const useRole = (id: number) => {
  return useQuery({
    queryKey: ['role', id],
    queryFn: () => rolesService.getRoleById(id),
    enabled: !!id,
  });
};

export const useCreateRole = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (request: CreateRoleRequest) => rolesService.createRole(request),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['roles'] });
    },
  });
};

export const useUpdateRole = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ id, request }: { id: number; request: UpdateRoleRequest }) =>
      rolesService.updateRole(id, request),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['roles'] });
      queryClient.invalidateQueries({ queryKey: ['role', variables.id] });
    },
  });
};

export const useDeleteRole = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (id: number) => rolesService.deleteRole(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['roles'] });
    },
  });
};

export const useAssignPermission = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ roleId, permissionId }: { roleId: number; permissionId: number }) =>
      rolesService.assignPermission(roleId, permissionId),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['role', variables.roleId] });
      queryClient.invalidateQueries({ queryKey: ['role-permissions', variables.roleId] });
    },
  });
};

export const useRolePermissions = (roleId: number) => {
  return useQuery({
    queryKey: ['role-permissions', roleId],
    queryFn: () => rolesService.getRolePermissions(roleId),
    enabled: !!roleId,
  });
};