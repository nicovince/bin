#!/usr/bin/env bash
PROGNAME="$(basename "$0")"

# Timestamp helper, utc time, no spaces
ts() { date -u '+%Y-%m-%dT%H:%M:%S%z'; }

LOGFILE="$(hostname)_$(ts).pcap"
INTERFACE="any"

print_usage() {
  cat <<EOF
Usage: $PROGNAME [--log LOGFILE] [--help] FQDN
  --help        Show this help
  --log         Save traffic to file (default ${LOGFILE})
  --interface INTERFACE name of the interface to capture on (default ${INTERFACE})
The script runs until interrupted (Ctrl-C).
EOF
}

# Parse options (allow positional anywhere)
if ! opts=$(getopt -o '' --long log:,help -- "$@"); then
  print_usage
  exit 2
fi
eval set -- "$opts"
while true; do
  case "$1" in
    --help) print_usage; exit 0 ;;
    --log) LOGFILE="$2"; shift 2;;
    --) shift; break ;;
    *) break ;;
  esac
done

tcpdump -ni "${INTERFACE}" -s0 -w "${LOGFILE}" "port 53 and (host 10.106.1.15 or host 10.100.1.43)"
