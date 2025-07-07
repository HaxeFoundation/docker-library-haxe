import haxe.*;
import haxe.io.*;
import sys.*;
import sys.io.*;
using Lambda;

typedef Sha256Values = {?src:String, ?win:String};
typedef NekoVersion = {version:String, tag:String, sha256:Sha256Values, pcre2:Bool, gtk3:Bool};
typedef HaxeVersion = {
	version:String,
	tag:String,
	sha256:Sha256Values,
	exclude:Array<String>,
	pcre2:Bool, winNeko:NekoVersion,
	opamPins:Array<{
		lib:String,
		version:String,
		?variants:Array<String>,
	}>
};
typedef Variant = {variant:String, suffix:Array<String>};

enum Family {
	Debian;
	WindowsServerCore;
	Alpine;
}

class Update {
	static final HEADER =
'#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "haxe update.hxml"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#';
	static final neko = {
		v2_4_1: {
			"version": "2.4.1",
			"tag": "v2-4-1",
			"sha256": {
				"src": "702282028190dffa2078b00cca515b8e2ba889186a221df2226d2b6deb3ffaca",
				"win": "3902933da42320e8bc04dbee07959ee9ff09a7848e9af48072396400cc3618c9",
			},
			pcre2: true,
			gtk3: true,
		},
		v2_3_0: {
			"version": "2.3.0",
			"tag": "v2-3-0",
			"sha256": {
				"src": "850e7e317bdaf24ed652efeff89c1cb21380ca19f20e68a296c84f6bad4ee995",
				"win": "d09fdf362cd2e3274f6c8528be7211663260c3a5323ce893b7637c2818995f0b",
			},
			pcre2: false,
			gtk3: false,
		}
	}

	//The first item is considered as "latest". Beta/RC versions should not be put as the first item.
	static public final versions:Array<HaxeVersion> = [
		{
			"version": "4.3.7",
			"tag": "4.3.7",
			"sha256": {"win": "29f7acb0fb9fc66a2b9f6bd9453af3474ccb14ebd9fd0142f351d7311c4010c9"},
			"exclude": [],
			"pcre2": true,
			"winNeko": neko.v2_4_1,
			"opamPins": [
			],
		},
		{
			"version": "5.0.0-preview.1",
			"tag": "5.0.0-preview.1",
			"sha256": {"win": "c223025518c6a527c66bd6c9ca51b4eff848ffcac97fc6c1833d1338cef1622e"},
			"exclude": [],
			"pcre2": true,
			"winNeko": neko.v2_4_1,
			"opamPins": [
			],
		},
		{
			"version": "4.2.5",
			"tag": "4.2.5",
			"sha256": {"win": "9e7913999eb3693d540926219b45107b3dc249feb44204c0378fcdc6a74a9132"},
			"exclude": [],
			"pcre2": false,
			"winNeko": neko.v2_3_0,
			"opamPins": [
				{"lib": "extlib", "version": "1.7.9"},
			],
		},
		{
			"version": "4.1.5",
			"tag": "4.1.5",
			"sha256": {"win": "ce4134cdf49814f8f8694648408d006116bd171b957a37be74c79cf403db9633"},
			"exclude": ["bookworm"],
			"pcre2": false,
			"winNeko": neko.v2_3_0,
			"opamPins": [
				{"lib": "extlib", "version": "1.7.7"},
				{"lib": "camlp5", "version": "8.03.01", "variants":["bullseye"]},
			],
		},
		{
			"version": "4.0.5",
			"tag": "4.0.5",
			"sha256": {"win": "93130ae2b1083efbcd9b8911afe2ba00d5af995f016149fd7ec629fa439c6120"},
			"exclude": ["bookworm"],
			"pcre2": false,
			"winNeko": neko.v2_3_0,
			"opamPins": [
				{"lib": "extlib", "version": "1.7.7"},
				{"lib": "camlp5", "version": "8.03.01", "variants":["bullseye"]},
			],
		},
	];

	static public final variants = [
		Debian => ["bookworm", "bullseye"],
		WindowsServerCore => ["windowsservercore-ltsc2022", "windowsservercore-1809"],
		Alpine => ["alpine3.20", "alpine3.19", "alpine3.18"],
	];

	static public function parseVersion(version:String) {
		final t = version.split("-");
		final nums = t[0].split(".").map(Std.parseInt);
		return {
			major: nums[0],
			minor: nums[1],
			patch: nums[2],
			tag: t[1],
		}
	}

	static public function verMajorMinor(version:String):String {
		final v = parseVersion(version);
		return v.major + "." + v.minor;
	}

	static public function verMajorMinorPatch(version:String):String {
		final v = parseVersion(version);
		return v.major + "." + v.minor + "." + v.patch;
	}

	static public function dockerfilePath(version:HaxeVersion, variant:String):String {
		final majorMinor = verMajorMinor(version.version);
		return Path.join([majorMinor, variant, "Dockerfile"]);
	}

	static public function getHaxeFileUrl(version:HaxeVersion, family:Family):String {
		return switch(family) {
			case WindowsServerCore:
				'https://github.com/HaxeFoundation/haxe/releases/download/${version.tag}/haxe-${version.version}-win64.zip';
			case _:
				null;
		}
	}

	static function main():Void {
		switch (Sys.args()) {
			case ["getHaxeFileUrl", version, family]:
				final version = versions.find(v -> v.version == version);
				Sys.println(getHaxeFileUrl(version, Family.createByName(family)));
				Sys.exit(0);
			case []:
				//pass
			case _:
				throw 'Invalid arguments';
		}

		for (family => variants in variants)
		for (variant in variants)
		{
			final tmpl = new Template(File.getContent('Dockerfile-${variant}.template'));
			for (version in versions) {
				if (version.exclude.indexOf(variant) >= 0)
					continue;
				final v = parseVersion(version.version);
				final neko = switch (family) {
					case WindowsServerCore:
						version.winNeko;
					case _:
						neko.v2_4_1;
				};
				final vars = {
					HAXE_VERSION: version.version,
					HAXE_VERSION_MAJOR: v.major,
					HAXE_VERSION_MINOR: v.minor,
					HAXE_VERSION_PATCH: v.patch,
					HAXE_TAG: version.tag,
					HAXE_FILE: getHaxeFileUrl(version, family),
					HAXE_SHA256: switch(family) {
						case WindowsServerCore:
							version.sha256.win;
						case _:
							null;
					},
					NEKO_VERSION: neko.version,
					NEKO_TAG: neko.tag,
					NEKO_SHA256: switch(family) {
						case WindowsServerCore:
							neko.sha256.win;
						case _:
							neko.sha256.src;
					},
					NEKO_PCRE2: neko.pcre2,
					NEKO_GTK3: neko.gtk3,
					HEADER: HEADER,
					PCRE2: version.pcre2,
					OPAM_PINS: version.opamPins.filter(pin -> pin.variants == null || pin.variants.indexOf(variant) >= 0),
				};
				final path = dockerfilePath(version, variant);
				FileSystem.createDirectory(Path.directory(path));
				File.saveContent(path, tmpl.execute(vars));
			}
		}
	}
}
