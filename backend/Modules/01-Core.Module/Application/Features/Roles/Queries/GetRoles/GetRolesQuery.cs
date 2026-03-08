using MediatR;
using Core.Module.Application.Common.Models;
using Core.Module.Application.Common.Mappings;
using Core.Module.Domain.Entities;

namespace Core.Module.Application.Features.Roles.Queries.GetRoles
{
  //  [Authorize(Permissions = "roles.view")]
    public class GetRolesQuery : IRequest<Result<List<RoleDto>>>
    {
        public bool IncludeSystemRoles { get; set; } = true;
        public string SearchTerm { get; set; }
    }

    public class RoleDto : IMapFrom<Role>
    {
        public int Id { get; set; }
        public string RoleName { get; set; }
        public string RoleDescription { get; set; }
        public bool IsSystemRole { get; set; }
        public DateTime CreatedAt { get; set; }
        public int UsersCount { get; set; }
        public int PermissionsCount { get; set; }
    }
}