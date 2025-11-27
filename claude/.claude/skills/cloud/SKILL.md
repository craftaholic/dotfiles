---
name: cloud-design
description: Design resilient, scalable multi-cloud architectures with best practices for AWS, Azure, and GCP. Use when creating cloud architecture diagrams, planning cloud infrastructure, or designing cloud migration strategies.
---

# Cloud Architecture Design

Principles and patterns for designing resilient, scalable cloud architectures across AWS, Azure, and GCP.

## When to Use

- Designing new cloud architectures
- Planning multi-cloud strategies
- Migrating workloads to the cloud
- Creating high-level architecture diagrams
- Evaluating cloud service selection

## Key Design Principles

### 1. Design for Failure

- **Region/Zone Redundancy**: Multi-AZ/zone deployments
- **Service Isolation**: Independent failure domains
- **Graceful Degradation**: Circuit breakers, fallbacks, timeouts
- **Self-Healing**: Auto-recovery, health checks, auto scaling
- **Disaster Recovery**: RPO/RTO-driven backup and recovery

### 2. Scalability Patterns

- **Horizontal Scaling**: Stateless services with auto-scaling
- **Vertical Partitioning**: Services by function
- **Horizontal Partitioning**: Sharding and data partitioning
- **Caching**: Multi-level caching strategy
- **Asynchronous Processing**: Event-driven, queue-based architectures

### 3. Security by Design

- **Defense in Depth**: Multiple security controls
- **Least Privilege**: Minimal required permissions
- **Zero Trust**: Assume breach mentality
- **Data Protection**: Encryption at rest and in transit
- **Immutable Infrastructure**: CI/CD with infrastructure as code

### 4. Cost Optimization

- **Right-sizing**: Match resources to workload
- **Elasticity**: Scale with demand
- **Reserved Capacity**: Predictable workloads
- **Spot/Preemptible**: Non-critical workloads
- **Serverless First**: Pay for execution, not idle

### 5. Operational Excellence

- **Monitoring**: Comprehensive metrics, logs, traces
- **Automation**: Self-service, infrastructure as code
- **Standardization**: Patterns, templates, naming
- **Documentation**: Architecture decisions, runbooks
- **Observability**: Business and technical insights

## Multi-Cloud Design Patterns

### Service Equivalents Map

| Pattern | AWS | Azure | GCP |
|---------|-----|-------|-----|
| **Compute** | EC2, Lambda | VM, Functions | Compute Engine, Functions |
| **Container** | ECS, EKS | AKS, Container Apps | GKE, Cloud Run |
| **Serverless** | Lambda, Step Functions | Functions, Logic Apps | Functions, Workflows |
| **Storage** | S3, EFS | Blob, Files | GCS, Filestore |
| **Database** | RDS, DynamoDB | SQL, Cosmos DB | Cloud SQL, Firestore |
| **Networking** | VPC, Route53 | VNET, DNS | VPC, Cloud DNS |
| **CDN** | CloudFront | Front Door | Cloud CDN |
| **API Gateway** | API Gateway | API Management | Apigee, API Gateway |

### Multi-Cloud Strategies

1. **Cloud-Agnostic**
   - Abstract cloud services behind interfaces
   - Use common tools and patterns (Kubernetes, Terraform)
   - Focus on portability over cloud-specific features

2. **Best-of-Breed**
   - Select optimal services from each provider
   - Accept higher integration complexity
   - Optimize for feature richness and innovation

3. **Primary-Secondary**
   - Main provider for most workloads
   - Secondary for specific use cases or DR
   - Balance between optimization and complexity

4. **Cloud-Specific**
   - Embrace native services for each workload
   - Optimize for cloud provider strengths
   - Accept potential lock-in for better performance

## Architecture Archetypes

### Web Application

```
[Users] → [CDN] → [Load Balancer] → [Web Tier] → [API Tier] → [Database]
                    ↑                   ↑             ↑           ↑
                    └───────[Caching Layer]───────────┘           |
                                                                  |
                   [Authentication] → [Identity Provider]          |
                                                                  |
                   [Monitoring] → [Logging] → [Alerting]          |
                        ↑                                         |
                        └─────────────────────────────────────────┘
```

### Event-Driven Microservices

```
[Event Source] → [Event Hub/Queue] → [Processing Service] → [Database/Storage]
                        ↓                     |                    ↑
                [Event Store] ← [Event Sink] ←┘                    |
                        ↓                                          |
                [Analytics]                                        |
                                                                  |
                [Monitoring] → [Tracing] → [Logging]               |
                     ↑                                             |
                     └───────────────────────────────────────────┘
```

### Data Processing Pipeline

```
[Data Sources] → [Ingestion] → [Storage] → [Processing] → [Serving]
                     ↓            ↓            ↓             ↓
                  [Monitoring] [Governance] [Orchestration] [Security]
```

## Provider-Specific Best Practices

### AWS
- Use multi-AZ deployments with auto-scaling groups
- Implement VPC flow logs and GuardDuty for security
- Use IAM roles for service-to-service communication
- Leverage S3 lifecycle policies for cost management
- Implement AWS Well-Architected Framework principles

### Azure
- Deploy across availability zones with VMSS
- Use Azure Security Center and Sentinel
- Implement managed identities for service authentication
- Use Azure Reserved Instances for predictable workloads
- Follow Azure Well-Architected Framework guidelines

### GCP
- Design for regional deployments with global load balancing
- Implement VPC Service Controls and Security Command Center
- Use Workload Identity for service-to-service authentication
- Leverage committed use discounts for predictable workloads
- Follow Google Cloud Architecture Framework principles

## Additional Resources
- Cloud provider well-architected frameworks
- Reference architectures for common patterns
- Migration tools and methodologies
- Architecture decision record templates
