package com.furusystems.bmfont;
import haxe.ds.Vector.Vector;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import sys.io.FileInput;

/**
 * ...
 * @author Andreas Rønning
 */
enum ReadStatus {
	COMPLETE;
	PROGRESS;
	ERROR;
}
class Reader
{
	static var bytes:Bytes;
	static var currentFont:FontDef = null;
	public static function read(bytes:Bytes):FontDef {
		
		Reader.bytes = bytes;
		var input = new BytesInput(bytes);
		currentFont = new FontDef();
		
		input.position = 0;
		if (input.readByte() != 66 || input.readByte() != 77 || input.readByte() != 70) throw "Invalid bmfont file";
		if (input.readByte() != 3) throw "Invalid bmfont file version";
		while (readBlock(input) == PROGRESS) { }
		
		var out = currentFont;
		currentFont = null;
		Reader.bytes = null;
		return out;
	}
	
	static function readBlock(input:BytesInput):ReadStatus {
		if (input.position == input.length) return COMPLETE;
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
				return ERROR;
		}
		return PROGRESS;
	}
	
	static function readKerningPairs(input:BytesInput, blockSize:Int) 
	{
		
		var target = input.position + blockSize;
		while (input.position < target) {
			readPair(input);
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
		var target = input.position + blockSize;
		currentFont.charMap = new Vector<CharacterDef>(256);
		var numChars = blockSize / 20;
		var charIdx = 0;
		while (charIdx++<numChars) {
			readChar(input);
		}
	}
	
	static public function readUnsignedInt(input:BytesInput):Int 
	{
		var ch1 = input.readByte();
		var ch2 = input.readByte();
		var ch3 = input.readByte();
		var ch4 = input.readByte();

		return input.bigEndian ?(ch1 << 24) |(ch2 << 16) |(ch3 << 8) | ch4 : (ch4 << 24) |(ch3 << 16) |(ch2 << 8) | ch1;
	}
	
	static function readChar(input:BytesInput) {
		var char = new CharacterDef();
		char.id = readUnsignedInt(input);
		
		char.x = input.readUInt16();
		char.y = input.readUInt16();
		char.width = input.readUInt16();
		char.height = input.readUInt16();
		char.halfWidth = char.width >> 1;
		char.halfHeight = char.height >> 1;
		char.xOffset = input.readInt16();
		char.yOffset = input.readInt16();
		char.xAdvance = input.readInt16();
		
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
		var target = input.position + blockSize;
		var idx = 0;
		currentFont.pageFileNames = new Array<String>();
		while (input.position < target) {
			currentFont.pageFileNames[idx++] = readZeroTerminatedString(input);
		}
	}
	
	static function readCommon(input:BytesInput, blockSize:Int) {
		
		currentFont.lineHeight = input.readUInt16();
		currentFont.base = input.readUInt16();
		currentFont.texWidth = input.readUInt16();
		currentFont.texHeight = input.readUInt16();
		currentFont.pageCount = input.readUInt16();
		currentFont.packed = input.readByte() & 1 > 0; 
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
		currentFont.smooth = bits & 128 > 0; 
		currentFont.unicode = bits & 64 > 0; 
		currentFont.italic = bits & 32 > 0; 
		currentFont.bold = bits & 16 > 0; 
		currentFont.fixedHeight = bits & 8 > 0;
		
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