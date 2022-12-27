@echo off
echo "Hello there!"
echo "Welcome to the test program."
set /p NAME=Please enter your name:
echo %NAME% >>"USERS.TXT"
if %NAME% EQU "Charlton" goto WAZZUP
echo "Goodbye, %NAME%"
exit 

:WAZZUP 
echo "Wazzup dad"