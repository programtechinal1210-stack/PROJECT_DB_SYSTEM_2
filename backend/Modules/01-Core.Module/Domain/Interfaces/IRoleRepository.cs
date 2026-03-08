using System.Collections.Generic;
using System.Threading.Tasks;
using Core.Module.Domain.Entities;

namespace Core.Module.Domain.Interfaces
{
    public interface IRoleRepository
    {
        Task<Role> GetByIdAsync(int id);
        Task<Role> GetByNameAsync(string roleName);
        Task<IEnumerable<Role>> GetAllAsync();
        Task<IEnumerable<Role>> GetByUserAsync(int userId);
        Task<IEnumerable<Role>> GetSystemRolesAsync();
        
        Task<Role> AddAsync(Role role);
        Task UpdateAsync(Role role);
        Task DeleteAsync(int id);
        
        Task<bool> ExistsByNameAsync(string roleName);
        
        Task AddPermissionToRoleAsync(int roleId, int permissionId, int? grantedBy = null);
        Task RemovePermissionFromRoleAsync(int roleId, int permissionId);
        Task ClearRolePermissionsAsync(int roleId);
        
        Task<IEnumerable<Permission>> GetRolePermissionsAsync(int roleId);
    }
}