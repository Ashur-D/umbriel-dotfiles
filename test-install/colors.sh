#!/bin/bash
# Terminal formatting helpers

BOLD="\033[1m"
DIM="\033[2m"
RESET="\033[0m"

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"

info()    { echo -e "${CYAN}${BOLD}[INFO]${RESET} $*"; }
success() { echo -e "${GREEN}${BOLD}[OK]${RESET}   $*"; }
warn()    { echo -e "${YELLOW}${BOLD}[WARN]${RESET} $*"; }
error()   { echo -e "${RED}${BOLD}[ERR]${RESET}  $*"; }
header()  {
    echo -e "\n${MAGENTA}${BOLD}====================================================${RESET}"
    echo -e "${MAGENTA}${BOLD}  $*${RESET}"
    echo -e "${MAGENTA}${BOLD}====================================================${RESET}\n"
}
