#https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html
Subdomain: true
OperationsCenter:
  HostName: <HOSTNAME>
  Protocol: <PROTOCOL>
  #https://support.cloudbees.com/hc/en-us/articles/360058867672
  Platform: aws
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
