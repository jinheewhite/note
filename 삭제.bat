@echo off
chcp 949 >nul
title 판서노트 삭제
set "DEST=%LOCALAPPDATA%\PanseoNote"
set "DESK=%USERPROFILE%\Desktop"
if not exist "%DESK%" set "DESK=%USERPROFILE%\OneDrive\Desktop"

if exist "%DESK%\판서노트.lnk" del /q "%DESK%\판서노트.lnk"
if exist "%DESK%\판서노트.url" del /q "%DESK%\판서노트.url"
if exist "%DEST%" rd /s /q "%DEST%"

echo.
echo   판서노트를 삭제했습니다.
echo   (필기 기록은 브라우저 안에 그대로 남아 있습니다)
echo.
pause
