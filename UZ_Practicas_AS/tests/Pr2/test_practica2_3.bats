#!/usr/bin/env bats
#
# Basic tests for exercise 3 from lab 2
#
# @author: Navarro Torres, Agustín
# @email: agusnt@unizar.es
#
# @version: 0.0.1

FILE="$(realpath "${BATS_TEST_DIRNAME}/../../src/Pr2/practica2_3.sh")"
load "../common.sh"


@test "Script ($FILE) exists" {
  # Read the head
  [ -f "$FILE" ]
}

@test "Check the shellbang" {
  # Check if the shellbang is right
  run check_shellbang "$FILE"
  echo "$output"
  [ "$status" -eq 0 ] 
}

@test "Check students name" {
  # Read the head
  run check_students "$FILE"
  echo "$output"
  [ "$status" -eq 0 ] 
}

@test "File doesn't exists" {
  # Create random string, and ensure that the file does not exists
  tmpFile=$(randomStringForTmpFile)
  until [ ! -f "$tmpFile" ]; do tmpFile=$(randomStringForTmpFile); done

  # Execute script
  run $FILE "$tmpFile"

  # Check that the user doesn't exists
  REGEX="(no existe.*$tmpFile)|($tmpFile.*no existe)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    exit 1
  fi
}

@test "No parameters" {
  # Execute script
  run $FILE

  # Check that the user doesn't exists
  REGEX="(sintaxis.* practica2_3.sh <nombre_archivo>)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    exit 1
  fi
}

@test "Three parameters" {
  # Execute script
  run $FILE "a" "b" "c"

  # Check that the user doesn't exists
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

  echo "$output" >&2
  # Check that the user doesn't exists
  REGEX="^-..x..x...$"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    exit 1
  fi

  # Check that the permisison really change
  if [[ "$output" == "$(stat -c \"%A\" ""$tmpFile"")" ]]; then
    exit 1
  fi

  removeTmpFile "$tmpFile"
}
