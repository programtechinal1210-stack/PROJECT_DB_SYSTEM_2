using MediatR;
using Core.Module.Application.Common.Models;

namespace Core.Module.Application.Features.Users.Commands.AssignRole
{
  //  [Authorize(Permissions = "users.edit")]
    public class AssignRoleCommand : IRequest<Result>
    {
        public int UserId { get; set; }
        public int RoleId { get; set; }
    }
}