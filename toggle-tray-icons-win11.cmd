@echo off

rem Windows 11 Tray Icons visibility toggle

rem getting current Windows UI language
for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CONTROLSET001\CONTROL\NLS\Language" /v Installlanguage') do set UILanguage=%%a
if %UILanguage%=="" set UILanguage=0409

if %UILanguage%==0419 (
	chcp 1251 >nul 2>&1
) else (
	chcp 65001 >nul 2>&1
)

rem declaring an extended types for variables to use it for incrementing numerical values  
@setlocal enabledelayedexpansion

if [%1]==[] (
	rem forcing to reveal tray icons if no program arguments
	set Enabled=1
) else (
	rem using argument value (2 or 1) to set tray icons visibility, if it was given by user at launch
	set Enabled=0
)

cls
@echo.
if %UILanguage%==0419 (
	@echo  Переключение видимости значков в области уведомлений...
	@echo.
	rem using "^" symbol to represent brackets as text instead of logical scope
	@echo  ^(чтобы скрыть значки, задайте абсолютной любой параметр запуска^)
) else (
	@echo  Switching visibility of Tray icons...
	@echo.
	@echo  ^(To hide Tray icons, just set any launch parameter^)
)
@echo.

rem getting Windows user SID to use it in registry path
for /f "tokens=2" %%i in ('whoami /user /fo table /nh') do set usersid=%%i

rem searching for words 1 and 2 in command's output text, specified inside single quotes
for /f "tokens=1-2" %%a in ('reg query "HKEY_USERS\%usersid%\Control Panel\NotifyIconSettings"') do (
	rem since the command above initially outputs registry paths separated by the white
	rem space in the middle, then we filter out all strings except actual paths containing subkeys
	if %%a==HKEY_USERS\%usersid%\Control (

		rem filtering single row, which does not contain backslash "\", others will pass
		if not %%b==Panel\NotifyIconSettings (

			rem writing target registry value in each subkey
			reg add "%%a %%b" /v "IsPromoted" /t REG_DWORD /d %Enabled% /f >nul 2>&1
		)
	)
)

@echo.
@echo.
if %UILanguage%==0419 (
	@echo  Готово.
) else (
	@echo  Done.
)

rem showing result for 3 seconds before closing
ping localhost -n 3 >nul 2>&1

exit /b