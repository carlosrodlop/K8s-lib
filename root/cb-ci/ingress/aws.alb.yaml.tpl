Ingress:
  Class: alb
  Annotations:
    alb.ingress.kubernetes.io/scheme               : internet-facing
    alb.ingress.kubernetes.io/target-type          : ip
    alb.ingress.kubernetes.io/listen-ports         : [{"HTTP": 80}, {"HTTPS":443}]
    alb.ingress.kubernetes.io/certificate-arn      :
    alb.ingress.kubernetes.io/actions.ssl-redirect : {"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}
    external-dns.alpha.kubernetes.io/hostname      :
