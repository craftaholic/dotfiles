---
name: clean-architecture
description: Implement Clean Architecture principles to create maintainable, testable, and framework-independent software. Use when designing new applications, refactoring existing code, or implementing domain-centric architectures.
---

# Clean Architecture

Implementation patterns for designing software systems following Clean Architecture principles.

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

2. **Application Business Rules (Use Cases)**
   - Application-specific business rules
   - Orchestrate the flow of data to/from entities
   - Implement use cases that represent system behavior

3. **Interface Adapters**
   - Convert data between use cases/entities and external layers
   - Controllers, presenters, and gateways
   - Framework-specific adapters

4. **Frameworks & Drivers**
   - Frameworks, tools, and delivery mechanisms
   - Database, web frameworks, devices
   - Most volatile layer, can be replaced

## Dependency Rule

The fundamental rule of Clean Architecture:

> Source code dependencies must point only inward, toward higher-level policies

```
External World  →  Adapters  →  Use Cases  →  Entities
   (low level)                                (high level)
```

## Implementation Patterns

### Golang Implementation

```go
// entities/user.go
package entities

type User struct {
    ID    string
    Name  string
    Email string
}

func (u *User) ValidateEmail() bool {
    // Domain validation logic
    return true
}

// usecases/user.go
package usecases

import "app/entities"

type UserRepository interface {
    FindByID(id string) (*entities.User, error)
    Save(user *entities.User) error
}

type UserUseCase struct {
    repo UserRepository
}

func NewUserUseCase(repo UserRepository) *UserUseCase {
    return &UserUseCase{repo: repo}
}

func (uc *UserUseCase) GetUser(id string) (*entities.User, error) {
    return uc.repo.FindByID(id)
}

// adapters/repository.go
package adapters

import (
    "app/entities"
    "database/sql"
)

type SQLUserRepository struct {
    db *sql.DB
}

func (r *SQLUserRepository) FindByID(id string) (*entities.User, error) {
    // SQL implementation
    return &entities.User{}, nil
}

// frameworks/http/handler.go
package http

import (
    "app/usecases"
    "net/http"
)

type UserHandler struct {
    userUseCase *usecases.UserUseCase
}

func (h *UserHandler) GetUser(w http.ResponseWriter, r *http.Request) {
    // HTTP handling
}
```

### TypeScript Implementation

```typescript
// entities/user.ts
export class User {
  constructor(
    private readonly id: string,
    private name: string,
    private email: string,
  ) {}

  validateEmail(): boolean {
    // Domain validation logic
    return true;
  }
}

// use-cases/get-user.ts
import { User } from '../entities/user';

export interface UserRepository {
  findById(id: string): Promise<User>;
  save(user: User): Promise<void>;
}

export class GetUserUseCase {
  constructor(private readonly userRepository: UserRepository) {}

  async execute(id: string): Promise<User> {
    return this.userRepository.findById(id);
  }
}

// adapters/user-repository.ts
import { User } from '../entities/user';
import { UserRepository } from '../use-cases/get-user';
import { Database } from '../frameworks/database';

export class SqlUserRepository implements UserRepository {
  constructor(private readonly db: Database) {}

  async findById(id: string): Promise<User> {
    // Database implementation
    return new User('1', 'John', 'john@example.com');
  }
}

// frameworks/express/user-controller.ts
import { Request, Response } from 'express';
import { GetUserUseCase } from '../../use-cases/get-user';

export class UserController {
  constructor(private readonly getUserUseCase: GetUserUseCase) {}

  async getUser(req: Request, res: Response): Promise<void> {
    const user = await this.getUserUseCase.execute(req.params.id);
    res.json({
      id: user.id,
      name: user.name,
      email: user.email,
    });
  }
}
```

### Python Implementation

```python
# entities/user.py
class User:
    def __init__(self, user_id, name, email):
        self.id = user_id
        self.name = name
        self.email = email

    def validate_email(self):
        # Domain validation logic
        return True

# use_cases/user_use_case.py
from abc import ABC, abstractmethod
from entities.user import User

class UserRepository(ABC):
    @abstractmethod
    def find_by_id(self, user_id):
        pass

    @abstractmethod
    def save(self, user):
        pass

class GetUserUseCase:
    def __init__(self, user_repository):
        self.user_repository = user_repository

    def execute(self, user_id):
        return self.user_repository.find_by_id(user_id)

# adapters/repositories.py
from use_cases.user_use_case import UserRepository
from entities.user import User

class SqlUserRepository(UserRepository):
    def __init__(self, db_connection):
        self.db = db_connection

    def find_by_id(self, user_id):
        # SQL implementation
        return User(user_id, "John", "john@example.com")

    def save(self, user):
        # SQL implementation
        pass

# frameworks/flask_app.py
from flask import Flask, jsonify
from adapters.repositories import SqlUserRepository
from use_cases.user_use_case import GetUserUseCase
import sqlite3

app = Flask(__name__)
db = sqlite3.connect("database.db")
user_repository = SqlUserRepository(db)
get_user_use_case = GetUserUseCase(user_repository)

@app.route("/users/<user_id>")
def get_user(user_id):
    user = get_user_use_case.execute(user_id)
    return jsonify({
        "id": user.id,
        "name": user.name,
        "email": user.email
    })
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

## Related Concepts

- **Hexagonal Architecture** (Ports & Adapters)
- **Onion Architecture**
- **Domain-Driven Design**
- **CQRS Pattern**
- **Event Sourcing**