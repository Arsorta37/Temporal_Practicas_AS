#!/usr/bin/env bats
#
# Basic tests for exercise 6 from lab 2
#
# @author: Navarro Torres, Agustín
# @email: agusnt@unizar.es
#
# @version: 0.0.1

FILE="$(realpath "${BATS_TEST_DIRNAME}/../../src/Pr2/practica2_6.sh")"
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

@test "Check number of files copied" {
  numRandomFile=$((10 + "$RANDOM" % 10))

  # Create files to copy
  for i in $(seq 1 $numRandomFile); do 
    name=$(createTmpFile)
    if [ $((i % 2)) -eq 0 ]; then
      chmod +x $name
    fi
  done

  # Get the number of files
  numFiles=$(find "$TMP_FOLDER" -type f -executable 2>/dev/null | wc -l)

  cd "$TMP_FOLDER"

  run bash "$FILE"

  if [[ ! "${lines[-1]}" =~ $numFiles ]]; then
    >&2 echo "Expected $numFiles copied files reported, but only reported: ${lines[-1]}"
    rm -rf "$HOME"/bin*
    exit
  fi

  # Delete file generated
  rm -rf "$HOME"/bin*
}

@test "Check copied files of files copied" {
  numRandomFile=$((10 + "$RANDOM" % 10))

  # Create files to copy
  for i in $(seq 1 $numRandomFile); do 
    name=$(createTmpFile)
    if [ $((i % 2)) -eq 0 ]; then
      chmod +x $name
    fi
  done

  # Get the number of files
  numFiles=$(find "$TMP_FOLDER" -type f -executable | wc -l)

  cd "$TMP_FOLDER"

  run bash "$FILE"

  newerDirectory=$(stat -c "%Y %n" "$HOME"/bin* 2>/dev/null | sort -n | head -n 1 | cut -d' ' -f2-)

  numFilesCopied=$(find "$newerDirectory" -type f | wc -l)

  if [ "$numFilesCopied" -ne "$numFiles" ]; then
    >&2 echo "Expected to be copied $numFiles, but only $numFilesCopied copied."
    rm -rf "$HOME"/bin*
    exit
  fi

  # Delete file generated
  rm -rf "$HOME"/bin*
}


@test "There is already a binXXX directory" {
  mkdir "$HOME"/binUZ0
  mkdir "$HOME"/binUZ1

  run bash "$FILE"

  if [[ "${lines[0]}" =~ "binUZ1" ]]; then
    >&2 echo "The script is using an existing directory, but no the oldest one"
    rm -rf "$HOME"/bin*
    exit
  fi

  if [[ ! "${lines[0]}" =~ "binUZ0" ]]; then
    >&2 echo "The script is not using the oldest directory"
    rm -rf "$HOME"/bin*
    exit
  fi

  # Delete file generated
  rm -rf "$HOME"/bin*
}

@test "Files are appended an already binXXX directory" {
  mkdir "$HOME"/binUZ0
  numRandomFileExisted=$((10 + "$RANDOM" % 10))
  for i in $(seq 1 $numRandomFileExisted); do touch "$HOME"/binUZ0/"$i"; done

  numFiles=$(find "$HOME"/binUZ0 -type f | wc -l)

  # Create files to copy
  numRandomFile=$((10 + "$RANDOM" % 10))
  for i in $(seq 1 $numRandomFile); do 
    name=$(createTmpFile)
    if [ $((i % 2)) -eq 0 ]; then
      chmod +x $name
    fi
  done

  numFiles=$(($(find "$TMP_FOLDER" -type f -executable | wc -l) + $numFiles))

  cd "$TMP_FOLDER"
  run bash "$FILE"

  numFilesCopied=$(find "$HOME"/binUZ0 -type f | wc -l)

  if [ "$numFilesCopied" -ne "$numFiles" ]; then
    >&2 echo "Expected to be copied $numFiles, but only $numFilesCopied copied."
    rm -rf "$HOME"/bin*
    exit
  fi

  # Delete file generated
  rm -rf "$HOME"/bin*
}
