 
// using System;
// using System.Text.RegularExpressions;

// namespace Core.Module.Domain.ValueObjects
// {
//     public class Email : IEquatable<Email>
//     {
//         public string Value { get; }

//     private Email()
//         {
//             Value = string.Empty;  // تهيئة لتجنب warnings
//         }

//         public static Email Create(string email)
//         {
//             if (string.IsNullOrWhiteSpace(email))
//                 throw new ArgumentException("Email cannot be empty");

//             email = email.Trim().ToLower();

//             if (!IsValidEmail(email))
//                 throw new ArgumentException("Invalid email format");

//             return new Email(email);
//         }

//         private static bool IsValidEmail(string email)
//         {
//             try
//             {
//                 var emailRegex = new Regex(@"^[^@\s]+@[^@\s]+\.[^@\s]+$", 
//                     RegexOptions.Compiled | RegexOptions.IgnoreCase);
                
//                 return emailRegex.IsMatch(email) && email.Length <= 100;
//             }
//             catch
//             {
//                 return false;
//             }
//         }

//         public string GetDomain()
//         {
//             return Value.Split('@')[1];
//         }

//         public string GetUsername()
//         {
//             return Value.Split('@')[0];
//         }

//         public override string ToString() => Value;

//         public override bool Equals(object obj)
//         {
//             return Equals(obj as Email);
//         }

//         public bool Equals(Email other)
//         {
//             return other != null && Value == other.Value;
//         }

//         public override int GetHashCode()
//         {
//             return Value.GetHashCode();
//         }

//         public static implicit operator string(Email email) => email.Value;
        
//         public static explicit operator Email(string email) => Create(email);
//     }
// }


using System;

namespace Core.Module.Domain.ValueObjects
{
    public class Email : IEquatable<Email>
    {
        public string Value { get; }

        // ✅ Constructor خاص لـ EF Core - هذا هو المهم
        private Email()
        {
            Value = string.Empty;  // تهيئة لتجنب warnings
        }

        public Email(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                throw new ArgumentException("Email cannot be empty");

            if (!IsValidEmail(value))
                throw new ArgumentException("Invalid email format");

            Value = value.Trim().ToLower();
        }

        private static bool IsValidEmail(string email)
        {
            try
            {
                var addr = new System.Net.Mail.MailAddress(email);
                return addr.Address == email;
            }
            catch
            {
                return false;
            }
        }

        public override bool Equals(object obj)
        {
            return Equals(obj as Email);
        }

        public bool Equals(Email other)
        {
            return other != null && Value == other.Value;
        }

        public override int GetHashCode()
        {
            return HashCode.Combine(Value);
        }

        public override string ToString() => Value;

        public static implicit operator string(Email email) => email.Value;

        public static explicit operator Email(string value) => new Email(value);
    }
}