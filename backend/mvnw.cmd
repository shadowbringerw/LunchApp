@echo off
setlocal

set BASE_DIR=%~dp0

if "%JAVA_HOME%"=="" (
  set JAVA_EXE=java
) else (
  set JAVA_EXE="%JAVA_HOME%\\bin\\java"
)

if not exist "%BASE_DIR%\\.mvn\\wrapper\\maven-wrapper.jar" (
  echo Maven wrapper jar missing, downloading...
  "%JAVA_EXE%" -Dmaven.multiModuleProjectDirectory="%BASE_DIR%" -classpath "%BASE_DIR%\\.mvn\\wrapper\\maven-wrapper.jar" org.apache.maven.wrapper.MavenWrapperMain -v >NUL 2>&1
)

"%JAVA_EXE%" -Dmaven.multiModuleProjectDirectory="%BASE_DIR%" -classpath "%BASE_DIR%\\.mvn\\wrapper\\maven-wrapper.jar" org.apache.maven.wrapper.MavenWrapperMain %*

