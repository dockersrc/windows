# Docker image for windows using Windows Server Core
ARG IMAGE_NAME="windows"
ARG PHP_SERVER="windows"
ARG BUILD_DATE="202601231310"
ARG LANGUAGE="en-US"
ARG TIMEZONE="Eastern Standard Time"
ARG WWW_ROOT_DIR="C:/inetpub/wwwroot"
ARG DEFAULT_FILE_DIR="C:/ProgramData/template-files"
ARG DEFAULT_DATA_DIR="C:/ProgramData/template-files/data"
ARG DEFAULT_CONF_DIR="C:/ProgramData/template-files/config"
ARG DEFAULT_TEMPLATE_DIR="C:/ProgramData/template-files/defaults"

ARG USER="Administrator"
ARG SHELL_OPTS=""

ARG SERVICE_PORT=""
ARG EXPOSE_PORTS=""
ARG PHP_VERSION="system"
ARG NODE_VERSION="system"
ARG NODE_MANAGER="system"

ARG IMAGE_REPO="casjaysdevdocker/windows"
ARG IMAGE_VERSION="ltsc2022"
ARG CONTAINER_VERSION=""

ARG PULL_URL="mcr.microsoft.com/windows/servercore"
ARG DISTRO_VERSION="${IMAGE_VERSION}"
ARG BUILD_VERSION="${BUILD_DATE}"

FROM ${PULL_URL}:${DISTRO_VERSION} AS build
ARG TZ
ARG USER
ARG LICENSE
ARG TIMEZONE
ARG LANGUAGE
ARG IMAGE_NAME
ARG BUILD_DATE
ARG SERVICE_PORT
ARG EXPOSE_PORTS
ARG BUILD_VERSION
ARG IMAGE_VERSION
ARG WWW_ROOT_DIR
ARG DEFAULT_FILE_DIR
ARG DEFAULT_DATA_DIR
ARG DEFAULT_CONF_DIR
ARG DEFAULT_TEMPLATE_DIR
ARG DISTRO_VERSION
ARG NODE_VERSION
ARG NODE_MANAGER
ARG PHP_VERSION
ARG PHP_SERVER
ARG SHELL_OPTS
ARG PATH

ARG PACK_LIST=" "

ENV TIMEZONE="${TIMEZONE}"
ENV LANG="${LANGUAGE}"
ENV HOSTNAME="casjaysdevdocker-windows"

USER ${USER}
WORKDIR C:/Users/Administrator

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY ./rootfs/. C:/

RUN Write-Host 'Setting up prerequisites'; \
    New-Item -ItemType Directory -Force -Path $env:DEFAULT_DATA_DIR, $env:DEFAULT_CONF_DIR, $env:DEFAULT_TEMPLATE_DIR, 'C:/ProgramData/Docker/setup' | Out-Null

RUN Write-Host 'Initializing the system'; \
    if (Test-Path 'C:/ProgramData/Docker/setup/00-init.ps1') { \
        Write-Host 'Running the init script'; \
        & 'C:/ProgramData/Docker/setup/00-init.ps1'; \
        if ($LASTEXITCODE -ne 0) { Write-Error 'Failed to execute 00-init.ps1'; exit 10 }; \
        Write-Host 'Done running the init script'; \
    }

RUN Write-Host 'Creating and editing system files'; \
    if (Test-Path 'C:/ProgramData/Docker/setup/01-system.ps1') { \
        Write-Host 'Running the system script'; \
        & 'C:/ProgramData/Docker/setup/01-system.ps1'; \
        if ($LASTEXITCODE -ne 0) { Write-Error 'Failed to execute 01-system.ps1'; exit 10 }; \
        Write-Host 'Done running the system script'; \
    }

RUN Write-Host 'Running pre-package commands'

RUN Write-Host 'Setting up and installing packages'; \
    if ($env:PACK_LIST -and $env:PACK_LIST.Trim() -ne '') { \
        Write-Host "Installing packages: $env:PACK_LIST"; \
        $env:PACK_LIST | Out-File -FilePath 'C:/ProgramData/Docker/setup/packages.txt' -Encoding UTF8; \
        & 'C:/Windows/System32/pkmgr.ps1' install $env:PACK_LIST.Split(' '); \
    }

RUN Write-Host 'Initializing packages before copying files to image'; \
    if (Test-Path 'C:/ProgramData/Docker/setup/02-packages.ps1') { \
        Write-Host 'Running the packages script'; \
        & 'C:/ProgramData/Docker/setup/02-packages.ps1'; \
        if ($LASTEXITCODE -ne 0) { Write-Error 'Failed to execute 02-packages.ps1'; exit 10 }; \
        Write-Host 'Done running the packages script'; \
    }

COPY ./Dockerfile C:/ProgramData/Docker/Dockerfile

RUN Write-Host 'Updating system files'; \
    if (Test-Path 'C:/ProgramData/Docker/setup/03-files.ps1') { \
        Write-Host 'Running the files script'; \
        & 'C:/ProgramData/Docker/setup/03-files.ps1'; \
        if ($LASTEXITCODE -ne 0) { Write-Error 'Failed to execute 03-files.ps1'; exit 10 }; \
        Write-Host 'Done running the files script'; \
    }

RUN Write-Host 'Custom Settings'

RUN Write-Host 'Setting up users and scripts'; \
    if (Test-Path 'C:/ProgramData/Docker/setup/04-users.ps1') { \
        Write-Host 'Running the users script'; \
        & 'C:/ProgramData/Docker/setup/04-users.ps1'; \
        if ($LASTEXITCODE -ne 0) { Write-Error 'Failed to execute 04-users.ps1'; exit 10 }; \
        Write-Host 'Done running the users script'; \
    }

RUN Write-Host 'Running the user init commands'

RUN Write-Host 'Setting OS Settings'

RUN Write-Host 'Custom Applications'

RUN Write-Host 'Running custom commands'; \
    if (Test-Path 'C:/ProgramData/Docker/setup/05-custom.ps1') { \
        Write-Host 'Running the custom script'; \
        & 'C:/ProgramData/Docker/setup/05-custom.ps1'; \
        if ($LASTEXITCODE -ne 0) { Write-Error 'Failed to execute 05-custom.ps1'; exit 10 }; \
        Write-Host 'Done running the custom script'; \
    }

RUN Write-Host 'Running final commands before cleanup'; \
    if (Test-Path 'C:/ProgramData/Docker/setup/06-post.ps1') { \
        Write-Host 'Running the post script'; \
        & 'C:/ProgramData/Docker/setup/06-post.ps1'; \
        if ($LASTEXITCODE -ne 0) { Write-Error 'Failed to execute 06-post.ps1'; exit 10 }; \
        Write-Host 'Done running the post script'; \
    }

RUN Write-Host 'Deleting unneeded files'; \
    & 'C:/Windows/System32/pkmgr.ps1' clean; \
    Remove-Item -Path 'C:/config', 'C:/data' -Recurse -Force -ErrorAction SilentlyContinue; \
    if (Test-Path 'C:/ProgramData/Docker/setup/07-cleanup.ps1') { \
        Write-Host 'Running the cleanup script'; \
        & 'C:/ProgramData/Docker/setup/07-cleanup.ps1'; \
        if ($LASTEXITCODE -ne 0) { Write-Error 'Failed to execute 07-cleanup.ps1'; exit 10 }; \
        Write-Host 'Done running the cleanup script'; \
    }

RUN Write-Host 'Init done'

FROM mcr.microsoft.com/windows/servercore:ltsc2022
ARG TZ
ARG PATH
ARG USER
ARG TIMEZONE
ARG LANGUAGE
ARG IMAGE_NAME
ARG BUILD_DATE
ARG SERVICE_PORT
ARG EXPOSE_PORTS
ARG BUILD_VERSION
ARG IMAGE_VERSION
ARG GIT_COMMIT
ARG WWW_ROOT_DIR
ARG DEFAULT_FILE_DIR
ARG DEFAULT_DATA_DIR
ARG DEFAULT_CONF_DIR
ARG DEFAULT_TEMPLATE_DIR
ARG DISTRO_VERSION
ARG NODE_VERSION
ARG NODE_MANAGER
ARG PHP_VERSION
ARG PHP_SERVER
ARG LICENSE="WTFPL"
ARG ENV_PORTS="${EXPOSE_PORTS}"

USER ${USER}
WORKDIR C:/Users/Administrator

LABEL maintainer="CasjaysDev <docker-admin@casjaysdev.pro>"
LABEL org.opencontainers.image.vendor="CasjaysDev"
LABEL org.opencontainers.image.authors="CasjaysDev"
LABEL org.opencontainers.image.description="Containerized version of ${IMAGE_NAME}"
LABEL org.opencontainers.image.title="${IMAGE_NAME}"
LABEL org.opencontainers.image.base.name="${IMAGE_NAME}"
LABEL org.opencontainers.image.authors="${LICENSE}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.version="${BUILD_VERSION}"
LABEL org.opencontainers.image.schema-version="${BUILD_VERSION}"
LABEL org.opencontainers.image.url="https://hub.docker.com/casjaysdevdocker/windows"
LABEL org.opencontainers.image.source="https://hub.docker.com/casjaysdevdocker/windows"
LABEL org.opencontainers.image.vcs-type="Git"
LABEL org.opencontainers.image.revision="${GIT_COMMIT}"
LABEL org.opencontainers.image.source="https://github.com/casjaysdevdocker/windows"
LABEL org.opencontainers.image.documentation="https://github.com/casjaysdevdocker/windows"
LABEL com.github.containers.toolbox="false"

ENV USER="${USER}"
ENV TIMEZONE="${TIMEZONE}"
ENV LANG="${LANGUAGE}"
ENV PORT="${SERVICE_PORT}"
ENV ENV_PORTS="${ENV_PORTS}"
ENV CONTAINER_NAME="${IMAGE_NAME}"
ENV HOSTNAME="casjaysdev-${IMAGE_NAME}"
ENV PHP_SERVER="${PHP_SERVER}"
ENV NODE_VERSION="${NODE_VERSION}"
ENV NODE_MANAGER="${NODE_MANAGER}"
ENV PHP_VERSION="${PHP_VERSION}"
ENV DISTRO_VERSION="${IMAGE_VERSION}"
ENV WWW_ROOT_DIR="${WWW_ROOT_DIR}"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

COPY --from=build C:/ C:/

VOLUME ["C:/config", "C:/data"]

EXPOSE ${SERVICE_PORT} ${ENV_PORTS}

ENTRYPOINT ["powershell", "-File", "C:/Windows/System32/entrypoint.ps1"]
HEALTHCHECK --start-period=10m --interval=5m --timeout=15s CMD powershell -File C:/Windows/System32/entrypoint.ps1 healthcheck
