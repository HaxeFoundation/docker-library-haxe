import haxe.*;
import haxe.io.*;
import sys.*;
import sys.io.*;

typedef Version = {version:String, tag:String, sha256:Dynamic, win64:Bool, nekowin64:Bool, exclude:Array<String>, ?pcre2:Bool };
typedef Variant = {variant:String, suffix:Array<String>};

enum Family {
	Debian;
	WindowsServerCore;
	Alpine;
}

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
			"version": "4.3.4",
			"tag": "4.3.4",
			"win64": true,
			"nekowin64": true,
			"sha256": {"win": "402ca2e8fd08477b5c08191bddc0e9af3b58484308dde4558f670a455bc3e503"},
			"exclude": [],
			"pcre2": true,
		},
		{
			"version": "4.2.5",
			"tag": "4.2.5",
			"win64": true,
			"nekowin64": true,
			"sha256": {"win": "9e7913999eb3693d540926219b45107b3dc249feb44204c0378fcdc6a74a9132"},
			"exclude": [],
		},
		{
			"version": "4.1.5",
			"tag": "4.1.5",
			"win64": true,
			"nekowin64": true,
			"sha256": {"win": "ce4134cdf49814f8f8694648408d006116bd171b957a37be74c79cf403db9633"},
			"exclude": ["bookworm"],
		},
		{
			"version": "4.0.5",
			"tag": "4.0.5",
			"win64": true,
			"nekowin64": true,
			"sha256": {"win": "93130ae2b1083efbcd9b8911afe2ba00d5af995f016149fd7ec629fa439c6120"},
			"exclude": ["bookworm"],
		},
	];

	static public var variants = [
		Debian => ["bookworm", "bullseye"],
		WindowsServerCore => ["windowsservercore-ltsc2022", "windowsservercore-1809"],
		Alpine => ["alpine3.19", "alpine3.18", "alpine3.17", "alpine3.16"],
	];

	static public function parseVersion(version:String) {
		var t = version.split("-");
		var nums = t[0].split(".").map(Std.parseInt);
		return {
			major: nums[0],
			minor: nums[1],
			patch: nums[2],
			tag: t[1],
		}
	}

	static public function verMajorMinor(version:String):String {
		var v = parseVersion(version);
		return v.major + "." + v.minor;
	}

	static public function verMajorMinorPatch(version:String):String {
		var v = parseVersion(version);
		return v.major + "." + v.minor + "." + v.patch;
	}

	static public function dockerfilePath(version:Version, variant:String):String {
		var majorMinor = verMajorMinor(version.version);
		return Path.join([majorMinor, variant, "Dockerfile"]);
	}

	static function main():Void {
		for (family => variants in variants)
		for (variant in variants)
		{
			var tmpl = new Template(File.getContent('Dockerfile-${variant}.template'));
			for (version in versions) {
				if (version.exclude.indexOf(variant) >= 0)
					continue;
				switch ([variant, version.win64]) {
					case ["nanoserver", false]:
						continue;
					case _:
						//pass
				}
				var v = parseVersion(version.version);
				var vars = {
					HAXE_VERSION: version.version,
					HAXE_VERSION_MAJOR: v.major,
					HAXE_VERSION_MINOR: v.minor,
					HAXE_VERSION_PATCH: v.patch,
					HAXE_TAG: version.tag,
					HAXE_FILE: switch(family) {
						case WindowsServerCore:
							'https://github.com/HaxeFoundation/haxe/releases/download/${version.tag}/haxe-${version.version}-win${version.win64 ? "64" : ""}.zip';
						case _:
							null;
					},
					HAXE_SHA256: switch(family) {
						case WindowsServerCore:
							version.sha256.win;
						case _:
							null;
					},
					NEKO_VERSION: "2.3.0",
					NEKO_TAG: "v2-3-0",
					NEKO_SHA256: switch(family) {
						case WindowsServerCore:
							if (version.nekowin64)
								"d09fdf362cd2e3274f6c8528be7211663260c3a5323ce893b7637c2818995f0b"
							else
								"fe5a11350d2dd74338f971d62115f2bd21ec6912f193db04c5d28eb987a50485";
						case _:
							"850e7e317bdaf24ed652efeff89c1cb21380ca19f20e68a296c84f6bad4ee995";
					},
					NEKO_WIN: version.nekowin64 ? "win64" : "win",
					HEADER: HEADER,
					PCRE2: version.pcre2,
				};
				var path = dockerfilePath(version, variant);
				FileSystem.createDirectory(Path.directory(path));
				File.saveContent(path, tmpl.execute(vars));
			}
		}
	}
}
