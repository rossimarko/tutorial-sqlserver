# Docker Setup for SQL Server 2022

Complete Docker environment for practicing SQL Server DBA skills.

---

## Quick Start

```bash
# Start SQL Server 2022
cd docker-setup
docker-compose up -d

# Check status
docker-compose ps

# Connect using:
# Server: localhost,1433
# User: sa
# Password: YourStrong@Passw0rd
```

---

## What's Included

- ✅ SQL Server 2022 Developer Edition
- ✅ 4 GB RAM allocated
- ✅ SQL Agent enabled
- ✅ Persistent volume for data
- ✅ Sample databases pre-loaded
- ✅ Ready for practice

---

## Files

- `docker-compose.yml` - Docker Compose configuration
- `init-db.sql` - Initial database setup script
- `Dockerfile` - Custom SQL Server image (optional)

---

## Usage

### Start Environment
```bash
docker-compose up -d
```

### Stop Environment
```bash
docker-compose down
```

### View Logs
```bash
docker-compose logs -f
```

### Reset Environment (Delete All Data)
```bash
docker-compose down -v
docker volume prune
docker-compose up -d
```

### Connect with sqlcmd
```bash
docker exec -it sqlserver2022 /opt/mssql-tools/bin/sqlcmd \
    -S localhost -U sa -P 'YourStrong@Passw0rd'
```

---

## System Requirements

- Docker Desktop installed
- 4 GB RAM available
- 10 GB disk space
- Windows, Mac, or Linux

---

## Connecting from SSMS

**Server Name:** `localhost,1433`  
**Authentication:** SQL Server Authentication  
**Login:** `sa`  
**Password:** `YourStrong@Passw0rd`

---

## Troubleshooting

**Container won't start:**
```bash
# Check logs
docker logs sqlserver2022

# Common issue: Port 1433 already in use
# Stop local SQL Server instance or change port in docker-compose.yml
```

**Connection refused:**
- Wait 30 seconds after starting (SQL Server takes time to initialize)
- Check firewall settings
- Verify password meets complexity requirements

**Performance issues:**
- Increase memory allocation in docker-compose.yml
- Close other applications
- Check Docker Desktop resource settings

---

## Advanced Configuration

### Change Port
Edit `docker-compose.yml`:
```yaml
ports:
  - "1434:1433"  # Use port 1434 instead
```

### Increase Memory
Edit `docker-compose.yml`:
```yaml
environment:
  - MSSQL_MEMORY_LIMIT_MB=8192  # 8 GB
```

### Mount Custom Scripts
Edit `docker-compose.yml`:
```yaml
volumes:
  - ./scripts:/scripts
```

---

## Security Notes

**⚠️ This setup is for LEARNING ONLY**

- Default password is weak (change for any real use)
- SA account is enabled (disable in production)
- No encryption configured
- No network isolation

**DO NOT use this configuration for production!**
