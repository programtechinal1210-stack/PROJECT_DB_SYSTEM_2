using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using Core.Module.Application.Common.Interfaces;

namespace Core.Module.Infrastructure.Services
{
    public class CurrentUserService : ICurrentUserService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public CurrentUserService(IHttpContextAccessor httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        public int? UserId
        {
            get
            {
                var userIdClaim = _httpContextAccessor.HttpContext?.User?
                    .FindFirst(ClaimTypes.NameIdentifier)?.Value;
                
                return userIdClaim != null ? int.Parse(userIdClaim) : null;
            }
        }

        public string Username => _httpContextAccessor.HttpContext?.User?
            .FindFirst(ClaimTypes.Name)?.Value;

        public string Email => _httpContextAccessor.HttpContext?.User?
            .FindFirst(ClaimTypes.Email)?.Value;

        public string IpAddress => _httpContextAccessor.HttpContext?.Connection?.RemoteIpAddress?.ToString();

        public string UserAgent => _httpContextAccessor.HttpContext?.Request?
            .Headers["User-Agent"].ToString();

        public bool IsAuthenticated => _httpContextAccessor.HttpContext?.User?.Identity?.IsAuthenticated ?? false;

        public IEnumerable<string> Roles => _httpContextAccessor.HttpContext?.User?
            .FindAll(ClaimTypes.Role).Select(c => c.Value) ?? new List<string>();

        public IEnumerable<string> Permissions => _httpContextAccessor.HttpContext?.User?
            .FindAll("permission").Select(c => c.Value) ?? new List<string>();

        public bool HasPermission(string permissionCode)
        {
            return Permissions.Contains(permissionCode);
        }

        public bool HasRole(string roleName)
        {
            return Roles.Contains(roleName);
        }
    }
}