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

# Build args
ARGS=()
[[ "$PROFILE_MANAGER" == true ]] && ARGS+=(--ProfileManager)
[[ "$PRIVATE" == true ]] && ARGS+=(--private-window)

# Bypass container routing for certain domains
case "$URL" in
*proton.me*)
  zen-twilight "${ARGS[@]}" "$URL"
  exit 0
  ;;
esac

# Profile-based routing (full isolation)
case "$URL" in
*dofus.com* | *d-bk.net* | *dofusdb.fr* | *barbofus.com* | *ankama.com* | *dofuspourlesnoobs.com* | *dofuswiki.fandom.com*)
  zen-twilight "${ARGS[@]}" -P "Dofus" "$URL"
  exit 0
  ;;
esac

# Define domain → container mappings
case "$URL" in
*youtube.com* | *youtu.be* | *reddit.com* | *twitch.tv* | *crunchyroll.com* | *discord.com* | *x.com* | *myanimelist.net* | *instagram.com* | *tinder.com* | *spotify.com*)
  CONTAINER="Social Media"
  ;;
*claude.ai* | *github.com* | *gitlab.com* | *stackoverflow.com* | *obsidian.md* | *linkedin.com* | *boot.dev* | *sendgrid.net* | *hypr.land*)
  CONTAINER="Productivity"
  ;;
*datev.de* | *revolut.com* | *ing.de* | *hushed.com* | *paypal.com* | *skrill.com* | *doctolib.de*)
  CONTAINER="Personal"
  ;;
*store.steampowered.com*)
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

zen-twilight "${ARGS[@]}" "ext+container:name=$CONTAINER&url=$URL"
