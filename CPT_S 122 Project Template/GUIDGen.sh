#!/usr/bin/env sh

# Find .vcxproj files in current directory
set -- ./*.vcxproj

# No match
[ "$1" = "./*.vcxproj" ] && {
    echo "No .vcxproj file found."
    exit 1
}

# More than one match
[ "$#" -gt 1 ] && {
    echo "More than one .vcxproj file found."
    exit 1
}

vcxproj="$1"

# Check if {GUID} placeholder exists
if ! grep -q '{GUID}' "$vcxproj"; then
    echo "No {GUID} placeholder found in $vcxproj."
fi

# Generate uppercase GUID in {XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX} format
guid="$(uuidgen | tr '[:lower:]' '[:upper:]')"
guid="{$guid}"

# Replace {GUID} with generated GUID
tmpfile="$(mktemp /tmp/tmp.XXXXXX)" || exit 1
sed "s/{GUID}/$guid/g" "$vcxproj" > "$tmpfile" && mv "$tmpfile" "$vcxproj"

echo "Updated $vcxproj with GUID $guid"

# Check slngen availability
if ! command -v slngen >/dev/null 2>&1; then
    echo "slngen not found in PATH."
    exit 1
fi

# Run slngen
if ! slngen "$vcxproj"; then
    echo "slngen failed."
    exit 1
fi
