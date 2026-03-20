# 1. Namespace
kubectl create namespace observability

# 2. Prometheus + Grafana
helm upgrade --install kube-prom prometheus-community/kube-prometheus-stack \
  -n observability \
  -f helm-values/kube-prometheus-stack.yml \
  --wait --timeout 10m

# 3. Loki
helm upgrade --install loki grafana/loki \
  -n observability \
  -f helm-values/loki.yml \
  --wait --timeout 10m

# 4. Tempo
helm upgrade --install tempo grafana/tempo \
  -n observability \
  -f helm-values/tempo.yml \
  --wait --timeout 10m

# 5. OTel Collector
docker pull otel/opentelemetry-collector-contrib:0.128.0
kubectl apply -f k8s/otel-collector/

# ingress 
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.metrics.enabled=true \
  --set controller.metrics.serviceMonitor.enabled=true


# por forward ingress
kubectl port-forward svc/ingress-nginx-controller 8080:80 -n ingress-nginx 
kubectl port-forward svc/kube-prom-grafana 3000:80 -n observability
