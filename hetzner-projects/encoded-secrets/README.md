https://jenkinsci.github.io/kubernetes-credentials-provider-plugin/examples/
https://github.com/jenkinsci/kubernetes-credentials-provider-plugin/tree/master/docs/examples
https://medium.com/codex/sealed-secrets-for-kubernetes-722d643eb658
echo -n "***" | base64

cat dockerhub-login.yaml| kubeseal \
    --controller-namespace kube-system \
    --controller-name sealed-secrets-controller \
    --format yaml \
    > sealed-secret.yaml
