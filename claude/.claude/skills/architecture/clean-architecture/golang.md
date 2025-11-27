---
name: clean-architecture-golang
description: Implement Clean Architecture principles in Go to create maintainable, testable, and framework-independent applications. Use when designing new Go applications or refactoring existing Go codebases.
---

# Clean Architecture in Go

Implementation patterns for designing Go applications following Clean Architecture principles.

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

## Key Concepts

### Clean Architecture Principles

- **Dependency Inversion**: Dependencies flow from outer layers to inner layers
- **Separation of Concerns**: Business logic is independent of frameworks, databases, and external services
- **Testability**: Components are designed for easy testing through interfaces and dependency injection
- **Maintainability**: Organized structure makes code easier to understand and evolve

### Interface Definition Pattern

In this template, interfaces are defined in `contracts.go` files within their respective packages. This pattern provides a clear location for interface definitions and makes it easy to generate mocks for testing.

For example, in `internal/repo/contracts.go`:

```go
// Package repo implements application outer layer logic. Each logic group in own file.
package repo

import (
    "context"
    "github.com/evrone/go-clean-template/internal/entity"
)

//go:generate mockgen -source=contracts.go -destination=../usecase/mocks_repo_test.go -package=usecase_test

type (
    // TranslationRepo -.
    TranslationRepo interface {
        Store(context.Context, entity.Translation) error
        GetHistory(context.Context) ([]entity.Translation, error)
    }

    // TranslationWebAPI -.
    TranslationWebAPI interface {
        Translate(entity.Translation) (entity.Translation, error)
    }
)
```

Note the `go:generate` directive that automatically generates mocks for testing.

### Project Structure

```
├── cmd/app                  # Application entrypoint
├── config                   # Configuration management
├── internal                 # Application code not exported to other projects
│   ├── app                  # Application startup and initialization
│   ├── controller           # Entry points/delivery layer (HTTP, gRPC, AMQP, NATS)
│   │   ├── http             # HTTP handlers
│   │   ├── grpc             # gRPC handlers
│   │   ├── amqp_rpc         # RabbitMQ RPC handlers
│   │   └── nats_rpc         # NATS RPC handlers
│   ├── entity               # Business domain models/entities
│   ├── repo                 # Repository interfaces and implementations
│   │   ├── persistent       # Database implementations
│   │   └── webapi           # External API implementations
│   └── usecase              # Business logic implementation
└── pkg                      # Reusable libraries and utilities
    ├── httpserver           # HTTP server wrapper
    ├── grpcserver           # gRPC server wrapper
    ├── postgres             # PostgreSQL client
    ├── rabbitmq             # RabbitMQ client
    └── logger               # Logging utility
```

### Layers

1. **Entities** (`internal/entity`): Domain models and business rules
2. **Use Cases** (`internal/usecase`): Application business logic
3. **Interface Adapters** (`internal/repo`, `internal/controller`): Converting data between layers
4. **Frameworks & Drivers** (`pkg`): External tools and frameworks

## How to Use This Template

### Creating a New Application

1. Define your domain entities in `internal/entity`
2. Define repository interfaces in `internal/repo`
3. Implement business logic in `internal/usecase`
4. Implement repositories in `internal/repo/{persistent|webapi}`
5. Implement controllers in `internal/controller/{http|grpc|amqp_rpc|nats_rpc}`
6. Wire everything together in `internal/app/app.go`

### Adding New Features

1. Add new entity models if needed
2. Add repository interfaces for data access
3. Add use case implementations for business logic
4. Add controller methods for API endpoints
5. Update routes in the appropriate router

### Implementing Dependencies

```go
// Define an interface in the inner layer
type Repository interface {
    Get() ([]Entity, error)
}

// Implement the interface in the outer layer
type PostgresRepository struct {
    db *sql.DB
}

func (r *PostgresRepository) Get() ([]Entity, error) {
    // Implementation
}

// Inject the dependency in the use case
type UseCase struct {
    repo Repository
}

func NewUseCase(r Repository) *UseCase {
    return &UseCase{
        repo: r,
    }
}
```

## Best Practices

1. **Interface Segregation**: Create small, focused interfaces
2. **Dependency Injection**: Inject dependencies through constructors
3. **Error Handling**: Wrap errors with context
4. **Testability**: Design components for easy mocking and testing
5. **Layer Isolation**: Inner layers should not depend on outer layers
6. **Package Structure**: Group related functionality by domain, not by technical layer

## Examples from the Template Repository

The examples below are taken directly from the template repository, showing how the clean architecture principles are applied.

### Repository Interface (contracts.go)

In `internal/repo/contracts.go`:

```go
// Package repo implements application outer layer logic. Each logic group in own file.
package repo

import (
	"context"
	"github.com/evrone/go-clean-template/internal/entity"
)

//go:generate mockgen -source=contracts.go -destination=../usecase/mocks_repo_test.go -package=usecase_test

type (
	// TranslationRepo -.
	TranslationRepo interface {
		Store(context.Context, entity.Translation) error
		GetHistory(context.Context) ([]entity.Translation, error)
	}

	// TranslationWebAPI -.
	TranslationWebAPI interface {
		Translate(entity.Translation) (entity.Translation, error)
	}
)
```

### Repository Implementation (persistent)

In `internal/repo/persistent/translation_postgres.go`:

```go
package persistent

import (
	"context"
	"fmt"

	"github.com/evrone/go-clean-template/internal/entity"
	"github.com/evrone/go-clean-template/pkg/postgres"
)

// TranslationRepo -.
type TranslationRepo struct {
	*postgres.Postgres
}

// New -.
func New(pg *postgres.Postgres) *TranslationRepo {
	return &TranslationRepo{pg}
}

// GetHistory -.
func (r *TranslationRepo) GetHistory(ctx context.Context) ([]entity.Translation, error) {
	sql, _, err := r.Builder.
		Select("source, destination, original, translation").
		From("history").
		ToSql()
	if err != nil {
		return nil, fmt.Errorf("TranslationRepo - GetHistory - r.Builder: %w", err)
	}

	rows, err := r.Pool.Query(ctx, sql)
	if err != nil {
		return nil, fmt.Errorf("TranslationRepo - GetHistory - r.Pool.Query: %w", err)
	}
	defer rows.Close()

	entities := make([]entity.Translation, 0, _defaultEntityCap)

	for rows.Next() {
		e := entity.Translation{}

		err = rows.Scan(&e.Source, &e.Destination, &e.Original, &e.Translation)
		if err != nil {
			return nil, fmt.Errorf("TranslationRepo - GetHistory - rows.Scan: %w", err)
		}

		entities = append(entities, e)
	}

	return entities, nil
}
```

### Use Case Implementation

In `internal/usecase/translation/translation.go`:

```go
package translation

import (
	"context"
	"fmt"

	"github.com/evrone/go-clean-template/internal/entity"
	"github.com/evrone/go-clean-template/internal/repo"
)

// UseCase -.
type UseCase struct {
	repo   repo.TranslationRepo
	webAPI repo.TranslationWebAPI
}

// New -.
func New(r repo.TranslationRepo, w repo.TranslationWebAPI) *UseCase {
	return &UseCase{
		repo:   r,
		webAPI: w,
	}
}

// Translate -.
func (uc *UseCase) Translate(ctx context.Context, t entity.Translation) (entity.Translation, error) {
	translation, err := uc.webAPI.Translate(t)
	if err != nil {
		return entity.Translation{}, fmt.Errorf("TranslationUseCase - Translate - s.webAPI.Translate: %w", err)
	}

	err = uc.repo.Store(ctx, translation)
	if err != nil {
		return entity.Translation{}, fmt.Errorf("TranslationUseCase - Translate - s.repo.Store: %w", err)
	}

	return translation, nil
}
```

### HTTP Controller and Router

In `internal/controller/http/v1/router.go`:

```go
package v1

import (
	"github.com/evrone/go-clean-template/internal/usecase"
	"github.com/evrone/go-clean-template/pkg/logger"
	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
)

// NewTranslationRoutes -.
func NewTranslationRoutes(apiV1Group fiber.Router, t usecase.Translation, l logger.Interface) {
	r := &V1{t: t, l: l, v: validator.New(validator.WithRequiredStructEnabled())}

	translationGroup := apiV1Group.Group("/translation")

	{
		translationGroup.Get("/history", r.history)
		translationGroup.Post("/do-translate", r.doTranslate)
	}
}
```

In `internal/controller/http/v1/translation.go`:

```go
// @Summary     Translate
// @Description Translate a text
// @ID          do-translate
// @Tags  	    translation
// @Accept      json
// @Produce     json
// @Param       request body request.Translate true "Set up translation"
// @Success     200 {object} entity.Translation
// @Failure     400 {object} response.Error
// @Failure     500 {object} response.Error
// @Router      /translation/do-translate [post]
func (r *V1) doTranslate(ctx *fiber.Ctx) error {
	var body request.Translate

	if err := ctx.BodyParser(&body); err != nil {
		r.l.Error(err, "http - v1 - doTranslate")
		return errorResponse(ctx, http.StatusBadRequest, "invalid request body")
	}

	if err := r.v.Struct(body); err != nil {
		r.l.Error(err, "http - v1 - doTranslate")
		return errorResponse(ctx, http.StatusBadRequest, "invalid request body")
	}

	translation, err := r.t.Translate(
		ctx.UserContext(),
		entity.Translation{
			Source:      body.Source,
			Destination: body.Destination,
			Original:    body.Original,
		},
	)
	if err != nil {
		r.l.Error(err, "http - v1 - doTranslate")
		return errorResponse(ctx, http.StatusInternalServerError, "translation service problems")
	}

	return ctx.Status(http.StatusOK).JSON(translation)
}
```

### Request/Response Models

In `internal/controller/http/v1/request/translate.go`:

```go
package request

type Translate struct {
	Source      string `json:"source"       validate:"required"  example:"auto"`
	Destination string `json:"destination"  validate:"required"  example:"en"`
	Original    string `json:"original"     validate:"required"  example:"текст для перевода"`
}
```

## Common Patterns

1. **Request/Response Mapping**: Convert between API DTOs and domain entities
2. **Error Wrapping**: Add context to errors as they pass through layers
3. **Dependency Injection**: Pass dependencies through constructors
4. **Interface-based Design**: Define behavior through interfaces
5. **Context Propagation**: Pass context.Context through all layers

## Logger Usage Pattern

The template uses a structured logger based on [zerolog](https://github.com/rs/zerolog) with a custom interface wrapper. The logger is created at application startup and injected into components that need logging capabilities.

### Logger Interface

In `pkg/logger/logger.go`:

```go
// Interface -.
type Interface interface {
    Debug(message interface{}, args ...interface{})
    Info(message string, args ...interface{})
    Warn(message string, args ...interface{})
    Error(message interface{}, args ...interface{})
    Fatal(message interface{}, args ...interface{})
}
```

### Logger Initialization

In `internal/app/app.go`:

```go
// Run creates objects via constructors.
func Run(cfg *config.Config) {
    l := logger.New(cfg.Log.Level)

    // ... rest of the application setup
}
```

### Logger Usage in Components

The logger is injected into components at creation time:

```go
// Controller example
type V1 struct {
    t Translation
    l logger.Interface
    v *validator.Validate
}

// New returns a new instance of the V1 router.
func NewTranslationRoutes(handler fiber.Router, t Translation, l logger.Interface) {
    v := validator.New()
    r := &V1{t, l, v}

    // ... router setup
}

// Usage within a controller method
func (r *V1) doTranslate(ctx *fiber.Ctx) error {
    // ...
    if err := ctx.BodyParser(&body); err != nil {
        r.l.Error(err, "http - v1 - doTranslate") // <-- Logger usage
        return errorResponse(ctx, http.StatusBadRequest, "invalid request body")
    }
    // ...
}
```

### Error Logging Pattern

The template follows a consistent pattern for error logging:

1. Log the error with its context
2. Return a formatted error to the caller

```go
if err != nil {
    r.l.Error(err, "component - function - operation")
    return errorResponse(ctx, statusCode, "user-friendly message")
}
```

### Limitations and Enhancement Opportunities

The default logger implementation does not support context-aware logging with request IDs or trace IDs propagated through different layers. This is an area where the template could be enhanced.

#### Recommended Approach: Context-Embedded Logger

A recommended approach is to embed the logger in the context and retrieve it in each layer. This approach is cleaner and more idiomatic in Go applications:

```go
// In pkg/logger/logger.go

package logger

import (
    "context"

    "go.uber.org/zap"
)

// ctxKey is used as the key for storing logger in context
type ctxKey struct{}

// Interface defines the logger methods
type Interface interface {
    // Standard logging methods
    Debug(msg string, fields ...any)
    Info(msg string, fields ...any)
    Warn(msg string, fields ...any)
    Error(msg string, fields ...any)
    Fatal(msg string, fields ...any)

    // Context methods
    FromCtx(ctx context.Context) Interface
    WithCtx(ctx context.Context) context.Context
    WithFields(fields ...any) Interface
}

// Logger implementation using zap
type Logger struct {
    logger *zap.Logger
}

var BaseLogger Interface

// FromCtx extracts the logger from context
func (l *Logger) FromCtx(ctx context.Context) Interface {
    if logger, ok := ctx.Value(ctxKey{}).(*Logger); ok {
        return logger
    }
    // Return base logger if none in context
    return l
}

// WithCtx creates a new context containing the logger
func (l *Logger) WithCtx(ctx context.Context) context.Context {
    return context.WithValue(ctx, ctxKey{}, l)
}

// WithFields returns a new logger with the specified fields
func (l *Logger) WithFields(fields ...any) Interface {
    // Add fields to the logger using zap
    sugar := l.logger.Sugar().With(fields...)
    return &Logger{logger: sugar.Desugar()}
}
```

#### Middleware Implementation

The logger is attached to the context in HTTP middleware:

```go
// In internal/controller/http/middleware/logging.go

func LoggingMiddleware(l logger.Interface) fiber.Handler {
    return func(c *fiber.Ctx) error {
        // Generate request ID
        requestID := uuid.New().String()
        c.Set("X-Request-ID", requestID)

        // Create a logger with request fields
        reqLogger := l.WithFields(
            "request_id", requestID,
            "method", c.Method(),
            "path", c.Path(),
            "ip", c.IP(),
        )

        // Store logger in context
        ctx := reqLogger.WithCtx(c.UserContext())
        c.SetUserContext(ctx)

        // Log the request
        reqLogger.Info("Incoming request")

        // Continue with request processing
        err := c.Next()

        // Log the response
        reqLogger.Info("Request completed",
            "status", c.Response().StatusCode(),
            "duration_ms", time.Since(start).Milliseconds(),
        )

        return err
    }
}
```

#### Usage in Controllers

```go
func (r *V1) doTranslate(ctx *fiber.Ctx) error {
    // Extract logger from context
    logger := BaseLogger.FromCtx(ctx.UserContext())

    var body request.Translate
    if err := ctx.BodyParser(&body); err != nil {
        logger.Error("Failed to parse request body",
            "error", err.Error(),
            "handler", "doTranslate",
        )
        return errorResponse(ctx, http.StatusBadRequest, "invalid request body")
    }

    // Pass context with logger to downstream services
    translation, err := r.t.Translate(ctx.UserContext(), entity.Translation{
        Source:      body.Source,
        Destination: body.Destination,
        Original:    body.Original,
    })

    if err != nil {
        logger.Error("Translation service error",
            "error", err.Error(),
            "handler", "doTranslate",
        )
        return errorResponse(ctx, http.StatusInternalServerError, "translation service problems")
    }

    return ctx.Status(http.StatusOK).JSON(translation)
}
```

#### Usage in Use Cases/Services

```go
func (uc *UseCase) Translate(ctx context.Context, t entity.Translation) (entity.Translation, error) {
    // Extract logger from context
    logger := BaseLogger.FromCtx(ctx)

    logger.Debug("Translating text",
        "source", t.Source,
        "destination", t.Destination,
        "length", len(t.Original),
    )

    translation, err := uc.webAPI.Translate(t)
    if err != nil {
        logger.Error("Translation API failed",
            "error", err.Error(),
            "source", t.Source,
            "destination", t.Destination,
        )
        return entity.Translation{}, fmt.Errorf("TranslationUseCase - Translate - webAPI.Translate: %w", err)
    }

    err = uc.repo.Store(ctx, translation)
    if err != nil {
        logger.Error("Failed to store translation",
            "error", err.Error(),
        )
        return entity.Translation{}, fmt.Errorf("TranslationUseCase - Translate - repo.Store: %w", err)
    }

    logger.Info("Translation successful",
        "source", t.Source,
        "destination", t.Destination,
    )

    return translation, nil
}
```

#### Benefits of this Approach:

1. **Automatic Propagation**: The logger is automatically propagated through all layers via context
2. **Contextual Information**: Each log entry includes request-specific information (request ID, etc.)
3. **Structured Logging**: Uses structured logging with fields for better filtering and analysis
4. **Clean API**: No need to pass a logger separately to methods
5. **Consistent Logging**: All components access the same logger with the same request context

#### Complete Zap Logger Implementation Example

Here's a complete implementation of the context-aware logger using Zap:

```go
package logger

import (
	"context"
	"fmt"
	"log"
	"os"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

// ctxKey is the type used as key for storing and retrieving logger from context
type ctxKey struct{}

// Global logger instance
var BaseLogger Log

// Log is the interface for logging operations
type Log interface {
	FromCtx(ctx context.Context) Log
	WithCtx(ctx context.Context) context.Context
	WithFields(fields ...any) Log
	Debug(msg string, fields ...any)
	Info(msg string, fields ...any)
	Warn(msg string, fields ...any)
	Error(msg string, fields ...any)
	Panic(msg string, fields ...any)
	DPanic(msg string, fields ...any)
	Fatal(msg string, fields ...any)
}

// ZapLogger implements the Log interface using Zap
type ZapLogger struct {
	logger *zap.Logger
}

// Init initializes the global logger
func Init() {
	// Check if the logger is already initialized
	if BaseLogger != nil {
		BaseLogger.DPanic("Base Global Logger is already initialized")
		return
	}

	// Create a new zap logger
	logger := newZapLogger()
	BaseLogger = &ZapLogger{logger: logger}
}

// newZapLogger creates a new zap.Logger with appropriate configuration
func newZapLogger() *zap.Logger {
	// Configure stdout as the output
	stdout := zapcore.AddSync(os.Stdout)

	// Set default log level to INFO
	level := zap.InfoLevel

	// Get log level from environment variable if set
	levelEnv := os.Getenv("LOG_LEVEL")
	if levelEnv != "" {
		levelFromEnv, err := zapcore.ParseLevel(levelEnv)
		if err != nil {
			log.Println(
				fmt.Errorf("invalid level, defaulting to INFO: %w", err),
			)
		} else {
			level = levelFromEnv
		}
	}

	logLevel := zap.NewAtomicLevelAt(level)

	// Configure encoder based on environment
	var encoderConfig zapcore.EncoderConfig

	// Use different encoder configs for production and development
	if os.Getenv("APP_ENV") == "prod" {
		encoderConfig = zap.NewProductionEncoderConfig()
		encoderConfig.TimeKey = "timestamp"
		encoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
	} else {
		encoderConfig = zap.NewDevelopmentEncoderConfig()
		encoderConfig.EncodeLevel = zapcore.CapitalColorLevelEncoder
	}

	// Create encoder
	consoleEncoder := zapcore.NewConsoleEncoder(encoderConfig)

	// Create core and logger
	core := zapcore.NewCore(consoleEncoder, stdout, logLevel)
	return zap.New(core)
}

// FromCtx extracts a logger from context
func (l *ZapLogger) FromCtx(ctx context.Context) Log {
	// Check if the logger is already attached to the context
	if logger, ok := ctx.Value(ctxKey{}).(*ZapLogger); ok {
		return logger
	}

	// Return the base logger if none is found in context
	return l
}

// WithCtx adds the logger to context
func (l *ZapLogger) WithCtx(ctx context.Context) context.Context {
	// Check if the same logger is already in context
	if logger, ok := ctx.Value(ctxKey{}).(*ZapLogger); ok {
		if logger == l {
			// Don't store same logger instance
			return ctx
		}
	}

	// Attach the logger to context
	return context.WithValue(ctx, ctxKey{}, l)
}

// WithFields returns a new logger with additional fields
func (l *ZapLogger) WithFields(fields ...any) Log {
	// Add fields to the logger
	sugar := l.logger.Sugar().With(fields...)
	return &ZapLogger{logger: sugar.Desugar()}
}

// Debug logs a debug message with fields
func (l *ZapLogger) Debug(msg string, fields ...any) {
	l.logger.Sugar().Debugw(msg, fields...)
}

// Info logs an info message with fields
func (l *ZapLogger) Info(msg string, fields ...any) {
	l.logger.Sugar().Infow(msg, fields...)
}

// Warn logs a warning message with fields
func (l *ZapLogger) Warn(msg string, fields ...any) {
	l.logger.Sugar().Warnw(msg, fields...)
}

// Error logs an error message with fields
func (l *ZapLogger) Error(msg string, fields ...any) {
	l.logger.Sugar().Errorw(msg, fields...)
}

// Panic logs a message with fields and then panics
func (l *ZapLogger) Panic(msg string, fields ...any) {
	l.logger.Sugar().Panicw(msg, fields...)
}

// DPanic logs a message with fields and panics in development mode
func (l *ZapLogger) DPanic(msg string, fields ...any) {
	l.logger.Sugar().DPanicw(msg, fields...)
}

// Fatal logs a message with fields and then calls os.Exit(1)
func (l *ZapLogger) Fatal(msg string, fields ...any) {
	l.logger.Sugar().Fatalw(msg, fields...)
}
```


## Testing Approach

1. **Unit Tests**: Test individual components in isolation using mocks
2. **Integration Tests**: Test interaction between components
3. **End-to-End Tests**: Test complete flows through the system

## Notes

This template implements multiple delivery mechanisms (HTTP, gRPC, AMQP, NATS) demonstrating how the same business logic can be exposed through different interfaces while maintaining separation of concerns.
