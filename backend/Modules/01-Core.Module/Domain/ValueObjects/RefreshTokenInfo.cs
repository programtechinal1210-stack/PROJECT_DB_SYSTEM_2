using System;

namespace Core.Module.Domain.ValueObjects
{
    public class RefreshTokenInfo
    {
        public string Token { get; set; } = string.Empty;
        public DateTime ExpiryDate { get; set; }
        public bool IsRevoked { get; set; }
        public string? RevokedByIp { get; set; }
        public DateTime? RevokedAt { get; set; }
    }
}