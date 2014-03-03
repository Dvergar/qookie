package qookie.net;

import qookie.net.ISocket;
import flash.utils.ByteArray;
import flash.utils.Endian;
import haxe.io.Bytes;
import flash.Lib;
import flash.events.Event;

#if flash
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;


class Socket extends flash.events.EventDispatcher implements ISocket
{
    private var socket:flash.net.Socket;
    private var output:flash.utils.ByteArray;
    public static var endianness:String = "bigEndian";
    public var bytesAvailable(get, null):Int;
    public var endian(get, set):String;
    public var connected(get, null):Bool;
    
    public function new()
    {
        super();

        var sEvt = new SocketEvent("onConnect");
        dispatchEvent(sEvt);
        this.output = new flash.utils.ByteArray();
        this.socket = new flash.net.Socket();
        
        socket.addEventListener(Event.CONNECT, onConnect);
        socket.addEventListener(ProgressEvent.SOCKET_DATA, onData); 
        socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError);
        socket.addEventListener(Event.CLOSE, onClose);
        socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
    }
    
    private function get_connected():Bool
    {
        return socket.connected;
    }

    private function get_endian():String
    {
        return endianness;
    }

    // Seems like on the flash target Endian is an enum as defined by Haxe
    // but openFL also have Endian as a class with string fields but not used for flash.
    private function set_endian(value:String):String
    {
        endianness = value;
        socket.endian = value == "bigEndian" ? Endian.BIG_ENDIAN : Endian.LITTLE_ENDIAN;
        output.endian = value == "bigEndian" ? Endian.BIG_ENDIAN : Endian.LITTLE_ENDIAN;
        return value;
    }

    public function connect(ip:String, port:Int)
    {
        socket.connect(ip, port);
    }
    
    public function flush()
    {
        socket.writeBytes(output);
        socket.flush();
        output.clear();
    }
    
    private function get_bytesAvailable():Int
    {
        return socket.bytesAvailable;
    }
    
    private function onConnect(event:Event)
    {
        trace("Flash > connected");
        var sEvt = new SocketEvent("onConnect");
        dispatchEvent(sEvt);
    }

    private function onClose(event:Event)
    {
        trace("Flash > disconnected");
        var sEvt = new SocketEvent("onClose");
        dispatchEvent(sEvt);
    }

    private function onError(event:Event)
    {
        trace("Flash > socket error");
        var sEvt = new SocketEvent("onError");
        dispatchEvent(sEvt);
    }

    private function onSecError(event:Event)
    {
        trace("Flash > socket security error");
    }

    private function onData(event:ProgressEvent)
    {
        // trace("Flash > Data");
        var sEvt = new SocketEvent("onData");
        dispatchEvent(sEvt);
    }
    
    public function readBoolean():Bool {return socket.readBoolean(); }

    public function readByte():Int {return socket.readByte();}

    public function readDouble():Float {return socket.readDouble(); }

    public function readFloat():Float {return socket.readFloat(); }
    
    public function readInt():Int {return socket.readInt(); }
    
    public function readShort():Int {return socket.readShort(); }

    public function readUnsignedByte():Int {return socket.readUnsignedByte(); }

    public function readUnsignedInt() {return socket.readUnsignedInt(); }

    public function readUnsignedShort():Int {return socket.readUnsignedShort(); }

    public function readUTF():String {return socket.readUTF(); }

    public function readUTFBytes(length:Int):String {return socket.readUTFBytes(length); }
    
    public function readBytes(data:ByteArray, ?offset:Int, ?length:Int):Void
    {
        return socket.readBytes(data, offset, length);
    }

    public function writeBytes(bytes:ByteArray, ?offset:Int, ?length:Int):Void
    {
        return output.writeBytes(bytes, offset, length);
    }

    public function update() {}
    
    public function writeBoolean(c:Bool) {output.writeBoolean(c); }
    
    public function writeByte(c:Int) {output.writeByte(c); }

    public function writeDouble(c:Float) {output.writeDouble(c); }

    public function writeFloat(c:Float) {output.writeFloat(c); }

    public function writeInt(c:Int) {output.writeInt(c); }

    public function writeUnsignedInt(c:Int) {output.writeUnsignedInt(c); }
    
    public function writeShort(x:Int) {output.writeShort(x); }

    public function writeUTF(s:String) {output.writeUTF(s); }

    public function writeUTFBytes(s:String) {output.writeUTFBytes(s); }
}

#elseif js
import qookie.tools.TypedArray;
// import browser.Html5Dom.Dataview;
// import browser.errors.IOError;

class Socket extends flash.events.EventDispatcher implements ISocket
{
    private var socket:WebSocket;
    private var output:flash.utils.ByteArray;
    private var input:flash.utils.ByteArray;
    private var dataLength:Int;
    private var dataPos:Int;
    private var bytesLeft:Int;
    private var isConnected:Bool = false;
    public static var endianness:String = "bigEndian";
    public var bytesAvailable(get, null):Int;
    public var endian(get, set):String;
    public var connected(get, null):Bool;

    public function new()
    {
        super();
        this.input = new flash.utils.ByteArray();
        this.output = new flash.utils.ByteArray();
    }

    private function get_connected():Bool
    {
        return isConnected;
    }

    private function get_endian():String
    {
        return endianness;
    }

    private function set_endian(value:String):String
    {
        endianness = value;
        output.endian = value == "bigEndian" ? Endian.BIG_ENDIAN : Endian.LITTLE_ENDIAN;
        return value;
    }

    public function connect(ip:String, port:Int)
    {
        this.socket = new WebSocket("ws://" + ip + ":" + Std.string(port + 1));
        trace("connection on > ws://" + ip + ":" + Std.string(port + 1));
        this.socket.binaryType = "arraybuffer";
        socket.onopen = function (event:Dynamic):Void {
            isConnected = true;
            trace("websocket opened...");
            var sEvt = new SocketEvent("onConnect");
            dispatchEvent(sEvt);
        }

        socket.onerror = function (event:Dynamic):Void {
            trace("websocket erred... " + event.data);   
            var sEvt = new SocketEvent("onError");
            dispatchEvent(sEvt);
        }

        socket.onmessage = function(event:Dynamic):Void
        {
            var ab:ArrayBuffer = event.data;
            if(ab.byteLength > 0) {
                input = new flash.utils.ByteArray();
                var d:DataView = new DataView(ab);

                for(i in 0...ab.byteLength)
                {
                    input.writeByte(d.getUint8(i));
                }
                input.position = 0;
            }
            var sEvt = new SocketEvent("onData");
            dispatchEvent(sEvt);
        }

        socket.onclose = function (event:Dynamic):Void
        {
            isConnected = false;
            trace("websocket closed.");
            var sEvt = new SocketEvent("onClose");
            dispatchEvent(sEvt);
        }
    }

    public function flush()
    {
        if(output.length > 0) {
            trace("BOOM");

            output.position = 0;
            // trace("output length " + output.length);
            // var value = output.readByte();
            // trace("value " + value);

            var ba:Dynamic = new Uint8Array(output.length);

            for(i in 0...output.length)
            {
                ba[i] = output.readByte();
            }

            socket.send(ba.buffer);
            this.output = new flash.utils.ByteArray();
        }
    }
    
    public function get_bytesAvailable():Int {return input.bytesAvailable; }
    
    public function readBoolean():Bool {return input.readBoolean(); }

    public function readDouble():Float {return input.readDouble(); }

    public function readByte():Int
    {
        var b = input.readByte();
        if(b >= 128) {b = -256 + b;}  // Biiiiit it !
        return b;
    }

    public function readFloat():Float {return input.readFloat(); }

    public function readInt():Int {return input.readInt(); }
    
    public function readShort():Int {return input.readShort(); }
    
    public function readUnsignedByte():Int {return input.readUnsignedByte(); }

    public function readUnsignedInt():Int {return input.readUnsignedInt(); }

    public function readUnsignedShort():Int {return input.readUnsignedShort(); }

    public function readUTF():String {return input.readUTF(); }

    public function readUTFBytes(length:Int):String
    {
        throw("not supported yet for html target :(");
        return input.readUTFBytes(length);
    }

    public function readBytes(data:ByteArray, ?offset:Int, ?length:Int):Void
    {
        return input.readBytes(data, offset, length);
    }

    public function writeBytes(bytes:ByteArray, ?offset:Int, ?length:Int):Void
    {
        return output.writeBytes(bytes, offset, length);
    }

    public function update() {}
    
    public function writeBoolean(c:Bool) {output.writeBoolean(c); }
    
    public function writeByte(c:Int) {output.writeByte(c); }

    public function writeDouble(c:Float) {output.writeDouble(c); }

    public function writeFloat(c:Float) {output.writeFloat(c); }

    public function writeInt(c:Int) {output.writeInt(c); }

    public function writeUnsignedInt(c:Int) {output.writeUnsignedInt(c); }

    public function writeShort(x:Int) {output.writeShort(x); }

    public function writeUTF(s:String) {output.writeUTF(s); }

    public function writeUTFBytes(s:String) {output.writeUTFBytes(s); }
}


#elseif (cpp||neko||java)

class Socket extends flash.events.EventDispatcher implements ISocket
{
    private var socket:sys.net.Socket;
    private var myTimer:haxe.Timer;
    private var output:flash.utils.ByteArray;
    private var input:flash.utils.ByteArray;
    private var isConnected:Bool = false;
    public static var endianness:String = "bigEndian";
    public var bytesAvailable(get, null):Int;
    public var endian(get, set):String;
    public var connected(get, null):Bool;

    public function new() {
        super();
        input = new flash.utils.ByteArray();
        output = new flash.utils.ByteArray();
        this.socket = new sys.net.Socket();

        Lib.current.stage.addEventListener(Event.ENTER_FRAME, update);
    }

    private function get_connected():Bool
    {
        return isConnected;
    }

    private function get_endian():String
    {
        return endianness;
    }

    private function set_endian(value:String):String
    {
        endianness = value;
        socket.input.bigEndian = value == "bigEndian" ? true : false;
        socket.output.bigEndian = value == "bigEndian" ? true : false;
        input.endian = value == "bigEndian" ? Endian.BIG_ENDIAN : Endian.LITTLE_ENDIAN;
        output.endian = value == "bigEndian" ? Endian.BIG_ENDIAN : Endian.LITTLE_ENDIAN;
        return value;
    }

    private function checkDatas()
    {
        var dataReceived = false;
        while(true)
        {
            var sockets = sys.net.Socket.select([this.socket], null, null, 0);
            if(sockets.read.length > 0)
            {
                try
                {
                    var tmp = socket.input.readByte();
                    input.writeByte(tmp);

                    dataReceived = true;
                }
                catch(e:Dynamic)
                {
                    trace("error2 > " + e);
                    var sEvt = new SocketEvent("onClose");
                    dispatchEvent(sEvt);
                    this.myTimer.stop();
                    this.socket.close();
                }
            }
            else {
                break;
            }
        }

        if(dataReceived) {
            input.position = 0;
            var sEvt = new SocketEvent("onData");
            dispatchEvent(sEvt);
            input.clear();
        }
    }

    public function connect(ip:String, port:Int)
    {
        var host = new sys.net.Host(ip);
        try
        {
            this.socket.connect(host, port);
            var sEvt = new SocketEvent("onConnect");
            dispatchEvent(sEvt);
            this.isConnected = true;
            // this.myTimer = new haxe.Timer(1 / 10 * 1000);
            // this.myTimer.run = this.checkDatas;
        }
        catch(e:Dynamic)
        {
            trace("error >" + e);
            var sEvt = new SocketEvent("onError");
            dispatchEvent(sEvt);
        }
    }
    
    public function flush()
    {
        this.socket.output.write(output);
        this.socket.output.flush();
        output = new flash.utils.ByteArray();
    }
    
    public function get_bytesAvailable():Int
    {
        return input.bytesAvailable;
    }
    
    public function readBoolean():Bool {return input.readBoolean(); }

    public function readDouble():Float {return input.readDouble(); }

    public function readByte():Int {return input.readByte(); }

    public function readFloat():Float {return input.readFloat(); }

    public function readInt():Int {return input.readInt(); }
    
    public function readShort():Int {return input.readShort(); }
    
    public function readUnsignedByte():Int {return input.readUnsignedByte(); }

    public function readUnsignedInt():Int {return input.readUnsignedInt(); }

    public function readUnsignedShort():Int {return input.readUnsignedShort(); }

    public function readUTF():String {return input.readUTF(); }

    public function readUTFBytes(length:Int):String {
        return input.readUTFBytes(length); }

    public function update(event:Event)
    {
        if(this.connected)
        {
            this.checkDatas();
        }
    }
    
    public function readBytes(data:ByteArray, ?offset:Int, ?length:Int):Void
    {
        return input.readBytes(data, offset, length);
    }

    public function writeBytes(bytes:ByteArray, ?offset:Int, ?length:Int):Void
    {
        return output.writeBytes(bytes, offset, length);
    }

    public function writeBoolean(c:Bool) {output.writeBoolean(c); }
    
    public function writeByte(c:Int) {output.writeByte(c); }

    public function writeDouble(c:Float) {output.writeDouble(c); }

    public function writeFloat(c:Float) {output.writeFloat(c); }
    
    public function writeInt(c:Int) {output.writeInt(c); }

    public function writeShort(x:Int) {output.writeShort(x); }

    public function writeUnsignedInt(x:Int) {output.writeUnsignedInt(x); }

    public function writeUTF(s:String) {output.writeUTF(s); }

    public function writeUTFBytes(s:String) {output.writeUTFBytes(s); }
}
#end
