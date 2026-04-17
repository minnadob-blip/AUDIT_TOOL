#!/bin/bash

REPORT_DIR="$HOME/sys_audit" # Ensure this matches the report directory used in report_gen.sh
LOG_FILE="$REPORT_DIR/audit.log" # Ensure the log file exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TYPE=$1 # $1 is validated in report_gen.sh, so we can trust it here
MODE=$2
EMAIL=$3

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [EMAIL] $1" >> "$LOG_FILE"
}

if [ -z "$TYPE" ] || [ -z "$MODE" ] || [ -z "$EMAIL" ]; then
    echo "Usage: $0 <hardware|software|both> <short|full> email@example.com"
    exit 1
fi

# Generate a fresh report
REPORT_FILE=$("$SCRIPT_DIR/report_gen.sh" "$TYPE" "$MODE" | grep "Saved:" | awk '{print $2}')
if [ ! -f "$REPORT_FILE" ]; then
    echo "Report generation failed"
    exit 1 
fi

log "Sending $REPORT_FILE to $EMAIL" # here we assume the report_gen.sh outputs a line like "Saved: /path/to/report.txt", we extract the path and use it as an attachment
mail -s "System Audit Report ($TYPE $MODE)" -a "$REPORT_FILE" "$EMAIL" < /dev/null
log "Email sent"