#!/usr/bin/env bash
# Bash terminal wizard matching the ServOS fixed-frame, numbered-step flow.
set -Eeuo pipefail
[[ $(id -u) -eq 0 && $# -eq 1 && -f $1/release/install-online.sh ]] || {
  echo 'Usage: root wd1.0-menu.sh /path/to/InstallWDOnline' >&2; exit 2;
}
[[ -r /dev/tty && -w /dev/tty ]] || { echo 'A console or SSH TTY is required' >&2; exit 69; }
for tool in jq tput fold findmnt timedatectl dpkg-query; do
  command -v "$tool" >/dev/null || { echo "Missing ServOS tool: $tool" >&2; exit 69; }
done
[[ -s /usr/share/i18n/SUPPORTED && -s /usr/share/iso-codes/json/iso_3166-1.json &&
   -s /usr/share/iso-codes/json/iso_639-3.json && -s /usr/share/X11/xkb/rules/base.lst ]] || {
  echo 'ServOS must include locales, iso-codes and xkb-data catalogs' >&2; exit 69;
}
pack=$1
locale=en_US.UTF-8 region=US layout=us variant= timezone=Etc/UTC
host=$(hostname -s) admin=${SUDO_USER:-root} user= fullname= sudo_choice=no
theme=light storage=1 reboot=1 terms=no network=no
step=1
width=$(tput cols </dev/tty); height=$(tput lines </dev/tty)
(( width >= 80 && height >= 24 )) || { echo 'ServOS-style setup needs an 80x24 terminal' >&2; exit 69; }

# One frame for every page: same header, step, divider, bottom actions and hint
# as the ServOS render.Page contract. Text is clipped to terminal width.
draw() {
  local title=$1 instruction=$2 body=$3 actions=$4 hint=${5:-'Up/Down: select  |  Enter: choose  |  Esc: back'}
  local i line rule label subtitle
  printf -v rule '%*s' "$width" ''
  rule=${rule// /─}
  printf '\033[H\033[2J' >/dev/tty
  label='TechE WorkDesk (13.7) v1.0'; subtitle='WORKDESK VERSION'
  printf '%*s%s\n%*s%s\n\n' "$(((width-${#label})/2))" '' "$label" \
    "$(((width-${#subtitle})/2))" '' "$subtitle" >/dev/tty
  printf 'Step %02d / 10  |  %s\n%s\n' "$step" "$title" "$instruction" >/dev/tty
  printf '%s\n' "$rule" >/dev/tty
  i=0
  while IFS= read -r line; do
    (( i >= height-10 )) && break
    printf '  %.*s\n' "$((width-4))" "$line" >/dev/tty
    ((i+=1))
  done <<< "$body"
  while (( i++ < height-10 )); do printf '\n' >/dev/tty; done
  printf '%s\n' "$rule" >/dev/tty
  printf '%s\n%s\nTechE.Works  |  Copyright (c) 2026 TechE\n' \
    "$actions" "$hint" >/dev/tty
}
key() {
  local k rest
  IFS= read -rsn1 k </dev/tty || return 1
  if [[ $k == $'\e' ]]; then
    IFS= read -rsn1 -t 0.05 rest </dev/tty || { KEY=back; return 0; }
    if [[ $rest == '[' ]]; then
      IFS= read -rsn1 -t 0.05 rest </dev/tty || true
      case $rest in A) KEY=up;; B) KEY=down;; *) KEY=back;; esac
    else KEY=back; fi
  elif [[ $k == '' ]]; then KEY=enter
  elif [[ $k == $'\t' ]]; then KEY=down
  else KEY=$k; fi
}
choose() {
  local title=$1 instruction=$2; shift 2
  local -a tags=() labels=()
  while (( $# )); do tags+=("$1"); labels+=("$2"); shift 2; done
  (( ${#tags[@]} > 0 )) || return 1
  local selected=0 start=0 i body visible=$((height-13))
  while :; do
    (( selected < start )) && start=$selected
    (( selected >= start+visible )) && start=$((selected-visible+1))
    body=''; for ((i=start;i<${#tags[@]} && i<start+visible;i++)); do
      body+=$(printf '%s %-18s %s\n' "$([[ $i == $selected ]] && echo '>' || echo ' ')" "${tags[i]}" "${labels[i]}")
      body+=$'\n'
    done
    draw "$title" "$instruction" "$body" '[ Back ]  [ Continue ]'
    key || return 1
    case $KEY in
      up|k) selected=$(((selected+${#tags[@]}-1)%${#tags[@]}));;
      down|j) selected=$(((selected+1)%${#tags[@]}));;
      enter) CHOICE=${tags[selected]}; return 0;;
      back) return 1;;
    esac
  done
}
input() {
  local title=$1 label=$2 value=$3 hidden=${4:-no} shown
  while :; do
    shown=$value
    if [[ $hidden == yes ]]; then
      printf -v shown '%*s' "${#value}" ''
      shown=${shown// /*}
    fi
    draw "$title" "$label" "> $shown" '[ Back ]  [ Continue ]' \
      'Type: edit  |  Backspace: delete  |  Enter: continue  |  Esc: back'
    key || return 1
    case $KEY in
      back) return 1;;
      enter) ANSWER=$value; return 0;;
      $'\177'|$'\b') value=${value%?};;
      *) [[ ${#KEY} == 1 && $KEY == [[:print:]] ]] && value+=$KEY || true;;
    esac
  done
}
notice() {
  while :; do
    draw "$1" "$2" "$3" '[ Back ]  [ Continue ]' 'Enter: continue  |  Esc: back'
    key || return 1
    case $KEY in enter) return 0;; back) return 1;; esac
  done
}
read_document() {
  local title=$1 instruction=$2 file=$3 offset=0 i body
  local -a lines=()
  mapfile -t lines < <(fold -s -w "$((width-4))" "$file")
  while :; do
    body=''
    for ((i=offset;i<${#lines[@]} && i<offset+height-10;i++)); do
      body+="${lines[i]}"$'\n'
    done
    draw "$title" "$instruction" "$body" '[ Back ]  [ Accept and continue ]' \
      'Up/Down: read  |  Enter at end: continue  |  Esc: back'
    key || return 1
    case $KEY in
      up|k) (( offset > 0 )) && ((offset-=1)) || true;;
      down|j) (( offset+height-10 < ${#lines[@]} )) && ((offset+=1)) || true;;
      enter) (( offset+height-10 >= ${#lines[@]} )) && return 0;;
      back) return 1;;
    esac
  done
}
choice_from_catalog() {
  local title=$1 instruction=$2; shift 2
  choose "$title" "$instruction" "$@"
}
validate() {
  [[ $locale =~ ^[a-z]{2,3}_[A-Z]{2}\.UTF-8$ && $region =~ ^[A-Z]{2}$ ]] || return 1
  [[ -f /usr/share/zoneinfo/$timezone && -f /usr/share/X11/xkb/symbols/$layout ]] || return 1
  [[ $host =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{0,62}$ && $host != *- ]] || return 1
  [[ $admin =~ ^[a-z_][a-z0-9_-]*$ ]] && getent passwd "$admin" >/dev/null || return 1
  if [[ $admin != root ]]; then id -nG "$admin" | grep -Eq '(^| )sudo( |$)' || return 1; fi
  [[ $user =~ ^[a-z_][a-z0-9_-]*$ && $user != root && $user != "$admin" ]] || return 1
  ! getent passwd "$user" >/dev/null || return 1
  [[ -n $fullname && $fullname != *:* ]] || return 1
  if [[ $storage == 2 || $storage == 3 ]]; then
    local p root_source; local -a points=(/home)
    if [[ $storage == 3 ]]; then points+=(/var /tmp); fi
    root_source=$(findmnt -T / -no SOURCE)
    for p in "${points[@]}"; do
      [[ $(findmnt -T "$p" -no TARGET) == "$p" &&
         $(findmnt -T "$p" -no SOURCE) != "$root_source" ]] || return 1
    done
  fi
}
basic_preflight() {
  local root_bytes root_free var_free mem_kib
  [[ $(dpkg --print-architecture) == amd64 && $(cat /etc/debian_version) == 13.7* ]] || return 1
  [[ $(nproc) -ge 4 ]] || return 1
  mem_kib=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
  [[ $mem_kib -ge 7864320 ]] || return 1
  read -r root_bytes root_free < <(df -PB1 / | awk 'NR==2 {print $2, $4}')
  read -r var_free < <(df -PB1 /var | awk 'NR==2 {print $4}')
  [[ $root_bytes -ge 34359738368 && $root_free -ge 8589934592 &&
     $var_free -ge 8589934592 ]] || return 1
  ip route get 1.1.1.1 >/dev/null 2>&1
}
while (( step <= 10 )); do
  case $step in
    1)
      if ! basic_preflight; then
        notice 'System requirements' 'This ServOS system does not meet WorkDesk requirements.' \
          $'Debian 13.7 amd64, 4 logical cores, 8 GiB RAM, 32 GiB root, 8 GiB free on root and /var, and a default network route are required.' || true
        exit 69
      fi
      notice 'Welcome' 'Install WorkDesk on the ServOS Debian system.' \
        $'ServOS has already prepared storage, Debian, SSH and the first administrator.\n\nWorkDesk will add the desktop, applications and system-wide defaults.\nNo disk will be formatted by this command.' || exit 0
      ;;
    2)
      legal=$pack/release/WORKDESK-ONLINE-SETUP-DISCLOSURE.txt
      [[ -s $legal ]] || { echo 'WorkDesk terms missing' >&2; exit 65; }
      # Reading is scrollable with the same Back/Continue flow.
      read_document 'Terms and legal' 'Review the WorkDesk terms before installation.' "$legal" || { ((step--)); continue; }
      choose 'Terms and legal' 'Accept the displayed terms?' no 'Back' yes 'I accept and am authorized to install' || { ((step--)); continue; }
      [[ $CHOICE == yes ]] || { ((step--)); continue; }
      terms=yes
      ;;
    3)
      options=()
      while IFS=$'\t' read -r code name; do [[ $code =~ ^[A-Z]{2}$ ]] && options+=("$code" "$name"); done \
        < <(jq -r '."3166-1"[] | [.alpha_2,.name] | @tsv' /usr/share/iso-codes/json/iso_3166-1.json)
      choice_from_catalog 'Location' 'Choose country or region.' "${options[@]}" || { ((step--)); continue; }; region=$CHOICE
      options=()
      while read -r code enc; do
        [[ $enc == UTF-8 && $code =~ ^[a-z]{2,3}_[A-Z]{2}\.UTF-8$ ]] && options+=("$code" "$code")
      done < /usr/share/i18n/SUPPORTED
      choice_from_catalog 'Language and locale' 'Choose a supported UTF-8 locale.' "${options[@]}" || { ((step--)); continue; }; locale=$CHOICE
      options=()
      while IFS= read -r zone; do [[ -f /usr/share/zoneinfo/$zone ]] && options+=("$zone" "$zone"); done \
        < <(timedatectl list-timezones --no-pager)
      choice_from_catalog 'Timezone' 'Choose your timezone.' "${options[@]}" || { ((step--)); continue; }; timezone=$CHOICE
      ;;
    4)
      options=()
      while IFS=$'\t' read -r code name; do [[ $code =~ ^[a-z0-9_-]+$ ]] && options+=("$code" "$name"); done \
        < <(awk '/^! layout/{p=1;next} /^! /{if(p) exit} p && NF {code=$1;$1="";sub(/^ +/,"");print code "\t" $0}' /usr/share/X11/xkb/rules/base.lst)
      choice_from_catalog 'Keyboard' 'Choose a keyboard layout.' "${options[@]}" || { ((step--)); continue; }; layout=$CHOICE
      options=(standard 'Standard layout')
      while IFS=$'\t' read -r code context name; do [[ $context == "$layout:" ]] && options+=("$code" "$name"); done \
        < <(awk '/^! variant/{p=1;next} /^! /{if(p) exit} p && NF>=3 {code=$1;ctx=$2;$1="";$2="";sub(/^ +/,"");print code "\t" ctx "\t" $0}' /usr/share/X11/xkb/rules/base.lst)
      choice_from_catalog 'Keyboard variant' 'Choose a variant.' "${options[@]}" || { ((step--)); continue; }
      variant=$CHOICE; [[ $variant == standard ]] && variant= || true
      ;;
    5)
      network_summary=$(ip -br addr show scope global; ip route show default)
      notice 'Network' 'ServOS network is already configured; review it.' "$network_summary" || { ((step--)); continue; }
      network=yes
      input 'Computer name' 'Choose a hostname for this machine.' "$host" || { ((step--)); continue; }; host=$ANSWER
      ;;
    6)
      mounts=$(for p in / /boot /boot/efi /home /var /tmp; do findmnt -T "$p" -no TARGET,SOURCE,FSTYPE 2>/dev/null || true; done)
      notice 'Storage' 'Review the mounts ServOS prepared. WorkDesk will not repartition.' "$mounts" || { ((step--)); continue; }
      choose 'Storage layout' 'Select the layout that already exists.' 1 'One root filesystem' 2 'Separate /home' \
        3 'Separate /home, /var and /tmp' 4 'Manual existing mounts' || { ((step--)); continue; }
      storage=$CHOICE
      ;;
    7)
      input 'Administrator' 'Existing ServOS administrator username.' "$admin" || { ((step--)); continue; }; admin=$ANSWER
      input 'Desktop account' 'New desktop username.' "$user" || { ((step--)); continue; }; user=$ANSWER
      input 'Full name' 'Full name for the desktop account.' "${fullname:-$user}" || { ((step--)); continue; }; fullname=$ANSWER
      choose 'Desktop privileges' 'Should the new user have sudo rights?' no 'No' yes 'Yes' || { ((step--)); continue; }; sudo_choice=$CHOICE
      ;;
    8)
      choose 'Appearance' 'First-user WorkDesk theme.' light 'Light' dark 'Dark' || { ((step--)); continue; }; theme=$CHOICE
      choose 'Finish behavior' 'Reboot after installation?' 1 'Yes' 0 'No' || { ((step--)); continue; }; reboot=$CHOICE
      ;;
    9)
      if ! validate; then notice 'Review' 'One or more entries are invalid.' \
        'Use Back to correct the choice. Check account names and real separate storage mounts.' || true; ((step--)); continue; fi
      review=$(printf 'Locale: %s  Region: %s  Timezone: %s\nKeyboard: %s %s\nHost: %s  Existing admin: %s\nNew user: %s (%s)  Sudo: %s\nStorage: %s  Theme: %s  Reboot: %s\n\nInstall packages and WorkDesk assets on this booted Debian system.' \
        "$locale" "$region" "$timezone" "$layout" "$variant" "$host" "$admin" "$user" "$fullname" "$sudo_choice" "$storage" "$theme" "$reboot")
      notice 'Review installation' 'Check every setting before continuing.' "$review" || { ((step--)); continue; }
      input 'Confirm installation' 'Type INSTALL to begin, or Esc to go back.' '' || { ((step--)); continue; }
      [[ $ANSWER == INSTALL ]] || continue
      input 'Desktop password' "Password for $user." '' yes || continue; password=$ANSWER
      input 'Confirm password' 'Enter the same password again.' '' yes || { unset password; continue; }; password_again=$ANSWER
      [[ -n $password && $password == "$password_again" ]] || { unset password password_again; continue; }
      ;;
    10)
      password_file=$(mktemp /run/teche-wd1.0-password.XXXXXX)
      chmod 0600 "$password_file"
      trap 'rm -f -- "$password_file"' EXIT
      printf '%s\n' "$password" > "$password_file"; unset password password_again
      install -d -m 0755 /var/log/teche-wd1.0
      terms_log="/var/log/teche-wd1.0/terms-$(date -u +'%Y.%m.%d-%H.%M.%S').log"
      (umask 077; printf 'Terms=accepted interactively\n' > "$terms_log")
      language=${locale%%_*}
      export WD_SETUP_MODE=unattended WD_LOCALE="$locale" WD_REGION="$region" WD_LANGUAGE="$language"
      export WD_KEYBOARD_LAYOUT="$layout" WD_KEYBOARD_VARIANT="$variant" WD_TIMEZONE="$timezone"
      export WD_HOSTNAME="$host" WD_ADMIN_USER="$admin" WD_DESKTOP_USER="$user" WD_DESKTOP_FULLNAME="$fullname"
      export WD_DESKTOP_SUDO="$sudo_choice" WD_DESKTOP_THEME="$theme" WD_LAYOUT="$storage" WD_REBOOT=0
      export WD_DESKTOP_PASSWORD_FILE="$password_file"
      draw 'Installing WorkDesk' 'Downloading pinned packages and applying system-wide configuration.' \
        'Dated logs are written under /var/log/teche-wd1.0.' '[ Working ]'
      stamp=$(date -u +'%Y.%m.%d-%H.%M.%S')
      prelist="/var/log/teche-wd1.0/preinstall-packages-$stamp.tsv"
      dpkg-query -W -f='${Package}\t${Version}\n' > "$prelist"
      if bash "$pack/release/install-online.sh"; then
        install -d -m 0755 /var/lib/teche-workdesk
        receipt=$(mktemp /var/lib/teche-workdesk/install-receipt-v1.XXXXXX)
        chmod 0600 "$receipt"
        printf 'product=wd1.0\ninstalled_utc=%s\npack_sha256=%s\npreinstall_packages=%s\nhostname=%s\nadmin=%s\ndesktop_user=%s\nlocale=%s\nregion=%s\nkeyboard=%s\nkeyboard_variant=%s\ntimezone=%s\nlayout=%s\n' \
          "$(date -u +'%Y.%m.%d-%H.%M.%S')" "$(sha256sum /var/cache/teche/packs/wd1.0.zip | cut -d' ' -f1)" \
          "$prelist" "$host" "$admin" "$user" "$locale" "$region" "$layout" "$variant" "$timezone" "$storage" > "$receipt"
        mv -f -- "$receipt" /var/lib/teche-workdesk/install-receipt-v1.txt
        notice 'Installation complete' 'WorkDesk was installed; run release QA after boot.' \
          "Receipt: /var/lib/teche-workdesk/install-receipt-v1.txt" || true
        if [[ $reboot == 1 ]]; then systemctl reboot; fi
        exit 0
      else
        rc=$?
        draw 'Installation stopped' "WorkDesk failed with exit $rc." \
          'Inspect the dated /var/log/teche-wd1.0 logs before retrying.' '[ Exit ]'
        exit "$rc"
      fi
      ;;
  esac
  ((step+=1))
done

