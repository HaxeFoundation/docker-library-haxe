#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "haxe update.hxml"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM mcr.microsoft.com/windows/servercore:ltsc2016

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
	\
	Write-Host 'Complete.';

RUN New-Item -ItemType directory -Path $env:HAXELIB_PATH;

# haxelib bundled in haxe 3.2 and below depends on these variables
ENV HOMEDRIVE C:
RUN $newPath = ('{0}\Users\{1}' -f $env:HOMEDRIVE, $env:USERNAME); \
	Write-Host ('Updating HOMEPATH: {0}' -f $newPath); \
	[Environment]::SetEnvironmentVariable('HOMEPATH', $newPath, [EnvironmentVariableTarget]::Machine);

CMD ["haxe"]
