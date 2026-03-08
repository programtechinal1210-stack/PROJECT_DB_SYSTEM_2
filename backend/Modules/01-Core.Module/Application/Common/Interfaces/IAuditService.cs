namespace Core.Module.Application.Common.Interfaces
{
    public interface IAuditService
    {
        Task LogAsync(string entityType, object entityId, string action, string? details = null, CancellationToken cancellationToken = default);
    }
}