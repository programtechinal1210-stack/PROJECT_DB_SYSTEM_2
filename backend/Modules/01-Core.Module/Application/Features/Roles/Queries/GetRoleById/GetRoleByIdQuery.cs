
using MediatR;
using Core.Module.Application.Common.Models;
using Core.Module.Application.Common.Mappings;
using Core.Module.Domain.Entities;

namespace Core.Module.Application.Features.Roles.Queries.GetRoleById
{
   // [Authorize(Permissions = "roles.view")]
    public class GetRoleByIdQuery : IRequest<Result<RoleDetailDto>>
    {
        public int Id { get; set; }
    }

    public class RoleDetailDto : IMapFrom<Role>
    {
        public int Id { get; set; }
        public string RoleName { get; set; }
        public string RoleDescription { get; set; }
        public bool IsSystemRole { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public string CreatedBy { get; set; }
        public string UpdatedBy { get; set; }
        public List<RoleUserDto> Users { get; set; }
        public List<RolePermissionDto> Permissions { get; set; }
    }

    public class RoleUserDto
    {
        public int UserId { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public DateTime AssignedAt { get; set; }
    }

    public class RolePermissionDto
    {
        public int PermissionId { get; set; }
        public string PermissionCode { get; set; }
        public string PermissionName { get; set; }
        public string ModuleName { get; set; }
        public DateTime GrantedAt { get; set; }
    }
}