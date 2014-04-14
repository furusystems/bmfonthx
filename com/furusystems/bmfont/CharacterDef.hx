package com.furusystems.bmfont;

/**
 * ...
 * @author Andreas Rønning
 */
class CharacterDef {
	public var id:UInt;
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	public var xOffset:Int;
	public var yOffset:Int;
	public var xAdvance:Int;
	public var page:Int;
	public var channel:Int;
	public var kerningPairs:Array<Int>;
	public function new() {
		kerningPairs = [];
	}
}