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

class GeoIP
{
	private static var SECTION:String;
	private static var LOAD:String;
	
	public static function Initialise(apikey:String):Void
	{
		SECTION = Md5.encode("geoip-" + apikey);
		LOAD = Md5.encode("geoip-lookup-" + apikey);
	}
	
	/**
	 * Performs a country lookup on the player IP address
	 * @param	callbackhandler	Your function to receive the data:  callbackhandler(data:Dynamic, response:Response);
	 * @param	view	If it's a view or not
	 */
	public static function Lookup(callbackhandler:Void->Void):Void
	{
		Request.Load(SECTION, LOAD, LookupComplete, callbackhandler);
	}	
	
	/**
	 * Processes the response received from the server, returns the data and response to the user's callbackhandler
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	postdata	The data that was posted
	 * @param	data		The XML returned from the server
	 * @param	status		The request status returned from the esrver (1 for success)
	 * @param	errorcode	The errorcode returned from the server (0 for none)
	 */
	private static function LookupComplete(callbackhandler:Dynamic->Dynamic->Void, postdata:Hash<String>, data:Xml = null, response:Response = null):Void
	{
		if(callbackhandler == null)
			return;
			
		var result = {Code:"", Name:""};

		if(response.Success)
		{	
			var fast = new haxe.xml.Fast(data.firstElement());
			Reflect.setField(result, "Code", Std.string(fast.node.code));
			Reflect.setField(result, "Name", Std.string(fast.node.name));
		}
		else
		{
			result.Code = "N/A";
			result.Name = "UNKNOWN";
		}
		
		callbackhandler(result, response);
	}
}