using Core.Module.Application.Common.Mappings;
using CoreModuleEntity = Core.Module.Domain.Entities.Module;
using Core.Module.Application.DTOs.Roles;

namespace Core.Module.Application.DTOs.Modules
{
    public class ModuleDto : IMapFrom<CoreModuleEntity>
    {
        public int Id { get; set; }
        public string ModuleCode { get; set; }
        public string ModuleName { get; set; }
        public string ModuleDescription { get; set; }
        public int? ParentModuleId { get; set; }
        public string ParentModuleName { get; set; }
        public int DisplayOrder { get; set; }
        public bool IsActive { get; set; }
        public string Icon { get; set; }
        public string Route { get; set; }
        public DateTime CreatedAt { get; set; }
        public List<ModuleDto> SubModules { get; set; }
        public List<PermissionBasicDto> Permissions { get; set; }
    }

    public class ModuleTreeDto
    {
        public int Id { get; set; }
        public string ModuleCode { get; set; }
        public string ModuleName { get; set; }
        public string Icon { get; set; }
        public string Route { get; set; }
        public int DisplayOrder { get; set; }
        public List<ModuleTreeDto> Children { get; set; }
    }
}