https://docs.dapr.io/operations/monitoring/logging/fluentd/

sh '''

helm install elasticsearch elasticsearch --version 7.17.3 -n logging --set replicas=1 -f elasticsearch/values-override.yaml

helm install kibana kibana --version 7.17.3 -n logging -f kibana/values-override.yaml

k apply -f fluentd -n logging
'''
