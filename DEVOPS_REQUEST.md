# Request to DevOps Team: Remove Catch-All Ingress Rule

## Issue

In the shared EKS cluster, there is a catch-all Ingress rule in the `tom-wakhungu` namespace that is intercepting traffic intended for other namespaces.

## Problem Details

**Catch-All Ingress Found:**
- **Namespace**: `tom-wakhungu`
- **Ingress Name**: `medicine-inventory-ingress`
- **Hostname**: `*` (wildcard/catch-all)
- **Impact**: This ingress catches all requests without a specific hostname, causing traffic intended for other namespaces to be routed incorrectly.

## Current Situation

When accessing the shared ELB directly (without a Host header), requests are being routed to Tom's application instead of the intended namespace applications. This affects:
- Direct ELB access without proper hostname
- Requests without Host header
- Testing and development workflows

## Request

Could you please either:

1. **Remove the catch-all rule** from `tom-wakhungu/medicine-inventory-ingress` and replace it with a specific hostname (e.g., `tom-wakhungu.capstone.company.com`), OR

2. **Restrict the catch-all rule** to only match specific paths or add namespace isolation, OR

3. **Set up proper DNS** for all namespaces so each application has its own hostname and catch-all rules are not needed

## Recommended Solution

Each namespace should have its own specific hostname:
- `ayan-warsame.capstone.company.com` → ayan-warsame namespace
- `tom-wakhungu.capstone.company.com` → tom-wakhungu namespace
- `ian-malavi-mhambe.capstone.company.com` → ian-malavi-mhambe namespace

This ensures proper traffic isolation and prevents namespace hijacking.

## Verification

You can verify catch-all ingresses with:
```bash
kubectl get ingress -A -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,HOSTS:.spec.rules[*].host
```

Any ingress with empty HOSTS or `*` is a catch-all.

## Contact

If you need any additional information or have questions, please let me know.

Thank you for your assistance!

---

**From**: Ayan Warsame  
**Namespace**: `ayan-warsame`  
**Date**: $(date +%Y-%m-%d)

