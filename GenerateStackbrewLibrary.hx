import Update.*;
import sys.io.*;
import haxe.io.*;
using StringTools;

class GenerateStackbrewLibrary {
	static var HEADER =
'#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "haxe generate-stackbrew-library.hxml"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#';

	static public function verAliases(version:String, suffix:Array<String>):Array<String> {
		var versions = [
			for (v in [version , verMajorMinorPatch(version), verMajorMinor(version)])
			v => v
		];
		var versions = [
			for (v in versions)
			for (s in suffix)
			s == "" ? v : v + "-" + s
		];
		versions.sort(function(v1, v2) return v2.length - v1.length);
		return versions;
	}

	static public function fileCommit(file:String):String {
		var p = new Process("git", ["log", "-1", "--format=%H", "HEAD", "--", file]);
		var commit = p.stdout.readAll().toString().trim();
		if (p.exitCode() != 0)
			throw p.stderr.readAll().toString().trim();
		p.close();
		return commit;
	}

	static function main():Void {
		var stackbrew = new StringBuf();
		stackbrew.add("Maintainers: Andy Li <andy@onthewings.net> (@andyli)\n");
		stackbrew.add("GitRepo: https://github.com/HaxeFoundation/docker-library-haxe.git\n");
		stackbrew.add("\n");
		for (version in versions)
		for (variant in variants)
		if (version.exclude.indexOf(variant.variant) < 0)
		{
			var aliases = verAliases(version.version, variant.suffix);
			if (variant.suffix.indexOf("") >= 0 && version == versions[0]) {
				aliases.push("latest");
			}
			var commit = fileCommit(dockerfilePath(version, variant));
			stackbrew.add('Tags: ${aliases.join(", ")}\n');
			var architectures = switch (variant.variant) {
				case "windowsservercore-1803"|"windowsservercore-ltsc2016"|"nanoserver":
					["windows-amd64"];
				case "buster"|"stretch":
					["amd64", "arm32v7", "arm64v8"];
				case v if (StringTools.startsWith(v, "alpine")):
					["amd64", "arm64v8"];
				case _:
					["amd64"];
			}
			stackbrew.add('Architectures: ${architectures.join(", ")}\n');
			stackbrew.add('GitCommit: ${commit}\n');
			var dir = Path.directory(dockerfilePath(version, variant));
			stackbrew.add('Directory: ${dir}\n');
			switch (variant.variant) {
				case "windowsservercore-1803"|"windowsservercore-ltsc2016"|"nanoserver":
					stackbrew.add('Constraints: ${variant.variant}\n');
				case _:
					//pass
			}
			stackbrew.add("\n");
		}
		File.saveContent("haxe", stackbrew.toString());
	}
}
