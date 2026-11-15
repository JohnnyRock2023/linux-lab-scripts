#!/bin/bash
set -euo pipefail

TARGET_DIR="${1:-/etc}"
FILE_TYPE="conf"

[ -f "/etc/count_files.conf" ] && source "/etc/count_files.conf" \
 && echo "Конфігураційний файл було успішно використано!"

GREEN='\033[0;32m';
BLUE='\033[0;34m';
RED='\033[0;31m';
NC='\033[0m';

[ -d "$TARGET_DIR" ] || { echo -e "${RED}Помилка${NC}: $TARGET_DIR не є директорією або не існує!" >&2; exit 1; }

cf_usage() {
    echo "Count_files usage: $0 [-e ext] [-t type] [-m +-days] [-r] [-s]" >&2
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

    depth=()
    [ "$RECURSIVE" -eq 1 ] || depth=(-maxdepth 1)

    name=()
    [ -z "$EXT" ] || name=(-name "*.$EXT")

    fType=()
    [ -z "$FTYPE" ] || fType=(-type "$FTYPE")

    modified=()
    [ -z "$MODIFIED" ] || modified=(-mtime "$MODIFIED")

    if [ "$DATA" = "s" ]; then
	find "$TARGET_DIR" "${depth[@]}" "${fType[@]}" "${modified[@]}" "${name[@]}" -printf "%s\n" 2>/dev/null \
             | awk '{sum+=$1} END {print sum+0}' || true

    else
	 find "$TARGET_DIR" "${depth[@]}" "${fType[@]}" "${modified[@]}" "${name[@]}" 2>/dev/null | wc "-$DATA" || true
    fi
}

dirs=$(count_files -t "d")
rec_dirs=$(count_files -t "d" -r)
modified_dirs=$(count_files -t "d" -m -1)
files=$(count_files -e "$FILE_TYPE" -t "f")
rec_files=$(count_files -e "$FILE_TYPE" -t "f" -r)
modified_files=$(count_files -e "$FILE_TYPE" -t "f" -m -1)
files_size=$(count_files -e "$FILE_TYPE" -t "f" -s)
rec_files_size=$(count_files -e "$FILE_TYPE" -t "f" -r -s)
links=$(count_files -t "l")
rec_links=$(count_files -t "l" -r)
modified_links=$(count_files -t "l" -m -1)

echo -e "Статистика директорії $TARGET_DIR:"
echo -e "  Файли з розширенням .${FILE_TYPE}: ${GREEN}$files${NC}"
echo -e "  Файли з розширенням .${FILE_TYPE} (рекурсивно): ${BLUE}$rec_files${NC}"
echo -e "  Файли з розширенням .${FILE_TYPE}, модифіковані 1 день тому: ${RED}$modified_files${NC}"
echo -e "  Директорії: ${GREEN}$((dirs-1))${NC}"
echo -e "  Директорії (рекурсивно): ${BLUE}$((rec_dirs - 1))${NC}"
echo -e "  Директорії, модифіковані 1 день тому: ${RED}$modified_dirs${NC}"
echo -e "  Символічні посилання: ${GREEN}$links${NC}"
echo -e "  Символічні посилання (рекурсивно): ${BLUE}$rec_links${NC}"
echo -e "  Символічні посилання, модифіковані 1 день тому: ${RED}$modified_links${NC}"
echo -e "  -------------------------"
echo -e "  Загальний розмір файлів з розширенням .${FILE_TYPE}: ${GREEN}$files_size${NC} Bytes"
echo -e "  Загальний розмір файлів з розширенням .${FILE_TYPE} (рекурсивно): ${BLUE}$rec_files_size${NC} Bytes"

exit 0

