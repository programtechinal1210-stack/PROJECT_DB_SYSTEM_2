 
// using System;
// using System.Collections.Generic;
// using System.Linq;
// using System.Threading.Tasks;
// using Microsoft.EntityFrameworkCore;
// using Microsoft.Extensions.Logging;
// using Core.Module.Domain.Entities;
// using Core.Module.Domain.Interfaces;
// using Core.Module.Infrastructure.Persistence.DbContext;

// namespace Core.Module.Infrastructure.Persistence.Repositories
// {
//     public class UserRepository : IUserRepository
//     {
//         private readonly CoreDbContext _context;
//         private readonly ILogger<UserRepository> _logger;

//         public UserRepository(CoreDbContext context, ILogger<UserRepository> logger)
//         {
//             _context = context;
//             _logger = logger;
//         }

//         public async Task<User> GetByIdAsync(int id)
//         {
//             return await _context.Users
//                 .Include(u => u.UserRoles)
//                     .ThenInclude(ur => ur.Role)
//                         .ThenInclude(r => r.Permissions)
//                             .ThenInclude(rp => rp.Permission)
//                 .FirstOrDefaultAsync(u => u.Id == id);
//         }

//         public async Task<User> GetByUsernameAsync(string username)
//         {
//             return await _context.Users
//                 .Include(u => u.UserRoles)
//                     .ThenInclude(ur => ur.Role)
//                 .FirstOrDefaultAsync(u => u.Username == username);
//         }

//         public async Task<User> GetByEmailAsync(string email)
//         {
//             return await _context.Users
//                 .Include(u => u.UserRoles)
//                     .ThenInclude(ur => ur.Role)
//                 .FirstOrDefaultAsync(u => u.Email == email);
//         }

//         public async Task<User> GetByRefreshTokenAsync(string refreshToken)
//         {
//             return await _context.Users
//                 .FirstOrDefaultAsync(u => u.RefreshToken.Token == refreshToken);
//         }

//         public async Task<IEnumerable<User>> GetAllAsync(int page = 1, int pageSize = 20)
//         {
//             return await _context.Users
//                 .Include(u => u.UserRoles)
//                     .ThenInclude(ur => ur.Role)
//                 .OrderBy(u => u.Username)
//                 .Skip((page - 1) * pageSize)
//                 .Take(pageSize)
//                 .ToListAsync();
//         }

//         public async Task<IEnumerable<User>> GetByRoleAsync(int roleId)
//         {
//             return await _context.Users
//                 .Where(u => u.UserRoles.Any(ur => ur.RoleId == roleId))
//                 .Include(u => u.UserRoles)
//                     .ThenInclude(ur => ur.Role)
//                 .ToListAsync();
//         }

//         public async Task<IEnumerable<User>> GetActiveUsersAsync()
//         {
//             return await _context.Users
//                 .Where(u => u.IsActive)
//                 .Include(u => u.UserRoles)
//                     .ThenInclude(ur => ur.Role)
//                 .ToListAsync();
//         }

//         public async Task<int> GetTotalCountAsync()
//         {
//             return await _context.Users.CountAsync();
//         }

//         public async Task<User> AddAsync(User user)
//         {
//             await _context.Users.AddAsync(user);
//             await _context.SaveChangesAsync();
//             return user;
//         }

//         public async Task UpdateAsync(User user)
//         {
//             _context.Entry(user).State = EntityState.Modified;
//             await _context.SaveChangesAsync();
//         }

//         public async Task DeleteAsync(int id)
//         {
//             var user = await _context.Users.FindAsync(id);
//             if (user != null)
//             {
//                 _context.Users.Remove(user);
//                 await _context.SaveChangesAsync();
//             }
//         }

//         public async Task<bool> ExistsByUsernameAsync(string username)
//         {
//             return await _context.Users.AnyAsync(u => u.Username == username);
//         }

//         public async Task<bool> ExistsByEmailAsync(string email)
//         {
//             return await _context.Users.AnyAsync(u => u.Email == email);
//         }

//         public async Task<UserSession> GetSessionAsync(string sessionToken)
//         {
//             return await _context.UserSessions
//                 .FirstOrDefaultAsync(s => s.SessionToken == sessionToken && s.IsActive);
//         }

//         public async Task AddSessionAsync(UserSession session)
//         {
//             await _context.UserSessions.AddAsync(session);
//             await _context.SaveChangesAsync();
//         }

//         public async Task UpdateSessionAsync(UserSession session)
//         {
//             _context.Entry(session).State = EntityState.Modified;
//             await _context.SaveChangesAsync();
//         }

//         public async Task TerminateSessionAsync(string sessionToken)
//         {
//             var session = await _context.UserSessions
//                 .FirstOrDefaultAsync(s => s.SessionToken == sessionToken);
            
//             if (session != null)
//             {
//                 session.Terminate();
//                 await _context.SaveChangesAsync();
//             }
//         }

//         public async Task TerminateAllUserSessionsAsync(int userId)
//         {
//             var sessions = await _context.UserSessions
//                 .Where(s => s.UserId == userId && s.IsActive)
//                 .ToListAsync();

//             foreach (var session in sessions)
//             {
//                 session.Terminate();
//             }

//             await _context.SaveChangesAsync();
//         }

//         public async Task AddLoginAttemptAsync(string username, string ipAddress, bool success)
//         {
//             var attempt = new LoginAttempt
//             {
//                 Username = username,
//                 IpAddress = ipAddress,
//                 Success = success,
//                 AttemptTime = DateTime.UtcNow
//             };

//             await _context.LoginAttempts.AddAsync(attempt);
//             await _context.SaveChangesAsync();
//         }

//         public async Task<int> GetFailedLoginAttemptsAsync(string username, TimeSpan withinTime)
//         {
//             var cutoff = DateTime.UtcNow.Subtract(withinTime);
            
//             return await _context.LoginAttempts
//                 .CountAsync(a => a.Username == username && 
//                                  !a.Success && 
//                                  a.AttemptTime >= cutoff);
//         }
        
//     }
// }



using System;
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
    public class UserRepository : IUserRepository
    {
        private readonly CoreDbContext _context;
        private readonly ILogger<UserRepository> _logger;

        public UserRepository(CoreDbContext context, ILogger<UserRepository> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<User?> GetByIdAsync(int id)
        {
            return await _context.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                        .ThenInclude(r => r.Permissions)
                            .ThenInclude(rp => rp.Permission)
                .FirstOrDefaultAsync(u => u.Id == id);
        }

   public async Task<User?> GetByUsernameAsync(string username)
{
    return await _context.Users
        .Include(u => u.UserRoles)
            .ThenInclude(ur => ur.Role)
        .FirstOrDefaultAsync(u => u.Username == username);
}

        public async Task<User?> GetByEmailAsync(string email)
        {
            return await _context.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Email == email);
        }

        public async Task<User?> GetByRefreshTokenAsync(string refreshToken)
        {
            return await _context.Users
                .FirstOrDefaultAsync(u => u.RefreshToken.Token == refreshToken);
        }

        public async Task<IEnumerable<User>> GetAllAsync(int page = 1, int pageSize = 20)
        {
            return await _context.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .OrderBy(u => u.Username)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();
        }

        public async Task<IEnumerable<User>> GetByRoleAsync(int roleId)
        {
            return await _context.Users
                .Where(u => u.UserRoles.Any(ur => ur.RoleId == roleId))
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .ToListAsync();
        }

        public async Task<IEnumerable<User>> GetActiveUsersAsync()
        {
            return await _context.Users
                .Where(u => u.IsActive)
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .ToListAsync();
        }

        public async Task<int> GetTotalCountAsync()
        {
            return await _context.Users.CountAsync();
        }

        public async Task<User> AddAsync(User user)
        {
            await _context.Users.AddAsync(user);
            await _context.SaveChangesAsync();
            return user;
        }

        public async Task UpdateAsync(User user)
        {
            _context.Entry(user).State = EntityState.Modified;
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == id);
            if (user != null)
            {
                _context.Users.Remove(user);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<bool> ExistsByUsernameAsync(string username)
        {
            return await _context.Users.AnyAsync(u => u.Username == username);
        }

        public async Task<bool> ExistsByEmailAsync(string email)
        {
            return await _context.Users.AnyAsync(u => u.Email == email);
        }

        public async Task<UserSession?> GetSessionAsync(string sessionToken)
        {
            return await _context.UserSessions
                .FirstOrDefaultAsync(s => s.SessionToken == sessionToken && s.IsActive);
        }

        public async Task AddSessionAsync(UserSession session)
        {
            await _context.UserSessions.AddAsync(session);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateSessionAsync(UserSession session)
        {
            _context.Entry(session).State = EntityState.Modified;
            await _context.SaveChangesAsync();
        }

        public async Task TerminateSessionAsync(string sessionToken)
        {
            var session = await _context.UserSessions
                .FirstOrDefaultAsync(s => s.SessionToken == sessionToken);
            
            if (session != null)
            {
                session.Terminate();
                await _context.SaveChangesAsync();
            }
        }

        public async Task TerminateAllUserSessionsAsync(int userId)
        {
            var sessions = await _context.UserSessions
                .Where(s => s.UserId == userId && s.IsActive)
                .ToListAsync();

            foreach (var session in sessions)
            {
                session.Terminate();
            }

            await _context.SaveChangesAsync();
        }

        public async Task AddLoginAttemptAsync(string username, string ipAddress, bool success)
        {
            var attempt = new LoginAttempt
            {
                Username = username,
                IpAddress = ipAddress,
                Success = success,
                AttemptTime = DateTime.UtcNow
            };

            await _context.LoginAttempts.AddAsync(attempt);
            await _context.SaveChangesAsync();
        }

        public async Task<int> GetFailedLoginAttemptsAsync(string username, TimeSpan withinTime)
        {
            var cutoff = DateTime.UtcNow.Subtract(withinTime);
            
            return await _context.LoginAttempts
                .CountAsync(a => a.Username == username && 
                                 !a.Success && 
                                 a.AttemptTime >= cutoff);
        }

       public async Task<int> CleanupExpiredTokensAsync()
{
    try
    {
        var expiredSessions = await _context.UserSessions
            .Where(s => s.ExpiresAt < DateTime.UtcNow)
            .ToListAsync();
        
        if (expiredSessions.Any())
        {
            _context.UserSessions.RemoveRange(expiredSessions);
            return await _context.SaveChangesAsync();
        }
        return 0;
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Error cleaning up expired sessions");
        throw;
    }
}
        }
    }
