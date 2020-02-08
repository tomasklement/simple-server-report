#!/usr/bin/env bash

result=$(
  df \
-h 
)

echo "${result}"