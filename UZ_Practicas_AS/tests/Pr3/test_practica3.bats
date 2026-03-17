#!/usr/bin/env bats
#
# Basic tests for lab 3 
#
# @author: Navarro Torres, Agustín
# @email: agusnt@unizar.es
#
# @version: 0.0.1

FILE="$(realpath "${BATS_TEST_DIRNAME}/../../src/Pr3/practica3.sh")"
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

@test "Script can not be run as no-sudo user" {
  TMP_FILE="$TMP_FOLDER/create"
  echo "asTest1,asTest1,asTest1" > "$TMP_FILE"

  run $FILE "-a" "$TMP_FILE"
  [ $status -eq 1 ]
}

@test "Number of parameters" {
  run sudo "$FILE"

  REGEX="(.*incorrecto.*)"

  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    >&2 echo "The expected output with 0 parameters is: \"Número incorrecto de párametros\", but I get: $output"
    exit
  fi

  run sudo "$FILE" "a" "b" "c"
  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    >&2 echo "The expected output with 3 parameters is: \"Número incorrecto de párametros\", but I get: $output"
    exit
  fi

  run sudo "$FILE" "a" "b"
  if grep -q -E -i "$REGEX" <<< "$output"; then 
    >&2 echo "The script should work with 2 parameters, but I get: $output"
    exit
  fi
}

@test "Not valid option" {
  run sudo "$FILE" "-d" "b"

  REGEX="(.*invalida.*)"

  if ! grep -q -E -i "$REGEX" <<< "$output"; then 
    >&2 echo "The expected output with 0 parameters is: \"Opción invalida\", but I get: $output"
    exit
  fi
}

@test "Not valid fields" {
  TMP_FILE="$TMP_FOLDER/create"
  echo "asTest1,," > "$TMP_FILE"
  echo "asTest1,asTest1," >> "$TMP_FILE"
  echo ",asTest1," >> "$TMP_FILE"
  echo "asTest1,,asTest1" >> "$TMP_FILE"

  run sudo "$FILE" "-a" "$TMP_FILE"
  REGEX="(.*invalido.*)"

  for i in "${!lines[@]}"; do
    line=$(("$i" + 1))
    user=$(awk -v l="$line" "NR==l" "$TMP_FILE" | cut -d',' -f1)
    if ! grep -q -E -i "$REGEX" <<< "${lines[$i]}"; then 
      >&2 echo "Expected output for $user is: \"Campo invalido\", the actual output is ${lines[$i]} when script call with parameter -a"
      exit
    fi
  done

  TMP_FILE="$TMP_FOLDER/dele"
  echo ",asTest1," >> "$TMP_FILE"

  run sudo "$FILE" "-a" "$TMP_FILE"
  REGEX="(.*invalido.*)"

  for i in "${!lines[@]}"; do
    line=$(("$i" + 1))
    user=$(awk -v l="$line" "NR==l" "$TMP_FILE" | cut -d',' -f1)
    if ! grep -q -E -i "$REGEX" <<< "${lines[$i]}"; then 
      >&2 echo "Expected output for $user is: \"Campo invalido\", the actual output is ${lines[$i]} when script call with parameter -s"
      exit
    fi
  done
}

@test "Create user" {
  sudo touch "/etc/skel/test"

  TMP_FILE="$TMP_FOLDER/create"
  echo "asTest1,asTest1,asNameTest1" > "$TMP_FILE"
  echo "asTest3,asTest3,asNameTest3" >> "$TMP_FILE"
  echo "asTest4,asTest4,asNameTest4" >> "$TMP_FILE"

  run sudo "$FILE" "-a" "$TMP_FILE"

  for i in "${!lines[@]}"; do
    line=$(("$i" + 1))
    user=$(awk -v l="$line" "NR==l" "$TMP_FILE" | cut -d',' -f1)
    REGEX="(.*$user.*creado.*)"
    if ! grep -q -E -i "$REGEX" <<< "${lines[$i]}"; then 
      >&2 echo "Expected output for $user is: \"$user ha sido creado\", the actual output is ${lines[$i]}"
      exit
    fi
  done
}

@test "Cannot create duplicate users" {
  TMP_FILE="$TMP_FOLDER/create"
  echo "asTest1,asTest1,asNameTest1" > "$TMP_FILE"
  echo "asTest3,asTest3,asNameTest3" >> "$TMP_FILE"
  echo "asTest4,asTest4,asNameTest4" >> "$TMP_FILE"

  run sudo "$FILE" "-a" "$TMP_FILE"

  for i in "${!lines[@]}"; do
    line=$(("$i" + 1))
    user=$(awk -v l="$line" "NR==l" "$TMP_FILE" | cut -d',' -f1)
    REGEX="(.*$user.*existe.*)"
    if ! grep -q -E -i "$REGEX" <<< "${lines[$i]}"; then 
      >&2 echo "Expected output for $user is: \"El usuario $user ya existe\", the actual output is ${lines[$i]}"
      exit
    fi
  done
}

@test "Create users again with no valid entries" {
  TMP_FILE="$TMP_FOLDER/create"
  echo "asTest1,asTest1,asNameTest1" > "$TMP_FILE"
  echo "asTest2,," >> "$TMP_FILE"
  echo "asTest2,asTest2,asNameTest2" >> "$TMP_FILE"

  run sudo "$FILE" "-a" "$TMP_FILE"

    user=$(awk "NR==1" "$TMP_FILE" | cut -d',' -f1)
    REGEX="(.*$user.*existe.*)"
    if ! grep -q -E -i "$REGEX" <<< "${lines[0]}"; then 
      >&2 echo "Expected output for $user is: \"El usuario $user ya existe\", the actual output is ${lines[0]}"
      exit
    fi
    user=$(awk "NR==2" "$TMP_FILE" | cut -d',' -f1)
    REGEX="(.*invalido.*)"
    if ! grep -q -E -i "$REGEX" <<< "${lines[1]}"; then 
      >&2 echo "Expected output for $user is: \"Campo invalido\", the actual output is ${lines[1]}"
      exit
    fi
    user=$(awk "NR==3" "$TMP_FILE" | cut -d',' -f1)
    REGEX="(.*$user.*creado.*)"
    if ! grep -q -E -i "$REGEX" <<< "${lines[2]}"; then 
      >&2 echo "Expected output for $user is: \"$user ha sido creado\", the actual output is ${lines[2]}"
      exit
    fi
}

@test "Check that users are really created in the system" {
  userNames=("asTest1" "asTest2" "asTest3" "asTest4")

  for user in "${userNames[@]}"; do
    if ! sudo grep -q -E -i "$user" "/etc/shadow"; then 
      >&2 echo "Some user(s) is not really created in the system"
      exit
    fi
  done
}

@test "Password of new users will expire in 30 days" {
  userNames=("asTest1" "asTest2" "asTest3" "asTest4")

  for user in "${userNames[@]}"; do
    days=$(sudo getent shadow "$user" | cut -d: -f5) 
    if [[ "$days" -ne 30 ]]; then
      >&2 echo "The password of user $user expire in $days days instead of 30"
      exit
    fi
  done
}

@test "Default group is the same that the user" {
  userNames=("asTest1" "asTest2" "asTest3" "asTest4")

  for user in "${userNames[@]}"; do
    defaultG=$(sudo id -gn "$user")
    if [[ "$user" != "$defaultG" ]]; then
      >&2 echo "Default group of $user is $defaultG instead of $user"
      exit
    fi
  done
}

@test "News home has the same content that /etc/skel" {
  userNames=("asTest1" "asTest2" "asTest3" "asTest4")

  for user in "${userNames[@]}"; do
    diffValue=$(sudo diff -r /etc/skel/ /home/"$user/")
    if [ ! -z "$diffValue" ]; then
      >&2 echo "/home/$user and /etc/skel differs: $diffValue"
      exit
    fi
  done
}

@test "Delete user that does not exits" {
  TMP_FILE="$TMP_FOLDER/del"
  echo "asTest99," > "$TMP_FILE"
  
  run sudo "$FILE" "-s" "$TMP_FILE"

  if [ ! -z "$output" ]; then
    >&2 echo "I expect no output when try to delete an user that does not exists, and I get: $output"
    exit
  fi
}

@test "Delete users" {
  TMP_FILE="$TMP_FOLDER/del"
  echo "asTest1," > "$TMP_FILE"
  echo "asTest2," >> "$TMP_FILE"
  echo "asTest3," >> "$TMP_FILE"
  echo "asTest4," >> "$TMP_FILE"
  
  run sudo "$FILE" "-s" "$TMP_FILE"

  userNames=("asTest1" "asTest2" "asTest3" "asTest4")

  for user in "${userNames[@]}"; do
    if sudo grep -q -E -i "$user" "/etc/shadow"; then 
      >&2 echo "Some user(s) is still in the system"
      exit
    fi
  done
}

@test "The home of the users are removed" {
  userNames=("asTest1" "asTest2" "asTest3" "asTest4")

  for user in "${userNames[@]}"; do
    if [ -d "/home/$user" ]; then
      >&2 echo "/home/$user still exists"
      exit
    fi
  done
}

@test "/extra/backup exists" {
  [ -d /extra/backup ]
}

@test "The home of users have backup in /extra/backup" {
  userNames=("asTest1" "asTest2" "asTest3" "asTest4")

  for user in "${userNames[@]}"; do
    if [ ! -f "/extra/backup/$user.tar" ]; then
      >&2 echo "/extra/backup/$user.tar does not exist"
      exit
    fi
  done
}

@test "Backup has some content" {
  userNames=("asTest1" "asTest2" "asTest3" "asTest4")

  for user in "${userNames[@]}"; do
    foo=$(tar -tf /extra/backup/"$user".tar | wc -l)
    if [ "$foo" -eq 0 ]; then
      >&2 echo "/extra/backup/$user.tar is empty"
      exit
    fi
  done
}

@test "/extra/backup is created even if not user is deleted" {
  TMP_FILE="$TMP_FOLDER/del"
  echo "asTest1," > "$TMP_FILE"
  echo "asTest2," >> "$TMP_FILE"
  echo "asTest3," >> "$TMP_FILE"
  echo "asTest4," >> "$TMP_FILE"

  [ -d /extra/backup ] && sudo rm -rf /extra/backup
  
  run sudo "$FILE" "-s" "$TMP_FILE"

  [ -d /extra/backup ] 

  # Clean system
  sudo rm -rf /extra/backup
  sudo rm /etc/skel/test
}

@test "The script use userdel, useradd, and, chpasswd" {
  commands=("useradd" "userdel" "chpasswd")
  for cmd in "${commands[@]}"; do
    if ! grep -q -E -i "$cmd" "$FILE"; then 
      >&2 echo "Command $cmd is not in your script"
      exit
    fi
  done
}

