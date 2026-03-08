using MediatR;
using Core.Module.Application.Common.Models;

namespace Core.Module.Application.Features.Roles.Commands.AssignPermission
{
  //  [Authorize(Permissions = "roles.edit")]
    public class AssignPermissionCommand : IRequest<Result>
    {
        public int RoleId { get; set; }
        public int PermissionId { get; set; }
    }
}