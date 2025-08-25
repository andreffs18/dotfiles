#!/bin/bash

set -euo pipefail

# Configuration
readonly SCRIPT_NAME="$(basename "$0")"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Functions
print_usage() {
    echo "Usage: $SCRIPT_NAME <IP_ADDRESS>"
    echo "Analyze a Kubernetes IP to find associated nodes, pods, or endpoints."
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

validate_ip_format() {
    local ip="$1"

    # Check basic IPv4 format
    if ! [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        log_error "Invalid IP format: '$ip'"
        return 1
    fi

    # Validate each octet is 0-255
    IFS='.' read -r o1 o2 o3 o4 <<< "$ip"
    for octet in "$o1" "$o2" "$o3" "$o4"; do
        if (( octet < 0 || octet > 255 )); then
            log_error "IP octet out of range: '$octet'"
            return 1
        fi
    done

    return 0
}

check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl not found. Please install kubectl."
        exit 1
    fi
}

find_node_by_ip() {
    local target_ip="$1"

    log_info "Checking if IP belongs to a Kubernetes node..."

    local node_name
    node_name=$(kubectl get nodes -o json | jq -r --arg ip "$target_ip" '
        .items[] |
        select(.status.addresses[]? | select(.type == "InternalIP" and .address == $ip)) |
        .metadata.name'
    )

    if [[ -n "$node_name" ]]; then
        log_success "IP matches node: $node_name"
        list_pods_on_node "$node_name"
        return 0
    fi

    log_warning "IP does not match any node Internal IP."
    show_available_nodes
    return 1
}

list_pods_on_node() {
    local node_name="$1"
    local pod_found=0

    echo
    log_info "Pods scheduled on node '$node_name':"
    echo

    local namespaces
    namespaces=$(kubectl get ns -o jsonpath='{.items[*].metadata.name}')

    for ns in $namespaces; do
        echo -n "🔹 Checking namespace: $ns... "

        local pods
        pods=$(kubectl get pods -n "$ns" -o wide --field-selector spec.nodeName="$node_name" 2>/dev/null || true)

        if [[ $(echo "$pods" | wc -l) -gt 1 ]]; then
            echo "✅ Found pods:"
            echo "$pods" | awk 'NR==1 || NF' | column -t
            pod_found=1
        else
            echo "no pods"
        fi
    done

    if [[ $pod_found -eq 0 ]]; then
        echo
        log_warning "No pods found on node '$node_name' across all namespaces."
    fi
}

show_available_nodes() {
    echo
    log_info "Available nodes and their Internal IPs:"
    echo
    kubectl get nodes -o json | jq -r '
        .items[] |
        [.metadata.name, (.status.addresses[] | select(.type == "InternalIP") | .address)] |
        @tsv' | column -t
}

find_endpoint_by_ip() {
    local target_ip="$1"

    echo
    log_info "Checking IP against endpoints in each namespace..."
    echo

    local namespaces
    namespaces=$(kubectl get ns -o jsonpath='{.items[*].metadata.name}')

    for ns in $namespaces; do
        echo -n "🔹 Scanning namespace: $ns... "

        local result
        result=$(kubectl get endpoints -n "$ns" -o json 2>/dev/null | \
            jq -r --arg ip "$target_ip" '
            .. | .addresses? // empty | .[] |
            select(.ip == $ip) |
            "[" + .targetRef.namespace + "] pod/" + .targetRef.name' || true)

        if [[ -n "$result" ]]; then
            log_success "Match found!"
            echo "$result"
            return 0
        else
            echo "no match"
        fi
    done

    log_error "No match found for IP $target_ip in any endpoints."
    return 1
}

main() {
    # Check for input
    if [[ $# -eq 0 ]]; then
        print_usage
        exit 1
    fi

    local target_ip="$1"

    # Validate input
    validate_ip_format "$target_ip"
    check_kubectl

    echo
    log_info "Analyzing IP: $target_ip"
    echo

    # Try to find node first
    if find_node_by_ip "$target_ip"; then
        exit 0
    fi

    # If not a node IP, check endpoints
    if find_endpoint_by_ip "$target_ip"; then
        exit 0
    fi

    exit 1
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
