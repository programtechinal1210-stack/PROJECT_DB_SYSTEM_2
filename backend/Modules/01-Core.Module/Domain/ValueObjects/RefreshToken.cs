// using System;

// namespace Core.Module.Domain.ValueObjects
// {
//     public class RefreshToken : IEquatable<RefreshToken>
//     {
//         public string Token { get; }
//            public DateTime? Expiry { get; }  // ✅ أضف علامة الاستفهام

//     public RefreshToken(string token, DateTime? expiry)  // ✅ تعديل الـ constructor
//     {
//         if (string.IsNullOrWhiteSpace(token))
//             throw new ArgumentException("Token cannot be empty");
        
//         // إذا كان expiry له قيمة، تأكد أنها في المستقبل
//         if (expiry.HasValue && expiry.Value <= DateTime.UtcNow)
//             throw new ArgumentException("Expiry must be in the future");

//     Token = string.Empty;
//         Expiry = expiry;
//     }

//     public bool IsValid()
//     {
//         return Expiry.HasValue && DateTime.UtcNow < Expiry.Value;
//     }

//     public bool IsExpired()
//     {
//         return Expiry.HasValue && DateTime.UtcNow >= Expiry.Value;
//     }
//         public RefreshToken Rotate(DateTime newExpiry)
//         {
//             return new RefreshToken(Guid.NewGuid().ToString("N"), newExpiry);
//         }

//         public override bool Equals(object obj)
//         {
//             return Equals(obj as RefreshToken);
//         }

//         public bool Equals(RefreshToken other)
//         {
//             return other != null && Token == other.Token && Expiry == other.Expiry;
//         }

//         public override int GetHashCode()
//         {
//             return HashCode.Combine(Token, Expiry);
//         }

//         public override string ToString() => Token;
//     }
// }


using System;

namespace Core.Module.Domain.ValueObjects
{
    public class RefreshToken : IEquatable<RefreshToken>
    {
        public string Token { get; }
        public DateTime Expiry { get; }

        // ✅ Constructor خاص لـ EF Core
        private RefreshToken()
        {
            Token = string.Empty;
        }

        public RefreshToken(string token, DateTime expiry)
        {
            if (string.IsNullOrWhiteSpace(token))
                throw new ArgumentException("Token cannot be empty");
            
            if (expiry <= DateTime.UtcNow)
                throw new ArgumentException("Expiry must be in the future");

            Token = token;
            Expiry = expiry;
        }

        public bool IsValid()
        {
            return DateTime.UtcNow < Expiry;
        }

        public bool IsExpired()
        {
            return DateTime.UtcNow >= Expiry;
        }

        public RefreshToken Rotate(DateTime newExpiry)
        {
            return new RefreshToken(Guid.NewGuid().ToString("N"), newExpiry);
        }

        public override bool Equals(object obj)
        {
            return Equals(obj as RefreshToken);
        }

        public bool Equals(RefreshToken other)
        {
            return other != null && Token == other.Token && Expiry == other.Expiry;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(Token, Expiry);
        }

        public override string ToString() => Token;
    }
}