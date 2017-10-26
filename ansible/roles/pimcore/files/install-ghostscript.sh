#!/bin/bash

apt-get build-dep ghostscript -y

wget https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs919/ghostscript-9.19-linux-x86_64.tgz -O ghostscript.tgz
tar xfvz ghostscript.tgz
cd ghostscript-9.19-linux-x86_64/
mv gs-919-linux_x86_64 /usr/local/bin/gs
