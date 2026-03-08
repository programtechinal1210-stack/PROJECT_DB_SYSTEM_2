using Core.Module.Domain.Common;

namespace Core.Module.Domain.Events
{
    // أحداث الوحدات
    public class ModuleCreatedEvent : DomainEvent
    {
        public ModuleCreatedEvent(int moduleId, string moduleCode, string moduleName)
        {
            ModuleId = moduleId;
            ModuleCode = moduleCode;
            ModuleName = moduleName;
        }

        public int ModuleId { get; }
        public string ModuleCode { get; }
        public string ModuleName { get; }
    }

    public class ModuleUpdatedEvent : DomainEvent
    {
        public ModuleUpdatedEvent(int moduleId, string moduleCode, string moduleName)
        {
            ModuleId = moduleId;
            ModuleCode = moduleCode;
            ModuleName = moduleName;
        }

        public int ModuleId { get; }
        public string ModuleCode { get; }
        public string ModuleName { get; }
    }

    public class ModuleActivatedEvent : DomainEvent
    {
        public ModuleActivatedEvent(int moduleId)
        {
            ModuleId = moduleId;
        }

        public int ModuleId { get; }
    }

    public class ModuleDeactivatedEvent : DomainEvent
    {
        public ModuleDeactivatedEvent(int moduleId)
        {
            ModuleId = moduleId;
        }

        public int ModuleId { get; }
    }
}