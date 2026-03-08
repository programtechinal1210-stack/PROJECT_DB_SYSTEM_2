using MediatR;
using Core.Module.Application.Common.Mappings;
using Core.Module.Application.Common.Models;

namespace Core.Module.Application.Features.Auth.Commands.Login
{
   // [Authorize] // This will be handled by the behaviour
    public class LoginCommand : IRequest<Result<LoginResponse>>
    {
        public string Username { get; set; }
        public string Password { get; set; }
        public bool RememberMe { get; set; }
        public string IpAddress { get; set; }
        public string UserAgent { get; set; }
    }

    public class LoginResponse
    {
        public string AccessToken { get; set; }
        public string RefreshToken { get; set; }
        public int ExpiresIn { get; set; }
        public UserInfo User { get; set; }
    }

    public class UserInfo
    {
        public int Id { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public List<string> Roles { get; set; }
        public List<string> Permissions { get; set; }
    }
}