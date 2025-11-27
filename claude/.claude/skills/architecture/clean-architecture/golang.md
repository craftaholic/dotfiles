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

## Main Application Wiring

```go
// cmd/api/main.go
package main

import (
    "context"
    "log"
    "os"
    "os/signal"
    "syscall"
    "time"

    "github.com/example/project/internal/adapter/handler/http"
    "github.com/example/project/internal/adapter/repository/postgres"
    "github.com/example/project/internal/infrastructure/database"
    "github.com/example/project/internal/infrastructure/server"
    "github.com/example/project/internal/usecase"
)

func main() {
    // Load configuration
    dbConfig := database.PostgresConfig{
        Host:     "localhost",
        Port:     "5432",
        User:     "postgres",
        Password: "password",
        DBName:   "userdb",
        SSLMode:  "disable",
    }

    // Set up database connection
    db, err := database.NewPostgresConnection(dbConfig)
    if err != nil {
        log.Fatalf("Failed to connect to database: %v", err)
    }
    defer db.Close()

    // Set up repositories
    userRepo := postgres.NewUserRepository(db)

    // Set up use cases
    userUseCase := usecase.NewUserUseCase(userRepo)

    // Set up HTTP server
    httpServer := server.NewHTTPServer("8080")

    // Set up HTTP handlers
    userHandler := http.NewUserHandler(userUseCase)
    userHandler.RegisterRoutes(httpServer.Router())

    // Start HTTP server
    httpServer.Start()

    // Wait for interrupt signal to gracefully shutdown the server
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit
    log.Println("Shutting down server...")

    // Create a deadline to wait for
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()

    // Shutdown the server
    if err := httpServer.Shutdown(ctx); err != nil {
        log.Fatalf("Server forced to shutdown: %v", err)
    }

    log.Println("Server exited properly")
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
