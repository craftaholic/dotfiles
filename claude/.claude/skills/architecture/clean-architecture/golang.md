---
name: clean-architecture-golang
description: Implement Clean Architecture principles in Go to create maintainable, testable, and framework-independent applications. Use when designing new Go applications or refactoring existing Go codebases.
---

# Clean Architecture in Go

Implementation patterns for designing Go applications following Clean Architecture principles.

## When to Use

- Designing new Go applications
- Refactoring legacy Go codebases
- Building complex domain models in Go
- Creating testable, maintainable Go code
- Framework-independent Go development

## Core Principles

1. **Independence from Frameworks**: The architecture doesn't depend on the existence of some framework
2. **Testability**: Business rules can be tested without UI, database, server, or frameworks
3. **Independence from UI**: The UI can change without changing the system
4. **Independence from Database**: The database can be changed without affecting the business rules
5. **Independence from External Agencies**: Business rules don't know about external interfaces

## Layer Structure in Go Applications

### Core Concentric Layers

```
┌────────────────────────────────────────────────────┐
│ FRAMEWORKS & DRIVERS (Web, UI, DB, Devices, etc.)  │
│ ┌────────────────────────────────────────────────┐ │
│ │ INTERFACE ADAPTERS (Controllers, Presenters)   │ │
│ │ ┌────────────────────────────────────────────┐ │ │
│ │ │ APPLICATION BUSINESS RULES (Use Cases)     │ │ │
│ │ │ ┌────────────────────────────────────────┐ │ │ │
│ │ │ │ ENTERPRISE BUSINESS RULES (Entities)   │ │ │ │
│ │ │ └────────────────────────────────────────┘ │ │ │
│ │ └────────────────────────────────────────────┘ │ │
│ └────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────┘
```

## Implementation in Go

### 1. Enterprise Business Rules (Entities)

Domain entities in Go are typically defined as structs with methods:

```go
// internal/domain/entity/user.go
package entity

import (
    "errors"
    "regexp"
    "time"
)

type User struct {
    ID        string
    Name      string
    Email     string
    CreatedAt time.Time
}

// ValidateEmail validates user email format
func (u *User) ValidateEmail() error {
    emailRegex := regexp.MustCompile(`^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,4}$`)
    if !emailRegex.MatchString(u.Email) {
        return errors.New("invalid email format")
    }
    return nil
}

// IsNew checks if the user is a new entity
func (u *User) IsNew() bool {
    return u.ID == ""
}
```

Domain repository interfaces are defined in the domain layer:

```go
// internal/domain/repository/user.go
package repository

import (
    "context"

    "github.com/example/project/internal/domain/entity"
)

// UserRepository defines the contract for data persistence
type User interface {
    FindByID(ctx context.Context, id string) (*entity.User, error)
    Save(ctx context.Context, user *entity.User) error
    Update(ctx context.Context, user *entity.User) error
    Delete(ctx context.Context, id string) error
}
```

### 2. Application Business Rules (Use Cases)

In Go, use cases are typically implemented as services with interfaces:

```go
// internal/usecase/user.go
package usecase

import (
    "context"
    "errors"
    "time"

    "github.com/example/project/internal/domain/entity"
    "github.com/example/project/internal/domain/repository"
)

// User defines the interface for user use cases
type User interface {
    GetByID(ctx context.Context, id string) (*entity.User, error)
    Create(ctx context.Context, name, email string) (*entity.User, error)
    Update(ctx context.Context, id, name, email string) (*entity.User, error)
    Delete(ctx context.Context, id string) error
}

// UserUseCase implements User interface
type UserUseCase struct {
    repo repository.User
}

// NewUserUseCase creates a new UserUseCase instance
func NewUserUseCase(repo repository.User) *UserUseCase {
    return &UserUseCase{
        repo: repo,
    }
}

// GetByID retrieves a user by ID
func (uc *UserUseCase) GetByID(ctx context.Context, id string) (*entity.User, error) {
    if id == "" {
        return nil, errors.New("user ID cannot be empty")
    }

    return uc.repo.FindByID(ctx, id)
}

// Create creates a new user
func (uc *UserUseCase) Create(ctx context.Context, name, email string) (*entity.User, error) {
    user := &entity.User{
        Name:      name,
        Email:     email,
        CreatedAt: time.Now(),
    }

    if err := user.ValidateEmail(); err != nil {
        return nil, err
    }

    if err := uc.repo.Save(ctx, user); err != nil {
        return nil, err
    }

    return user, nil
}

// Update updates an existing user
func (uc *UserUseCase) Update(ctx context.Context, id, name, email string) (*entity.User, error) {
    user, err := uc.repo.FindByID(ctx, id)
    if err != nil {
        return nil, err
    }

    user.Name = name
    user.Email = email

    if err := user.ValidateEmail(); err != nil {
        return nil, err
    }

    if err := uc.repo.Update(ctx, user); err != nil {
        return nil, err
    }

    return user, nil
}

// Delete deletes a user by ID
func (uc *UserUseCase) Delete(ctx context.Context, id string) error {
    return uc.repo.Delete(ctx, id)
}
```

### 3. Interface Adapters

In Go, adapters implement the interfaces defined in the use cases:

```go
// internal/adapter/repository/postgres/user.go
package postgres

import (
    "context"
    "database/sql"
    "errors"

    "github.com/example/project/internal/domain/entity"
)

// UserRepository implements repository.User interface using PostgreSQL
type UserRepository struct {
    db *sql.DB
}

// NewUserRepository creates a new PostgreSQL repository
func NewUserRepository(db *sql.DB) *UserRepository {
    return &UserRepository{
        db: db,
    }
}

// FindByID retrieves a user from PostgreSQL by ID
func (r *UserRepository) FindByID(ctx context.Context, id string) (*entity.User, error) {
    query := "SELECT id, name, email, created_at FROM users WHERE id = $1"

    var user entity.User
    err := r.db.QueryRowContext(ctx, query, id).Scan(
        &user.ID,
        &user.Name,
        &user.Email,
        &user.CreatedAt,
    )

    if err == sql.ErrNoRows {
        return nil, errors.New("user not found")
    }

    if err != nil {
        return nil, err
    }

    return &user, nil
}

// Save persists a new user to PostgreSQL
func (r *UserRepository) Save(ctx context.Context, user *entity.User) error {
    query := "INSERT INTO users (name, email, created_at) VALUES ($1, $2, $3) RETURNING id"

    err := r.db.QueryRowContext(ctx, query, user.Name, user.Email, user.CreatedAt).Scan(&user.ID)
    if err != nil {
        return err
    }

    return nil
}

// Update updates an existing user in PostgreSQL
func (r *UserRepository) Update(ctx context.Context, user *entity.User) error {
    query := "UPDATE users SET name = $1, email = $2 WHERE id = $3"

    result, err := r.db.ExecContext(ctx, query, user.Name, user.Email, user.ID)
    if err != nil {
        return err
    }

    rowsAffected, err := result.RowsAffected()
    if err != nil {
        return err
    }

    if rowsAffected == 0 {
        return errors.New("user not found")
    }

    return nil
}

// Delete removes a user from PostgreSQL
func (r *UserRepository) Delete(ctx context.Context, id string) error {
    query := "DELETE FROM users WHERE id = $1"

    result, err := r.db.ExecContext(ctx, query, id)
    if err != nil {
        return err
    }

    rowsAffected, err := result.RowsAffected()
    if err != nil {
        return err
    }

    if rowsAffected == 0 {
        return errors.New("user not found")
    }

    return nil
}
```

HTTP handlers for the REST API:

```go
// internal/adapter/handler/http/user.go
package http

import (
    "encoding/json"
    "net/http"

    "github.com/gorilla/mux"

    "github.com/example/project/internal/usecase"
)

// UserResponse is the DTO for user data
type UserResponse struct {
    ID        string `json:"id"`
    Name      string `json:"name"`
    Email     string `json:"email"`
    CreatedAt string `json:"created_at"`
}

// UserHandler handles HTTP requests related to users
type UserHandler struct {
    userUseCase usecase.User
}

// NewUserHandler creates a new UserHandler
func NewUserHandler(userUseCase usecase.User) *UserHandler {
    return &UserHandler{
        userUseCase: userUseCase,
    }
}

// GetUser handles GET requests to retrieve a user
func (h *UserHandler) GetUser(w http.ResponseWriter, r *http.Request) {
    vars := mux.Vars(r)
    id := vars["id"]

    ctx := r.Context()
    user, err := h.userUseCase.GetByID(ctx, id)

    if err != nil {
        w.WriteHeader(http.StatusNotFound)
        json.NewEncoder(w).Encode(map[string]string{"error": err.Error()})
        return
    }

    response := UserResponse{
        ID:        user.ID,
        Name:      user.Name,
        Email:     user.Email,
        CreatedAt: user.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}

// CreateUser handles POST requests to create a user
func (h *UserHandler) CreateUser(w http.ResponseWriter, r *http.Request) {
    var input struct {
        Name  string `json:"name"`
        Email string `json:"email"`
    }

    if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
        w.WriteHeader(http.StatusBadRequest)
        json.NewEncoder(w).Encode(map[string]string{"error": "Invalid request payload"})
        return
    }

    ctx := r.Context()
    user, err := h.userUseCase.Create(ctx, input.Name, input.Email)

    if err != nil {
        w.WriteHeader(http.StatusBadRequest)
        json.NewEncoder(w).Encode(map[string]string{"error": err.Error()})
        return
    }

    response := UserResponse{
        ID:        user.ID,
        Name:      user.Name,
        Email:     user.Email,
        CreatedAt: user.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
    }

    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusCreated)
    json.NewEncoder(w).Encode(response)
}

// RegisterRoutes registers all user routes to the router
func (h *UserHandler) RegisterRoutes(router *mux.Router) {
    router.HandleFunc("/users/{id}", h.GetUser).Methods("GET")
    router.HandleFunc("/users", h.CreateUser).Methods("POST")
}
```

### 4. Frameworks & Drivers

```go
// internal/infrastructure/database/postgres.go
package database

import (
    "database/sql"
    "fmt"
    "log"

    _ "github.com/lib/pq"
)

// PostgresConfig contains postgres connection configuration
type PostgresConfig struct {
    Host     string
    Port     string
    User     string
    Password string
    DBName   string
    SSLMode  string
}

// NewPostgresConnection creates a new postgres database connection
func NewPostgresConnection(config PostgresConfig) (*sql.DB, error) {
    dsn := fmt.Sprintf(
        "host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
        config.Host, config.Port, config.User, config.Password, config.DBName, config.SSLMode,
    )

    db, err := sql.Open("postgres", dsn)
    if err != nil {
        return nil, fmt.Errorf("failed to open database connection: %w", err)
    }

    if err := db.Ping(); err != nil {
        return nil, fmt.Errorf("failed to ping database: %w", err)
    }

    log.Println("Connected to PostgreSQL database")
    return db, nil
}
```

```go
// internal/infrastructure/server/http.go
package server

import (
    "context"
    "log"
    "net/http"
    "time"

    "github.com/gorilla/mux"
)

// HTTPServer represents the HTTP server
type HTTPServer struct {
    server *http.Server
    router *mux.Router
}

// NewHTTPServer creates a new HTTP server
func NewHTTPServer(port string) *HTTPServer {
    router := mux.NewRouter()

    return &HTTPServer{
        server: &http.Server{
            Addr:         ":" + port,
            Handler:      router,
            ReadTimeout:  15 * time.Second,
            WriteTimeout: 15 * time.Second,
            IdleTimeout:  60 * time.Second,
        },
        router: router,
    }
}

// Router returns the router instance
func (s *HTTPServer) Router() *mux.Router {
    return s.router
}

// Start starts the HTTP server
func (s *HTTPServer) Start() {
    go func() {
        log.Printf("Starting HTTP server on %s", s.server.Addr)
        if err := s.server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatalf("HTTP server error: %v", err)
        }
    }()
}

// Shutdown gracefully shuts down the HTTP server
func (s *HTTPServer) Shutdown(ctx context.Context) error {
    log.Println("Shutting down HTTP server...")
    return s.server.Shutdown(ctx)
}
```

## Dependency Injection with Bootstrap Pattern

In Clean Architecture, proper dependency injection is crucial for maintainability and testability. A well-designed bootstrap pattern provides a structured way to initialize and wire dependencies while adhering to the dependency inversion principle.

### Interface-Based Bootstrap Approach

The bootstrap pattern should work with interfaces, not concrete implementations, to maintain proper dependency inversion:

```go
// internal/bootstrap/container.go
package bootstrap

import (
    "database/sql"

    "github.com/example/project/internal/interfaces"
    "github.com/example/project/internal/adapter/http"
)

// Container holds all application dependencies as interfaces
type Container struct {
    // Infrastructure
    DB *sql.DB

    // Repositories (interfaces)
    UserRepository interfaces.UserRepository

    // Use cases (interfaces)
    UserUseCase interfaces.UserUseCase

    // HTTP handlers
    UserHandler *http.UserHandler

    // Logger
    Logger interfaces.Logger

    // Server
    Server interfaces.HTTPServer
}

// Bootstrap initializes all application dependencies
func Bootstrap() (*Container, error) {
    // Initialize the logger first
    logger, err := initLogger()
    if err != nil {
        return nil, err
    }

    logger.Info("Bootstrapping application")

    // Initialize the container with the logger
    container := &Container{
        Logger: logger,
    }

    // Load configuration
    config, err := initConfig()
    if err != nil {
        return nil, err
    }

    // Initialize database connection
    db, err := initDatabase(config.Database, logger)
    if err != nil {
        return nil, err
    }
    container.DB = db

    // Initialize repositories
    if err := initRepositories(container); err != nil {
        return nil, err
    }

    // Initialize use cases
    if err := initUseCases(container); err != nil {
        return nil, err
    }

    // Initialize HTTP handlers
    if err := initHTTPHandlers(container); err != nil {
        return nil, err
    }

    // Initialize server
    server, err := initHTTPServer(config.Server, logger)
    if err != nil {
        return nil, err
    }
    container.Server = server

    logger.Info("Application bootstrapped successfully")
    return container, nil
}

// Shutdown gracefully shuts down all services
func (c *Container) Shutdown() error {
    c.Logger.Info("Shutting down application")

    // Close database connection
    if c.DB != nil {
        if err := c.DB.Close(); err != nil {
            c.Logger.Error("Error closing database", "error", err)
            return err
        }
    }

    // Additional shutdown logic for other components

    c.Logger.Info("Application shutdown complete")
    return nil
}
```

### Modular Initialization Functions

Break down initialization logic into separate functions for better organization:

```go
// internal/bootstrap/init.go
package bootstrap

import (
    "database/sql"

    "github.com/example/project/internal/adapter/repository/postgres"
    "github.com/example/project/internal/adapter/handler/http"
    "github.com/example/project/internal/infrastructure/database"
    "github.com/example/project/internal/infrastructure/server"
    "github.com/example/project/internal/infrastructure/logger"
    "github.com/example/project/internal/usecase"
    "github.com/example/project/internal/shared/config"
)

// Initialize logger
func initLogger() (interfaces.Logger, error) {
    return logger.NewZapLogger(), nil
}

// Initialize configuration
func initConfig() (*config.Config, error) {
    return config.Load()
}

// Initialize database connection
func initDatabase(dbConfig config.DatabaseConfig, logger interfaces.Logger) (*sql.DB, error) {
    logger.Info("Connecting to database", "host", dbConfig.Host)

    db, err := database.NewPostgresConnection(database.PostgresConfig{
        Host:     dbConfig.Host,
        Port:     dbConfig.Port,
        User:     dbConfig.User,
        Password: dbConfig.Password,
        DBName:   dbConfig.Name,
        SSLMode:  dbConfig.SSLMode,
    })

    if err != nil {
        logger.Error("Failed to connect to database", "error", err)
        return nil, err
    }

    logger.Info("Successfully connected to database")
    return db, nil
}

// Initialize repositories
func initRepositories(c *Container) error {
    // User repository
    c.UserRepository = postgres.NewUserRepository(c.DB)
    return nil
}

// Initialize use cases
func initUseCases(c *Container) error {
    // User use case
    c.UserUseCase = usecase.NewUserUseCase(c.UserRepository)
    return nil
}

// Initialize HTTP handlers
func initHTTPHandlers(c *Container) error {
    // User handler
    c.UserHandler = http.NewUserHandler(c.UserUseCase)
    return nil
}

// Initialize HTTP server
func initHTTPServer(serverConfig config.ServerConfig, logger interfaces.Logger) (interfaces.HTTPServer, error) {
    return server.NewHTTPServer(serverConfig.Port), nil
}
```

## Main Application Wiring with Bootstrap

Using the bootstrap pattern in the main entry point:

```go
// cmd/api/main.go
package main

import (
    "context"
    "os"
    "os/signal"
    "syscall"
    "time"

    "github.com/example/project/internal/api/route"
    "github.com/example/project/internal/bootstrap"
)

func main() {
    // Bootstrap the application
    container, err := bootstrap.Bootstrap()
    if err != nil {
        panic(err)
    }

    // Ensure proper shutdown
    defer func() {
        if err := container.Shutdown(); err != nil {
            container.Logger.Error("Error during shutdown", "error", err)
        }
    }()

    // Set up HTTP routes using the container
    router := route.Setup(container)

    // Configure the HTTP server with the router
    server := container.Server
    server.SetHandler(router)

    // Start the server in a goroutine
    go func() {
        container.Logger.Info("Starting HTTP server", "port", server.Port())
        if err := server.Start(); err != nil {
            container.Logger.Error("Server failed", "error", err)
        }
    }()

    // Wait for interrupt signal to gracefully shutdown
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit
    container.Logger.Info("Shutting down server...")

    // Create a deadline for server shutdown
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()

    // Shut down the server
    if err := server.Shutdown(ctx); err != nil {
        container.Logger.Fatal("Server forced to shutdown", "error", err)
    }
}
```

## Folder Structure for Go Clean Architecture

```
project/
├── cmd/
│   └── api/
│       └── main.go          // Application entry point
├── internal/                // All private application code
│   ├── domain/              // Enterprise Business Rules
│   │   ├── entity/          // Domain models
│   │   │   └── user.go
│   │   └── repository/      // Repository interfaces
│   │       └── user.go
│   ├── usecase/             // Application Business Rules
│   │   └── user.go          // Use cases for user domain
│   ├── adapter/             // Interface Adapters
│   │   ├── handler/         // HTTP/gRPC handlers
│   │   │   ├── http/
│   │   │   │   └── user.go
│   │   │   └── grpc/
│   │   │       └── user.go
│   │   ├── presenter/       // View presenters
│   │   │   └── user.go
│   │   └── repository/      // Repository implementations
│   │       ├── postgres/
│   │       │   └── user.go
│   │       └── mongo/
│   │           └── user.go
│   └── infrastructure/      // Frameworks & Drivers
│       ├── database/        // Database connections
│       │   ├── postgres.go
│       │   └── mongo.go
│       ├── server/          // Server configurations
│       │   ├── http.go
│       │   └── grpc.go
│       └── config/          // Application configuration
│           └── config.go
└── pkg/                     // Shared utilities (exported)
    ├── logger/
    │   └── logger.go
    └── utils/
        └── utils.go
```

## Go-Specific Testing Strategy

```go
// application/usecases/user_usecase_test.go
package usecases_test

import (
    "context"
    "errors"
    "testing"
    "time"

    "app/domain/entities"
    "app/application/usecases"
)

// MockUserRepository implements UserRepository for testing
type MockUserRepository struct {
    users map[string]*entities.User
}

func NewMockUserRepository() *MockUserRepository {
    return &MockUserRepository{
        users: make(map[string]*entities.User),
    }
}

func (m *MockUserRepository) FindByID(ctx context.Context, id string) (*entities.User, error) {
    user, exists := m.users[id]
    if !exists {
        return nil, errors.New("user not found")
    }
    return user, nil
}

func (m *MockUserRepository) Save(ctx context.Context, user *entities.User) error {
    // Simulate ID generation
    user.ID = "test-id"
    m.users[user.ID] = user
    return nil
}

func (m *MockUserRepository) Update(ctx context.Context, user *entities.User) error {
    if _, exists := m.users[user.ID]; !exists {
        return errors.New("user not found")
    }
    m.users[user.ID] = user
    return nil
}

func (m *MockUserRepository) Delete(ctx context.Context, id string) error {
    if _, exists := m.users[id]; !exists {
        return errors.New("user not found")
    }
    delete(m.users, id)
    return nil
}

func TestUserUseCase_GetUser(t *testing.T) {
    repo := NewMockUserRepository()
    useCase := usecases.NewUserUseCase(repo)
    ctx := context.Background()

    // Test with non-existing user
    _, err := useCase.GetUser(ctx, "non-existing-id")
    if err == nil {
        t.Fatalf("Expected error for non-existing user, got nil")
    }

    // Create a test user
    testUser := &entities.User{
        ID:        "test-id",
        Name:      "Test User",
        Email:     "test@example.com",
        CreatedAt: time.Now(),
    }
    repo.users["test-id"] = testUser

    // Test with existing user
    user, err := useCase.GetUser(ctx, "test-id")
    if err != nil {
        t.Fatalf("Expected no error, got %v", err)
    }

    if user.ID != testUser.ID || user.Name != testUser.Name || user.Email != testUser.Email {
        t.Errorf("Expected user %+v, got %+v", testUser, user)
    }
}

func TestUserUseCase_CreateUser(t *testing.T) {
    repo := NewMockUserRepository()
    useCase := usecases.NewUserUseCase(repo)
    ctx := context.Background()

    // Test with invalid email
    _, err := useCase.CreateUser(ctx, "Test User", "invalid-email")
    if err == nil {
        t.Fatalf("Expected error for invalid email, got nil")
    }

    // Test with valid data
    user, err := useCase.CreateUser(ctx, "Test User", "test@example.com")
    if err != nil {
        t.Fatalf("Expected no error, got %v", err)
    }

    if user.ID == "" || user.Name != "Test User" || user.Email != "test@example.com" {
        t.Errorf("User was not created correctly: %+v", user)
    }
}
```

## Common Go Patterns in Clean Architecture

### 1. Dependency Injection

Go typically uses constructor injection:

```go
// Constructor injection
func NewUserUseCase(repo UserRepository) *UserUseCase {
    return &UserUseCase{repo: repo}
}
```

### 2. Error Handling

Go uses explicit error handling:

```go
// Error checking pattern
user, err := useCase.GetUser(ctx, id)
if err != nil {
    // Handle error
    return err
}

// Use user...
```

### 3. Context Passing

Go passes request context through the layers:

```go
// Context passing
func (uc *UserUseCase) GetUser(ctx context.Context, id string) (*entities.User, error) {
    // Pass context to repository
    return uc.repo.FindByID(ctx, id)
}
```

### 4. Interfaces for Dependency Inversion

Go uses interfaces to abstract dependencies:

```go
// Define interface in the layer that uses it
type UserRepository interface {
    FindByID(ctx context.Context, id string) (*entities.User, error)
    // Other methods...
}

// Implementation in the infrastructure layer
type PostgresUserRepository struct {
    // Implementation details...
}
```

## Go-Specific Clean Architecture Benefits

1. **Clear separation of concerns**: Go's package system works well with Clean Architecture
2. **Testability**: Easy to mock interfaces for unit testing
3. **Maintainability**: Clean separation reduces coupling
4. **Adaptability**: Easy to replace implementations (e.g., database, framework)
5. **Scalability**: Go's concurrency model works well with the layered approach

## Common Challenges and Solutions in Go

### 1. Circular Dependencies

**Problem**: Circular imports between packages
**Solution**: Define interfaces in the using package

### 2. Over-engineering

**Problem**: Too many layers/interfaces for simple applications
**Solution**: Right-size the architecture based on application complexity

### 3. Error Propagation

**Problem**: Error handling across multiple layers
**Solution**: Use error wrapping with context

### 4. Domain vs. Data Transfer Objects

**Problem**: Converting between domain and DTOs
**Solution**: Use mappers/transformers to convert between representations

### 5. Testing Database Adapters

**Problem**: Testing repositories with real databases
**Solution**: Use testcontainers-go for integration tests with ephemeral databases

## Structured Logging in Clean Architecture

Proper logging is a critical aspect of any production-ready application. In Clean Architecture, logging should be:
1. Treated as a cross-cutting concern
2. Abstracted behind interfaces
3. Structured and consistent

### Logger Interface Design

Define a domain-agnostic logging interface:

```go
// internal/interfaces/logger.go
package interfaces

import "context"

// Standard field keys for consistent structured logging
const (
    // Context metadata
    FieldTraceID    = "trace_id"
    FieldRequestID  = "request_id"
    FieldUserID     = "user_id"

    // Component identification
    FieldComponent  = "component"
    FieldModule     = "module"
    FieldFunction   = "function"

    // Operation context
    FieldOperation  = "operation"
    FieldDuration   = "duration_ms"

    // Error information
    FieldError      = "error"
    FieldErrorCode  = "error_code"
)

// Logger defines the interface for logging operations
type Logger interface {
    // Context operations
    WithContext(ctx context.Context) Logger

    // Field operations
    WithFields(fields map[string]interface{}) Logger
    WithField(key string, value interface{}) Logger
    WithError(err error) Logger
    WithComponent(component string) Logger

    // Logging methods
    Debug(msg string, args ...interface{})
    Info(msg string, args ...interface{})
    Warn(msg string, args ...interface{})
    Error(msg string, args ...interface{})
    Fatal(msg string, args ...interface{})

    // Operation timing
    TimeOperation(operation string) Timer
}

// Timer allows measuring and logging operation durations
type Timer interface {
    End(level string, msg string, args ...interface{})
    EndDebug(msg string, args ...interface{})
    EndInfo(msg string, args ...interface{})
    EndError(msg string, args ...interface{})
}
```

### Logger Implementation with Zap

Implement the Logger interface using Zap:

```go
// internal/infrastructure/logger/zap_logger.go
package logger

import (
    "context"
    "time"

    "github.com/example/project/internal/interfaces"
    "go.uber.org/zap"
    "go.uber.org/zap/zapcore"
)

// Key for storing/retrieving logger from context
type loggerContextKey struct{}

// ZapLogger implements Logger interface using Zap
type ZapLogger struct {
    logger *zap.Logger
    fields map[string]interface{}
}

// NewZapLogger creates a new ZapLogger instance
func NewZapLogger() interfaces.Logger {
    // Create logger configuration
    config := zap.NewProductionConfig()

    // Customize encoding
    config.EncoderConfig.TimeKey = "timestamp"
    config.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder

    // Create logger
    zapLogger, err := config.Build(
        zap.AddCallerSkip(1),
        zap.AddStacktrace(zapcore.ErrorLevel),
    )
    if err != nil {
        panic(err)
    }

    return &ZapLogger{
        logger: zapLogger,
        fields: make(map[string]interface{}),
    }
}

// WithContext extracts logger from context or creates a new one with request metadata
func (l *ZapLogger) WithContext(ctx context.Context) interfaces.Logger {
    if ctx == nil {
        return l
    }

    // Check if logger already exists in context
    if ctxLogger, ok := ctx.Value(loggerContextKey{}).(*ZapLogger); ok {
        return ctxLogger
    }

    // Extract request ID from context if available
    reqID := extractRequestID(ctx)
    if reqID != "" {
        return l.WithField(interfaces.FieldRequestID, reqID)
    }

    return l
}

// WithFields adds multiple fields to logger
func (l *ZapLogger) WithFields(fields map[string]interface{}) interfaces.Logger {
    // Create a new logger with merged fields
    newFields := make(map[string]interface{}, len(l.fields)+len(fields))

    // Copy existing fields
    for k, v := range l.fields {
        newFields[k] = v
    }

    // Add new fields
    for k, v := range fields {
        newFields[k] = v
    }

    return &ZapLogger{
        logger: l.logger,
        fields: newFields,
    }
}

// WithField adds a single field to logger
func (l *ZapLogger) WithField(key string, value interface{}) interfaces.Logger {
    return l.WithFields(map[string]interface{}{key: value})
}

// WithError adds error information to logger
func (l *ZapLogger) WithError(err error) interfaces.Logger {
    if err == nil {
        return l
    }
    return l.WithField(interfaces.FieldError, err.Error())
}

// WithComponent adds component name to logger
func (l *ZapLogger) WithComponent(component string) interfaces.Logger {
    return l.WithField(interfaces.FieldComponent, component)
}

// getZapFields converts fields map to zap fields
func (l *ZapLogger) getZapFields() []zap.Field {
    zapFields := make([]zap.Field, 0, len(l.fields))
    for k, v := range l.fields {
        zapFields = append(zapFields, zap.Any(k, v))
    }
    return zapFields
}

// Debug logs at debug level
func (l *ZapLogger) Debug(msg string, args ...interface{}) {
    fields := l.processArgs(args...)
    l.logger.Debug(msg, fields...)
}

// Info logs at info level
func (l *ZapLogger) Info(msg string, args ...interface{}) {
    fields := l.processArgs(args...)
    l.logger.Info(msg, fields...)
}

// Warn logs at warn level
func (l *ZapLogger) Warn(msg string, args ...interface{}) {
    fields := l.processArgs(args...)
    l.logger.Warn(msg, fields...)
}

// Error logs at error level
func (l *ZapLogger) Error(msg string, args ...interface{}) {
    fields := l.processArgs(args...)
    l.logger.Error(msg, fields...)
}

// Fatal logs at fatal level and terminates the program
func (l *ZapLogger) Fatal(msg string, args ...interface{}) {
    fields := l.processArgs(args...)
    l.logger.Fatal(msg, fields...)
}

// TimeOperation starts timing an operation
func (l *ZapLogger) TimeOperation(operation string) interfaces.Timer {
    return &zapTimer{
        logger:    l,
        operation: operation,
        startTime: time.Now(),
    }
}

// processArgs converts variable args to zap fields
func (l *ZapLogger) processArgs(args ...interface{}) []zap.Field {
    if len(args) == 0 {
        return l.getZapFields()
    }

    // Start with existing fields
    fields := l.getZapFields()

    // Process additional fields
    for i := 0; i < len(args); i += 2 {
        if i+1 < len(args) {
            key, ok := args[i].(string)
            if !ok {
                key = "unknown_key"
            }
            fields = append(fields, zap.Any(key, args[i+1]))
        }
    }

    return fields
}

// zapTimer implements Timer interface
type zapTimer struct {
    logger    *ZapLogger
    operation string
    startTime time.Time
}

// End logs the operation duration with the specified level
func (t *zapTimer) End(level string, msg string, args ...interface{}) {
    duration := time.Since(t.startTime)

    // Prepare fields
    fields := append(
        []interface{}{
            interfaces.FieldOperation, t.operation,
            interfaces.FieldDuration, duration.Milliseconds(),
        },
        args...,
    )

    switch level {
    case "debug":
        t.logger.Debug(msg, fields...)
    case "info":
        t.logger.Info(msg, fields...)
    case "warn":
        t.logger.Warn(msg, fields...)
    case "error":
        t.logger.Error(msg, fields...)
    default:
        t.logger.Info(msg, fields...)
    }
}

// EndDebug ends timer with debug level
func (t *zapTimer) EndDebug(msg string, args ...interface{}) {
    t.End("debug", msg, args...)
}

// EndInfo ends timer with info level
func (t *zapTimer) EndInfo(msg string, args ...interface{}) {
    t.End("info", msg, args...)
}

// EndError ends timer with error level
func (t *zapTimer) EndError(msg string, args ...interface{}) {
    t.End("error", msg, args...)
}

// Helper function to extract request ID from context
func extractRequestID(ctx context.Context) string {
    // Implementation depends on your context structure
    // Example for a simple request ID:
    if reqID, ok := ctx.Value("request_id").(string); ok {
        return reqID
    }
    return ""
}
```

### Using the Logger Across Layers

#### 1. Repository Layer

```go
// internal/adapter/repository/postgres/user_repository.go
func (r *UserRepository) FindByID(ctx context.Context, id string) (*entity.User, error) {
    logger := r.logger.WithContext(ctx).WithFields(map[string]interface{}{
        interfaces.FieldComponent: "repository",
        interfaces.FieldModule:    "user",
        interfaces.FieldFunction:  "FindByID",
        "user_id":                 id,
    })

    logger.Debug("Finding user by ID")

    timer := logger.TimeOperation("db_query")

    query := "SELECT id, name, email, created_at FROM users WHERE id = $1"
    var user entity.User
    err := r.db.QueryRowContext(ctx, query, id).Scan(
        &user.ID,
        &user.Name,
        &user.Email,
        &user.CreatedAt,
    )

    if err == sql.ErrNoRows {
        timer.EndInfo("User not found")
        return nil, errors.New("user not found")
    }

    if err != nil {
        timer.EndError("Database query failed", "error", err)
        return nil, err
    }

    timer.EndDebug("User found")
    return &user, nil
}
```

#### 2. Use Case Layer

```go
// internal/usecase/user_usecase.go
func (uc *UserUseCase) GetByID(ctx context.Context, id string) (*entity.User, error) {
    logger := uc.logger.WithContext(ctx).WithFields(map[string]interface{}{
        interfaces.FieldComponent: "usecase",
        interfaces.FieldModule:    "user",
        interfaces.FieldFunction:  "GetByID",
        "user_id":                 id,
    })

    logger.Info("Getting user by ID")

    if id == "" {
        logger.Warn("Empty user ID provided")
        return nil, errors.New("user ID cannot be empty")
    }

    user, err := uc.userRepo.FindByID(ctx, id)
    if err != nil {
        logger.WithError(err).Error("Failed to get user by ID")
        return nil, err
    }

    logger.Debug("Successfully retrieved user")
    return user, nil
}
```

#### 3. HTTP Handler Layer

```go
// internal/adapter/handler/http/user_handler.go
func (h *UserHandler) GetUser(w http.ResponseWriter, r *http.Request) {
    ctx := r.Context()
    logger := h.logger.WithContext(ctx).WithFields(map[string]interface{}{
        interfaces.FieldComponent: "http_handler",
        interfaces.FieldModule:    "user",
        interfaces.FieldFunction:  "GetUser",
    })

    // Extract user ID from request
    vars := mux.Vars(r)
    id := vars["id"]

    logger.WithField("user_id", id).Info("Handling get user request")

    // Measure the entire handler execution time
    timer := logger.TimeOperation("handler_execution")

    user, err := h.userUseCase.GetByID(ctx, id)
    if err != nil {
        logger.WithError(err).Error("Failed to get user")
        w.WriteHeader(http.StatusNotFound)
        json.NewEncoder(w).Encode(map[string]string{"error": err.Error()})
        timer.EndError("Handler failed")
        return
    }

    // Create the response
    response := toUserResponse(user)

    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusOK)
    json.NewEncoder(w).Encode(response)

    timer.EndInfo("Handler completed successfully")
}
```

### HTTP Middleware for Request Logging

```go
// internal/api/middleware/logger.go
package middleware

import (
    "context"
    "net/http"
    "time"

    "github.com/google/uuid"
    "github.com/example/project/internal/interfaces"
)

// RequestLogger creates a middleware for logging HTTP requests
func RequestLogger(logger interfaces.Logger) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            start := time.Now()

            // Generate request ID if not present
            requestID := r.Header.Get("X-Request-ID")
            if requestID == "" {
                requestID = uuid.New().String()
                r.Header.Set("X-Request-ID", requestID)
            }

            // Create a request-scoped logger
            reqLogger := logger.WithFields(map[string]interface{}{
                interfaces.FieldRequestID: requestID,
                interfaces.FieldComponent: "http",
                "method":                  r.Method,
                "path":                    r.URL.Path,
                "remote_addr":             r.RemoteAddr,
                "user_agent":              r.UserAgent(),
            })

            // Store logger in context
            ctx := context.WithValue(r.Context(), "logger", reqLogger)

            // Log request start
            reqLogger.Debug("Request started")

            // Create response wrapper to capture status code
            wrapper := newResponseWrapper(w)

            // Process request
            next.ServeHTTP(wrapper, r.WithContext(ctx))

            // Calculate duration
            duration := time.Since(start).Milliseconds()

            // Log request completion with appropriate level
            logFields := map[string]interface{}{
                "status":                  wrapper.status,
                "size":                    wrapper.size,
                interfaces.FieldDuration:  duration,
            }

            // Choose log level based on status code
            if wrapper.status >= 500 {
                reqLogger.WithFields(logFields).Error("Request completed with server error")
            } else if wrapper.status >= 400 {
                reqLogger.WithFields(logFields).Warn("Request completed with client error")
            } else {
                reqLogger.WithFields(logFields).Info("Request completed successfully")
            }
        })
    }
}

// responseWrapper wraps http.ResponseWriter to capture status code and size
type responseWrapper struct {
    http.ResponseWriter
    status int
    size   int
}

func newResponseWrapper(w http.ResponseWriter) *responseWrapper {
    return &responseWrapper{ResponseWriter: w, status: http.StatusOK}
}

func (rw *responseWrapper) WriteHeader(code int) {
    rw.status = code
    rw.ResponseWriter.WriteHeader(code)
}

func (rw *responseWrapper) Write(b []byte) (int, error) {
    size, err := rw.ResponseWriter.Write(b)
    rw.size += size
    return size, err
}
```

## Integrating Bootstrap and Logging in Clean Architecture

Here's how to combine dependency injection with the bootstrap pattern and structured logging in a cohesive clean architecture implementation:

### 1. Enhanced Container with Logger

```go
// internal/bootstrap/container.go
package bootstrap

import (
    "database/sql"

    "github.com/example/project/internal/interfaces"
)

// Container holds all application dependencies as interfaces
type Container struct {
    // Infrastructure
    DB *sql.DB

    // Repositories (interfaces)
    UserRepository interfaces.UserRepository

    // Use cases (interfaces)
    UserUseCase interfaces.UserUseCase

    // Cross-cutting concerns
    Logger interfaces.Logger

    // Server
    Server interfaces.HTTPServer
}

// Bootstrap initializes all application dependencies
func Bootstrap() (*Container, error) {
    // Initialize the logger first for early diagnostics
    logger, err := initLogger()
    if err != nil {
        return nil, err
    }

    logger.Info("Bootstrapping application")

    // Create the container with the logger
    container := &Container{
        Logger: logger,
    }

    // Load configuration
    config, err := initConfig()
    if err != nil {
        logger.WithError(err).Error("Failed to load configuration")
        return nil, err
    }

    // Initialize components with tracing
    dbTimer := logger.TimeOperation("init_database")
    db, err := initDatabase(config.Database, logger)
    if err != nil {
        dbTimer.EndError("Failed to initialize database")
        return nil, err
    }
    dbTimer.EndInfo("Database initialized successfully")
    container.DB = db

    // Initialize repositories with component-specific loggers
    repoLogger := logger.WithComponent("repository")
    container.UserRepository = initUserRepository(db, repoLogger)

    // Initialize use cases with component-specific loggers
    usecaseLogger := logger.WithComponent("usecase")
    container.UserUseCase = initUserUseCase(container.UserRepository, usecaseLogger)

    // Initialize server with component-specific logger
    serverLogger := logger.WithComponent("http_server")
    server, err := initHTTPServer(config.Server.Port, serverLogger)
    if err != nil {
        logger.WithError(err).Error("Failed to initialize HTTP server")
        return nil, err
    }
    container.Server = server

    logger.Info("Application bootstrapped successfully")
    return container, nil
}
```

### 2. Repository Initialization with Logger

```go
// internal/bootstrap/init.go
func initUserRepository(db *sql.DB, logger interfaces.Logger) interfaces.UserRepository {
    logger.Debug("Initializing user repository")
    return postgres.NewUserRepository(db, logger.WithModule("user"))
}

// internal/adapter/repository/postgres/user_repository.go
type UserRepository struct {
    db     *sql.DB
    logger interfaces.Logger
}

func NewUserRepository(db *sql.DB, logger interfaces.Logger) *UserRepository {
    return &UserRepository{
        db:     db,
        logger: logger,
    }
}
```

### 3. Use Case Initialization with Logger

```go
// internal/bootstrap/init.go
func initUserUseCase(repo interfaces.UserRepository, logger interfaces.Logger) interfaces.UserUseCase {
    logger.Debug("Initializing user use case")
    return usecase.NewUserUseCase(repo, logger.WithModule("user"))
}

// internal/usecase/user_usecase.go
type UserUseCase struct {
    repo   interfaces.UserRepository
    logger interfaces.Logger
}

func NewUserUseCase(repo interfaces.UserRepository, logger interfaces.Logger) *UserUseCase {
    return &UserUseCase{
        repo:   repo,
        logger: logger,
    }
}
```

### 4. Setting Up HTTP Routes with Middleware

```go
// internal/api/route/setup.go
package route

import (
    "net/http"

    "github.com/gorilla/mux"
    "github.com/example/project/internal/api/middleware"
    "github.com/example/project/internal/bootstrap"
)

// Setup configures all HTTP routes
func Setup(container *bootstrap.Container) http.Handler {
    r := mux.NewRouter()

    // Apply global middleware
    r.Use(middleware.RequestLogger(container.Logger))
    r.Use(middleware.Recovery(container.Logger))

    // User routes
    userHandler := container.UserHandler
    r.HandleFunc("/users/{id}", userHandler.GetUser).Methods("GET")
    r.HandleFunc("/users", userHandler.CreateUser).Methods("POST")

    return r
}
```

### 5. Main Application with Graceful Shutdown and Logging

```go
// cmd/api/main.go
package main

import (
    "context"
    "os"
    "os/signal"
    "syscall"
    "time"

    "github.com/example/project/internal/api/route"
    "github.com/example/project/internal/bootstrap"
)

func main() {
    // Bootstrap the application
    container, err := bootstrap.Bootstrap()
    if err != nil {
        panic(err)
    }

    logger := container.Logger
    logger.Info("Application initialized successfully")

    // Ensure proper shutdown
    defer func() {
        if err := container.Shutdown(); err != nil {
            logger.Error("Error during shutdown", "error", err)
        }
    }()

    // Set up HTTP routes using the container
    router := route.Setup(container)

    // Configure the HTTP server with the router
    server := container.Server
    server.SetHandler(router)

    // Start the server in a goroutine
    serverErrors := make(chan error, 1)
    go func() {
        logger.Info("Starting HTTP server", "port", server.Port())
        serverErrors <- server.Start()
    }()

    // Wait for interrupt or server errors
    shutdownSignal := make(chan os.Signal, 1)
    signal.Notify(shutdownSignal, syscall.SIGINT, syscall.SIGTERM)

    select {
    case err := <-serverErrors:
        logger.Error("Server error", "error", err)
    case sig := <-shutdownSignal:
        logger.Info("Shutdown signal received", "signal", sig)
    }

    // Create a deadline for server shutdown
    shutdownTimer := logger.TimeOperation("graceful_shutdown")
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()

    // Shut down the server
    if err := server.Shutdown(ctx); err != nil {
        logger.Error("Server forced to shutdown", "error", err)
        os.Exit(1)
    }

    shutdownTimer.EndInfo("Server gracefully stopped")
}
```

### 6. Recovery Middleware with Logger

```go
// internal/api/middleware/recovery.go
package middleware

import (
    "net/http"
    "runtime/debug"

    "github.com/example/project/internal/interfaces"
)

// Recovery middleware catches panics and logs them
func Recovery(logger interfaces.Logger) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            defer func() {
                if err := recover(); err != nil {
                    // Log the panic with stack trace
                    logger.WithFields(map[string]interface{}{
                        interfaces.FieldComponent: "http",
                        "stack":                   string(debug.Stack()),
                        "panic":                   err,
                    }).Error("Panic recovered in HTTP handler")

                    // Return 500 Internal Server Error
                    http.Error(w,
                        "The server encountered an unexpected error",
                        http.StatusInternalServerError)
                }
            }()
            next.ServeHTTP(w, r)
        })
    }
}
```

### 7. Logger Shutdown

```go
// internal/bootstrap/container.go
func (c *Container) Shutdown() error {
    c.Logger.Info("Shutting down application")

    // Close database connection
    if c.DB != nil {
        c.Logger.Debug("Closing database connection")
        if err := c.DB.Close(); err != nil {
            c.Logger.Error("Error closing database", "error", err)
            return err
        }
    }

    // Custom shutdown logic for other components
    // ...

    c.Logger.Info("Application shutdown complete")
    return nil
}
```
