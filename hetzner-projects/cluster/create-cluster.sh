curl -sfL https://get.k3s.io | sh -
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.* $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo cat /var/lib/rancher/k3s/server/node-token

# add-worker-node.sh 
#curl -sfL https://get.k3s.io | K3S_URL=https://65.109.175.195:6443 K3S_TOKEN=K10a91a5dca384a27ba43b54fc11ee21400381824568b4ad4c6a0f9b54b45deed70::server:c1b61cd6e506056381d2cd15293fab71 sh -
