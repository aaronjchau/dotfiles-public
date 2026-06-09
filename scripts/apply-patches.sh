#!/usr/bin/env bash
# Re-apply local yazi-plugin patches after `ya pkg install` / `ya pkg upgrade`
# (those overwrite plugin files). Idempotent — safe to run repeatedly. Only patches
# plugins that are present, so a partial or Linux install stays quiet.
# Authoritative before/after for each patch is in ../README.md.
set -euo pipefail
P="$HOME/.config/yazi/plugins"

# Portable in-place sed: GNU sed wants `-i`, BSD/macOS sed wants `-i ''`.
sedi() { if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi; }

if [ -f "$P/duckdb.yazi/main.lua" ]; then
  echo "• duckdb.yazi  (yazi-26 seek arg + DuckDB-1.5 lambda)"
  sedi 's/ya\.emit("seek", { "lateral scroll" })/ya.emit("seek", { 0 })/' "$P/duckdb.yazi/main.lua"
  sedi 's/columns(c -> list_contains/columns(lambda c: list_contains/'    "$P/duckdb.yazi/main.lua"
fi

if [ -f "$P/nbpreview.yazi/main.lua" ]; then
  echo "• nbpreview.yazi  (term_image /dev/tty probing → --no-images + no-tty wrapper)"
  sedi 's/"--images",/"--no-images",/'                     "$P/nbpreview.yazi/main.lua"
  sedi 's/Command("nbpreview")/Command("nbpreview-notty")/' "$P/nbpreview.yazi/main.lua"
fi

F="$P/yatline-selected-size.yazi/main.lua"
if [ -f "$F" ]; then
  echo "• yatline-selected-size.yazi  (GNU du -sb → POSIX du -sk, KB→bytes)"
  sedi 's/arg("-sb")/arg("-sk")/' "$F"
  if ! grep -q '\* 1024' "$F"; then
    sedi 's/local size = tonumber(size_output\.stdout:match("^(%d+)"))/local size = (tonumber(size_output.stdout:match("^(%d+)")) or 0) * 1024/' "$F"
  fi
fi

echo "✅ Patches applied (present plugins only). Restart yazi."
