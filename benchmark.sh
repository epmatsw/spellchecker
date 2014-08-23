#!/usr/local/bin/zsh

git checkout 168575f3f73f79185db0abdb91be364c0d0f29f9
file -I **/* | awk '/us-ascii/ {print substr($1, 0, length($1)-1)}' | xargs time node spellcheck
git reset --hard HEAD
git checkout 168575f3f73f79185db0abdb91be364c0d0f29f9
file -I **/* | awk '/us-ascii/ {print substr($1, 0, length($1)-1)}' | xargs time node spellcheck
git reset --hard HEAD
git checkout 168575f3f73f79185db0abdb91be364c0d0f29f9
file -I **/* | awk '/us-ascii/ {print substr($1, 0, length($1)-1)}' | xargs time node spellcheck
