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
import flash.external.ExternalInterface;
#end // flash

class Leaderboards
{
	public static var TODAY:String = "today";
	public static var LAST7DAYS:String = "last7days";
	public static var LAST30DAYS:String = "last30days";
	public static var ALLTIME:String = "alltime";
	public static var NEWEST:String = "newest";
	
	private static var SECTION:String;
	private static var CREATEPRIVATELEADERBOARD:String;
	private static var LOADPRIVATELEADERBOARD:String;
	private static var SAVEANDLIST:String;
	private static var SAVE:String;
	private static var LIST:String;
	
	public static function Initialise(apikey:String):Void
	{
		SECTION = Md5.encode("leaderboards-" + apikey);
		CREATEPRIVATELEADERBOARD = Md5.encode("leaderboards-createprivateleaderboard-" + apikey);
		LOADPRIVATELEADERBOARD = Md5.encode("leaderboards-loadprivateleaderboard-" + apikey);
		SAVEANDLIST = Md5.encode("leaderboards-saveandlist-" + apikey);
		SAVE = Md5.encode("leaderboards-save-" + apikey);
		LIST = Md5.encode("leaderboards-list-" + apikey);
	}
	
	/**
	 * Creates a private leaderboard for the user
	 * @param	table		The name of the leaderboard
	 * @param	permalink	The stem of the permalink, eg http://mywebsite.com/game.html?leaderboard=
	 * @param	callbackhandler	Callback function to receive the data:  function(leaderboard:Leaderboard, response:Response)
	 * @param	highest		The board's mode (true for highest, false for lowest)
	 */
	public static function CreatePrivateLeaderboard(table:String, permalink:String, callbackhandler:Void->Void = null, highest:Bool=true):Void
	{
		var postdata = new Hash<String>();
		postdata.set("table", table);
		postdata.set("highest", highest ? "y" : "n");
		postdata.set("permalink", permalink);
		
		Request.Load(SECTION, CREATEPRIVATELEADERBOARD, CreatePrivateLeaderboardComplete, callbackhandler, postdata);
	}
	
	/**
	 * Processes the response received from the server, returns the data and response to the user's callbackhandler
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	postdata	The data that was posted
	 * @param	data		The XML returned from the server
	 * @param	response	The response from the server
	 */
	private static function CreatePrivateLeaderboardComplete(callbackhandler:Dynamic->Dynamic->Void, postdata:Hash<String>, data:Xml = null, response:Response = null):Void
	{
		if(callbackhandler == null)
			return;
			
		var leaderboard:PrivateLeaderboard = null;
		
		if(response.Success)
		{
      // karg: haxe.xml.Fast
      var fast = new haxe.xml.Fast(data);
      
      //leaderboard = new PrivateLeaderboard(data["tableid"], data["name"], data["bitly"], data["permalink"], data["highest"] == "true", data["realname"]);
      leaderboard = new PrivateLeaderboard(fast.att.tableid, fast.att.name, fast.att.bitly, fast.att.permalink, fast.att.highest == "true", fast.att.realname);
		}
		
		callbackhandler(leaderboard, response);
		
	}
	
	/**
	 * Loads a private leaderboard
	 * @param	tableid		The id of the leaderboard
	 * @param	callbackhandler	Callback function to receive the data:  function(leaderboard:Leaderboard, response:Response)
	 */
	public static function LoadPrivateLeaderboard(tableid:String, callbackhandler:Void->Void=null):Void
	{
		var postdata = new Hash<String>();
		postdata.set("tableid", tableid);
		
		Request.Load(SECTION, LOADPRIVATELEADERBOARD, LoadPrivateLeaderboardComplete, callbackhandler, postdata);
	}
	
	/**
	 * Processes the response received from the server, returns the data and response to the user's callbackhandler
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	postdata	The data that was posted
	 * @param	data		The XML returned from the server
	 * @param	response	The response from the server
	 */
	private static function LoadPrivateLeaderboardComplete(callbackhandler:Dynamic->Dynamic->Void, postdata:Hash<String>, data:Xml = null, response:Response = null):Void
	{
		if(callbackhandler == null)
			return;
		
		var leaderboard:PrivateLeaderboard = null;
		
		if(response.Success)
		{
			var fast = new haxe.xml.Fast(data);
      
      //leaderboard = new PrivateLeaderboard(data["tableid"], data["name"], data["bitly"], data["permalink"], data["highest"] == "true", data["realname"]);
			leaderboard = new PrivateLeaderboard(fast.att.tableid, fast.att.name, fast.att.bitly, fast.att.permalink, fast.att.highest == "true", fast.att.realname);
		}
		
		callbackhandler(leaderboard, response);
		
	}
	
	/**
	 * Attempts to retrieve a leaderboard id from the URL (eg http://url.com/game?leaderboard=xxxx)
	 */
	public static function GetLeaderboardFromUrl():String
	{
		if(!ExternalInterface.available)
			return null;
			
		try
		{
			// karg: might also use an explicit cast to String
      var url = Std.string(ExternalInterface.call("window.location.href.toString"));
			
			if(url.indexOf("?") == -1)
				return null;
				
			var leaderboardid:String = url.substr(url.indexOf("leaderboard=") + 12);
			
			if(leaderboardid.indexOf("&") > -1)
				leaderboardid = leaderboardid.substr(0, leaderboardid.indexOf("&"));

			if(leaderboardid.indexOf("#") > -1)
				leaderboardid = leaderboardid.substr(0, leaderboardid.indexOf("#"));

			return leaderboardid;
		}
		catch(s:Dynamic)
		{
			
		}		
		
		return null;
	}
	
	/**
	 * Performs a save and a list in a single request that returns the player's score and page of scores it occured on
	 * @param	score		The player's score as a PlayerScore
	 * @param	table		The name of the leaderboard
	 * @param	callbackhandler	Callback function to receive the data:  function(scores:Array, numscores:Int, response:Response)
	 * @param	options		The leaderboard options, check the documentation at http://playtomic.com/api/as3#Leaderboards
	 */
	public static function SaveAndList(score:PlayerScore, table:String, callbackhandler:Void->Void = null, options:Dynamic=null):Void
	{
		var allowduplicates:Bool = Reflect.hasField(options, "allowduplicates") ? Reflect.field(options, "allowduplicates") : false;
		var global:Bool = Reflect.hasField(options, "global") ? Reflect.field(options, "global") : true;
		var highest:Bool = Reflect.hasField(options, "highest") ? Reflect.field(options, "highest") : true;
		var mode:String = Reflect.hasField(options, "mode") ? Reflect.field(options, "mode") : "alltime";
		var customfilters:Hash<String> = new Hash();
		
		if(Reflect.field(options, "customfilters"))
			customfilters = Reflect.field(options, "customfilters");

		var page:Int = Reflect.hasField(options, "page") ? Reflect.field(options, "page") : 1;
		var perpage:Int = Reflect.hasField(options, "perpage") ? Reflect.field(options, "perpage") : 20;
		var friendslist:Array<String> = Reflect.hasField(options, "friendslist") ? Reflect.field(options, "friendslist") : new Array();

		// save options
		var postdata = new Hash<String>();
		postdata.set("url", Log.SourceUrl);
		postdata.set("table", table);
		postdata.set("highest", highest ? "y" : "n");
		postdata.set("name", score.Name);
		postdata.set("points", Std.string(score.Points));
		postdata.set("allowduplicates", allowduplicates ? "y" : "n");
		postdata.set("auth", Md5.encode(Log.BaseUrl + Std.string(score.Points)));
		
		var numfields:Int = 0;
		
		if(score.CustomData != null)
		{
			for(dkey in score.CustomData.keys())
			{
				postdata.set("ckey" + numfields, dkey);
				postdata.set("cdata" + numfields, score.CustomData.get(dkey));
				numfields++;
			}
		}
		
		postdata.set("numfields", Std.string(numfields));
		
		// list options
		postdata.set("global", global ? "y" : "n");
		postdata.set("mode", mode);
		postdata.set("page", Std.string(page));
		postdata.set("perpage", Std.string(perpage));
		
		var numfilters:Int = 0;
		
		if(customfilters != null)
		{
			for(fkey in customfilters.keys())
			{
				postdata.set("lkey" + numfilters, fkey);
				postdata.set("ldata" + numfilters, customfilters.get(fkey));
				numfilters++;
			}
		}
		
		postdata.set("numfilters", Std.string(numfilters));
		
		if(score.FBUserId != null && score.FBUserId != "")
		{
			if(friendslist.length > 0)
				postdata.set("friendslist", friendslist.join(","));
			
			postdata.set("fbuserid", score.FBUserId);
		}

		Request.Load(SECTION, SAVEANDLIST, callback(SaveAndListComplete), callbackhandler, postdata);
	}
	
	/**
	 * Processes the response received from the server, returns the data and response to the user's callbackhandler
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	postdata	The data that was posted
	 * @param	data		The XML returned from the server
	 * @param	response	The response from the server
	 */
	private static function SaveAndListComplete(callbackhandler:Dynamic->Dynamic->Dynamic->Void, postdata:Hash<String>, data:Xml = null, response:Response = null):Void
	{
		if(callbackhandler == null)
			return;
		
		if(response.Success)
		{				
			ProcessScores(data, response, callbackhandler);
		}
		else
		{
			callbackhandler([], 0, response);
		}
		
		
	}
	
	/**
	 * Saves a user's score
	 * @param	score		The player's score as a PlayerScore
	 * @param	table		The name of the leaderboard
	 * @param	callbackhandler	Callback function to receive the data:  function(score:PlayerScore, response:Response)
	 * @param	options		The leaderboard options, check the documentation at http://playtomic.com/api/as3#Leaderboards
	 */
	public static function Save(score:PlayerScore, table:String, callbackhandler:Void->Void = null, options:Dynamic):Void
	{
		var allowduplicates:Bool = Reflect.hasField(options, "allowduplicates") ? Reflect.field(options, "allowduplicates") : false;
		var highest:Bool = Reflect.hasField(options, "highest") ? Reflect.field(options, "highest") : true;

		// save the score
		var s:String = Std.string(score.Points);
		
		if(s.indexOf(".") > -1)
			s = s.substr(0, s.indexOf("."));
		
		var postdata = new Hash<String>();
		var customfields:Int = 0;
		
		if(score.CustomData != null)
		{
			for(key in score.CustomData)
			{
				//Reflect.setField(postdata, "ckey" + customfields, key);
				//Reflect.setField(postdata, "cdata" + customfields, Reflect.field(score.CustomData, key));
				postdata.set("ckey" + customfields, key);
				postdata.set("cdata" + customfields, Reflect.field(score.CustomData, key));
				customfields++;
			}
		}
		
		postdata.set("url", Log.BaseUrl);
		postdata.set("table", table);
		postdata.set("highest", highest ? "y" : "n");
		postdata.set("name", score.Name);
		postdata.set("points", s);
		postdata.set("allowduplicates", allowduplicates ? "y" : "n");
		postdata.set("auth", Md5.encode(Log.BaseUrl + s));
		postdata.set("fb", (score.FBUserId != "" && score.FBUserId != null) ? "y" : "n");
		postdata.set("fbuserid", score.FBUserId);
		postdata.set("customfields", Std.string(customfields));
		
		Request.Load(SECTION, SAVE, SaveComplete, callbackhandler, postdata);
	}
	
	/**
	 * Processes the response received from the server, returns the data and response to the user's callbackhandler
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	postdata	The data that was posted
	 * @param	data		The XML returned from the server
	 * @param	response	The response from the server
	 */
	private static function SaveComplete(callbackhandler:Dynamic->Void, postdata:Hash<String>, data:Xml = null, response:Response = null):Void
	{
		if(callbackhandler == null)
			return;
		
							
		callbackhandler(response);
	}
	
	/**
	 * Lists scores from a table
	 * @param	table		The name of the leaderboard
	 * @param	callbackhandler	Callback function to receive the data:  function(scores:Array, numscores:Int, response:Response)
	 * @param	options		The leaderboard options, check the documentation at http://playtomic.com/api/as3#Leaderboards
   * TODO (karg) : replace the options parameter with a full list for portability
	 */
	public static function List(table:String, callbackhandler:Void->Void, options:Dynamic):Void
	{
		var global:Bool = Reflect.hasField(options, "global") ? Reflect.field(options, "global") : true;
		var highest:Bool = Reflect.hasField(options, "highest") ? Reflect.field(options, "highest") : true;
		var mode:String = Reflect.hasField(options, "mode") ? Reflect.field(options, "mode") : "alltime";
		var customfilters:Hash<String> = Reflect.hasField(options, "customfilters") ? Reflect.field(options, "customfilters") : new Hash<String>();
		var page:Int = Reflect.hasField(options, "page") ? Reflect.field(options, "page") : 1;
		var perpage:Int = Reflect.hasField(options, "perpage") ? Reflect.field(options, "perpage") : 20;
		var facebook:Bool = Reflect.hasField(options, "facebook") ? Reflect.field(options, "facebook") : false;
		var friendslist:Array<String> = Reflect.hasField(options, "friendslist") ? Reflect.field(options, "friendslist") : new Array();

		var postdata = new Hash<String>();
		var numfilters:Int = 0;
		
		for(key in customfilters.keys())
		{
			postdata.set("ckey" + numfilters, key);
			postdata.set("cdata" + numfilters, customfilters.get(key));
			numfilters++;
		}
		
		postdata.set("url", (global || Log.BaseUrl == null) ? "global" : Log.BaseUrl);
		postdata.set("mode", mode);
		postdata.set("page", Std.string(page));
		postdata.set("perpage", Std.string(perpage));
		postdata.set("highest", highest ? "y" : "n");
		postdata.set("filters", Std.string(numfilters));
		postdata.set("table", table);
		
		if(facebook)
		{
			if(friendslist.length > 0)
				postdata.set("friendslist", friendslist.join(","));
		}
		
		//trace("posting ");
		//for(var x:String in postdata)
		//	trace(x + ": " + postdata[x]);
		
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
		
		if(response.Success)
		{				
			ProcessScores(data, response, callbackhandler);
		}
		else
		{
			callbackhandler([], 0, response);
		}
		
		
	}

	/**
	 * Processes the scores received from a List request
	 * @param	data		The XML returned from the server
	 * @param	response	The response from the server
	 * @param	callbackhandler	The user's callbackhandler function
	 */
	private static function ProcessScores(data:Xml, response:Response, callbackhandler:Dynamic->Dynamic->Dynamic->Void):Void
	{			
		var fast = new haxe.xml.Fast(data);
    
    var numscores:Int = Std.parseInt(fast.att.numscores/*data["numscores"]*/);
		var results:Array<PlayerScore> = new Array<PlayerScore>();
		var datestring:String;
		var year:Int;
		var month:Int;
		var day:Int;
					
		//var entries:XMLList = data["score"];
    var entries = fast.nodes.entries;

		for(item in entries) 
		{
			datestring = item.att.sdate;//item["sdate"];				
			year = Std.parseInt(datestring.substr(datestring.lastIndexOf("/") + 1));
			month = Std.parseInt(datestring.substr(0, datestring.indexOf("/")));
			day = Std.parseInt(datestring.substr(datestring.indexOf("/" ) +1).substr(0, 2));
			
			var score:PlayerScore = new PlayerScore();
			score.SDate = new Date(year, month-1, day, 0 , 0 , 0);
			score.RDate = item.att.rdate;//item["rdate"];
			score.Name = item.att.name;//item["name"];

			// karg: convert from string to haxe.Int64
      score.Points = PlayerScore.scoreFromStr(item.att.points);//item["points"];

			score.Website = item.att.website;//item["website"];
			score.Rank = Std.parseInt(item.att.rank);//item["rank"];
			
			if(item.has.submittedorbest/*item["submittedorbest"] != null*/)
				score.SubmittedOrBest = item.att.submittedorbest == "true";//item["submittedorbest"] == "true";
			
			if(item.has.fbuserid/*item["fbuserid"]*/)
				score.FBUserId = item.att.fbuserid;//item["fbuserid"];
			
			if(item.hasNode.custom/*item["custom"]*/)
			{			
				//var custom:XMLList = item["custom"];
        var custom = item.nodes.custom;
				
				//for(cfield in custom.children())
        for(cfield in custom)
				{
					//score.CustomData[cfield.name()] = cfield.text();
          // TODO: karg: i don't think this is the structure of the xml
          score.CustomData.set(cfield.att.name, cfield.att.text);
				}
			}
			
			results.push(score);
		}
		
		callbackhandler(results, numscores, response);
	}
}