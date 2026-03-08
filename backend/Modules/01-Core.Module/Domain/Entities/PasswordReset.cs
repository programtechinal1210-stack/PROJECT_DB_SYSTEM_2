using System;

namespace Core.Module.Domain.Entities
{
    // public class PasswordReset
    // {
    //     public int Id { get; set; }
    //     public int UserId { get; set; }
    //     public User User { get; set; }
    //     public string ResetToken { get; set; }
    //     public DateTime ExpiresAt { get; set; }
    //     public bool Used { get; set; }
    //     public DateTime CreatedAt { get; set; }
    //         public string Token { get; set; }  // ✅ إضافة Token
    //     public bool IsUsed { get; set; }  // ✅ إضافة IsUsed

    // }
    public class PasswordReset
{
    public int Id { get; set; }

    public int UserId { get; set; }
    public User User { get; set; }

    public string Token { get; set; }

    public DateTime ExpiresAt { get; set; }

    public bool IsUsed { get; set; }

    public DateTime CreatedAt { get; set; }
}
}