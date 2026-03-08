using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Domain.Common;

namespace Core.Module.Infrastructure.EventBus
{
    public class InMemoryEventBus : IEventBus
    {
        private readonly IMediator _mediator;
        private readonly ILogger<InMemoryEventBus> _logger;

        public InMemoryEventBus(IMediator mediator, ILogger<InMemoryEventBus> logger)
        {
            _mediator = mediator;
            _logger = logger;
        }

        public async Task PublishAsync<TEvent>(TEvent @event, CancellationToken cancellationToken = default) 
            where TEvent : DomainEvent
        {
            try
            {
                _logger.LogDebug("Publishing event: {EventType} with ID: {EventId}", 
                    typeof(TEvent).Name, @event.EventId);
                
                await _mediator.Publish(@event, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error publishing event {EventType}", typeof(TEvent).Name);
                throw;
            }
        }

        public async Task PublishMultipleAsync<TEvent>(IEnumerable<TEvent> events, CancellationToken cancellationToken = default) 
            where TEvent : DomainEvent
        {
            foreach (var @event in events)
            {
                await PublishAsync(@event, cancellationToken);
            }
        }
    }
}