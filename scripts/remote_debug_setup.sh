#!/bin/bash

# remote_debug_setup: Copies binary to target and executes gdbserver

####################################################################################################
# Functions
####################################################################################################

function log() {
  local reset='\033[0m'

  local color

  case $1 in
  success) color='\033[0;32m' ;;
  warning) color='\033[1;33m' ;;
  error) color='\033[0;31m' ;;
  info) color='\033[0;34m' ;;
  *) color=$reset
  esac

  echo -e "$color$2$reset"
}

####################################################################################################
# Main
####################################################################################################

readonly PROGRAM="$1"

log info "\nSourcing environment variables from .env file..."

if [ ! -f .env ]; then
    log error ".env file not found! Exiting..."

    exit 1
fi

source .env

BUILD_BIN_FILE="${PROGRAM}"

TARGET_CWD="/home/$TARGET_USER"
TARGET_BIN_DIR="/tmp/vscode/debug"
TARGET_BIN_FILE="$TARGET_BIN_DIR/$PROGRAM"

log info "\nChecking for sshpass installation..."

which sshpass > /dev/null

if [ $? -ne 0 ]; then
    sudo apt install -y sshpass
fi

log info "\nStopping current gdbserver instance, if it exists..."

sshpass -p "$TARGET_PASS" ssh "$TARGET_USER@$TARGET_IP" "killall gdbserver $PROGRAM; mkdir -p $TARGET_BIN_DIR"

log info "\nCopying cross-compiled binary to target..."

if ! sshpass -p "$TARGET_PASS" scp "$BUILD_BIN_FILE" "$TARGET_USER@$TARGET_IP:$TARGET_BIN_DIR"; then
    exit 1
fi

log info "\nExecuting gdbserver on target..."

sshpass -p "$TARGET_PASS" ssh -f "$TARGET_USER@$TARGET_IP" "sh -c 'cd $TARGET_CWD; nohup gdbserver *:$GDB_PORT $TARGET_BIN_FILE > /dev/null 2>&1 &'"
