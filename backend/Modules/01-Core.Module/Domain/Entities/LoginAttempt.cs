using System;

namespace Core.Module.Domain.Entities
{
    public class LoginAttempt
    {
        public int Id { get; set; }
        public string Username { get; set; }
        public string IpAddress { get; set; }
        public bool Success { get; set; }
        public DateTime AttemptTime { get; set; }
         public string? UserAgent { get; set; }  // ✅ إضافة UserAgent
        public DateTime AttemptedAt { get; set; }  // ✅ إضافة AttemptedAt
        public bool IsSuccessful { get; set; }  // ✅ إضافة IsSuccessful
        public string? FailureReason { get; set; }
    }
}