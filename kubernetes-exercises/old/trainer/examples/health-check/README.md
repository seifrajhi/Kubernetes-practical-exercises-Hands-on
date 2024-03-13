# Health and live probes

Start `pod.yaml`

Run three shells:

1. `kubectl describe pod probing| grep -A20 Events`
2. `watch kubectl get pods -o wide`
3. `kubectl exec -ti probing sh`

- in [3] try to delete /tmp/ready , and see that
  the status in [2] changes.
- make the file again.
- in [3] try to delete the /tmp/health and see
  that after the failureThreshold, the pod will be
  restarted
