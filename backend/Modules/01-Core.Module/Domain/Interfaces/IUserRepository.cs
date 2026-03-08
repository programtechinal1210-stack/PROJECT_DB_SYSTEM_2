using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Core.Module.Domain.Entities;

namespace Core.Module.Domain.Interfaces
{
    public interface IUserRepository
    {
        // تعديل: إضافة ? للدوال التي قد ترجع null
        Task<User?> GetByIdAsync(int id);
        Task<User?> GetByUsernameAsync(string username);
        Task<User?> GetByEmailAsync(string email);
        Task<User?> GetByRefreshTokenAsync(string refreshToken);
        
        // باقي الدوال كما هي
        Task<IEnumerable<User>> GetAllAsync(int page = 1, int pageSize = 20);
        Task<IEnumerable<User>> GetByRoleAsync(int roleId);
        Task<IEnumerable<User>> GetActiveUsersAsync();
        Task<int> GetTotalCountAsync();
        
        Task<User> AddAsync(User user);
        Task UpdateAsync(User user);
        Task DeleteAsync(int id);
        
        Task<bool> ExistsByUsernameAsync(string username);
        Task<bool> ExistsByEmailAsync(string email);
        
        // تعديل: إضافة ? هنا أيضاً
        Task<UserSession?> GetSessionAsync(string sessionToken);
        Task AddSessionAsync(UserSession session);
        Task UpdateSessionAsync(UserSession session);
        Task TerminateSessionAsync(string sessionToken);
        Task TerminateAllUserSessionsAsync(int userId);
        
        Task AddLoginAttemptAsync(string username, string ipAddress, bool success);
        Task<int> GetFailedLoginAttemptsAsync(string username, TimeSpan withinTime);
        
        Task<int> CleanupExpiredTokensAsync();
    }
}