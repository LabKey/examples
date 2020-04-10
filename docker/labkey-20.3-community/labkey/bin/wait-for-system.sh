#!/usr/bin/env bash

# Wait for the postgres container to be ready before starting LabKey.

#Wait for the port
wait-for-it.sh $DATABASE_HOST:$DATABASE_PORT -t 0

echo "Starting LabKey Application"
exec "$@"