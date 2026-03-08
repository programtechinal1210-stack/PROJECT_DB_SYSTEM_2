 
using System;

namespace Core.Module.Domain.Entities
{
    public class UserSession
    {
        public int Id { get; private set; }
        public int UserId { get; private set; }
        public User User { get; private set; }
        public string SessionToken { get; private set; }
        public string IpAddress { get; private set; }
        public string UserAgent { get; private set; }
        public DateTime LoginAt { get; private set; }
        public DateTime LastActivity { get; private set; }
        public DateTime ExpiresAt { get; private set; }
                public string? RefreshToken { get; set; }  // ✅ إضافة RefreshToken (nullable)
        public bool IsActive { get; private set; }
    public DateTime LastActivityAt { get; set; }  // ✅ إضافة LastActivityAt
        public bool IsRevoked { get; set; } 
        private UserSession() { } // For EF Core

        public UserSession(int userId, string sessionToken, DateTime expiresAt, 
            string ipAddress = null, string userAgent = null)
        {
            if (userId <= 0)
                throw new ArgumentException("Invalid user ID");
            
            if (string.IsNullOrWhiteSpace(sessionToken))
                throw new ArgumentException("Session token cannot be empty");

            UserId = userId;
            SetSessionToken(sessionToken);
            IpAddress = ipAddress;
            UserAgent = userAgent;
            LoginAt = DateTime.UtcNow;
            LastActivity = DateTime.UtcNow;
            ExpiresAt = expiresAt;
            IsActive = true;
        }

        public void SetSessionToken(string token)
        {
            if (string.IsNullOrWhiteSpace(token))
                throw new ArgumentException("Session token cannot be empty");
            
            SessionToken = token;
        }

        public void UpdateActivity()
        {
            LastActivity = DateTime.UtcNow;
        }

        public void ExtendExpiry(DateTime newExpiry)
        {
            if (newExpiry <= ExpiresAt)
                throw new ArgumentException("New expiry must be later than current expiry");
            
            ExpiresAt = newExpiry;
        }

        public void Terminate()
        {
            IsActive = false;
            LastActivity = DateTime.UtcNow;
        }

        public bool IsExpired()
        {
            return DateTime.UtcNow >= ExpiresAt;
        }
    }
}