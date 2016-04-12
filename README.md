# aws-bosh-lite-resource

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)

A [Concourse](https://concourse.ci/) resource for deploying [bosh-lite](https://github.com/cloudfoundry/bosh-lite) instances to your [AWS](https://aws.amazon.com/) environment. It extends the [`aws-cloudformation-stack-resource`](https://github.com/dpb587/aws-cloudformation-stack-resource) to automatically look up the latest bosh-lite version and use a generated stack template.


## Source Configuration

Parameters:

 * **`access_key`** - AWS access key
 * **`availability_zone`** - availability zone to deploy into
 * **`name`** - the stack name
 * **`secret_key`** - AWS secret key
 * **`security_group_id`** - security group ID(s) to use on the instance (comma separated)
 * **`subnet_id`** - subnet ID to deploy into
 * `instance_type` - instance type to use (default: `c3.xlarge`)
 * `key_name` - key pair name to use (default: `default`)
 * `private_ip` - specific IP to use on the VM (default: auto-assign)
 * `version` - specific bosh-lite version to use (default: `latest`, example: `9000.109.0`)


## Behavior


### `check`

Trigger when the bosh-lite is successfully created or updated.


### `in`

Pulls down bosh-lite instance details. Internal [stack data](https://github.com/dpb587/aws-cloudformation-stack-resource#in) is available in the `/stack` directory.

 * `/target` - bosh-lite IP address

Parameters:

 * `allow_deleted` - by default the resource will fail when referencing a deleted bosh-lite (default `false`)


### `out`

Create, update, or delete the bosh-lite stack.

 * `delete` - set to `true` to delete the instance (default `false`)


## Example

The following job is an example of creating a bosh-lite instance, deploying something to it, running some tests which use it, and then always destroying bosh-lite afterwards.

    jobs:
      - name: "integration-test"
        plan:
          - get: "repo"
            trigger: true
          - put: "bosh-lite"                                        # +
          - do:
              - put: "integration-deployment"
                params:
                  manifest: "repo/ci/integration-test/manifest.yml"
                  stemcells:
                    - path/to/stemcells-*.tgz
                  releases:
                    - path/to/releases-*.tgz
              - task: "integration-test"
                path: "repo/ci/task/integration-test/config.yml"
                params:
                  director: "192.0.2.80"
            ensure:
              put: "bosh-lite"                                      # +
              params: { delete: true }                              # +
              get_params: { allow_deleted: true }                   # +
    resources:
      - name: "repo"
        type: "git"
        source:
          uri: {{repo_uri}}
          branch: {{repo_branch}}
      - name: "bosh-lite"                                           # +
        type: "aws-bosh-lite"                                       # +
        source:                                                     # +
          access_key: "my-aws-access-key"                           # +
          availability_zone: "us-west-1b"                           # +
          key_name: "devtest"                                       # +
          name: "bosh-lite"                                         # +
          private_ip: "192.0.2.80"                                  # +
          secret_key: "my-aws-secret-key"                           # +
          subnet_id: "subnet-a1b2c3d4"                              # +
          security_group_id: "sg-b2c3d4e5"                          # +


## Installation

This resource is not included with the standard Concourse release. Use one of the following methods to make this resource available to your pipelines.


### Deployment-wide

To install on all Concourse workers, update your deployment manifest properties to include a new `groundcrew.additional_resource_types` entry...

    properties:
      groundcrew:
        additional_resource_types:
          - image: "docker:///dpb587/aws-bosh-lite-resource#master" # +
            type: "github-status"                                   # +


### Pipeline-specific

To use on a single pipeline, update your pipeline to include a new `resource_types` entry...

    resource_types:
      - name: "github-status"                         # +
        type: "docker-image"                          # +
        source:                                       # +
          repository: "dpb587/aws-bosh-lite-resource" # +
          tag: "master"                               # +


## Notes

Due to the way AWS CloudFormation performs updates, upgrading an existing instance to a newer bosh-lite version will fail when using static private IPs because the new instance will be created before the old one is terminated. Instead, either avoid long-running bosh-lite instances or allow AWS to auto-assign the private IP.


## License

[MIT License](./LICENSE)
