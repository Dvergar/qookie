import openfl.Assets;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.ui.Keyboard;

import qookie.net.Socket;
import qookie.net.SocketEvent;


class Rocket extends Sprite {
    private var image:Bitmap;
    private var netx:Float;
    private var nety:Float;

    public function new(x, y) {
        super();
        this.image = new Bitmap(Assets.getBitmapData("assets/rocket.png"));
        this.image.x = -this.image.width / 2;
        this.image.y = -this.image.height / 2;
        this.addChild(image);
        this.x = x;
        this.y = y;
        this.netx = this.x;
        this.nety = this.y;
        Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        trace("rocket pop at > " + this.x + ", " + this.y);
    }
    
    public function updatePosition(x, y):Void {
        this.netx = x;
        this.nety = y;
    }
    
    private function onEnterFrame(event:Event):Void {
        var dx = this.netx - this.x;
        var dy = this.nety - this.y;
        this.x += 0.3 * dx;
        this.y += 0.3 * dy;
    }
}


class Ship extends Sprite {
    private var image:Bitmap;
    private var netx:Float;
    private var nety:Float;
    private var blinkTimer:haxe.Timer;
    private var blinkCount:Int;

    public function new(id, x, y) {
        super();
        this.image = new Bitmap(Assets.getBitmapData("assets/ship.png"));
		this.image.x = -this.image.width / 2;
		this.image.y = -this.image.height / 2;
        this.image.alpha = 1;
        this.addChild(image);
        this.x = x;
        this.y = y;
        this.netx = this.x;
        this.nety = this.y;
        this.blinkCount = 0;
        this.rotation = 0;
        Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        trace("ship pop at > " + this.x + ", " + this.y);
    }
    
    public function updatePosition(x, y, rotation):Void {
        this.netx = x;
        this.nety = y;
        this.rotation = -rotation;
    }
    
    public function blink() {
        trace(blinkCount);
        if(this.blinkCount == 0) {
            this.blinkTimer = new haxe.Timer(50);
            this.blinkTimer.run = this.blinkLoop;
        }
    }

    private function blinkLoop() {
        if(blinkCount % 2 == 0) {
            this.image.alpha = 0.2;
        }
        else {
            this.image.alpha = 1;
        }

        blinkCount++;

        if(blinkCount >= 6) {
            this.blinkStop();
        }
    }

    private function blinkStop() {
        this.blinkTimer.stop();
        this.blinkCount = 0;
    }

    private function onEnterFrame(event:Event):Void {
        var dx = this.netx - this.x;
        var dy = this.nety - this.y;

        if(Math.abs(dx) < 300 && Math.abs(dy) < 300) {
            this.x += 0.3 * dx;
            this.y += 0.3 * dy;
        }
        else {
            this.x = this.netx;
            this.y = this.nety;
        }
    }
}


class LocalShip extends Ship {
    private static var SPEED = 0.14;
    private static var ROTATION_SPEED = 400;
    private var velocity:Array<Float>;
    private var frame:Int;
    private var trueX:Float;
    private var trueY:Float;

    public function new(x, y) {
        super(0, x, y);
        this.image.alpha = 1;
        this.velocity = [0, 0];
        this.frame = 0;
        this.trueX = x;
        this.trueY = y;
    }

    public function respawnPosition(x, y):Void {
        this.x = x;
        this.y = y;
        this.trueX = x;
        this.trueY = y;
        this.velocity = [0, 0];
        this.rotation = 0;
    }

    public function updatePosition2(left, right, up, down):Void {
        var a = [0.0, 0.0];
        var rotation_direction = 0;
        if(left) {
            rotation_direction = 1;
        }
        if(right) {
            rotation_direction = -1;
        }

        this.rotation -= ROTATION_SPEED * 1 / 60 * rotation_direction;

        if(up) {
            a[0] -= Math.sin(Math.PI / 180 * -this.rotation) * SPEED;
            a[1] -= Math.cos(Math.PI / 180 * -this.rotation) * SPEED;
        }
        if(down) {
            a[0] += Math.sin(Math.PI / 180 * -this.rotation) * SPEED;
            a[1] += Math.cos(Math.PI / 180 * -this.rotation) * SPEED;
        }

        this.velocity[0] += a[0];
        this.velocity[1] += a[1];

        this.trueX += this.velocity[0];
        this.trueY += this.velocity[1];

        if(this.trueX < 0) {
            this.trueX = 640;
        }
        else if(this.trueX > 640) {
            this.trueX = 0;
        }

        if(this.trueY < 0) {
            this.trueY = 480;
        }
        else if(this.trueY > 480) {
            this.trueY = 0;
        }

        this.x = this.trueX;
        this.y = this.trueY;

        // trace(Std.string(this.frame) + " | " +
        //         Std.string(a[0]) + ", " + Std.string(a[1]) + " || " +
        //         Std.string(this.x) + ", " + Std.string(this.y) + " || " +
        //         Std.string(this.trueX) + ", " + Std.string(this.trueY));
        this.frame ++;
    }

    override function onEnterFrame(event:Event):Void {


    }
}



class SampleGame extends Sprite {
    private static var CONNECTION = 0;
    private static var PLAYER_UPDATE = 1;
    private static var PLAYER_HIT = 5;
    private static var PLAYER_STATE = 6;
    private static var PLAYER_DESTROY = 7;
    private static var ROCKET_CREATE = 2;
    private static var ROCKET_UPDATE = 3;
    private static var ROCKET_DESTROY = 4;
    
    private var keyIsDown:Bool;
    private var keyLeftIsDown:Bool;
    private var keyRightIsDown:Bool;
    private var keyUpIsDown:Bool;
    private var keyDownIsDown:Bool;
    private var keyAttack:Bool;
    
    private var s:Socket;
    private var players:Map<Int, Ship>;
    private var rockets:Map<Int, Rocket>;
    private var myId:Int;
    private var myShip:Ship;
    private var localShip:LocalShip;
    private var gameIsRunning:Bool;
    private var attackTime:Float;
    private var lastTime:Float;
    private var lastNetTime:Float;
    
    public function new() {
        super();
        this.players = new Map();
        this.rockets = new Map();
        this.myId = -1;
        this.gameIsRunning = false;
        this.attackTime = Lib.getTimer();
        this.lastTime = Lib.getTimer();
        this.lastNetTime = Lib.getTimer();

        s = new Socket();
        s.addEventListener(SocketEvent.CONNECT, onConnect);
        s.addEventListener(SocketEvent.CLOSE, onClose);
        s.addEventListener(SocketEvent.IO_ERROR, onError);
        s.addEventListener(SocketEvent.SOCKET_DATA, onData);
        s.connect("127.0.0.1", 4999);

        Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }
    
    private function debugSend() {
        trace("debugSend");
        s.writeShort(5000);
        s.writeShort(20);
        s.flush();
    }
    
    private function onData(event:SocketEvent) {
        while(s.bytesAvailable > 0) {
            var msgType = s.readUnsignedByte();
            if(msgType == CONNECTION) {
                trace("connection");

                var id = s.readUnsignedByte();
                var x = s.readShort();
                var y = s.readShort();

                var ship = new Ship(id, x, y);
                this.addChild(ship); 

                trace("x > " + x + " | y > " + y);
                trace("id > " + id);

                if(myId == -1) {
                    trace("MEEE");
                    this.myShip = ship;
                    this.myId = id;
                    this.localShip = new LocalShip(x, y);
                    this.addChild(localShip);
                    
                    // UNDEBUG
                    // this.removeChild(ship);

                    // INIT
                    this.gameIsRunning = true;
                    Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
                    Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
                }
                
                this.players.set(id, ship);
            }
            
            if(msgType == PLAYER_UPDATE) {
                // trace("PLAYER_UPDATE");
                var id = s.readUnsignedByte();
                var x = s.readShort();
                var y = s.readShort();
                var rotation = s.readShort();
                // trace("rotation > " + rotation);
                var player = this.players.get(id);
                // trace("id is" + id);
                player.updatePosition(x, y, rotation);
            }

            if(msgType == PLAYER_DESTROY) {
                trace("PLAYER_DESTROY");
                var id = s.readUnsignedByte();
                var player = this.players.get(id);
                if(player != myShip) {
                    this.removeChild(player); // bug here
                    this.players.remove(id);
                }
                else {
                    this.removeChild(localShip);
                }
            }

            if(msgType == PLAYER_HIT) {
                var id = s.readUnsignedByte();
                var player = this.players.get(id);
                player.blink();
            }

            if(msgType == PLAYER_STATE) {
                trace("PLAYER_STATE");
                var id = s.readUnsignedByte();
                var player = this.players.get(id);
                var alive = s.readBoolean();
                trace("Alive > " + alive);
                var x = s.readShort();
                var y = s.readShort();

                if(alive) {
                    trace("alive");
                    player.updatePosition(x, y, 0);

                    if(id == this.myId) {
                        this.addChild(localShip);
                        localShip.respawnPosition(x, y);
                    }
                    else {
                        this.addChild(player);
                    }
                }
                else {
                    trace("dead");

                    if(id == this.myId) {
                        this.removeChild(localShip);
                    }
                    else {
                        this.removeChild(player);
                    }
                }
            }

            if(msgType == ROCKET_CREATE) {
                trace("ROCKET_CREATE");
                var id = s.readUnsignedByte();
                var x = s.readShort();
                var y = s.readShort();
                var rocket = new Rocket(x, y);
                this.addChild(rocket);
                this.rockets.set(id, rocket);
            }

            if(msgType == ROCKET_UPDATE) {
                // trace("ROCKET_UPDATE");
                var id = s.readUnsignedByte();
                var x = s.readShort();
                var y = s.readShort();
                var rocket = this.rockets.get(id);
                rocket.updatePosition(x, y);
            }

            if(msgType == ROCKET_DESTROY) {
                trace("ROCKET_DESTROY");
                var id = s.readUnsignedByte();
                var rocket = this.rockets.get(id);
                this.removeChild(rocket);  // Bug
                this.rockets.remove(id);
            }
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
    
    // CONTROLLER
    private function onEnterFrame(event:Event):Void {
        var elapsedTime:Float = Lib.getTimer() - lastTime;
        if(elapsedTime > 1 / 60) {

            // If i'm connected...
            if(this.gameIsRunning) {
                this.localShip.updatePosition2(keyLeftIsDown,
                                                keyRightIsDown,
                                                keyUpIsDown,
                                                keyDownIsDown);

                var attack:Bool = false;
                if(keyAttack){
                    if(Lib.getTimer() - this.attackTime > 300){
                        attack = true;
                        this.attackTime = Lib.getTimer();
                    }
                }

                s.writeByte(PLAYER_UPDATE);
                s.writeBoolean(keyLeftIsDown);
                s.writeBoolean(keyRightIsDown);
                s.writeBoolean(keyUpIsDown);
                s.writeBoolean(keyDownIsDown);
                s.writeBoolean(attack);
            }
            
            lastTime = Lib.getTimer();
        }
        
        var elapsedNetTime:Float = Lib.getTimer() - lastNetTime;
        if (elapsedNetTime > 1 / 10 && this.gameIsRunning) {
            s.flush();
        }
    }
    
    private function onKeyDown(event:KeyboardEvent) {
        switch(event.keyCode){
            case Keyboard.LEFT:
                keyLeftIsDown = true;
            case Keyboard.RIGHT:
                keyRightIsDown = true;
            case Keyboard.UP:
                keyUpIsDown = true;
            case Keyboard.DOWN:
                keyDownIsDown = true;
            case Keyboard.SPACE:
                keyAttack = true;
        }
    }

    private function onKeyUp(event:KeyboardEvent) {
        switch(event.keyCode){
            case Keyboard.LEFT:
                keyLeftIsDown = false;
            case Keyboard.RIGHT:
                keyRightIsDown = false;
            case Keyboard.UP:
                keyUpIsDown = false;
            case Keyboard.DOWN:
                keyDownIsDown = false;
            case Keyboard.SPACE:
                keyAttack = false;
        }
    }
}
