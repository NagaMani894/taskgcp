#!/bin/bash

# Function to retrieve metadata of an instance
get_instance_metadata() {
    local data_key="$1"
    local metadata_url="http://metadata.google.internal/computeMetadata/v1/"
    local headers="Metadata-Flavor: Google"

    if [ -z "$data_key" ]; then
        # If no data key is provided, retrieve all metadata
        curl -H "$headers" "$metadata_url"
    else
        # If a specific data key is provided, retrieve only that
        curl -H "$headers" "$metadata_url/$data_key"
    fi
}

# Call the function and format the output as JSON
get_instance_metadata "$1" | jq '.'