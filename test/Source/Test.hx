import openfl.Assets;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.ui.Keyboard;
import flash.net.Socket;
import flash.utils.ByteArray;
// import flash.events.ProgressEvent;
// import flash.events.IOErrorEvent;

import qookie.net.Socket;
import qookie.net.SocketEvent;


class Test extends Sprite
{
    private var socket:Socket;
    private var msglen:Int;
    
    public function new()
    {
        super();
        msglen = 0;

        socket = new Socket();
        socket.addEventListener(SocketEvent.CONNECT, onConnect);
        socket.addEventListener(SocketEvent.CLOSE, onClose);
        socket.addEventListener(SocketEvent.IO_ERROR, onError);
        socket.addEventListener(SocketEvent.SOCKET_DATA, onData);
        socket.connect("192.168.1.4", 32000);
        // socket.connect("127.0.0.1", 32000);
    }
    
    public inline static function assertEquals(a:Dynamic, b:Dynamic)
    {
        if(a != b)
        {
            throw "Test error : expected " + b + " got " + a;
        }
    }

    function round2(number:Float, precision:Int):Float
    {
        var num = number;
        num = num * Math.pow(10, precision);
        num = Math.round(num) / Math.pow(10, precision);
        return num;
    }

    private function onData(event:SocketEvent)
    {
    // private function onData(event:ProgressEvent) {

        while(socket.bytesAvailable > 0) {
            trace("Sookie > Data " + socket.bytesAvailable);
            if(msglen == 0) msglen = socket.readByte();
            trace("msglen " + msglen);
            if(socket.bytesAvailable != msglen) break;

            var bo = socket.readBoolean();
            var b = socket.readByte();
            var bb = socket.readUnsignedByte();
            var h = socket.readShort();
            var hh = socket.readUnsignedShort();
            var i = socket.readInt();
            var ii = socket.readUnsignedInt();
            var d = socket.readDouble();
            var f = round2(socket.readFloat(), 4);
            var s = socket.readUTF();
            var ss = socket.readUTFBytes(5);

            var ba = new ByteArray();
            socket.readBytes(ba);
            var b1 = ba.readByte();
            var b2 = ba.readByte();

            trace(bo);
            trace(b);
            trace(bb);
            trace(h);
            trace(hh);
            trace(i);
            trace(ii);
            trace(d);
            trace(f);
            trace(s);
            trace(ss);
            trace(b1 + " / " + b2);

            assertEquals(bo, true);
            assertEquals(b, -128);
            assertEquals(bb, 255);
            assertEquals(h, -32768);
            assertEquals(hh, 65535);
            // assertEquals(i, -2147483648);
            assertEquals(i, -1073741824);  // Neko
            // assertEquals(ii, 4294967295);
            assertEquals(ii, 1073741823);  // Neko
            assertEquals(d, 999999999999.2222);
            assertEquals(f, 5.4444);
            assertEquals(s, "hello");
            assertEquals(ss, "world");
            assertEquals(b1, 4);
            assertEquals(b2, 2);

            trace("send");
            socket.writeBoolean(bo);
            socket.writeByte(b);
            socket.writeByte(bb);
            socket.writeShort(h);
            socket.writeShort(hh);
            socket.writeInt(i);
            socket.writeUnsignedInt(ii);
            socket.writeDouble(d);
            socket.writeFloat(f);
            socket.writeUTF(s);
            socket.writeUTFBytes(ss);
            ba.position = 0;
            // socket.writeBytes(ba, 0, ba.length -1);
            socket.writeBytes(ba);
            // socket.writeByte(1);
            // socket.writeByte(2);
            socket.flush();

            msglen == 0;
        }
    }
    
    private function onConnect(event:SocketEvent) {
        trace("Sookie > Connection");
    }
    
    private function onClose(event:SocketEvent) {
        trace("Sookie > Close");
    }
    
    private function onError(event:SocketEvent) {
        trace("Sookie > Error");
    }
}
