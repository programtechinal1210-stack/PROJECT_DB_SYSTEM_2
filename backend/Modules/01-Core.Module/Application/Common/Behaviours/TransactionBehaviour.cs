using MediatR;
using Microsoft.Extensions.Logging;
using Core.Module.Application.Common.Interfaces;
using Core.Module.Domain.Common;

namespace Core.Module.Application.Common.Behaviours
{
    public class TransactionBehaviour<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
        where TRequest : IRequest<TResponse>
        where TResponse : class
    {
        private readonly ILogger<TransactionBehaviour<TRequest, TResponse>> _logger;
        private readonly IApplicationDbContext _context;
        private readonly IEventBus _eventBus;

        public TransactionBehaviour(
            ILogger<TransactionBehaviour<TRequest, TResponse>> logger,
            IApplicationDbContext context,
            IEventBus eventBus)
        {
            _logger = logger;
            _context = context;
            _eventBus = eventBus;
        }

        public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken cancellationToken)
        {
            var requestName = typeof(TRequest).Name;

            try
            {
                await _context.BeginTransactionAsync();

                var response = await next();

                // Save changes and commit transaction
                await _context.SaveChangesAsync(cancellationToken);
                await _context.CommitTransactionAsync();

                // Publish domain events after successful commit
                if (response is IAggregateRoot aggregate)
                {
                    await PublishDomainEvents(aggregate, cancellationToken);
                }

                _logger.LogInformation("Transaction completed successfully for {RequestName}", requestName);

                return response;
            }
            catch (Exception ex)
            {
                await _context.RollbackTransactionAsync();
                _logger.LogError(ex, "Transaction failed for {RequestName}", requestName);
                throw;
            }
        }

        private async Task PublishDomainEvents(IAggregateRoot aggregate, CancellationToken cancellationToken)
        {
            var events = aggregate.DomainEvents.ToList();
            aggregate.ClearDomainEvents();

            foreach (var domainEvent in events)
            {
                await _eventBus.PublishAsync(domainEvent, cancellationToken);
            }
        }
    }
}