@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

SET PROJECT_ROOT=%~dp0
SET GRADLEWJ_HOME=%PROJECT_ROOT%.gradlewj
SET GRADLEWJ_TMP_DIR=%GRADLEWJ_HOME%\tmp
SET GRADLEWJ_JDK_DIR=%GRADLEWJ_HOME%\jdk\
SET GRADLEWJ_GRADLE_DIR=%GRADLEWJ_HOME%\gradle\
SET GRADLEWJ_TMP_VBS_SCRIPT=%GRADLEWJ_TMP_DIR%\script.vbs

FOR /F "tokens=1* delims==" %%A IN (gradlewj.properties) DO (
    SET VALUE=%%B
    call set VALUE=%%VALUE:{GRADLEWJ_JDK_DIR}=%GRADLEWJ_JDK_DIR%%%
    call set VALUE=%%VALUE:{GRADLEWJ_GRADLE_DIR}=%GRADLEWJ_GRADLE_DIR%%%
    call set VALUE=%%VALUE:{GRADLE_NAME}=%GRADLE_NAME%%%
    call set VALUE=%%VALUE:{JAVA_HOME}=%JAVA_HOME%%%
    set %%A=!VALUE!
)

IF NOT EXIST "%GRADLEWJ_HOME%" (
    MKDIR "%GRADLEWJ_HOME%"
)

IF NOT EXIST "%JDK_HOME%" (
    GOTO download_jdk
)

GOTO check_gradle

:download_jdk

IF NOT EXIST "%GRADLEWJ_TMP_DIR%" (
    MKDIR "%GRADLEWJ_TMP_DIR%"
)

IF EXIST "%GRADLEWJ_TMP_DIR%\%JDK_NAME%.zip" (
    GOTO unzip_jdk
)

ECHO "Downlading JDK..." 
CALL :DOWNLOAD %WIN_JDK_DOWNLOAD_URL% , "%GRADLEWJ_TMP_DIR%\%JDK_NAME%.zip"
ECHO "JDK is downloaded." 

:unzip_jdk

if EXIST "%GRADLEWJ_TMP_DIR%\%JDK_NAME%" (
    RMDIR /S /Q "%GRADLEWJ_TMP_DIR%\%JDK_NAME%
)

MKDIR "%GRADLEWJ_TMP_DIR%\%JDK_NAME%

ECHO "Extracting JDK..." 
CALL :UNZIP "%GRADLEWJ_TMP_DIR%\%JDK_NAME%.zip" , "%GRADLEWJ_TMP_DIR%\%JDK_NAME%"
ECHO "JDK is extracted."

DEL "%GRADLEWJ_TMP_DIR%\%JDK_NAME%.zip"

MKDIR "%GRADLEWJ_JDK_DIR%"
ECHO "Moving JDK..." 
MOVE "%GRADLEWJ_TMP_DIR%\%JDK_NAME%\%WIN_JDK_ZIP_HOME_ROOT%" "%GRADLEWJ_JDK_DIR%" >nul
ECHO "JDK is moved."
RMDIR /S /Q "%GRADLEWJ_TMP_DIR%\%JDK_NAME%"

:check_gradle

IF NOT EXIST "%GRADLE_HOME%" (
    GOTO download_gradle
)

GOTO run_gradle

:download_gradle

IF EXIST "%GRADLEWJ_TMP_DIR%\%GRADLE_NAME%.zip" (
    GOTO unzip_gradle
)

IF NOT EXIST "%GRADLEWJ_TMP_DIR%" (
    MKDIR "%GRADLEWJ_TMP_DIR%"
)

ECHO "Downlading Gradle..." 
CALL :DOWNLOAD %GRADLE_DOWNLOAD_URL% , "%GRADLEWJ_TMP_DIR%\%GRADLE_NAME%.zip"
ECHO "Gradle is downloaded." 

:unzip_gradle

if EXIST "%GRADLEWJ_TMP_DIR%\%GRADLE_NAME%" (
    RMDIR /S /Q "%GRADLEWJ_TMP_DIR%\%GRADLE_NAME%
)

MKDIR "%GRADLEWJ_TMP_DIR%\%GRADLE_NAME%
ECHO "Extracting Gradle..." 
CALL :UNZIP "%GRADLEWJ_TMP_DIR%\%GRADLE_NAME%.zip" , "%GRADLEWJ_TMP_DIR%\%GRADLE_NAME%"
ECHO "Gradle is extracted."

DEL "%GRADLEWJ_TMP_DIR%\%GRADLE_NAME%.zip"

MKDIR "%GRADLEWJ_GRADLE_DIR%"
ECHO "Moving Gradle..." 
MOVE "%GRADLEWJ_TMP_DIR%\%GRADLE_NAME%\%GRADLE_ZIP_HOME_ROOT%" "%GRADLEWJ_GRADLE_DIR%" >nul
ECHO "Gradle is moved."
RMDIR /S /Q "%GRADLEWJ_TMP_DIR%\%GRADLE_NAME%"

:run_gradle
SET JAVA_HOME=%JDK_HOME%
CALL "%GRADLE_HOME%\bin\gradle.bat" %*

EXIT /B %ERRORLEVEL%


:DOWNLOAD
IF EXIST "%GRADLEWJ_TMP_VBS_SCRIPT%" (
    DEL "%GRADLEWJ_TMP_VBS_SCRIPT%"
)
ECHO dim xHttp: Set xHttp = createobject("Microsoft.XMLHTTP")   >> %GRADLEWJ_TMP_VBS_SCRIPT%
ECHO dim bStrm: Set bStrm = createobject("Adodb.Stream")        >> %GRADLEWJ_TMP_VBS_SCRIPT%
ECHO xHttp.Open "GET",  "%~1", False                            >> %GRADLEWJ_TMP_VBS_SCRIPT%
ECHO xHttp.Send                                                 >> %GRADLEWJ_TMP_VBS_SCRIPT%
ECHO with bStrm                                                 >> %GRADLEWJ_TMP_VBS_SCRIPT%
ECHO     .type = 1 '//binary                                    >> %GRADLEWJ_TMP_VBS_SCRIPT%
ECHO     .open                                                  >> %GRADLEWJ_TMP_VBS_SCRIPT%
ECHO     .write xHttp.responseBody                              >> %GRADLEWJ_TMP_VBS_SCRIPT%
ECHO     .savetofile "%~2", 2 '//overwrite                      >> %GRADLEWJ_TMP_VBS_SCRIPT%
ECHO end with                                                   >> %GRADLEWJ_TMP_VBS_SCRIPT%

CSCRIPT //nologo %GRADLEWJ_TMP_VBS_SCRIPT%

IF EXIST "%GRADLEWJ_TMP_VBS_SCRIPT%" (
    DEL "%GRADLEWJ_TMP_VBS_SCRIPT%"
)
EXIT /B 0


:UNZIP
IF EXIST "%GRADLEWJ_TMP_VBS_SCRIPT%" (
    DEL "%GRADLEWJ_TMP_VBS_SCRIPT%"
)

ECHO Set objShell = CreateObject( "Shell.Application" ) >> "%GRADLEWJ_TMP_VBS_SCRIPT%"
ECHO Set objSource = objShell.NameSpace("%~1").Items()  >> "%GRADLEWJ_TMP_VBS_SCRIPT%"
ECHO Set objTarget = objShell.NameSpace("%~2")          >> "%GRADLEWJ_TMP_VBS_SCRIPT%"
ECHO objTarget.CopyHere objSource, 4                    >> "%GRADLEWJ_TMP_VBS_SCRIPT%"

CSCRIPT //nologo %GRADLEWJ_TMP_VBS_SCRIPT%

IF EXIST "%GRADLEWJ_TMP_VBS_SCRIPT%" (
    DEL "%GRADLEWJ_TMP_VBS_SCRIPT%"
)
EXIT /B 0
