:: BAT: Synch Job example
:: Created by Roger Nem - 2015

@ECHO ON

SET options=/E /R:0 /W:0
:: /E :: copy empty subdirectories
:: /COPY:DATSOU :: copy with fileproperties
:: /R:n :: number of retries
:: /W:n :: time between retries

SET filters=/XO
:: /XO :: excludes older files

SET logging=/ETA 
:: /ETA :: estimated time for copied files

set localyear=%date:~10,4%
set localmonth=%date:~7,2%
set localday=%date:~4,2%
set localhour=%time:~1,1%
set localminute=%time:~3,2%
set localsecond=%time:~6,2%

SET folder1=\\DAC38997BRP001\D$\NestBR\Cont-DAC-ASP-BR-5492\fileup\_App_Data\AconteceNaNest\Sitefinity\Configuration
SET folder2=\\DAC38997BRP002\D$\NestBR\Cont-DAC-ASP-BR-5492\fileup\_App_Data\AconteceNaNest\Sitefinity\Configuration
SET logfile=D:\Jobs\Logs\Synchlog_Cont-DAC-ASP-BR-5492-AconteceNaNest.txt

D:\Jobs\ROBOCOPY.EXE %folder2% %folder1% %options% %filters% %logging% > %logfile%
D:\Jobs\ROBOCOPY.EXE %folder1% %folder2% %options% %filters% %logging% >> %logfile%