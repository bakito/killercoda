#!/usr/bin/env bash

# Colors
RED=$(printf '\033[0;31m')
GREEN=$(printf '\033[0;32m')
YELLOW=$(printf '\033[1;33m')
BLUE=$(printf '\033[0;34m')
CYAN=$(printf '\033[0;36m')
NC=$(printf '\033[0m') # No Color
BOLD=$(printf '\033[1m')

# Icons
ICON_PENDING="⏳"
ICON_RUNNING="🔄"
ICON_DONE="✅"
ICON_FAILED="❌"
ICON_SKIPPED="⏭️"

KODA_DIR="/tmp/koda"
mkdir -p "$KODA_DIR"

# Global tasks array
KODA_TASKS=()

koda_task_add() {
    KODA_TASKS+=("$1:$2")
}

koda_task_init() {
    local id=$1
    local label=$2
    mkdir -p "$KODA_DIR"
    if [ ! -f "$KODA_DIR/$id" ]; then
        echo "pending" > "$KODA_DIR/$id"
        echo "$label" > "$KODA_DIR/$id.label"
    fi
}

koda_task_start() {
    local id=$1
    echo "running" > "$KODA_DIR/$id"
    date +%s > "$KODA_DIR/$id.start"
}

koda_task_done() {
    local id=$1
    echo "done" > "$KODA_DIR/$id"
    if [ -f "$KODA_DIR/$id.start" ]; then
      local start_time
      start_time=$(cat "$KODA_DIR/$id.start")
      local end_time
      end_time=$(date +%s)
      local elapsed=$((end_time - start_time))
      echo "$elapsed" > "$KODA_DIR/$id.duration"
    fi
}

koda_task_fail() {
    local id=$1
    local required=${2:-false}
    echo "failed" > "$KODA_DIR/$id"
    # Store any error message passed via stderr capture or environment
    if [ -n "${KODA_ERROR_MSG:-}" ]; then
        echo "$KODA_ERROR_MSG" > "$KODA_DIR/$id.error"
    fi
    if [ "$required" = "true" ]; then
        printf "${RED}Critical task %s failed. Exiting.${NC}\n" "$id"
        exit 1
    fi
}

# Store an error message for a task (used by debug helpers)
koda_task_error() {
    local id=$1
    local msg=$2
    echo "$msg" > "$KODA_DIR/$id.error"
}

# Debug helper: print kubectl diagnostics for a failed Helm deployment
# Tries both Helm labels (app.kubernetes.io/instance) and plain app= labels
koda_debug_deployment() {
    local name=$1
    local namespace=$2
    echo "========================================" >&2
    echo "DEBUG: Deployment $name (namespace: $namespace)" >&2
    echo "========================================" >&2
    echo "--- All pods in namespace ---" >&2
    kubectl get pods -n "$namespace" -o wide 2>&1 || true
    echo "--- Pod describe ---" >&2
    local pod=""
    # Try Helm label first
    pod=$(kubectl get pods -n "$namespace" -l "app.kubernetes.io/instance=$name" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
    # Fallback to app= label
    if [ -z "$pod" ]; then
        pod=$(kubectl get pods -n "$namespace" -l "app=$name" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
    fi
    # Fallback to name prefix match
    if [ -z "$pod" ]; then
        pod=$(kubectl get pods -n "$namespace" -o jsonpath="{.items[?(@.metadata.name=='${name}.*')].metadata.name}" 2>/dev/null | head -1 || true)
    fi
    if [ -n "$pod" ]; then
        echo "Found pod: $pod" >&2
        kubectl describe pod "$pod" -n "$namespace" 2>&1 || true
        echo "--- Pod logs ---" >&2
        kubectl logs "$pod" -n "$namespace" --tail=50 2>&1 || true
    else
        echo "No pods found for $name in namespace $namespace" >&2
    fi
    echo "--- Events ---" >&2
    kubectl get events -n "$namespace" --sort-by='.lastTimestamp' 2>&1 | tail -20 || true
    echo "========================================" >&2
}

koda_task_skip() {
    local id=$1
    echo "skipped" > "$KODA_DIR/$id"
}

koda_task_check() {
    local id=$1
    local cmd=$2
    local label=$3
    koda_task_init "$id" "$label"
    if command -v "$cmd" &> /dev/null; then
        koda_task_skip "$id"
        return 1
    else
        koda_task_start "$id"
        return 0
    fi
}

koda_render_ui() {
    local title=$1
    local footer=$2

    local spinner_idx=0
    local spinner_chars="|/-\\"

    # Hide cursor (safe with set -e)
    [ -t 1 ] && tput civis || true

    while true; do
        # Move cursor to top-left
        printf "\033[H\033[J"
        
        printf "${BOLD}${CYAN}🚀 %s${NC}\n" "$title"
        printf "${BLUE}----------------------------------------${NC}\n"

        local all_done=true
        for task_info in "${KODA_TASKS[@]}"; do
            local id="${task_info%%:*}"
            local label="${task_info#*:}"
            
            local status="pending"
            if [ -f "$KODA_DIR/$id" ]; then
                status=$(cat "$KODA_DIR/$id")
            fi
            
            case $status in
                pending)
                    printf "%s %s\n" "$ICON_PENDING" "$label"
                    all_done=false
                    ;;
                running)
                    local sp="${spinner_chars:spinner_idx%4:1}"
                    printf "%s %s ... [${YELLOW}%s${NC}]\n" "$ICON_RUNNING" "$label" "$sp"
                    all_done=false
                    ;;
                done)
                    local duration_str=""
                    if [ -f "$KODA_DIR/$id.duration" ]; then
                        local dur
                        dur=$(cat "$KODA_DIR/$id.duration")
                        if [ "$dur" -ge 60 ]; then
                            local mins=$((dur / 60))
                            local secs=$((dur % 60))
                            duration_str=" (${mins}m ${secs}s)"
                        else
                            duration_str=" (${dur}s)"
                        fi
                    fi
                    printf "%s %s%s\n" "$ICON_DONE" "$label" "$duration_str"
                    ;;
                skipped)
                    local duration_str=""
                    if [ -f "$KODA_DIR/$id.duration" ]; then
                        local dur
                        dur=$(cat "$KODA_DIR/$id.duration")
                        if [ "$dur" -ge 60 ]; then
                            local mins=$((dur / 60))
                            local secs=$((dur % 60))
                            duration_str=" (${mins}m ${secs}s)"
                        else
                            duration_str=" (${dur}s)"
                        fi
                    fi
                    printf "%s %s (already installed)%s\n" "$ICON_DONE" "$label" "$duration_str"
                    ;;
                failed)
                    local error_msg=""
                    if [ -f "$KODA_DIR/$id.error" ]; then
                        error_msg=$(head -1 "$KODA_DIR/$id.error")
                    fi
                    if [ -n "$error_msg" ]; then
                        printf "%s ${RED}%s (failed: %s)${NC}\n" "$ICON_FAILED" "$label" "$error_msg"
                    else
                        printf "%s ${RED}%s (failed)${NC}\n" "$ICON_FAILED" "$label"
                    fi
                    ;;
            esac
        done

        printf "${BLUE}----------------------------------------${NC}\n"

        if [ "$all_done" = "true" ]; then
            if [ -n "$footer" ]; then
                printf "${GREEN}%s${NC}\n" "$footer"
            fi
            break
        fi

        spinner_idx=$((spinner_idx + 1))
        sleep 0.5
    done

    # Show cursor (safe with set -e)
    [ -t 1 ] && tput cnorm || true
    echo ""
}
