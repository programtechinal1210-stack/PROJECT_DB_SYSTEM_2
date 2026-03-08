using MediatR;
using AutoMapper;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Common.Models;
using Core.Module.Application.Common.Exceptions;
using Core.Module.Domain.Interfaces;
using Core.Module.Application.DTOs.Roles;
namespace Core.Module.Application.Features.Roles.Commands.UpdateRole
{
    public class UpdateRoleCommandHandler : IRequestHandler<UpdateRoleCommand, Result<RoleDto>>
    {
        private readonly IRoleRepository _roleRepository;
        private readonly ICacheService _cacheService;
        private readonly ICurrentUserService _currentUser;
        private readonly IMapper _mapper;
        private readonly ILogger<UpdateRoleCommandHandler> _logger;
        
        public UpdateRoleCommandHandler(
            IRoleRepository roleRepository,
            ICacheService cacheService,
            ICurrentUserService currentUser,
            IMapper mapper,
            ILogger<UpdateRoleCommandHandler> logger)
        {
            _roleRepository = roleRepository;
            _cacheService = cacheService;
            _currentUser = currentUser;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task<Result<RoleDto>> Handle(UpdateRoleCommand request, CancellationToken cancellationToken)
        {
            try
            {
                var role = await _roleRepository.GetByIdAsync(request.Id);
                if (role == null)
                {
                    return Result<RoleDto>.Failure($"Role with ID {request.Id} not found");
                }

                // Update role name
                if (!string.IsNullOrWhiteSpace(request.RoleName) && request.RoleName != role.RoleName)
                {
                    if (await _roleRepository.ExistsByNameAsync(request.RoleName))
                    {
                        return Result<RoleDto>.Failure($"Role name {request.RoleName} already exists");
                    }
                    role.SetRoleName(request.RoleName);
                }

                // Update description
                if (request.Description != null)
                {
                    role.SetDescription(request.Description);
                }

role.SetUpdatedBy(_currentUser.UserId.ToString());
                await _roleRepository.UpdateAsync(role);

                // Clear caches
                await _cacheService.RemoveAsync($"role_detail_{role.Id}", cancellationToken);
                await _cacheService.RemoveAsync("roles_list", cancellationToken);

                // Clear user permissions cache for all users with this role
                foreach (var userRole in role.UserRoles)
                {
                    await _cacheService.RemoveAsync($"user_permissions_{userRole.UserId}", cancellationToken);
                    await _cacheService.RemoveAsync($"current_user_{userRole.UserId}", cancellationToken);
                }

                _logger.LogInformation("Role {RoleId} updated by {UpdaterId}", role.Id, _currentUser.UserId);

                var roleDto = _mapper.Map<RoleDto>(role);
                roleDto.UsersCount = role.UserRoles.Count;
                roleDto.PermissionsCount = role.Permissions.Count;

                return Result<RoleDto>.Success(roleDto, "Role updated successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating role {RoleId}", request.Id);
                return Result<RoleDto>.Failure("An error occurred while updating role");
            }
        }
    }
}