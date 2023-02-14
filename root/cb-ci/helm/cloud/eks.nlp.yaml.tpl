#https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html
#Trying to create NLP without NGINX as explained in https://www.eksworkshop.com/docs/fundamentals/exposing/loadbalancer/adding-lb fails with
#Error: UPGRADE FAILED: failed to create resource: admission webhook vingress.elbv2.k8s.aws denied the request: invalid ingress class: IngressClass.networking.k8s.io nginx not found
Subdomain: true
OperationsCenter:
  HostName: <HOSTNAME>
  Protocol: <PROTOCOL>
  #https://support.cloudbees.com/hc/en-us/articles/360058867672
  Platform: aws
  ServiceType: LoadBalancer
  ServiceAnnotations:
    service.beta.kubernetes.io/aws-load-balancer-type: external
    service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: instance
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
