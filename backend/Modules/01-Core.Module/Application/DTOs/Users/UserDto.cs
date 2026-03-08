using Core.Module.Application.Common.Mappings;
using Core.Module.Domain.Entities;
using Core.Module.Application.DTOs.Roles;


namespace Core.Module.Application.DTOs.Users
{
    public class UserDto : IMapFrom<User>
    {
        public int Id { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public bool IsActive { get; set; }
        public DateTime? LastLogin { get; set; }
        public int? EmployeeId { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public string CreatedBy { get; set; }
        public string UpdatedBy { get; set; }
        public List<string> Roles { get; set; }
        public int RolesCount => Roles?.Count ?? 0;
    }

    public class UserDetailsDto : UserDto
    {
        public List<RoleBasicDto> RoleDetails { get; set; }
        public List<UserSessionDto> ActiveSessions { get; set; }
        public LoginAttemptsDto LoginAttempts { get; set; }
    }

    public class UserSessionDto
    {
        public int Id { get; set; }
        public string SessionToken { get; set; }
        public string IpAddress { get; set; }
        public string UserAgent { get; set; }
        public DateTime LoginAt { get; set; }
        public DateTime LastActivity { get; set; }
        public DateTime ExpiresAt { get; set; }
        public bool IsActive { get; set; }
    }

    public class LoginAttemptsDto
    {
        public int TotalAttempts { get; set; }
        public int FailedAttempts { get; set; }
        public int SuccessfulAttempts { get; set; }
        public DateTime? LastAttempt { get; set; }
        public DateTime? LastSuccessfulLogin { get; set; }
        public DateTime? LastFailedLogin { get; set; }
    }
}