@echo  off
echo.

rem // verify files exist
if not exist gradlogt.exe  goto error1
if not exist gradmark.exe  goto error1
if not exist mazedrvr.exe  goto error2

rem // verify the user typed the correct command
rem // if this is a marking run then do not test files
if %1. == mark.  goto tmetest
if %1. == r.     goto tmetest
if %1. == .      goto errcmd

rem // verify the input and output file exist
if not exist %1            goto errin

:tmetest
if exist gradmaze.tme goto endtme
echo Grading and testing history log > gradmaze.tme
:endtme

rem // test for marking run, random run, user test
if not %1. == mark. goto usertest
gradmark gradmaze.tme
goto exit

:usertest
rem // update the time
gradlogt gradmaze.tme %1 -
if errorlevel 4 goto locked

if not %1. == r. goto readmaze

rem // run the test
:ranomaze
mazedrvr %2 %1
goto exit

rem // run the test
:readmaze
mazedrvr %2 < %1
goto exit

:errcmd
echo.
echo To run a test type:
echo    testmaze.bat  input_file
echo.
echo To mark the program as working type:
echo    testmaze.bat  mark
echo.
goto   exit

:errin
echo.
echo The input file specified: %1 does not exist.
echo.
goto   exit

:error1
echo.
echo The grading system has detected a problem.
echo Some of the required files are missing.
echo Try to re-copy all the grading files from the course locker.
echo If this fails then contact the instructor.
echo.
goto   exit

:error2
echo.
echo The executable file 'mazedrvr.exe' does not exist in this directory.
echo.
goto   exit

:locked
echo.
echo I can not access the required files.
echo Shutdown and reboot the system.
echo.
goto exit

:exit
echo.
