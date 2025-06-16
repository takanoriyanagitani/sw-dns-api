#!/bin/sh

export ENV_TARGET_NAME=example.com

ENV_TYPE=a ./simpledns | jq -c
ENV_TYPE=aaaa ./simpledns | jq -c
ENV_TYPE=mx ./simpledns | bat --language=log
ENV_TYPE=ns ./simpledns | jq -c
ENV_TYPE=soa ./simpledns | jq -c
ENV_TYPE=txt ./simpledns | jq -c
