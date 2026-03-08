using System.Collections.Generic;
using System.Threading.Tasks;
using Core.Module.Application.DTOs.Users;

namespace Core.Module.Application.Interfaces
{
    public interface IUserService
    {
        Task<UserDto> GetByIdAsync(int id);
        Task<UserDto> GetByUsernameAsync(string username);
        Task<UserDto> GetByEmailAsync(string email);
       // Task<PagedResult<UserDto>> GetAllAsync(int page, int pageSize);
        Task<IEnumerable<UserDto>> GetByRoleAsync(int roleId);
        
        Task<UserDto> CreateAsync(CreateUserDto dto, int createdBy);
        Task<UserDto> UpdateAsync(int id, UpdateUserDto dto, int updatedBy);
        Task<bool> DeleteAsync(int id);
        
        Task<bool> ActivateAsync(int id);
        Task<bool> DeactivateAsync(int id);
        
        Task<bool> AssignRoleAsync(int userId, int roleId, int assignedBy);
        Task<bool> RemoveRoleAsync(int userId, int roleId);
       // Task<IEnumerable<RoleDto>> GetUserRolesAsync(int userId);
    }
}