OperationCenter:
  Protocol: <PROTOCOL>
  Hostname: <HOSTNAME>
  Ingress:
    Class: alb
  Casc:
    ControllerBundleStorageSCM: <C_CASC_REPO>
  Credentials:
    Github:
      Token: <SECRET_GH_TOKEN>
      User: <SECRET_GH_USER>
ManagedControllers:
  loadCount: <N_LOAD_CONTROLLERS>
Agents:
  Namespace: <AGENT_NAMESPACE>
