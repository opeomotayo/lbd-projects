 curl -sfL https://get.k3s.io | sh -
 mkdir -p $HOME/.kube
 sudo cp /etc/rancher/k3s/k3s.* $HOME/.kube/config
 sudo chown $(id -u):$(id -g) $HOME/.kube/config
