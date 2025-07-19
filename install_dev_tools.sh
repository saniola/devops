#!/bin/bash
set -e

# Colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RESET="\033[0m"

log_info() {
  echo -e "${YELLOW}🔧 $1${RESET}"
}

log_success() {
  echo -e "${GREEN}✅ $1${RESET}"
}

export DEBIAN_FRONTEND=noninteractive

log_info "Updating package list..."
apt-get update -qq

log_info "Installing prerequisites..."
apt-get install -y -qq ca-certificates curl gnupg lsb-release software-properties-common

# Install Docker
if ! command -v docker &> /dev/null; then
  log_info "Installing Docker..."

  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list

  apt-get update -qq
  apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  log_success "Docker installed"
else
  log_success "Docker already installed"
fi

# Docker Compose plugin
if ! docker compose version &> /dev/null; then
  log_info "Installing Docker Compose plugin..."
  apt-get install -y -qq docker-compose-plugin
  log_success "Docker Compose plugin installed"
else
  log_success "Docker Compose plugin already installed"
fi

# Python 3.9+
PYTHON_VERSION=$(python3 -c "import sys; print('.'.join(map(str, sys.version_info[:2])))")

if dpkg --compare-versions "$PYTHON_VERSION" ge "3.9"; then
  log_success "Python $PYTHON_VERSION is 3.9 or newer"
else
  log_info "Installing Python 3.9..."
  add-apt-repository -y ppa:deadsnakes/ppa
  apt-get update -qq
  apt-get install -y -qq python3.9 python3.9-distutils
  update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1
  log_success "Python 3.9 installed and set as default"
fi

# pip
if ! command -v pip3 &> /dev/null; then
  log_info "Installing pip..."
  apt-get install -y -qq python3-pip
  log_success "pip installed"
else
  log_success "pip is already installed"
fi

# Django
if ! python3 -m django --version &> /dev/null; then
  log_info "Installing Django via pip..."
  pip3 install --break-system-packages django
  log_success "Django installed"
else
  log_success "Django already installed"
fi
