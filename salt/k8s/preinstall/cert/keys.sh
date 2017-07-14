K8S_MASTER="k8s-master"
K8S_NODE="k8s-node"

# 清理文件
rm -f ca.crt ca.key master/* node/* 

# 生成CA证书和密钥
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -subj "/CN=k8s.org" -days 10000 -out ca.crt

# 生成master节点的证书和密钥
openssl genrsa -out master/server.key 2048
openssl req -new -key master/server.key -subj "/CN=$K8S_MASTER" -config master-ssl.cnf -out master/server.csr
openssl x509 -req -in master/server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 10000 -extensions v3_req -extfile master-ssl.cnf -out master/server.crt
cp ca.crt master;rm -f ca.srl master/server.csr

# 生成worker节点的证书和密钥
openssl genrsa -out node/kubelet.key 2048
openssl req -new -key node/kubelet.key -subj "/CN=$K8S_NODE" -out node/kubelet.csr
openssl x509 -req -in node/kubelet.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 10000 -out node/kubelet.crt
cp ca.crt node;rm -f ca.srl node/kubelet.csr
