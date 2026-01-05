
#!/bin/bash

# 定义颜色，让输出好看点
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}>>> 1. 正在清理旧环境 (Destroying old cluster)...${NC}"
kind delete cluster --name my-lab

echo -e "${GREEN}>>> 2. 创建新集群 (Creating new cluster)...${NC}"
# 使用指定版本镜像，更稳定
kind create cluster --name my-lab --image kindest/node:v1.27.3

echo -e "${GREEN}>>> 3. 安装 Ingress Controller (Installing Nginx)...${NC}"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
# 等待 Ingress 就绪
echo "等待 Ingress Controller 启动 (这可能需要 1 分钟)..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo -e "${GREEN}>>> 4. 安装 Metrics Server (Installing Metrics)...${NC}"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# 这里的 Patch 是为了解决 Kind 环境下的 TLS 证书问题
kubectl patch -n kube-system deployment metrics-server --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

echo -e "${GREEN}>>> 5. 部署应用 (Deploying WordPress Stack)...${NC}"
kubectl apply -f manifests.yaml

echo -e "${GREEN}>>> 6. 等待应用启动 (Waiting for pods)...${NC}"
# 等待一段时间让数据库初始化
sleep 15
kubectl wait --for=condition=ready pod -l app=wordpress --timeout=120s

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}🎉 部署完成！(Deployed Successfully)${NC}"
echo -e "${GREEN}==============================================${NC}"
echo -e "请确保你的 /etc/hosts 文件里有: 127.0.0.1 my-blog.local"
echo -e "访问命令: kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80"
echo -e "浏览器打开: http://my-blog.local:8080"
