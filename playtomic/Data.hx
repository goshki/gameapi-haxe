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

class Data
{
	private static var SECTION:String;
	private static var VIEWS:String;
	private static var PLAYS:String;
	private static var PLAYTIME:String;
	private static var CUSTOMMETRIC:String;
	private static var LEVELCOUNTERMETRIC:String;
	private static var LEVELRANGEDMETRIC:String;
	private static var LEVELAVERAGEMETRIC:String;
	
	public static function Initialise(apikey:String):Void
	{
		SECTION = Md5.encode("data-" + apikey);
		VIEWS = Md5.encode("data-views-" + apikey);
		PLAYS = Md5.encode("data-plays-" + apikey);
		PLAYTIME = Md5.encode("data-playtime-" + apikey);
		CUSTOMMETRIC = Md5.encode("data-custommetric-" + apikey);
		LEVELCOUNTERMETRIC = Md5.encode("data-levelcountermetric-" + apikey);
		LEVELRANGEDMETRIC = Md5.encode("data-levelrangedmetric-" + apikey);
		LEVELAVERAGEMETRIC = Md5.encode("data-levelaveragemetric-" + apikey);
	}
	
	/**
	 * Loads the views your game logged on a day or all time
	 * @param	callbackhandler	Your function to receive the data:  callbackhandler(data:Dynamic, response:Response);
	 * @param	options		Dynamic with day, month, year properties or null for all time
	 */
	public static function Views(callbackhandler:Void->Void, options:Dynamic=null):Void
	{
		General(VIEWS, "Views", callbackhandler, options);
	}
	
	/**
	 * Loads the plays your game logged on a day or all time
	 * @param	callbackhandler	Your function to receive the data:  callbackhandler(data:Dynamic, response:Response);
	 * @param	options		Dynamic with day, month, year properties or null for all time
	 */
	public static function Plays(callbackhandler:Void->Void, options:Dynamic=null):Void
	{
		General(PLAYS, "Plays", callbackhandler, options);
	}

	/**
	 * Loads the playtime your game logged on a day or all time
	 * @param	callbackhandler	Your function to receive the data:  callbackhandler(data:Dynamic, response:Response);
	 * @param	options		Dynamic with day, month, year properties or null for all time
	 */
	public static function PlayTime(callbackhandler:Void->Void, options:Dynamic=null):Void
	{		
		General(PLAYTIME, "Playtime", callbackhandler, options);
	}
	
	/**
	 * Passes a general request on
	 * @param	action		The action on the server
	 * @param	type		The type of data being requested
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	options		Dynamic with day, month, year properties or null for all time
	 */
	private static function General(action:String, type:String, callbackhandler:Void->Void, options:Dynamic):Void
	{
		var postdata = new Hash<String>();
		postdata.set("type", type);
		postdata.set("day", Reflect.hasField(options, "day") ? Reflect.field(options, "day") : "0");
		postdata.set("month", Reflect.hasField(options, "month") ? Reflect.field(options, "month") : "0");
		postdata.set("year", Reflect.hasField(options, "year") ? Reflect.field(options, "year") : "0");

		Request.Load(SECTION, action, GeneralComplete, callbackhandler, postdata);
	}
	
	/**
	 * Processes the response received from the server, returns the data and response to the user's callbackhandler
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	postdata	The data that was posted
	 * @param	data		The XML returned from the server
	 * @param	response	The response from the server
	 */
	private static function GeneralComplete(callbackhandler:Dynamic->Dynamic->Void, postdata:Hash<String>, data:Xml = null, response:Response = null):Void
	{
		if(callbackhandler == null)
			return;
			
		var result = {};
									
		if(response.Success)
		{
			var fast = new haxe.xml.Fast(data.firstElement());

			Reflect.setField(result, "Name", postdata.get("type"));
			Reflect.setField(result, "Day", postdata.get("day"));
			Reflect.setField(result, "Month", postdata.get("month"));
			Reflect.setField(result, "Year", postdata.get("year"));
			Reflect.setField(result, "Value", Std.parseInt(Std.string(fast.node.value)));
		}
		
		callbackhandler(result, response);
	}

	/**
	 * Loads a custom metric's data for a date or all time
	 * @param	metric		The name of your metric
	 * @param	callbackhandler	Your function to receive the data:  callbackhandler(data:Dynamic, response:Response);
	 * @param	options		Dynamic with day, month, year properties or null for all time
	 */
	public static function CustomMetric(metric:String, callbackhandler:Void->Void, options:Dynamic):Void
	{
		var postdata = new Hash<String>();	
		postdata.set("metric", metric);
		postdata.set("day", Reflect.hasField(options, "day") ? Reflect.field(options, "day") : "0");
		postdata.set("month", Reflect.hasField(options, "month") ? Reflect.field(options, "month") : "0");
		postdata.set("year", Reflect.hasField(options, "year") ? Reflect.field(options, "year") : "0");
					
		Request.Load(SECTION, CUSTOMMETRIC, CustomMetricComplete, callbackhandler, postdata);
	}
	
	/**
	 * Processes the response received from the server, returns the data and response to the user's callbackhandler
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	postdata	The data that was posted
	 * @param	data		The XML returned from the server
	 * @param	response	The response from the server
	 */
	private static function CustomMetricComplete(callbackhandler:Dynamic->Dynamic->Void, postdata:Hash<String>, data:Xml = null, response:Response = null):Void
	{
		if(callbackhandler == null)
			return;
			
		var result = {};
									
		if(response.Success)
		{
			var fast = new haxe.xml.Fast(data.firstElement());

			Reflect.setField(result, "Name", "CustomMetric");
			Reflect.setField(result, "Metric", postdata.get("metric"));
			Reflect.setField(result, "Day", postdata.get("day"));
			Reflect.setField(result, "Month", postdata.get("month"));
			Reflect.setField(result, "Year", postdata.get("year"));
			Reflect.setField(result, "Value", Std.parseInt(Std.string(fast.node.value)));
		}
		
		callbackhandler(result, response);
	}
	
	/**
	 * Loads a level counter metric's data for a level on a date or all time
	 * @param	metric		The name of your metric
	 * @param	level		The level number (integer) or name (string)
	 * @param	callbackhandler	Your function to receive the data:  callbackhandler(data:Dynamic, response:Response);
	 * @param	options		Dynamic with day, month, year properties or null for all time
	 */
	public static function LevelCounterMetric(metric:String, level:Dynamic, callbackhandler:Void->Void, options:Dynamic):Void
	{
		LevelMetric(LEVELCOUNTERMETRIC, metric, level.toStd.string(), LevelCounterMetricComplete, callbackhandler, options);
	}
			
	/**
	 * Processes the response received from the server, returns the data and response to the user's callbackhandler
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	postdata	The data that was posted
	 * @param	data		The XML returned from the server
	 * @param	response	The response from the server
	 */
	private static function LevelCounterMetricComplete(callbackhandler:Dynamic->Dynamic->Void, postdata:Hash<String>, data:Xml = null, response:Response = null):Void
	{
		if(callbackhandler == null)
			return;
			
		var result = {};
											
		if(response.Success)
		{
			var fast = new haxe.xml.Fast(data.firstElement());

			Reflect.setField(result, "Name", "LevelCounterMetric");
			Reflect.setField(result, "Metric", postdata.get("metric"));
			Reflect.setField(result, "Level", postdata.get("level"));
			Reflect.setField(result, "Day", postdata.get("day"));
			Reflect.setField(result, "Month", postdata.get("month"));
			Reflect.setField(result, "Year", postdata.get("year"));
			Reflect.setField(result, "Value", Std.parseInt(Std.string(fast.node.value)));
		}
		
		callbackhandler(result, response);
	}

	/**
	 * Loads a level ranged metric's data for a level on a date or all time
	 * @param	metric		The name of your metric
	 * @param	level		The level number (integer) or name (string)
	 * @param	callbackhandler	Your function to receive the data:  callbackhandler(data:Dynamic, response:Response);
	 * @param	options		Dynamic with day, month, year properties or null for all time
	 */
	public static function LevelRangedMetric(metric:String, level:Dynamic, callbackhandler:Void->Void, options:Dynamic):Void
	{
		LevelMetric(LEVELRANGEDMETRIC, metric, level.toStd.string(), LevelRangedMetricComplete, callbackhandler, options);
	}
	
	/**
	 * Processes the response received from the server, returns the data and response to the user's callbackhandler
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	postdata	The data that was posted
	 * @param	data		The XML returned from the server
	 * @param	response	The response from the server
	 */
	private static function LevelRangedMetricComplete(callbackhandler:Dynamic->Dynamic->Void, postdata : Hash<String>, data:Xml = null, response:Response = null):Void
	{
		if(callbackhandler == null)
			return;
			
		var result = {};
									
		if(response.Success)
		{
			var fast = new haxe.xml.Fast(data.firstElement());

			Reflect.setField(result, "Name", "LevelRangedMetric");
			Reflect.setField(result, "Metric", postdata.get("metric"));
			Reflect.setField(result, "Level", postdata.get("level"));
			Reflect.setField(result, "Day", postdata.get("day"));
			Reflect.setField(result, "Month", postdata.get("month"));
			Reflect.setField(result, "Year", postdata.get("year"));

			var values:Array<Dynamic> = new Array<Dynamic>();

			for(n in fast.nodes.value)
			{
				/*
        var value:Dynamic;
				value.TrackValue = Std.parseInt(Std.string(n.att.trackvalue));
				value.Value = Std.parseInt(Std.string(n.innerData));
        */
				values.push({TrackValue:Std.parseInt(Std.string(n.att.trackvalue)), Value:Std.parseInt(Std.string(n.innerData))});
			}

			Reflect.setField(result, "Values", values);
		}
		
		callbackhandler(result, response);
	}
	
	/**
	 * Loads a level average metric's data for a level on a date or all time
	 * @param	metric		The name of your metric
	 * @param	level		The level number (integer) or name (string)
	 * @param	callbackhandler	Your function to receive the data:  callbackhandler(data:Dynamic, response:Response);
	 * @param	options		Dynamic with day, month, year properties or null for all time
	 */
	public static function LevelAverageMetric(metric:String, level:Dynamic, callbackhandler:Void->Void, options:Dynamic):Void
	{
		LevelMetric(LEVELAVERAGEMETRIC, metric, level.toStd.string(), LevelAverageMetricComplete, callbackhandler, options);
	}
	
	/**
	 * Processes the response received from the server, returns the data and response to the user's callbackhandler
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	postdata	The data that was posted
	 * @param	data		The XML returned from the server
	 * @param	response	The response from the server
	 */
	private static function LevelAverageMetricComplete(callbackhandler:Dynamic->Dynamic->Void, postdata : Hash<String>, data:Xml = null, response:Response = null):Void
	{
		if(callbackhandler == null)
			return;
			
		var result = {};
									
		if(response.Success)
		{
			var fast = new haxe.xml.Fast(data.firstElement());

			Reflect.setField(result, "Name", "LevelAverageMetric");
			Reflect.setField(result, "Metric", postdata.get("metric"));
			Reflect.setField(result, "Level", postdata.get("level"));
			Reflect.setField(result, "Day", postdata.get("day"));
			Reflect.setField(result, "Month", postdata.get("month"));
			Reflect.setField(result, "Year", postdata.get("year"));
			Reflect.setField(result, "Min", Std.parseInt(Std.string(fast.node.min)));
			Reflect.setField(result, "Max", Std.parseInt(Std.string(fast.node.max)));
			Reflect.setField(result, "Average", Std.parseInt(Std.string(fast.node.average)));
			Reflect.setField(result, "Total", Std.parseInt(Std.string(fast.node.total)));
		}
		
		callbackhandler(result, response);
	}
	
	/**
	 * Passes a level metric request on
	 * @param	action		The action on the server
	 * @param	metric		The metric
	 * @param	level		The level number or name as a string
	 * @param	complete	The complete handler
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	options		Dynamic with day, month, year properties or null for all time
	 */
	private static function LevelMetric(action:String, metric:String, level:String, complete:Dynamic->Dynamic->Dynamic->Dynamic->Void, callbackhandler:Void->Void, options:Dynamic):Void
	{
		var postdata = new Hash<String>();
		postdata.set("metric", metric);
		postdata.set("level", level);
		postdata.set("day", Reflect.hasField(options, "day") ? Reflect.field(options, "day") : "0");
		postdata.set("month", Reflect.hasField(options, "month") ? Reflect.field(options, "month") : "0");
		postdata.set("year", Reflect.hasField(options, "year") ? Reflect.field(options, "year") : "0");
		
		Request.Load(SECTION, action, complete, callbackhandler, postdata);
	}
}