#!/usr/bin/env bash

printf "args: %s\n" "$@"

while read line; do
  printf "This is not a drill!: %s\n" "$line"
done