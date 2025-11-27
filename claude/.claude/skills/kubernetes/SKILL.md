---
name: k8s-architecture
description: Design and implement production-grade Kubernetes clusters with best practices for reliability, security, and scalability. Use when planning cluster architecture, designing K8s network models, or implementing multi-cluster strategies.
---

# Kubernetes Architecture

Principles and patterns for designing production-ready Kubernetes environments.

## When to Use

- Designing new Kubernetes deployments
- Planning cluster topology and network architecture
- Implementing multi-cluster strategies
- Evaluating Kubernetes distribution options
- Migrating workloads to Kubernetes

## Cluster Architecture Patterns

### Single Cluster / Multi-Environment

```
Single Kubernetes Cluster
├── Namespace: production
│   ├── Network Policy
│   ├── Resource Quotas
│   ├── RBAC: Production Team
│   └── Workloads with high QoS
├── Namespace: staging
│   ├── Network Policy
│   ├── Resource Quotas
│   ├── RBAC: Dev Teams
│   └── Workloads with medium QoS
└── Namespace: development
    ├── Network Policy
    ├── Resource Quotas
    ├── RBAC: Dev Teams
    └── Workloads with low QoS
```

**Best for:**
- Small to medium-sized teams
- Limited operational resources
- Starting Kubernetes journey
- Testing/development with moderate isolation needs

### Environment-Based Clusters

```
Production Cluster          Staging Cluster           Development Cluster
├── Stringent Security      ├── Standard Security     ├── Relaxed Security
├── High Reliability        ├── Medium Reliability    ├── Basic Reliability
├── Production Workloads    ├── Pre-production Tests  ├── Development Work
├── Limited Access          ├── Team Access           └── Developer Access
└── Strict Change Control   └── Managed Changes
```

**Best for:**
- Strict isolation requirements
- Different security/compliance needs per environment
- Separate upgrade cycles
- Independent scalability requirements

### Multi-Region / Multi-Cloud

```
Primary Region (AWS)         Secondary Region (Azure)
├── Production Cluster       ├── DR Cluster
│   ├── Active Workloads     │   ├── Passive/Active Workloads
│   ├── Primary Data         │   ├── Replicated Data
│   └── Full Traffic         │   └── Failover Traffic
├── Staging Cluster          └── Limited Staging
└── Development Cluster
```

**Best for:**
- High availability requirements
- Geographic distribution needs
- Regulatory/compliance requirements
- Disaster recovery objectives
- Cloud provider redundancy

## Node Architecture Patterns

### Dedicated Node Pools

```
Kubernetes Cluster
├── System Node Pool (Small VMs)
│   └── System Components (CoreDNS, Metrics, etc.)
├── General Purpose Pool (Medium VMs)
│   └── Stateless Applications
├── Memory-Optimized Pool (High Memory VMs)
│   └── In-Memory Databases, Caches
├── Compute-Optimized Pool (High CPU VMs)
│   └── Batch Processing, ML Workloads
└── Storage-Optimized Pool (High Disk I/O VMs)
    └── Databases, Storage Systems
```

**Best for:**
- Mixed workload characteristics
- Cost optimization
- Performance isolation
- Specialized hardware requirements

### Node Placement Strategy

```
Kubernetes Workloads
├── Node Affinity/Anti-Affinity
│   └── Place workloads on specific nodes
├── Pod Affinity/Anti-Affinity
│   └── Control pod-to-pod placement
├── Taints and Tolerations
│   └── Restrict which pods run on nodes
└── Topology Spread Constraints
    └── Distribute pods across failure domains
```

**Implementation:**
```yaml
# Node affinity example
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: node-type
          operator: In
          values:
          - memory-optimized
```

## Networking Models

### Cluster Networking

| Component | Options | Best For |
|-----------|---------|----------|
| **CNI** | Calico, Cilium, Flannel | Security policies, performance, simplicity |
| **Service Mesh** | Istio, Linkerd, Consul | Advanced traffic, security, observability |
| **Ingress** | Nginx, Contour, Traefik | HTTP routing, TLS termination, path-based rules |
| **Load Balancing** | MetalLB, Cloud LBs | External traffic distribution |
| **DNS** | CoreDNS, External DNS | Service discovery, external DNS integration |

### Network Security Pattern

```
                      ┌─────────────────────────────────────┐
                      │ Network Policy: default-deny-all    │
                      └─────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────┐      ┌─────────────────────┐      ┌─────────────────────┐
│ Namespace: frontend │      │ Namespace: backend  │      │ Namespace: database │
│ ┌─────────────────┐ │      │ ┌─────────────────┐ │      │ ┌─────────────────┐ │
│ │ Allow ingress   │◄┼──────┼─┤ Allow frontend  │ │      │ │ Allow backend   │ │
│ │ from Internet   │ │      │ │ namespace       │◄┼──────┼─┤ namespace       │ │
│ └─────────────────┘ │      │ └─────────────────┘ │      │ └─────────────────┘ │
│ ┌─────────────────┐ │      │ ┌─────────────────┐ │      │ ┌─────────────────┐ │
│ │ Allow egress to │ │      │ │ Allow egress to │ │      │ │ Deny all other  │ │
│ │ backend only    │─┼─────►│ │ database only   │─┼─────►│ │ traffic         │ │
│ └─────────────────┘ │      │ └─────────────────┘ │      │ └─────────────────┘ │
└─────────────────────┘      └─────────────────────┘      └─────────────────────┘
```

## Control Plane Patterns

### Highly Available Control Plane

```
┌───────────────────────────────────────────────────────────┐
│ Control Plane - Multi-AZ/Multi-Zone                       │
│ ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│ │ AZ 1        │  │ AZ 2        │  │ AZ 3        │         │
│ │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │         │
│ │ │API Server│ │  │ │API Server│ │  │ │API Server│ │         │
│ │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │         │
│ │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │         │
│ │ │Controller│ │  │ │Controller│ │  │ │Controller│ │         │
│ │ │Manager   │ │  │ │Manager   │ │  │ │Manager   │ │         │
│ │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │         │
│ │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌─────────┐ │         │
│ │ │Scheduler │ │  │ │Scheduler │ │  │ │Scheduler │ │         │
│ │ └─────────┘ │  │ └─────────┘ │  │ └─────────┘ │         │
│ └─────────────┘  └─────────────┘  └─────────────┘         │
└───────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│ Distributed etcd                                            │
│ ┌─────────┐            ┌─────────┐            ┌─────────┐   │
│ │ etcd 1  │◄──────────►│ etcd 2  │◄──────────►│ etcd 3  │   │
│ │ (AZ 1)  │            │ (AZ 2)  │            │ (AZ 3)  │   │
│ └─────────┘            └─────────┘            └─────────┘   │
└───────────────────────────────────────────────────────────────┘
```

**Key recommendations:**
- Control plane components in each AZ/Zone
- Odd number of etcd instances (3, 5, 7) across zones
- Node auto-repair and auto-upgrade
- Separate system workloads from user workloads
- Control plane scaling for large clusters (>100 nodes)

## Storage Architecture

### Storage Class Strategy

```yaml
# Performance-optimized
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: performance
provisioner: kubernetes.io/aws-ebs
parameters:
  type: io1
  iopsPerGB: "50"
  fsType: ext4
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
---
# Cost-optimized
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
  fsType: ext4
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

**Best practices:**
- Use `WaitForFirstConsumer` binding mode
- Create purpose-specific storage classes
- Enable volume expansion
- Configure appropriate reclaim policies
- Implement backup solutions

## Multi-Cluster Management

### Federation Pattern

```
┌───────────────────────────────────┐
│ Management Cluster                │
│ ┌───────────────────────────────┐ │
│ │ Cluster API                   │ │
│ │ ┌─────────┐ ┌─────────┐      │ │
│ │ │Providers│ │Templates│      │ │
│ │ └─────────┘ └─────────┘      │ │
│ └───────────────────────────────┘ │
│ ┌───────────────────────────────┐ │
│ │ Fleet Management             │ │
│ │ ┌─────────┐ ┌─────────┐      │ │
│ │ │Config   │ │Workload │      │ │
│ │ │Sync     │ │Placement│      │ │
│ │ └─────────┘ └─────────┘      │ │
│ └───────────────────────────────┘ │
└───────────────────────────────────┘
            │         │         │
      ┌─────▼─┐  ┌────▼──┐  ┌───▼───┐
      │Cluster│  │Cluster│  │Cluster│
      │  1    │  │  2    │  │  3    │
      └───────┘  └───────┘  └───────┘
```

**Implementation options:**
- Cluster API for provisioning
- Fleet management (Config Sync, Karmada, KubeFed)
- Service mesh federation (Istio multi-cluster)
- GitOps for configuration management

## Managed vs Self-Managed Decision Matrix

| Factor | Managed K8s | Self-Managed K8s |
|--------|------------|-----------------|
| **Control Plane Management** | Provider-managed | Team responsibility |
| **Upgrade Control** | Limited scheduling | Full control |
| **Feature Availability** | Provider-dependent | Full access |
| **Infrastructure Integration** | Pre-integrated | Custom integration |
| **Cost Model** | Control plane fee + nodes | Node costs only |
| **Operational Overhead** | Lower | Higher |
| **Support** | Provider support | Internal/community |

## Production Readiness Checklist

- [ ] High availability control plane
- [ ] Node auto-scaling configuration
- [ ] Pod disruption budgets for critical services
- [ ] Resource requests/limits for all workloads
- [ ] Network policies defined for all namespaces
- [ ] Ingress with TLS configuration
- [ ] RBAC with least privilege
- [ ] Monitoring and alerting
- [ ] Logging and audit trail
- [ ] Backup and disaster recovery
- [ ] Upgrade strategy
- [ ] Security scanning and policy enforcement