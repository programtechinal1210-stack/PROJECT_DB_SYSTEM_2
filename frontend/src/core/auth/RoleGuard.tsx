import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuthStore } from '../store/authStore';

interface RoleGuardProps {
  children: React.ReactNode;
  role: string | string[];
  requireAll?: boolean;
  fallbackPath?: string;
}

export const RoleGuard: React.FC<RoleGuardProps> = ({
  children,
  role,
  requireAll = false,
  fallbackPath = '/unauthorized',
}) => {
  const { hasRole } = useAuthStore();

  const checkRole = () => {
    if (Array.isArray(role)) {
      return requireAll
        ? role.every(r => hasRole(r))
        : role.some(r => hasRole(r));
    }
    return hasRole(role);
  };

  if (!checkRole()) {
    return <Navigate to={fallbackPath} replace />;
  }

  return <>{children}</>;
};