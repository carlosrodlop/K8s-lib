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
