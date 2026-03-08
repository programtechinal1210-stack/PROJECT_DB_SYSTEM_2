using MediatR;
using Core.Module.Application.Common.Models;
using Core.Module.Application.DTOs.Users;

namespace Core.Module.Application.Features.Users.Queries.GetUsers
{
    public class GetUsersQuery : IRequest<Result<PaginatedList<UserDto>>>
    {
        public int PageNumber { get; set; } = 1;
        public int PageSize { get; set; } = 10;
        public string? SearchTerm { get; set; }
        public string? SortBy { get; set; }
        public bool SortAscending { get; set; } = true;
        public bool? IsActive { get; set; }
        public int? RoleId { get; set; }
    }
}