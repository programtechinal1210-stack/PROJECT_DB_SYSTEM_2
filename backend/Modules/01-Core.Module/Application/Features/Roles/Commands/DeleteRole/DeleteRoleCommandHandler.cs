using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Common.Models;
using Core.Module.Domain.Interfaces;

namespace Core.Module.Application.Features.Roles.Commands.DeleteRole
{
    public class DeleteRoleCommandHandler : IRequestHandler<DeleteRoleCommand, Result>
    {
        private readonly IRoleRepository _roleRepository;
        private readonly ICacheService _cacheService;
        private readonly ICurrentUserService _currentUser;
        private readonly ILogger<DeleteRoleCommandHandler> _logger;

        public DeleteRoleCommandHandler(
            IRoleRepository roleRepository,
            ICacheService cacheService,
            ICurrentUserService currentUser,
            ILogger<DeleteRoleCommandHandler> logger)
        {
            _roleRepository = roleRepository;
            _cacheService = cacheService;
            _currentUser = currentUser;
            _logger = logger;
        }

        public async Task<Result> Handle(DeleteRoleCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var role = await _roleRepository.GetByIdAsync(request.Id);
                if (role == null)
                {
                    return Result.Failure($"Role with ID {request.Id} not found");
                }

                // Prevent deleting system roles
                if (role.IsSystemRole)
                {
                    return Result.Failure("Cannot delete system role");
                }

                // Check if role has users
                if (role.UserRoles.Any())
                {
                    return Result.Failure("Cannot delete role that has assigned users");
                }

                // Clear user permissions cache for all users with this role
                foreach (var userRole in role.UserRoles)
                {
                    await _cacheService.RemoveAsync($"user_permissions_{userRole.UserId}", cancellationToken);
                    await _cacheService.RemoveAsync($"current_user_{userRole.UserId}", cancellationToken);
                }

                await _roleRepository.DeleteAsync(request.Id);

                // Clear role caches
                await _cacheService.RemoveAsync($"role_detail_{role.Id}", cancellationToken);
                await _cacheService.RemoveAsync("roles_list", cancellationToken);

                _logger.LogInformation("Role {RoleName} deleted by {DeleterId}", role.RoleName, _currentUser.UserId);

                return Result.Success("Role deleted successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting role {RoleId}", request.Id);
                return Result.Failure("An error occurred while deleting role");
            }
        }
    }
}