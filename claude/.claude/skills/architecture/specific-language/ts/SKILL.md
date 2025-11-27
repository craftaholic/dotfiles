---
name: clean-architecture-typescript
description: Implement Clean Architecture principles in TypeScript for maintainable, testable, and framework-independent applications. Use when designing new TypeScript applications, refactoring existing code, or implementing domain-centric Node.js applications.
---

# Clean Architecture in TypeScript

Implementation patterns for designing TypeScript applications following Clean Architecture principles.

## When to Use

- Designing new TypeScript/Node.js applications
- Refactoring legacy JavaScript/TypeScript codebases
- Building complex domain models
- Creating testable, maintainable TypeScript code
- Framework-independent backend or frontend development

## Core Principles

1. **Independence from Frameworks**: The architecture doesn't depend on frameworks
2. **Testability**: Business rules can be tested without UI, database, server, or frameworks
3. **Independence from UI**: The UI can change without changing the system
4. **Independence from Database**: The database can be changed without affecting the business rules
5. **Independence from External Agencies**: Business rules don't know about external interfaces

## Layer Structure in TypeScript Applications

### Core Concentric Layers

```
┌────────────────────────────────────────────────────┐
│ FRAMEWORKS & DRIVERS (Express, React, DB, etc.)    │
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

## Implementation in TypeScript

### 1. Enterprise Business Rules (Entities)

Domain entities in TypeScript are typically defined as classes with business logic:

```typescript
// src/domain/entities/user.ts
export class User {
  private readonly _id: string | null;
  private _name: string;
  private _email: string;
  private readonly _createdAt: Date;

  constructor(
    params: {
      id?: string;
      name: string;
      email: string;
      createdAt?: Date;
    }
  ) {
    this._id = params.id || null;
    this._name = params.name;
    this._email = params.email;
    this._createdAt = params.createdAt || new Date();
  }

  // Getters
  get id(): string | null { return this._id; }
  get name(): string { return this._name; }
  get email(): string { return this._email; }
  get createdAt(): Date { return this._createdAt; }

  // Business logic methods
  validateEmail(): boolean {
    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return emailRegex.test(this._email);
  }

  isNew(): boolean {
    return this._id === null;
  }

  changeName(newName: string): void {
    if (!newName || newName.trim().length === 0) {
      throw new Error('Name cannot be empty');
    }
    this._name = newName;
  }
}
```

### 2. Application Business Rules (Use Cases)

In TypeScript, use cases are typically implemented as classes with interfaces:

```typescript
// src/domain/repositories/user-repository.interface.ts
import { User } from '../entities/user';

export interface UserRepository {
  findById(id: string): Promise<User | null>;
  save(user: User): Promise<User>;
  update(user: User): Promise<User>;
  delete(id: string): Promise<void>;
}

// src/application/use-cases/user/get-user.use-case.ts
import { User } from '../../../domain/entities/user';
import { UserRepository } from '../../../domain/repositories/user-repository.interface';

// Input data for the use case
export interface GetUserUseCaseInput {
  id: string;
}

// Output data from the use case
export interface GetUserUseCaseOutput {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
}

export class GetUserUseCase {
  constructor(private readonly userRepository: UserRepository) {}

  async execute(input: GetUserUseCaseInput): Promise<GetUserUseCaseOutput> {
    if (!input.id) {
      throw new Error('User ID is required');
    }

    const user = await this.userRepository.findById(input.id);

    if (!user) {
      throw new Error('User not found');
    }

    return {
      id: user.id!,
      name: user.name,
      email: user.email,
      createdAt: user.createdAt
    };
  }
}

// src/application/use-cases/user/create-user.use-case.ts
import { User } from '../../../domain/entities/user';
import { UserRepository } from '../../../domain/repositories/user-repository.interface';

export interface CreateUserUseCaseInput {
  name: string;
  email: string;
}

export interface CreateUserUseCaseOutput {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
}

export class CreateUserUseCase {
  constructor(private readonly userRepository: UserRepository) {}

  async execute(input: CreateUserUseCaseInput): Promise<CreateUserUseCaseOutput> {
    const user = new User({
      name: input.name,
      email: input.email,
    });

    if (!user.validateEmail()) {
      throw new Error('Invalid email format');
    }

    const savedUser = await this.userRepository.save(user);

    return {
      id: savedUser.id!,
      name: savedUser.name,
      email: savedUser.email,
      createdAt: savedUser.createdAt
    };
  }
}
```

### 3. Interface Adapters

In TypeScript, adapters implement the interfaces defined in the domain layer:

```typescript
// src/infrastructure/repositories/postgres-user.repository.ts
import { Pool } from 'pg';
import { User } from '../../domain/entities/user';
import { UserRepository } from '../../domain/repositories/user-repository.interface';

export class PostgresUserRepository implements UserRepository {
  constructor(private readonly pool: Pool) {}

  async findById(id: string): Promise<User | null> {
    const query = 'SELECT id, name, email, created_at FROM users WHERE id = $1';
    const values = [id];

    const result = await this.pool.query(query, values);

    if (result.rows.length === 0) {
      return null;
    }

    const userData = result.rows[0];
    return new User({
      id: userData.id,
      name: userData.name,
      email: userData.email,
      createdAt: userData.created_at,
    });
  }

  async save(user: User): Promise<User> {
    const query = 'INSERT INTO users(name, email, created_at) VALUES($1, $2, $3) RETURNING id';
    const values = [user.name, user.email, user.createdAt];

    const result = await this.pool.query(query, values);
    const id = result.rows[0].id;

    return new User({
      id,
      name: user.name,
      email: user.email,
      createdAt: user.createdAt,
    });
  }

  async update(user: User): Promise<User> {
    const query = 'UPDATE users SET name = $1, email = $2 WHERE id = $3 RETURNING *';
    const values = [user.name, user.email, user.id];

    const result = await this.pool.query(query, values);

    if (result.rows.length === 0) {
      throw new Error('User not found');
    }

    const userData = result.rows[0];
    return new User({
      id: userData.id,
      name: userData.name,
      email: userData.email,
      createdAt: userData.created_at,
    });
  }

  async delete(id: string): Promise<void> {
    const query = 'DELETE FROM users WHERE id = $1';
    const values = [id];

    await this.pool.query(query, values);
  }
}
```

### 4. Frameworks & Drivers

```typescript
// src/interfaces/controllers/user.controller.ts
import { Request, Response } from 'express';
import { GetUserUseCase } from '../../application/use-cases/user/get-user.use-case';
import { CreateUserUseCase } from '../../application/use-cases/user/create-user.use-case';

export class UserController {
  constructor(
    private readonly getUserUseCase: GetUserUseCase,
    private readonly createUserUseCase: CreateUserUseCase,
  ) {}

  async getUser(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;

      const result = await this.getUserUseCase.execute({ id });

      res.status(200).json(result);
    } catch (error) {
      res.status(404).json({ message: error.message });
    }
  }

  async createUser(req: Request, res: Response): Promise<void> {
    try {
      const { name, email } = req.body;

      const result = await this.createUserUseCase.execute({
        name,
        email,
      });

      res.status(201).json(result);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  }
}
```

## Main Application Wiring

```typescript
// src/main.ts
import express from 'express';
import { Pool } from 'pg';
import { PostgresUserRepository } from './infrastructure/repositories/postgres-user.repository';
import { GetUserUseCase } from './application/use-cases/user/get-user.use-case';
import { CreateUserUseCase } from './application/use-cases/user/create-user.use-case';
import { UserController } from './interfaces/controllers/user.controller';

async function bootstrap() {
  // Create Express app
  const app = express();
  app.use(express.json());

  // Database connection
  const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'clean_arch_db',
    password: 'password',
    port: 5432,
  });

  // Repositories
  const userRepository = new PostgresUserRepository(pool);

  // Use Cases
  const getUserUseCase = new GetUserUseCase(userRepository);
  const createUserUseCase = new CreateUserUseCase(userRepository);

  // Controllers
  const userController = new UserController(
    getUserUseCase,
    createUserUseCase,
  );

  // Routes
  app.get('/users/:id', (req, res) => userController.getUser(req, res));
  app.post('/users', (req, res) => userController.createUser(req, res));

  // Start server
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

bootstrap().catch(console.error);
```

## Folder Structure for TypeScript Clean Architecture

```
src/
├── domain/                         // Enterprise Business Rules
│   ├── entities/
│   │   └── user.ts
│   └── repositories/
│       └── user-repository.interface.ts
├── application/                    // Application Business Rules
│   └── use-cases/
│       └── user/
│           ├── get-user.use-case.ts
│           └── create-user.use-case.ts
├── infrastructure/                 // Interface Adapters (Data)
│   ├── repositories/
│   │   └── postgres-user.repository.ts
│   └── config/
│       └── database.ts
├── interfaces/                     // Interface Adapters (Delivery)
│   ├── controllers/
│   │   └── user.controller.ts
│   └── presenters/
│       └── user.presenter.ts
├── frameworks/                     // Frameworks & Drivers
│   ├── express/
│   │   ├── routes/
│   │   │   └── user.routes.ts
│   │   └── middlewares/
│   │       └── error-handler.middleware.ts
│   └── database/
│       └── postgres/
│           └── connection.ts
└── main.ts                         // Application entry point
```

## TypeScript-Specific Testing Strategy

```typescript
// tests/unit/application/use-cases/user/get-user.use-case.spec.ts
import { expect } from 'chai';
import sinon from 'sinon';
import { User } from '../../../../../src/domain/entities/user';
import { UserRepository } from '../../../../../src/domain/repositories/user-repository.interface';
import { GetUserUseCase } from '../../../../../src/application/use-cases/user/get-user.use-case';

describe('GetUserUseCase', () => {
  let userRepository: UserRepository;
  let getUserUseCase: GetUserUseCase;

  beforeEach(() => {
    // Create a mock repository
    userRepository = {
      findById: sinon.stub(),
      save: sinon.stub(),
      update: sinon.stub(),
      delete: sinon.stub(),
    };

    getUserUseCase = new GetUserUseCase(userRepository);
  });

  afterEach(() => {
    sinon.restore();
  });

  it('should throw an error if user ID is not provided', async () => {
    try {
      await getUserUseCase.execute({ id: '' });
      expect.fail('Expected an error to be thrown');
    } catch (error) {
      expect(error.message).to.equal('User ID is required');
    }
  });

  it('should throw an error if user is not found', async () => {
    (userRepository.findById as sinon.SinonStub).resolves(null);

    try {
      await getUserUseCase.execute({ id: 'non-existent-id' });
      expect.fail('Expected an error to be thrown');
    } catch (error) {
      expect(error.message).to.equal('User not found');
    }
  });

  it('should return user data if user exists', async () => {
    const testUser = new User({
      id: 'test-id',
      name: 'Test User',
      email: 'test@example.com',
      createdAt: new Date('2023-01-01'),
    });

    (userRepository.findById as sinon.SinonStub).resolves(testUser);

    const result = await getUserUseCase.execute({ id: 'test-id' });

    expect(result).to.deep.equal({
      id: 'test-id',
      name: 'Test User',
      email: 'test@example.com',
      createdAt: testUser.createdAt,
    });

    expect(userRepository.findById).to.have.been.calledWith('test-id');
  });
});

// tests/integration/user-api.spec.ts
import request from 'supertest';
import { expect } from 'chai';
import express from 'express';
import { createConnection } from 'typeorm';
import { UserController } from '../../src/interfaces/controllers/user.controller';
// ... other imports

describe('User API', () => {
  let app: express.Application;
  let connection: any;

  before(async () => {
    // Set up database connection
    connection = await createConnection({
      type: 'postgres',
      host: 'localhost',
      port: 5432,
      username: 'test',
      password: 'test',
      database: 'test_db',
      entities: ['src/domain/entities/*.ts'],
      synchronize: true,
      dropSchema: true,
    });

    // Set up Express app for testing
    app = express();
    app.use(express.json());

    // Set up repositories, use cases, and controllers
    const userRepository = new TypeOrmUserRepository(connection);
    const getUserUseCase = new GetUserUseCase(userRepository);
    const createUserUseCase = new CreateUserUseCase(userRepository);
    const userController = new UserController(getUserUseCase, createUserUseCase);

    // Set up routes for testing
    app.get('/users/:id', (req, res) => userController.getUser(req, res));
    app.post('/users', (req, res) => userController.createUser(req, res));
  });

  after(async () => {
    await connection.close();
  });

  it('should create a new user', async () => {
    const response = await request(app)
      .post('/users')
      .send({
        name: 'John Doe',
        email: 'john.doe@example.com',
      });

    expect(response.status).to.equal(201);
    expect(response.body).to.have.property('id');
    expect(response.body.name).to.equal('John Doe');
    expect(response.body.email).to.equal('john.doe@example.com');
  });

  it('should retrieve a user by ID', async () => {
    // First create a user
    const createResponse = await request(app)
      .post('/users')
      .send({
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
      });

    const userId = createResponse.body.id;

    // Then retrieve the user
    const getResponse = await request(app).get(`/users/${userId}`);

    expect(getResponse.status).to.equal(200);
    expect(getResponse.body.id).to.equal(userId);
    expect(getResponse.body.name).to.equal('Jane Smith');
    expect(getResponse.body.email).to.equal('jane.smith@example.com');
  });
});
```

## Common TypeScript Patterns in Clean Architecture

### 1. Dependency Injection

TypeScript typically uses constructor injection:

```typescript
// Constructor injection
constructor(private readonly userRepository: UserRepository) {}
```

For more complex applications, you might use a DI container like InversifyJS:

```typescript
// With InversifyJS
import { Container } from 'inversify';
import { UserRepository } from './domain/repositories/user-repository.interface';
import { PostgresUserRepository } from './infrastructure/repositories/postgres-user.repository';

const container = new Container();
container.bind<UserRepository>('UserRepository').to(PostgresUserRepository);
```

### 2. Data Transfer Objects (DTOs)

TypeScript uses interfaces for DTOs:

```typescript
// DTOs for input/output
export interface CreateUserDTO {
  name: string;
  email: string;
}

export interface UserResponseDTO {
  id: string;
  name: string;
  email: string;
  createdAt: string;
}
```

### 3. Error Handling

TypeScript typically uses exceptions and custom error classes:

```typescript
// Custom error classes
export class NotFoundError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'NotFoundError';
  }
}

// Usage
if (!user) {
  throw new NotFoundError('User not found');
}
```

### 4. Async/Await for Asynchronous Operations

TypeScript leverages async/await for handling asynchronous operations:

```typescript
async execute(input: GetUserUseCaseInput): Promise<GetUserUseCaseOutput> {
  const user = await this.userRepository.findById(input.id);
  // ...
}
```

## TypeScript-Specific Clean Architecture Benefits

1. **Type safety**: TypeScript's static typing enhances code reliability
2. **Interface-driven development**: Interfaces are first-class citizens
3. **Dependency inversion**: Easy to implement with TypeScript interfaces
4. **Code navigation**: Better IDE support for navigating between layers
5. **Refactoring support**: Type checking makes refactoring safer

## Common Challenges and Solutions in TypeScript

### 1. Type Duplication

**Problem**: Similar types defined in different layers
**Solution**: Create shared type definitions or use mapped types

### 2. Complex Type Hierarchies

**Problem**: Over-engineered type hierarchies
**Solution**: Use composition over inheritance, keep types simple

### 3. Excessive Abstraction

**Problem**: Too many interfaces and abstractions
**Solution**: Find the right balance for your application's complexity

### 4. Managing Dependency Injection

**Problem**: Manual DI becomes complex as application grows
**Solution**: Consider using a DI container like InversifyJS or TypeDI

### 5. Balancing Framework Independence with Productivity

**Problem**: Total framework independence can reduce productivity
**Solution**: Consider framework-specific adapters while keeping core logic clean