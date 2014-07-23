bmfonthx
========

Haxe reader for the BMFont format (http://www.angelcode.com/products/bmfont/). Takes a Bytes or String source and spits out a FontDef.

Installation:  

	haxelib install bmfonthx

..or 

	haxelib git bmfonthx https://github.com/furusystems/bmfonthx.git

Basic usage:  

	//neko
    var font = Reader.read(File.read("myfont.fnt", true).readAll());  
    //lime & openfl
    var font = Reader.read(Assets.getBytes("assets/myfont.fnt"));  
  
FontDef has a pageFileNames array of textures (usually local relative path to where the .fnt file is situated) and a charMap vector of CharacterDefs that you can look up with charCodes, and that's about as specific as it gets. The rest is just data: Apply at your leisure.

Tested with OpenFL drawTiles and Lime OpenGL renderers. Works a treat.

Kerning pair support is a bit weird in that pairs are intended to be used as negative offsets. For instance, given the kerning pair 10,20, only 20 is given kerning info pertaining to 10. In this way, when drawing characters left-to-right, the "current" character can offset its position based on the preceding character, if it is paired. Still experimenting with that stuff.
