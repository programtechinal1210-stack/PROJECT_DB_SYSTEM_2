// using Core.Module.Domain.Common;
// using Core.Module.Domain.Events;
// using Core.Module.Domain.ValueObjects;
// using System;  // أضف هذا
// using System.Collections.Generic;  // أضف هذا
// using System.Linq;  // أضف هذا
// namespace Core.Module.Domain.Entities
// {
//     public class User : BaseEntity, IAggregateRoot
//     {
//         public string Username { get; private set; }
//         public Email Email { get; private set; }
//         public PasswordHash Password { get; private set; }
//         public RefreshToken RefreshToken { get; private set; }
//         public bool IsActive { get; private set; }
//         public DateTime? LastLogin { get; private set; }
//         public int? EmployeeId { get; private set; }
//         public DateTime CreatedAt { get; private set; }
//         public DateTime UpdatedAt { get; private set; }
//         public string CreatedBy { get; private set; }
//         public string UpdatedBy { get; private set; }

//         private readonly List<UserRole> _userRoles = new();
//         public IReadOnlyCollection<UserRole> UserRoles => _userRoles.AsReadOnly();
// public void SetUpdatedBy(string? updatedBy)
// {
//     UpdatedBy = updatedBy;
//     UpdatedAt = DateTime.UtcNow;
// }
//         private User() { } // For EF Core

//         public User(string username, string email, string password, int? employeeId = null)
//         {
//             SetUsername(username);
//             SetEmail(email);
//             SetPassword(password);
//             EmployeeId = employeeId;
//             IsActive = true;
//             CreatedAt = DateTime.UtcNow;
//             UpdatedAt = DateTime.UtcNow;

//             AddDomainEvent(new UserCreatedEvent(this.Id, this.Username, this.Email));
//         }

//         public void SetUsername(string username)
//         {
//             if (string.IsNullOrWhiteSpace(username))
//                 throw new ArgumentException("Username cannot be empty");
            
//             if (username.Length < 3 || username.Length > 50)
//                 throw new ArgumentException("Username must be between 3 and 50 characters");

//             Username = username.Trim();
//             UpdatedAt = DateTime.UtcNow;
//         }

//         public void SetEmail(string email)
//         {
//             var oldEmail = Email?.Value;
//             Email = new Email(email);
//             UpdatedAt = DateTime.UtcNow;
            
//             if (oldEmail != null && oldEmail != email)
//             {
//                 AddDomainEvent(new UserEmailChangedEvent(this.Id, oldEmail, email));
//             }
//         }

// // استخدم Create بدلاً من constructor
// public void SetPassword(string password)
// {
//     Password = PasswordHash.Create(password);  // تعديل هنا
//     UpdatedAt = DateTime.UtcNow;
    
//     AddDomainEvent(new PasswordChangedEvent(Id));
// }

//         public void SetRefreshToken(string token, DateTime expiry)
//         {
//             RefreshToken = new RefreshToken(token, expiry);
//             UpdatedAt = DateTime.UtcNow;
//         }

//         public void ClearRefreshToken()
//         {
//             RefreshToken = null;
//             UpdatedAt = DateTime.UtcNow;
//         }

//         public void Activate()
//         {
//             if (!IsActive)
//             {
//                 IsActive = true;
//                 UpdatedAt = DateTime.UtcNow;
//                 AddDomainEvent(new UserActivatedEvent(this.Id));
//             }
//         }

//         public void Deactivate()
//         {
//             if (IsActive)
//             {
//                 IsActive = false;
//                 ClearRefreshToken();
//                 UpdatedAt = DateTime.UtcNow;
//                 AddDomainEvent(new UserDeactivatedEvent(this.Id));
//             }
//         }

//         public void RecordLogin(string ipAddress, string userAgent)
//         {
//             LastLogin = DateTime.UtcNow;
//             UpdatedAt = DateTime.UtcNow;
//             AddDomainEvent(new UserLoggedInEvent(this.Id, ipAddress, userAgent));
//         }

//         public void AddRole(Role role, int assignedBy)
//         {
//             if (role == null)
//                 throw new ArgumentNullException(nameof(role));

//             if (_userRoles.Any(ur => ur.RoleId == role.Id))
//                 throw new InvalidOperationException($"User already has role {role.RoleName}");

//             _userRoles.Add(new UserRole(this.Id, role.Id, assignedBy));
//             UpdatedAt = DateTime.UtcNow;
            
//             AddDomainEvent(new RoleAssignedEvent(this.Id, role.Id, assignedBy));
//         }

//         public void RemoveRole(int roleId)
//         {
//             var userRole = _userRoles.FirstOrDefault(ur => ur.RoleId == roleId);
//             if (userRole != null)
//             {
//                 _userRoles.Remove(userRole);
//                 UpdatedAt = DateTime.UtcNow;
//                 AddDomainEvent(new RoleRemovedEvent(this.Id, roleId));
//             }
//         }

//         public bool HasRole(string roleName)
//         {
//             return _userRoles.Any(ur => ur.Role?.RoleName == roleName);
//         }

//         public bool HasPermission(string permissionCode)
//         {
//             return _userRoles.Any(ur => ur.Role?.HasPermission(permissionCode) == true);
//         }

//         public IReadOnlyList<string> GetAllPermissions()
//         {
//             return _userRoles
//                 .SelectMany(ur => ur.Role?.GetAllPermissions() ?? new List<string>())
//                 .Distinct()
//                 .ToList();
//         }
//     }

//     public class UserRole
//     {
//         public int UserId { get; private set; }
//         public User User { get; private set; }
//         public int RoleId { get; private set; }
//         public Role Role { get; private set; }
//         public int? AssignedBy { get; private set; }
//         public DateTime AssignedAt { get; private set; }

//         private UserRole() { }

//         public UserRole(int userId, int roleId, int? assignedBy = null)
//         {
//             UserId = userId;
//             RoleId = roleId;
//             AssignedBy = assignedBy;
//             AssignedAt = DateTime.UtcNow;
//         }
//     }
// }


using Core.Module.Domain.Common;
using Core.Module.Domain.Events;
using Core.Module.Domain.ValueObjects;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Core.Module.Domain.Entities
{
    public class User : BaseEntity, IAggregateRoot
    {
        public string Username { get; private set; }
        public Email Email { get; private set; }
        public PasswordHash Password { get; private set; }
        
        // 🔴 تعديل: جعل RefreshToken nullable لأنه Value Object
        public RefreshToken RefreshToken { get; private set; }
        
        public bool IsActive { get; private set; }
        public DateTime? LastLogin { get; private set; }
        public int? EmployeeId { get; private set; }
        public DateTime CreatedAt { get; private set; }
        public DateTime UpdatedAt { get; private set; }
        public string CreatedBy { get; private set; }
        public string UpdatedBy { get; private set; }

        private readonly List<UserRole> _userRoles = new();
        public IReadOnlyCollection<UserRole> UserRoles => _userRoles.AsReadOnly();

        public void SetUpdatedBy(string? updatedBy)
        {
            UpdatedBy = updatedBy;
            UpdatedAt = DateTime.UtcNow;
        }

        private User() { } // For EF Core

        public User(string username, string email, string password, int? employeeId = null, string? createdBy = null)
        {
            SetUsername(username);
            SetEmail(email);
            SetPassword(password);
            EmployeeId = employeeId;
            IsActive = true;
            CreatedAt = DateTime.UtcNow;
            UpdatedAt = DateTime.UtcNow;
            CreatedBy = createdBy ?? "system";
            UpdatedBy = createdBy ?? "system";

            AddDomainEvent(new UserCreatedEvent(this.Id, this.Username, this.Email));
        }

        public void SetUsername(string username)
        {
            if (string.IsNullOrWhiteSpace(username))
                throw new ArgumentException("Username cannot be empty");
            
            if (username.Length < 3 || username.Length > 50)
                throw new ArgumentException("Username must be between 3 and 50 characters");

            Username = username.Trim();
            UpdatedAt = DateTime.UtcNow;
        }

        public void SetEmail(string email)
        {
            var oldEmail = Email?.Value;
            Email = new Email(email);
            UpdatedAt = DateTime.UtcNow;
            
            if (oldEmail != null && oldEmail != email)
            {
                AddDomainEvent(new UserEmailChangedEvent(this.Id, oldEmail, email));
            }
        }

        public void SetPassword(string password)
        {
            Password = PasswordHash.Create(password);
            UpdatedAt = DateTime.UtcNow;
            AddDomainEvent(new PasswordChangedEvent(Id));
        }

        // 🔴 تعديل: استقبل RefreshToken object مباشرة
        public void SetRefreshToken(RefreshToken refreshToken)
        {
            RefreshToken = refreshToken;
            UpdatedAt = DateTime.UtcNow;
        }

        // 🔴 إضافة overload للراحة
        public void SetRefreshToken(string token, DateTime expiry)
        {
            RefreshToken = new RefreshToken(token, expiry);
            UpdatedAt = DateTime.UtcNow;
        }

        public void ClearRefreshToken()
        {
            RefreshToken = null;
            UpdatedAt = DateTime.UtcNow;
        }

        // 🔴 إضافة دوال مساعدة للتحقق من RefreshToken
        public bool HasValidRefreshToken(string token)
        {
            return RefreshToken != null && 
                   RefreshToken.Token == token && 
                   !RefreshToken.IsExpired();
        }

        public bool HasValidRefreshToken()
        {
            return RefreshToken != null && RefreshToken.IsValid();
        }

        public void Activate()
        {
            if (!IsActive)
            {
                IsActive = true;
                UpdatedAt = DateTime.UtcNow;
                AddDomainEvent(new UserActivatedEvent(this.Id));
            }
        }

        public void Deactivate()
        {
            if (IsActive)
            {
                IsActive = false;
                ClearRefreshToken();
                UpdatedAt = DateTime.UtcNow;
                AddDomainEvent(new UserDeactivatedEvent(this.Id));
            }
        }

        public void RecordLogin(string ipAddress, string userAgent)
        {
            LastLogin = DateTime.UtcNow;
            UpdatedAt = DateTime.UtcNow;
            AddDomainEvent(new UserLoggedInEvent(this.Id, ipAddress, userAgent));
        }

        public void AddRole(Role role, int assignedBy)
        {
            if (role == null)
                throw new ArgumentNullException(nameof(role));

            if (_userRoles.Any(ur => ur.RoleId == role.Id))
                throw new InvalidOperationException($"User already has role {role.RoleName}");

            _userRoles.Add(new UserRole(this.Id, role.Id, assignedBy));
            UpdatedAt = DateTime.UtcNow;
            
            AddDomainEvent(new RoleAssignedEvent(this.Id, role.Id, assignedBy));
        }

        public void RemoveRole(int roleId)
        {
            var userRole = _userRoles.FirstOrDefault(ur => ur.RoleId == roleId);
            if (userRole != null)
            {
                _userRoles.Remove(userRole);
                UpdatedAt = DateTime.UtcNow;
                AddDomainEvent(new RoleRemovedEvent(this.Id, roleId));
            }
        }

        public bool HasRole(string roleName)
        {
            return _userRoles.Any(ur => ur.Role?.RoleName == roleName);
        }

        public bool HasPermission(string permissionCode)
        {
            return _userRoles.Any(ur => ur.Role?.HasPermission(permissionCode) == true);
        }

        public IReadOnlyList<string> GetAllPermissions()
        {
            return _userRoles
                .SelectMany(ur => ur.Role?.GetAllPermissions() ?? new List<string>())
                .Distinct()
                .ToList();
        }
                public ICollection<UserSession> Sessions { get; set; } = new List<UserSession>();

    }

    public class UserRole
    {
        public int UserId { get; private set; }
        public User User { get; private set; }
        public int RoleId { get; private set; }
        public Role Role { get; private set; }
        public int? AssignedBy { get; private set; }
        public DateTime AssignedAt { get; private set; }

        private UserRole() { }

        public UserRole(int userId, int roleId, int? assignedBy = null)
        {
            UserId = userId;
            RoleId = roleId;
            AssignedBy = assignedBy;
            AssignedAt = DateTime.UtcNow;
        }
    }
}