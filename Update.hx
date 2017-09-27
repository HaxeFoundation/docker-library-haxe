import haxe.*;
import haxe.io.*;
import sys.*;
import sys.io.*;

class Update {
	static var HEADER =
'#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "haxe update.hxml"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#';

	static public var versions = [
		{
			"version": "3.4.3",
			"tag": "3.4.3",
			"sha256": {"win": "0ac0b4115ff2a551c8784bdc415f2355a392e866aff61f17cb116539fcf55f93"}
		},
		{
			"version": "3.3.0-rc.1",
			"tag": "3.3.0-rc1",
			"sha256": {"win": "fa51621132432328a47e5e0416ab3b9f2f734b217a2bc9b650826aae2f12c6f4"}
		},
		{
			"version": "3.2.1",
			"tag": "3.2.1",
			"sha256": {"win": "af57d42ca474bba826426e9403b2cb21c210d56addc8bbc0e8fafa88b3660db3"}
		},
		{
			"version": "3.1.3",
			"tag": "3.1.3",
			"sha256": {"win": "4cf84cdbf7960a61ae70b0d9166c6f9bde16388c3b81e54af91446f4c9e44ae4"}
		},
	];

	static public var variants = [
		{
			"variant": "stretch",
			"suffix": "stretch"
		},
		{
			"variant": "jessie",
			"suffix": "jessie"
		},
		{
			"variant": "onbuild",
			"suffix": "onbuild"
		},
		{
			"variant": "windowsservercore",
			"suffix": "windowsservercore"
		},
	];

	static public function verMajorMinor(version:String):String {
		return version.split(".").slice(0, 2).join(".");
	}

	static public function verMajorMinorPatch(version:String):String {
		return version.split("-")[0];
	}

	static public function dockerfilePath(version:{version:String, tag:String, sha256:Dynamic}, variant:{variant:String, suffix:String}):String {
		var majorMinor = verMajorMinor(version.version);
		return if (variant.suffix == "")
			Path.join([majorMinor, "Dockerfile"]);
		else
			Path.join([majorMinor, variant.suffix, "Dockerfile"]);
	}

	static function main():Void {
		for (variant in variants) {
			var tmpl = new Template(File.getContent('Dockerfile-${variant.variant}.template'));
			for (version in versions) {
				var vars = {
					HAXE_VERSION: version.version,
					HAXE_TAG: version.tag,
					HAXE_SHA256: switch(variant.variant) {
						case "windowsservercore":
							version.sha256.win;
						case _:
							null;
					},
					NEKO_VERSION: "2.1.0",
					NEKO_SHA256: switch(variant.variant) {
						case "windowsservercore":
							"ad7f8ead8300cdbfdc062bcf7ba63b1b1993d975023cde2dfd61936950eddb0e";
						case _:
							"0c93d5fe96240510e2d1975ae0caa9dd8eadf70d916a868684f66a099a4acf96";
					},
					HEADER: HEADER,
				};
				var path = dockerfilePath(version, variant);
				FileSystem.createDirectory(Path.directory(path));
				File.saveContent(path, tmpl.execute(vars));
			}
		}
	}
}
