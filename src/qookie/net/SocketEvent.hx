package qookie.net;

import flash.events.Event;
 
class SocketEvent extends Event {
    public static var CONNECT:String = "onConnect";
    public static var CLOSE:String = "onClose";
    public static var SOCKET_DATA:String = "onData";
    public static var IO_ERROR:String = "onError";
    public var customMessage:String;

    public function new(type:String, bubbles:Bool=false, cancelable:Bool=false) {
       super(type, bubbles, cancelable);
    }
}