using MediatR;
using Core.Module.Application.Common.Models;
using Core.Module.Application.DTOs.Roles;

namespace Core.Module.Application.Features.Roles.Commands.UpdateRole
{
    public class UpdateRoleCommand : IRequest<Result<RoleDto>>
    {
        public int Id { get; set; }
        public string? RoleName { get; set; }
        public string? Description { get; set; }
    }
}