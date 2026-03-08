using System.Collections.Generic;
using System.Threading.Tasks;

namespace Core.Module.Application.Interfaces
{
    public interface IAuthorizationService
    {
        Task<bool> HasPermissionAsync(int userId, string permissionCode);
        Task<bool> HasAnyPermissionAsync(int userId, params string[] permissionCodes);
        Task<bool> HasAllPermissionsAsync(int userId, params string[] permissionCodes);
        Task<IEnumerable<string>> GetUserPermissionsAsync(int userId);
        Task<bool> IsInRoleAsync(int userId, string roleName);
        Task<IEnumerable<string>> GetUserRolesAsync(int userId);
        Task<bool> AuthorizeAsync(int userId, string resource, string action);
    }
}