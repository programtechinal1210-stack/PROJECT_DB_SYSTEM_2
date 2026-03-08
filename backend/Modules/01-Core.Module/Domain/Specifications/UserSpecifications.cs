using System.Linq.Expressions;
using Core.Module.Domain.Entities;

namespace Core.Module.Domain.Specifications
{
    public static class UserSpecifications
    {
        public static Expression<Func<User, bool>> IsActive()
        {
            return user => user.IsActive;
        }

        public static Expression<Func<User, bool>> HasRole(string roleName)
        {
            return user => user.UserRoles.Any(ur => ur.Role.RoleName == roleName);
        }

        public static Expression<Func<User, bool>> HasPermission(string permissionCode)
        {
            return user => user.UserRoles
                .Any(ur => ur.Role.Permissions
                    .Any(rp => rp.Permission.PermissionCode == permissionCode));
        }

        public static Expression<Func<User, bool>> HasAnyPermission(params string[] permissionCodes)
        {
            return user => user.UserRoles
                .Any(ur => ur.Role.Permissions
                    .Any(rp => permissionCodes.Contains(rp.Permission.PermissionCode)));
        }

        public static Expression<Func<User, bool>> HasAllPermissions(params string[] permissionCodes)
        {
            return user => permissionCodes.All(pc => 
                user.UserRoles.Any(ur => 
                    ur.Role.Permissions.Any(rp => rp.Permission.PermissionCode == pc)));
        }

        public static Expression<Func<User, bool>> CreatedAfter(DateTime date)
        {
            return user => user.CreatedAt >= date;
        }

        public static Expression<Func<User, bool>> CreatedBefore(DateTime date)
        {
            return user => user.CreatedAt <= date;
        }

        public static Expression<Func<User, bool>> LastLoginAfter(DateTime date)
        {
            return user => user.LastLogin >= date;
        }

        public static Expression<Func<User, bool>> Search(string searchTerm)
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
                return user => true;

            searchTerm = searchTerm.ToLower();
            return user => user.Username.ToLower().Contains(searchTerm) ||
                          user.Email.Value.ToLower().Contains(searchTerm);
        }
    }

    public static class RoleSpecifications
    {
        public static Expression<Func<Role, bool>> IsSystemRole()
        {
            return role => role.IsSystemRole;
        }

        public static Expression<Func<Role, bool>> HasPermission(string permissionCode)
        {
            return role => role.Permissions
                .Any(rp => rp.Permission.PermissionCode == permissionCode);
        }

        public static Expression<Func<Role, bool>> HasMinimumPermissions(int count)
        {
            return role => role.Permissions.Count >= count;
        }

        public static Expression<Func<Role, bool>> Search(string searchTerm)
        {
            if (string.IsNullOrWhiteSpace(searchTerm))
                return role => true;

            searchTerm = searchTerm.ToLower();
            return role => role.RoleName.ToLower().Contains(searchTerm) ||
                          (role.RoleDescription != null && 
                           role.RoleDescription.ToLower().Contains(searchTerm));
        }
    }
}