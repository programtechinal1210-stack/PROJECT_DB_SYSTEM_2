using System.Collections.Generic;
using System.Threading.Tasks;
using Core.Module.Application.DTOs.Roles;

namespace Core.Module.Application.Interfaces
{
    public interface IRoleService
    {
        Task<RoleDto> GetByIdAsync(int id);
        Task<RoleDto> GetByNameAsync(string roleName);
        Task<IEnumerable<RoleDto>> GetAllAsync();
        Task<IEnumerable<RoleDto>> GetByUserAsync(int userId);
        
        Task<RoleDto> CreateAsync(CreateRoleDto dto, int createdBy);
        Task<RoleDto> UpdateAsync(int id, UpdateRoleDto dto, int updatedBy);
        Task<bool> DeleteAsync(int id);
        
        Task<bool> AssignPermissionAsync(int roleId, int permissionId, int assignedBy);
        Task<bool> RemovePermissionAsync(int roleId, int permissionId);
        Task<IEnumerable<PermissionDto>> GetRolePermissionsAsync(int roleId);
    }
}