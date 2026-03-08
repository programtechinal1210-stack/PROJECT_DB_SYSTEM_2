using Core.Module.Domain.Common;
using MediatR;

namespace Core.Module.Domain.Events
{
    // أحداث المصادقة
    public class LoginFailedEvent : DomainEvent
    {
        public LoginFailedEvent(string username, string ipAddress, int attemptCount)
        {
            Username = username;
            IpAddress = ipAddress;
            AttemptCount = attemptCount;
        }

        public string Username { get; }
        public string IpAddress { get; }
        public int AttemptCount { get; }
    }

    public class AccountLockedEvent : DomainEvent
    {
        public AccountLockedEvent(int userId, string username, string reason)
        {
            UserId = userId;
            Username = username;
            Reason = reason;
        }

        public int UserId { get; }
        public string Username { get; }
        public string Reason { get; }
    }

    public class AccountUnlockedEvent : DomainEvent
    {
        public AccountUnlockedEvent(int userId, string username)
        {
            UserId = userId;
            Username = username;
        }

        public int UserId { get; }
        public string Username { get; }
    }

    public class PasswordResetRequestedEvent : DomainEvent
    {
        public PasswordResetRequestedEvent(int userId, string email, string resetToken)
        {
            UserId = userId;
            Email = email;
            ResetToken = resetToken;
        }

        public int UserId { get; }
        public string Email { get; }
        public string ResetToken { get; }
    }

    public class PasswordResetCompletedEvent : DomainEvent
    {
        public PasswordResetCompletedEvent(int userId)
        {
            UserId = userId;
        }

        public int UserId { get; }
    }
     public class UserLoggedOutEvent : DomainEvent, INotification
    {
        public int UserId { get; }
        public string? SessionId { get; } // استخدم SessionId بدلاً من SessionToken

        public UserLoggedOutEvent(int userId, string? sessionId = null)
        {
            UserId = userId;
            SessionId = sessionId;
        }
    }
}