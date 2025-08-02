@echo off
setlocal EnableDelayedExpansion

set "output=roghoul.luau"
> "%output%" echo -- Generated automatically

:: === Adding Functions.luau ===
if exist "Functions.luau" (
    echo [INFO] Adding Functions.luau...
    >> "%output%" echo local Functions = function^(...^)
    type "Functions.luau" >> "%output%"
    >> "%output%" echo end
    >> "%output%" echo.
) else (
    echo [WARN] Functions.luau not found!
)

:: === Adding ESP.luau ===
if exist "ESP.luau" (
    echo [INFO] Adding ESP.luau...
    >> "%output%" echo local ESP = function^(...^)
    type "ESP.luau" >> "%output%"
    >> "%output%" echo end
    >> "%output%" echo.
) else (
    echo [WARN] ESP.luau not found!
)

:: === Adding GroupFunctions ===
echo [INFO] Adding Groups\*.luau...

>> "%output%" echo local GroupFunctions = {
for %%f in (Groups\*.luau) do (
    echo [INFO] Operating: %%f

    >> "%output%" echo.
    >> "%output%" echo %%~nf = function^(...^)
    type "%%f" >> "%output%"
    >> "%output%" echo end,
)
>> "%output%" echo }

:: === Adding main.luau ===
echo [INFO] Adding main.luau...
if exist "main.luau" (
    >> "%output%" echo.
    type main.luau >> "%output%"
) else (
    echo [ERROR] main.luau not found!
)

echo.
echo [OK] File created: %output%
copy "%output%" "C:\Users\PC\AppData\Local\LX63\workspace\%output%" /Y
exit /b