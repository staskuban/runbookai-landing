#!/bin/sh
set -e

# Function to pluralize Russian word "функция"
pluralize_functions() {
    local n=$1
    local mod100=$((n % 100))
    local mod10=$((n % 10))

    # Special case for 11-19
    if [ $mod100 -ge 11 ] && [ $mod100 -le 19 ]; then
        echo "функций"
    elif [ $mod10 -eq 1 ]; then
        echo "функция"
    elif [ $mod10 -ge 2 ] && [ $mod10 -le 4 ]; then
        echo "функции"
    else
        echo "функций"
    fi
}

# Calculate pluralized form
export FUNCTIONS_WORD=$(pluralize_functions ${FUNCTIONS_COUNT})

# Substitute environment variables in index.html
envsubst '${APP_URL} ${PRICE} ${FUNCTIONS_COUNT} ${FUNCTIONS_WORD}' < /usr/share/nginx/html/index.html.template > /usr/share/nginx/html/index.html

# Execute the main command
exec "$@"
