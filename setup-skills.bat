@echo off
setlocal EnableExtensions

rem Compatibility launcher for setup-skills.sh. For Windows, prefer setup-skills.ps1.
set "BASH_EXE=%ProgramFiles%\Git\bin\bash.exe"
if not exist "%BASH_EXE%" set "BASH_EXE=%ProgramFiles(x86)%\Git\bin\bash.exe"

if not exist "%BASH_EXE%" (
  echo Git Bash was not found.
  echo Install Git for Windows, or use setup-skills.ps1 instead.
  exit /b 1
)

"%BASH_EXE%" -lc "command -v python3 >/dev/null 2>&1"
if errorlevel 1 (
  echo Python 3 is not available as python3 in Git Bash.
  echo Install Python 3 and make it available in the Git Bash PATH, or use setup-skills.ps1 instead.
  exit /b 1
)

if /I "%~1"=="--path" (
  if "%~2"=="" (
    echo Missing path after --path.
    exit /b 1
  )
  for /f "usebackq delims=" %%P in (`"%BASH_EXE%" -lc "cygpath -u \"$1\"" -- "%~2"`) do set "CONTEXT_PATH=%%P"
  "%BASH_EXE%" "%~dp0setup-skills.sh" --path "%CONTEXT_PATH%"
) else (
  "%BASH_EXE%" "%~dp0setup-skills.sh" %*
)

exit /b %ERRORLEVEL%
