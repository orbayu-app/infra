#!/usr/bin/env bash

set -e

# export env vars from file
set -a
source ./.env
set +a

start=$(date +%s)
compose_command='docker compose'
RepositoryUrl=${REPOSITORY_URL}
ProjectName=${COMPOSE_PROJECT_NAME}
ProjectPath=${PROJECT_PATH}


echo "--- Stopping environment..."
echo '--- $$> '"${compose_command} -p ${ProjectName} down"
${compose_command} -p ${ProjectName} down
echo "--- Done."


if [ ! -d ${ProjectPath} ]; then
  echo "--- Clone project..."
  echo '--- $$> '"git clone ${RepositoryUrl} ${ProjectPath}"
  git clone ${RepositoryUrl} ${ProjectPath}
  echo "--- Done."
fi


echo "--- Rebuilding environment..."
echo '--- $$> '"${compose_command} -p ${ProjectName} up -d --build"
${compose_command} -p ${ProjectName} up -d --build
echo "--- Done."


echo "--- Running composer install..."
echo '--- $$> '" ${compose_command} -p ${ProjectName} exec php composer install"
${compose_command} -p ${ProjectName} exec php composer install
echo "--- Done."


if [ ! -f ${ProjectPath}/.env ]; then
    echo "--- Creating .env..."
    cp ${ProjectPath}/.env.example ${ProjectPath}/.env
    ${compose_command} -p ${ProjectName} exec php php artisan key:generate
    echo "--- Done."
fi


end=$(date +%s)
echo ""
echo "--- Finished. Elapsed time $((end-start)) seconds."
