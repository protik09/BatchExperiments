@echo OFF
TITLE Install Dev Environment (wget, Python and python libraries)
echo.
@echo :::: Install Dev Environment (wget, Python, Arduino and python libraries) ::::
echo.
:: Backgroud to black & foreground to purple
color 05

:::::: Initialise global variables

:::: Change links to most recent ones manually
set wgetlink=https://eternallybored.org/misc/wget/current/wget64.exe
set pythlink=https://www.python.org/ftp/python/2.7.13/python-2.7.13.amd64.msi
set clanglink=http://releases.llvm.org/3.9.1/LLVM-3.9.1-win64.exe
set ardlink=https://www.arduino.cc/download_handler.php

:::: Change where programs are installed on your comp already or will be installed
set wgetdir=wget64.exe
set pythondir=C:\Python27\python.exe
set clangdir=C:\Program Files\LLVM\bin\clang.exe
set arddir=C:\Program Files (x86)\Arduino\arduino.exe

:::: Error Messages
set exit=Program is now exiting...
set w64err=ERROR: wget64.exe not found in %wgetdir%.
set pytherr=ERROR: python.exe not found in %pythondir%

:::: Commmand Shortcuts
set download=wget64.exe -nc --directory-prefix=Downloads

:::::: Check what programs exist

:: The &echo. at the end adds the newline to the next line so you get a skipped line
@echo Checking for existing programs...&echo.
if exist %wgetdir% (@echo SUCCESS: wget64.exe exists in current folder&echo.) else (call:Downwget64)
::Wait for user input to ensure that everything happened successfully
PAUSE

if exist %pythondir% (@echo SUCCESS: Python exists on this system.) else (
	call:DownPyth27)

if exist %clangdir% (@echo SUCCESS: Clang exists on this system&echo.) else (
	call:DownClang )


:::: Install your standard python libs via pip
rem This is the python pip install section
rem <# Please wait 5 seconds..... #>
timeout /t 5
rem python -m pip install --upgrade pip
rem python -m pip install --upgrade setuptools
rem python -m pip install --upgrade python-build
rem python -m pip install --upgrade matplotlib
rem python -m pip install --upgrade numpy
rem python -m pip install --upgrade beautifulsoup4
rem python -m pip install --upgrade pyserial
rem python -m pip install --upgrade pyaudio
rem python -m pip install --upgrade pyusb
rem python -m pip install --upgrade jupyter
rem python -m pip install --upgrade pytools
python -m pip install --upgrade -r requirements.txt
rem <#Remember to run these commands in the atom PS shell#>
timeout /t 5

rem @echo "Installing Python linter for Atom...."
rem timeout /t 5
rem python -m pip install --upgrade flake8
rem python -m pip install --upgrade flake8-docstrings
rem <#apm install linter-flake8 #>
rem <#Remember to run these above in the atom PS shell#>

echo.
@echo Dowloading required distributions via wget cmdlet
if exist Downloads\NUL (@echo Folder Already Exists. Downloading...) else (
	mkdir Downloads)

rem https://eternallybored.org/misc/wget/

echo.
echo Copying files to Python Scripts folder.....
timeout /t 5

:: Revert text color back to white (default)
color
exit /B

:Downwget64
echo.%w64err%&echo.
@echo Do you want to install wget64.exe? You WILL need it.
set /P wgetdown="Do you wish to install wget? (Y/N): "
:: The /I switch makes the input letter case-insensitive
if /I %wgetdown%==n echo.%exit%&call:ExitBatch
:: if %wgetdown%=="N" (call:ExitBatch&goto:eof)
if /I %wgetdown%==y call:installncheck_wget
:: if %wgetdown%=="Y" (call:installncheck_wget)
goto:eof

:installncheck_wget
echo.
@echo Function running: installncheck_wget
echo.
@echo Transfer wget64 to current batch file folder otherwise this batch will terminate.
:: Download wget64.exe via web browser
start %wgetlink%
echo.
PAUSE
:: Check to make sure wget64 is indeed there in C drive otherwise exit
if exist wget64.exe (@echo SUCCESS: wget64.exe exists. Continuing...&echo.) else (
	echo.&echo.%w64err% %exit%&call:ExitBatch)
goto:eof

:DownPyth27
echo.
@echo %pytherr%
set /P pythondown="Do you wish to install Python27? (Y/N): "
if /I %pythondown%==n call:ExitBatch
:: if %pythondown%=="N" (call:ExitBatch&goto:eof)
if /I %pythondown%==y call:installncheck_python
:: if %pythondown%=="Y" (call:installncheck_python)
goto:eof

:installncheck_python
echo.
@echo Function running: installncheck_python&echo.
@echo Installing python27.....
:: wget with no overwrite existing file -nc and download directory Downloads
%download% %pythlink%
rem C:\wget64.exe -nc --directory-prefix=Downloads %pythlink%
cd Downloads
msiexec /i python-2.7.13.amd64.msi TARGETDIR=C:\Python27 ALLUSERS=1
cd..
:: Check to make sure python is properly installed in c:\Python27
if exist %pythondir% (@echo SUCCESS: Python was succesfully installed.) else (
	echo.&call:DownPyth27)
echo.&pause&goto:eof

:DownClang
echo.
set /P clangdown="Do you wish to install clang (linter for Atom)? (Y/N): "
if /I %clangdown%==n goto:eof
if /I %clangdown%==y goto:installncheck_clang

:installncheck_clang
echo.
@echo Installing clangllvm....
:: wget with no overwrite existing file -nc and download directory Downloads
%download% %clanglink%
cd Downloads
start LLVM*.exe
cd..
echo Make sure that you go the next step after finishing the install.
PAUSE

:: CLEAN BATCH EXIT SECTION from https://stackoverflow.com/questions/3227796/exit-batch-script-from-inside-a-function/25474648#25474648
@echo off
:ExitBatch - Cleanly exit batch processing, regardless how many CALLs
if not exist "%temp%\ExitBatchYes.txt" call :buildYes
call :CtrlC <"%temp%\ExitBatchYes.txt" 1>nul 2>&1
:CtrlC
cmd /c exit -1073741510

:buildYes - Establish a Yes file for the language used by the OS
pushd "%temp%"
set "yes="
copy nul ExitBatchYes.txt >nul
for /f "delims=(/ tokens=2" %%Y in (
  '"copy /-y nul ExitBatchYes.txt <nul"'
) do if not defined yes set "yes=%%Y"
echo %yes%>ExitBatchYes.txt
popd
exit /b
