import { create } from 'zustand';
import { authService } from '../api/services/auth.service';

interface PermissionStore {
  permissions: string[];
  isLoading: boolean;
  loadPermissions: () => Promise<void>;
  hasPermission: (permissionCode: string) => boolean;
  hasAnyPermission: (permissionCodes: string[]) => boolean;
  hasAllPermissions: (permissionCodes: string[]) => boolean;
}

export const usePermissionStore = create<PermissionStore>((set, get) => ({
  permissions: [],
  isLoading: false,

  loadPermissions: async () => {
    set({ isLoading: true });
    try {
      const permissions = await authService.getUserPermissions();
      set({ permissions, isLoading: false });
    } catch (error) {
      set({ isLoading: false });
    }
  },

  hasPermission: (permissionCode: string) => {
    return get().permissions.includes(permissionCode);
  },

  hasAnyPermission: (permissionCodes: string[]) => {
    const { permissions } = get();
    return permissionCodes.some(code => permissions.includes(code));
  },

  hasAllPermissions: (permissionCodes: string[]) => {
    const { permissions } = get();
    return permissionCodes.every(code => permissions.includes(code));
  },
}));