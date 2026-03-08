using MediatR;
using Core.Module.Application.Common.Models;

namespace Core.Module.Application.Features.Users.Commands.DeactivateUser
{
  //  [Authorize(Permissions = "users.edit")]
    public class DeactivateUserCommand : IRequest<Result>
    {
        public int Id { get; set; }
    }
}