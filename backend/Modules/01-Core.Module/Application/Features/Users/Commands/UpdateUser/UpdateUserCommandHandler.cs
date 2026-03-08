using MediatR;
using AutoMapper;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Common.Models;
using Core.Module.Application.Common.Exceptions;
using Core.Module.Domain.Interfaces;
using Core.Module.Application.DTOs.Users;

namespace Core.Module.Application.Features.Users.Commands.UpdateUser
{
    public class UpdateUserCommandHandler : IRequestHandler<UpdateUserCommand, Result<UserDto>>
    {
        private readonly IUserRepository _userRepository;
        private readonly ICacheService _cacheService;
        private readonly ICurrentUserService _currentUser;
        private readonly IMapper _mapper;
        private readonly ILogger<UpdateUserCommandHandler> _logger;

        public UpdateUserCommandHandler(
            IUserRepository userRepository,
            ICacheService cacheService,
            ICurrentUserService currentUser,
            IMapper mapper,
            ILogger<UpdateUserCommandHandler> logger)
        {
            _userRepository = userRepository;
            _cacheService = cacheService;
            _currentUser = currentUser;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task<Result<UserDto>> Handle(UpdateUserCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var user = await _userRepository.GetByIdAsync(request.Id);
                if (user == null)
                {
                    return Result<UserDto>.Failure($"User with ID {request.Id} not found");
                }

                // Update username
                if (!string.IsNullOrWhiteSpace(request.Username) && request.Username != user.Username)
                {
                    if (await _userRepository.ExistsByUsernameAsync(request.Username))
                    {
                        return Result<UserDto>.Failure($"Username {request.Username} already exists");
                    }
                    user.SetUsername(request.Username);
                }

                // Update email
                if (!string.IsNullOrWhiteSpace(request.Email) && request.Email != user.Email)
                {
                    if (await _userRepository.ExistsByEmailAsync(request.Email))
                    {
                        return Result<UserDto>.Failure($"Email {request.Email} already exists");
                    }
                    user.SetEmail(request.Email);
                }

                // Update password
                if (!string.IsNullOrWhiteSpace(request.Password))
                {
                    user.SetPassword(request.Password);
                }

                // Update active status
                if (request.IsActive.HasValue)
                {
                    if (request.IsActive.Value)
                        user.Activate();
                    else
                        user.Deactivate();
                }

                await _userRepository.UpdateAsync(user);

                // Clear caches
                await _cacheService.RemoveAsync($"user_{user.Id}", cancellationToken);
                await _cacheService.RemoveAsync($"current_user_{user.Id}", cancellationToken);
                await _cacheService.RemoveAsync($"user_permissions_{user.Id}", cancellationToken);

                _logger.LogInformation("User {UserId} updated by {UpdaterId}", user.Id, _currentUser.UserId);

                var userDto = _mapper.Map<UserDto>(user);
                userDto.Roles = user.UserRoles.Select(ur => ur.Role.RoleName).ToList();

                return Result<UserDto>.Success(userDto, "User updated successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating user {UserId}", request.Id);
                return Result<UserDto>.Failure("An error occurred while updating user");
            }
        }
    }
}