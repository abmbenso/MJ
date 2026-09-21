#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Start the ssh service in the background for troubleshooting
/usr/sbin/sshd -D &

cd /app

# Run migrations with the --tag parameter (skippable: a deployment whose schema is provisioned
# out-of-band -- e.g. a bacpac copy of a dev database -- gains nothing from boot-time migrate,
# which still parses the full 500+ MB migration set and needs a large Node heap to do it)
if [ "${MJ_SKIP_MIGRATE:-0}" = "1" ]; then
  echo "MJ_SKIP_MIGRATE=1: skipping mj migrate"
else
  mj migrate
fi

# Run code generation (skippable: a deployment whose database metadata is already complete and
# whose generated code is baked into the image gains nothing from re-running CodeGen on every
# boot, and it costs minutes of heavy DB load per restart on a small cloud tier)
if [ "${MJ_SKIP_CODEGEN:-0}" = "1" ]; then
  echo "MJ_SKIP_CODEGEN=1: skipping mj codegen"
else
  mj codegen
fi

# Start the MJAPI application
pm2-runtime packages/MJAPI/dist/index.js
