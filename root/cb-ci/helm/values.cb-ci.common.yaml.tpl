#Common_Configuration
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
    Name: cbci-agents
