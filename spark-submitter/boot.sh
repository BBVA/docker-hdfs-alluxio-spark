#!/usr/bin/env bash

executable=/opt/spark/bin/spark-submit

launcher_args=""

if [ -n "$LAUNCHER_DRIVER_REMOTE_DEBUGGING_PORT" ]; then
  launcher_args=" --driver-java-options -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=$LAUNCHER_DRIVER_REMOTE_DEBUGGING_PORT $launcher_args"
fi

if [ -n "$LAUNCHER_TOTAL_EXECUTOR_CORES" ]; then
  launcher_args=" --total-executor-cores $LAUNCHER_TOTAL_EXECUTOR_CORES $launcher_args"
fi

if [ -n "$LAUNCHER_EXECUTOR_CORES" ]; then
  launcher_args=" --executor-cores $LAUNCHER_EXECUTOR_CORES $launcher_args"
fi

if [ -n "$LAUNCHER_EXECUTOR_MEMORY" ]; then
  launcher_args=" --executor-memory $LAUNCHER_EXECUTOR_MEMORY $launcher_args"
fi

if [ -n "$LAUNCHER_DRIVER_CORES" ]; then
  launcher_args=" --driver-cores $LAUNCHER_DRIVER_CORES $launcher_args"
fi

if [ -n "$LAUNCHER_DRIVER_MEMORY" ]; then
  launcher_args=" --driver-memory $LAUNCHER_DRIVER_MEMORY $launcher_args"
fi

if [ -n "$LAUNCHER_FILES" ]; then
  launcher_args=" --files $LAUNCHER_FILES $launcher_args"
fi

if [ -n "$LAUNCHER_REPOSITORIES" ]; then
  launcher_args=" --repositories $LAUNCHER_REPOSITORIES $launcher_args"
fi

if [ -n "$LAUNCHER_EXCLUDE_PACKAGES" ]; then
  launcher_args=" --exclude-packages $LAUNCHER_EXCLUDE_PACKAGES $launcher_args"
fi

if [ -n "$LAUNCHER_PACKAGES" ]; then
  launcher_args=" --packages $LAUNCHER_PACKAGES $launcher_args"
fi

if [ -n "$LAUNCHER_JARS" ]; then
  launcher_args=" --jars $LAUNCHER_JARS $launcher_args"
fi

if [ -n "$LAUNCHER_APP_NAME" ]; then
  launcher_args=" --name $LAUNCHER_APP_NAME $launcher_args"
fi

if [ -n "$LAUNCHER_CLASS_NAME" ]; then
  launcher_args=" --class $LAUNCHER_CLASS_NAME $launcher_args"
fi

if [ -n "$LAUNCHER_DEPLOY_MODE" ]; then
  launcher_args=" --deploy-mode $LAUNCHER_DEPLOY_MODE $launcher_args"
fi

if [ -n "$LAUNCHER_MASTER_URL" ]; then
  launcher_args=" --master $LAUNCHER_MASTER_URL $launcher_args"
fi

launcher_args="$launcher_args $LAUNCHER_EXTRA_ARGS"

exec $executable $launcher_args $LAUNCHER_APP_JAR
