export const ROLES = {
  ADMIN: 'Admin',
  HR: 'HR',
  BRANCH_MANAGER: 'BranchManager',
  EMPLOYEE: 'Employee',
  VIEWER: 'Viewer',
} as const;

export type Role = typeof ROLES[keyof typeof ROLES];

export const ROLE_PERMISSIONS = {
  [ROLES.ADMIN]: ['*'], // All permissions
  [ROLES.HR]: [
    'employees.view',
    'employees.create',
    'employees.edit',
    'employees.export',
    'attendance.view',
    'attendance.create',
    'attendance.edit',
    'attendance.export',
    'reports.generate',
  ],
  [ROLES.BRANCH_MANAGER]: [
    'branches.view',
    'employees.view',
    'equipment.view',
    'tasks.view',
    'reports.view',
  ],
  [ROLES.EMPLOYEE]: [
    'attendance.view',
    'tasks.view',
  ],
  [ROLES.VIEWER]: [
    'dashboard.view',
    'branches.view',
    'employees.view',
    'equipment.view',
    'locations.view',
    'reports.view',
  ],
} as const;