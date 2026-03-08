using MediatR;
using Core.Module.Application.Common.Models;
using Core.Module.Application.Common.Mappings;
using Core.Module.Domain.Entities;
using Core.Module.Application.DTOs;

namespace Core.Module.Application.Features.Users.Queries.GetUserById
{
    public class GetUserByIdQuery : IRequest<Result<UserDto>>
    {
        public int Id { get; set; }
    }

    public class UserDto : IMapFrom<User>
    {
        public int Id { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public bool IsActive { get; set; }
        public DateTime? LastLogin { get; set; }
        public int? EmployeeId { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public List<string> Roles { get; set; }
    }
}