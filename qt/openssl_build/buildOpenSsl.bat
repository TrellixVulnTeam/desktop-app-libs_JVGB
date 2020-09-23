@echo off

set OPENSSL_URL=https://www.openssl.org/source/openssl-1.1.1h.tar.gz
set OPENSSL_VERSION=1.1.1h

::TODO replace with real 7Zip.zip (for some reason, its impossible to find 7Zip in an ordinary .zip archive, which PS can extract)
set SZIP_URL=https://github.com/Squirrel/Squirrel.Windows/releases/download/1.9.1/Squirrel.Windows-1.9.1.zip
set PERL_URL=http://strawberryperl.com/download/5.32.0.1/strawberry-perl-5.32.0.1-32bit.zip
set NASM_URL=https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/win32/nasm-2.15.05-win32.zip

set OUT_X32=_out\openssl-%OPENSSL_VERSION%\win32-ia32
set OUT_X64=_out\openssl-%OPENSSL_VERSION%\win32-x64

::-------------------------------------------------------------------------------------------------

echo buildOpenSsl.bat

if not exist _out ( md _out )
del /s /q _out\*

::-------------------------------------------------------------------------------------------------

if not exist 7zip\7z.exe (
	if not exist 7zip.zip (
		echo buildOpenSsl.bat: downloading 7Zip...
		powershell.exe -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%SZIP_URL%' -OutFile '7zip.zip'" || exit /b 1
	)
	echo buildOpenSsl.bat: extracting 7Zip...
	md 7zip
	powershell.exe -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath '7zip.zip' -DestinationPath '7zip'" || exit /b 1
)
set PATH=%CD%\7zip;%PATH%

::-------------------------------------------------------------------------------------------------

if not exist perl\perl\bin\perl.exe (
	if not exist perl.zip (
		echo buildOpenSsl.bat: downloading Perl...
		powershell.exe -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%PERL_URL%' -OutFile 'perl.zip'" || exit /b 1
	)
	echo buildOpenSsl.bat: extracting Perl...
	md perl
	7z.exe x perl.zip -operl || exit /b 1

	pushd perl
	echo buildOpenSsl.bat: configuring Perl...
	call relocation.pl.bat || exit /b 1
	popd
)
set PATH=%CD%\perl\perl\bin;%PATH%

::-------------------------------------------------------------------------------------------------

if not exist nasm\nasm.exe (
	if not exist nasm.zip (
		echo buildOpenSsl.bat: downloading NASM...
		powershell.exe -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%NASM_URL%' -OutFile 'nasm.zip'" || exit /b 1
	)
	echo buildOpenSsl.bat: extracting NASM...
	7z.exe x "nasm.zip" || exit /b 1
	powershell.exe -ExecutionPolicy Bypass -Command "(Get-ChildItem 'nasm-*') | foreach-object { invoke-expression 'ren $_ nasm'; }" || exit /b 1
)
set PATH=%CD%\nasm;%PATH%

::-------------------------------------------------------------------------------------------------

if not exist openssl-%OPENSSL_VERSION%.tar.gz (
	echo buildOpenSsl.bat: downloading OpenSSL %OPENSSL_VERSION%...
	powershell.exe -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%OPENSSL_URL%' -OutFile 'openssl-%OPENSSL_VERSION%.tar.gz'" || exit /b 1
)

::-------------------------------------------------------------------------------------------------

echo buildOpenSsl.bat: extracting x32 OpenSSL...

if not exist _build_x32 ( md _build_x32 )
del /s /q _build_x32\* 1>nul
pushd _build_x32 || exit /b 1
7z.exe x -tgzip -so ..\openssl-%OPENSSL_VERSION%.tar.gz | 7z.exe x -si -ttar || exit /b 1
pushd openssl-%OPENSSL_VERSION% || exit /b 1

if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\Common7\Tools\VsMSBuildCmd.bat" (
	echo buildOpenSsl.bat: BuildTools env x32
	call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\Common7\Tools\VsMSBuildCmd.bat" -arch=x86
	call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x86
)
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat" (
	echo buildOpenSsl.bat: Community env x32
	call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat" -arch=x86
	call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" x86
)

echo buildOpenSsl.bat: configuring x32 OpenSSL...
perl Configure no-zlib VC-WIN32 || exit /b 1

echo buildOpenSsl.bat: building x32 OpenSSL...
nmake || exit /b 1

echo buildOpenSsl.bat: copying libssl-1_1.dll...
md ..\..\%OUT_X32%
copy libssl-1_1.dll ..\..\%OUT_X32% || exit /b 1
echo buildOpenSsl.bat: copying libcrypto-1_1.dll...
copy libcrypto-1_1.dll ..\..\%OUT_X32% || exit /b 1

popd
popd

::-------------------------------------------------------------------------------------------------

echo buildOpenSsl.bat: extracting x64 OpenSSL...

if not exist _build_x64 ( md _build_x64 )
del /s /q _build_x64\* 1>nul
pushd _build_x64 || exit /b 1
7z.exe x -tgzip -so ..\openssl-%OPENSSL_VERSION%.tar.gz | 7z.exe x -si -ttar || exit /b 1
pushd openssl-%OPENSSL_VERSION% || exit /b 1

if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\Common7\Tools\VsMSBuildCmd.bat" (
	echo buildOpenSsl.bat: BuildTools env x32
	call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\Common7\Tools\VsMSBuildCmd.bat" -arch=amd64
	call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64
)
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat" (
	echo buildOpenSsl.bat: Community env x32
	call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat" -arch=amd64
	call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
)

echo buildOpenSsl.bat: configuring x64 OpenSSL...
perl Configure no-zlib VC-WIN64A || exit /b 1

echo buildOpenSsl.bat: building x64 OpenSSL...
nmake || exit /b 1

echo buildOpenSsl.bat: copying libssl-1_1-x64.dll...
md ..\..\%OUT_X64%
copy libssl-1_1-x64.dll ..\..\%OUT_X64% || exit /b 1
echo buildOpenSsl.bat: copying libcrypto-1_1-x64.dll...
copy libcrypto-1_1-x64.dll ..\..\%OUT_X64% || exit /b 1

popd
popd

::-------------------------------------------------------------------------------------------------

echo buildOpenSsl.bat: packing artifacts
pushd _out
del /s /q openssl-%OPENSSL_VERSION%.zip
7z a openssl-%OPENSSL_VERSION%.zip *
popd

echo buildOpenSsl.bat: done
