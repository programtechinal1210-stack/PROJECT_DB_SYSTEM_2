 
import { useEffect } from 'react';
import { useAuthStore } from '../store/authStore';
import { tokenUtils } from '../utils/token.utils';

export const useAuth = () => {
  const { 
    user, 
    isAuthenticated, 
    isLoading, 
    error, 
    login, 
    logout, 
    logoutAll,
    refreshUser,
    hasPermission,
    hasRole 
  } = useAuthStore();

  useEffect(() => {
    const token = tokenUtils.getAccessToken();
    if (token && !isAuthenticated && !isLoading) {
      refreshUser();
    }
  }, []);

  return {
    user,
    isAuthenticated,
    isLoading,
    error,
    login,
    logout,
    logoutAll,
    refreshUser,
    hasPermission,
    hasRole,
  };
};