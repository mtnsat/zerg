Zerg test tasks
=========

Import tasks:

```
zerg hive import chef_client.ke
zerg hive import chef_solo.ke
```

Setup environment variables:

- ZERG_TEST_CHEF_SERVER - url of chef server
- ZERG_TEST_CHEF_VALIDATOR - path to validator key file
- ZERG_TEST_COOKBOOKS_PATH - path to zerg test_cookbooks directory
- ZERG_TEST_CHEF_CLIENTKEY - path to client key .pem
- ZERG_TEST_CHEF_CLIENTNAME - validator name (i.e. 'chef-validator')
- AWS_ACCESS_KEY_ID - AWS key id
- AWS_SECRET_ACCESS_KEY - AWS secret key
- AWS_PRIVATE_KEY_PATH - AWS key pair name
- AWS_PRIVATE_KEY_PATH - path to the private key .pem
=