package com.furusystems.bmfont;
import haxe.ds.Vector.Vector;

/**
 * ...
 * @author Andreas Rønning
 */
class FontDef
{
	
	public var name:String;
	public var size:Int;
	public var pageFileNames:Array<String>;
	
	public var smooth:Bool;
	public var unicode:Bool;
	public var italic:Bool;
	public var bold:Bool;
	public var fixedHeight:Bool;
	public var charSet:Int;
	public var stretchH:Int;
	public var aa:Int;
	public var paddingUp:Int;
	public var paddingRight:Int;
	public var paddingDown:Int;
	public var paddingLeft:Int;
	public var spacingHorizontal:Int;
	public var spacingVertical:Int;
	public var outline:Int;
	public var lineHeight:Int;
	public var base:Int;
	public var texWidth:Int;
	public var texHeight:Int;
	public var pageCount:Int;
	public var alphaChannel:Int;
	public var redChannel:Int;
	public var greenChannel:Int;
	public var blueChannel:Int;
	public var charMap:Vector<CharacterDef>;

	public function new() 
	{
		
	}
	
	public function toString():String 
	{
		return "[FontDef name=" + name + " size=" + size + " textures=" + pageFileNames +"]";
	}
}