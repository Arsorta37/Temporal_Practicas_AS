#!/usr/bin/env bash
#
# Common functions for all tests
#
# @author: Navarro Torres, Agustín
# @email: agusnt@unizar.es
#
# @version: 0.0.1

#####################################################################################
# Common Vars
TMP_FOLDER="/tmp/AS_UNIZAR_LABS"
PIPE="$TMP_FOLDER/pipe"
SCRIPT_PID=""

# Temporal files, you should not change this
TMP_FILE="$TMP_FOLDER/create"
TMP_ADDR="$TMP_FOLDER/addr"

# The maximum time that a test can run (30 seconds)
BATS_TEST_TIMEOUT=30

#####################################################################################
# Common tests

# Check shellbang
check_shellbang() {
  if [[ ! -f "$1" || ! -s "$1" ]]; then
    >&2 echo "File does not exist or is empty"
    return 1
  fi
  
  REGEX='^#!(/usr/bin/env bash|/usr/bin/bash|/bin/bash)$'
  foo=$(head -n 1 "$1")
  if [[ $foo =~ $REGEX ]]; then
    return 0
  else
    >&2 echo "The shell bang is not right"
    return 1
  fi
}

check_students() {
  if [[ ! -f "$1" || ! -s "$1" ]]; then
    >&2 echo "File does not exist or is empty"
    return 1
  fi
  
  REGEX='^#!(/usr/bin/env bash|/usr/bin/bash|/bin/bash)$'
  foo=$(head -n 1 "$1")
  if [[ $foo =~ $REGEX ]]; then
    return 0
  else
    >&2 echo "The shell bang is not right"
    return 1
  fi
}

check_students() {
  REGEX='^#.**[0-9][0-9][0-9][0-9][0-9].*[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ -.]+.*[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ -.]+, [MT].*[0-9].*[AB]$'
  if [[ "$(sed -n "2p" "$1")" =~ $REGEX ]]; then
    return 0
  else
    >&2 echo "Wrong user header! # NIP, Apellidos,  Nombre,  [MT],  [1-5],  [AB]"
    return 1
  fi
}

#####################################################################################
# Common setup
setup() {
  # This function is called at the beginning of each test and prepare the environment
  dirname "$(realpath "$1")" >/dev/null 2>&1
  mkdir "$TMP_FOLDER" >/dev/null 2>&1

  # Create a pipe needed for some test
  mkfifo "$PIPE" >/dev/null 2>&1
  REGEX='^#[0-9][0-9][0-9][0-9][0-9],[\s][a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s\-\.]+,[\s]*[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s\-\.]+,[\s]*[MT],[\s]*[1-5],[\s]*[AB]$'
  if [[ "$(sed -n "2p" "$1")" =~ $REGEX ]]; then
    return 0
  else
    >&2 echo "Wrong user header! NIP, Apellidos,  Nombre,  [MT],  [1-5],  [AB]"
    return 1
  fi
}

#####################################################################################
# Common setup
setup() {
  # This function is called at the beginning of each test and prepare the environment
  dirname "$(realpath "$1")" >/dev/null 2>&1
  mkdir "$TMP_FOLDER" >/dev/null 2>&1

  # Create a pipe needed for some test
  mkfifo "$PIPE" >/dev/null 2>&1

  if [ ! -z "$IPS" ]; then
    echo -n "" > "$TMP_ADDR"
    for ip_ in "${IPS[@]}"; do
      echo "$ip_" >> "$TMP_ADDR"
    done
  fi
}

teardown() {
  # This function is called at the end of each test and destroy the environment
  rm -rf "$TMP_FOLDER" >/dev/null 2>&1

  # Some test requires killing an script
  kill "$SCRIPT_PID" >/dev/null 2>&1 || true
}

#####################################################################################
# Auxiliary functions
randomStringForTmpFile() {
  # Return a random file in /tmp
  echo "$TMP_FOLDER/$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 16)"
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

removeTmpDir() {
  # Clean temporal directory
  rm -rf "$1"
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
