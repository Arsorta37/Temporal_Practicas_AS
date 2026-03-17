#!/usr/bin/env bats
#
# Basic tests for exercise 2 from lab 2
#
# @author: Navarro Torres, Agustín
# @email: agusnt@unizar.es
#
# @version: 0.0.1

FILE="$(realpath "${BATS_TEST_DIRNAME}/../../src/Pr2/practica2_2.sh")"
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
  REGEX="(no.*fichero.*$tmpFile)|($tmpFile.*no.*fichero)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    exit 1
  fi
}

@test "File is a directory" {
  # Create random string, and ensure that the file does not exists
  tmpFile=$(randomStringForTmpFile)
  until [ ! -f "$tmpFile" ]; do tmpFile=$(randomStringForTmpFile); done
  until [ ! -d "$tmpFile" ]; do tmpFile=$(randomStringForTmpFile); done
  
  mkdir "$tmpFile"

  # Execute script
  run $FILE "$tmpFile"

  # Check that the user doesn't exists
  REGEX="(no.*fichero.*$tmpFile)|($tmpFile.*no.*fichero)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    rmdir "$tmpFile"
    exit 1
  fi

  rmdir "$tmpFile"
}

@test "Test pager" {
  # Create random string, and ensure that the file does not exists
  tmpFileAndContent=$(createContentFile 4000)

  # Name of the temporal file and content
  tmpFile=$(echo "$tmpFileAndContent" | cut -d' ' -f1)
  tmpFileContent=$(echo "$tmpFileAndContent" | cut -d' ' -f2-)

  # Ensure that they use more
  run cat "$FILE"
  if ! grep -q -E "more" <<< "$output"; then 
    exit 1
  fi

  # Change pagger to cat to ensure that it works
  export PAGE=cat
  export LESS=""

  run $FILE "$tmpFile"

  unset PAGER
  unset LESS

  if [[ "$output" != "$tmpFileContent" ]]; then
    exit 1
  fi
}

@test "File with name space" {
  tmpFile=$(randomStringForTmpFile)" abc"
  until [ ! -f "$tmpFile" ]; do tmpFile=$(randomStringForTmpFile)" abc"; done

  # Execute script
  run $FILE "$tmpFile"

  echo "AGUS $output" >&2
  # Check that the user doesn't exists
  REGEX="(no.*fichero.*$tmpFile)|($tmpFile.*no.*fichero)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    exit 1
  fi
}

@test "Test multiple files" {
  arrayOfFiles=()
  arrayOfStrings=()

  # test to create file
  createFiles() {
    # Create three files
    for _ in $(seq 1 "$1"); do
      # Create random string, and ensure that the file does not exists
      tmpFileAndContent=$(createContentFile 10)

      # Name of the temporal file and content
      tmpFile=$(echo "$tmpFileAndContent" | cut -d' ' -f1)
      tmpFileContent=$(echo "$tmpFileAndContent" | cut -d' ' -f2-)

      # Add to the array and strings
      arrayOfFiles+=("$tmpFile")
      arrayOfStrings+=("$tmpFileContent")
    done
  }

  addNoFile() {
    REGEX="(no.*fichero.*$tmpFile)|($tmpFile.*no.*fichero)"
    tmpFile=$(randomStringForTmpFile)
    until [ ! -f "$tmpFile" ]; do tmpFile=$(randomStringForTmpFile); done

    # Add to the array and strings
    arrayOfFiles+=("$tmpFile")
    arrayOfStrings+=("$REGEX")
  }

  # Create list of files
  createFiles 3
  addNoFile
  addNoFile
  createFiles 3
  addNoFile

  # Change pagger to cat to ensure that it works
  export PAGE=cat
  export LESS=""

  run $FILE "${arrayOfFiles[@]}"

  unset PAGER
  unset LESS

  if ! grep -q -E -i "$arrayOfStrings" <<< "$output"; then 
    exit 1
  fi
}
