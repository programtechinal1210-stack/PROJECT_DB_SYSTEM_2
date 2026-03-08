using MediatR;
using System;
using Core.Module.Domain.Common;

namespace Core.Module.Domain.Events
{
    // User Events
    public class UserCreatedEvent : DomainEvent, INotification
    {
        public int UserId { get; }
        public string Username { get; }
        public string Email { get; }
        public string? CreatedBy { get; }

        public UserCreatedEvent(int userId, string username, string email, string? createdBy = null)
        {
            UserId = userId;
            Username = username;
            Email = email;
            CreatedBy = createdBy;
        }
    }

    public class UserActivatedEvent : DomainEvent, INotification
    {
        public int UserId { get; }
        public string? ActivatedBy { get; }

        public UserActivatedEvent(int userId, string? activatedBy = null)
        {
            UserId = userId;
            ActivatedBy = activatedBy;
        }
    }

    public class UserDeactivatedEvent : DomainEvent, INotification
    {
        public int UserId { get; }
        public string? DeactivatedBy { get; }

        public UserDeactivatedEvent(int userId, string? deactivatedBy = null)
        {
            UserId = userId;
            DeactivatedBy = deactivatedBy;
        }
    }

    public class UserEmailChangedEvent : DomainEvent, INotification
    {
        public int UserId { get; }
        public string OldEmail { get; }
        public string NewEmail { get; }
        public string? ChangedBy { get; }

        public UserEmailChangedEvent(int userId, string oldEmail, string newEmail, string? changedBy = null)
        {
            UserId = userId;
            OldEmail = oldEmail;
            NewEmail = newEmail;
            ChangedBy = changedBy;
        }
    }

    public class UserLoggedInEvent : DomainEvent, INotification
    {
        public int UserId { get; }
        public string IpAddress { get; }
        public string UserAgent { get; }

        public UserLoggedInEvent(int userId, string ipAddress, string userAgent)
        {
            UserId = userId;
            IpAddress = ipAddress;
            UserAgent = userAgent;
        }
    }

    public class PasswordChangedEvent : DomainEvent, INotification
    {
        public int UserId { get; }

        public PasswordChangedEvent(int userId)
        {
            UserId = userId;
        }
    }

    // Role Events
    public class RoleCreatedEvent : DomainEvent, INotification
    {
        public int RoleId { get; }
        public string RoleName { get; }
        public string? CreatedBy { get; }

        public RoleCreatedEvent(int roleId, string roleName, string? createdBy = null)
        {
            RoleId = roleId;
            RoleName = roleName;
            CreatedBy = createdBy;
        }
    }

    public class RoleRenamedEvent : DomainEvent, INotification
    {
        public int RoleId { get; }
        public string OldName { get; }
        public string NewName { get; }
        public string? RenamedBy { get; }

        public RoleRenamedEvent(int roleId, string oldName, string newName, string? renamedBy = null)
        {
            RoleId = roleId;
            OldName = oldName;
            NewName = newName;
            RenamedBy = renamedBy;
        }
    }

    // Permission Events
    public class PermissionGrantedEvent : DomainEvent, INotification
    {
        public int RoleId { get; }
        public int PermissionId { get; }
        public int? GrantedBy { get; }

        public PermissionGrantedEvent(int roleId, int permissionId, int? grantedBy = null)
        {
            RoleId = roleId;
            PermissionId = permissionId;
            GrantedBy = grantedBy;
        }
    }
    public class RoleDeletedEvent : DomainEvent, INotification
    {
        public int RoleId { get; }
        public string RoleName { get; }
        public int? DeletedBy { get; }

        public RoleDeletedEvent(int roleId, string roleName, int? deletedBy = null)
        {
            RoleId = roleId;
            RoleName = roleName;
            DeletedBy = deletedBy;
        }
    }
    public class PermissionRevokedEvent : DomainEvent, INotification
    {
        public int RoleId { get; }
        public int PermissionId { get; }
        public int? RevokedBy { get; }

        public PermissionRevokedEvent(int roleId, int permissionId, int? revokedBy = null)
        {
            RoleId = roleId;
            PermissionId = permissionId;
            RevokedBy = revokedBy;
        }
    }

    public class RolePermissionsClearedEvent : DomainEvent, INotification
    {
        public int RoleId { get; }
        public int? ClearedBy { get; }

        public RolePermissionsClearedEvent(int roleId, int? clearedBy = null)
        {
            RoleId = roleId;
            ClearedBy = clearedBy;
        }
    }

    // Role Assignment Events
    public class RoleAssignedEvent : DomainEvent, INotification
    {
        public int UserId { get; }
        public int RoleId { get; }
        public int? AssignedBy { get; }

        public RoleAssignedEvent(int userId, int roleId, int? assignedBy = null)
        {
            UserId = userId;
            RoleId = roleId;
            AssignedBy = assignedBy;
        }
    }

    public class RoleRemovedEvent : DomainEvent, INotification
    {
        public int UserId { get; }
        public int RoleId { get; }

        public RoleRemovedEvent(int userId, int roleId)
        {
            UserId = userId;
            RoleId = roleId;
        }
    }
}