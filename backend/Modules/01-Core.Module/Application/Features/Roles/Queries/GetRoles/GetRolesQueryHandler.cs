using MediatR;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Application.Common.Models;
using Core.Module.Domain.Interfaces;
using Core.Module.Domain.Specifications;

namespace Core.Module.Application.Features.Roles.Queries.GetRoles
{
    public class GetRolesQueryHandler : IRequestHandler<GetRolesQuery, Result<List<RoleDto>>>
    {
        private readonly IRoleRepository _roleRepository;
        private readonly ICacheService _cacheService;
        private readonly IMapper _mapper;
        private readonly ILogger<GetRolesQueryHandler> _logger;

        public GetRolesQueryHandler(
            IRoleRepository roleRepository,
            ICacheService cacheService,
            IMapper mapper,
            ILogger<GetRolesQueryHandler> logger)
        {
            _roleRepository = roleRepository;
            _cacheService = cacheService;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task<Result<List<RoleDto>>> Handle(GetRolesQuery request, CancellationToken cancellationToken)
        {
            try
            {
                // Try cache first
                var cacheKey = $"roles_list_{request.IncludeSystemRoles}_{request.SearchTerm}";
                var cachedRoles = await _cacheService.GetAsync<List<RoleDto>>(cacheKey, cancellationToken);

                if (cachedRoles != null)
                {
                    return Result<List<RoleDto>>.Success(cachedRoles);
                }

                // Get from repository
                var roles = await _roleRepository.GetAllAsync();

                if (!request.IncludeSystemRoles)
                {
                    roles = roles.Where(r => !r.IsSystemRole);
                }

                if (!string.IsNullOrWhiteSpace(request.SearchTerm))
                {
                    var searchTerm = request.SearchTerm.ToLower();
                    roles = roles.Where(r => 
                        r.RoleName.ToLower().Contains(searchTerm) ||
                        (r.RoleDescription?.ToLower().Contains(searchTerm) ?? false));
                }

                var roleDtos = roles.Select(r => 
                {
                    var dto = _mapper.Map<RoleDto>(r);
                    dto.UsersCount = r.UserRoles.Count;
                    dto.PermissionsCount = r.Permissions.Count;
                    return dto;
                }).ToList();

                // Cache for 10 minutes
                await _cacheService.SetAsync(cacheKey, roleDtos, TimeSpan.FromMinutes(10), cancellationToken);

                return Result<List<RoleDto>>.Success(roleDtos);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting roles list");
                return Result<List<RoleDto>>.Failure("An error occurred while retrieving roles");
            }
        }
    }
}