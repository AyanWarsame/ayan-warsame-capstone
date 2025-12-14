# 🔧 Troubleshooting Connection Issues

## Flask Backend Connection Issues

### ✅ Current Configuration

Your Flask app is correctly configured:
```python
app.run(host='0.0.0.0', port=5000, debug=True)
```

The `host='0.0.0.0'` makes the server accessible from outside the container.

### Common Issues & Solutions

#### 1. **Port Already in Use**

**Error**: `Bind for 0.0.0.0:5000 failed: port is already allocated`

**Solution**:
```bash
# Find what's using port 5000
# Windows
netstat -ano | findstr :5000

# Mac/Linux
lsof -i :5000

# Stop the process or change port in docker-compose.yml
# Change "5000:5000" to "5001:5000" and access via http://localhost:5001
```

#### 2. **Container Not Running**

**Check**:
```bash
docker-compose ps
```

**Solution**:
```bash
# Start containers
docker-compose up -d

# Check logs
docker-compose logs backend
```

#### 3. **Firewall Blocking**

**Windows**:
- Check Windows Firewall settings
- Allow port 5000 through firewall

**Solution**:
```bash
# Windows PowerShell (as Administrator)
New-NetFirewallRule -DisplayName "Flask App" -Direction Inbound -LocalPort 5000 -Protocol TCP -Action Allow
```

#### 4. **Frontend Can't Reach Backend**

**Check Nginx proxy configuration**:
- Verify `frontend/nginx.conf` has correct proxy settings
- Backend service name should be `backend-service` in Kubernetes
- In docker-compose, use `backend` (service name)

**Test backend directly**:
```bash
# From host machine
curl http://localhost:5000/health

# From frontend container
docker-compose exec frontend wget -O- http://backend:5000/health
```

#### 5. **Database Connection Issues**

**Error**: `Database connection failed`

**Solution**:
```bash
# Check if database file exists
ls -la backend/appointments.db

# Check file permissions
chmod 666 backend/appointments.db

# Check backend logs
docker-compose logs backend
```

#### 6. **CORS Issues (Browser Console Errors)**

If frontend can't call backend API:

**Check**:
- Browser console for CORS errors
- Network tab in DevTools

**Solution**: Nginx proxy should handle this, but verify:
```nginx
# In nginx.conf
location /api/ {
    proxy_pass http://backend-service:5000/;
    # CORS headers should be set
}
```

## Testing Connections

### 1. Test Backend Health

```bash
# From host
curl http://localhost:5000/health

# Expected response:
# {"status":"healthy","service":"backend","database":"connected"}
```

### 2. Test Frontend Health

```bash
# From host
curl http://localhost/health

# Expected response:
# {"status":"healthy","service":"frontend"}
```

### 3. Test API Endpoint

```bash
# Get appointments
curl http://localhost:5000/appointments?format=json

# Or through frontend proxy
curl http://localhost/api/appointments?format=json
```

### 4. Test from Inside Containers

```bash
# Test backend from frontend container
docker-compose exec frontend wget -O- http://backend:5000/health

# Test backend from backend container
docker-compose exec backend curl http://localhost:5000/health
```

## Network Debugging

### Check Container Network

```bash
# List networks
docker network ls

# Inspect network
docker network inspect ayan-warsame-capstone_default

# Check container IPs
docker-compose ps
docker inspect appointment-backend | grep IPAddress
docker inspect appointment-frontend | grep IPAddress
```

### Check Port Mappings

```bash
# Verify ports are mapped correctly
docker-compose ps

# Should show:
# appointment-backend   0.0.0.0:5000->5000/tcp
# appointment-frontend  0.0.0.0:80->80/tcp
```

## Common Docker Issues

### Container Won't Start

```bash
# Check logs
docker-compose logs backend
docker-compose logs frontend

# Restart containers
docker-compose restart

# Rebuild if needed
docker-compose up --build
```

### Permission Issues

```bash
# Fix database file permissions
chmod 666 backend/appointments.db

# Or remove and let it recreate
rm backend/appointments.db
docker-compose restart backend
```

## Quick Diagnostic Commands

```bash
# Full system check
echo "=== Containers ==="
docker-compose ps

echo "=== Backend Health ==="
curl http://localhost:5000/health

echo "=== Frontend Health ==="
curl http://localhost/health

echo "=== Backend Logs ==="
docker-compose logs --tail=20 backend

echo "=== Frontend Logs ==="
docker-compose logs --tail=20 frontend

echo "=== Network ==="
docker network inspect ayan-warsame-capstone_default
```

## Still Having Issues?

1. **Check all logs**:
   ```bash
   docker-compose logs
   ```

2. **Verify configuration files**:
   - `docker-compose.yml` - port mappings
   - `frontend/nginx.conf` - proxy settings
   - `backend/app.py` - host binding

3. **Restart everything**:
   ```bash
   docker-compose down
   docker-compose up --build
   ```

4. **Check browser console**:
   - Open DevTools (F12)
   - Check Console and Network tabs
   - Look for errors

