#!/bin/sh -eu

target=$( cat bosh-lite/target )

curl -sk https://$target:25555/info \
  | jq '.'
