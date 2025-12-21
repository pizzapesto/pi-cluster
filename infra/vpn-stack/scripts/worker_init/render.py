import os, sys
from jinja2 import Template

src, dst = sys.argv[1], sys.argv[2]
tpl = open(src, "r", encoding="utf-8").read()
out = Template(tpl).render(
    API_URL=os.environ["API_URL"],
    CF_ACCESS_CLIENT_ID=os.environ["CF_ACCESS_CLIENT_ID"],
    CF_ACCESS_CLIENT_SECRET=os.environ["CF_ACCESS_CLIENT_SECRET"],
    K8S_MINOR=os.environ["K8S_MINOR"],
    CONTROLPLANE_ENDPOINT=os.environ["CONTROLPLANE_ENDPOINT"],
    KUBEADM_TOKEN=os.environ["KUBEADM_TOKEN"],
    DISCOVERY_TOKEN_CA_CERT_HASH=os.environ["DISCOVERY_TOKEN_CA_CERT_HASH"],
)
open(dst, "w", encoding="utf-8").write(out)
print("rendered:", dst)