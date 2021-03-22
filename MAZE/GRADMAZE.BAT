@echo off
echo.

rem // test access to required files
if exist gradjunk erase gradjunk
if exist results  erase results
if exist results  goto  locked

rem // assure all executable files exist and are valid
if not exist mazedrvr.exe  goto error1
if not exist gradcpy.bat   goto error2
if not exist graddoc.exe   goto error2
if not exist gradgtl.exe   goto error2
if not exist gradlog.exe   goto error2
if not exist gradmmaz.exe  goto error2
if not exist gradmaze.mod  goto error2
if not exist gradmzg1.exe  goto error2
if not exist gradmzg2.exe  goto error2
if not exist gradmzg3.exe  goto error2
if not exist gradresm.exe  goto error2
if not exist gradres.exe   goto error2
if not exist nextval.asm   goto error3

rem // init grading count
if exist gradmaze.cnt goto tmetest
call gradcpy gradmaze.mod gradmaze.cnt

:tmetest
rem // init history log
if exist gradmaze.tme goto endtme
echo Grading and testing history log > gradmaze.tme
:endtme
if %1. == f. goto skip
gradgtl gradmaze.tme
if errorlevel 4 goto exit

:skip
rem // update count and log
gradlog gradmaze.cnt gradmaze.tme p31 2
if errorlevel 4 goto locked

echo Maze Grading System Version 4.0 >> results

type gradid.p31   >> results
type gradmaze.tme >> results

rem // run tests

rem // spec verification
echo Testing against the nextval specification
echo Testing against the nextval specification >> results
gradmzg2 > gradjunk
mazedrvr s < gradjunk >> results
if errorlevel 1 goto specerr
echo Test completed okay
echo Test completed okay >> results

rem // symetry verification
echo Testing against non symetrical maze
echo Testing against non symetrical maze >> results
gradmzg3 > gradjunk
mazedrvr %1 < gradjunk >> results
if errorlevel 1 goto symerr
echo Test completed okay
echo Test completed okay >> results

rem // symetry verification
echo Testing against a set of random mazes
echo Testing against a set of random mazes  >> results
mazedrvr r >> results
if errorlevel 1 goto symerr
echo Test completed okay
echo Test completed okay >> results

rem // maze verification
echo Testing for correct operation and efficiency
echo Testing for correct operation and efficiency >> results
gradmzg1 > gradjunk
mazedrvr b %1 < gradjunk >> results
if errorlevel 1 goto mazeerr

rem // grade instructions written
echo.
gradmmaz nextval.asm
echo. >> results
gradmmaz nextval.asm >> results
echo. >> results

rem Grade documentation
graddoc nextval.asm >> results
echo. >> results
echo.
graddoc nextval.asm
echo.

:mazeerr
rem Calculate the grade
gradresm
type  gradres.tmp
gradres
type  gradres.tmp >> results
erase gradres.tmp
echo. >> results
echo Building the file maze.ans for electronic submission...  >> results
echo. >> results
call gradcpy results+nextval.asm maze.ans >> results
goto exit

:specerr
echo Your code does not meet the nextval specification >> results
rem Calculate the grade
echo. >> results
gradres
type  gradres.tmp >> results
erase gradres.tmp
echo. >> results
echo Building the file maze.ans for electronic submission...  >> results
echo. >> results
call gradcpy results+nextval.asm maze.ans >> results
goto exit

:symerr
echo Nextval does not work with non symetric - random mazes >> results
rem Calculate the grade
gradres
type  gradres.tmp >> results
erase gradres.tmp
echo. >> results
echo Building the file maze.ans for electronic submission...  >> results
echo. >> results
call gradcpy results+nextval.asm maze.ans >> results
goto exit

:error1
echo.
echo The executable file 'mazedrvr.exe' does not exist.
echo.
echo.
echo The executable file 'mazedrvr.exe' does not exist.           >> results
echo.                                                             >> results
goto exit

:error2
echo.
echo The grading system has detected a problem.
echo Some of the required files are missing.
echo Try to re-copy all the grading files from the course locker.
echo If this fails then contact the instructor.
echo.
echo.                                                             >> results
echo The grading system has detected a problem.                   >> results
echo Some of the required files are missing.                      >> results
echo Try to re-copy all the grading files from the course locker. >> results
echo If this fails then contact the instructor.                   >> results
echo.                                                             >> results
goto exit

:error3
echo.
echo The source file 'nextval.asm' does not exist.
echo This file needs to be in the current directory.
echo.
echo.                                                             >> results
echo The source file 'nextval.asm' does not exist.                >> results
echo This file needs to be in the current directory.              >> results
echo.                                                             >> results
goto exit

:locked
if exist results erase results
echo.
echo The grading system can not access its files.
echo Shutdown and reboot the system.
echo.
goto exit

:exit
if exist gradjunk erase gradjunk
if exist     junk erase     junk
echo.
