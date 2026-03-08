import { useAuthStore } from '../store/authStore';
import { usePermissionStore } from '../store/permissionStore';

export const usePermissions = () => {
  const { hasPermission: authHasPermission } = useAuthStore();
  const { permissions, loadPermissions, hasPermission, hasAnyPermission, hasAllPermissions } = usePermissionStore();

  return {
    permissions,
    loadPermissions,
    hasPermission: authHasPermission || hasPermission,
    hasAnyPermission,
    hasAllPermissions,
  };
};