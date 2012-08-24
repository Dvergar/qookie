package sookie.net;

// import sookie.net.SocketEvent;

#if flash
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;

class Socket extends nme.events.EventDispatcher {
    private var socket:flash.net.Socket;
    public var bytesAvailable(getBytesAvailable, never): Int;
    
    public function new() {
        super();
        var sEvt = new SocketEvent("onConnect");
        dispatchEvent(sEvt);
        this.socket = new flash.net.Socket();
        socket.addEventListener(Event.CONNECT, onConnect);
        socket.addEventListener(ProgressEvent.SOCKET_DATA, onData); 
        socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError);
        socket.addEventListener(Event.CLOSE, onClose);
        socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
        socket.endian = flash.utils.Endian.BIG_ENDIAN;
    }
    
    public function connect(ip:String, port:Int) {
        this.socket.connect(ip, port);
    }
    
    public function flush() {
        socket.flush();
    }
    
    private function getBytesAvailable():Int {
        return socket.bytesAvailable;
    }
    
    private function onConnect(event:Event) {
        trace("Flash > connected");
        var sEvt = new SocketEvent("onConnect");
        dispatchEvent(sEvt);
    }

    private function onClose(event:Event) {
        trace("Flash > disconnected");
        var sEvt = new SocketEvent("onClose");
        dispatchEvent(sEvt);
    }

    private function onError(event:Event) {
        trace("Flash > socket error");
        var sEvt = new SocketEvent("onError");
        dispatchEvent(sEvt);
    }

    private function onSecError(event:Event) {
        trace("Flash > socket security error");
    }

    private function onData(event:ProgressEvent) {
        // trace("Flash > Data");
        var sEvt = new SocketEvent("onData");
        dispatchEvent(sEvt);
    }
    
    public function readBoolean():Bool {
        return socket.readBoolean();
    }

    public function readByte():Int {
        return socket.readByte();
    }    
    
    public function readInt():Int {
        return socket.readInt();
    }
    
    public function readShort():Int {
        return socket.readShort();
    }

    public function readUnsignedByte():Int {
        return socket.readUnsignedByte();
    }  
    
    public function update() {}
    
    public function writeBoolean(c:Bool) {
        socket.writeBoolean(c);
    }
    
    public function writeByte(c:Int) {
        socket.writeByte(c);
    }
    
    public function writeShort(x:Int) {
        socket.writeShort(x);
    }
}

#elseif js
import sookie.tools.TypedArray;

class Socket extends nme.events.EventDispatcher {
    private var socket:WebSocket;
    private var buf:ArrayBuffer;
    private var output:DataView;
    private var input:DataView;
    private var dataLength:Int;
    private var dataPos:Int;
    private var bytesLeft:Int;
    public var bytesAvailable(getBytesAvailable, never): Int;

    public function new() {
        super();
        this.buf = new ArrayBuffer(4242);
        this.output = new DataView(this.buf);
        this.dataLength = 0;
    }

    public function connect(ip:String, port:Int) {
        this.socket = new WebSocket("ws://" + ip + ":" + Std.string(port + 1));
        this.socket.binaryType = "arraybuffer";
        socket.onopen = function (event:Dynamic):Void {
            trace("websocket opened...");
            var sEvt = new SocketEvent("onConnect");
            dispatchEvent(sEvt);
        }

        socket.onerror = function (event:Dynamic):Void {
            trace("websocket erred... " + event.data);   
            var sEvt = new SocketEvent("onError");
            dispatchEvent(sEvt);
        }

        socket.onmessage = function (event:Dynamic):Void {
            // trace("websocket recieving message...");
            // trace("message: " + event.data);
            // this.input.writeByte(event.data);
            this.input = new DataView(event.data);
            this.bytesLeft = this.input.byteLength;
            this.dataPos = 0;
            var sEvt = new SocketEvent("onData");
            dispatchEvent(sEvt);
        }

        socket.onclose = function (event:Dynamic):Void {
            trace("websocket closed.");
            var sEvt = new SocketEvent("onClose");
            dispatchEvent(sEvt);
        }
    }

    public function flush() {
        var arr = new Uint8Array(this.buf);
        var part = arr.subarray(0, this.dataLength);
        var newBuf = new Uint8Array(part).buffer;
        // var newBuf = new Uint8Array(part);
        this.socket.send(newBuf);
        // Reset
        this.dataLength = 0;
        this.buf = new ArrayBuffer(4242);
        this.output = new DataView(this.buf);
    }
    
    public function getBytesAvailable():Int {
        return this.bytesLeft;
    }

    public function readBoolean():Bool {
        this.bytesLeft -= 1;
        var data = this.input.getInt8(this.dataPos);
        this.dataPos += 1;
        return data;
    }

    public function readByte():Int {
        this.bytesLeft -= 1;
        var data = this.input.getInt8(this.dataPos);
        this.dataPos += 1;
        return data;
    }
    
    public function readInt():Int {
        this.bytesLeft -= 4;
        var data = this.input.getInt32(this.dataPos);
        this.dataPos += 4;
        return data;
    }

    public function readShort():Int {
        this.bytesLeft -= 2;
        var data = this.input.getInt16(this.dataPos);
        this.dataPos += 2;
        return data;
    }

    public function readUnsignedByte():Int {
        this.bytesLeft -= 1;
        var data = this.input.getUint8(this.dataPos);
        this.dataPos += 1;
        return data;
    } 
    
    public function update() {}

    public function writeBoolean(c:Bool) {
        this.output.setInt8(this.dataLength, c);
        this.dataLength += 1;
    }

    public function writeByte(c:Int) {
        this.output.setInt8(this.dataLength, c);
        this.dataLength += 1;
    }

    public function writeShort(x:Int) {
        this.output.setInt16(this.dataLength, x);
        this.dataLength += 2;
    }
}

#elseif (cpp||neko)
import nme.display.Sprite;

class Socket extends nme.events.EventDispatcher {
    private var socket:sys.net.Socket;
    private var myTimer:haxe.Timer;
    private var output:nme.utils.ByteArray;
    private var input:nme.utils.ByteArray;
    private var connected:Bool;
    public var bytesAvailable(getBytesAvailable, never): Int;

    public function new() {
        super();
        this.input = new nme.utils.ByteArray();
        this.output = new nme.utils.ByteArray();
        this.output.endian = nme.utils.Endian.BIG_ENDIAN; 
        this.socket = new sys.net.Socket();
        this.socket.output.bigEndian = true;
        this.socket.input.bigEndian = true;
        this.connected = false;
        // this.socket.setBlocking(false);
    }

    private function checkDatas() {
        var dataReceived = false;
        while(true) {
            var sockets = sys.net.Socket.select([this.socket], null, null, 0);
            if(sockets.read.length > 0) {
                try {
                    this.input.writeByte(socket.input.readByte());
                    dataReceived = true;
                }
                catch(e:Dynamic) {
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
            var sEvt = new SocketEvent("onData");
            dispatchEvent(sEvt);
        }
    }
    
    public function connect(ip:String, port:Int) {
        var host = new sys.net.Host(ip);
        try {
            this.socket.connect(host, port);
            var sEvt = new SocketEvent("onConnect");
            dispatchEvent(sEvt);
            this.connected = true;
            
            // this.myTimer = new haxe.Timer(1 / 10 * 1000);
            // this.myTimer.run = this.checkDatas;
        }
        catch(e:Dynamic) {
            trace("error >" + e);
            var sEvt = new SocketEvent("onError");
            dispatchEvent(sEvt);
        }
    }
    
    public function flush() {
        this.socket.write(this.output.toString());
        this.socket.output.flush();
        this.output = new nme.utils.ByteArray();
    }
    
    public function getBytesAvailable():Int {
        return this.input.bytesAvailable;
    }
    
    public function readBoolean():Bool {
        return this.input.readBoolean();
    }

    public function readByte():Int {
        return this.input.readByte();
    }

    public function readInt():Int {
        return this.input.readInt();
    }
    
    public function readShort():Int {
        return this.input.readShort();
    }
    
    public function readUnsignedByte():Int {
        return this.input.readUnsignedByte();
    }

    public function update() {
        if(this.connected) {
            this.checkDatas();
        }
    }
    
    public function writeBoolean(c:Bool) {
        this.output.writeBoolean(c);
    }
    
    public function writeByte(c:Int) {
        this.output.writeByte(c);
    }
    
    public function writeShort(x:Int) {
        this.output.writeShort(x);
    }
}
#end
