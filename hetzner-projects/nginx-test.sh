kubectl create deployment nginx --image=nginx:alpine

kubectl expose deployment nginx \
--port 80 \
--target-port 80 \
--type ClusterIP \
--selector=app=nginx \
--name nginx

export CLUSTER_IP=$(kubectl get svc/nginx -o go-template='{{(index .spec.clusterIP)}}')
echo CLUSTER_IP=$CLUSTER_IP
lynx $CLUSTER_IP:80
