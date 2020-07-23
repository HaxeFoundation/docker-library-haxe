import haxe.*;
import haxe.io.*;
import sys.*;
import sys.io.*;

typedef Version = {version:String, tag:String, sha256:Dynamic, win64:Bool, nekowin64:Bool, exclude:Array<String>, opam:Bool};
typedef Variant = {variant:String, suffix:Array<String>};

class Update {
	static var HEADER =
'#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "haxe update.hxml"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#';

	//The first item is considered as "latest". Beta/RC versions should not be put as the first item.
	static public var versions:Array<Version> = [
		{
			"version": "4.1.3",
			"tag": "4.1.3",
			"win64": true,
			"nekowin64": true,
			"sha256": {"win": "547edd2478e5fc17eddbcc473c3ecf84743a20bfd630cb61148c538e179f4a71"},
			"exclude": ["stretch"],
			"opam": true
		},
		{
			"version": "4.0.5",
			"tag": "4.0.5",
			"win64": true,
			"nekowin64": true,
			"sha256": {"win": "93130ae2b1083efbcd9b8911afe2ba00d5af995f016149fd7ec629fa439c6120"},
			"exclude": [],
			"opam": true
		},
		{
			"version": "3.4.7",
			"tag": "3.4.7",
			"win64": true,
			"nekowin64": false,
			"sha256": {"win": "609acdcb58a2253e357487d495ffe19e9034165f3102f8716ca968afbee8f1b2"},
			"exclude": [],
			"opam": false
		},
		{
			"version": "3.3.0-rc.1",
			"tag": "3.3.0-rc1",
			"win64": false,
			"nekowin64": false,
			"sha256": {"win": "fa51621132432328a47e5e0416ab3b9f2f734b217a2bc9b650826aae2f12c6f4"},
			"exclude": [],
			"opam": false
		},
		{
			"version": "3.2.1",
			"tag": "3.2.1",
			"win64": false,
			"nekowin64": false,
			"sha256": {"win": "af57d42ca474bba826426e9403b2cb21c210d56addc8bbc0e8fafa88b3660db3"},
			"exclude": [],
			"opam": false
		},
		{
			"version": "3.1.3",
			"tag": "3.1.3",
			"win64": false,
			"nekowin64": false,
			"sha256": {"win": "4cf84cdbf7960a61ae70b0d9166c6f9bde16388c3b81e54af91446f4c9e44ae4"},
			"exclude": ["alpine3.9", "alpine3.10", "alpine3.11", "alpine3.12", "buster"],
			"opam": false
		},
	];

	static public var variants:Array<Variant> = [
		{
			"variant": "buster",
			"suffix": ["buster", ""]
		},
		{
			"variant": "stretch",
			"suffix": ["stretch"]
		},
		{
			"variant": "windowsservercore-1809",
			"suffix": ["windowsservercore-1809", "windowsservercore", ""]
		},
		{
			"variant": "windowsservercore-ltsc2016",
			"suffix": ["windowsservercore-ltsc2016", "windowsservercore", ""]
		},
		// neko and haxelib are still 32-bit only
		// {
		// 	"variant": "nanoserver",
		// 	"suffix": ["nanoserver"]
		// },
		{
			"variant": "alpine3.12",
			"suffix": ["alpine3.12", "alpine"]
		},
		{
			"variant": "alpine3.11",
			"suffix": ["alpine3.11"]
		},
		{
			"variant": "alpine3.10",
			"suffix": ["alpine3.10"]
		},
		{
			"variant": "alpine3.9",
			"suffix": ["alpine3.9"]
		},
	];

	static public function verMajorMinor(version:String):String {
		return version.split(".").slice(0, 2).join(".");
	}

	static public function verMajorMinorPatch(version:String):String {
		return version.split("-")[0];
	}

	static public function dockerfilePath(version:Version, variant:Variant):String {
		var majorMinor = verMajorMinor(version.version);
		return if (variant.suffix[0] == "")
			Path.join([majorMinor, "Dockerfile"]);
		else
			Path.join([majorMinor, variant.suffix[0], "Dockerfile"]);
	}

	static function main():Void {
		for (variant in variants) {
			var tmpl = new Template(File.getContent('Dockerfile-${variant.variant}.template'));
			for (version in versions) {
				if (version.exclude.indexOf(variant.variant) >= 0)
					continue;
				switch ([variant.variant, version.win64]) {
					case ["nanoserver", false]:
						continue;
					case _:
						//pass
				}
				var vars = {
					HAXE_VERSION: version.version,
					HAXE_TAG: version.tag,
					HAXE_FILE: switch(variant.variant) {
						case "windowsservercore-1809"|"windowsservercore-ltsc2016"|"nanoserver":
							'https://github.com/HaxeFoundation/haxe/releases/download/${version.tag}/haxe-${version.version}-win${version.win64 ? "64" : ""}.zip';
						case _:
							null;
					},
					HAXE_SHA256: switch(variant.variant) {
						case "windowsservercore-1809"|"windowsservercore-ltsc2016"|"nanoserver":
							version.sha256.win;
						case _:
							null;
					},
					NEKO_VERSION: "2.3.0",
					NEKO_TAG: "v2-3-0",
					NEKO_SHA256: switch(variant.variant) {
						case "windowsservercore-1809"|"windowsservercore-ltsc2016"|"nanoserver":
							if (version.nekowin64)
								"d09fdf362cd2e3274f6c8528be7211663260c3a5323ce893b7637c2818995f0b"
							else
								"fe5a11350d2dd74338f971d62115f2bd21ec6912f193db04c5d28eb987a50485";
						case _:
							"850e7e317bdaf24ed652efeff89c1cb21380ca19f20e68a296c84f6bad4ee995";
					},
					NEKO_WIN: version.nekowin64 ? "win64" : "win",
					HEADER: HEADER,
					USE_OPAM: version.opam,
				};
				var path = dockerfilePath(version, variant);
				FileSystem.createDirectory(Path.directory(path));
				File.saveContent(path, tmpl.execute(vars));
			}
		}
	}
}
