using MediatR;
using Core.Module.Application.Common.Models;

namespace Core.Module.Application.Features.Roles.Commands.DeleteRole
{
   // [Authorize(Permissions = "roles.delete")]
    public class DeleteRoleCommand : IRequest<Result>
    {
        public int Id { get; set; }
    }
}