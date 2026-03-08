 
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { QueryProvider } from './providers/QueryProvider';
import { AuthProvider } from './providers/AuthProvider';
import { AuthGuard } from '../core/auth/AuthGuard';
import { PermissionGuard } from '../core/auth/PermissionGuard';
import { LoginPage } from '../features/auth/pages/LoginPage';
import { ProfilePage } from '../features/auth/pages/ProfilePage';
import { PERMISSIONS } from '../core/config/permissions';

// Lazy load other pages
const DashboardPage = React.lazy(() => import('../features/dashboard/pages/DashboardPage'));
const UsersPage = React.lazy(() => import('../features/users/pages/UsersPage'));
const RolesPage = React.lazy(() => import('../features/roles/pages/RolesPage'));

function App() {
  return (
    <QueryProvider>
      <AuthProvider>
        <Router>
          <Routes>
            {/* Public routes */}
            <Route
              path="/login"
              element={
                <AuthGuard requireAuth={false}>
                  <LoginPage />
                </AuthGuard>
              }
            />

            {/* Protected routes */}
            <Route
              path="/"
              element={
                <AuthGuard>
                  <Layout>
                    <Outlet />
                  </Layout>
                </AuthGuard>
              }
            >
              <Route index element={<Navigate to="/dashboard" replace />} />
              
              <Route
                path="dashboard"
                element={
                  <React.Suspense fallback={<LoadingSpinner />}>
                    <DashboardPage />
                  </React.Suspense>
                }
              />

              <Route
                path="profile"
                element={<ProfilePage />}
              />

              <Route
                path="users"
                element={
                  <PermissionGuard permission={PERMISSIONS.USERS_VIEW}>
                    <React.Suspense fallback={<LoadingSpinner />}>
                      <UsersPage />
                    </React.Suspense>
                  </PermissionGuard>
                }
              />

              <Route
                path="roles"
                element={
                  <PermissionGuard permission={PERMISSIONS.ROLES_VIEW}>
                    <React.Suspense fallback={<LoadingSpinner />}>
                      <RolesPage />
                    </React.Suspense>
                  </PermissionGuard>
                }
              />
            </Route>

            {/* 404 */}
            <Route path="*" element={<NotFoundPage />} />
          </Routes>
        </Router>
      </AuthProvider>
    </QueryProvider>
  );
}

export default App;