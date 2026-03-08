// using Microsoft.EntityFrameworkCore;
// using Microsoft.Extensions.Logging;
// using Core.Module.Domain.Entities;
// using Core.Module.Domain.Enums;
// using Core.Module.Infrastructure.Persistence.DbContext;

// namespace Core.Module.Infrastructure.Persistence.SeedData
// {
//     public static class CoreDbContextSeed
//     {
//         public static async Task SeedAsync(CoreDbContext context, ILogger logger)
//         {
//             try
//             {
//                 await SeedModulesAsync(context, logger);
//                 await SeedPermissionsAsync(context, logger);
//                 await SeedRolesAsync(context, logger);
//                 await SeedAdminUserAsync(context, logger);
                
//                 await context.SaveChangesAsync();
                
//                 logger.LogInformation("Core module seed data completed successfully");
//             }
//             catch (Exception ex)
//             {
//                 logger.LogError(ex, "Error seeding core module data");
//                 throw;
//             }
//         }

//         private static async Task SeedModulesAsync(CoreDbContext context, ILogger logger)
//         {
//             if (await context.Modules.AnyAsync())
//                 return;

//             logger.LogInformation("Seeding modules...");

//             var modules = new List<Module>
//             {
//                 new Module("DASHBOARD", "لوحة التحكم") { DisplayOrder = 1, Icon = "dashboard", Route = "/dashboard" },
//                 new Module("BRANCHES", "الفروع") { DisplayOrder = 2, Icon = "business", Route = "/branches" },
//                 new Module("EMPLOYEES", "الموظفين") { DisplayOrder = 3, Icon = "people", Route = "/employees" },
//                 new Module("ATTENDANCE", "الحضور") { DisplayOrder = 4, Icon = "schedule", Route = "/attendance" },
//                 new Module("EQUIPMENT", "المعدات") { DisplayOrder = 5, Icon = "build", Route = "/equipment" },
//                 new Module("LOCATIONS", "المواقع") { DisplayOrder = 6, Icon = "location_on", Route = "/locations" },
//                 new Module("TASKS", "المهام") { DisplayOrder = 7, Icon = "task", Route = "/tasks" },
//                 new Module("REPORTS", "التقارير") { DisplayOrder = 8, Icon = "assessment", Route = "/reports" },
//                 new Module("SETTINGS", "الإعدادات") { DisplayOrder = 9, Icon = "settings", Route = "/settings" }
//             };

//             await context.Modules.AddRangeAsync(modules);
//         }

//         private static async Task SeedPermissionsAsync(CoreDbContext context, ILogger logger)
//         {
//             if (await context.Permissions.AnyAsync())
//                 return;

//             logger.LogInformation("Seeding permissions...");

//             var modules = await context.Modules.ToDictionaryAsync(m => m.ModuleCode);
//             var permissions = new List<Permission>();

//             foreach (var module in modules.Values)
//             {
//                 permissions.AddRange(new[]
//                 {
//                     new Permission($"{module.ModuleCode.ToLower()}.view", $"عرض {module.ModuleName}", module.Id, PermissionAction.View),
//                     new Permission($"{module.ModuleCode.ToLower()}.create", $"إنشاء {module.ModuleName}", module.Id, PermissionAction.Create),
//                     new Permission($"{module.ModuleCode.ToLower()}.edit", $"تعديل {module.ModuleName}", module.Id, PermissionAction.Update),
//                     new Permission($"{module.ModuleCode.ToLower()}.delete", $"حذف {module.ModuleName}", module.Id, PermissionAction.Delete),
//                     new Permission($"{module.ModuleCode.ToLower()}.export", $"تصدير {module.ModuleName}", module.Id, PermissionAction.Export),
//                 });
//             }

//             // Add special permissions
//             permissions.Add(new Permission("admin.full", "التحكم الكامل", modules["SETTINGS"].Id, PermissionAction.Manage));
//             permissions.Add(new Permission("reports.generate", "توليد التقارير", modules["REPORTS"].Id, PermissionAction.Create));

//             await context.Permissions.AddRangeAsync(permissions);
//         }

//         private static async Task SeedRolesAsync(CoreDbContext context, ILogger logger)
//         {
//             if (await context.Roles.AnyAsync())
//                 return;

//             logger.LogInformation("Seeding roles...");

//             var permissions = await context.Permissions.ToDictionaryAsync(p => p.PermissionCode);
//             var roles = new List<Role>();

//             // Admin role
//             var adminRole = new Role("Admin", "مدير النظام الكامل", true);
//             foreach (var permission in permissions.Values)
//             {
//                 adminRole.AddPermission(permission);
//             }
//             roles.Add(adminRole);

//             // HR role
//             var hrRole = new Role("HR", "مدير الموارد البشرية", false);
//             var hrPermissions = permissions.Where(p => 
//                 p.Key.StartsWith("employees.") || 
//                 p.Key.StartsWith("attendance.") ||
//                 p.Key == "reports.generate");
//             foreach (var permission in hrPermissions)
//             {
//                 hrRole.AddPermission(permission.Value);
//             }
//             roles.Add(hrRole);

//             // Branch Manager role
//             var managerRole = new Role("BranchManager", "مدير فرع", false);
//             var managerPermissions = permissions.Where(p => 
//                 p.Key.StartsWith("branches.view") ||
//                 p.Key.StartsWith("employees.view") ||
//                 p.Key.StartsWith("equipment.view"));
//             foreach (var permission in managerPermissions)
//             {
//                 managerRole.AddPermission(permission.Value);
//             }
//             roles.Add(managerRole);

//             // Employee role
//             var employeeRole = new Role("Employee", "موظف عادي", false);
//             var employeePermissions = permissions.Where(p => 
//                 p.Key == "attendance.view" ||
//                 p.Key == "tasks.view");
//             foreach (var permission in employeePermissions)
//             {
//                 employeeRole.AddPermission(permission.Value);
//             }
//             roles.Add(employeeRole);

//             // Viewer role
//             var viewerRole = new Role("Viewer", "مستخدم للعرض فقط", false);
//             var viewerPermissions = permissions.Where(p => 
//                 p.Key.EndsWith(".view") || 
//                 p.Key.EndsWith(".export"));
//             foreach (var permission in viewerPermissions)
//             {
//                 viewerRole.AddPermission(permission.Value);
//             }
//             roles.Add(viewerRole);

//             await context.Roles.AddRangeAsync(roles);
//         }

//         private static async Task SeedAdminUserAsync(CoreDbContext context, ILogger logger)
//         {
//             if (await context.Users.AnyAsync(u => u.Username == "admin"))
//                 return;

//             logger.LogInformation("Seeding admin user...");

//             var adminRole = await context.Roles.FirstOrDefaultAsync(r => r.RoleName == "Admin");
            
//             var adminUser = new User(
//                 "admin",
//                 "admin@projectdbsystem.com",
//                 "Admin@123", // This should be changed after first login
//                 null
//             );

//             if (adminRole != null)
//             {
//                 adminUser.AddRole(adminRole, 0);
//             }

//             await context.Users.AddAsync(adminUser);
//         }
//     }
// }


using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Core.Module.Domain.Entities;
using Core.Module.Domain.Enums;
using Core.Module.Infrastructure.Persistence.DbContext;
using ModuleEntity = Core.Module.Domain.Entities.Module; // Alias لتجنب التضارب

namespace Core.Module.Infrastructure.Persistence.SeedData
{
    public static class CoreDbContextSeed
    {
        public static async Task SeedAsync(CoreDbContext context, ILogger logger)
        {
            try
            {
                await SeedModulesAsync(context, logger);
                await SeedPermissionsAsync(context, logger);
                await SeedRolesAsync(context, logger);
                await SeedAdminUserAsync(context, logger);
                
                await context.SaveChangesAsync();
                
                logger.LogInformation("Core module seed data completed successfully");
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Error seeding core module data");
                throw;
            }
        }

  private static async Task SeedModulesAsync(CoreDbContext context, ILogger logger)
{
    if (await context.Modules.AnyAsync())
        return;

    logger.LogInformation("Seeding modules...");

    var modules = new List<ModuleEntity>();

    var dashboard = new ModuleEntity("DASHBOARD", "لوحة التحكم");
    dashboard.SetDisplayOrder(1);
    dashboard.SetIcon("dashboard");
    dashboard.SetRoute("/dashboard");
    modules.Add(dashboard);

    var branches = new ModuleEntity("BRANCHES", "الفروع");
    branches.SetDisplayOrder(2);
    branches.SetIcon("business");
    branches.SetRoute("/branches");
    modules.Add(branches);

    var employees = new ModuleEntity("EMPLOYEES", "الموظفين");
    employees.SetDisplayOrder(3);
    employees.SetIcon("people");
    employees.SetRoute("/employees");
    modules.Add(employees);

    var attendance = new ModuleEntity("ATTENDANCE", "الحضور");
    attendance.SetDisplayOrder(4);
    attendance.SetIcon("schedule");
    attendance.SetRoute("/attendance");
    modules.Add(attendance);

    var equipment = new ModuleEntity("EQUIPMENT", "المعدات");
    equipment.SetDisplayOrder(5);
    equipment.SetIcon("build");
    equipment.SetRoute("/equipment");
    modules.Add(equipment);

    var locations = new ModuleEntity("LOCATIONS", "المواقع");
    locations.SetDisplayOrder(6);
    locations.SetIcon("location_on");
    locations.SetRoute("/locations");
    modules.Add(locations);

    var tasks = new ModuleEntity("TASKS", "المهام");
    tasks.SetDisplayOrder(7);
    tasks.SetIcon("task");
    tasks.SetRoute("/tasks");
    modules.Add(tasks);

    var reports = new ModuleEntity("REPORTS", "التقارير");
    reports.SetDisplayOrder(8);
    reports.SetIcon("assessment");
    reports.SetRoute("/reports");
    modules.Add(reports);

    var settings = new ModuleEntity("SETTINGS", "الإعدادات");
    settings.SetDisplayOrder(9);
    settings.SetIcon("settings");
    settings.SetRoute("/settings");
    modules.Add(settings);

    await context.Modules.AddRangeAsync(modules);
}

        private static async Task SeedPermissionsAsync(CoreDbContext context, ILogger logger)
        {
            if (await context.Permissions.AnyAsync())
                return;

            logger.LogInformation("Seeding permissions...");

            var modules = await context.Modules.ToDictionaryAsync(m => m.ModuleCode);
            var permissions = new List<Permission>();

            foreach (var module in modules.Values)
            {
                permissions.AddRange(new[]
                {
                    new Permission($"{module.ModuleCode.ToLower()}.view", $"عرض {module.ModuleName}", module.Id, PermissionAction.Read),
                    new Permission($"{module.ModuleCode.ToLower()}.create", $"إنشاء {module.ModuleName}", module.Id, PermissionAction.Create),
                    new Permission($"{module.ModuleCode.ToLower()}.edit", $"تعديل {module.ModuleName}", module.Id, PermissionAction.Update),
                    new Permission($"{module.ModuleCode.ToLower()}.delete", $"حذف {module.ModuleName}", module.Id, PermissionAction.Delete),
                    new Permission($"{module.ModuleCode.ToLower()}.export", $"تصدير {module.ModuleName}", module.Id, PermissionAction.Export),
                });
            }

            // Add special permissions
            permissions.Add(new Permission("admin.full", "التحكم الكامل", modules["SETTINGS"].Id, PermissionAction.Manage));
            permissions.Add(new Permission("reports.generate", "توليد التقارير", modules["REPORTS"].Id, PermissionAction.Create));

            await context.Permissions.AddRangeAsync(permissions);
        }

        private static async Task SeedRolesAsync(CoreDbContext context, ILogger logger)
        {
            if (await context.Roles.AnyAsync())
                return;

            logger.LogInformation("Seeding roles...");

            var permissions = await context.Permissions.ToDictionaryAsync(p => p.PermissionCode);
            var roles = new List<Role>();

            // Admin role
            var adminRole = new Role("Admin", "مدير النظام الكامل", true);
            foreach (var permission in permissions.Values)
            {
                adminRole.AddPermission(permission);
            }
            roles.Add(adminRole);

            // HR role
            var hrRole = new Role("HR", "مدير الموارد البشرية", false);
            var hrPermissions = permissions.Where(p => 
                p.Key.StartsWith("employees.") || 
                p.Key.StartsWith("attendance.") ||
                p.Key == "reports.generate");
            foreach (var permission in hrPermissions)
            {
                hrRole.AddPermission(permission.Value);
            }
            roles.Add(hrRole);

            // Branch Manager role
            var managerRole = new Role("BranchManager", "مدير فرع", false);
            var managerPermissions = permissions.Where(p => 
                p.Key.StartsWith("branches.view") ||
                p.Key.StartsWith("employees.view") ||
                p.Key.StartsWith("equipment.view"));
            foreach (var permission in managerPermissions)
            {
                managerRole.AddPermission(permission.Value);
            }
            roles.Add(managerRole);

            // Employee role
            var employeeRole = new Role("Employee", "موظف عادي", false);
            var employeePermissions = permissions.Where(p => 
                p.Key == "attendance.view" ||
                p.Key == "tasks.view");
            foreach (var permission in employeePermissions)
            {
                employeeRole.AddPermission(permission.Value);
            }
            roles.Add(employeeRole);

            // Viewer role
            var viewerRole = new Role("Viewer", "مستخدم للعرض فقط", false);
            var viewerPermissions = permissions.Where(p => 
                p.Key.EndsWith(".view") || 
                p.Key.EndsWith(".export"));
            foreach (var permission in viewerPermissions)
            {
                viewerRole.AddPermission(permission.Value);
            }
            roles.Add(viewerRole);

            await context.Roles.AddRangeAsync(roles);
        }

        private static async Task SeedAdminUserAsync(CoreDbContext context, ILogger logger)
        {
            if (await context.Users.AnyAsync(u => u.Username == "admin"))
                return;

            logger.LogInformation("Seeding admin user...");

            var adminRole = await context.Roles.FirstOrDefaultAsync(r => r.RoleName == "Admin");
            
            var adminUser = new User(
                "admin",
                "admin@projectdbsystem.com",
                "Admin@123", // This should be changed after first login
                null
            );

            if (adminRole != null)
            {
                adminUser.AddRole(adminRole, 0);
            }

            await context.Users.AddAsync(adminUser);
        }
    }
}