#!/bin/bash

# Function to print colored output
print_green() {
    echo -e "\033[0;32m$1\033[0m"
}

print_yellow() {
    echo -e "\033[0;33m$1\033[0m"
}

print_cyan() {
    echo -e "\033[0;36m$1\033[0m"
}

# Start the .NET Functions API in a new terminal window
print_green "Starting Azure Functions API..."
osascript -e 'tell app "Terminal" to do script "cd \"'$PWD/api'\"; print_yellow \"Starting Azure Functions on http://localhost:7071...\"; func start"'

# Wait for the API to start up
print_yellow "Waiting for API to start..."
sleep 5

# Check if the API is responding
print_yellow "Checking if API is ready..."
api_ready=false
max_attempts=10
attempt=0

while [ "$api_ready" = false ] && [ $attempt -lt $max_attempts ]; do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:7071/api/live | grep -q "200"; then
        api_ready=true
        print_green "✅ API is ready!"
    else
        attempt=$((attempt + 1))
        print_yellow "API not ready yet, attempt $attempt/$max_attempts..."
        sleep 2
    fi
done

if [ "$api_ready" = false ]; then
    print_yellow "⚠️  API might not be ready, but continuing anyway..."
fi

# Start the SWA CLI
print_green "Starting SWA CLI..."
print_cyan "Your app will be available at: http://localhost:4280"
npx @azure/static-web-apps-cli start