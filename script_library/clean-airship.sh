#delete ucp helm charts

helm ls -a | grep ucp | awk 'NR >= 1 {print $1 }' | xargs helm delete $line --purge

helm delete --purge airship-ingress-kube-system

#delete opennstack helm charts
helm ls -a | grep openstack | awk 'NR >= 1 {print $1 }' | xargs helm delete $line --purge

sleep 30

#in case the helm delete didn't do its job
kubectl delete --all deployments -n ucp
kubectl delete --all deployments -n openstack
# make sure all pods are deleted especially test pods
kubectl delete --all pods -n ucp
kubectl delete --all pods -n openstack
kubectl delete pod -n kube-system --ignore-not-found -l app=ingress-api,application=ingress,component=server
kubectl delete pod -n kube-system --ignore-not-found -l application=ingress,component=error-pages

kubectl delete --all pvc -n ucp
kubectl delete --all pvc -n openstack
kubectl delete --all pv -n ucp
kubectl delete --all pv -n openstack

kubectl delete configmap --namespace kube-system airship-ingress-kube-system-nginx-cluster
kubectl delete --all configmaps --namespace=ucp
kubectl delete --all configmaps --namespace=openstack

kubectl delete sc --ignore-not-found general
kubectl delete serviceaccount --all -n openstack
kubectl delete serviceaccount --all -n ucp
kubectl delete serviceaccount --all -n ceph
kubectl delete secret --all -n openstack
kubectl delete secret --all -n ucp
kubectl delete secret --all -n ceph


# DO NOT USE clusterrolebinding, else you will delete all rolebindings, even the suse: and system: ones,
# even when scoped in the namespace.
kubectl get -n openstack rolebinding.rbac.authorization.k8s.io -o name | xargs kubectl -n openstack delete

# Remove extra data
kubectl delete clusterrolebinding --ignore-not-found PrivilegedRoleBinding
kubectl delete clusterrolebinding --ignore-not-found NonResourceUrlRoleBinding

kubectl delete namespace --ignore-not-found openstack
kubectl delete namespace --ignore-not-found ceph
kubectl delete namespace --ignore-not-found ucp


# Need to keep them idempotent
if [[ $(docker images -a | grep "airship" | wc -c) > 0 ]]; then
    docker images -a | grep "airship" | awk '{print $3}' | xargs docker rmi -f
fi

sudo rm -rf /opt/airship-*
sudo rm -rf /opt/openstack-helm*
