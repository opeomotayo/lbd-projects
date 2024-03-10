# How I deployed Jenkins

* ### Clone official Jenkins chart
```
git clone https://github.com/jenkinsci/helm-charts.git
```

* ### Create values-override.yaml to override the default values

* ### Update ingress.yaml file for host/domain name configuration

* ### Create crbac.yaml file for cluster-role service account

* ### Create cred-sealed-secrets directory to store sealed secrets credentials

* ### Create jenkins-casc.yaml file override the default values and store Jenkins configurations as code:
    *new/additional plugins* <br/>
    *tools configurations* <br/>
    *dsl-jobs/seed job configurations* <br/>
    *sharerd library configurations* <br/>
    *email notification configurations* <br/>
    *jenkins url configurations* <br/>

* ### Run the below commands to test installation
```
helm -n jenkins show values jenkins
helm -n jenkins get values jenkins
helm template jenkins -f jenkins/values-override.yaml > template-outputs/jenkins.yaml 
helm -n jenkins upgrade --install jenkins jenkins -f jenkins/values-override.yaml
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo
```

* ### To deploy with Argo CD 
Create jenkins.yaml file within argocd/apps/ directory

* ### Run the below command to create Jenkins 
```
kubectl apply -f apps/jenkins.yaml
```
