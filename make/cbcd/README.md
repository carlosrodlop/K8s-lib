# CloudBees CD

## Known issues

Flow-server pod is entering into `CrashLoopBackOff` state due

```bash
Could not start amazon-efs-mount-watchdog, unrecognized init system "aws-efs-csi-dri" b'mount.nfs4: access denied by server while mounting 127.0.0.1:/
```

## Steps to check successful installation

- Helm output

```bash
NOTES:
- CloudBees Flow Server was successfully deployed

- CloudBees Flow Web was successfully deployed and is available at https://cd.crl.core.pscbdemos.com
  Username: admin



  Password:  Get your admin user password by running:
             kubectl get secret --namespace cbcd cbcd-server-cloudbees-flow-credentials -o jsonpath="{.data.CBF_SERVER_ADMIN_PASSWORD}" | base64 --decode; echo

- CloudBees Flow Devops Insight was successfully deployed

- CloudBees Flow Repository was successfully deployed
swiss-user@59cd24fb1b21:~/terraform-lib/libs/k8s/make/cbcd$ kubectl get secret --namespace cbcd cbcd-server-cloudbees-flow-credentials -o jsonpath="{.data.CBF_SERVER_ADMIN_PASSWORD}" | base64 --decode; echo
admin
```

- Check logs for Flow init job and Flow server
- Port forward to Flow web and check if it is working
