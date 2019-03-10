#!/bin/bash
set -e

rm -f cweepahcraft-*.jar

cd ../
root=`pwd`
MAVEN_CMD="mvn clean install -P development"

cd "$root/Bukkit/"
git fetch -a
git checkout -f master
git reset --hard origin/master
git checkout -f spigot
git reset --hard origin/master
eval $MAVEN_CMD

cd "$root/CraftBukkit/"
git fetch -a
git checkout -f master
git reset --hard origin/master
git checkout -f patched
git reset --hard origin/master
./applyPatches.sh ../work/decompile-56ba149d
git add .
git commit -m "Applied patches on `date '+%Y/%m/%d %H:%M:%S'`"
eval $MAVEN_CMD

cd "$root/Spigot/"
git checkout -f master
git fetch -a
git reset --hard origin/master

cd "$root/Spigot/Bukkit/"
git fetch -a
git reset --hard origin/master

cd "$root/Spigot/CraftBukkit/"
git fetch -a
git reset --hard origin/patched

cd "$root/Spigot/"
./applyPatches.sh

cd "$root/Spigot/Spigot-API/"
eval $MAVEN_CMD

cd "$root/Spigot/Spigot-Server/"
eval $MAVEN_CMD

if [ ! -d "$root/CweepahCraft/CweepahCraft-API/" ]; then
	cp -r "$root/Spigot/Spigot-API" "$root/CweepahCraft/"
	mv "$root/CweepahCraft/Spigot-API" "$root/CweepahCraft/CweepahCraft-API"
	cd "$root/CweepahCraft/CweepahCraft-API/"
	git remote set-url origin ../../Spigot/Spigot-API/
fi

cd "$root/CweepahCraft/CweepahCraft-API/"
git fetch -a origin
git reset --hard origin/master
git am -3 ../Spigot-API-Patches/*.patch

if [ ! -d "$root/CweepahCraft/CweepahCraft-Server/" ]; then
	cp -r "$root/Spigot/Spigot-Server" "$root/CweepahCraft/"
	mv "$root/CweepahCraft/Spigot-Server" "$root/CweepahCraft/CweepahCraft-Server"
	cd "$root/CweepahCraft/CweepahCraft-Server/"
	git remote set-url origin ../../Spigot/Spigot-Server/
fi

cd "$root/CweepahCraft/CweepahCraft-Server/"
git fetch -a origin
git branch premaster || true
git checkout -f premaster
git reset --hard origin/master
rm nms-patches/*
git add .
git commit -m "Deleted old nms-patches on `date '+%Y/%m/%d %H:%M%:S'`"
git checkout -f master
git reset --hard premaster
git am -3 ../Spigot-Server-Patches/*.patch
git branch patched || true
git checkout -f patched
git reset --hard master
./applyPatches.sh ../../work/decompile-latest
git add .
git commit -m "Applied patches on `date '+%Y/%m/%d %H:%M:%S'`"

cd "$root/CraftBukkit/"
git checkout -f master
cd "$root/CweepahCraft/"
eval $MAVEN_CMD

cp ./CweepahCraft-Server/target/cweepahcraft-*.jar ./
mv -v cweepahcraft-*.jar $(ls cweepahcraft-*.jar | sed -r 's/.*(cweepahcraft-[0-9,\.]+).*(jar)/\1.\2/')
