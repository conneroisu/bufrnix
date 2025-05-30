#!/usr/bin/env bash
# RoadRunner development helper script

case "$1" in
  start)
    echo "Starting RoadRunner server..."
    rr serve -c .rr.yaml
    ;;
  debug)
    echo "Starting RoadRunner in debug mode..."
    rr serve -c .rr.yaml -d
    ;;
  workers)
    echo "Checking worker status..."
    rr workers -c .rr.yaml
    ;;
  reset)
    echo "Resetting RoadRunner workers..."
    rr reset -c .rr.yaml
    ;;
  stop)
    echo "Stopping RoadRunner..."
    rr stop -c .rr.yaml
    ;;
  *)
    echo "Usage: $0 {start|debug|workers|reset|stop}"
    exit 1
esac
