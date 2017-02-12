#!/bin/bash

set -e

cd ./Spigot-API-Patches/
rm *
cd ../CweepahCraft-API/
git format-patch -o ../Spigot-API-Patches/ origin/master

cd ../Spigot-Server-Patches/
rm *
cd ../CweepahCraft-Server/
git format-patch -o ../Spigot-Server-Patches/ upstream/master

echo Done!
