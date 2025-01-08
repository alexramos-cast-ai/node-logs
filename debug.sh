#!/bin/bash
# Only an initial POC boiler plate script to test if we can
# collect kubelet logs by deploying a daemonset and then
# exec into each daemonset pods to collect the journalctl logs output

# Deploy daemonset debugger-sh.yaml
kubectl apply -f https://raw.githubusercontent.com/alexramos-cast-ai/node-logs/refs/heads/main/debugger-ds.yaml
sleep 10

# Get all debuggerds pods
NODELOGDS=$(kubectl get pods -n castai-agent -l app=nodelog -o jsonpath='{.items[*].metadata.name}')

# Loop through all nodes
for POD in $NODELOGDS; do
    echo "Pod: $POD"
    kubectl exec -n castai-agent $POD -- chroot /host /bin/bash -c "journalctl -u kubelet" > $POD-kubelet.log
done

kubectl delete -f https://raw.githubusercontent.com/alexramos-cast-ai/node-logs/refs/heads/main/debugger-ds.yaml --now