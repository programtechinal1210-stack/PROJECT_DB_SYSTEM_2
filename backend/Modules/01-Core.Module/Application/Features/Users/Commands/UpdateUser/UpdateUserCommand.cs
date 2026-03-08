using MediatR;
using Core.Module.Application.Common.Models;
using Core.Module.Application.Common.Mappings;
using Core.Module.Domain.Entities;
using Core.Module.Application.DTOs.Users;

namespace Core.Module.Application.Features.Users.Commands.UpdateUser
{
 //   [Authorize(Permissions = "users.edit")]
    public class UpdateUserCommand : IRequest<Result<UserDto>>, IMapFrom<User>
    {
        public int Id { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public string ConfirmPassword { get; set; }
        public bool? IsActive { get; set; }
    }
}