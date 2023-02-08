OperationsCenter:
  HostName: <HOSTNAME>
  Protocol: <PROTOCOL>
  Platform: eks
  Ingress:
    Class: alb
    Annotations:
      alb.ingress.kubernetes.io/scheme               : internet-facing
      alb.ingress.kubernetes.io/target-type          : ip
      alb.ingress.kubernetes.io/listen-ports         : [{"HTTP": 80}, {"HTTPS":443}]
      alb.ingress.kubernetes.io/certificate-arn      : <CERTIFICATE>
      alb.ingress.kubernetes.io/actions.ssl-redirect : {"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}
      external-dns.alpha.kubernetes.io/hostname      : <HOSTNAME>
  CasC:
    Enabled: true
  ConfigMapName: oc-casc-bundle
  ContainerEnv:
    - name: SECRETS
      value: /var/run/secrets/cjoc
  ExtraVolumes:
    - name: oc-secrets
      secret:
        secretName: oc-secrets
  ExtraVolumeMounts:
    - name: oc-secrets
      mountPath: /var/run/secrets/cjoc
      readOnly: true
  License:
    Evaluation:
      Enabled: true
      FirstName: Carlos
      LastName: Lopez
      Email: crodriguezlopez@cloudbees.com
      Company: cloudbees.com
Agents:
  SeparateNamespace:
    Enabled: true
    Name: <AGENT_NAMESPACE>
