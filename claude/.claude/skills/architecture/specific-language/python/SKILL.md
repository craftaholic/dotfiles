---
name: clean-architecture-python
description: Implement Clean Architecture principles in Python to create maintainable, testable, and framework-independent applications. Use when designing new Python applications, refactoring existing code, or implementing domain-driven designs.
---

# Clean Architecture in Python

Implementation patterns for designing Python applications following Clean Architecture principles.

## When to Use

- Designing new Python applications
- Refactoring legacy Python codebases
- Building complex domain models
- Creating testable, maintainable Python code
- Framework-independent development with Flask, FastAPI, Django, etc.

## Core Principles

1. **Independence from Frameworks**: The architecture doesn't depend on frameworks
2. **Testability**: Business rules can be tested without UI, database, server, or frameworks
3. **Independence from UI**: The UI can change without changing the system
4. **Independence from Database**: The database can be changed without affecting the business rules
5. **Independence from External Agencies**: Business rules don't know about external interfaces

## Layer Structure in Python Applications

### Core Concentric Layers

```
┌────────────────────────────────────────────────────┐
│ FRAMEWORKS & DRIVERS (Flask, Django, DB, etc.)     │
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

## Implementation in Python

### 1. Enterprise Business Rules (Entities)

Domain entities in Python are typically defined as classes:

```python
# domain/entities/user.py
from dataclasses import dataclass
from datetime import datetime
import re
from typing import Optional


@dataclass
class User:
    name: str
    email: str
    created_at: datetime = None
    id: Optional[str] = None

    def __post_init__(self):
        if self.created_at is None:
            self.created_at = datetime.now()

    def validate_email(self) -> bool:
        """Validate email format."""
        email_regex = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
        return bool(re.match(email_regex, self.email))

    def is_new(self) -> bool:
        """Check if the user is a new entity."""
        return self.id is None

    def change_name(self, new_name: str) -> None:
        """Change user name with validation."""
        if not new_name or not new_name.strip():
            raise ValueError("Name cannot be empty")
        self.name = new_name
```

### 2. Application Business Rules (Use Cases)

In Python, use cases are typically implemented as classes with defined input/output protocols:

```python
# domain/repositories/user_repository.py
from abc import ABC, abstractmethod
from typing import Optional, List
from domain.entities.user import User


class UserRepository(ABC):
    """Interface for user repository."""

    @abstractmethod
    def find_by_id(self, user_id: str) -> Optional[User]:
        """Find a user by ID."""
        pass

    @abstractmethod
    def save(self, user: User) -> User:
        """Save a user to the repository."""
        pass

    @abstractmethod
    def update(self, user: User) -> User:
        """Update an existing user."""
        pass

    @abstractmethod
    def delete(self, user_id: str) -> None:
        """Delete a user by ID."""
        pass

    @abstractmethod
    def find_all(self) -> List[User]:
        """Find all users."""
        pass


# application/use_cases/user/get_user.py
from dataclasses import dataclass
from typing import Optional
from domain.entities.user import User
from domain.repositories.user_repository import UserRepository


@dataclass
class GetUserInputDto:
    """Input data for the GetUser use case."""
    user_id: str


@dataclass
class GetUserOutputDto:
    """Output data from the GetUser use case."""
    id: str
    name: str
    email: str
    created_at: str  # ISO format date


class GetUserUseCase:
    """Use case for retrieving a user by ID."""

    def __init__(self, user_repository: UserRepository):
        self.user_repository = user_repository

    def execute(self, input_dto: GetUserInputDto) -> GetUserOutputDto:
        """Execute the use case."""
        if not input_dto.user_id:
            raise ValueError("User ID is required")

        user = self.user_repository.find_by_id(input_dto.user_id)

        if user is None:
            raise ValueError(f"User with ID {input_dto.user_id} not found")

        return GetUserOutputDto(
            id=user.id,
            name=user.name,
            email=user.email,
            created_at=user.created_at.isoformat()
        )


# application/use_cases/user/create_user.py
from dataclasses import dataclass
from domain.entities.user import User
from domain.repositories.user_repository import UserRepository


@dataclass
class CreateUserInputDto:
    """Input data for the CreateUser use case."""
    name: str
    email: str


@dataclass
class CreateUserOutputDto:
    """Output data from the CreateUser use case."""
    id: str
    name: str
    email: str
    created_at: str  # ISO format date


class CreateUserUseCase:
    """Use case for creating a new user."""

    def __init__(self, user_repository: UserRepository):
        self.user_repository = user_repository

    def execute(self, input_dto: CreateUserInputDto) -> CreateUserOutputDto:
        """Execute the use case."""
        # Create domain entity
        user = User(
            name=input_dto.name,
            email=input_dto.email,
        )

        # Validate business rules
        if not user.validate_email():
            raise ValueError("Invalid email format")

        # Save to repository
        saved_user = self.user_repository.save(user)

        # Return output DTO
        return CreateUserOutputDto(
            id=saved_user.id,
            name=saved_user.name,
            email=saved_user.email,
            created_at=saved_user.created_at.isoformat()
        )
```

### 3. Interface Adapters

In Python, adapters implement the interfaces defined in the domain layer:

```python
# infrastructure/repositories/sqlalchemy_user_repository.py
from typing import Optional, List
from sqlalchemy.orm import Session
from domain.entities.user import User
from domain.repositories.user_repository import UserRepository
from infrastructure.orm.models import UserModel


class SqlAlchemyUserRepository(UserRepository):
    """SQLAlchemy implementation of the UserRepository interface."""

    def __init__(self, session: Session):
        self.session = session

    def find_by_id(self, user_id: str) -> Optional[User]:
        """Find a user by ID."""
        user_model = self.session.query(UserModel).filter_by(id=user_id).first()

        if user_model is None:
            return None

        return User(
            id=str(user_model.id),
            name=user_model.name,
            email=user_model.email,
            created_at=user_model.created_at
        )

    def save(self, user: User) -> User:
        """Save a user to the database."""
        user_model = UserModel(
            name=user.name,
            email=user.email,
            created_at=user.created_at
        )

        self.session.add(user_model)
        self.session.commit()

        # Update domain entity with generated ID
        user.id = str(user_model.id)
        return user

    def update(self, user: User) -> User:
        """Update an existing user."""
        user_model = self.session.query(UserModel).filter_by(id=user.id).first()

        if user_model is None:
            raise ValueError(f"User with ID {user.id} not found")

        user_model.name = user.name
        user_model.email = user.email

        self.session.commit()
        return user

    def delete(self, user_id: str) -> None:
        """Delete a user by ID."""
        user_model = self.session.query(UserModel).filter_by(id=user_id).first()

        if user_model is None:
            raise ValueError(f"User with ID {user_id} not found")

        self.session.delete(user_model)
        self.session.commit()

    def find_all(self) -> List[User]:
        """Find all users."""
        user_models = self.session.query(UserModel).all()

        return [
            User(
                id=str(model.id),
                name=model.name,
                email=model.email,
                created_at=model.created_at
            )
            for model in user_models
        ]


# infrastructure/orm/models.py
from sqlalchemy import Column, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
import uuid

Base = declarative_base()


class UserModel(Base):
    """SQLAlchemy model for the users table."""

    __tablename__ = "users"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String, nullable=False)
    email = Column(String, nullable=False, unique=True)
    created_at = Column(DateTime, nullable=False)
```

### 4. Frameworks & Drivers

```python
# interfaces/controllers/user_controller.py
from application.use_cases.user.get_user import GetUserUseCase, GetUserInputDto
from application.use_cases.user.create_user import CreateUserUseCase, CreateUserInputDto


class UserController:
    """Controller for user-related endpoints."""

    def __init__(self, get_user_use_case: GetUserUseCase, create_user_use_case: CreateUserUseCase):
        self.get_user_use_case = get_user_use_case
        self.create_user_use_case = create_user_use_case

    def get_user(self, user_id: str) -> dict:
        """Get a user by ID."""
        input_dto = GetUserInputDto(user_id=user_id)
        output_dto = self.get_user_use_case.execute(input_dto)

        return {
            "id": output_dto.id,
            "name": output_dto.name,
            "email": output_dto.email,
            "created_at": output_dto.created_at
        }

    def create_user(self, request_data: dict) -> dict:
        """Create a new user."""
        input_dto = CreateUserInputDto(
            name=request_data["name"],
            email=request_data["email"]
        )

        output_dto = self.create_user_use_case.execute(input_dto)

        return {
            "id": output_dto.id,
            "name": output_dto.name,
            "email": output_dto.email,
            "created_at": output_dto.created_at
        }


# frameworks/web/flask/app.py
from flask import Flask, jsonify, request
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from dependency_injector import containers, providers

from domain.repositories.user_repository import UserRepository
from application.use_cases.user.get_user import GetUserUseCase
from application.use_cases.user.create_user import CreateUserUseCase
from infrastructure.repositories.sqlalchemy_user_repository import SqlAlchemyUserRepository
from interfaces.controllers.user_controller import UserController
from infrastructure.orm.models import Base


class Container(containers.DeclarativeContainer):
    """Dependency injection container."""

    config = providers.Configuration()

    db = providers.Singleton(
        create_engine,
        config.db.url
    )

    db_session_factory = providers.Factory(
        sessionmaker,
        autocommit=False,
        autoflush=False,
        bind=db
    )

    db_session = providers.Callable(
        db_session_factory
    )

    user_repository = providers.Factory(
        SqlAlchemyUserRepository,
        session=db_session
    )

    get_user_use_case = providers.Factory(
        GetUserUseCase,
        user_repository=user_repository
    )

    create_user_use_case = providers.Factory(
        CreateUserUseCase,
        user_repository=user_repository
    )

    user_controller = providers.Factory(
        UserController,
        get_user_use_case=get_user_use_case,
        create_user_use_case=create_user_use_case
    )


# Application setup
app = Flask(__name__)

# Configure dependency injection
container = Container()
container.config.db.url.from_env("DATABASE_URL", "sqlite:///clean_arch.db")

# Create database tables
engine = container.db()
Base.metadata.create_all(engine)


@app.route("/users/<user_id>", methods=["GET"])
def get_user(user_id):
    """Get a user by ID endpoint."""
    try:
        user_controller = container.user_controller()
        result = user_controller.get_user(user_id)
        return jsonify(result), 200
    except ValueError as e:
        return jsonify({"error": str(e)}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/users", methods=["POST"])
def create_user():
    """Create a new user endpoint."""
    try:
        user_controller = container.user_controller()
        result = user_controller.create_user(request.json)
        return jsonify(result), 201
    except ValueError as e:
        return jsonify({"error": str(e)}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(debug=True)
```

## Folder Structure for Python Clean Architecture

```
project/
├── domain/                      # Enterprise Business Rules
│   ├── entities/
│   │   └── user.py
│   └── repositories/
│       └── user_repository.py
├── application/                 # Application Business Rules
│   └── use_cases/
│       └── user/
│           ├── get_user.py
│           └── create_user.py
├── infrastructure/              # Interface Adapters (Data)
│   ├── repositories/
│   │   └── sqlalchemy_user_repository.py
│   └── orm/
│       └── models.py
├── interfaces/                  # Interface Adapters (Delivery)
│   ├── controllers/
│   │   └── user_controller.py
│   └── serializers/
│       └── user_serializer.py
├── frameworks/                  # Frameworks & Drivers
│   ├── web/
│   │   ├── flask/
│   │   │   └── app.py
│   │   └── fastapi/
│   │       └── app.py
│   └── db/
│       └── connection.py
├── tests/                       # Tests for all layers
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── config.py                    # Configuration settings
└── main.py                      # Application entry point
```

## Python-Specific Testing Strategy

```python
# tests/unit/domain/entities/test_user.py
import unittest
from datetime import datetime
from domain.entities.user import User


class TestUser(unittest.TestCase):
    """Unit tests for the User entity."""

    def test_validate_email_with_valid_email(self):
        """Test validate_email with a valid email."""
        user = User(name="Test User", email="test@example.com")
        self.assertTrue(user.validate_email())

    def test_validate_email_with_invalid_email(self):
        """Test validate_email with an invalid email."""
        user = User(name="Test User", email="invalid-email")
        self.assertFalse(user.validate_email())

    def test_is_new_for_new_user(self):
        """Test is_new returns True for a new user."""
        user = User(name="Test User", email="test@example.com")
        self.assertTrue(user.is_new())

    def test_is_new_for_existing_user(self):
        """Test is_new returns False for an existing user."""
        user = User(name="Test User", email="test@example.com", id="test-id")
        self.assertFalse(user.is_new())

    def test_change_name_with_valid_name(self):
        """Test change_name with a valid name."""
        user = User(name="Test User", email="test@example.com")
        user.change_name("New Name")
        self.assertEqual(user.name, "New Name")

    def test_change_name_with_empty_name(self):
        """Test change_name with an empty name."""
        user = User(name="Test User", email="test@example.com")
        with self.assertRaises(ValueError):
            user.change_name("")


# tests/unit/application/use_cases/user/test_get_user.py
import unittest
from unittest.mock import Mock
from datetime import datetime
from domain.entities.user import User
from application.use_cases.user.get_user import GetUserUseCase, GetUserInputDto


class TestGetUserUseCase(unittest.TestCase):
    """Unit tests for the GetUserUseCase."""

    def setUp(self):
        """Set up test dependencies."""
        self.user_repository = Mock()
        self.use_case = GetUserUseCase(self.user_repository)

    def test_execute_with_valid_id(self):
        """Test execute with a valid user ID."""
        # Arrange
        test_user = User(
            id="test-id",
            name="Test User",
            email="test@example.com",
            created_at=datetime(2023, 1, 1)
        )
        self.user_repository.find_by_id.return_value = test_user

        # Act
        input_dto = GetUserInputDto(user_id="test-id")
        output_dto = self.use_case.execute(input_dto)

        # Assert
        self.user_repository.find_by_id.assert_called_once_with("test-id")
        self.assertEqual(output_dto.id, "test-id")
        self.assertEqual(output_dto.name, "Test User")
        self.assertEqual(output_dto.email, "test@example.com")
        self.assertEqual(output_dto.created_at, "2023-01-01T00:00:00")

    def test_execute_with_empty_id(self):
        """Test execute with an empty user ID."""
        with self.assertRaises(ValueError) as context:
            input_dto = GetUserInputDto(user_id="")
            self.use_case.execute(input_dto)

        self.assertEqual(str(context.exception), "User ID is required")
        self.user_repository.find_by_id.assert_not_called()

    def test_execute_with_nonexistent_id(self):
        """Test execute with a non-existent user ID."""
        # Arrange
        self.user_repository.find_by_id.return_value = None

        # Act and Assert
        with self.assertRaises(ValueError) as context:
            input_dto = GetUserInputDto(user_id="non-existent")
            self.use_case.execute(input_dto)

        self.assertEqual(str(context.exception), "User with ID non-existent not found")
        self.user_repository.find_by_id.assert_called_once_with("non-existent")


# tests/integration/test_user_repository.py
import unittest
import os
from datetime import datetime
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from domain.entities.user import User
from infrastructure.repositories.sqlalchemy_user_repository import SqlAlchemyUserRepository
from infrastructure.orm.models import Base


class TestSqlAlchemyUserRepository(unittest.TestCase):
    """Integration tests for the SqlAlchemyUserRepository."""

    @classmethod
    def setUpClass(cls):
        """Set up the test database."""
        cls.engine = create_engine('sqlite:///test.db')
        Base.metadata.create_all(cls.engine)
        cls.Session = sessionmaker(bind=cls.engine)

    @classmethod
    def tearDownClass(cls):
        """Clean up the test database."""
        Base.metadata.drop_all(cls.engine)
        os.remove("test.db")

    def setUp(self):
        """Set up a new session for each test."""
        self.session = self.Session()
        self.repository = SqlAlchemyUserRepository(self.session)

    def tearDown(self):
        """Clean up after each test."""
        self.session.close()

    def test_save_and_find_by_id(self):
        """Test saving a user and finding it by ID."""
        # Arrange
        user = User(
            name="Test User",
            email="test@example.com",
            created_at=datetime(2023, 1, 1)
        )

        # Act
        saved_user = self.repository.save(user)
        found_user = self.repository.find_by_id(saved_user.id)

        # Assert
        self.assertIsNotNone(saved_user.id)
        self.assertIsNotNone(found_user)
        self.assertEqual(found_user.name, "Test User")
        self.assertEqual(found_user.email, "test@example.com")

    def test_update(self):
        """Test updating a user."""
        # Arrange
        user = User(
            name="Original Name",
            email="test@example.com",
            created_at=datetime(2023, 1, 1)
        )
        saved_user = self.repository.save(user)

        # Act
        saved_user.name = "Updated Name"
        updated_user = self.repository.update(saved_user)
        found_user = self.repository.find_by_id(saved_user.id)

        # Assert
        self.assertEqual(updated_user.name, "Updated Name")
        self.assertEqual(found_user.name, "Updated Name")

    def test_delete(self):
        """Test deleting a user."""
        # Arrange
        user = User(
            name="Test User",
            email="test@example.com",
            created_at=datetime(2023, 1, 1)
        )
        saved_user = self.repository.save(user)

        # Act
        self.repository.delete(saved_user.id)
        found_user = self.repository.find_by_id(saved_user.id)

        # Assert
        self.assertIsNone(found_user)
```

## Common Python Patterns in Clean Architecture

### 1. Dependency Injection

Python typically uses constructor injection:

```python
# Constructor injection
def __init__(self, user_repository: UserRepository):
    self.user_repository = user_repository
```

For more complex applications, you might use a DI container like `dependency_injector`:

```python
# With dependency_injector
from dependency_injector import containers, providers

class Container(containers.DeclarativeContainer):
    user_repository = providers.Factory(SqlAlchemyUserRepository, session=db_session)
    get_user_use_case = providers.Factory(GetUserUseCase, user_repository=user_repository)
```

### 2. Type Hints

Python 3.5+ supports type hints to make code more explicit:

```python
# Type hints
def find_by_id(self, user_id: str) -> Optional[User]:
    """Find a user by ID."""
    pass
```

### 3. Data Classes

Python 3.7+ supports data classes for cleaner entity definitions:

```python
# Data classes for entities and DTOs
@dataclass
class User:
    name: str
    email: str
    created_at: datetime = None
    id: Optional[str] = None
```

### 4. Abstract Base Classes

Python uses ABC for defining interfaces:

```python
# Abstract Base Classes for repositories
class UserRepository(ABC):
    @abstractmethod
    def find_by_id(self, user_id: str) -> Optional[User]:
        pass
```

## Python-Specific Clean Architecture Benefits

1. **Duck typing with explicit interfaces**: Python's dynamic typing with explicit interface definitions
2. **Readable code**: Python's clean syntax enhances readability across layers
3. **Test-friendly**: Easy to mock dependencies for unit testing
4. **Adaptability**: Simple to adapt to different frameworks (Flask, FastAPI, Django)
5. **Modern language features**: Type hints, data classes, and ABCs support clean code

## Common Challenges and Solutions in Python

### 1. Type Safety

**Problem**: Python's dynamic typing can lead to runtime errors
**Solution**: Use type hints and static type checkers like mypy

### 2. Enforcing Interfaces

**Problem**: Python doesn't enforce interface implementation
**Solution**: Use abstract base classes and runtime checking

### 3. Framework Integration

**Problem**: Many Python frameworks prefer their own architecture
**Solution**: Use framework-specific adapters while keeping core logic clean

### 4. ORM Integration

**Problem**: ORMs like SQLAlchemy often influence domain design
**Solution**: Keep ORM models separate from domain entities using mappers

### 5. Dependency Management

**Problem**: Managing complex dependency graphs
**Solution**: Use dependency injection containers or composition root patterns