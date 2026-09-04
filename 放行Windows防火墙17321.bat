@echo off
chcp 65001 >nul
echo ?????????? 17321 ??...
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
netsh advfirewall firewall delete rule name="Token Monitor Hub" >nul 2>&1
netsh advfirewall firewall add rule name="Token Monitor Hub" dir=in action=allow protocol=TCP localport=17321
echo.
echo ========================================================
echo   [OK] Windows ???????? 17321 TCP ???
echo ========================================================
pause
