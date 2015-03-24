# Qookie

*Note: OpenFL now seems to support the net package, so you should probably just use that :)*

Qookie is a socket abstraction for OpenFL in order to reflect the same behaviour as the flash socket library.

It's been unit-tested for android, cpp, neko, flash & html5 targets for basic write/read methods.

## Instructions

Import

    import qookie.net.Socket
    
get the socket

    var socket = new Socket();
        
add events

    socket.addEventListener(SocketEvent.CONNECT, onConnect);
    socket.addEventListener(SocketEvent.CLOSE, onClose);
    socket.addEventListener(SocketEvent.IO_ERROR, onError);
    socket.addEventListener(SocketEvent.SOCKET_DATA, onData);
    
connect

    socket.connect("127.0.0.1", 4999);
    
write to it

    socket.writeByte(99);
    
flush the datas

    socket.flush();

**Note :** *`flush` is generally unreliable because it depends on your system and in the case of haxe the target, so i'm enforcing its use here, every writeX method will actually buffer the data and `flush` will push it to the socket.*

**Note2 :** *Error handling is really basic and not mimicing flash at the moment*.

Not implemented yet : `writeBytes`, `readBytes`, `writeObject`, `readObject`, `timeout`, `bytesPending`, `objectEncoding`
