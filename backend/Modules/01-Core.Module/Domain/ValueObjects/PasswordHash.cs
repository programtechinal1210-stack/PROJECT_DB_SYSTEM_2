 
// using System;
// using System.Security.Cryptography;
// using Microsoft.AspNetCore.Cryptography.KeyDerivation;

// namespace Core.Module.Domain.ValueObjects
// {
//     public class PasswordHash : IEquatable<PasswordHash>
//     {
//        public string Hash { get; }
//         public string Salt { get; }

//         // For EF Core
//         private PasswordHash() { }

//         private PasswordHash(string hash, string salt)
//         {
//              Hash = string.Empty;
//     Salt = string.Empty;
//         }

//         public static PasswordHash Create(string password)
//         {
//             if (string.IsNullOrWhiteSpace(password))
//                 throw new ArgumentException("Password cannot be empty");

//             if (password.Length < 6)
//                 throw new ArgumentException("Password must be at least 6 characters long");

//             // Generate a 128-bit salt
//             byte[] salt = new byte[128 / 8];
//             using (var rng = RandomNumberGenerator.Create())
//             {
//                 rng.GetBytes(salt);
//             }

//             // Derive a 256-bit subkey
//             string hashed = Convert.ToBase64String(KeyDerivation.Pbkdf2(
//                 password: password,
//                 salt: salt,
//                 prf: KeyDerivationPrf.HMACSHA256,
//                 iterationCount: 10000,
//                 numBytesRequested: 256 / 8));

//             return new PasswordHash(hashed, Convert.ToBase64String(salt));
//         }

//         public static PasswordHash FromHash(string hash, string salt)
//         {
//             if (string.IsNullOrWhiteSpace(hash))
//                 throw new ArgumentException("Hash cannot be empty");
            
//             if (string.IsNullOrWhiteSpace(salt))
//                 throw new ArgumentException("Salt cannot be empty");

//             return new PasswordHash(hash, salt);
//         }

//         public bool Verify(string password)
//         {
//             if (string.IsNullOrWhiteSpace(password))
//                 return false;

//             byte[] salt = Convert.FromBase64String(Salt);

//             string hashed = Convert.ToBase64String(KeyDerivation.Pbkdf2(
//                 password: password,
//                 salt: salt,
//                 prf: KeyDerivationPrf.HMACSHA256,
//                 iterationCount: 10000,
//                 numBytesRequested: 256 / 8));

//             return Hash == hashed;
//         }

//         public PasswordHash Update(string newPassword)
//         {
//             return Create(newPassword);
//         }

//         public override bool Equals(object obj)
//         {
//             return Equals(obj as PasswordHash);
//         }

//         public bool Equals(PasswordHash other)
//         {
//             return other != null && Hash == other.Hash && Salt == other.Salt;
//         }

//         public override int GetHashCode()
//         {
//             return HashCode.Combine(Hash, Salt);
//         }
//     }
// }

using System;
using System.Security.Cryptography;
using Microsoft.AspNetCore.Cryptography.KeyDerivation;

namespace Core.Module.Domain.ValueObjects
{
    public class PasswordHash : IEquatable<PasswordHash>
    {
        public string Hash { get; }
        public string Salt { get; }

        // ✅ Constructor خاص لـ EF Core
        private PasswordHash()
        {
            Hash = string.Empty;
            Salt = string.Empty;
        }

        private PasswordHash(string hash, string salt)
        {
            Hash = hash;
            Salt = salt;
        }

        public static PasswordHash Create(string password)
        {
            if (string.IsNullOrWhiteSpace(password))
                throw new ArgumentException("Password cannot be empty");

            // Generate a 128-bit salt using a secure PRNG
            byte[] salt = new byte[128 / 8];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(salt);
            }

            // Derive a 256-bit subkey (use HMACSHA256 with 100,000 iterations)
            string hashed = Convert.ToBase64String(KeyDerivation.Pbkdf2(
                password: password,
                salt: salt,
                prf: KeyDerivationPrf.HMACSHA256,
                iterationCount: 100000,
                numBytesRequested: 256 / 8));

            return new PasswordHash(hashed, Convert.ToBase64String(salt));
        }

        public bool Verify(string password)
        {
            if (string.IsNullOrWhiteSpace(password))
                return false;

            byte[] salt = Convert.FromBase64String(Salt);
            string hashed = Convert.ToBase64String(KeyDerivation.Pbkdf2(
                password: password,
                salt: salt,
                prf: KeyDerivationPrf.HMACSHA256,
                iterationCount: 100000,
                numBytesRequested: 256 / 8));

            return Hash == hashed;
        }

        public override bool Equals(object obj)
        {
            return Equals(obj as PasswordHash);
        }

        public bool Equals(PasswordHash other)
        {
            return other != null && Hash == other.Hash && Salt == other.Salt;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(Hash, Salt);
        }
    }
}