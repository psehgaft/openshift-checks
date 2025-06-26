#!/bin/bash

echo "Listing all pods with age > 24 hours (excluding namespaces starting with 'openshift-')"
echo

# Get the current date in seconds since epoch
now=$(date +%s)

# Get all pods except those in 'openshift-*' namespaces
oc get pods --all-namespaces -o json | jq -r '
  .items[] |
  select(.metadata.namespace | startswith("openshift-") | not) |
  {
    name: .metadata.name,
    namespace: .metadata.namespace,
    startTime: .status.startTime
  } |
  select(.startTime != null) |
  "\(.namespace) \(.name) \(.startTime)"
' | while read namespace pod start_time; do
  start_sec=$(date -d "$start_time" +%s)
  age_sec=$((now - start_sec))
  if [ "$age_sec" -gt 86400 ]; then
    age_hr=$(echo "scale=2; $age_sec / 3600" | bc)
    echo "Namespace: $namespace | Pod: $pod | Age: ${age_hr}h"
  fi
done
