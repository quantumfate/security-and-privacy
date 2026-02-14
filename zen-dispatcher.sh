#!/bin/bash

PROFILE_MANAGER=false
PRIVATE=false

# Parse flags
while [[ "$1" == -* ]]; do
  case "$1" in
  --ProfileManager)
    PROFILE_MANAGER=true
    shift
    ;;
  --private-window)
    PRIVATE=true
    shift
    ;;
  *) shift ;;
  esac
done
URL="$1"

# Only allow https and localhost
case "$URL" in
https://*) ;;
http://localhost* | http://127.0.0.1* | http://\[::1\]*) ;;
*)
  notify-send "Zen Dispatcher" "Blocked non-HTTPS URL: $URL"
  exit 1
  ;;
esac

# Bypass container routing for certain domains
case "$URL" in
*proton.me*)
  zen-browser "${ARGS[@]}" "$URL"
  exit 0
  ;;
esac

# Define domain → container/profile mappings
case "$URL" in
*youtube.com* | *reddit.com* | *twitch.tv* | *crunchyroll.com*)
  CONTAINER="Personal"
  ;;
*claude.ai* | *github.com* | *gitlab.com* | *stackoverflow.com* | *proton.me*)
  CONTAINER="Work"
  ;;
*datev.de* | *app.revolut.com* | *ing.de*)
  CONTAINER="Finance"
  ;;
*store.steampowered.com* | *discord.com*)
  CONTAINER="Gaming"
  ;;
*amazon.de* | *otto.de*)
  CONTAINER="Shopping"
  ;;
*)
  notify-send "External URL ($URL) not yet allowed" -u critical -a "Zen Dispatcher"
  exit 0
  ;;
esac

ARGS=()
[[ "$PROFILE_MANAGER" == true ]] && ARGS+=(--ProfileManager)
[[ "$PRIVATE" == true ]] && ARGS+=(--private-window)

zen-twilight "${ARGS[@]}" "ext+container:name=$CONTAINER&url=$URL"
