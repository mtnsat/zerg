Simple Amazon CloudFormation driver for Zerg
===

Dependencies
--------------

- [fog](http://fog.io/)

Additional properties defined
--------------

######[Driver options](resources/option_schema.template)

- access_key_id - AWS access key id
- secret_access_key - AWS secret. 
- template - body of a AWS CloudFormation template
- template_parameters - 

Example use:
```
...
"driver": {
    "drivertype": "cloudformation",
    "driveroptions": [
        {
            "access_key_id": "ENV['AWS_ACCESS_KEY_ID']",
            "secret_access_key": "ENV['AWS_SECRET_ACCESS_KEY']",
            "template": {
                ...
            },
            "template_parameters": {
                "Param1": "value",
                "Param2": "ENV['SOME_VARIABLE']"
            }
        }
    }
}
...
```

Additional properties defined
--------------

num_instances is ignored (always 1)