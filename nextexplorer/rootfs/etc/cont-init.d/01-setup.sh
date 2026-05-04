#!/usr/bin/with-contenv bash


V_ROOT="${VOLUME_ROOT:-/storage}"
OPTIONS_FILE="/data/options.json"

#need apparmor: false and privileged: SYS_ADMIN
if jq -e '.root_volumes and (.root_volumes | length > 0)' "$OPTIONS_FILE" > /dev/null; then
    for vol in $(jq -r '.root_volumes[]' "$OPTIONS_FILE"); do
        SOURCE_PATH="/$vol"
		
		# share is reserved name for next cloud
		if [ "$vol" = "share" ]; then
            TARGET_NAME="shared"
        else
            TARGET_NAME="$vol"
        fi
		
		TARGET_PATH="$V_ROOT/$TARGET_NAME"

		# share is reserved name for next cloud
		if [ "$vol" = "root" ]; then
            SOURCE_PATH="/"
        fi
		
		echo "$SOURCE_PATH -> $TARGET_PATH"

        if [ -d "$SOURCE_PATH" ]; then
            mkdir -p "$TARGET_PATH"
            if ! mountpoint -q "$TARGET_PATH"; then
                mount --bind "$SOURCE_PATH" "$TARGET_PATH"
            fi
        fi
    done
else
   echo "No root_volumes defined for setup" 
fi

echo "Preparing folders in /config and /cache..."
mkdir -p "${CONFIG_DIR:-/config}/extensions/icons" \
         "${CONFIG_DIR:-/config}/extensions/brand" \
         "${CACHE_DIR:-/cache}/thumbnails"

echo "Next Explorer Setup complete."

