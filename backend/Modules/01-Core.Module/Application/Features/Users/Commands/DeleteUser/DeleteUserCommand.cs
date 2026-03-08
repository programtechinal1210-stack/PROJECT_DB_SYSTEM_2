using MediatR;
using Core.Module.Application.Common.Models;

namespace Core.Module.Application.Features.Users.Commands.DeleteUser
{
  //  [Authorize(Permissions = "users.delete")]
    public class DeleteUserCommand : IRequest<Result>
    {
        public int Id { get; set; }
    }
}