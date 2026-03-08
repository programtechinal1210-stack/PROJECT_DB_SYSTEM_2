using System.Diagnostics;
using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;

namespace Core.Module.Application.Common.Behaviours
{
    public class PerformanceBehaviour<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
        where TRequest : IRequest<TResponse>
    {
        private readonly Stopwatch _timer;
        private readonly ILogger<PerformanceBehaviour<TRequest, TResponse>> _logger;
        private readonly ICurrentUserService _currentUserService;
        private readonly int _threshold = 500; // milliseconds

        public PerformanceBehaviour(
            ILogger<PerformanceBehaviour<TRequest, TResponse>> logger,
            ICurrentUserService currentUserService)
        {
            _timer = new Stopwatch();
            _logger = logger;
            _currentUserService = currentUserService;
        }

        public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
        {
            _timer.Start();

            var response = await next();

            _timer.Stop();

            var elapsedMilliseconds = _timer.ElapsedMilliseconds;

            if (elapsedMilliseconds > _threshold)
            {
                var requestName = typeof(TRequest).Name;
                var userId = _currentUserService.UserId?.ToString() ?? "Anonymous";

                _logger.LogWarning("Long Running Request: {Name} ({ElapsedMilliseconds} milliseconds) for user {UserId}",
                    requestName, elapsedMilliseconds, userId);
            }

            return response;
        }
    }
}