#!/bin/bash

# Color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# File paths
EXTERNAL_COMPONENTS_YAML="./external-image-delp.yaml"
CATALOG_SERVICE_YAML="./catalog-api-delp.yaml"
ORDER_SERVICE_YAML="./ordering-api-delp.yaml"
DISCOUNT_SERVICE_YAML="./discount-api-delp.yaml"
BASKET_SERVICE_YAML="./basket-api-delp.yaml"
USER_SERVICE_YAML="./user-api-delp.yaml"

# Function to display welcome message
function welcome() {
    current_dir=$(pwd)
    echo -e "${YELLOW}----------${NC}"
    echo -e "CURRENT LOCATION is: ${GREEN}${current_dir}${NC}"
    echo -e "${YELLOW}----------${NC}"
    echo "FILES AT CURRENT LOCATION:"
    ls -la
    echo -e "${YELLOW}----------${NC}"
    echo -e "${RED}This process can prolong for a few minutes. Please, be patient. (┬┬﹏┬┬)${NC}"
}

# Function to install Kubernetes components
function install_component_k8s() {
    echo -e "${GREEN}INSTALLING EXTERNAL COMPONENTS${NC}"
    kubectl apply -f "$EXTERNAL_COMPONENTS_YAML"
    echo -e "${YELLOW}----------${NC}"
    echo -e "${GREEN}EXTERNAL COMPONENTS INSTALLED${NC}"
    echo -e "${YELLOW}----------${NC}"
    echo -e "${GREEN}INSTALLING CATALOG SERVICE${NC}"
    kubectl apply -f "$CATALOG_SERVICE_YAML"
    echo -e "${YELLOW}----------${NC}"
    echo -e "${GREEN}CATALOG SERVICE INSTALLED${NC}"
    echo -e "${YELLOW}----------${NC}"
    echo -e "${GREEN}INSTALLING ORDER SERVICE${NC}"
    kubectl apply -f "$ORDER_SERVICE_YAML"
    echo -e "${YELLOW}----------${NC}"
    echo -e "${GREEN}ORDER SERVICE INSTALLED${NC}"
    echo -e "${YELLOW}----------${NC}"
    echo -e "${GREEN}INSTALLING DISCOUNT SERVICE${NC}"
    kubectl apply -f "$DISCOUNT_SERVICE_YAML"
    echo -e "${YELLOW}----------${NC}"
    echo -e "${GREEN}DISCOUNT SERVICE INSTALLED${NC}"
    echo -e "${YELLOW}----------${NC}"
    echo -e "${GREEN}INSTALLING BASKET SERVICE${NC}"
    kubectl apply -f "$BASKET_SERVICE_YAML"
    echo -e "${YELLOW}----------${NC}"
    echo -e "${GREEN}BASKET SERVICE INSTALLED${NC}"
    echo -e "${YELLOW}----------${NC}"
    echo -e "${GREEN}INSTALLING USER SERVICE${NC}"
    kubectl apply -f "$USER_SERVICE_YAML"
    echo -e "${YELLOW}----------${NC}"
    echo -e "${GREEN}ALL SERVICES INSTALLED SUCCESSFULLY${NC}"
}

# Main script execution
welcome
install_component_k8s