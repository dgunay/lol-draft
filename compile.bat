@echo off
REM Make the ./build dir if it doesn't already exist.
if not exist build mkdir build

REM Compile the program using the included DLLs.
pp -o build\lol_draft_win64.exe -c -I lib -l dll\SSLeay.xs.dll -l dll\libcrypto-1_1-x64__.dll -l dll\libssl-1_1-x64__.dll -l dll\perl528.dll -l dll\zlib1__.dll bin\lol_draft