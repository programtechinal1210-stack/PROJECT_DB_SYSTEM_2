using MediatR;
using Core.Module.Application.Common.Models;

namespace Core.Module.Application.Features.Users.Commands.ActivateUser
{
   // [Authorize(Permissions = "users.edit")]
    public class ActivateUserCommand : IRequest<Result>
    {
        public int Id { get; set; }
    }
}