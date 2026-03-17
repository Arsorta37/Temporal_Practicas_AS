#!/usr/bin/env bats
#
# Basic tests for exercise 1 from lab 2
#
# @author: Navarro Torres, Agustín
# @email: agusnt@unizar.es
#
# @version: 0.0.1

FILE="$(realpath "${BATS_TEST_DIRNAME}/../../src/Pr2/practica2_1.sh")"
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
  run $FILE <<< "$tmpFile"

  # Check that the user doesn't exists
  REGEX="(no existe.*$tmpFile)|($tmpFile.*no existe)"
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
  run $FILE <<< "$tmpFile"

  # Check that the user doesn't exists
  REGEX="(no existe.*$tmpFile)|($tmpFile.*no existe)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    exit 1
  fi
}

@test "No permissions" {
  # Create random string, and ensure that the file does not exists
  tmpFile=$(createTmpFile)
  
  # Remove permissiones
  chmod -rxw "$tmpFile"

  # Execute script
  run $FILE <<< "$tmpFile"

  # Check that the user doesn't exists
  REGEX="(.*$tmpFile.*---)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    exit 1
  fi

}

@test "Read permissions" {
  # Create random string, and ensure that the file does not exists
  tmpFile=$(createTmpFile)
  
  # Remove permissiones
  chmod -rxw "$tmpFile"
  # Add read permission
  chmod +r "$tmpFile"

  # Execute script
  run $FILE <<< "$tmpFile"

  # Check that the user doesn't exists
  REGEX="(.*$tmpFile.*r--)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    exit 1
  fi

}

@test "Write permissions" {
  # Create random string, and ensure that the file does not exists
  tmpFile=$(createTmpFile)
  
  # Remove permissiones
  chmod -rxw "$tmpFile"
  # Add read permission
  chmod +w "$tmpFile"

  # Execute script
  run $FILE <<< "$tmpFile"

  # Check that the user doesn't exists
  REGEX="(.*$tmpFile.*-w-)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    exit 1
  fi

}

@test "Exec permissions" {
  # Create random string, and ensure that the file does not exists
  tmpFile=$(createTmpFile)
  
  # Remove permissiones
  chmod -rxw "$tmpFile"
  # Add permissions
  chmod +x "$tmpFile"

  # Execute script
  run $FILE <<< "$tmpFile"

  # Check that the user doesn't exists
  REGEX="(.*$tmpFile.*--x)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    exit 1
  fi

}

@test "Read-Write permissions" {
  # Create random string, and ensure that the file does not exists
  tmpFile=$(createTmpFile)
  
  # Remove permissiones
  chmod -rxw "$tmpFile"
  # Add permissions
  chmod +rw "$tmpFile"

  # Execute script
  run $FILE <<< "$tmpFile"

  # Check that the user doesn't exists
  REGEX="(.*$tmpFile.*rw-)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    exit 1
  fi

}

@test "Read-Exec permissions" {
  # Create random string, and ensure that the file does not exists
  tmpFile=$(createTmpFile)
  
  # Remove permissiones
  chmod -rxw "$tmpFile"
  # Add permissions
  chmod +rx "$tmpFile"

  # Execute script
  run $FILE <<< "$tmpFile"

  # Check that the user doesn't exists
  REGEX="(.*$tmpFile.*r-x)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    exit 1
  fi

}

@test "Write-Exec permissions" {
  # Create random string, and ensure that the file does not exists
  tmpFile=$(createTmpFile)
  
  # Remove permissiones
  chmod -rxw "$tmpFile"
  # Add permission
  chmod +wx "$tmpFile"

  # Execute script
  run $FILE <<< "$tmpFile"

  # Check that the user doesn't exists
  REGEX="(.*$tmpFile.*-wx)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    exit 1
  fi

}

@test "All permissions" {
  # Create random string, and ensure that the file does not exists
  tmpFile=$(createTmpFile)
  
  # Add all permission
  chmod +rxw "$tmpFile"

  # Execute script
  run $FILE <<< "$tmpFile"

  # Check that the user doesn't exists
  REGEX="(.*$tmpFile.*rwx)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    exit 1
  fi

}
