
# Script: List Pods with Age > 24h Excluding `openshift-*` Namespaces

This guide provides a script to list all pods in a Kubernetes/OpenShift cluster that have been running for **more than 24 hours**, excluding system namespaces that start with `openshift-`.

---

## Script

```bash
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
```

---

## Requirements

- OpenShift or Kubernetes CLI (`oc` or `kubectl`)
- [`jq`](https://stedolan.github.io/jq/) for JSON parsing
- Bash shell environment

---

## Installation of jq

On Fedora/RHEL:
```bash
sudo dnf install jq
```

On Debian/Ubuntu:
```bash
sudo apt install jq
```

---

## References

- Kubernetes API Reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.29/#pod-v1-core
- OpenShift CLI: https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/developer-cli-commands.html
