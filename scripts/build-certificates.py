import json
from os import path, getcwd, chdir
from subprocess import Popen, PIPE
from jinja2 import Template

base_path = path.dirname(path.abspath(__file__))
terradir = path.join(base_path, "../terraform")
template_file = path.join(path.dirname(path.abspath(__file__)), "../certificates/kubernetes-csr.json.j2")
content = open(template_file, "r").read()

template = Template(content)

def get_output_json():
    """ get ouput json """
    chdir(terradir)
    process = Popen(["terraform", "output", "-json"], stdout=PIPE, stderr=PIPE)
    out, err = process.communicate()
    if err:
        raise Exception("error outputing json")
    chdir(base_path)
    return {k: v["value"] for k, v in json.loads(out).items()}


def convert_ip_list(json_dict):
    """ json list dict """
    itms = json_dict.values()
    val = []
    for i in itms:
        if isinstance(i, list):
            for j in i:
                val.append(j)
    val.append(json_dict["elb_dns_name"])
    return json.dumps(val)


if __name__ == "__main__":
    val = get_output_json()
    hts = convert_ip_list(val)
    json_content = template.render(hosts=hts)
    certdir = path.join(base_path, "../gen_certs/kubernetes-csr.json")
    kubernetes_cert = open(certdir, "w")
    kubernetes_cert.write(json_content)
    kubernetes_cert.close()
    print(" ".join(json.loads(hts)))