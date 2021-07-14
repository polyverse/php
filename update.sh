#!/usr/bin/env bash
set -Eeuo pipefail

# Don't tolerate outdated bash on Darwin
[ "${BASH_VERSINFO:-0}" -ge 4 ] || ( echo "Outdated bash version: ${BASH_VERSION}. If you're on MacOS/Darwin, please 'brew install bash' to move away from this comically outdated version." && exit 1)

# Substitute for readlink that works on MacOS/Darwin.
# Copied from: https://stackoverflow.com/questions/29836821/how-does-this-os-x-bash-script-that-emulates-linuxs-readlink-work
function abspath() {
  pushd . > /dev/null;
  if [ -d "$1" ]; then
    cd "$1";
    dirs -l +0;
  else
    cd "`dirname \"$1\"`";
    cur_dir=`dirs -l +0`;
    if [ "$cur_dir" == "/" ]; then
      echo "$cur_dir`basename \"$1\"`";
    else
      echo "$cur_dir/`basename \"$1\"`";
    fi;
  fi;
  popd > /dev/null;
}

cd "$(dirname "$(abspath "$BASH_SOURCE")")"

./versions.sh "$@"
./apply-templates.sh "$@"
