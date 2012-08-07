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

class GameVars
{
	private static var SECTION:String;
	private static var LOAD:String;
	
	public static function Initialise(apikey:String):Void
	{
		SECTION = Md5.encode("gamevars-" + apikey);
		LOAD = Md5.encode("gamevars-load-" + apikey);
	}
	
	/**
	 * Loads your GameVars 
	 * @param	callbackhandler	Your function to receive the data:  callbackhandler(gamevars:Dynamic, response:Response);
	 */
	public static function Load(callbackhandler:Void->Void):Void
	{
		Request.Load(SECTION, LOAD, LoadComplete, callbackhandler, null);
	}
	
	/**
	 * Processes the response received from the server, returns the data and response to the user's callbackhandler
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	postdata	The data that was posted
	 * @param	data		The XML returned from the server
	 * @param	status		The request status returned from the esrver (1 for success)
	 * @param	errorcode	The errorcode returned from the server (0 for none)
	 */
	private static function LoadComplete(callbackhandler:Dynamic->Dynamic->Void, postdata:Hash<String>, data:Xml = null, response:Response = null):Void
	{
		if(callbackhandler == null)
			return;
			
		var result = {};

		if(response.Success)
		{
			var fast = new haxe.xml.Fast(data.firstElement());
			var name:String;
			var value:String;

			for(item in fast.nodes.gamevar) 
			{
				name = Std.string(item.node.name);
				value = Std.string(item.node.value);
				Reflect.setField(result, name, value);
			}
		}

		callbackhandler(result, response);
	}
}