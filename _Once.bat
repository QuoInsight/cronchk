@echo off
rem Environment variable substitution has been enhanced as follows: %PATH:str1=str2%
rem May also specify substrings for an expansion. %PATH:~10,5%
rem FOR %variable modifiers with %~ syntax [http://cplusplus.bordoon.com/cmd_exe_variables.html]

rem http://stackoverflow.com/questions/11619416/identify-running-instances-of-a-batch-file
::- Redirect an unused file handle for an entire code block to a lock file.
::- The batch file will maintain a lock on the file until the code block ends
::- or until the process is killed.
set "_lock.done="
set "_lock.file=%~nx0.lock"
if exist "%temp%" set "_lock.file=%temp%\%_lock.file%"
9> "%_lock.file%" (
  set _lock.done=1
  call :@continue
)
if defined _lock.done (
  del "%_lock.file%" >nul 2>nul
  echo ==Process Ended. File Lock Released.==
  exit /b
) else (
  echo Process aborted. Failed to create lock file: "%_lock.file%"
  echo Please ensure other instance of "%~f0" is ended or terminated.
  exit /b
)
goto @end

:@continue

if "%_ONCE.HOME%"=="" set _ONCE.HOME=%cron_home%\_Once
set log="%_ONCE.HOME%\archive.log\_Once.log"
rem time /t > %log% & path >> %log% & type %0 >> %log%

%_ONCE.HOME:~0,2% & cd "%_ONCE.HOME%"
cd & echo.

rem for %%F in ("%_ONCE.HOME%\*.*") do (
for /F "tokens=*" %%F in ('DIR /a-d /od /b "%_ONCE.HOME%\*.*"') do (
  date /t >> %log% & time /t >> %log% 
  echo "%%F" & echo "%%~dpnxF" >> %log%
  if /i "%%~xF"==".bat" (
    echo Executing .BAT: "%%F"
    call "%%~fF" >> %log% 2>&1
    echo "==end of execution==" >> %log%
  ) else if /i "%%~xF"==".js" (
    echo Executing .JS: "%%F"
    cscript "%%~fF" >> %log% 2>&1
    echo "==end of execution==" >> %log%
  ) else if /i "%%~xF"==".vbs" (
    echo Executing .VBS: "%%F"
    cscript "%%~fF" >> %log% 2>&1
    echo "==end of execution==" >> %log%
  ) else (
    echo Skipping: "%%~fF"
    echo "==skipped==" >> %log%
  )
  echo.
  move /Y "%_ONCE.HOME%\%%F" "%_ONCE.HOME%\archive.log\" 
  echo. >> %log% & echo.
)

:@end
