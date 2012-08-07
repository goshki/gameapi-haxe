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

import haxe.Md5;

#if flash
import flash.display.DisplayObject;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.net.SharedObject;
#end

class PlayerLevels
{	
	public static var NEWEST:String = "newest";
	public static var POPULAR:String = "popular";
		
	private static var SECTION:String;
	private static var SAVE:String;
	private static var LIST:String;
	private static var LOAD:String;
	private static var RATE:String;
	
	public static function Initialise(apikey:String):Void
	{
		SECTION = Md5.encode("playerlevels-" + apikey);
		RATE = Md5.encode("playerlevels-rate-" + apikey);
		LIST = Md5.encode("playerlevels-list-" + apikey);
		SAVE = Md5.encode("playerlevels-save-" + apikey);
		LOAD = Md5.encode("playerlevels-load-" + apikey);
	}
	
	/**
	 * Logs a start on a player level
	 * @param	levelid			The playerLevel.LevelId 
	 */
	public static function LogStart(levelid:String):Void
	{
		Log.PlayerLevelStart(levelid);
	}

	/**
	 * Logs a win on a player level
	 * @param	levelid			The playerLevel.LevelId 
	 */
	public static function LogWin(levelid:String):Void
	{
		Log.PlayerLevelWin(levelid);
	}

	/**
	 * Logs a quit on a player level
	 * @param	levelid			The playerLevel.LevelId 
	 */
	public static function LogQuit(levelid:String):Void
	{
		Log.PlayerLevelQuit(levelid);
	}
	
	/**
	 * Logs a retry on a player level
	 * @param	levelid			The playerLevel.LevelId 
	 */
	public static function LogRetry(levelid:String):Void
	{
		Log.PlayerLevelRetry(levelid);
	}

	/**
	 * Flags a player level
	 * @param	levelid			The playerLevel.LevelId 
	 */
	public static function Flag(levelid:String):Void
	{
		Log.PlayerLevelFlag(levelid);
	}
	
	/**
	 * Rates a player level
	 * @param	levelid			The playerLevel.LevelId 
	 * @param	rating			Integer from 1 to 10
	 * @param	callbackhandler		Your function to receive the response:  function(response:Response)
	 * @param	additionalCallback (karg)Error callback (separate callbacks with variable parameter count)
	 */
	public static function Rate(levelid:String, rating:Int, callbackhandler:Void->Void = null, additionalCallback : Dynamic -> Void = null):Void
	{			
		var cookie:SharedObject = SharedObject.getLocal("ratings");

		//if(cookie.data[levelid] != null)
    if (Reflect.hasField(cookie.data, levelid))
		{
			if(additionalCallback != null)
			{
				additionalCallback(new Response(0, 402));
			}
			
			return;
		}
		
		if(rating < 0 || rating > 10)
		{
			if(additionalCallback != null)
			{
				additionalCallback(new Response(0, 401));
			}
			
			return;
		}
		
		var postdata = new Hash<String>();
		postdata.set("levelid", levelid);
		postdata.set("rating", "" + rating);
		
		//cookie.data[levelid] = rating;
    Reflect.setField(cookie.data, levelid, rating);

		Request.Load(SECTION, RATE, RateComplete, callbackhandler, postdata);
	}
	
	/**
	 * Processes the response received from the server, returns the data and response to the user's callbackhandler
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	postdata	The data that was posted
	 * @param	data		The XML returned from the server
	 * @param	response	The response from the server
	 */
	private static function RateComplete(callbackhandler:Dynamic->Void, postdata:Hash<String>, data:Xml = null, response:Response = null):Void
	{
		if(callbackhandler == null)
			return;
							
		callbackhandler(response);
		
	}

	/**
	 * Loads a player level
	 * @param	levelid			The playerLevel.LevelId 
	 * @param	callbackhandler		Your function to receive the response:  function(response:Response)
	 */
	public static function Load(levelid:String, callbackhandler:Void->Void = null):Void
	{	
		var postdata = new Hash<String>();
		postdata.set("levelid", levelid);
			
		Request.Load(SECTION, LOAD, LoadComplete, callbackhandler, postdata);
	}	
	
	/**
	 * Processes the response received from the server, returns the data and response to the user's callbackhandler
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	postdata	The data that was posted
	 * @param	data		The XML returned from the server
	 * @param	response	The response from the server
	 */
	private static function LoadComplete(callbackhandler:Dynamic->Dynamic->Void, postdata:Hash<String>, data:Xml = null, response:Response = null):Void
	{
		if(callbackhandler == null)
			return;
		
		var level:PlayerLevel = null;
		
		if(response.Success)
		{
      // karg: making Xml the right way
      // TODO: change to Fast xml
      var fast = new haxe.xml.Fast(data);

			//var item:Xml = data["level"];
      var item = fast.node.level;
      
			var datestring:String = item.att.sdate;//item["sdate"];				
			var year:Int = Std.parseInt(datestring.substr(datestring.lastIndexOf("/") + 1));
			var month:Int = Std.parseInt(datestring.substr(0, datestring.indexOf("/")));
			var day:Int = Std.parseInt(datestring.substr(datestring.indexOf("/" ) +1).substr(0, 2));
			
			level = new PlayerLevel();
			level.LevelId = item.att.levelid;//item["levelid"];
			level.PlayerName = item.att.playername;//item["playername"];
			level.PlayerId = item.att.playerid;//item["playerid"];
			level.Name = item.att.name;//item["name"];
			level.Score = Std.parseInt(item.att.score);//item["score"];
			level.Votes = Std.parseInt(item.att.votes);//item["votes"];
			level.Rating = Std.parseFloat(item.att.rating);//item["rating"];
			level.Data = item.att.data;//item["data"];
			level.Wins = Std.parseInt(item.att.wins);//item["wins"];
			level.Starts = Std.parseInt(item.att.starts);//item["starts"];
			level.Retries = Std.parseInt(item.att.retries);//item["retries"];
			level.Quits = Std.parseInt(item.att.quits);//item["quits"];
			level.Flags = Std.parseInt(item.att.flags);//item["flags"];
			// karg: haxe Date has mandatory arguments hour, minutes and seconds
      level.SDate = new Date(year, month-1, day, 0, 0, 0);
			level.RDate = item.att.rdate;//item["rdate"];
			level.SetThumb(item.att.thumb/*item["thumb"]*/);
						
			if(item.hasNode.custom/*item["custom"]*/)
			{			
				//var custom:XMLList = item["custom"];
        var custom = item.nodes.custom;
	
				for(cfield in custom)
				//for(cfield in custom.children())
				{
					//level.CustomData.set(cfield.name(), cfield.text());
					level.CustomData.set(cfield.att.name, cfield.att.text);
				}
			}
		}
		
		callbackhandler(level, response);
			
	}

	/**
	 * Lists player levels
	 * @param	callbackhandler		Your function to receive the response:  function(response:Response)
	 * @param	options			The list options, see http://playtomic.com/api/as3#PlayerLevels
	 */
	//public static function List(callbackhandler:Void->Void = null, options:Dynamic):Void
	public static function List(callbackhandler:Void->Void = null, options:Dynamic, ?customfilters : Hash<String> = null):Void
	{			
		var mode:String = Reflect.hasField(options, "mode") ? Reflect.field(options, "mode") : "popular";
		var page:Int = Reflect.hasField(options, "page") ? Reflect.field(options, "page") : 1;
		var perpage:Int = Reflect.hasField(options, "perpage") ? Reflect.field(options, "perpage") : 20;
		var datemin:String = Reflect.hasField(options, "datemin") ? Reflect.field(options, "datemin") : "";
		var datemax:String = Reflect.hasField(options, "datemax") ? Reflect.field(options, "datemax") : "";
		var data:Bool = Reflect.hasField(options, "data") ? Reflect.field(options, "data") : false;
		var thumbs:Bool = Reflect.hasField(options, "thumbs") ? Reflect.field(options, "thumbs") : false;
		//var customfilters:Dynamic = Reflect.hasField(options, "customfilters") ? Reflect.field(options, "customfilters") : {};
		
		var postdata = new Hash<String>();	
		postdata.set("mode", mode);
    // karg: simpler int to string conversion :)
		postdata.set("page", "" + page);	
		postdata.set("perpage", "" + perpage);
		postdata.set("data", data ? "y" : "n");
		postdata.set("thumbs", thumbs ? "y" : "n");
		postdata.set("datemin", datemin);
		postdata.set("datemax", datemax);
			
		var numcustomfilters:Int = 0;
		
		/*
    if(customfilters != null)
		{
			for(key in customfilters)
			{
				Reflect.setField(postdata, "ckey" + numcustomfilters, key);
				Reflect.setField(postdata, "cdata" + numcustomfilters, Reflect.field(customfilters, key));
				numcustomfilters++;
			}
		}
    */

    if (customfilters != null)
    {
      for(key in customfilters.keys())
      {
        postdata.set("ckey" + numcustomfilters, key);
        postdata.set("cdata" + numcustomfilters, customfilters.get(key));
				numcustomfilters++;
      }
    }
		
		postdata.set("filters", "" + numcustomfilters);
		
		Request.Load(SECTION, LIST, ListComplete, callbackhandler, postdata);
	}
	
	/**
	 * Processes the response received from the server, returns the data and response to the user's callbackhandler
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	postdata	The data that was posted
	 * @param	data		The XML returned from the server
	 * @param	response	The response from the server
	 */
	private static function ListComplete(callbackhandler:Dynamic->Dynamic->Dynamic->Void, postdata:Hash<String>, data:Xml = null, response:Response = null):Void
	{
		if(callbackhandler == null)
			return;
		
		var levels = new Array<PlayerLevel>();	
		var numresults:Int = 0;	

		if(response.Success)
		{
			var fast = new haxe.xml.Fast(data.firstElement());
      
			var cfield:Xml;
			var datestring:String;
			var year:Int;
			var month:Int;
			var day:Int;
			
			numresults = Std.parseInt(fast.att.numresults);//data["numresults"];	
			
      //var entries:XMLList = data["level"];
      var entries = fast.nodes.level;

			for(item in entries) 
			{
				datestring = item.att.sdate;//item["sdate"];				
				year = Std.parseInt(datestring.substr(datestring.lastIndexOf("/") + 1));
				month = Std.parseInt(datestring.substr(0, datestring.indexOf("/")));
				day = Std.parseInt(datestring.substr(datestring.indexOf("/" ) +1).substr(0, 2));
				
				var level:PlayerLevel = new PlayerLevel();
				level.LevelId = item.att.levelid;//item["levelid"];
				level.PlayerId = item.att.playerid;//item["playerid"];
				level.PlayerName = item.att.playername;//item["playername"];
				level.Name = item.att.name;//item["name"];
				level.Score = Std.parseInt(item.att.score);//item["score"];
				level.Rating = Std.parseFloat(item.att.rating);//item["rating"];
				level.Votes = Std.parseInt(item.att.votes);//item["votes"];
				level.Wins = Std.parseInt(item.att.wins);//item["wins"];
				level.Starts = Std.parseInt(item.att.starts);//item["starts"];
				level.Retries = Std.parseInt(item.att.retries);//item["retries"];
				level.Quits = Std.parseInt(item.att.quits);//item["quits"];
				level.Flags = Std.parseInt(item.att.flags);//item["flags"];
				level.SDate = new Date(year, month-1, day, 0, 0, 0);
				level.RDate = item.att.rdate;//item["rdate"];

				/*
        if(item["data"])
				{
					level.Data = item["data"];
				}
        */

        if (item.has.data)
        {
          level.Data = item.att.data;
        }
				
				level.SetThumb(item.att.thumb/*item["thumb"]*/);
        
				// karg: using haxe.xml.Fast
        /*
        var custom:XMLList = item["custom"];
	
				if(custom != null)
				{				
					for(cfield in custom.children())
					{
						level.CustomData[cfield.name()] = cfield.text();
					}
				}
        */

        if (item.hasNode.custom)
        {
          var custom = item.nodes.custom;

          for(cfield in custom)
          {
						level.CustomData.set(cfield.att.name, cfield.att.text);
          }
        }
				
				levels.push(level);
			}
		}

		callbackhandler(levels, numresults, response);
		
	}
			
	/**
	 * Saves a player level
	 * @param	level			The PlayerLevel to save
	 * @param	thumb			A movieclip or other displayobject (optional)
	 * @param	callbackhandler		Your function to receive the response:  function(level:PlayerLevel, response:Response)
	 */
	public static function Save(level:PlayerLevel, thumb:DisplayObject = null, callbackhandler:Void->Void = null):Void
	{
		var postdata = new Hash<String>();
		postdata.set("data", level.Data);
		postdata.set("playerid", level.PlayerId);
		postdata.set("playersource", level.PlayerSource);
		postdata.set("playername", level.PlayerName);
		postdata.set("name", level.Name);

		if(thumb != null)
		{
			var scale:Float = 1;
			var w:Int = Std.int(thumb.width);
			var h:Int = Std.int(thumb.height);
			
			if(thumb.width > 100 || thumb.height > 100)
			{
				if(thumb.width >= thumb.height)
				{
					scale = 100 / thumb.width;
					w = 100;
					h = Math.ceil(scale * thumb.height);
				}
				else if(thumb.height > thumb.width)
				{
					scale = 100 / thumb.height;
					w = Math.ceil(scale * thumb.width);
					h = 100;
				}
			}
			
			var scaler:Matrix = new Matrix();
			scaler.scale(scale, scale);

			var image:BitmapData = new BitmapData(w, h, true, 0x00000000);
			image.draw(thumb, scaler, null, null, null, true);
		
			postdata.set("image", Encode.Base64(Encode.PNG(image)));
			postdata.set("arrp", RandomSample(image));
			postdata.set("hash", Md5.encode(postdata.get("image") + postdata.get("arrp")));
		}
		else
		{
			postdata.set("nothumb", "y");
		}
		
		var customfields:Int = 0;
		
		if(level.CustomData != null)
		{
			for(key in level.CustomData.keys())
			{
				// karg: postdata is Hash<String>
        //Reflect.setField(postdata, "ckey" + customfields, key);
				//Reflect.setField(postdata, "cdata" + customfields, Reflect.field(level.CustomData, key));
        postdata.set("ckey" + customfields, key);
        postdata.set("cdata" + customfields, level.CustomData.get(key));

				customfields++;
			}
		}

		// karg: rename customfields tp customfieldsCount?
    postdata.set("customfields", "" + customfields);
		
		Request.Load(SECTION, SAVE, SaveComplete, callbackhandler, postdata);	
	}
	
	/**
	 * Processes the response received from the server, returns the data and response to the user's callbackhandler
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	postdata	The data that was posted
	 * @param	data		The XML returned from the server
	 * @param	response	The response from the server
	 */
	private static function SaveComplete(callbackhandler:Dynamic->Dynamic->Void, postdata:Hash<String>, data:Xml = null, response:Response = null):Void
	{
		if(callbackhandler == null)
			return;
			
		var level:PlayerLevel = new PlayerLevel();
		level.Data = postdata.get("data");
		level.PlayerId = postdata.get("playerid");
		level.PlayerSource = postdata.get("playersource");
		level.PlayerName = postdata.get("playername");
		level.Name = postdata.get("name");
		
		for(key in postdata)
		{
			if(key.indexOf("ckey") == 0)
			{
				var num:String = key.substr(4);
				
        // karg: postdata is now Hash<String>
        //var name:String = Reflect.field(postdata, "ckey" + num);
				//var value:String = Reflect.field(postdata, "cdata" + num);
        var name:String = postdata.get("ckey" + num);
				var value:String = postdata.get("cdata" + num);
				
				level.CustomData.set(name, value);
			}
		}
		
		postdata.set("data", level.Data);
		postdata.set("playerid", level.PlayerId);
		postdata.set("playersource", level.PlayerSource);
		postdata.set("playername", level.PlayerName);
		postdata.set("name", level.Name);
					
		if(response.Success || response.ErrorCode == 406)
		{
			level.LevelId = data.get("levelid");//data["levelid"];
			
      // karg: as3 api states that new Date() returns the current date
      //level.SDate = new Date();
      level.SDate = Date.now();

			level.RDate = "Just now";
		}

		callbackhandler(level, response);			
	}
						
	/**
	 * Gets a random sampling of pixels from an image
	 * @param	b	The image
	 */
	private static function RandomSample(b:BitmapData):String
	{
		var arr:Array<String> = new Array<String>();
		var x:Int;
		var y:Int;
		var c:String;
		
		while(arr.length < 10)
		{
			x = Std.int(Math.random() * b.width);
			y = Std.int(Math.random() * b.height);

			// karg: hex conversion
      //c = b.getPixel32(x, y).toStd.string(16);     
      c = StringTools.hex(b.getPixel32(x, y));     
			
			while(c.length < 6)  
				c = "0" + c;  				
			
			arr.push(x + "/" + y + "/" + c);
		}
		
		return arr.join(",");
	}		
}