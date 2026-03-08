using Core.Module.Domain.Common;

namespace Core.Module.Domain.Events
{
    // أحداث الجلسات
    public class SessionCreatedEvent : DomainEvent
    {
        public SessionCreatedEvent(int userId, string sessionToken, string ipAddress, DateTime expiresAt)
        {
            UserId = userId;
            SessionToken = sessionToken;
            IpAddress = ipAddress;
            ExpiresAt = expiresAt;
        }

        public int UserId { get; }
        public string SessionToken { get; }
        public string IpAddress { get; }
        public DateTime ExpiresAt { get; }
    }

    public class SessionExpiredEvent : DomainEvent
    {
        public SessionExpiredEvent(int userId, string sessionToken)
        {
            UserId = userId;
            SessionToken = sessionToken;
        }

        public int UserId { get; }
        public string SessionToken { get; }
    }

    public class SessionTerminatedEvent : DomainEvent
    {
        public SessionTerminatedEvent(int userId, string sessionToken)
        {
            UserId = userId;
            SessionToken = sessionToken;
        }

        public int UserId { get; }
        public string SessionToken { get; }
    }

    public class AllUserSessionsTerminatedEvent : DomainEvent
    {
        public AllUserSessionsTerminatedEvent(int userId)
        {
            UserId = userId;
        }

        public int UserId { get; }
    }
}