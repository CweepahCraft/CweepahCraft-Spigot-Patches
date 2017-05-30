#!/bin/bash
set -e

rm -f cweepahcraft-*.jar

cd ../
root=`pwd`

cd "$root/Bukkit/"
git fetch -a
git checkout -f master
git reset --hard origin/master
git checkout -f spigot
git reset --hard origin/master
mvn clean install

cd "$root/CraftBukkit/"
git fetch -a
git checkout -f master
git reset --hard origin/master
git checkout -f patched
git reset --hard origin/master
./applyPatches.sh ../work/decompile-5118e321
git add .
git commit -m "Applied patches on `date '+%Y/%m/%d %H:%M:%S'`"
mvn clean install

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
mvn clean install

cd "$root/Spigot/Spigot-Server/"
mvn clean install

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
	git remote set-url upstream ../../Spigot/Spigot-Server/
fi

cd "$root/CweepahCraft/CweepahCraft-Server/"
git fetch -a upstream
git reset --hard upstream/master
git am -3 ../Spigot-Server-Patches/*.patch

cd "$root/CraftBukkit/"
git checkout -f master
cd "$root/CweepahCraft/"
mvn clean install

cp ./CweepahCraft-Server/target/cweepahcraft-*.jar ./
rename -v 's/.*(cweepahcraft-[0-9,\.]+).*(jar)/$1.$2/' cweepahcraft-*.jar
