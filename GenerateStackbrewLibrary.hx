import Update.*;
import sys.io.*;
import haxe.io.*;
using StringTools;
using Lambda;

typedef Entry = {
	tags:Array<String>,
	?sharedTags:Array<String>,
	architectures:Array<String>,
	gitCommit:String,
	directory:String,
	?constraints:Array<String>,
}

class GenerateStackbrewLibrary {
	static var HEADER =
'#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "haxe generate-stackbrew-library.hxml"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#';

	static public function isShared(suffix:String):Bool {
		return switch (suffix) {
			case "" | "windowsservercore": true;
			case _: false;
		}
	}

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

	static public function printEntry(e:Entry):String {
		var buf = new StringBuf();
		buf.add('Tags: ' + e.tags.join(", ") + "\n");
		if (e.sharedTags != null && e.sharedTags.length > 0)
			buf.add('SharedTags: ' + e.sharedTags.join(", ") + "\n");
		buf.add('Architectures: ' + e.architectures.join(", ") + "\n");
		buf.add('GitCommit: ' + e.gitCommit + "\n");
		buf.add('Directory: ' + e.directory + "\n");
		if (e.constraints != null && e.constraints.length > 0)
			buf.add('Constraints: ' + e.constraints.join(", ") + "\n");
		return buf.toString();
	}

	static function main():Void {
		var stackbrew = new StringBuf();
		stackbrew.add("Maintainers: Andy Li <andy@onthewings.net> (@andyli)\n");
		stackbrew.add("GitRepo: https://github.com/HaxeFoundation/docker-library-haxe.git\n");
		stackbrew.add("\n");

		var entries:Array<Entry> = [
			for (version in versions)
			for (variant in variants)
			if (version.exclude.indexOf(variant.variant) < 0)
			{
				tags: verAliases(version.version, variant.suffix.filter(function(s) return !isShared(s))),
				sharedTags: verAliases(version.version, variant.suffix.filter(isShared)),
				architectures: switch (variant.variant) {
					case "windowsservercore-1809"|"windowsservercore-ltsc2016"|"nanoserver":
						["windows-amd64"];
					case "bullseye"|"buster"|"stretch":
						["amd64", "arm32v7", "arm64v8"];
					case v if (StringTools.startsWith(v, "alpine")):
						["amd64", "arm64v8"];
					case _:
						["amd64"];
				},
				gitCommit: fileCommit(dockerfilePath(version, variant)),
				directory: Path.directory(dockerfilePath(version, variant)),
				constraints: switch (variant.variant) {
					case "windowsservercore-1809"|"windowsservercore-ltsc2016"|"nanoserver":
						[variant.variant];
					case _:
						[];
				},
			}
		];

		// add "latest" tags
		for (variant in variants)
		{
			switch (entries.find(e ->
				e.tags.contains('${versions[0].version}-${variant.variant}')
				&&
				e.sharedTags.contains(versions[0].version)
			)) {
				case null: //pass
				case e:
					e.sharedTags.push("latest");
			}
		}

		for (e in entries) {
			stackbrew.add(printEntry(e));
			stackbrew.add("\n");
		}

		File.saveContent("haxe", stackbrew.toString());
	}
}
