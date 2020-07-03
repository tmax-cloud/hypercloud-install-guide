CLUSTER_CONTEXTS="cluster1 cluster2"
for c in ${CLUSTER_CONTEXTS}; do
    echo ----- ${c} -----
    kubectl --context=${c} api-resources --api-group=tmax.co.kr
done
