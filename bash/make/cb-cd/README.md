# cd-cd

Init Containers `volumen-permissions`` for Pods flow-server, doris and repository are hitting this issue which leaves the Pod in a Pending state

```bash
chown -R 1000:1000 /repository-data
chown: changing ownership of ‘/repository-data’: Operation not permitted
```
