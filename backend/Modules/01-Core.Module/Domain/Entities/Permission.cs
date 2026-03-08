// using System;
// using System.Collections.Generic;
// using Core.Module.Domain.Enums;
// using System.ComponentModel.DataAnnotations.Schema;  // ✅ هذه موجودة

// namespace Core.Module.Domain.Entities
// {
//     public class Permission
//     {
//         public int Id { get; private set; }
//         public string PermissionCode { get; private set; }
//         public string PermissionName { get; private set; }
//         public string PermissionDescription { get; private set; }
//         public int ModuleId { get; private set; }
        
//         [NotMapped]  // ✅ أضف هذا السطر - يخبر EF Core بتجاهل هذه الخاصية
//         public SystemModule Module { get; private set; }
        
//         public PermissionAction ActionType { get; private set; }
//         public DateTime CreatedAt { get; private set; }
//         public DateTime UpdatedAt { get; private set; }
//         public string? Description { get; set; }

//         private readonly List<RolePermission> _rolePermissions = new();
//         public IReadOnlyCollection<RolePermission> RolePermissions => _rolePermissions.AsReadOnly();

//         private Permission() { } // For EF Core

//         public Permission(string permissionCode, string permissionName, int moduleId, 
//             PermissionAction actionType, string description = null)
//         {
//             SetPermissionCode(permissionCode);
//             SetPermissionName(permissionName);
//             ModuleId = moduleId;
//             ActionType = actionType;
//             PermissionDescription = description;
//             CreatedAt = DateTime.UtcNow;
//             UpdatedAt = DateTime.UtcNow;
//         }

//         public void SetPermissionCode(string permissionCode)
//         {
//             if (string.IsNullOrWhiteSpace(permissionCode))
//                 throw new ArgumentException("Permission code cannot be empty");
            
//             if (permissionCode.Length > 100)
//                 throw new ArgumentException("Permission code too long");

//             PermissionCode = permissionCode.Trim().ToLower();
//             UpdatedAt = DateTime.UtcNow;
//         }

//         public void SetPermissionName(string permissionName)
//         {
//             if (string.IsNullOrWhiteSpace(permissionName))
//                 throw new ArgumentException("Permission name cannot be empty");
            
//             PermissionName = permissionName.Trim();
//             UpdatedAt = DateTime.UtcNow;
//         }

//         public void SetDescription(string description)
//         {
//             PermissionDescription = description;
//             UpdatedAt = DateTime.UtcNow;
//         }

//         public void SetActionType(PermissionAction actionType)
//         {
//             ActionType = actionType;
//             UpdatedAt = DateTime.UtcNow;
//         }
        
//         // ✅ دالة لإضافة RolePermission
//         public void AddRolePermission(RolePermission rolePermission)
//         {
//             if (rolePermission == null)
//                 throw new ArgumentNullException(nameof(rolePermission));
            
//             _rolePermissions.Add(rolePermission);
//             UpdatedAt = DateTime.UtcNow;
//         }
//     }
// }



using System;
using System.Collections.Generic;
using Core.Module.Domain.Enums;
using System.ComponentModel.DataAnnotations.Schema;  // ✅ مهم جداً

namespace Core.Module.Domain.Entities
{
    public class Permission
    {
        public int Id { get; private set; }
        public string PermissionCode { get; private set; }
        public string PermissionName { get; private set; }
        public string PermissionDescription { get; private set; }
        // public int ModuleId { get; private set; }
        
        // [NotMapped]  // ✅ هذا هو السطر المهم - يخبر EF Core بتجاهل هذه الخاصية
        // public SystemModule Module { get; private set; }
public int ModuleId { get; private set; }
public Module Module { get; private set; }        
        public PermissionAction ActionType { get; private set; }
        public DateTime CreatedAt { get; private set; }
        public DateTime UpdatedAt { get; private set; }
        public string? Description { get; set; }

        private readonly List<RolePermission> _rolePermissions = new();
        public IReadOnlyCollection<RolePermission> RolePermissions => _rolePermissions.AsReadOnly();

        private Permission() { } // For EF Core

        public Permission(string permissionCode, string permissionName, int moduleId, 
            PermissionAction actionType, string description = null)
        {
            SetPermissionCode(permissionCode);
            SetPermissionName(permissionName);
            ModuleId = moduleId;
            ActionType = actionType;
            PermissionDescription = description;
            CreatedAt = DateTime.UtcNow;
            UpdatedAt = DateTime.UtcNow;
        }

        public void SetPermissionCode(string permissionCode)
        {
            if (string.IsNullOrWhiteSpace(permissionCode))
                throw new ArgumentException("Permission code cannot be empty");
            
            if (permissionCode.Length > 100)
                throw new ArgumentException("Permission code too long");

            PermissionCode = permissionCode.Trim().ToLower();
            UpdatedAt = DateTime.UtcNow;
        }

        public void SetPermissionName(string permissionName)
        {
            if (string.IsNullOrWhiteSpace(permissionName))
                throw new ArgumentException("Permission name cannot be empty");
            
            PermissionName = permissionName.Trim();
            UpdatedAt = DateTime.UtcNow;
        }

        public void SetDescription(string description)
        {
            PermissionDescription = description;
            UpdatedAt = DateTime.UtcNow;
        }

        public void SetActionType(PermissionAction actionType)
        {
            ActionType = actionType;
            UpdatedAt = DateTime.UtcNow;
        }
        
        public void AddRolePermission(RolePermission rolePermission)
        {
            if (rolePermission == null)
                throw new ArgumentNullException(nameof(rolePermission));
            
            _rolePermissions.Add(rolePermission);
            UpdatedAt = DateTime.UtcNow;
        }
    }
}