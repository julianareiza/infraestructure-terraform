# 1. Instalar el controller de ARC
kubectl apply -f service-account.yml

helm install arc \
  --namespace arc-systems \
  --create-namespace \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller

# 2. Instalar el runner set apuntando a tu repo

#app-ge repo
helm install arc-runner-set-app \
  --namespace arc-runners \
  --create-namespace \
  --set githubConfigUrl="https://github.com/julianareiza/app-ge" \
  --set githubConfigSecret.github_token="${GITHUB_ACCESS_TOKEN}" \
  --set template.spec.serviceAccountName=arc-runner-sa \
  --set containerMode.type=dind \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set

#infra repo
helm upgrade arc-runner-set-infra \
  --namespace arc-runners \
  --create-namespace \
  --set githubConfigUrl="https://github.com/julianareiza/infraestructure-terraform" \
  --set githubConfigSecret.github_token="${GITHUB_ACCESS_TOKEN}" \
  --set template.spec.serviceAccountName=arc-runner-sa-iac \
  --set containerMode.type=dind \
  oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set

# 3. Verificar que todo esté corriendo
kubectl get pods -n arc-systems
kubectl get pods -n arc-runners