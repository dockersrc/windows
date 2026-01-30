## 👋 Welcome to windows 🚀  

Windows Server Core Container for running Windows applications in Docker.

⚠️ **IMPORTANT**: This container requires a Windows host to build and run. It will NOT work on Linux or macOS.
  
## Requirements

- Windows Server 2022 or Windows 10/11 Pro with containers feature enabled
- Docker Desktop for Windows (with Windows containers enabled)
- At least 10GB free disk space for the image

## Install and run container
  
```powershell
# Create directories
$dockerHome = "C:\docker\casjaysdevdocker\windows"
New-Item -ItemType Directory -Force -Path "$dockerHome\data", "$dockerHome\config"

# Run container
docker run -d `
  --restart always `
  --name casjaysdevdocker-windows-latest `
  --hostname windows `
  -e TIMEZONE="Eastern Standard Time" `
  -v "$dockerHome\data:C:\data" `
  -v "$dockerHome\config:C:\config" `
  -p 80:80 `
  casjaysdevdocker/windows:latest
```
  
## via docker-compose  
  
```yaml
version: "3.8"
services:
  windows:
    image: casjaysdevdocker/windows:latest
    container_name: casjaysdevdocker-windows
    environment:
      - TIMEZONE=Eastern Standard Time
      - HOSTNAME=windows
    volumes:
      - "C:/docker/casjaysdevdocker/windows/data:C:/data"
      - "C:/docker/casjaysdevdocker/windows/config:C:/config"
    ports:
      - "80:80"
    restart: always
```
  
## Get source files  
  
```powershell
git clone "https://github.com/casjaysdevdocker/windows" "$env:USERPROFILE\Projects\casjaysdevdocker\windows"
```
  
## Build container  

⚠️ **Must be built on Windows with Docker Desktop in Windows containers mode**

```powershell
cd "$env:USERPROFILE\Projects\casjaysdevdocker\windows"
docker build -t casjaysdevdocker/windows:latest .
```

## Package Management

This container uses **winget** (Windows Package Manager) or **chocolatey** as fallback. To install packages:

```powershell
# Via pkmgr wrapper (recommended)
docker exec casjaysdevdocker-windows-latest powershell "C:/Windows/System32/pkmgr.ps1 install git.git"
docker exec casjaysdevdocker-windows-latest powershell "C:/Windows/System32/pkmgr.ps1 install nodejs"

# Direct via winget
docker exec casjaysdevdocker-windows-latest powershell "winget install git.git"
```

## Container Structure

```
C:/
├── ProgramData/
│   ├── Docker/setup/          - Setup scripts (00-init.ps1 to 07-cleanup.ps1)
│   └── template-files/        - Configuration templates
├── Windows/System32/
│   ├── entrypoint.ps1         - Container entrypoint
│   ├── pkmgr.ps1              - Package manager wrapper
│   └── pkmgr                  - Shell script version
├── Users/Administrator/       - User home directory
├── config/                    - Configuration volume mount
└── data/                      - Data volume mount
```

## Environment Variables

- `TIMEZONE` - Windows timezone (default: "Eastern Standard Time")
- `HOSTNAME` - Container hostname
- `LANG` - Language setting (default: "en-US")
- `SERVICE_PORT` - Primary service port
- `ENV_PORTS` - Additional exposed ports
  
## Authors  
  
🤖 casjay: [Github](https://github.com/casjay) 🤖  
⛵ casjaysdevdocker: [Github](https://github.com/casjaysdevdocker) [Docker](https://hub.docker.com/u/casjaysdevdocker) ⛵  
