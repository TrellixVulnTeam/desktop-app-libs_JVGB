@echo off

:: before pasting this script into TC, do "%" -> "%%" replace (except those around TC variables)

echo buildOpenSsl.bat

set S3_PREFIX=https://samepage-swarchive.s3-eu-west-1.amazonaws.com/openssl

:: https://www.openssl.org/source/openssl-1.1.1h.tar.gz
set OPENSSL_URL=%S3_PREFIX%/openssl-1.1.1h.tar.gz
set OPENSSL_VERSION=1.1.1h

set SZIP_URL=%S3_PREFIX%/7z-19.0.0-32bit.zip
set PERL_URL=%S3_PREFIX%/strawberry-perl-5.32.0.1-32bit.zip
set NASM_URL=%S3_PREFIX%/nasm-2.15.05-win32.zip

set OUT_X32=_out\openssl-%OPENSSL_VERSION%\win32-ia32
set OUT_X64=_out\openssl-%OPENSSL_VERSION%\win32-x64

::-------------------------------------------------------------------------------------------------

if not exist 7z\7z.exe (
	if not exist 7z.zip (
		echo buildOpenSsl.bat: downloading 7Zip...
		powershell.exe -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%SZIP_URL%' -OutFile '7z.zip'" || exit /b 1
	)
	echo buildOpenSsl.bat: extracting 7Zip...
	powershell.exe -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath '7z.zip' -DestinationPath '.'" || exit /b 1
)
set PATH=%CD%\7z;%PATH%

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
	call relocation.pl.bat 1>nul || exit /b 1
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

echo buildOpenSsl.bat: clearing out folder
if not exist _out ( md _out )
del /s /q _out\*

::-------------------------------------------------------------------------------------------------

echo buildOpenSsl.bat: clearing x32 build folder
if not exist _build_x32 ( md _build_x32 )
del /s /q _build_x32\* 1>nul

echo buildOpenSsl.bat: extracting OpenSSL into x32 build folder
pushd _build_x32 || exit /b 1
7z.exe x -tgzip -so ..\openssl-%OPENSSL_VERSION%.tar.gz | 7z.exe x -si -ttar || exit /b 1
pushd openssl-%OPENSSL_VERSION% || exit /b 1

echo buildOpenSsl.bat: including VS2017 x32 env
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools" (
	echo buildOpenSsl.bat: VS2017 BuildTools x32 env
	call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x86
)
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community" (
	echo buildOpenSsl.bat: VS2017 Community x32 env
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

echo buildOpenSsl.bat: clearing x64 build folder
if not exist _build_x64 ( md _build_x64 )
del /s /q _build_x64\* 1>nul

echo buildOpenSsl.bat: extracting OpenSSL into x64 build folder
pushd _build_x64 || exit /b 1
7z.exe x -tgzip -so ..\openssl-%OPENSSL_VERSION%.tar.gz | 7z.exe x -si -ttar || exit /b 1
pushd openssl-%OPENSSL_VERSION% || exit /b 1

echo buildOpenSsl.bat: including VS2017 x64 env
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools" (
	echo buildOpenSsl.bat: VS2017 BuildTools x64 env
	call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64
)
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community" (
	echo buildOpenSsl.bat: VS2017 Community x64 env
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
7z a openssl-%OPENSSL_VERSION%.zip * || exit /b 1
popd

echo buildOpenSsl.bat: done
