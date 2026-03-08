using MediatR;
using AutoMapper;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Common.Models;
using Core.Module.Application.Common.Exceptions;
using Core.Module.Domain.Interfaces;
using Core.Module.Domain.Entities;
using Core.Module.Application.DTOs.Users;  // ← أضف هذا السطر في البداية
namespace Core.Module.Application.Features.Users.Commands.CreateUser
{
    public class CreateUserCommandHandler : IRequestHandler<CreateUserCommand, Result<UserDto>>
    {
        private readonly IUserRepository _userRepository;
        private readonly IRoleRepository _roleRepository;
        private readonly IMapper _mapper;
        private readonly ICurrentUserService _currentUser;
        private readonly ILogger<CreateUserCommandHandler> _logger;

        public CreateUserCommandHandler(
            IUserRepository userRepository,
            IRoleRepository roleRepository,
            IMapper mapper,
            ICurrentUserService currentUser,
            ILogger<CreateUserCommandHandler> logger)
        {
            _userRepository = userRepository;
            _roleRepository = roleRepository;
            _mapper = mapper;
            _currentUser = currentUser;
            _logger = logger;
        }

        public async Task<Result<UserDto>> Handle(CreateUserCommand request, CancellationToken cancellationToken)
        {
            try
            {
                // Check if username exists
                if (await _userRepository.ExistsByUsernameAsync(request.Username))
                {
                    return Result<UserDto>.Failure($"Username {request.Username} already exists");
                }

                // Check if email exists
                if (await _userRepository.ExistsByEmailAsync(request.Email))
                {
                    return Result<UserDto>.Failure($"Email {request.Email} already exists");
                }

                // Create user
                var user = new User(
                    request.Username,
                    request.Email,
                    request.Password,
                    request.EmployeeId
                );

user.SetUpdatedBy(_currentUser.UserId?.ToString());
                // Add roles
                if (request.RoleIds?.Any() == true)
                {
                    foreach (var roleId in request.RoleIds)
                    {
                        var role = await _roleRepository.GetByIdAsync(roleId);
                        if (role != null)
                        {
                            user.AddRole(role, _currentUser.UserId.Value);
                        }
                    }
                }

                var createdUser = await _userRepository.AddAsync(user);
                
                _logger.LogInformation("User {Username} created by {CreatorId}", 
                    createdUser.Username, _currentUser.UserId);

                var userDto = _mapper.Map<UserDto>(createdUser);
                userDto.Roles = createdUser.UserRoles.Select(ur => ur.Role.RoleName).ToList();

                return Result<UserDto>.Success(userDto, "User created successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating user {Username}", request.Username);
                return Result<UserDto>.Failure("An error occurred while creating user");
            }
        }
    }
}