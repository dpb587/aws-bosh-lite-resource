{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Description": "dpb587/aws-bosh-lite-resource",
  "Mappings": {
    "RegionMap": ( [
      . | split("\n") | map(select(. != "")) | .[] | split(" ") | {
        (.[0]) : {
          "Ami": (.[1])
        }
      }
    ] | add )
  },
  "Resources": {
    "BoshLite": {
      "Type": "AWS::EC2::Instance",
      "Properties": {
        "AvailabilityZone": $params.availability_zone,
        "ImageId": {
          "Fn::FindInMap": [
            "RegionMap",
            {
              "Ref": "AWS::Region"
            },
            "Ami"
          ]
        },
        "InstanceType": $params.instance_type,
        "KeyName": $params.key_name,
        "PrivateIpAddress": (
          if null != $params.private_ip then
            $params.private_ip
          else
            {
              "Ref": "AWS::NoValue"
            }
          end
        ),
        "SecurityGroupIds": $params.security_group_id,
        "SubnetId": $params.subnet_id,
        "Tags": [
          {
            "Key": "Name",
            "Value": {
              "Ref": "AWS::StackName"
            }
          }
        ]
      }
    }
  },
  "Outputs": {
    "BoshLitePrivateIp": {
      "Description": "Private IP of the bosh-lite instance",
      "Value": {
        "Fn::GetAtt": [
          "BoshLite",
          "PrivateIp"
        ]
      }
    }
  }
}
