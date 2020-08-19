SET PATH=C:\Work\sioclient\repository\sioclient-bin\wix;%PATH%

RMDIR /S /Q win32-ia32
RMDIR /S /Q win32-x64
RMDIR /S /Q win32-ia32_temp
RMDIR /S /Q win32-x64_temp

MKDIR win32-ia32
MKDIR win32-x64
MKDIR win32-ia32_temp
MKDIR win32-x64_temp

@ECHO "extractFromVcRedist.bat: arch: x86"
dark.exe vc_redist.x86.exe -x win32-ia32_temp
msiexec /a win32-ia32_temp\AttachedContainer\packages\vcRuntimeMinimum_x86\vc_runtimeMinimum_x86.msi /qb /l win32-ia32_temp\log.txt TARGETDIR="%cd%\win32-ia32_temp"
cp win32-ia32_temp\System\*.dll win32-ia32
RMDIR /S /Q win32-ia32_temp

@ECHO "extractFromVcRedist.bat: arch: x64"
dark.exe vc_redist.x64.exe -x win32-x64_temp
msiexec /a win32-x64_temp\AttachedContainer\packages\vcRuntimeMinimum_amd64\vc_runtimeMinimum_x64.msi /qb /l win32-x64_temp\log.txt TARGETDIR="%cd%\win32-x64_temp"
cp win32-x64_temp\System64\*.dll win32-x64
RMDIR /S /Q win32-x64_temp

@ECHO "extractFromVcRedist.bat: done"
