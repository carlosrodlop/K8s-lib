#!/bin/bash

cd ../../../clouds/aws/root/alpha/01_infra/ && terraform output -json | yq eval -P -
cd - > /dev/null || true
