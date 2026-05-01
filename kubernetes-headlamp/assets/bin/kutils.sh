#!/bin/bash

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
}

koda_task_done() {
    local id=$1
    echo "done" > "$KODA_DIR/$id"
}

koda_task_fail() {
    local id=$1
    local required=${2:-false}
    echo "failed" > "$KODA_DIR/$id"
    if [ "$required" = "true" ]; then
        printf "${RED}Critical task %s failed. Exiting.${NC}\n" "$id"
        exit 1
    fi
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

    # Hide cursor
    [ -t 1 ] && tput civis

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
                    printf "%s %s\n" "$ICON_DONE" "$label"
                    ;;
                skipped)
                    printf "%s %s (already installed)\n" "$ICON_DONE" "$label"
                    ;;
                failed)
                    printf "%s ${RED}%s (failed)${NC}\n" "$ICON_FAILED" "$label"
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

    # Show cursor
    [ -t 1 ] && tput cnorm
    echo ""
}
