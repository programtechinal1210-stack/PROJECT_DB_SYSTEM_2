// using System;
// using System.Collections.Generic;
// using Core.Module.Domain.Enums;

// namespace Core.Module.Domain.Entities
// {
//     public class Module
//     {
//         public int Id { get; private set; }
//         public string ModuleCode { get; private set; }
//         public string ModuleName { get; private set; }
//         public string ModuleDescription { get; private set; }
//         public int? ParentModuleId { get; private set; }
//         public Module ParentModule { get; private set; }
//         public int DisplayOrder { get; private set; }
//         public bool IsActive { get; private set; }
//         public string Icon { get; private set; }
//         public string Route { get; private set; }
//         public DateTime CreatedAt { get; private set; }
//         public DateTime UpdatedAt { get; private set; }

//         private readonly List<Module> _subModules = new();
//         public IReadOnlyCollection<Module> SubModules => _subModules.AsReadOnly();

//         private readonly List<Permission> _permissions = new();
//         public IReadOnlyCollection<Permission> Permissions => _permissions.AsReadOnly();

//         private Module() { } // For EF Core

//         public Module(string moduleCode, string moduleName, int? parentModuleId = null)
//         {
//             SetModuleCode(moduleCode);
//             SetModuleName(moduleName);
//             ParentModuleId = parentModuleId;
//             IsActive = true;
//             DisplayOrder = 0;
//             CreatedAt = DateTime.UtcNow;
//             UpdatedAt = DateTime.UtcNow;
//         }

//         public void SetModuleCode(string moduleCode)
//         {
//             if (string.IsNullOrWhiteSpace(moduleCode))
//                 throw new ArgumentException("Module code cannot be empty");
            
//             ModuleCode = moduleCode.Trim().ToUpper();
//             UpdatedAt = DateTime.UtcNow;
//         }

//         public void SetModuleName(string moduleName)
//         {
//             if (string.IsNullOrWhiteSpace(moduleName))
//                 throw new ArgumentException("Module name cannot be empty");
            
//             ModuleName = moduleName.Trim();
//             UpdatedAt = DateTime.UtcNow;
//         }

//         public void SetDescription(string description)
//         {
//             ModuleDescription = description;
//             UpdatedAt = DateTime.UtcNow;
//         }

//         public void SetParentModule(int? parentModuleId)
//         {
//             if (parentModuleId == Id)
//                 throw new InvalidOperationException("Module cannot be parent of itself");

//             ParentModuleId = parentModuleId;
//             UpdatedAt = DateTime.UtcNow;
//         }

//         public void SetDisplayOrder(int order)
//         {
//             DisplayOrder = order;
//             UpdatedAt = DateTime.UtcNow;
//         }

//         public void SetIcon(string icon)
//         {
//             Icon = icon;
//             UpdatedAt = DateTime.UtcNow;
//         }

//         public void SetRoute(string route)
//         {
//             Route = route;
//             UpdatedAt = DateTime.UtcNow;
//         }

//         public void Activate()
//         {
//             IsActive = true;
//             UpdatedAt = DateTime.UtcNow;
//         }

//         public void Deactivate()
//         {
//             IsActive = false;
//             UpdatedAt = DateTime.UtcNow;
//         }

//         public void AddPermission(Permission permission)
//         {
//             if (permission == null)
//                 throw new ArgumentNullException(nameof(permission));

//             _permissions.Add(permission);
//             UpdatedAt = DateTime.UtcNow;
//         }
//     }
// }

using System;
using System.Collections.Generic;
using Core.Module.Domain.Enums;

namespace Core.Module.Domain.Entities
{
    public class Module
    {
        public int Id { get; private set; }
        public string ModuleCode { get; private set; } = string.Empty;
        public string ModuleName { get; private set; } = string.Empty;
        public string? ModuleDescription { get; private set; }
        public int? ParentModuleId { get; private set; }
        public Module? ParentModule { get; private set; }
        public int DisplayOrder { get; private set; }
        public bool IsActive { get; private set; }
        public string? Icon { get; private set; }
        public string? Route { get; private set; }
        public DateTime CreatedAt { get; private set; }
        public DateTime UpdatedAt { get; private set; }
    //   public string? Description { get; set; }  // ✅ إضافة Description
        // public string? Version { get; set; }  
public string? Version { get; private set; }
        private readonly List<Module> _subModules = new();
        public IReadOnlyCollection<Module> SubModules => _subModules.AsReadOnly();

        private readonly List<Permission> _permissions = new();
        public IReadOnlyCollection<Permission> Permissions => _permissions.AsReadOnly();
public void RemovePermission(Permission permission)
{
    _permissions.Remove(permission);
}
        private Module() { } // For EF Core

        public Module(string moduleCode, string moduleName, int? parentModuleId = null)
        {
            SetModuleCode(moduleCode);
            SetModuleName(moduleName);
            ParentModuleId = parentModuleId;
            IsActive = true;
            DisplayOrder = 0;
            CreatedAt = DateTime.UtcNow;
            UpdatedAt = DateTime.UtcNow;
        }
public void SetVersion(string version)
{
    Version = version;
    UpdatedAt = DateTime.UtcNow;
}
        public void SetModuleCode(string moduleCode)
        {
            if (string.IsNullOrWhiteSpace(moduleCode))
                throw new ArgumentException("Module code cannot be empty");
            
            ModuleCode = moduleCode.Trim().ToUpper();
            UpdatedAt = DateTime.UtcNow;
        }

        public void SetModuleName(string moduleName)
        {
            if (string.IsNullOrWhiteSpace(moduleName))
                throw new ArgumentException("Module name cannot be empty");
            
            ModuleName = moduleName.Trim();
            UpdatedAt = DateTime.UtcNow;
        }

        public void SetDescription(string? description)
        {
            ModuleDescription = description;
            UpdatedAt = DateTime.UtcNow;
        }

        public void SetParentModule(int? parentModuleId)
        {
            if (parentModuleId == Id)
                throw new InvalidOperationException("Module cannot be parent of itself");

            ParentModuleId = parentModuleId;
            UpdatedAt = DateTime.UtcNow;
        }

        public void SetDisplayOrder(int order)
        {
            DisplayOrder = order;
            UpdatedAt = DateTime.UtcNow;
        }

        public void SetIcon(string? icon)
        {
            Icon = icon;
            UpdatedAt = DateTime.UtcNow;
        }

        public void SetRoute(string? route)
        {
            Route = route;
            UpdatedAt = DateTime.UtcNow;
        }

        public void Activate()
        {
            IsActive = true;
            UpdatedAt = DateTime.UtcNow;
        }

        public void Deactivate()
        {
            IsActive = false;
            UpdatedAt = DateTime.UtcNow;
        }

        public void AddPermission(Permission permission)
        {
            if (permission == null)
                throw new ArgumentNullException(nameof(permission));

            _permissions.Add(permission);
            UpdatedAt = DateTime.UtcNow;
        }
    }
}