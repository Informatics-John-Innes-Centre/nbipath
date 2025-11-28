#!/usr/bin/bash

# ======================================================
#  NBI NAVIGATION GAME WITH TAB COMPLETION, HISTORY,
#  LS, TREE & DIRECTORY MIRRORING
# ======================================================

# -------------------------
# COLOURS
# -------------------------
RESET="\e[0m"
BOLD="\e[1m"
PURPLE="\e[1;35m"   # JIC
BLUE="\e[1;34m"     # TSL
GREEN="\e[1;32m"    # QIB
RED="\e[1;31m"      # EI
YELLOW="\e[1;33m"   # current
CYAN="\e[1;36m"     # quest target

# -------------------------
# MAP
# -------------------------
map=(
  "/norwich/nbi/jic/floor_1/reception"
  "/norwich/nbi/jic/floor_1/microscope_room"
  "/norwich/nbi/jic/floor_1/toilet"
  "/norwich/nbi/jic/floor_2/metabolomics_lab"
  "/norwich/nbi/jic/floor_2/informatics_office"
  "/norwich/nbi/jic/floor_2/toilet"

  "/norwich/nbi/tsl/floor_1/proteomics_lab"
  "/norwich/nbi/tsl/floor_1/toilet"
  "/norwich/nbi/tsl/floor_2/synbio_lab"
  "/norwich/nbi/tsl/floor_2/toilet"

  "/norwich/nbi/qib/floor_1/reception"
  "/norwich/nbi/qib/floor_1/tier_3_lab"
  "/norwich/nbi/qib/floor_1/toilet"
  "/norwich/nbi/qib/floor_2/gut_model_lab"
  "/norwich/nbi/qib/floor_2/meeting_room"
  "/norwich/nbi/qib/floor_2/toilet"

  "/norwich/nbi/ei/floor_1/server_room"
  "/norwich/nbi/ei/floor_1/toilet"
  "/norwich/nbi/ei/floor_1/biofoundry_lab"
  "/norwich/nbi/ei/floor_2/genomics_lab"
  "/norwich/nbi/ei/floor_2/toilet"
)


# -------------------------
# NORMALIZE & VALIDATE
# -------------------------
normalize() {
    if [[ "$1" == /* ]]; then
        # absolute
        readlink -m "$1"
    else
        # relative to simulated current dir
        readlink -m "$current/$1"
    fi
}

valid_path() {
    local check=$(normalize "$1")

    for room in "${map[@]}"; do
        local r=$(normalize "$room")

        # walk upwards
        local p="$r"
        while [[ "$p" != "/" ]]; do
            [[ "$check" == "$p" ]] && return 0
            p=$(dirname "$p")
        done
    done

    return 1
}



# -------------------------
# COLOUR PER INSTITUTE
# -------------------------
colour_for() {
  case "$1" in
    *"/jic/"*) echo -e "$PURPLE" ;;
    *"/tsl/"*) echo -e "$BLUE" ;;
    *"/qib/"*) echo -e "$GREEN" ;;
    *"/ei/"*)  echo -e "$RED" ;;
    *) echo -e "$RESET" ;;
  esac
}

# -------------------------
# TREE VIEW
# -------------------------
show_tree() {
  echo
  echo "===== NBI MAP ====="
  declare -A children
  for room in "${map[@]}"; do
    dir="$room"
    while [[ "$dir" != "/" ]]; do
      parent="$(dirname "$dir")"
      [[ " ${children[$parent]} " == *" $dir "* ]] || children["$parent"]+="$dir "
      dir="$parent"
    done
  done

  print_branch() {
    local indent="$1"
    local node="$2"
    local kids=($(echo ${children[$node]} | tr ' ' '\n' | sort -u))
    local count=${#kids[@]}
    local i=0
    for child in "${kids[@]}"; do
      ((i++))
      local is_last=false
      [[ $i -eq $count ]] && is_last=true

      name="$(basename "$child")"
      colour="$(colour_for "$child")"

      # Show only user icon if current = target
      if [[ "$child" == "$current" ]]; then
          name="${YELLOW}${BOLD}${name} ${PERSON_ICON}${RESET}"
      elif [[ "$child" == "$target" ]]; then
          name="${CYAN}${BOLD}${name} ${TARGET_ICON}${RESET}"
      fi

      [[ "$current" == "$child"* ]] && name="${YELLOW}${name}${RESET}"

      # choose prefix based on whether it's last child
      if $is_last; then
        echo -e "${indent}└── ${colour}${name}${RESET}"
        new_indent="${indent}    "
      else
        echo -e "${indent}├── ${colour}${name}${RESET}"
        new_indent="${indent}│   "
      fi

      [[ -n "${children[$child]}" ]] && print_branch "$new_indent" "$child"
    done
  }

  root="/norwich"
  echo "/norwich"
  print_branch "" "$root"
  echo "======================="
}




# -------------------------
# TAB COMPLETION
# -------------------------
completions_file=$(mktemp)
for room in "${map[@]}"; do
  echo "$room" >> "$completions_file"
  echo "${room%/*}" >> "$completions_file"
done
echo "cd" >> "$completions_file"
echo "exit" >> "$completions_file"
echo "ls" >> "$completions_file"
echo "tree" >> "$completions_file"
echo "pwd" >> "$completions_file"
echo "help" >> "$completions_file"

_nbipath_complete() {
    COMPREPLY=($(compgen -W "$(cat "$completions_file")" -- "${COMP_WORDS[1]}"))
}
complete -F _nbipath_complete "$BASH_SOURCE"

# -------------------------
# QUEST GENERATION
# -------------------------

echo -e "${CYAN}${BOLD}Welcome to the Definitive NBI Navigation Game!${RESET}"
echo
echo -e "Learn the paths and explore the building in a fun way! 🚀"
echo
# Prompt username
read -p "$(echo -e ${YELLOW}Enter your username: ${RESET})" username
echo
echo -e "Hello, ${BOLD}$username${RESET}! Let's start your adventure... 🧭"

PERSON_ICON="🧍$username <<<------YOU ARE HERE "
TARGET_ICON="🎯 <<<----- YOUR DESTINATION"

# -------------------------
# ENABLE READLINE HISTORY
# -------------------------
# ----- USER-SPECIFIC HISTORY -----
history_file="/tmp/nbigame_history_${username}"
HISTFILE="$history_file"
set -o history

# Create file if it doesn't exist
touch "$history_file"
chmod 600 "$history_file"


start="${map[$RANDOM % ${#map[@]}]}"
current="${start%/*}"

# Ensure starting directory exists
if [[ ! -d "$current" ]]; then
    echo -e "❌ Starting directory $current does not exist."
    echo "Please run creating_paths.sh to create the required directories before starting the game."
    exit 1
fi

cd "$current"


all_paths=()
for room in "${map[@]}"; do
  all_paths+=("$room")
  all_paths+=("${room%/*}")
done
all_paths=($(printf "%s\n" "${all_paths[@]}" | sort -u))

generate_path_type() { [[ $((RANDOM % 10)) -le 2 ]] && echo "absolute" || echo "relative"; }

quests=()
for i in {1..10}; do
  q="${all_paths[$RANDOM % ${#all_paths[@]}]}"
  type=$(generate_path_type)
  quests+=("$q|$type")
done

quest_i=0
total_score=0

clear
echo "=============================================="
echo "   NBI Navigation Game - by JIC Informatics   "
echo "=============================================="
echo "Starting point: $current"

# -------------------------
# MAIN LOOP
# -------------------------
while (( quest_i < 10 )); do
  IFS="|" read -r target required <<< "${quests[$quest_i]}"
  quest_score=10
  show_tree

  while (( quest_score > 0 )); do
    echo
    echo -e "📍 ${YELLOW}Current:${RESET} ${BOLD}$current${RESET}"
    echo -e "🎯 ${CYAN}Quest ${quest_i+1}/10 →${RESET} ${BOLD}$target${RESET}"
    echo -e "🔧 ${MAGENTA}Required:${RESET} $required path"
    echo -e "⭐ ${GREEN}Points left:${RESET} ${BOLD}$quest_score${RESET}"
    echo -e "💡 Type ${BOLD}help${RESET} if you are lost"

    # Get just the last part of the path
    short_current="$(basename "$current")"
    
    # Construct prompt with system username and hostname
    prompt="[$USER@$HOSTNAME $short_current]# "
    

    # Load history so arrow-up works
    history -r "$history_file"

    # Read full line, split into cmd + arg
    read -e -p "$prompt" -r line
    cmd="${line%% *}"
    arg="${line#* }"
    [[ "$arg" == "$line" ]] && arg=""

    # Save valid commands to history
    if [[ "$cmd" == "cd" || "$cmd" == "pwd" || "$cmd" == "ls" || "$cmd" == "tree" || "$cmd" == "help" ]]; then
        history -s "$line"
        history -w "$history_file"
    fi 

    # -------------------------
    # EXIT
    # -------------------------
    if [[ "$cmd" == "exit" ]]; then
      echo -e "\n🏁 Game over!"
      echo "Score: $total_score"
      rm -f "$completions_file"
      exit 0
    fi

    # -------------------------
    # PWD
    # -------------------------
    if [[ "$cmd" == "pwd" ]]; then
      echo "$current"
      continue
    fi

    # -------------------------
    # LS (NBI-AWARE)
    # -------------------------
    if [[ "$cmd" == "ls" ]]; then
      echo "Contents of $current:"
      declare -A seen

      for p in "${map[@]}"; do
        parent=$(dirname "$p")
        if [[ "$parent" == "$current" ]]; then
          child=$(basename "$p")
          if [[ -z "${seen[$child]}" ]]; then
            echo "  $child"
            seen[$child]=1
          fi
        fi

        if [[ "$p" == "$current/"* ]]; then
          suffix="${p#$current/}"
          first="${suffix%%/*}"
          if [[ -z "${seen[$first]}" ]]; then
            echo "  ${first}/"
            seen[$first]=1
          fi
        fi
      done
      continue
    fi

    # -------------------------
    # HELP
    # -------------------------
    if [[ "$cmd" == "help" ]]; then
      echo -e "${BOLD}Available commands:${RESET}"
      echo -e "  ${BLUE}cd <path>${RESET}     Change directory (relative or absolute)"
      echo -e "  ${GREEN}pwd${RESET}         Print current path"
      echo -e "  ${CYAN}ls${RESET}          List rooms and floors"
      echo -e "  ${PURPLE}tree${RESET}        Show campus map tree"
      echo -e "  ${RED}exit${RESET}         Quit game"
      echo -e "  ${YELLOW}help${RESET}         Show this help"
      echo
      echo -e "${BOLD}Path types:${RESET}"
      echo -e "  ${CYAN}Absolute paths:${RESET}"
      echo -e "    - Start with '/'"
      echo -e "    - Always point to the same location, no matter where you currently are"
      echo -e "    - Example:"
      echo -e "        ${BLUE}/norwich/nbi/jic/floor_1/toilet${RESET}"
      echo
      echo -e "  ${CYAN}Relative paths:${RESET}"
      echo -e "    - Do not start with '/'"
      echo -e "    - Based on your current location"
      echo -e "    - Use:"
      echo -e "        ${GREEN}.  ${RESET}for current directory"
      echo -e "        ${GREEN}.. ${RESET}for parent directory"
      echo -e "    - Example (from /norwich/nbi/jic/floor_2/office_A):"
      echo -e "        ${BLUE}../floor_1/toilet${RESET}"
      continue
  fi


    # -------------------------
    # TREE (CUSTOM MAP)
    # -------------------------
    if [[ "$cmd" == "tree" ]]; then
      show_tree
      continue
    fi

    # -------------------------
    # ONLY CD ALLOWED
    # -------------------------
    if [[ "$cmd" != "cd" ]]; then
      echo "❌ Allowed commands: cd, pwd, ls, tree, help, exit"
      ((quest_score--))
      continue
    fi

    # -------------------------
    # PATH TYPE CHECK
    # -------------------------
    [[ "$required" == "absolute" && "$arg" != /* ]] && { echo "❌ Absolute path required"; ((quest_score--)); continue; }
    [[ "$required" == "relative" && "$arg" == /* ]] && { echo "❌ Relative path required"; ((quest_score--)); continue; }

    # -------------------------
    # CALCULATE NEW PATH
    # -------------------------
    newpath="$([[ "$arg" == /* ]] && echo "$arg" || echo "$current/$arg")"
    newpath=$(normalize "$newpath")

    if ! valid_path "$newpath"; then
      echo "❌ Invalid path"
      ((quest_score--))
      continue
    fi

    # If path is not exactly the target, don't move
    if [[ "$newpath" != "$target" ]]; then
        echo "❌ That is a valid path, but it is NOT the quest destination."
        echo "   You must reach: $target"
        ((quest_score--))
        continue
    fi


    current="$newpath"
    echo "➡️  Moved to: $current"
    show_tree

    # -------------------------
    # QUEST COMPLETED
    # -------------------------
    if [[ "$current" == "$target" ]]; then
      echo "🎉 Quest completed! +$quest_score points"
      total_score=$((total_score + quest_score))
      ((quest_i++))
      read -n1 -r -p "Press any key for next quest..."
      echo
      break
    fi
  done

  if (( quest_score == 0 )); then
    echo "⚠️ Quest failed. Moving on."
    ((quest_i++))
    read -n1 -r -p "Press any key..."
    echo
  fi
done


echo
echo "🏁 FINAL SCORE: $total_score / 100"
echo "Well done, $username!"

rm -f "$completions_file"
exit 0

