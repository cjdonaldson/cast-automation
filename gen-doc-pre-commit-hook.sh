#!/bin/bash
# create .git/hooks/pre-commit
# with ./gen-doc-pre-commit-hook.sh

makeMdFromFile() {
   sed -n '/^#start__md$/,/^#end__md$/{/^#start__md$/d; /^#end__md$/d; p; }' $1 | sed 's/^#//'
}

{
echo "
# CAST Automation
CAST supports basic authentication which allows for simpler scripting operations.

"
  makeMdFromFile ./cast-global-setup.sh
  makeMdFromFile ./cast-source-catalog.sh
} > README.md
git add README.md