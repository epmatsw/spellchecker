git checkout 168575f3f73f79185db0abdb91be364c0d0f29f9
time file -I **/* | awk '/us-ascii/ {print substr($1, 0, length($1)-1)}' | xargs node spellcheck > /dev/null
git reset --hard HEAD
git checkout 168575f3f73f79185db0abdb91be364c0d0f29f9
time file -I **/* | awk '/us-ascii/ {print substr($1, 0, length($1)-1)}' | xargs node spellcheck > /dev/null
git reset --hard HEAD
git checkout 168575f3f73f79185db0abdb91be364c0d0f29f9
time file -I **/* | awk '/us-ascii/ {print substr($1, 0, length($1)-1)}' | xargs node spellcheck > /dev/null
