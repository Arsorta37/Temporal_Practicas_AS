#!/usr/bin/env bats
# @author: Navarro Torres, Agustín
# @email: agusnt@unizar.es
#
# @version: 0.0.1

FILE='../practica2/practica2_3.sh'
load "./test_common.sh"

@test "Check the shellbang" {
  # Read the head
  run head -n 1 "$FILE"
  
  # Ensure that head -n 1 is executed
  [ "$status" -eq 0 ] 

  # Check if the shellbang is right
  REGEX='^#!(/usr/bin/env bash|/usr/bin/bash|/bin/bash)$'
  [[ "$output" =~ $REGEX ]]
}

@test "File doesn't exist" {
  # Create random string, and ensure that the file does not exist
  tmpFile=$(randomStringForTmpFile)
  until [ ! -f "$tmpFile" ]; do tmpFile=$(randomStringForTmpFile); done

  # Execute script
  run $FILE "$tmpFile"

  REGEX="(no existe.*$tmpFile)|($tmpFile.*no existe)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    exit 1
  fi
}

@test "No parameters" {
  # Execute script
  run $FILE

  REGEX="(sintaxis.* practica2_3.sh <nombre_archivo>)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    exit 1
  fi
}

@test "Three parameters" {
  # Execute script
  run $FILE "a" "b" "c"

  REGEX="(sintaxis.* practica2_3.sh <nombre_archivo>)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    exit 1
  fi
}

@test "Change permission file" {
  # Create file
  tmpFile=$(createTmpFile)
  chmod 000 "$tmpFile"

  # Execute script
  run $FILE "$tmpFile"

  REGEX="^-..x..x...$"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    exit 1
  fi

  # Verify the actual permissions changed
  if [[ "$output" == "$(stat -c \"%A\" ""$tmpFile"")" ]]; then
    exit 1
  fi

  removeTmpFile "$tmpFile"
}
