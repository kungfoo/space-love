#!/bin/env bash

rm -rf release/
mkdir release

zip -9 -r release/space.love conf.lua game gfx lib main.lua resources

cd release/

curl -LO https://bitbucket.org/rude/love/downloads/love-0.10.2-win64.zip
unzip -j love-0.10.2-win64.zip

cat love.exe space.love > space.exe

rm love.exe lovec.exe love-0.10.2-win64.zip love.ico game.ico space.love

zip -9 space-game.zip *