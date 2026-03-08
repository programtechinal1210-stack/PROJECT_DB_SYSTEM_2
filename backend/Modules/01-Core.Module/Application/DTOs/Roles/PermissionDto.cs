using Core.Module.Application.Common.Mappings;
using Core.Module.Domain.Entities;
using Core.Module.Domain.Enums;
using System.ComponentModel.DataAnnotations;
namespace Core.Module.Application.DTOs.Roles
{
    public class PermissionDto : IMapFrom<Permission>
    {
        public int Id { get; set; }
        public string PermissionCode { get; set; }
        public string PermissionName { get; set; }
        public string PermissionDescription { get; set; }
        public int ModuleId { get; set; }
        public string ModuleName { get; set; }
        public string ModuleCode { get; set; }
        public PermissionAction ActionType { get; set; }
        public string ActionName => ActionType.ToString();
        public DateTime CreatedAt { get; set; }
    }

    public class PermissionGroupDto
    {
        public int ModuleId { get; set; }
        public string ModuleName { get; set; }
        public string ModuleCode { get; set; }
        public string ModuleIcon { get; set; }
        public List<PermissionDto> Permissions { get; set; }
    }

    public class PermissionBasicDto
    {
        public int Id { get; set; }
        public string PermissionCode { get; set; }
        public string PermissionName { get; set; }
    }

    public class CheckPermissionDto
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public string PermissionCode { get; set; }
    }

    public class PermissionCheckResultDto
    {
        public int UserId { get; set; }
        public string PermissionCode { get; set; }
        public bool HasPermission { get; set; }
    }
}