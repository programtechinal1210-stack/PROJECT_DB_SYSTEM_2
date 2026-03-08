using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Common.Models;
using Core.Module.Domain.Interfaces;
using Core.Module.Domain.Events;
namespace Core.Module.Application.Features.Auth.Commands.Logout
{
    public class LogoutCommandHandler : IRequestHandler<LogoutCommand, Result>
    {
        private readonly IUserRepository _userRepository;
        private readonly ICacheService _cacheService;
        private readonly ILogger<LogoutCommandHandler> _logger;

        public LogoutCommandHandler(
            IUserRepository userRepository,
            ICacheService cacheService,
            ILogger<LogoutCommandHandler> logger)
        {
            _userRepository = userRepository;
            _cacheService = cacheService;
            _logger = logger;
        }

        public async Task<Result> Handle(LogoutCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var session = await _userRepository.GetSessionAsync(request.SessionToken);
                if (session != null)
                {
                    session.Terminate();
                    await _userRepository.UpdateSessionAsync(session);

                    var user = await _userRepository.GetByIdAsync(request.UserId);
                    if (user != null)
                    {
                        user.ClearRefreshToken();
                        await _userRepository.UpdateAsync(user);
                        await _cacheService.RemoveAsync($"user_permissions_{user.Id}", cancellationToken);
                        
                        user.AddDomainEvent(new UserLoggedOutEvent(user.Id, request.SessionToken));
                    }
                }

                return Result.Success("Logged out successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during logout for user {UserId}", request.UserId);
                return Result.Failure("An error occurred during logout");
            }
        }
    }
}