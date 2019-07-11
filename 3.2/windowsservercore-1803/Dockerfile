#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "haxe update.hxml"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM mcr.microsoft.com/windows/servercore:1803

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

ENV HAXETOOLKIT_PATH C:\\HaxeToolkit
ENV NEKOPATH $HAXETOOLKIT_PATH\\neko
ENV HAXEPATH $HAXETOOLKIT_PATH\\haxe
ENV HAXE_STD_PATH $HAXEPATH\\std
ENV HAXELIB_PATH $HAXEPATH\\lib

# PATH isn't actually set in the Docker image, so we have to set it from within the container
RUN $newPath = ('{0};{1};{2}' -f $env:HAXEPATH, $env:NEKOPATH, $env:PATH); \
	Write-Host ('Updating PATH: {0}' -f $newPath); \
	[Environment]::SetEnvironmentVariable('PATH', $newPath, [EnvironmentVariableTarget]::Machine);
# doing this first to share cache across versions more aggressively

# haxelib.exe needs msvcr120.dll
RUN $url = 'https://download.microsoft.com/download/0/5/6/056dcda9-d667-4e27-8001-8a0c6971d6b1/vcredist_x86.exe'; \
	Write-Host ('Downloading {0} ...' -f $url); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $url -OutFile 'vcredist_x86.exe'; \
	\
	Write-Host 'Verifying sha256 (89f4e593ea5541d1c53f983923124f9fd061a1c0c967339109e375c661573c17) ...'; \
	if ((Get-FileHash vcredist_x86.exe -Algorithm sha256).Hash -ne '89f4e593ea5541d1c53f983923124f9fd061a1c0c967339109e375c661573c17') { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host 'Installing ...'; \
	Start-Process -FilePath "vcredist_x86.exe" -ArgumentList "/Q" -Wait; \
	\
	Write-Host 'Removing installer...'; \
	Remove-Item .\vcredist_x86.exe; \
	\
	Write-Host 'Complete.';

# install Amazon Root CA (expires in 2037), which allows haxelib to talk to https://lib.haxe.org
RUN $cert = \"-----BEGIN CERTIFICATE-----`n\
MIIEkjCCA3qgAwIBAgITBn+USionzfP6wq4rAfkI7rnExjANBgkqhkiG9w0BAQsF`n\
ADCBmDELMAkGA1UEBhMCVVMxEDAOBgNVBAgTB0FyaXpvbmExEzARBgNVBAcTClNj`n\
b3R0c2RhbGUxJTAjBgNVBAoTHFN0YXJmaWVsZCBUZWNobm9sb2dpZXMsIEluYy4x`n\
OzA5BgNVBAMTMlN0YXJmaWVsZCBTZXJ2aWNlcyBSb290IENlcnRpZmljYXRlIEF1`n\
dGhvcml0eSAtIEcyMB4XDTE1MDUyNTEyMDAwMFoXDTM3MTIzMTAxMDAwMFowOTEL`n\
MAkGA1UEBhMCVVMxDzANBgNVBAoTBkFtYXpvbjEZMBcGA1UEAxMQQW1hem9uIFJv`n\
b3QgQ0EgMTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALJ4gHHKeNXj`n\
ca9HgFB0fW7Y14h29Jlo91ghYPl0hAEvrAIthtOgQ3pOsqTQNroBvo3bSMgHFzZM`n\
9O6II8c+6zf1tRn4SWiw3te5djgdYZ6k/oI2peVKVuRF4fn9tBb6dNqcmzU5L/qw`n\
IFAGbHrQgLKm+a/sRxmPUDgH3KKHOVj4utWp+UhnMJbulHheb4mjUcAwhmahRWa6`n\
VOujw5H5SNz/0egwLX0tdHA114gk957EWW67c4cX8jJGKLhD+rcdqsq08p8kDi1L`n\
93FcXmn/6pUCyziKrlA4b9v7LWIbxcceVOF34GfID5yHI9Y/QCB/IIDEgEw+OyQm`n\
jgSubJrIqg0CAwEAAaOCATEwggEtMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/`n\
BAQDAgGGMB0GA1UdDgQWBBSEGMyFNOy8DJSULghZnMeyEE4KCDAfBgNVHSMEGDAW`n\
gBScXwDfqgHXMCs4iKK4bUqc8hGRgzB4BggrBgEFBQcBAQRsMGowLgYIKwYBBQUH`n\
MAGGImh0dHA6Ly9vY3NwLnJvb3RnMi5hbWF6b250cnVzdC5jb20wOAYIKwYBBQUH`n\
MAKGLGh0dHA6Ly9jcnQucm9vdGcyLmFtYXpvbnRydXN0LmNvbS9yb290ZzIuY2Vy`n\
MD0GA1UdHwQ2MDQwMqAwoC6GLGh0dHA6Ly9jcmwucm9vdGcyLmFtYXpvbnRydXN0`n\
LmNvbS9yb290ZzIuY3JsMBEGA1UdIAQKMAgwBgYEVR0gADANBgkqhkiG9w0BAQsF`n\
AAOCAQEAYjdCXLwQtT6LLOkMm2xF4gcAevnFWAu5CIw+7bMlPLVvUOTNNWqnkzSW`n\
MiGpSESrnO09tKpzbeR/FoCJbM8oAxiDR3mjEH4wW6w7sGDgd9QIpuEdfF7Au/ma`n\
eyKdpwAJfqxGF4PcnCZXmTA5YpaP7dreqsXMGz7KQ2hsVxa81Q4gLv7/wmpdLqBK`n\
bRRYh5TmOTFffHPLkIhqhBGWJ6bt2YFGpn6jcgAKUj6DiAdjd4lpFw85hdKrCEVN`n\
0FE6/V1dN2RMfjCyVSRCnTawXZwXgWHxyvkQAiSr6w10kY17RSlQOYiypok1JR4U`n\
akcjMS9cmvqtmg5iUaQqqcT5NJ0hGA==`n\
-----END CERTIFICATE-----\";\
	Set-Content -Path C:\amazon.cer -Value $cert; \
	Import-Certificate -FilePath C:\amazon.cer -CertStoreLocation Cert:\LocalMachine\Root\; \
	Remove-Item -Path C:\amazon.cer;

RUN New-Item -ItemType directory -Path $env:HAXETOOLKIT_PATH;

# install neko, which is a dependency of haxelib
ENV NEKO_VERSION 2.2.0
RUN $url = 'https://github.com/HaxeFoundation/neko/releases/download/v2-2-0/neko-2.2.0-win.zip'; \
	Write-Host ('Downloading {0} ...' -f $url); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $url -OutFile 'neko.zip'; \
	\
	Write-Host 'Verifying sha256 (93d7ca96698a6825f38ca8eea49e2e6b691c0849270174f6c1bd531290db8d69) ...'; \
	if ((Get-FileHash neko.zip -Algorithm sha256).Hash -ne '93d7ca96698a6825f38ca8eea49e2e6b691c0849270174f6c1bd531290db8d69') { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host 'Expanding ...'; \
	New-Item -ItemType directory -Path tmp; \
	Expand-Archive -Path neko.zip -DestinationPath tmp; \
	if (Test-Path tmp\neko.exe) { Move-Item tmp $env:NEKOPATH } \
	else { Move-Item (Resolve-Path tmp\neko* | Select -ExpandProperty Path) $env:NEKOPATH }; \
	\
	Write-Host 'Removing ...'; \
	Remove-Item -Path neko.zip, tmp -Force -Recurse -ErrorAction Ignore; \
	\
	Write-Host 'Verifying install ...'; \
	Write-Host '  neko -version'; neko -version; \
	\
	Write-Host 'Complete.';

# install haxe
ENV HAXE_VERSION 3.2.1
RUN $url = 'https://github.com/HaxeFoundation/haxe/releases/download/3.2.1/haxe-3.2.1-win.zip'; \
	Write-Host ('Downloading {0} ...' -f $url); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $url -OutFile haxe.zip; \
	\
	Write-Host 'Verifying sha256 (af57d42ca474bba826426e9403b2cb21c210d56addc8bbc0e8fafa88b3660db3) ...'; \
	if ((Get-FileHash haxe.zip -Algorithm sha256).Hash -ne 'af57d42ca474bba826426e9403b2cb21c210d56addc8bbc0e8fafa88b3660db3') { \
		Write-Host 'FAILED!'; \
		exit 1; \
	}; \
	\
	Write-Host 'Expanding ...'; \
	New-Item -ItemType directory -Path tmp; \
	Expand-Archive -Path haxe.zip -DestinationPath tmp; \
	if (Test-Path tmp\haxe.exe) { Move-Item tmp $env:HAXEPATH } \
	else { Move-Item (Resolve-Path tmp\haxe* | Select -ExpandProperty Path) $env:HAXEPATH }; \
	\
	Write-Host 'Removing ...'; \
	Remove-Item -Path haxe.zip, tmp -Force -Recurse -ErrorAction Ignore; \
	\
	Write-Host 'Verifying install ...'; \
	Write-Host '  haxe -version'; haxe -version; \
	Write-Host '  haxelib version'; haxelib version; \
	\
	Write-Host 'Complete.';

RUN New-Item -ItemType directory -Path $env:HAXELIB_PATH;

# haxelib bundled in haxe 3.2 and below depends on these variables
ENV HOMEDRIVE C:
RUN $newPath = ('{0}\Users\{1}' -f $env:HOMEDRIVE, $env:USERNAME); \
	Write-Host ('Updating HOMEPATH: {0}' -f $newPath); \
	[Environment]::SetEnvironmentVariable('HOMEPATH', $newPath, [EnvironmentVariableTarget]::Machine);

CMD ["haxe"]
