#!/usr/bin/env bash
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

MASTER_ADDRESS=${1:-""}
SERVICE_CLUSTER_IP=${2:-""}
MASTER_NODE1_IP=${3:-""}
MASTER_NODE2_IP=${4:-""}
MASTER_NODE3_IP=${5:-""}
K8S_DOMAIN=${6:-""}
cat <<EOF >master-ssl.cnf
[req]
req_extensions = v3_req
distinguished_name =req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation,digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.${K8S_DOMAIN}
# ip address of master
IP.1 = ${MASTER_ADDRESS}
# master node1
IP.2 = ${MASTER_NODE1_IP}
# master node2
IP.3 = ${MASTER_NODE2_IP}
# master node3
IP.4 = ${MASTER_NODE3_IP}
# cluster ip of kubernetes service
IP.5 = ${SERVICE_CLUSTER_IP}
EOF

