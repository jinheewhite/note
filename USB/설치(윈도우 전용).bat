@echo off
chcp 949 >nul
title 판서노트 설치
setlocal enabledelayedexpansion

set "SRC=%~dp0"
set "DEST=%LOCALAPPDATA%\PanseoNote"

echo.
echo   ================================================
echo      판서노트 설치  -  전자칠판용 PDF 필기
echo   ================================================
echo.

if not exist "%SRC%판서노트.html" (
  echo   [오류] 판서노트.html 이 이 폴더에 없습니다.
  echo          설치.bat 과 같은 폴더에 두고 다시 실행해 주세요.
  echo.
  pause
  exit /b 1
)

if not exist "%DEST%" mkdir "%DEST%" >nul 2>&1
copy /y "%SRC%판서노트.html" "%DEST%\index.html" >nul
if exist "%SRC%판서노트.ico" copy /y "%SRC%판서노트.ico" "%DEST%\app.ico" >nul
echo   [1/3] 프로그램 파일을 복사했습니다.

set "BR="
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" set "BR=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not defined BR if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" set "BR=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not defined BR if exist "%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe" set "BR=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe"
if not defined BR if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" set "BR=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
if not defined BR if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" set "BR=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"

if defined BR (
  echo   [2/3] 브라우저를 찾았습니다.
) else (
  echo   [2/3] 크롬을 못 찾아 기본 브라우저로 열도록 설정합니다.
)

set "PAGE=%DEST%\index.html"
set "PAGE=!PAGE:\=/!"
set "PAGE=file:///!PAGE!"

set "DESK=%USERPROFILE%\Desktop"
if not exist "%DESK%" set "DESK=%USERPROFILE%\OneDrive\Desktop"
if not exist "%DESK%" set "DESK=%PUBLIC%\Desktop"

set "MADE="
if defined BR (
  set "VBS=%TEMP%\pn_setup.vbs"
  > "!VBS!" echo Set S = CreateObject("WScript.Shell")
  >>"!VBS!" echo Set L = S.CreateShortcut(S.SpecialFolders("Desktop") ^& "\판서노트.lnk")
  >>"!VBS!" echo L.TargetPath = "%BR%"
  >>"!VBS!" echo L.Arguments = "--app=""!PAGE!"" --allow-file-access-from-files"
  >>"!VBS!" echo L.IconLocation = "%DEST%\app.ico"
  >>"!VBS!" echo L.WorkingDirectory = "%DEST%"
  >>"!VBS!" echo L.Description = "전자칠판용 PDF 필기 - 판서노트"
  >>"!VBS!" echo L.Save
  cscript //nologo "!VBS!" >nul 2>&1
  if not errorlevel 1 set "MADE=1"
  del "!VBS!" >nul 2>&1
)

if not defined MADE (
  > "%DESK%\판서노트.url" echo [InternetShortcut]
  >>"%DESK%\판서노트.url" echo URL=!PAGE!
  >>"%DESK%\판서노트.url" echo IconFile=%DEST%\app.ico
  >>"%DESK%\판서노트.url" echo IconIndex=0
)

echo   [3/3] 바탕화면에 아이콘을 만들었습니다.
echo.
echo   ------------------------------------------------
echo    설치가 끝났습니다.
echo    바탕화면의 판서노트 아이콘을 두 번 누르세요.
echo    USB는 이제 빼셔도 됩니다.
echo   ------------------------------------------------
echo.
pause
