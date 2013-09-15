package qookie.tools;

@:native("ArrayBuffer") extern class ArrayBuffer {
    public function new(length:Int) : Void;
    public var byteLength : Int;
    public var IntLength (default,never) : Int;
}

extern interface ArrayBufferView {
    public var buffer (default,never) : ArrayBuffer;
    public var IntOffset (default,never) : Int;
    public var IntLength (default,never) : Int;
}

@:native("DataView") extern class DataView implements ArrayBufferView {
    public var buffer (default,never) : ArrayBuffer;
    public var IntOffset (default,never) : Int;
    public var IntLength (default,never) : Int;
    public var byteLength : Int;
    public function new(buffer:ArrayBuffer, ?IntOffset:Int, ?IntLength:Int) : Void;
      
    public function getInt8(IntOffset:Int) : Dynamic; // Because can also be Bool :/
    public function getUint8(IntOffset:Int) : Int;
    public function getInt16(IntOffset:Int, ?littleEndian:Bool) : Int;
    public function getUint16(IntOffset:Int, ?littleEndian:Bool) : Int;
    public function getInt32(IntOffset:Int, ?littleEndian:Bool) : Int;
    public function getUint32(IntOffset:Int, ?littleEndian:Bool) : Int;
    public function getFloat32(IntOffset:Int, ?littleEndian:Bool) : Float;
    public function getFloat64(IntOffset:Int, ?littleEndian:Bool) : Float;

    public function setInt8(IntOffset:Int, value:Dynamic, ?littleEndian:Bool) : Void;
    public function setUint8(IntOffset:Int, value:Int, ?littleEndian:Bool) : Void;
    public function setInt16(IntOffset:Int, value:Int, ?littleEndian:Bool) : Void;
    public function setUint16(IntOffset:Int, value:Int, ?littleEndian:Bool) : Void;
    public function setInt32(IntOffset:Int, value:Int, ?littleEndian:Bool) : Void;
    public function setUint32(IntOffset:Int, value:Int, ?littleEndian:Bool) : Void;
    public function setFloat32(IntOffset:Int, value:Float, ?littleEndian:Bool) : Void;
    public function setFloat64(IntOffset:Int, value:Float, ?littleEndian:Bool) : Void;
}

@:native("Uint8Array") extern class Uint8Array implements ArrayBufferView {
    public static var BYTES_PER_ELEMENT:Int;
	public var buffer(default,null):ArrayBuffer;
	public var IntOffset(default,null):Int;
    public var IntLength(default,null):Int;
	public var length(default,null):Int;
	function new(buffer:Dynamic, ?byteOffset:Int, ?length:Int):Void;
    
    public function subarray(begin:Int, end:Int):Uint8Array;
}