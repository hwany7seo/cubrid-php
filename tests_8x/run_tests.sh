#!/bin/bash
#
# Run the tests with the extension built by ../build.sh <ver>.
#
#   ./run_tests.sh [run-tests.php options] [tests...]
#       no test given: all tests
#   ./run_tests.sh --php script.php [args...]
#       run a PHP script with the extension loaded
#
# Environment
#   PHP_BIN      PHP binary        (default: php in PATH), e.g. ~/php/8.4/bin/php
#   CUBRID_EXT   extension to test (default: ../build_<ver>/modules/cubrid.so,
#                <ver> = 83, 84, 85 from PHP_BIN)

cd "$(dirname "$0")"

PHP_BIN=$(command -v "${PHP_BIN:-php}") || { echo "[ERROR] php not found" >&2; exit 1; }
php_ver=$("$PHP_BIN" -n -r 'echo PHP_MAJOR_VERSION, PHP_MINOR_VERSION;')
CUBRID_EXT=${CUBRID_EXT:-../build_$php_ver/modules/cubrid.so}

if [ ! -f "$CUBRID_EXT" ]; then
    echo "[ERROR] $CUBRID_EXT not found. Run '../build.sh $php_ver' first." >&2
    exit 1
fi
CUBRID_EXT=$(readlink -f "$CUBRID_EXT")

if [ "$1" = "--php" ]; then
    shift
    exec "$PHP_BIN" -n -d extension="$CUBRID_EXT" "$@"
fi

# Run the default test set when no test path is given.
has_target=0
for arg in "$@"; do
    [ -e "$arg" ] && has_target=1
done
targets=(.)
[ $has_target -eq 1 ] && targets=()

export NO_COLOR=1
exec "$PHP_BIN" run-tests.php -q -n -d extension="$CUBRID_EXT" -p "$PHP_BIN" "$@" "${targets[@]}"
