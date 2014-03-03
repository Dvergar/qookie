package qookie.net;

import flash.utils.ByteArray;
import haxe.io.Bytes;

interface ISocket
{
	public var endian (get, set):String;
	public var bytesAvailable (get, null):Int;
	
	public function readBoolean ():Bool;
	public function readByte ():Int;
	public function readBytes (data:ByteArray, ?offset:Int, ?length:Int):Void;
	public function readDouble ():Float;
	public function readFloat ():Float;
	public function readInt ():Int;
	public function readShort ():Int;
	public function readUnsignedByte ():Int;
	public function readUnsignedInt ():Int;
	public function readUnsignedShort ():Int;
	public function readUTF ():String;
	public function readUTFBytes (length:Int):String;

	public function writeBoolean (value:Bool):Void;
	public function writeByte (value:Int):Void;
	public function writeBytes (bytes:ByteArray, ?offset:Int, ?length:Int):Void;
	public function writeDouble (value:Float):Void;
	public function writeFloat (value:Float):Void;
	public function writeInt (value:Int):Void;
	public function writeShort (value:Int):Void;
	public function writeUnsignedInt (value:Int):Void;
	public function writeUTF (value:String):Void;
	public function writeUTFBytes (value:String):Void;

	// public var bytesPending(get, null):Int;
	public var connected(get, null):Bool;
	// public var localAddress(get, null):String;
	// public var localPort(get, null):Int;
	// public var objectEncoding(get, null):Int;
	// public var remoteAddress(get, null):String;
	// public var remotePort(get, null):Int;
	// public var timeout:Int;
}
