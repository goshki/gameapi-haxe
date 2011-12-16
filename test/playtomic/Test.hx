package;

import flash.display.Sprite;
import playtomic.Log;

class Test extends Sprite {
		
	public function new()
	{
		super();
	}

	public static function main() 
  {
#if debug
    if (haxe.Firebug.detect())
    {
      haxe.Firebug.redirectTraces();
    }
#end // debug
    
    flash.Lib.current.addChild(new Test());

    var num = "-99";

    trace(num + " -> " + haxe.Int64.toStr(playtomic.PlayerScore.scoreFromStr(num)));
	}
}
