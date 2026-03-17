#!/usr/bin/env bash
# Common functions for all tests
#
# @author: Navarro Torres, Agustín
# @email: agusnt@unizar.es
#
# @version: 0.0.1

#####################################################################################
# Auxiliary functions
randomStringForTmpFile() {
  # Return a random file in /tmp
  echo "/tmp/$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 16)"
}

createTmpFile() {
  # Create a temporal file
  tmpFile=$(randomStringForTmpFile)
  until [ ! -f "$tmpFile" ]; do tmpFile=$(randomStringForTmpFile); done

  # Create file
  touch "$tmpFile"

  # Return file
  echo -n "$tmpFile"
}

removeTmpFile() {
  # Clean temporal file
  rm -f "$1"
}

createContentFile() {
  # Create a temporal file
  tmpFile=$(createTmpFile)

  # Random string
  randomString=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$1")

  # Populate temporal file
  echo "$randomString" >> "$tmpFile"
  echo "$tmpFile" "$randomString"
}
#####################################################################################
