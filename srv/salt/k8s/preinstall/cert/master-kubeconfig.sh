#!/usr/bin/env bash
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cat <<EOF >master/kubeconfig
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /opt/kube-master/cert/master/ca.crt
  name: k8s
contexts:
- context:
    cluster: k8s
    user: server
  name: k8s
current-context: k8s
kind: Config
preferences: {}
users:
- name: server
  user:
    client-certificate: /opt/kube-master/cert/master/server.crt
    client-key: /opt/kube-master/cert/master/server.key
EOF
