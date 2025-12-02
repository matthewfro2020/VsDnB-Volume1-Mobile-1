import sys.FileSystem;
import sys.io.File;

class RenameNilFix {
	static final dirs = [
		"export/release/ios/obj/", "export/release/ios/obj/obj/", "export/release/ios/obj/obj/iphoneos/", "export/release/ios/obj/obj/iphoneos-arm64/",
		"export/release/ios/obj/include/thx/", "export/release/ios/obj/src/thx/", "export/release/mac/obj/include/thx/", "export/release/mac/obj/src/thx/",
		"export/cpp/obj/include/thx/", "export/cpp/obj/src/thx/", "export/mac/obj/include/thx/", "export/mac/obj/src/thx/" "export/release/ios/build/",
		"export/release/ios/build/Release-iphoneos/", "export/release/ios/build/VS*/", "export/release/ios/build/VS*/*/",
		"export/release/ios/build/*-iphoneos/", "export/release/ios/build/*-iphoneos/Objects-normal/arm64/"
	];

	public static function main() {
		for (dir in dirs) {
			if (!FileSystem.exists(dir))
				continue;

			for (file in FileSystem.readDirectory(dir)) {
				if (!StringTools.endsWith(file, ".h") && !StringTools.endsWith(file, ".cpp"))
					continue;

				var full = dir + file;
				patchFile(full);
			}
		}
	}

	static function patchFile(path:String) {
		var txt = File.getContent(path);

		// Replace class name
		txt = StringTools.replace(txt, "thx::Nil", "thx::ThxNil");
		txt = StringTools.replace(txt, "thx_Nil", "thx_ThxNil");
		txt = StringTools.replace(txt, "Nil_obj", "ThxNil_obj");

		// Replace standalone Nil keyword (avoid replacing Objective-C Nil)
		txt = ~/([^A-Za-z0-9_])Nil([^A-Za-z0-9_])/g.replace(txt, "$1ThxNil$2");

		// Fix file includes
		txt = StringTools.replace(txt, "Nil.h", "ThxNil.h");
		txt = StringTools.replace(txt, "Nil.cpp", "ThxNil.cpp");

		File.saveContent(path, txt);
	}
}
