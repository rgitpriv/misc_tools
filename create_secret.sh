#!/bin/bash

# Default values
NAMESPACE=""
SECRET_NAME=""
COPY_TO_CLIPBOARD=false

# Parse arguments
while getopts "s:n:m" opt; do
  case $opt in
    s) SECRET_NAME="$OPTARG" ;;
    n) NAMESPACE="$OPTARG" ;;
    m) COPY_TO_CLIPBOARD=true ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done

# Prompt for namespace and secret name if not provided
if [ -z "$NAMESPACE" ]; then
    read -p "Enter the namespace: " NAMESPACE
fi

if [ -z "$SECRET_NAME" ]; then
    read -p "Enter the secret name: " SECRET_NAME
fi

# Initialize an empty string for the key-value pairs
KEY_VALUES=""

while true; do
    read -p "Enter key (or press Enter to finish): " KEY
    if [ -z "$KEY" ]; then
        break
    fi
    read -sp "Enter value for $KEY: " VALUE
    echo

    # Add the key-value pair to the KEY_VALUES string
    KEY_VALUES="$KEY_VALUES --from-literal=$KEY=$VALUE"
done

# Separate the output with "---"
echo "---"
echo

# Generate the kubectl command
KUBECTL_CMD="kubectl create secret generic \"$SECRET_NAME\" -n \"$NAMESPACE\" $KEY_VALUES -o yaml --dry-run=client"

# Run the kubectl command
eval $KUBECTL_CMD

# If -m is provided, pipe the output to xsel -b to copy to the clipboard
if [ "$COPY_TO_CLIPBOARD" = true ]; then
    eval $KUBECTL_CMD | xsel -b
    echo "Secret YAML copied to clipboard."
fi

