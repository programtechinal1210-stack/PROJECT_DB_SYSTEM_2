using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using System.Text.Json;

namespace Core.Module.Application.Common.Behaviours
{
    public class LoggingBehaviour<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
        where TRequest : IRequest<TResponse>
    {
        private readonly ILogger<LoggingBehaviour<TRequest, TResponse>> _logger;
        private readonly ICurrentUserService _currentUserService;

        public LoggingBehaviour(
            ILogger<LoggingBehaviour<TRequest, TResponse>> logger,
            ICurrentUserService currentUserService)
        {
            _logger = logger;
            _currentUserService = currentUserService;
        }

        public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
        {
            var requestName = typeof(TRequest).Name;
            var userId = _currentUserService.UserId?.ToString() ?? "Anonymous";

            _logger.LogInformation("Processing request: {Name} for user {UserId}", requestName, userId);

            try
            {
                var response = await next();
                
                _logger.LogInformation("Request completed: {Name} for user {UserId}", requestName, userId);
                
                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Request failed: {Name} for user {UserId}", requestName, userId);
                throw;
            }
        }
    }
}