#EKS+ALB
Subdomain: true
OperationsCenter:
  HostName: <HOSTNAME>
  Protocol: <PROTOCOL>
  Platform: eks
  Ingress:
    Class: alb
    Annotations:
      #Default annotations per platform https://github.com/cloudbees/cloud-platform-v2/blob/master/helm-chart/cloudbees-core/templates/_helpers.tpl
      alb.ingress.kubernetes.io/scheme               : internet-facing
      alb.ingress.kubernetes.io/certificate-arn      : <CERTIFICATE>
      external-dns.alpha.kubernetes.io/hostname      : <HOSTNAME>
