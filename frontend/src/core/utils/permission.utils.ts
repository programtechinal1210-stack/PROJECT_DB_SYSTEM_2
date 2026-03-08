export const permissionUtils = {
  hasPermission: (userPermissions: string[], requiredPermission: string): boolean => {
    return userPermissions.includes(requiredPermission);
  },

  hasAnyPermission: (userPermissions: string[], requiredPermissions: string[]): boolean => {
    return requiredPermissions.some(p => userPermissions.includes(p));
  },

  hasAllPermissions: (userPermissions: string[], requiredPermissions: string[]): boolean => {
    return requiredPermissions.every(p => userPermissions.includes(p));
  },

  filterPermissionsByModule: (permissions: string[], moduleCode: string): string[] => {
    return permissions.filter(p => p.startsWith(moduleCode.toLowerCase()));
  },

  getPermissionAction: (permissionCode: string): string => {
    const parts = permissionCode.split('.');
    return parts.length > 1 ? parts[1] : '';
  },

  getPermissionResource: (permissionCode: string): string => {
    const parts = permissionCode.split('.');
    return parts.length > 0 ? parts[0] : '';
  },
};