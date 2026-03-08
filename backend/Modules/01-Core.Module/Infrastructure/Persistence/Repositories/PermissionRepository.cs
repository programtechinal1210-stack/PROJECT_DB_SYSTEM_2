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
    public class PermissionRepository : IPermissionRepository
    {
        private readonly CoreDbContext _context;
        private readonly ILogger<PermissionRepository> _logger;

        public PermissionRepository(CoreDbContext context, ILogger<PermissionRepository> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<Permission> GetByIdAsync(int id)
        {
            return await _context.Permissions
                .Include(p => p.Module)
                .FirstOrDefaultAsync(p => p.Id == id);
        }

        public async Task<Permission> GetByCodeAsync(string permissionCode)
        {
            return await _context.Permissions
                .Include(p => p.Module)
                .FirstOrDefaultAsync(p => p.PermissionCode == permissionCode);
        }

        public async Task<IEnumerable<Permission>> GetAllAsync()
        {
            return await _context.Permissions
                .Include(p => p.Module)
                .OrderBy(p => p.ModuleId)
                .ThenBy(p => p.PermissionCode)
                .ToListAsync();
        }

        public async Task<IEnumerable<Permission>> GetByModuleAsync(int moduleId)
        {
            return await _context.Permissions
                .Where(p => p.ModuleId == moduleId)
                .Include(p => p.Module)
                .ToListAsync();
        }

        public async Task<IEnumerable<Permission>> GetByRoleAsync(int roleId)
        {
            return await _context.RolePermissions
                .Where(rp => rp.RoleId == roleId)
                .Select(rp => rp.Permission)
                .Include(p => p.Module)
                .ToListAsync();
        }

        public async Task<IEnumerable<Permission>> GetByUserAsync(int userId)
        {
            return await _context.UserRoles
                .Where(ur => ur.UserId == userId)
                .SelectMany(ur => ur.Role.Permissions.Select(rp => rp.Permission))
                .Distinct()
                .Include(p => p.Module)
                .ToListAsync();
        }

        public async Task<Permission> AddAsync(Permission permission)
        {
            await _context.Permissions.AddAsync(permission);
            await _context.SaveChangesAsync();
            return permission;
        }

        public async Task UpdateAsync(Permission permission)
        {
            _context.Entry(permission).State = EntityState.Modified;
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            var permission = await _context.Permissions.FindAsync(id);
            if (permission != null)
            {
                _context.Permissions.Remove(permission);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<bool> ExistsByCodeAsync(string permissionCode)
        {
            return await _context.Permissions
                .AnyAsync(p => p.PermissionCode == permissionCode);
        }

        public async Task<IEnumerable<string>> GetUserPermissionCodesAsync(int userId)
        {
            return await _context.UserRoles
                .Where(ur => ur.UserId == userId)
                .SelectMany(ur => ur.Role.Permissions.Select(rp => rp.Permission.PermissionCode))
                .Distinct()
                .ToListAsync();
        }

        public async Task<bool> UserHasPermissionAsync(int userId, string permissionCode)
        {
            return await _context.UserRoles
                .Where(ur => ur.UserId == userId)
                .SelectMany(ur => ur.Role.Permissions)
                .AnyAsync(rp => rp.Permission.PermissionCode == permissionCode);
        }
    }
}