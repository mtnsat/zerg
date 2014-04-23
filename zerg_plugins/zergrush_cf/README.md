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
- template - body of a AWS CloudFormation template (use this OR template_file)
- template_file - file containing the CloudFormation template. Path is relative to location of .ke task file in .hive (use this OR template)
- template_parameters - parameter values for the cloudformation template
- rabbit - optional information on a rabbitmq server to publish event log to
- storage - optional information on an S3 bucket to upload files from "additional_files_section" of zerg to.

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
            "template_file": "template_file.json",
            "template_parameters": {
                "Param1": "value",
                "Param2": "ENV['SOME_VARIABLE']"
            },
            "rabbit": {
                "bunny_params": {
                    ...
                },
                "queue": {
                    "name": "your rabbit queue",
                    "params": {
                        "durable": true,
                        <other bunny queue parameters>
                    }
                },
                "exchange": {
                    "name": "your rabbit exchange",
                    "params": {
                        "durable": true,
                        <other bunny exchange parameters>
                    }
                },
                "event_timestamp_name": "happened at:",
                "event_resource_id_name": "CF Resource ID:",
                "event_resource_type_name": "CF Resource Type:",
                "event_resource_status_name": "CF Resource Status:",
                "event_resource_reason_name": "What up?"
            },
            "storage": {
                "s3_bucket": {
                    "name": "my_task_storage",
                    "public": false,
                    "files": [
                        "first_to_file_from_additional_files_section.extension",
                        "second_to_file_from_additional_files_section.extension"
                    ]
                }
            }
        }
    }
}
...
```

Additional properties defined
--------------

num_instances is ignored (always 1)