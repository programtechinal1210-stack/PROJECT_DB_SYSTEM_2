using MediatR;
using Core.Module.Application.Common.Models;
using Core.Module.Application.DTOs.Roles;

namespace Core.Module.Application.Features.Roles.Commands.CreateRole
{
    public class CreateRoleCommand : IRequest<Result<RoleDto>>
    {
        public string RoleName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public bool IsSystemRole { get; set; }
        public List<int>? PermissionIds { get; set; }
    }
}