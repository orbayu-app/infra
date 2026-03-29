#!/usr/bin/env bash

set -e

# export env vars from file
set -a
source ./.env
set +a

start=$(date +%s)

compose_command='docker compose'
ProjectName=${COMPOSE_PROJECT_NAME}


echo "--- Stopping environment..."
echo '--- $$> '"${compose_command} -p ${ProjectName} down"
${compose_command} -p ${ProjectName} down
echo "--- Done."


end=$(date +%s)
echo ""
echo "--- Finished. Elapsed time $((end-start)) seconds."
