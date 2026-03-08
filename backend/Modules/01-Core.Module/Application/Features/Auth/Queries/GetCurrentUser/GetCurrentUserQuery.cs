using MediatR;
using Core.Module.Application.Common.Models;
using Core.Module.Application.Common.Mappings;
using Core.Module.Domain.Entities;

namespace Core.Module.Application.Features.Auth.Queries.GetCurrentUser
{
   // [Authorize]
    public class GetCurrentUserQuery : IRequest<Result<CurrentUserDto>>
    {
    }

    public class CurrentUserDto : IMapFrom<User>
    {
        public int Id { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public bool IsActive { get; set; }
        public DateTime? LastLogin { get; set; }
        public int? EmployeeId { get; set; }
        public List<string> Roles { get; set; }
        public List<string> Permissions { get; set; }
    }
}