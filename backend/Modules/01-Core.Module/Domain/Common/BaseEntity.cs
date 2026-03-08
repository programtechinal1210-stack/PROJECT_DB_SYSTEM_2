using System.ComponentModel.DataAnnotations.Schema;
using Core.Module.Domain.Common;

namespace Core.Module.Domain.Common
{
    public abstract class BaseEntity
    {
        public int Id { get; protected set; }
        
        private readonly List<DomainEvent> _domainEvents = new();
        
        [NotMapped]
        public IReadOnlyCollection<DomainEvent> DomainEvents => _domainEvents.AsReadOnly();

        public void AddDomainEvent(DomainEvent domainEvent)
        {
            _domainEvents.Add(domainEvent);
        }

        public void RemoveDomainEvent(DomainEvent domainEvent)
        {
            _domainEvents.Remove(domainEvent);
        }

        public void ClearDomainEvents()
        {
            _domainEvents.Clear();
        }
    }
}