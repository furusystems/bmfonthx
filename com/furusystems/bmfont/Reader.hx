package com.furusystems.bmfont;
import haxe.ds.Vector.Vector;
import haxe.io.BytesInput;

/**
 * ...
 * @author Andreas Rønning
 */
class Reader
{
	static var currentFont:FontDef = null;
	public static function read(input:BytesInput):FontDef {
		currentFont = new FontDef();
		
		input.position = 0;
		if (input.readByte() != 66 || input.readByte() != 77 || input.readByte() != 70 || input.readByte() != 3) throw "Invalid bmfont file";
		while (readBlock(input)) { }
		
		var out = currentFont;
		currentFont = null;
		return out;
	}
	
	static function readBlock(input:BytesInput):Bool {
		if (input.position == input.length) return false;
		var id = input.readByte();
		switch(id) {
			case 1:
				readInfo(input, input.readInt32());
			case 2:
				readCommon(input, input.readInt32());
			case 3:
				readPages(input, input.readInt32());
			case 4:
				readChars(input, input.readInt32());
			case 5:
				readKerningPairs(input, input.readInt32());
			default:
				return false;
		}
		return true;
	}
	
	static function readKerningPairs(input:BytesInput, blockSize:Int) 
	{
		var pairBytes = input.read(blockSize);
		var reader = new BytesInput(pairBytes);
		while (reader.position < reader.length) {
			readPair(reader);
		}
	}
	
	static function readPair(reader:BytesInput) 
	{
		var first = reader.readUInt16();
		var second = reader.readUInt16();
		var amount = reader.readInt8();
		var firstChar = currentFont.charMap[first];
		var secondChar = currentFont.charMap[second];
		//The idea here is that during rendering, the second character of a pair to be drawn will offset its position backwards by the kerning value
		if (firstChar != null && secondChar != null) secondChar.kerningPairs[first] = amount;
	}
	
	static function readChars(input:BytesInput, blockSize:Int) 
	{
		currentFont.charMap = new Vector<CharacterDef>(256);
		var charBytes = input.read(blockSize);
		var reader = new BytesInput(charBytes);
		while (reader.position < reader.length) {
			readChar(reader);
		}
	}
	static function readChar(input:BytesInput) {
		var char = new CharacterDef();
		char.id = input.readUInt24();
		
		char.x = input.readUInt16();
		char.y = input.readUInt16();
		char.width = input.readUInt16();
		char.height = input.readUInt16();
		char.xOffset = input.readInt8();
		char.yOffset = input.readInt8();
		char.xAdvance = input.readInt8();
		
		char.page = input.readByte();
		char.channel = input.readByte();
		currentFont.charMap[char.id] = char;
	}
	
	static inline function readZeroTerminatedString(input:BytesInput):String {
		var out:String = "";
		var byte:Int = 0;
		while ((byte = input.readByte()) != 0) out += String.fromCharCode(byte); 
		return out;
	}
	
	static function readPages(input:BytesInput, blockSize:Int) 
	{
		var block = input.read(blockSize);
		var reader = new BytesInput(block);
		var idx = 0;
		currentFont.pageFileNames = new Array<String>();
		while (reader.position < reader.length) {
			currentFont.pageFileNames[idx++] = readZeroTerminatedString(reader);
		}
	}
	
	static function readCommon(input:BytesInput, blockSize:Int) {
		
		currentFont.lineHeight = input.readUInt16();
		currentFont.base = input.readUInt16();
		currentFont.texWidth = input.readUInt16();
		currentFont.texHeight = input.readUInt16();
		currentFont.pageCount = input.readUInt16();
		var bits = input.readByte();
		
		//currentFont.packed = bits & 7 //read bit 7 for packed, still not sure what "bit 7" means since 
		currentFont.alphaChannel = input.readByte();
		currentFont.redChannel = input.readByte();
		currentFont.greenChannel = input.readByte();
		currentFont.blueChannel = input.readByte();
	}
	
	static function readInfo(input:BytesInput, blockSize:Int) 
	{
		var start = input.position;
		var end = input.position + blockSize;
		var pre:Int = input.position;
		currentFont.size = input.readInt16();
		
		var bits = input.readByte();
		//TODO: Why isn't this working right?
		currentFont.smooth = bits & 1 > 0;
		currentFont.unicode = bits & 2 > 0;
		currentFont.italic = bits & 4 > 0;
		currentFont.bold = bits & 8 > 0;
		currentFont.fixedHeight = bits & 16 > 0;
		//
		currentFont.charSet = input.readByte();
		currentFont.stretchH = input.readUInt16();
		currentFont.aa = input.readByte();
		currentFont.paddingUp = input.readByte();
		currentFont.paddingRight = input.readByte();
		currentFont.paddingDown = input.readByte();
		currentFont.paddingLeft = input.readByte();
		currentFont.spacingHorizontal = input.readByte();
		currentFont.spacingVertical = input.readByte();
		currentFont.outline = input.readByte();
		
		currentFont.name = readZeroTerminatedString(input);
	}
	
}