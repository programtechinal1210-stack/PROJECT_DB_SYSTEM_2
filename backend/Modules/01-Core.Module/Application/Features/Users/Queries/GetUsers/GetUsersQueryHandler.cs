using MediatR;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Common.Models;
using Core.Module.Domain.Specifications;
using Core.Module.Domain.Interfaces;
using Core.Module.Application.DTOs.Users;  // ← أضف هذا السطر
namespace Core.Module.Application.Features.Users.Queries.GetUsers
{
    public class GetUsersQueryHandler : IRequestHandler<GetUsersQuery, Result<PaginatedList<UserDto>>>
    {
        private readonly IUserRepository _userRepository;
        private readonly IMapper _mapper;
        private readonly ILogger<GetUsersQueryHandler> _logger;

        public GetUsersQueryHandler(
            IUserRepository userRepository,
            IMapper mapper,
            ILogger<GetUsersQueryHandler> logger)
        {
            _userRepository = userRepository;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task<Result<PaginatedList<UserDto>>> Handle(GetUsersQuery request, CancellationToken cancellationToken)
        {
            try
            {
                var users = await _userRepository.GetAllAsync(request.PageNumber, request.PageSize);
                var totalCount = await _userRepository.GetTotalCountAsync();

                var userDtos = new List<UserDto>();
                foreach (var user in users)
                {
                    var userDto = _mapper.Map<UserDto>(user);
                    userDto.Roles = user.UserRoles.Select(ur => ur.Role.RoleName).ToList();
                    userDtos.Add(userDto);
                }

                var paginatedList = new PaginatedList<UserDto>(
                    userDtos, totalCount, request.PageNumber, request.PageSize);

                return Result<PaginatedList<UserDto>>.Success(paginatedList);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting users list");
                return Result<PaginatedList<UserDto>>.Failure("An error occurred while retrieving users");
            }
        }
    }
}