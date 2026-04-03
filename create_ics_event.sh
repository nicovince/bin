#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 [--time HH:MM-HH:MM] [--title <title>] [--public] YYYY-MM-DD

Options:
  --title title  The title to give to the event
  --time HH:MM-HH:MM  Start and end time (24h). Default: 12:00-14:00
  --public  Make the event public (private by default)

Examples:
  $0 2026-04-03
  $0 --time 09:30-11:00 2026-04-03
EOF
    exit 1
}

TIME_RANGE="12:00-14:00"
DATE=""
CLASS_EVENT="PRIVATE"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --title)
            shift
            TITLE="${1}"
            shift
            ;;
        --time)
            shift || usage
            TIME_RANGE="${1:-}"
            shift
            ;;
        --public)
            CLASS_EVENT="PUBLIC"
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            if [[ -z "$DATE" ]]; then
                DATE="$1"
                shift
            else
                usage
            fi
            ;;
    esac
done

if [[ -z "$DATE" ]]; then
    usage
fi

# Validate date format YYYY-MM-DD
if ! [[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Error: Date must be in format YYYY-MM-DD" >&2
    exit 1
fi

# Validate time range format HH:MM-HH:MM
if ! [[ "$TIME_RANGE" =~ ^([0-9]{2}):([0-9]{2})-([0-9]{2}):([0-9]{2})$ ]]; then
    echo "Error: Time must be in format HH:MM-HH:MM (24h)" >&2
    exit 1
fi

START_HOUR="${BASH_REMATCH[1]}"
START_MIN="${BASH_REMATCH[2]}"
END_HOUR="${BASH_REMATCH[3]}"
END_MIN="${BASH_REMATCH[4]}"
SUMMARY="${TITLE:-"Event on ${DATE}"}"

# Check time numbers are valid
if ((10#$START_HOUR > 23 || 10#$END_HOUR > 23 || 10#$START_MIN > 59 || 10#$END_MIN > 59)); then
    echo "Error: Invalid time values in --time" >&2
    exit 1
fi

# Build datetime strings in local time (floating time, no 'Z')
# ICS requires YYYYMMDDTHHMMSS format
DATE_COMPACT="${DATE//-/}"                       # 20260403
DTSTART="${DATE_COMPACT}T${START_HOUR}${START_MIN}00"
DTEND="${DATE_COMPACT}T${END_HOUR}${END_MIN}00"

# Generate a simple UID (date+time+random)
UUID_SUFFIX=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 8 || true)
_UID="event-${DATE_COMPACT}-${START_HOUR}${START_MIN}-${END_HOUR}${END_MIN}-${UUID_SUFFIX}@local"

# DTSTAMP is "now", in UTC, formatted as YYYYMMDDTHHMMSSZ
DTSTAMP=$(date -u +"%Y%m%dT%H%M%SZ")

# Timezone (adjust as needed)
TZID="Europe/Berlin"

# Output file
OUTFILE="event-${DATE_COMPACT}-${START_HOUR}${START_MIN}-${END_HOUR}${END_MIN}.ics"

cat > "$OUTFILE" <<EOF
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Custom Script//EN
CALSCALE:GREGORIAN
METHOD:PUBLISH
BEGIN:VEVENT
UID:$_UID
DTSTAMP:$DTSTAMP
DTSTART;TZID=$TZID:$DTSTART
DTEND;TZID=$TZID:$DTEND
SUMMARY:${SUMMARY}
DESCRIPTION:Event on $DATE from $START_HOUR:$START_MIN to $END_HOUR:$END_MIN
CLASS:${CLASS_EVENT}
END:VEVENT
END:VCALENDAR
EOF

echo "Created ICS file: $OUTFILE"
