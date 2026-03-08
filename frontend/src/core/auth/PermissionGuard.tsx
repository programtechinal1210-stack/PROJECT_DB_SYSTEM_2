 
import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuthStore } from '../store/authStore';

interface PermissionGuardProps {
  children: React.ReactNode;
  permission: string | string[];
  requireAll?: boolean;
  fallbackPath?: string;
}

export const PermissionGuard: React.FC<PermissionGuardProps> = ({
  children,
  permission,
  requireAll = false,
  fallbackPath = '/unauthorized',
}) => {
  const { hasPermission, hasAllPermissions, hasAnyPermission } = useAuthStore();

  const checkPermission = () => {
    if (Array.isArray(permission)) {
      return requireAll
        ? hasAllPermissions(permission)
        : hasAnyPermission(permission);
    }
    return hasPermission(permission);
  };

  if (!checkPermission()) {
    return <Navigate to={fallbackPath} replace />;
  }

  return <>{children}</>;
};