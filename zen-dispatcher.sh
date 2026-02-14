#!/bin/bash

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

# Define domain → container/profile mappings
case "$URL" in
*youtube.com* | *reddit.com* | *twitch.tv* | *crunchyroll.com*)
  CONTAINER="Personal"
  ;;
*claude.ai* | *github.com* | *gitlab.com* | *stackoverflow.com*)
  CONTAINER="Work"
  ;;
*datev.de* | *app.revolut.com* | *ing.de*)
  CONTAINER="Finance"
  ;;
*store.steampowered.com* | *discord.com*)
  CONTAINER="Gaming"
  ;;
*amazon.de*)
  CONTAINER="Shopping"
  ;;
*)
  notify-send "External URL ($URL) not yet allowed" -u critical -a "Zen Dispatcher"
  exit 0
  ;;
esac

zen-twilight "ext+container:name=$CONTAINER&url=$URL"
