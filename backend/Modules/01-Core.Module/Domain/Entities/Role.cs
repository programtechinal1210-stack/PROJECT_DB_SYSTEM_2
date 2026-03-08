// using Core.Module.Domain.Common;
// using Core.Module.Domain.Events;
// using System.Collections.Generic;
// namespace Core.Module.Domain.Entities
// {
//     public class Role : BaseEntity, IAggregateRoot
//     {
    
//         public string RoleName { get; private set; }
//         public string? RoleDescription { get; private set; }
//         public bool IsSystemRole { get; private set; }
//         public DateTime CreatedAt { get; private set; }
//         public DateTime? UpdatedAt { get; private set; }
//         public string? CreatedBy { get; private set; }
//         public string? UpdatedBy { get; private set; }

//         private readonly List<RolePermission> _permissions = new();
//         public IReadOnlyCollection<RolePermission> Permissions => _permissions.AsReadOnly();
        
//         // ✅ إضافة RolePermissions للتوافق مع DbContext
//         public IReadOnlyCollection<RolePermission> RolePermissions => _permissions.AsReadOnly();

//         private readonly List<UserRole> _userRoles = new();
//         public IReadOnlyCollection<UserRole> UserRoles => _userRoles.AsReadOnly();

//         private Role() { }

//         public Role(string roleName, string? description = null, bool isSystemRole = false, string? createdBy = null)
//         {
//             SetRoleName(roleName);
//             RoleDescription = description;
//             IsSystemRole = isSystemRole;
//             CreatedAt = DateTime.UtcNow;
//             CreatedBy = createdBy;

//             AddDomainEvent(new RoleCreatedEvent(Id, roleName, createdBy));}
        

//         public void SetRoleName(string roleName, string? updatedBy = null)
//         {
//             if (string.IsNullOrWhiteSpace(roleName))
//                 throw new ArgumentException("Role name cannot be empty");
            
//             if (roleName.Length < 3 || roleName.Length > 50)
//                 throw new ArgumentException("Role name must be between 3 and 50 characters");

//             var oldName = RoleName;
//             RoleName = roleName.Trim();
//             UpdatedAt = DateTime.UtcNow;
//             UpdatedBy = updatedBy;

//             if (oldName != null && oldName != roleName)
//             {
//                 AddDomainEvent(new RoleRenamedEvent(Id, oldName, roleName, updatedBy));
//             }
//         }

//         public void SetDescription(string? description, string? updatedBy = null)
//         {
//             RoleDescription = description;
//             UpdatedAt = DateTime.UtcNow;
//             UpdatedBy = updatedBy;
//         }

//         public void AddPermission(Permission permission, int? grantedBy = null)
//         {
//             if (permission == null)
//                 throw new ArgumentNullException(nameof(permission));

//             if (_permissions.Any(rp => rp.PermissionId == permission.Id))
//                 return;

//             _permissions.Add(new RolePermission(this, permission, grantedBy));
//             UpdatedAt = DateTime.UtcNow;
            
//             AddDomainEvent(new PermissionGrantedEvent(Id, permission.Id, grantedBy));
//         }

//         public void RemovePermission(int permissionId, int? revokedBy = null)
//         {
//             if (IsSystemRole)
//                 throw new InvalidOperationException("Cannot modify system role permissions");

//             var permission = _permissions.FirstOrDefault(rp => rp.PermissionId == permissionId);
//             if (permission != null)
//             {
//                 _permissions.Remove(permission);
//                 UpdatedAt = DateTime.UtcNow;
//                 AddDomainEvent(new PermissionRevokedEvent(Id, permissionId, revokedBy));
//             }
//         }

//         public bool HasPermission(string permissionCode)
//         {
//             return _permissions.Any(rp => rp.Permission?.PermissionCode == permissionCode);
//         }

//         public IReadOnlyList<string> GetAllPermissions()
//         {
//             return _permissions
//                 .Select(rp => rp.Permission?.PermissionCode)
//                 .Where(p => p != null)
//                 .Select(p => p!)
//                 .ToList();
//         }

//         public void ClearPermissions(int? clearedBy = null)
//         {
//             if (IsSystemRole)
//                 throw new InvalidOperationException("Cannot modify system role permissions");
            
//             _permissions.Clear();
//             UpdatedAt = DateTime.UtcNow;
//             AddDomainEvent(new RolePermissionsClearedEvent(Id, clearedBy));
//         }

//         public void SetAuditInfo(string? createdBy, string? updatedBy)
//         {
//             CreatedBy = createdBy;
//             UpdatedBy = updatedBy;
//         }
//         // أضف هذه الدالة إلى كلاس Role
// public void SetUpdatedBy(string? updatedBy)
// {
//     UpdatedBy = updatedBy;
//     UpdatedAt = DateTime.UtcNow;
// }
//     }

//     public class RolePermission
//     {
//         public int RoleId { get; private set; }
//         public Role Role { get; private set; } = null!;
//         public int PermissionId { get; private set; }
//         public Permission Permission { get; private set; } = null!;
//         public int? GrantedBy { get; private set; }
//         public DateTime GrantedAt { get; private set; }

//         private RolePermission() { } // For EF Core

//         public RolePermission(Role role, Permission permission, int? grantedBy = null)
//         {
//             Role = role ?? throw new ArgumentNullException(nameof(role));
//             Permission = permission ?? throw new ArgumentNullException(nameof(permission));
//             RoleId = role.Id;
//             PermissionId = permission.Id;
//             GrantedBy = grantedBy;
//             GrantedAt = DateTime.UtcNow;
//         }
        
//     }
// }

using Core.Module.Domain.Common;
using Core.Module.Domain.Events;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;

namespace Core.Module.Domain.Entities
{
    public class Role : BaseEntity, IAggregateRoot
    {
        // الخصائص المطابقة لقاعدة البيانات
        public string RoleCode { get; private set; }
        public string RoleNameAr { get; private set; }
        public string? RoleNameEn { get; private set; }
        public string? RoleDescription { get; private set; }
        public bool IsSystemRole { get; private set; }
        public int SortOrder { get; private set; }
        
        public DateTime CreatedAt { get; private set; }
        public DateTime? UpdatedAt { get; private set; }
        public int? CreatedBy { get; private set; }
        public int? UpdatedBy { get; private set; }

        // خاصية مساعدة للتوافق مع الكود القديم
        [NotMapped]
        public string RoleName 
        { 
            get => !string.IsNullOrEmpty(RoleNameEn) ? RoleNameEn : RoleNameAr; 
            set => RoleNameAr = value; 
        }

        // خاصية مساعدة لعرض الاسم
        [NotMapped]
        public string DisplayName => !string.IsNullOrEmpty(RoleNameEn) ? RoleNameEn : RoleNameAr;

        private readonly List<RolePermission> _permissions = new();
        public IReadOnlyCollection<RolePermission> Permissions => _permissions.AsReadOnly();
        public IReadOnlyCollection<RolePermission> RolePermissions => _permissions.AsReadOnly();

        private readonly List<UserRole> _userRoles = new();
        public IReadOnlyCollection<UserRole> UserRoles => _userRoles.AsReadOnly();

        private Role() 
        {
            RoleCode = string.Empty;
            RoleNameAr = string.Empty;
        }

        public Role(string roleCode, string roleNameAr, string? roleNameEn = null, 
                    string? description = null, bool isSystemRole = false, 
                    int sortOrder = 0, int? createdBy = null)
        {
            RoleCode = roleCode ?? throw new ArgumentNullException(nameof(roleCode));
            RoleNameAr = roleNameAr ?? throw new ArgumentNullException(nameof(roleNameAr));
            RoleNameEn = roleNameEn;
            RoleDescription = description;
            IsSystemRole = isSystemRole;
            SortOrder = sortOrder;
            CreatedAt = DateTime.UtcNow;
            CreatedBy = createdBy;

            AddDomainEvent(new RoleCreatedEvent(Id, roleNameAr));
        }

        public void SetRoleCode(string roleCode)
        {
            if (string.IsNullOrWhiteSpace(roleCode))
                throw new ArgumentException("Role code cannot be empty");
            
            RoleCode = roleCode.Trim().ToUpper();
            UpdatedAt = DateTime.UtcNow;
        }

        public void SetRoleNameAr(string roleNameAr)
        {
            if (string.IsNullOrWhiteSpace(roleNameAr))
                throw new ArgumentException("Arabic role name cannot be empty");
            
            var oldName = RoleNameAr;
            RoleNameAr = roleNameAr.Trim();
            UpdatedAt = DateTime.UtcNow;

            if (oldName != roleNameAr)
            {
                AddDomainEvent(new RoleRenamedEvent(Id, oldName, roleNameAr));
            }
        }

        public void SetRoleNameEn(string? roleNameEn)
        {
            RoleNameEn = roleNameEn?.Trim();
            UpdatedAt = DateTime.UtcNow;
        }

        public void SetDescription(string? description)
        {
            RoleDescription = description;
            UpdatedAt = DateTime.UtcNow;
        }

        public void SetSortOrder(int sortOrder)
        {
            SortOrder = sortOrder;
            UpdatedAt = DateTime.UtcNow;
        }

        public void SetUpdatedBy(int? updatedBy)
        {
            UpdatedBy = updatedBy;
            UpdatedAt = DateTime.UtcNow;
        }

        public void AddPermission(Permission permission, int? grantedBy = null)
        {
            if (permission == null)
                throw new ArgumentNullException(nameof(permission));

            if (_permissions.Any(rp => rp.PermissionId == permission.Id))
                return;

            _permissions.Add(new RolePermission(this, permission, grantedBy));
            UpdatedAt = DateTime.UtcNow;
            
            AddDomainEvent(new PermissionGrantedEvent(Id, permission.Id, grantedBy));
        }

        public void RemovePermission(int permissionId, int? revokedBy = null)
        {
            if (IsSystemRole)
                throw new InvalidOperationException("Cannot modify system role permissions");

            var permission = _permissions.FirstOrDefault(rp => rp.PermissionId == permissionId);
            if (permission != null)
            {
                _permissions.Remove(permission);
                UpdatedAt = DateTime.UtcNow;
                AddDomainEvent(new PermissionRevokedEvent(Id, permissionId, revokedBy));
            }
        }

        public bool HasPermission(string permissionCode)
        {
            return _permissions.Any(rp => rp.Permission?.PermissionCode == permissionCode);
        }

        public IReadOnlyList<string> GetAllPermissions()
        {
            return _permissions
                .Select(rp => rp.Permission?.PermissionCode)
                .Where(p => p != null)
                .Select(p => p!)
                .ToList();
        }

        public void ClearPermissions(int? clearedBy = null)
        {
            if (IsSystemRole)
                throw new InvalidOperationException("Cannot modify system role permissions");
            
            _permissions.Clear();
            UpdatedAt = DateTime.UtcNow;
            AddDomainEvent(new RolePermissionsClearedEvent(Id, clearedBy));
        }

        public void SetAuditInfo(int? createdBy, int? updatedBy)
        {
            CreatedBy = createdBy;
            UpdatedBy = updatedBy;
        }
    }
}