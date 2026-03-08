using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Common.Models;
using Core.Module.Application.Common.Exceptions;
using Core.Module.Domain.Interfaces;
using Core.Module.Application.DTOs.Auth;
using Core.Module.Infrastructure.Security; // لـ ITokenService
namespace Core.Module.Application.Features.Auth.Commands.RefreshToken
{
    public class RefreshTokenCommandHandler : IRequestHandler<RefreshTokenCommand, Result<LoginResponse>>
    {
        private readonly IUserRepository _userRepository;
        private readonly ITokenService _tokenService;
        private readonly ICacheService _cacheService;
        private readonly ILogger<RefreshTokenCommandHandler> _logger;

        public RefreshTokenCommandHandler(
            IUserRepository userRepository,
            ITokenService tokenService,
            ICacheService cacheService,
            ILogger<RefreshTokenCommandHandler> logger)
        {
            _userRepository = userRepository;
            _tokenService = tokenService;
            _cacheService = cacheService;
            _logger = logger;
        }

        public async Task<Result<LoginResponse>> Handle(RefreshTokenCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var user = await _userRepository.GetByRefreshTokenAsync(request.RefreshToken);
                if (user == null)
                {
                    return Result<LoginResponse>.Failure("Invalid refresh token");
                }

                // Verify refresh token is valid
                if (user.RefreshToken?.IsValid() != true)
                {
                    return Result<LoginResponse>.Failure("Refresh token expired");
                }

                // Generate new tokens
                var newAccessToken = _tokenService.GenerateAccessToken(user);
                var newRefreshToken = _tokenService.GenerateRefreshToken();
                var newRefreshTokenExpiry = DateTime.UtcNow.AddDays(7);

                // Update refresh token
                user.SetRefreshToken(newRefreshToken, newRefreshTokenExpiry);
                await _userRepository.UpdateAsync(user);

                // Update session
                var session = await _userRepository.GetSessionAsync(request.RefreshToken);
                if (session != null)
                {
                    session.SetSessionToken(newAccessToken);
                    session.UpdateActivity();
                    session.ExtendExpiry(DateTime.UtcNow.AddHours(1));
                    await _userRepository.UpdateSessionAsync(session);
                }

                // Get cached permissions or load from user
                var permissions = await _cacheService.GetAsync<List<string>>($"user_permissions_{user.Id}", cancellationToken)
                    ?? user.GetAllPermissions().ToList();

                var response = new LoginResponse
                {
                    AccessToken = newAccessToken,
                    RefreshToken = newRefreshToken,
ExpiresAt = DateTime.UtcNow.AddHours(1),
                    User = new UserInfo
                    {
                        Id = user.Id,
                        Username = user.Username,
                        Email = user.Email,
                        Roles = user.UserRoles.Select(ur => ur.Role.RoleName).ToList(),
                        Permissions = permissions
                    }
                };

                return Result<LoginResponse>.Success(response, "Token refreshed successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error refreshing token");
                return Result<LoginResponse>.Failure("An error occurred while refreshing token");
            }
        }
    }
}