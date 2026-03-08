namespace Core.Module.Application.Common.Interfaces
{
    public interface INotificationService
    {
        Task SendSecurityAlertAsync(int userId, string message, CancellationToken cancellationToken = default);
    
    Task SendPasswordChangedAlertAsync(int userId, DateTime changedAt);}
}