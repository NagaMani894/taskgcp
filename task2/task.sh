#!/bin/bash

# Function to retrieve metadata of an instance
get_instance_metadata() {
    data_key="$1"
    metadata_url="http://metadata.google.internal/computeMetadata/v1"
    headers="Metadata-Flavor: Google"

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




curl "http://metadata.google.internal/computeMetadata/v1/instance/?recursive=true&alt=json" -H "Metadata-Flavor: Google"
