#!/usr/bin/env bash
set -euo pipefail

if (( $# < 1 )); then
    echo "Usage: $0 PROFILE_DIRECTORY" >&2
    exit 1
fi

command -v sqlite3 >/dev/null || {
    echo "Error: install sqlite3 first." >&2
    exit 1
}

profile=$1
shift
db="$profile/cookies.sqlite"

[[ -f "$db" ]] || {
    echo "Error: cookie database not found: $db" >&2
    exit 1
}

if pgrep -x 'firefox|firefox-bin' >/dev/null; then
    echo "Error: close Firefox completely before running this script." >&2
    exit 1
fi

# Microsoft domains cookies to delete
ms_domains=()
ms_domains+=("office.com")
ms_domains+=("microsoftonline.com")

# Escape single quotes in the backup filename for SQLite.
backup="${db}.backup.$(date +%Y%m%d-%H%M%S).$$"
backup_sql=${backup//\'/\'\'}

sqlite3 -batch -bail "$db" "VACUUM INTO '$backup_sql';"
echo "Backup created: $backup"

# One transaction: delete exact-domain and subdomain cookies.
{
    echo "BEGIN IMMEDIATE;"
    for domain in "${ms_domains[@]}"; do
        printf \
            "DELETE FROM moz_cookies
             WHERE ltrim(host, '.') = '%s'
                OR ltrim(host, '.') LIKE '%%.%s';
             SELECT '%s: ' || changes() || ' cookies deleted';\n" \
            "$domain" "$domain" "$domain"
    done
    echo "COMMIT;"
} | sqlite3 -batch -bail "$db"
