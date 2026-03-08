// using Microsoft.EntityFrameworkCore;
// using Core.Module.Domain.Entities;

// namespace Core.Module.Application.Common.Interfaces
// {
//     public interface IApplicationDbContext
//     {
//         DbSet<User> Users { get; }
//         DbSet<Role> Roles { get; }
//         DbSet<Permission> Permissions { get; }
//         DbSet<Module> Modules { get; }
//         DbSet<UserRole> UserRoles { get; }
//         DbSet<RolePermission> RolePermissions { get; }
//         DbSet<UserSession> UserSessions { get; }
//         DbSet<LoginAttempt> LoginAttempts { get; }
//         DbSet<PasswordReset> PasswordResets { get; }

//         Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
//         Task BeginTransactionAsync();
//         Task CommitTransactionAsync();
//         Task RollbackTransactionAsync();
//     }
// }

using Microsoft.EntityFrameworkCore;
using Core.Module.Domain.Entities;
using ModuleEntity = Core.Module.Domain.Entities.Module; // Alias لتجنب التضارب

namespace Core.Module.Application.Common.Interfaces
{
    public interface IApplicationDbContext
    {
        DbSet<User> Users { get; }
        DbSet<Role> Roles { get; }
        DbSet<Permission> Permissions { get; }
        DbSet<ModuleEntity> Modules { get; } // استخدام Alias
        DbSet<UserRole> UserRoles { get; }
        DbSet<RolePermission> RolePermissions { get; }
        DbSet<UserSession> UserSessions { get; }
        DbSet<LoginAttempt> LoginAttempts { get; }
        DbSet<PasswordReset> PasswordResets { get; }

        Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
        Task BeginTransactionAsync();
        Task CommitTransactionAsync();
        Task RollbackTransactionAsync();
    }
}