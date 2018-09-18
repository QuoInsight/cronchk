@echo off
time /t > %cron_home%\_schedule.log\_Oncex64.log

set _ONCE.HOME=%cron_home%\_Oncex64
call %cron_home%\_schedule\_Once.bat >> %cron_home%\_schedule.log\_Oncex64.log

echo Done: %_ONCE.HOME% >> %cron_home%\_schedule.log\_Oncex64.log
:@end
