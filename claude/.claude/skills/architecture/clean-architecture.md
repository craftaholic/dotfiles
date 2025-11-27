---
name: clean-architecture
description: Implement Clean Architecture principles to create maintainable, testable, and framework-independent software. Use when designing new applications, refactoring existing code, or implementing domain-centric architectures.
---

# Clean Architecture

Core principles and patterns for designing software systems following Clean Architecture principles.

## When to Use

- Designing new applications
- Refactoring legacy systems
- Building complex domain models
- Creating testable, maintainable code
- Framework-independent development

## Core Principles

1. **Independence from Frameworks**: The architecture doesn't depend on frameworks
2. **Testability**: Business rules can be tested without UI, database, server, or frameworks
3. **Independence from UI**: The UI can change without changing the system
4. **Independence from Database**: The database can be changed without affecting the business rules
5. **Independence from External Agencies**: Business rules don't know about external interfaces

## Layer Structure

### Core Concentric Layers

```
┌────────────────────────────────────────────────────┐
│ FRAMEWORKS & DRIVERS (Web, UI, DB, Devices, etc.)  │
│ ┌────────────────────────────────────────────────┐ │
│ │ INTERFACE ADAPTERS (Controllers, Presenters)    │ │
│ │ ┌────────────────────────────────────────────┐ │ │
│ │ │ APPLICATION BUSINESS RULES (Use Cases)     │ │ │
│ │ │ ┌────────────────────────────────────────┐ │ │ │
│ │ │ │ ENTERPRISE BUSINESS RULES (Entities)   │ │ │ │
│ │ │ └────────────────────────────────────────┘ │ │ │
│ │ └────────────────────────────────────────────┘ │ │
│ └────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────┘
```

### Implementation by Layer

1. **Enterprise Business Rules (Entities)**
   - Domain objects
   - Business rules that apply to the entire organization
   - Have no dependencies on outer layers
   - Examples: User, Product, Order

2. **Application Business Rules (Use Cases)**
   - Application-specific business rules
   - Orchestrate the flow of data to/from entities
   - Implement use cases that represent system behavior
   - Examples: CreateOrder, ProcessPayment, RegisterUser

3. **Interface Adapters**
   - Convert data between use cases/entities and external layers
   - Controllers, presenters, and gateways
   - Framework-specific adapters
   - Examples: REST controllers, database repositories, view models

4. **Frameworks & Drivers**
   - Frameworks, tools, and delivery mechanisms
   - Database, web frameworks, devices
   - Most volatile layer, can be replaced
   - Examples: Express/Flask/Rails, React/Vue, PostgreSQL/MongoDB

## Dependency Rule

The fundamental rule of Clean Architecture:

> Source code dependencies must point only inward, toward higher-level policies

```
External World  →  Adapters  →  Use Cases  →  Entities
   (low level)                                (high level)
```

## Dependency Inversion

The key mechanism for maintaining the dependency rule is the use of interfaces:

```
┌─────────────────────┐     ┌───────────────────────────┐
│ Application Layer   │     │ Infrastructure Layer      │
│                     │     │                           │
│  ┌───────────────┐  │     │   ┌───────────────────┐   │
│  │  UseCase      │  │     │   │ DatabaseAdapter   │   │
│  │               │  │     │   │                   │   │
│  └───────┬───────┘  │     │   └─────────┬─────────┘   │
│          │          │     │             │             │
│          │ uses     │     │             │ implements  │
│          ▼          │     │             │             │
│  ┌───────────────┐  │     │             │             │
│  │ Repository    │◄─┼─────┼─────────────┘             │
│  │ Interface     │  │     │                           │
│  └───────────────┘  │     │                           │
└─────────────────────┘     └───────────────────────────┘
```

### Implementation Rules:
1. High-level modules define interfaces
2. Low-level modules implement interfaces
3. Interfaces belong to the module that uses them
4. Implementation details point inward toward interfaces

## Common Implementation Challenges

### Handling Cross-Cutting Concerns

```
┌───────────────────────────────────────────────┐
│               Cross-Cutting Concerns          │
│  ┌─────────┐  ┌─────────┐  ┌───────────────┐  │
│  │ Logging │  │ Security│  │ Transactions  │  │
│  └─────────┘  └─────────┘  └───────────────┘  │
└───────┬───────────┬───────────────┬───────────┘
        │           │               │
        ▼           ▼               ▼
┌───────────┐ ┌─────────────┐ ┌────────────────┐
│ Entities  │ │ Use Cases   │ │ Adapters       │
└───────────┘ └─────────────┘ └────────────────┘
```

**Solutions:**
- Use aspect-oriented programming techniques
- Apply decorators/middleware
- Implement cross-cutting concerns in adapters
- Use dependency injection to add behavior

### Data Transfer Between Layers

```
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│ Controller    │    │ Use Case      │    │ Entity        │
│               │    │               │    │               │
│ UserDTO       │--->│ UserRequest   │--->│ User          │
│               │    │               │    │               │
│ UserResponse  │<---│ UserResponse  │<---│               │
└───────────────┘    └───────────────┘    └───────────────┘
```

**Patterns:**
- Use request/response models for use cases
- Use mappers between layers
- Define layer-specific DTOs
- Avoid leaking domain objects to external layers

## Testing Strategy

```
┌────────────────────────────────────────────────────────┐
│ End-to-End Tests (few)                                 │
│ ┌────────────────────────────────────────────────────┐ │
│ │ Integration Tests                                  │ │
│ │ ┌────────────────────────────────────────────────┐ │ │
│ │ │ Component Tests                                │ │ │
│ │ │ ┌────────────────────────────────────────────┐ │ │ │
│ │ │ │ Unit Tests (many)                          │ │ │ │
│ │ │ └────────────────────────────────────────────┘ │ │ │
│ │ └────────────────────────────────────────────────┘ │ │
│ └────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────┘
```

**Focus Areas:**
- **Unit Tests**: Domain entities and use cases in isolation
- **Component Tests**: Use cases with mocked repositories
- **Integration Tests**: Interface adapters with real repositories
- **E2E Tests**: Complete flows through the entire system

## Folder Structure Patterns

### By Layer (Traditional)

```
src/
├── entities/
├── usecases/
├── interfaces/
│   ├── controllers/
│   ├── presenters/
│   └── repositories/
└── frameworks/
    ├── web/
    ├── persistence/
    └── external/
```

### By Feature (Modern)

```
src/
├── users/
│   ├── domain/
│   │   └── user.ts
│   ├── application/
│   │   └── user-use-cases.ts
│   ├── interfaces/
│   │   └── user-controller.ts
│   └── infrastructure/
│       └── user-repository.ts
├── products/
│   ├── domain/
│   ├── application/
│   ├── interfaces/
│   └── infrastructure/
└── shared/
    ├── domain/
    ├── application/
    ├── interfaces/
    └── infrastructure/
```

## Language-Specific Implementations

For language-specific implementations and examples, please refer to:

- [Clean Architecture in Golang](clean-architecture/golang.md)
- [Clean Architecture in TypeScript](clean-architecture/typescript.md)
- [Clean Architecture in Python](clean-architecture/python.md)

## Related Concepts

- **Hexagonal Architecture** (Ports & Adapters)
- **Onion Architecture**
- **Domain-Driven Design**
- **CQRS Pattern**
- **Event Sourcing**