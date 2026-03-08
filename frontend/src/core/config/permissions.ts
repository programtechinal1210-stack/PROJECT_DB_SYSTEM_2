export const PERMISSIONS = {
  // Dashboard
  DASHBOARD_VIEW: 'dashboard.view',

  // Users
  USERS_VIEW: 'users.view',
  USERS_CREATE: 'users.create',
  USERS_EDIT: 'users.edit',
  USERS_DELETE: 'users.delete',
  USERS_EXPORT: 'users.export',

  // Roles
  ROLES_VIEW: 'roles.view',
  ROLES_CREATE: 'roles.create',
  ROLES_EDIT: 'roles.edit',
  ROLES_DELETE: 'roles.delete',

  // Branches
  BRANCHES_VIEW: 'branches.view',
  BRANCHES_CREATE: 'branches.create',
  BRANCHES_EDIT: 'branches.edit',
  BRANCHES_DELETE: 'branches.delete',
  BRANCHES_EXPORT: 'branches.export',

  // Employees
  EMPLOYEES_VIEW: 'employees.view',
  EMPLOYEES_CREATE: 'employees.create',
  EMPLOYEES_EDIT: 'employees.edit',
  EMPLOYEES_DELETE: 'employees.delete',
  EMPLOYEES_EXPORT: 'employees.export',

  // Attendance
  ATTENDANCE_VIEW: 'attendance.view',
  ATTENDANCE_CREATE: 'attendance.create',
  ATTENDANCE_EDIT: 'attendance.edit',
  ATTENDANCE_DELETE: 'attendance.delete',
  ATTENDANCE_EXPORT: 'attendance.export',

  // Equipment
  EQUIPMENT_VIEW: 'equipment.view',
  EQUIPMENT_CREATE: 'equipment.create',
  EQUIPMENT_EDIT: 'equipment.edit',
  EQUIPMENT_DELETE: 'equipment.delete',
  EQUIPMENT_EXPORT: 'equipment.export',

  // Locations
  LOCATIONS_VIEW: 'locations.view',
  LOCATIONS_CREATE: 'locations.create',
  LOCATIONS_EDIT: 'locations.edit',
  LOCATIONS_DELETE: 'locations.delete',
  LOCATIONS_EXPORT: 'locations.export',

  // Tasks
  TASKS_VIEW: 'tasks.view',
  TASKS_CREATE: 'tasks.create',
  TASKS_EDIT: 'tasks.edit',
  TASKS_DELETE: 'tasks.delete',
  TASKS_EXPORT: 'tasks.export',

  // Reports
  REPORTS_VIEW: 'reports.view',
  REPORTS_GENERATE: 'reports.generate',
  REPORTS_EXPORT: 'reports.export',

  // Settings
  SETTINGS_VIEW: 'settings.view',
  SETTINGS_EDIT: 'settings.edit',

  // Admin
  ADMIN_FULL: 'admin.full',
} as const;

export type Permission = typeof PERMISSIONS[keyof typeof PERMISSIONS];