#!/usr/bin/env bats
#
# Basic tests for exercise 5 from lab 2
#
# @author: Navarro Torres, Agustín
# @email: agusnt@unizar.es
#
# @version: 0.0.1

FILE="$(realpath "${BATS_TEST_DIRNAME}/../../src/Pr2/practica2_5.sh")"
load "../common.sh"

outputError() {
  # Generate output error for students
  echo "Error with input: $1, actual output: $2, expected output: $3"
}

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

@test "Directory doesn't exists" {
  until [ ! -d "$tmpFile" ]; do tmpFile=$(randomStringForTmpFile); done

  run bash "$FILE" <<< "$tmpFile"

  local regex=".*[[:space:]]+no[[:space:]]+es.*[Dd]irectorio"

  if [[ ! "$output" =~ $regex ]]; then
    exit
  fi
}

@test "Check the script" {
  while True; do
    dir=$(find "/etc" -maxdepth 3 -type d 2>/dev/null | shuf -n 1)
    run bash "$FILE" <<< "$dir"

    files=$(find "$dir" -maxdepth 1 -type f | wc -l)
    folder=$(find "$dir" -maxdepth 1 -type f | wc -l)


    # Only use regular expression to check the number of files and directories
    if [[ ! "$output" =~ $files ]]; then
      >&2 echo "Wrong number of files, it should be: $files (directory tested: $dir)"
      exit
    fi

    if [[ ! "$output" =~ $folder ]]; then
      >&2 echo "Wrong number of files, it should be: $folder (directory tested: $dir)"
      exit
    fi

    if [[ $files -gt 0 ]] && [[ $folder -gt 0 ]]; then
      break
    fi
  done
}
