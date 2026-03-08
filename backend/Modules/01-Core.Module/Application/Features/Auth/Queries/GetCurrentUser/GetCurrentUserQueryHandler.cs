using MediatR;
using AutoMapper;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Common.Models;
using Core.Module.Application.Common.Exceptions;
using Core.Module.Domain.Interfaces;

namespace Core.Module.Application.Features.Auth.Queries.GetCurrentUser
{
    public class GetCurrentUserQueryHandler : IRequestHandler<GetCurrentUserQuery, Result<CurrentUserDto>>
    {
        private readonly IUserRepository _userRepository;
        private readonly ICurrentUserService _currentUser;
        private readonly ICacheService _cacheService;
        private readonly IMapper _mapper;
        private readonly ILogger<GetCurrentUserQueryHandler> _logger;

        public GetCurrentUserQueryHandler(
            IUserRepository userRepository,
            ICurrentUserService currentUser,
            ICacheService cacheService,
            IMapper mapper,
            ILogger<GetCurrentUserQueryHandler> logger)
        {
            _userRepository = userRepository;
            _currentUser = currentUser;
            _cacheService = cacheService;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task<Result<CurrentUserDto>> Handle(GetCurrentUserQuery request, CancellationToken cancellationToken)
        {
            try
            {
                if (!_currentUser.UserId.HasValue)
                {
                    return Result<CurrentUserDto>.Failure("User not authenticated");
                }

                // Try to get from cache first
                var cachedUser = await _cacheService.GetAsync<CurrentUserDto>(
                    $"current_user_{_currentUser.UserId}", cancellationToken);

                if (cachedUser != null)
                {
                    return Result<CurrentUserDto>.Success(cachedUser);
                }

                // Get from database
                var user = await _userRepository.GetByIdAsync(_currentUser.UserId.Value);
                if (user == null)
                {
                    return Result<CurrentUserDto>.Failure("User not found");
                }

                var userDto = _mapper.Map<CurrentUserDto>(user);
                userDto.Roles = user.UserRoles.Select(ur => ur.Role.RoleName).ToList();
                userDto.Permissions = user.GetAllPermissions().ToList();

                // Cache for 5 minutes
                await _cacheService.SetAsync(
                    $"current_user_{_currentUser.UserId}", 
                    userDto, 
                    TimeSpan.FromMinutes(5),
                    cancellationToken);

                return Result<CurrentUserDto>.Success(userDto);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting current user");
                return Result<CurrentUserDto>.Failure("An error occurred while retrieving current user");
            }
        }
    }
}