using Core.Module.Domain.Common;

namespace Core.Module.Application.Common.Interfaces
{
    public interface IEventBus
    {
        Task PublishAsync<TEvent>(TEvent @event, CancellationToken cancellationToken = default) 
            where TEvent : DomainEvent;
        
        Task PublishMultipleAsync<TEvent>(IEnumerable<TEvent> events, CancellationToken cancellationToken = default) 
            where TEvent : DomainEvent;
    }
}