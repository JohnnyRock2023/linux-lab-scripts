#!/bin/bash
set -eu

TARGET_DIR="${1:-/etc}"

GREEN='\033[0;32m';
BLUE='\033[0;34m';
RED='\033[0;31m';
NC='\033[0m';

[ -d "$TARGET_DIR" ] || { echo -e "${RED}Помилка${NC}: $TARGET_DIR не є директорією або не існує!!!" >&2; exit 1; }

cf_usage() {
    echo "Count_files function usage: $0 [-e ext] [-t type] [-m +-days] [-r] [-s]" >&2
    exit 2
}

count_files() {
    local EXT=""
    local RECURSIVE=0
    local DATA="l"
    local FTYPE=""
    local MODIFIED=""

    while getopts ":e:t:m:rsh" opt; do
        case "$opt" in
	    e) EXT="$OPTARG" ;;
	    t) FTYPE="$OPTARG" ;;
	    m) MODIFIED="$OPTARG" ;;
            r) RECURSIVE=1 ;;
	    s) DATA="s" ;;
            h) cf_usage ;;
            *) cf_usage ;;
        esac
    done
    shift  $((OPTIND-1))

    local depth=()
    [ "$RECURSIVE" -eq 1 ] || depth=(-maxdepth 1)

    local name=()
    [ -z "$EXT" ] || name=(-name "*.$EXT")

    local fType=()
    [ -z "$FTYPE" ] || fType=(-type "$FTYPE")

    local modified=()
    [ -z "$MODIFIED" ] || modified=(-mtime "$MODIFIED")

    if [ "$DATA" = "s" ]; then
	find "$TARGET_DIR" "${depth[@]}" "${fType[@]}" "${modified[@]}" "${name[@]}" -printf "%s\n" 2>/dev/null \
             | awk '{sum+=$1} END {print sum+0}'

    else
	 find "$TARGET_DIR" "${depth[@]}" "${fType[@]}" "${modified[@]}" "${name[@]}" 2>/dev/null | wc "-$DATA"
    fi
}

dirs=$(count_files -t "d")
rec_dirs=$(count_files -t "d" -r)
modified_dirs=$(count_files -t "d" -m -1)
files=$(count_files -e "conf" -t "f")
rec_files=$(count_files -e "conf" -t "f" -r)
modified_files=$(count_files -e "conf" -t "f" -m -1)
files_size=$(count_files -e "conf" -t "f" -s)
rec_files_size=$(count_files -e "conf" -t "f" -r -s)
links=$(count_files -t "l")
rec_links=$(count_files -t "l" -r)
modified_links=$(count_files -t "l" -m -1)

echo -e "Статистика директорії $TARGET_DIR:"
echo -e "  Файли з розширенням .conf: ${GREEN}$files${NC}"
echo -e "  Файли з розширенням .conf (рекурсивно): ${BLUE}$rec_files${NC}"
echo -e "  Файли з розширенням .conf, модифіковані за останню добу: ${RED}$modified_files${NC}"
echo -e "  Директорії: ${GREEN}$((dirs-1))${NC}"
echo -e "  Директорії (рекурсивно): ${BLUE}$((rec_dirs - 1))${NC}"
echo -e "  Директорії, модифіковані за останню добу: ${RED}$((modified_dirs-1))${NC}"
echo -e "  Символічні посилання: ${GREEN}$links${NC}"
echo -e "  Символічні посилання (рекурсивно): ${BLUE}$rec_links${NC}"
echo -e "  Символічні посилання, модифіковані за останню добу: ${RED}$modified_links${NC}"
echo -e "  -----------------------------------------"
echo -e "  Загальний розмір файлів з розширенням .conf: ${GREEN}$files_size${NC} Байт"
echo -e "  Загальний розмір файлів з розширенням .conf (рекурсивно): ${BLUE}$rec_files_size${NC} Байт"

exit 0

