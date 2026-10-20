#!/usr/bin/env bash
# check-dns.sh
# Repeatedly resolve an FQDN every 2s using a given DNS server (default 10.106.1.15).
# On failure prints timestamp of the attempt. On success prints nothing.
# Every hour prints overall statistics (since startup).
# Runs until Ctrl-C.

# Timestamp helper, utc time, no spaces
ts() { date -u '+%Y-%m-%dT%H:%M:%S%z'; }
# default display of utc time
ts_utc() { date -u; }

set -u
PROGNAME="$(basename "$0")"
DEFAULT_DNS="10.106.1.15"
DNS_SERVER="$DEFAULT_DNS"
FQDN=""
INTERVAL=2
LOGFILE="dig_$(ts).log"

print_usage() {
    cat <<EOF
Usage: $PROGNAME [--dns DNS] [--help] FQDN
  --dns DNS     Use DNS server (default: $DEFAULT_DNS)
  --log LOGFILE Log to specified file (default: dig_<timestamp utc>.log)
  --help        Show this help
FQDN may appear before or after options.
The script runs until interrupted (Ctrl-C).
EOF
}

# Parse options (allow positional anywhere)
if ! opts=$(getopt -o '' --long log:,dns:,help -- "$@"); then
  print_usage
  exit 2
fi
eval set -- "$opts"
while true; do
    case "$1" in
        --dns) DNS_SERVER="$2"; shift 2 ;;
        --help) print_usage; exit 0 ;;
        --log) LOGFILE="$2"; shift 2;;
        --) shift; break ;;
        *) break ;;
    esac
done

# Remaining positional args: first is FQDN
if [ $# -ge 1 ]; then
    FQDN="$1"
fi

if [ -z "$FQDN" ]; then
    echo "FQDN is required." >&2
    print_usage
    exit 2
fi

# Check resolver tool exists
if ! command -v dig >/dev/null 2>&1; then
    echo "No suitable DNS tool found (need dig)." >&2
    exit 1
fi

# Stats
succ=0
fail=0
start_ts=$(date +%s)
last_report_hours=0

# Cleanup on SIGINT: print final stats then exit
on_exit() {
    echo
    elapsed=$(( $(date +%s) - start_ts ))
    printf 'Exiting. Elapsed: %s seconds. Success: %d  Fail: %d\n' "$elapsed" "$succ" "$fail"
    exit 0
}
trap on_exit INT TERM

# Function to perform resolution
# Returns 0 on success (one or more answers), non-zero on failure.
resolve_once() {
    local dns_server="$1"
    local tcp_opt="$2"
    local fqdn="$3"

    # +time=3 to keep it quick, +tries=1 to avoid retrying at dig level
    ts_utc >> "${LOGFILE}"
    dig @"${dns_server}" "${tcp_opt}" +time=3 +tries=1 "${fqdn}" A >> "${LOGFILE}" 2>&1
    res="$?"
    if [ "${res}" -eq 0 ]; then
        # non-empty output means we got at least one A record
        return 0
    else
        return 1
    fi
}

check_dns() {
    local dns_server="$1"
    local tcp_opt="$2"
    local fqdn="$3"

    if resolve_once "${dns_server}" "${tcp_opt}" "${fqdn}"; then
        succ=$((succ+1))
        # on success: nothing printed
    else
        fail=$((fail+1))
        # print timestamp of the failed attempt and when the resolution started
        printf '%s DNS resolution failed for %s (server=%s/%s) (resolution started at %s)\n' \
            "$(ts)" "${fqdn}" "${dns_server}" "${tcp_opt}" "$resolution_started" >&2
        printf '%s DNS resolution failed for %s (server=%s/%s) (resolution started at %s)\n' \
            "$(ts_utc)" "${fqdn}" "${dns_server}" "${tcp_opt}" "$resolution_started" >> "${LOGFILE}"
    fi

}

# Main loop
while true; do
  # record when this resolution attempt started
  resolution_started="$(ts)"

  check_dns "10.106.1.15" "+notcp" "${FQDN}"
  check_dns "10.106.1.15" "+tcp" "${FQDN}"

  # hourly report: compute hours elapsed since start (integer)
  elapsed=$(( $(date +%s) - start_ts ))
  hours_passed=$(( elapsed / 3600 ))
  if [ "$hours_passed" -gt "$last_report_hours" ]; then
    last_report_hours=$hours_passed
    printf '%s Hourly report: success=%d fail=%d (since start)\n' "$(ts)" "$succ" "$fail" | tee -a "${LOGFILE}"
  fi

  sleep "$INTERVAL"
done
