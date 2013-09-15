package qookie.net;

@:native("WebSocket") extern class WebSocket {
    function new(url:String):Void;
    var onmessage:Dynamic->Void;
    var onopen:Dynamic->Void;
    var onclose:Dynamic->Void;
    var onerror:Dynamic->Void;
    var binaryType:String;
    var byteLength:Int;
    function send(p:Dynamic):Void;
    function close(?code:Int, ?reason:String):Void;
}