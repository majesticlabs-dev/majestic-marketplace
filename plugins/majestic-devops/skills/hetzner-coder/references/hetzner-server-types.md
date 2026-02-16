# Hetzner Cloud Server Types

## Shared CPU (CX - Best for general workloads)

| Type | vCPUs | RAM | Storage | Best For |
|------|-------|-----|---------|----------|
| `cx22` | 2 | 4 GB | 40 GB | Small apps |
| `cx32` | 4 | 8 GB | 80 GB | Medium apps |
| `cx42` | 8 | 16 GB | 160 GB | Production |
| `cx52` | 16 | 32 GB | 320 GB | High traffic |

## AMD EPYC (CPX - Better single-thread)

| Type | vCPUs | RAM | Storage |
|------|-------|-----|---------|
| `cpx11` | 2 | 2 GB | 40 GB |
| `cpx21` | 3 | 4 GB | 80 GB |
| `cpx31` | 4 | 8 GB | 160 GB |
| `cpx41` | 8 | 16 GB | 240 GB |
| `cpx51` | 16 | 32 GB | 360 GB |

## ARM64 (CAX - Best price/performance)

| Type | vCPUs | RAM | Storage |
|------|-------|-----|---------|
| `cax11` | 2 | 4 GB | 40 GB |
| `cax21` | 4 | 8 GB | 80 GB |
| `cax31` | 8 | 16 GB | 160 GB |
| `cax41` | 16 | 32 GB | 320 GB |

## Dedicated vCPU (CCX - Guaranteed resources)

| Type | vCPUs | RAM | Storage |
|------|-------|-----|---------|
| `ccx13` | 2 | 8 GB | 80 GB |
| `ccx23` | 4 | 16 GB | 160 GB |
| `ccx33` | 8 | 32 GB | 240 GB |
| `ccx43` | 16 | 64 GB | 360 GB |

## Selection Guide

- **CX**: Default choice for web apps, APIs
- **CPX**: Single-threaded workloads (Rails, Node)
- **CAX**: Best value, ARM-compatible workloads (Docker, Go, Rust)
- **CCX**: Databases, CI/CD runners, latency-sensitive apps
