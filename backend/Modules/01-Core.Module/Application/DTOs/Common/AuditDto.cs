namespace Core.Module.Application.DTOs.Common
{
    public class AuditDto
    {
        public DateTime CreatedAt { get; set; }
        public string CreatedBy { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public string UpdatedBy { get; set; }
    }

    public class AuditLogDto
    {
        public int Id { get; set; }
        public string EntityName { get; set; }
        public int EntityId { get; set; }
        public string Action { get; set; }
        public string Changes { get; set; }
        public string PerformedBy { get; set; }
        public DateTime PerformedAt { get; set; }
        public string IpAddress { get; set; }
    }
}