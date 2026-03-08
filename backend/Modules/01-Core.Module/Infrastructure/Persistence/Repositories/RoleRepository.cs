 
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Core.Module.Domain.Entities;
using Core.Module.Domain.Interfaces;
using Core.Module.Infrastructure.Persistence.DbContext;

namespace Core.Module.Infrastructure.Persistence.Repositories
{
    public class RoleRepository : IRoleRepository
    {
        private readonly CoreDbContext _context;
        private readonly ILogger<RoleRepository> _logger;

        public RoleRepository(CoreDbContext context, ILogger<RoleRepository> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<Role> GetByIdAsync(int id)
        {
            return await _context.Roles
                .Include(r => r.Permissions)
                    .ThenInclude(rp => rp.Permission)
                .FirstOrDefaultAsync(r => r.Id == id);
        }

        public async Task<Role> GetByNameAsync(string roleName)
        {
            return await _context.Roles
                .Include(r => r.Permissions)
                    .ThenInclude(rp => rp.Permission)
                .FirstOrDefaultAsync(r => r.RoleName == roleName);
        }

        public async Task<IEnumerable<Role>> GetAllAsync()
        {
            return await _context.Roles
                .Include(r => r.Permissions)
                    .ThenInclude(rp => rp.Permission)
                .OrderBy(r => r.RoleName)
                .ToListAsync();
        }

        public async Task<IEnumerable<Role>> GetByUserAsync(int userId)
        {
            return await _context.UserRoles
                .Where(ur => ur.UserId == userId)
                .Select(ur => ur.Role)
                .Include(r => r.Permissions)
                    .ThenInclude(rp => rp.Permission)
                .ToListAsync();
        }

        public async Task<IEnumerable<Role>> GetSystemRolesAsync()
        {
            return await _context.Roles
                .Where(r => r.IsSystemRole)
                .Include(r => r.Permissions)
                    .ThenInclude(rp => rp.Permission)
                .ToListAsync();
        }

        public async Task<Role> AddAsync(Role role)
        {
            await _context.Roles.AddAsync(role);
            await _context.SaveChangesAsync();
            return role;
        }

        public async Task UpdateAsync(Role role)
        {
            _context.Entry(role).State = EntityState.Modified;
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            var role = await _context.Roles.FindAsync(id);
            if (role != null)
            {
                _context.Roles.Remove(role);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<bool> ExistsByNameAsync(string roleName)
        {
            return await _context.Roles.AnyAsync(r => r.RoleName == roleName);
        }

public async Task AddPermissionToRoleAsync(int roleId, int permissionId, int? grantedBy = null)
{
    var role = await GetByIdAsync(roleId);
    var permission = await _context.Permissions.FindAsync(permissionId);
    
    if (role == null)
        throw new ArgumentException($"Role with ID {roleId} not found");
    
    if (permission == null)
        throw new ArgumentException($"Permission with ID {permissionId} not found");
    
    // استخدم constructor الذي يأخذ الكائنات
    var rolePermission = new RolePermission(role, permission, grantedBy);
    await _context.RolePermissions.AddAsync(rolePermission);
    await _context.SaveChangesAsync();
}

        public async Task RemovePermissionFromRoleAsync(int roleId, int permissionId)
        {
            var rolePermission = await _context.RolePermissions
                .FirstOrDefaultAsync(rp => rp.RoleId == roleId && rp.PermissionId == permissionId);
            
            if (rolePermission != null)
            {
                _context.RolePermissions.Remove(rolePermission);
                await _context.SaveChangesAsync();
            }
        }

        public async Task ClearRolePermissionsAsync(int roleId)
        {
            var permissions = await _context.RolePermissions
                .Where(rp => rp.RoleId == roleId)
                .ToListAsync();
            
            _context.RolePermissions.RemoveRange(permissions);
            await _context.SaveChangesAsync();
        }

        public async Task<IEnumerable<Permission>> GetRolePermissionsAsync(int roleId)
        {
            return await _context.RolePermissions
                .Where(rp => rp.RoleId == roleId)
                .Select(rp => rp.Permission)
                .ToListAsync();
        }
    }
}