# Access Guide - Ayan Warsame Application

## Problem Fixed

The ingress was configured with a catch-all fallback rule that conflicted with other namespaces' ingresses. This has been removed. Your ingress now **only** responds to requests with the specific hostname.

## How to Access Your Application

### Option 1: Add to /etc/hosts (Recommended)

1. Get the ELB IP address:
   ```bash
   nslookup a34fc6306ef174b7da4448774a97fe5a-c127de64f9bef2fd.elb.eu-west-1.amazonaws.com
   ```

2. Add to `/etc/hosts` (Linux/Mac) or `C:\Windows\System32\drivers\etc\hosts` (Windows):
   ```
   <ELB_IP> ayan-warsame.capstone.company.com
   ```

3. Access in browser:
   ```
   http://ayan-warsame.capstone.company.com
   ```

### Option 2: Use Host Header with curl

```bash
curl -H "Host: ayan-warsame.capstone.company.com" \
     http://a34fc6306ef174b7da4448774a97fe5a-c127de64f9bef2fd.elb.eu-west-1.amazonaws.com
```

### Option 3: Use Browser Extension

Install a browser extension like "ModHeader" to add the Host header:
- Header: `Host`
- Value: `ayan-warsame.capstone.company.com`
- URL: `http://a34fc6306ef174b7da4448774a97fe5a-c127de64f9bef2fd.elb.eu-west-1.amazonaws.com`

## Why This Happened

The cluster has multiple namespaces sharing the same ELB:
- `ayan-warsame` - Your application
- `ian-malavi-mhambe` - Ian's application (Caresync)
- `tom-wakhungu` - Tom's application
- `bench-system` - Bench system

When accessing the ELB directly without a Host header, the ingress controller routes based on:
1. Hostname matching (specific hosts first)
2. Catch-all rules (`*` or no host)

Tom's ingress has a catch-all (`host: *`), which was catching requests without proper hostnames.

## Solution Applied

✅ Removed the catch-all fallback rule from your ingress
✅ Your ingress now **only** responds to: `ayan-warsame.capstone.company.com`

## Verification

Test that you're accessing your application:

```bash
# Should return your frontend health check
curl -H "Host: ayan-warsame.capstone.company.com" \
     http://a34fc6306ef174b7da4448774a97fe5a-c127de64f9bef2fd.elb.eu-west-1.amazonaws.com/health

# Expected response:
# {"status":"healthy","service":"frontend"}
```

If you see Ian's login page, you're not using the correct hostname. Make sure to:
1. Add the hostname to `/etc/hosts`, OR
2. Use the Host header in your requests

## Quick Fix Script

```bash
#!/bin/bash
# Get ELB IP
ELB_IP=$(nslookup a34fc6306ef174b7da4448774a97fe5a-c127de64f9bef2fd.elb.eu-west-1.amazonaws.com | grep "Address:" | tail -1 | awk '{print $2}')

# Add to /etc/hosts (requires sudo)
echo "$ELB_IP ayan-warsame.capstone.company.com" | sudo tee -a /etc/hosts

echo "Added to /etc/hosts. Now access: http://ayan-warsame.capstone.company.com"
```

