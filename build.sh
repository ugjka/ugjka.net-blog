#!/bin/bash
set -e
nix shell github:bobvanderlinden/nixpkgs-ruby#'"ruby-2.7"' --extra-experimental-features nix-command --extra-experimental-features flakes --command \
bundle exec jekyll build
find _site \( -name '*.css' -o -name '*.html' -o -name '*.js' -o -name '*.json' -o -name '*.txt' -o -name '*.xml' -o -name '*.yml' \) -exec gzip --best --keep -f {} \;
rsync -Pvhr --delete _site/ server.internal:share/blog/
