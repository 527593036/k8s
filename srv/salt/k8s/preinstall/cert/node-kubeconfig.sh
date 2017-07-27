#!/usr/bin/env bash
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cat <<EOF >node/kubeconfig
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /opt/kube-node/cert/node/ca.crt
  name: k8s
contexts:
- context:
    cluster: k8s
    user: kubelet
  name: k8s
current-context: k8s
kind: Config
preferences: {}
users:
- name: kubelet
  user:
    client-certificate: /opt/kube-node/cert/node/kubelet.crt
    client-key: /opt/kube-node/cert/node/kubelet.key
EOF