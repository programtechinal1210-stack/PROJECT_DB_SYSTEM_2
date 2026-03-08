using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Common.Models;
using Core.Module.Application.Common.Exceptions;
using Core.Module.Domain.Interfaces;

namespace Core.Module.Application.Features.Roles.Commands.AssignPermission
{
    public class AssignPermissionCommandHandler : IRequestHandler<AssignPermissionCommand, Result>
    {
        private readonly IRoleRepository _roleRepository;
        private readonly IPermissionRepository _permissionRepository;
        private readonly ICacheService _cacheService;
        private readonly ICurrentUserService _currentUser;
        private readonly ILogger<AssignPermissionCommandHandler> _logger;

        public AssignPermissionCommandHandler(
            IRoleRepository roleRepository,
            IPermissionRepository permissionRepository,
            ICacheService cacheService,
            ICurrentUserService currentUser,
            ILogger<AssignPermissionCommandHandler> logger)
        {
            _roleRepository = roleRepository;
            _permissionRepository = permissionRepository;
            _cacheService = cacheService;
            _currentUser = currentUser;
            _logger = logger;
        }

        public async Task<Result> Handle(AssignPermissionCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var role = await _roleRepository.GetByIdAsync(request.RoleId);
                if (role == null)
                {
                    return Result.Failure($"Role with ID {request.RoleId} not found");
                }

                var permission = await _permissionRepository.GetByIdAsync(request.PermissionId);
                if (permission == null)
                {
                    return Result.Failure($"Permission with ID {request.PermissionId} not found");
                }

                role.AddPermission(permission, _currentUser.UserId);
                await _roleRepository.UpdateAsync(role);

                // Clear user permissions cache for all users with this role
                foreach (var userRole in role.UserRoles)
                {
                    await _cacheService.RemoveAsync($"user_permissions_{userRole.UserId}", cancellationToken);
                    await _cacheService.RemoveAsync($"current_user_{userRole.UserId}", cancellationToken);
                }

                // Clear role cache
                await _cacheService.RemoveAsync($"role_detail_{role.Id}", cancellationToken);

                _logger.LogInformation("Permission {PermissionCode} assigned to role {RoleName} by {AssignerId}",
                    permission.PermissionCode, role.RoleName, _currentUser.UserId);

                return Result.Success("Permission assigned successfully");
            }
            catch (InvalidOperationException ex)
            {
                return Result.Failure(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error assigning permission to role {RoleId}", request.RoleId);
                return Result.Failure("An error occurred while assigning permission");
            }
        }
    }
}