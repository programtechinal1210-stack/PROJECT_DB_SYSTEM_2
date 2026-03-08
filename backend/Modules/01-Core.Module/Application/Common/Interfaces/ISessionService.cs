namespace Core.Module.Application.Common.Interfaces
{
    public interface ISessionService
    {
        Task TerminateAllUserSessionsAsync(int userId);
        Task TerminateSessionAsync(string sessionId);
    }
}