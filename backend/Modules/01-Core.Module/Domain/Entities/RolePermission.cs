using System;

namespace Core.Module.Domain.Entities
{
    public class RolePermission
    {
        public int RoleId { get; private set; }
        public Role Role { get; private set; } = null!;
        public int PermissionId { get; private set; }
        public Permission Permission { get; private set; } = null!;
        public int? GrantedBy { get; private set; }
        public DateTime GrantedAt { get; private set; }

        private RolePermission() { }

        public RolePermission(Role role, Permission permission, int? grantedBy = null)
        {
            Role = role ?? throw new ArgumentNullException(nameof(role));
            Permission = permission ?? throw new ArgumentNullException(nameof(permission));
            RoleId = role.Id;
            PermissionId = permission.Id;
            GrantedBy = grantedBy;
            GrantedAt = DateTime.UtcNow;
        }
    }
}