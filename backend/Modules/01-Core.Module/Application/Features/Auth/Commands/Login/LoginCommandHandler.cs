using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Common.Models;
using Core.Module.Application.Common.Exceptions;
using Core.Module.Domain.Interfaces;
using Core.Module.Domain.Entities;

namespace Core.Module.Application.Features.Auth.Commands.Login
{
    public class LoginCommandHandler : IRequestHandler<LoginCommand, Result<LoginResponse>>
    {
        private readonly IUserRepository _userRepository;
        private readonly ITokenService _tokenService;
        private readonly ICacheService _cacheService;
        private readonly ILogger<LoginCommandHandler> _logger;

        public LoginCommandHandler(
            IUserRepository userRepository,
            ITokenService tokenService,
            ICacheService cacheService,
            ILogger<LoginCommandHandler> logger)
        {
            _userRepository = userRepository;
            _tokenService = tokenService;
            _cacheService = cacheService;
            _logger = logger;
        }

        public async Task<Result<LoginResponse>> Handle(LoginCommand request, CancellationToken cancellationToken)
        {
            try
            {
                // Check for too many failed attempts
                var failedAttempts = await _userRepository.GetFailedLoginAttemptsAsync(
                    request.Username, TimeSpan.FromMinutes(15));
                
                if (failedAttempts >= 5)
                {
                    _logger.LogWarning($"Too many failed login attempts for {request.Username}");
                    return Result<LoginResponse>.Failure(
                        "Account locked due to too many failed attempts. Try again later.");
                }

                // Get user
                var user = await _userRepository.GetByUsernameAsync(request.Username);
                if (user == null)
                {
                    user = await _userRepository.GetByEmailAsync(request.Username);
                }

                if (user == null)
                {
                    await _userRepository.AddLoginAttemptAsync(request.Username, request.IpAddress, false);
                    return Result<LoginResponse>.Failure("Invalid username or password");
                }

                // Verify password
                if (!user.Password.Verify(request.Password))
                {
                    await _userRepository.AddLoginAttemptAsync(request.Username, request.IpAddress, false);
                    return Result<LoginResponse>.Failure("Invalid username or password");
                }

                // Check if user is active
                if (!user.IsActive)
                {
                    _logger.LogWarning($"Inactive user attempted login: {user.Username}");
                    return Result<LoginResponse>.Failure("Account is deactivated");
                }

                // Generate tokens
                var accessToken = _tokenService.GenerateAccessToken(user);
                var refreshToken = _tokenService.GenerateRefreshToken();
                var refreshTokenExpiry = request.RememberMe 
                    ? DateTime.UtcNow.AddDays(30) 
                    : DateTime.UtcNow.AddDays(7);

                // Save refresh token
                user.SetRefreshToken(refreshToken, refreshTokenExpiry);
                await _userRepository.UpdateAsync(user);

                // Create session
                var session = new UserSession(
                    user.Id,
                    accessToken,
                    DateTime.UtcNow.AddHours(1),
                    request.IpAddress,
                    request.UserAgent
                );
                await _userRepository.AddSessionAsync(session);

                // Record successful login
                user.RecordLogin(request.IpAddress, request.UserAgent);
                await _userRepository.UpdateAsync(user);
                await _userRepository.AddLoginAttemptAsync(request.Username, request.IpAddress, true);

                _logger.LogInformation($"Successful login for user: {user.Username}");

                // Get user permissions
                var permissions = user.GetAllPermissions();

                // Cache permissions
                await _cacheService.SetAsync(
                    $"user_permissions_{user.Id}", 
                    permissions, 
                    TimeSpan.FromMinutes(30),
                    cancellationToken);

                var response = new LoginResponse
                {
                    AccessToken = accessToken,
                    RefreshToken = refreshToken,
                    ExpiresIn = 3600,
                    User = new UserInfo
                    {
                        Id = user.Id,
                        Username = user.Username,
                        Email = user.Email,
                        Roles = user.UserRoles.Select(ur => ur.Role.RoleName).ToList(),
                        Permissions = permissions.ToList()
                    }
                };

                return Result<LoginResponse>.Success(response, "Login successful");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error during login for {request.Username}");
                return Result<LoginResponse>.Failure("An error occurred during login");
            }
        }
    }
}