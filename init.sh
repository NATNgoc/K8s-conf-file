#!/bin/bash

# Color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Spinner function (fixed)
spinner() {
    local pid=$1
    local delay=0.1  # Faster spinner
    local spinstr='|/-\'
    tput civis  # Hide cursor
    while kill -0 $pid 2>/dev/null; do  # Check if process is still running
        for char in $spinstr; do
            printf " [%c]  " "$char"
            sleep $delay
            printf "\b\b\b\b\b\b"
        done
    done
    tput cnorm  # Restore cursor
    echo -e "${GREEN}✅ DONE${NC}"
}

# Trap to handle errors and restore cursor
trap 'tput cnorm; exit 1' INT TERM ERR

# File paths
EXTERNAL_COMPONENTS_YAML="./external-image-delp.yaml"
CATALOG_SERVICE_YAML="./catalog-api-delp.yaml"
ORDER_SERVICE_YAML="./ordering-api-delp.yaml"
DISCOUNT_SERVICE_YAML="./discount-api-delp.yaml"
BASKET_SERVICE_YAML="./basket-api-delp.yaml"
USER_SERVICE_YAML="./user-api-delp.yaml"
LOAD_BALANCER_YAML="./nginx-ingress-rule.yaml"

# Welcome function with directory display
welcome() {
    local current_dir=$(pwd)
    echo -e "${YELLOW}====================${NC}"
    echo -e "📍 CURRENT LOCATION: ${GREEN}${current_dir}${NC}"
    echo -e "${YELLOW}====================${NC}"
    echo "📁 FILES IN THIS DIRECTORY:"
    ls -la --color=auto
    echo -e "${CYAN}🔔 Please be patient, this might take a few minutes...${NC} (⏳)"
}

# Install components with progress spinner
install_component_k8s() {
    declare -A services=(
        ["EXTERNAL COMPONENTS"]=$EXTERNAL_COMPONENTS_YAML
        ["CATALOG SERVICE"]=$CATALOG_SERVICE_YAML
        ["ORDER SERVICE"]=$ORDER_SERVICE_YAML
        ["DISCOUNT SERVICE"]=$DISCOUNT_SERVICE_YAML
        ["BASKET SERVICE"]=$BASKET_SERVICE_YAML
        ["USER SERVICE"]=$USER_SERVICE_YAML
    )

    for service in "${!services[@]}"; do
        echo -e "${GREEN}🚀 INSTALLING $service...${NC}"
        kubectl apply -f "${services[$service]}" &
        pid=$!  # Capture PID of the kubectl command
        spinner $pid  # Start spinner
        if wait $pid; then
            echo -e "${GREEN}✅ $service INSTALLED SUCCESSFULLY${NC}"
        else
            echo -e "${RED}❌ FAILED TO INSTALL $service. Please check logs.${NC}"
            exit 1
        fi
        echo -e "${YELLOW}--------------------${NC}"
    done
}

# Install Nginx load balancer with Helm
install_nginx_load_balancer() {
    local release_name=$1
    echo -e "${GREEN}🚀 INSTALLING LOAD BALANCER...${NC}"
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx &
    pid=$!
    spinner $pid  # Start spinner for Helm repo add

    helm repo update &
    pid=$!
    spinner $pid  # Start spinner for Helm repo update

    helm install ${release_name} ingress-nginx/ingress-nginx &
    pid=$!
    spinner $pid  # Start spinner for Helm install

    if wait $pid; then
        echo -e "${GREEN}✅ LOAD BALANCER INSTALLED SUCCESSFULLY${NC}"
    else
        echo -e "${RED}❌ FAILED TO INSTALL LOAD BALANCER. Please check Helm logs.${NC}"
        exit 1
    fi

    kubectl apply -f "$LOAD_BALANCER_YAML" &
    pid=$!
    spinner $pid  # Start spinner for applying YAML
    echo -e "${GREEN}✅ NGINX LOAD BALANCER CONFIGURED${NC}"
    echo -e "${YELLOW}--------------------${NC}"
}

# Main script execution
welcome
install_component_k8s
install_nginx_load_balancer "nginx-ingress-microservice"
