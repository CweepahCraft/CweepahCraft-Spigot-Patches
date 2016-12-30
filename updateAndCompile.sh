#!/bin/bash
set -e

cd ../Bukkit/
git fetch -a
git checkout master
git reset --hard origin/master
git checkout spigot
git reset --hard origin/master
mvn clean install

cd ../CraftBukkit/
git fetch -a
git checkout master
git reset --hard origin/master
git checkout patched
git reset --hard origin/master
./applyPatches.sh ../work/decompile-22de4839/
git add .
git commit -m "Applied patches on `date '+%Y/%m/%d %H:%M:%S'`"
mvn clean install

cd ../Spigot/
git checkout master
git fetch -a
git reset --hard origin/master
./upstreamMerge.sh || true
./applyPatches.sh

cd ../CweepahCraft/Spigot-API/
git fetch -a
git reset --hard origin/master
mvn clean install

cd ../Spigot-Server/
git fetch -a
git reset --hard origin/master
mvn clean install

cd ../CweepahCraft-API/
git fetch -a
git reset --hard origin/master
git am ../Spigot-API-Patches/*.patch
mvn clean install

cd ../CweepahCraft-Server/
git fetch -a
git reset --hard origin/master
git am ../Spigot-Server-Patches/*.patch
mvn clean install
cp ./target/cweepahcraft*.jar ../
