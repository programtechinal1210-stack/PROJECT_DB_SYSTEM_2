using MediatR;
using Core.Module.Application.Common.Mappings;
using Core.Module.Application.Common.Models;
using Core.Module.Domain.Entities;
using Core.Module.Application.DTOs.Users;

namespace Core.Module.Application.Features.Users.Commands.CreateUser
{
  //  [Authorize(Permissions = "users.create")]
    public class CreateUserCommand : IRequest<Result<UserDto>>, IMapFrom<User>
    {
        public string Username { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public string ConfirmPassword { get; set; }
        public int? EmployeeId { get; set; }
        public List<int> RoleIds { get; set; }

        // public void Mapping(Profile profile)
        // {
        //     profile.CreateMap<CreateUserCommand, User>();
        // }
    }
}