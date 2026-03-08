using System.Collections.Generic;
using System.Threading.Tasks;
using Core.Module.Domain.Entities;

namespace Core.Module.Domain.Interfaces
{
    public interface IPermissionRepository
    {
        Task<Permission> GetByIdAsync(int id);
        Task<Permission> GetByCodeAsync(string permissionCode);
        Task<IEnumerable<Permission>> GetAllAsync();
        Task<IEnumerable<Permission>> GetByModuleAsync(int moduleId);
        Task<IEnumerable<Permission>> GetByRoleAsync(int roleId);
        Task<IEnumerable<Permission>> GetByUserAsync(int userId);
        
        Task<Permission> AddAsync(Permission permission);
        Task UpdateAsync(Permission permission);
        Task DeleteAsync(int id);
        
        Task<bool> ExistsByCodeAsync(string permissionCode);
        
        Task<IEnumerable<string>> GetUserPermissionCodesAsync(int userId);
        Task<bool> UserHasPermissionAsync(int userId, string permissionCode);
    }
}