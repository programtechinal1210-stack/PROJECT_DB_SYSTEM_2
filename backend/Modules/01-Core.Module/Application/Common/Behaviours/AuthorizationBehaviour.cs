using System.Reflection;
using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Common.Exceptions;

namespace Core.Module.Application.Common.Behaviours
{
    public class AuthorizationBehaviour<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
        where TRequest : IRequest<TResponse>
    {
        private readonly ILogger<AuthorizationBehaviour<TRequest, TResponse>> _logger;
        private readonly ICurrentUserService _currentUserService;

        public AuthorizationBehaviour(
            ILogger<AuthorizationBehaviour<TRequest, TResponse>> logger,
            ICurrentUserService currentUserService)
        {
            _logger = logger;
            _currentUserService = currentUserService;
        }

        public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
        {
            var authorizeAttributes = request.GetType().GetCustomAttributes<AuthorizeAttribute>().ToList();

            if (authorizeAttributes.Any())
            {
                // Must be authenticated
                if (!_currentUserService.IsAuthenticated)
                {
                    throw new UnauthorizedException("User is not authenticated");
                }

                // Role-based authorization
                var authorizeAttributesWithRoles = authorizeAttributes
                    .Where(a => !string.IsNullOrWhiteSpace(a.Roles))
                    .ToList();

                if (authorizeAttributesWithRoles.Any())
                {
                    var requiredRoles = authorizeAttributesWithRoles
                        .SelectMany(a => a.Roles.Split(','))
                        .Select(r => r.Trim())
                        .Distinct();

                    var hasRequiredRole = requiredRoles.Any(role => _currentUserService.HasRole(role));
                    
                    if (!hasRequiredRole)
                    {
                        _logger.LogWarning($"User {_currentUserService.UserId} attempted to access {typeof(TRequest).Name} without required roles");
                        throw new ForbiddenAccessException("User does not have required role");
                    }
                }

                // Permission-based authorization
                var authorizeAttributesWithPermissions = authorizeAttributes
                    .Where(a => !string.IsNullOrWhiteSpace(a.Permissions))
                    .ToList();

                if (authorizeAttributesWithPermissions.Any())
                {
                    var requiredPermissions = authorizeAttributesWithPermissions
                        .SelectMany(a => a.Permissions.Split(','))
                        .Select(p => p.Trim())
                        .Distinct();

                    var hasRequiredPermission = requiredPermissions.Any(perm => _currentUserService.HasPermission(perm));
                    
                    if (!hasRequiredPermission)
                    {
                        _logger.LogWarning($"User {_currentUserService.UserId} attempted to access {typeof(TRequest).Name} without required permissions");
                        throw new ForbiddenAccessException("User does not have required permission");
                    }
                }
            }

            return await next();
        }
    }

    [AttributeUsage(AttributeTargets.Class, AllowMultiple = true)]
    public class AuthorizeAttribute : Attribute
    {
        public string Roles { get; set; }
        public string Permissions { get; set; }
        public string Policy { get; set; }
    }
}