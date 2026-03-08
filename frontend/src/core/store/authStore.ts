import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { AuthState, UserInfo, LoginRequest } from '../types/auth.types';
import { authService } from '../api/services/auth.service';
import { tokenUtils } from '../utils/token.utils';

interface AuthStore extends AuthState {
  login: (request: LoginRequest) => Promise<void>;
  logout: () => Promise<void>;
  logoutAll: () => Promise<void>;
  refreshUser: () => Promise<void>;
  setUser: (user: UserInfo | null) => void;
  setLoading: (isLoading: boolean) => void;
  setError: (error: string | null) => void;
  hasPermission: (permissionCode: string) => boolean;
  hasRole: (roleName: string) => boolean;
}

export const useAuthStore = create<AuthStore>()(
  persist(
    (set, get) => ({
      user: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,

      login: async (request: LoginRequest) => {
        set({ isLoading: true, error: null });
        try {
          const response = await authService.login(request);
          tokenUtils.setAccessToken(response.accessToken);
          tokenUtils.setRefreshToken(response.refreshToken);
          set({ 
            user: response.user, 
            isAuthenticated: true, 
            isLoading: false 
          });
        } catch (error: any) {
          set({ 
            error: error.message || 'Login failed', 
            isLoading: false 
          });
          throw error;
        }
      },

      logout: async () => {
        try {
          await authService.logout();
        } finally {
          tokenUtils.clearTokens();
          set({ user: null, isAuthenticated: false });
        }
      },

      logoutAll: async () => {
        try {
          await authService.logoutAll();
        } finally {
          tokenUtils.clearTokens();
          set({ user: null, isAuthenticated: false });
        }
      },

      refreshUser: async () => {
        if (!tokenUtils.getAccessToken()) return;
        
        set({ isLoading: true });
        try {
          const user = await authService.getCurrentUser();
          set({ user, isAuthenticated: true, isLoading: false });
        } catch (error) {
          tokenUtils.clearTokens();
          set({ user: null, isAuthenticated: false, isLoading: false });
        }
      },

      setUser: (user) => set({ user, isAuthenticated: !!user }),
      setLoading: (isLoading) => set({ isLoading }),
      setError: (error) => set({ error }),

      hasPermission: (permissionCode: string) => {
        const { user } = get();
        return user?.permissions?.includes(permissionCode) || false;
      },

      hasRole: (roleName: string) => {
        const { user } = get();
        return user?.roles?.includes(roleName) || false;
      },
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({ user: state.user, isAuthenticated: state.isAuthenticated }),
    }
  )
);