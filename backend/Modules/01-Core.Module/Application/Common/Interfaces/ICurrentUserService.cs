namespace Core.Module.Application.Common.Interfaces
{
    public interface ICurrentUserService
    {
        int? UserId { get; }
        string Username { get; }
        string Email { get; }
        string IpAddress { get; }
        string UserAgent { get; }
        bool IsAuthenticated { get; }
        IEnumerable<string> Roles { get; }
        IEnumerable<string> Permissions { get; }
        bool HasPermission(string permissionCode);
        bool HasRole(string roleName);
    }
}