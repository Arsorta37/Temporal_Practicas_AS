#!/usr/bin/env bats
# @author: Navarro Torres, Agustín
# @email: agusnt@unizar.es
#
# @version: 0.0.1

FILE='../practica2/practica2_1.sh'
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

@test "File doesn't exists" {
  # Create random string, and ensure that the file does not exists
  tmpFile=$(randomStringForTmpFile)
  until [ ! -f "$tmpFile" ]; do tmpFile=$(randomStringForTmpFile); done

  # Execute script
  run $FILE <<< "$tmpFile"

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

  REGEX="(no existe.*$tmpFile)|($tmpFile.*no existe)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    exit 1
  fi
}



@test "No permissions" {
  # Create random string, and ensure that the file does not exists
  tmpFile=$(createTmpFile)
  
  # Remove permissions
  chmod -rxw "$tmpFile"

  # Execute script
  run $FILE <<< "$tmpFile"

  REGEX="(.*$tmpFile.*---)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    removeTmpFile "$tmpFile"
    exit 1
  fi

  removeTmpFile "$tmpFile"
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

  REGEX="(.*$tmpFile.*r--)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    removeTmpFile "$tmpFile"
    exit 1
  fi

  removeTmpFile "$tmpFile"
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

  REGEX="(.*$tmpFile.*-w-)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    removeTmpFile "$tmpFile"
    exit 1
  fi

  removeTmpFile "$tmpFile"
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

  REGEX="(.*$tmpFile.*--x)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    removeTmpFile "$tmpFile"
    exit 1
  fi

  removeTmpFile "$tmpFile"
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

  REGEX="(.*$tmpFile.*rw-)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    removeTmpFile "$tmpFile"
    exit 1
  fi

  removeTmpFile "$tmpFile"
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

  REGEX="(.*$tmpFile.*r-x)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    removeTmpFile "$tmpFile"
    exit 1
  fi

  removeTmpFile "$tmpFile"
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

  REGEX="(.*$tmpFile.*-wx)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    removeTmpFile "$tmpFile"
    exit 1
  fi

  removeTmpFile "$tmpFile"
}

@test "All permissions" {
  # Create random string, and ensure that the file does not exists
  tmpFile=$(createTmpFile)
  
  # Add all permissions
  chmod +rxw "$tmpFile"

  # Execute script
  run $FILE <<< "$tmpFile"

  REGEX="(.*$tmpFile.*rwx)"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    removeTmpFile "$tmpFile"
    exit 1
  fi

  removeTmpFile "$tmpFile"
}
