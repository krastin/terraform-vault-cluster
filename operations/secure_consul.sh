#!/usr/bin/env bash

# $consul_nodes is a space delimetered list of consul hosts
for consul_node in "${consul_nodes}"; do
  echo Copying files to node $consul_node
  scp -i ~/.ssh/krastin-key1-hashi-euc1.pem -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -l ubuntu ./consul_configs 3.122.52.125:/tmp/
done



consul@ip-10-1-0-10:~$ cp acl.hcl /etc/consul.d/
consul@ip-10-1-0-10:~$ sudo systemctl restart consul
consul@ip-10-1-0-10:~$ consul acl bootstrap | tee consul-mgmt.token
consul@ip-10-1-0-10:~$ mgmttoken=$(cat consul-mgmt.token | grep SecretID: | awk '{ print $NF }')
consul@ip-10-1-0-10:~$ consul acl policy create -token=$mgmttoken -name node-policy -rules @node-policy.hcl
consul@ip-10-1-0-10:~$ consul acl token create -token=$mgmttoken -description "node token" -policy-name node-policy | tee node.token
consul@ip-10-1-0-10:~$ nodetoken=$(cat node.token | grep SecretID: | awk '{ print $NF }')
consul@ip-10-1-0-10:~$ consul acl set-agent-token -token=$mgmttoken agent $nodetoken
consul@ip-10-1-0-10:~$ consul acl policy create -token=$mgmttoken -name vault-policy -rules @vault-policy.hcl
consul@ip-10-1-0-10:~$ consul acl token create -token=$mgmttoken -description "Token for Vault Service" -policy-name vault-policy | tee vault.token
consul@ip-10-1-0-10:~$ vaulttoken=$(cat vault.token | grep SecretID: | awk '{ print $NF }')
