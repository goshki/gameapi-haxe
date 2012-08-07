﻿//  This file is part of the official Playtomic API for HaXe games.  
//  Playtomic is a real time analytics platform for casual games 
//  and services that go in casual games.  If you haven't used it 
//  before check it out:
//  http://playtomic.com/
//
//  Created by ben at the above domain on 10/5/11.
//  Copyright 2011 Playtomic LLC. All rights reserved.
//
//  Documentation is available at:
//  http://playtomic.com/api/haxe
//
// PLEASE NOTE:
// You may modify this SDK if you wish but be kind to our servers.  Be
// careful about modifying the analytics stuff as it may give you 
// borked reports.
//
// If you make any awesome improvements feel free to let us know!
//
// -------------------------------------------------------------------------
// THIS SOFTWARE IS PROVIDED BY PLAYTOMIC, LLC "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

package playtomic;

import haxe.Timer;

#if flash
import flash.system.Security;
#end
import nme.net.SharedObject;


class Log {
	// API settings
	private static var Enabled:Bool = false;
	private static var Queue:Bool = true;
	
	// SWF settings
	public static var SWFID:Int = 0;
	public static var GUID:String = "";
	public static var SourceUrl:String;
	public static var BaseUrl:String;

	// play timer, goal tracking etc
	//#if flash
	private static var Cookie:SharedObject;
	//#end

	public static var LogQueue:LogRequest;
	private static var PingR:Timer;
	private static var FirstPing:Bool = true;
	private static var Pings:Int = 0;
	private static var Plays:Int = 0;	
	
	private static var Frozen:Bool = false;
	private static var FrozenQueue:Array<String> = new Array<String>();

	// unique, logged metrics
	private static var Customs:Array<String> = new Array<String>();
	private static var LevelCounters:Array<String> = new Array<String>();
	private static var LevelAverages:Array<String> = new Array<String>();
	private static var LevelRangeds:Array<String> = new Array<String>();

	/**
	 * Logs a view and initializes the API.  You must do this first before anything else!
	 * @param	swfid		Your game id from the Playtomic dashboard
	 * @param	guid		Your game guid from the Playtomic dashboard
	 * @param	apikey		Your secret API key from the Playtomic dashboard
	 * @param	defaulturl	Should be root.loaderInfo.loaderURL or some other default url value to be used if we can't detect the page
	 */
	public static function View( swfid:Int = 0, guid:String = "", apikey:String = "", defaulturl:String = "" ):Void {
		if ( SWFID > 0 ) {
			return;
        }

		SWFID = swfid;
		GUID = guid;
		Enabled = true;

		if ( ( SWFID == 0 || GUID == "" ) ) {
			Enabled = false;
			return;
		}

		SourceUrl = GetUrl( defaulturl );

		if ( SourceUrl == null || SourceUrl == "" ) {
			Enabled = false;
			return;
		}
		
		BaseUrl = SourceUrl.split("://")[1];
		BaseUrl = BaseUrl.substr(0, BaseUrl.indexOf("/"));
        
		//SourceUrl = Request.Escape(SourceUrl);
		//BaseUrl = Request.Escape(BaseUrl);
		
		//Parse.Initialise(apikey);
		//GeoIP.Initialise(apikey);
		//Data.Initialise(apikey);
		//Leaderboards.Initialise(apikey);
		//GameVars.Initialise(apikey);
		//PlayerLevels.Initialise(apikey);
		Request.Initialise();	
		
		LogQueue = LogRequest.Create();
		//#if flash
		Cookie = SharedObject.getLocal("playtomic");
		//#end
		
		// Load the security context
		//trace("*** WARNING CROSSDOMAIN IS LOADING FROM .DEV ***");
		#if flash
		Security.loadPolicyFile("http://g" + guid + ".api.playtomic.com/crossdomain.xml");
		#end
					
		// Check the URL is http		
		//if(defaulturl.indexOf("http://") != 0 && Security.sandboxType != "localWithNetwork" && Security.sandboxType != "localTrusted")
		//{
		//	Enabled = false;
		//	return;
		//}
		
		// Log the view (first or repeat visitor)
		var views:Int = GetCookie( "views" );
		Send( "v/" + ( views + 1 ), true );

		// Start the play timer
		Timer.delay( PingServer, 60000 );
	}

	/**
	 * Increases the number of views successfully logged 
	 */
	public static function IncreaseViews():Void
	{
		var views:Int = GetCookie("views");
		views++;
		SaveCookie("views", views);
	}
	
	/**
	 * Increases the number of plays successfully logged 
	 */
	public static function IncreasePlays():Void
	{
		Plays++;
	}

	/**
	 * Logs a play.  Call this when the user begins an actual game (eg clicks play button)
	 */
	public static function Play():Void
	{						
		if(!Enabled)
			return;

		LevelCounters = new Array<String>();
		LevelAverages = new Array<String>();
		LevelRangeds = new Array<String>();
			
		Send("p/" + (Plays + 1), true);
	}

	/**
	 * Increases the play time and triggers events being sent
	 */
	private static function PingServer():Void
	{			
		if(!Enabled)
			return;
			
		Pings++;
		
		Send("t/" + (FirstPing ? "y" : "n") + "/" + Pings, true);
			
		if(FirstPing)
		{
			PingR = new Timer(30000);
			PingR.run = PingServer;

			FirstPing = false;
		}
	}
	
	/**
	 * Logs a custom metric which can be used to track how many times something happens in your game.
	 * @param	name		The metric name
	 * @param	group		Optional group used in reports
	 * @param	unique		Only count a metric one single time per view
	 */
	public static function CustomMetric(name:String, group:String = null, unique:Bool = false):Void
	{		
		if(!Enabled)
			return;

		if(group == null)
			group = "";

		if(unique)
		{
			if(ArrayContains(Customs, name))
				return;

			Customs.push(name);
		}
		
		Send("c/" + Clean(name) + "/" + Clean(group));
	}

	/**
	 * Logs a level counter metric which can be used to track how many times something occurs in levels in your game.
	 * @param	name		The metric name
	 * @param	level		The level number as an integer or name as a string
	 * @param	unique		Only count a metric one single time per play
	 */
	public static function LevelCounterMetric(name:String, level:Dynamic, unique:Bool = false):Void
	{		
		if(!Enabled)
			return;

		if(unique)
		{
			var key:String = name + "." + Std.string(level);
			
			if(ArrayContains(LevelCounters, key))
				return;

			LevelCounters.push(key);
		}
		
		Send("lc/" + Clean( name ) + "/" + Clean( Std.string( level ) ) );
	}
	
	/**
	 * Logs a level ranged metric which can be used to track how many times a certain value is achieved in levels in your game.
	 * @param	name		The metric name
	 * @param	level		The level number as an integer or name as a string
	 * @param	value		The value being tracked
	 * @param	unique		Only count a metric one single time per play
	 */
	public static function LevelRangedMetric(name:String, level:Dynamic, value:Int, unique:Bool = false):Void
	{			
		if(!Enabled)
			return;

		if(unique)
		{
			var key:String = name + "." + Std.string(level);
			
			if(ArrayContains(LevelRangeds, key))
				return;

			LevelRangeds.push(key);
		}
		
		Send("lr/" + Clean(name) + "/" + Clean(level.ToStd.string()) + "/" + value);
	}

	/**
	 * Logs a level average metric which can be used to track the min, max, average and total values for an event.
	 * @param	name		The metric name
	 * @param	level		The level number as an integer or name as a string
	 * @param	value		The value being added
	 * @param	unique		Only count a metric one single time per play
	 */
	public static function LevelAverageMetric(name:String, level:Dynamic, value:Int, unique:Bool = false):Void
	{
		if(!Enabled)
			return;

		if(unique)
		{
			var key:String = name + "." + Std.string(level);
			
			if(ArrayContains(LevelAverages, key))
				return;

			LevelAverages.push(key);
		}
		
		Send( "la/" + Clean( name ) + "/" + Clean( Std.string( level ) ) + "/" + value );
	}

	private static function ArrayContains(arr:Array<String>, key:String):Bool
	{
		for(arrayItem in arr)
		{
			if(arrayItem == key)
			{
				return true;
			}
		}

		return false;
	}

	/**
	 * Logs the link results, internal use only.  The correct use is Link.Open(...)
	 * @param	levelid		The player level id
	 */
	public static function Link(url:String, name:String, group:String, unique:Int, total:Int, fail:Int):Void
	{
		if(!Enabled)
			return;
		
		Send("l/" + Clean(name) + "/" + Clean(group) + "/" + Clean(url) + "/" + unique + "/" + total + "/" + fail);
	}

	/**
	 * Logs a heatmap which allows you to visualize where some event occurs.
	 * @param	metric		The metric you are tracking (eg clicks)
	 * @param	heatmap		The heatmap (the one you upload images for)
	 * @param	x			The x coordinate
	 * @param	y			The y coordinate
	 */
	public static function Heatmap(metric:String, heatmap:String, x:Int, y:Int):Void
	{
		if(!Enabled)
			return;
		
		Send("h/" + Clean(metric) + "/" + Clean(heatmap) + "/" + x + "/" + y);
	}

	/**
	 * Not yet implemented :(
	 */
	private static function Funnel(name:String, step:String, stepnum:Int):Void
	{
		if(!Enabled)
			return;
		
		Send("f/" + Clean(name) + "/" + Clean(step) + "/" + stepnum);
	}

	/**
	 * Logs a start of a player level, internal use only.  The correct use is PlayerLevels.LogStart(...);
	 * @param	levelid		The player level id
	 */
	public static function PlayerLevelStart(levelid:String):Void
	{
		if(!Enabled)
			return;
		
		Send("pls/" + levelid);
	}

	/**
	 * Logs a win on a player level, internal use only.  The correct use is PlayerLevels.LogWin(...);
	 * @param	levelid		The player level id
	 */
	public static function PlayerLevelWin(levelid:String):Void
	{
		if(!Enabled)
			return;
		
		Send("plw/" + levelid);
	}

	/**
	 * Logs a quit on a player level, internal use only.  The correct use is PlayerLevels.LogQuit(...);
	 * @param	levelid		The player level id
	 */
	public static function PlayerLevelQuit(levelid:String):Void
	{
		if(!Enabled)
			return;
		
		Send("plq/" + levelid);
	}
	
	/**
	 * Logs a flag on a player level, internal use only.  The correct use is PlayerLevels.Flag(...);
	 * @param	levelid		The player level id
	 */
	public static function PlayerLevelFlag(levelid:String):Void
	{
		if(!Enabled)
			return;
		
		Send("plf/" + levelid);
	}
	
	/**
	 * Logs a retry on a player level, internal use only.  The correct use is PlayerLevels.LogRetry(...);
	 * @param	levelid		The player level id
	 */
	public static function PlayerLevelRetry(levelid:String):Void
	{
		if(!Enabled)
			return;
		
		Send("plr/" + levelid);
	}
	
	/**
	 * Freezes the API so analytics events are queued but not sent
	 */
	public static function Freeze():Void
	{
		Frozen = true;
	}

	/**
	 * Unfreezes the API and sends any queued events
	 */
	public static function UnFreeze():Void
	{
		if(!Enabled)
			return;
		
		Frozen = false;
		LogQueue.MassQueue(FrozenQueue);
	}

	/**
	 * Forces the API to send any unsent data now
	 */
	public static function ForceSend():Void
	{
		if(!Enabled)
			return;

		if(LogQueue == null)
			LogQueue = LogRequest.Create();

		LogQueue.Send();
		LogQueue = LogRequest.Create();

		if(FrozenQueue.length > 0)
		LogQueue.MassQueue(FrozenQueue);
	}
	
	/**
	 * Adds an event and if ready or a view or not queuing, sends it
	 * @param	s	The event as an ev/xx string
	 * @param	view	If it's a view or not
	 */
	private static function Send(s:String, view:Bool = false):Void
	{
		if(Frozen)
		{
			FrozenQueue.push(s);
			return;
		}
		
		LogQueue.Queue(s);

		if(LogQueue.ready || view || !Queue)
		{
			LogQueue.Send();
			LogQueue = LogRequest.Create();
		}
	}
	
	/**
	 * Cleans a piece of text of reserved characters
	 * @param	s	The string to be cleaned
	 */
	private static function Clean(s:String):String
	{
		while(s.indexOf("/") > -1)
			s = StringTools.replace(s, "/", "\\");
			
		while(s.indexOf("~") > -1)
			s = StringTools.replace(s, "~", "-");				
			
		return playtomic.Request.Escape(s);
	}

	/**
	 * Gets a cookie value
	 * @param	n	The key (views, plays)
	 */
	private static function GetCookie(n:String):Int
	{
		//#if flash
		if(Reflect.field(Cookie.data, n) == null)
		{
			return 0;
		}
		else
		{
			// karg: ugly as hell
      //return Std.parseInt(Cookie.data[n]);
      return Std.parseInt(cast(Reflect.field(Cookie.data, n), String));
		}
		//#end

		return 0;
	}
	
	/**
	 * Saves a cookie value
	 * @param	n	The key (views, plays)
	 * @param	v	The value
	 */
	private static function SaveCookie(n:String, v:Int):Void
	{
		//#if flash
		if(Reflect.field(Cookie.data, n) != null)
		{
      // karg: workarounds
      //Cookie.data[n] = Std.string(v);
      Reflect.setField(Cookie.data, n, "" + v); 
      
      try
      {
        Cookie.flush();
      }
      catch(s:Dynamic)
      {
      }
    }
		//#end
	}	

	/**
	 * Attempts to detect the page url
	 * @param	defaultUrl		The fallback url if page cannot be detected
	 */
	private static function GetUrl( defaultUrl:String ):String {
		if ( defaultUrl == null || defaultUrl == "" || defaultUrl == "null") {
			return "http://localhost/";
        }
		return defaultUrl;
	}
}