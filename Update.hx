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
			"version": "3.1.3",
			"tag": "3.1.3"
		},
		{
			"version": "3.2.1",
			"tag": "3.2.1"
		},
		{
			"version": "3.3.0-rc.1",
			"tag": "3.3.0-rc1"
		},
		{
			"version": "3.4.0-rc.1",
			"tag": "3.4.0-rc1"
		}
	];

	static public var variants = [
		{
			"variant": "debian",
			"suffix": ""
		}
	];

	static public function verMajorMinor(version:String):String {
		return version.split(".").slice(0, 2).join(".");
	}

	static public function verMajorMinorPatch(version:String):String {
		return version.split("-")[0];
	}

	static public function dockerfilePath(version:{version:String, tag:String}, variant:{variant:String, suffix:String}):String {
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
					NEKO_VERSION: "2.1.0",
					HEADER: HEADER,
				};
				var path = dockerfilePath(version, variant);
				FileSystem.createDirectory(Path.directory(path));
				File.saveContent(path, tmpl.execute(vars));
			}
		}
	}
}
