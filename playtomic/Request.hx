﻿// -------------------------------------------------------------------------
//  This file is part of the official Playtomic API for HaXe games.  
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
import haxe.Timer;

//#if flash
import nme.net.URLLoader;
import nme.net.URLRequest;
import nme.net.URLVariables;
import nme.events.Event;
import nme.utils.ByteArray;
//#else
//import hax.remoting;
//#end

class Request extends URLLoader
{
	private static var Pool:Array<Request>;
	private static var Queue:Array<Request>;
	private static var URLStub:String;
	private static var URLTail:String;
	private static var URL:String;
	
	private var urlRequest:URLRequest;
	private var completeHandler:Dynamic->Dynamic->Dynamic->Dynamic->Void;
	private var callbackHandler:Void->Void;
	private var handled:Bool;
	private var logging:Bool;
	private var postdata:Dynamic<String>;
	private var time:Int;

	public function new()
	{
		super();
    
    //#if flash
		urlRequest = new URLRequest();
		/*addEventListener("ioError", Fail);
		addEventListener("networkError", Fail);
		addEventListener("verifyError", Fail);
		addEventListener("diskError", Fail);
		addEventListener("securityError", Fail);
		addEventListener("httpStatus", HTTPStatusIgnore);
		addEventListener("complete", Complete);*/
	//	#end
	}

	public static function Initialise():Void
	{
		//trace("*** WARNING .DEV URL IS ON ***");
		Pool = new Array<Request>();
		Queue = new Array<Request>();
		URLStub = "http://g" + Log.GUID + ".api.playtomic.com";
		URLTail = "swfid=" + Log.SWFID;
		URL = URLStub + "/v3/api.aspx?" + URLTail;
					
		
    // karg: portable Timer doesnt have these methods
		//var reqtimer:Timer = new Timer(500);
    //reqtimer.addEventListener("timer", TimeoutHandler);
		//reqtimer.start();

    var reqtimer = Timer.delay(TimeoutHandler, 500);
    reqtimer.run();
		
		for(i in 0...20)
			Pool.push(new Request());
	}
	
	public static function SendStatistics(completeHandler:Dynamic->Dynamic->Dynamic->Dynamic->Void, url:String):Void {
		var request:Request = Pool.length > 0 ? Pool.pop() : new Request();
		request.time = 0;
		request.handled = false;
		request.completeHandler = completeHandler;
		request.callbackHandler = null;
		request.logging = true;
        request.urlRequest = new URLRequest( URLStub + url + (url.indexOf("?") > -1 ? "&" : "?") + URLTail + "&" + Math.random() + "Z" );
		request.urlRequest.method = "GET";
		request.urlRequest.data = null;
		request.postdata = null;
		request.load(request.urlRequest);
		Queue.push(request);
	}
	
  // karg: changed Dynamic postdata to Hash<String>
	public static function Load(section:String, action:String, complete:Dynamic->Dynamic->Dynamic->Dynamic->Void, callbackhandler:Void->Void, ?postdata:Hash<String>):Void
	{
		//trace("Request.Load " + section + " " + action);
		var request:Request = Pool.length > 0 ? Pool.pop() : new Request();
		request.time = 0;
		request.handled = false;
		request.completeHandler = complete;
		request.callbackHandler = callbackhandler;
		request.logging = false;

		var url:String = URL + "&r=" + Math.random() + "Z";
		
    // karg: haxe Date has different interface
    //var timestamp:String = Std.string(new Date().time).substr(0, 10);
		//var nonce:String = Md5.encode(new Date().time * Math.random() + Log.GUID);
    var timestamp:String = Std.string(Date.now().getTime()).substr(0, 10);
		var nonce:String = Md5.encode(Date.now().getTime() * Math.random() + Log.GUID);
				
		//trace(url);
		
		var pd:Array<String> = new Array<String>();
		pd.push("nonce=" + nonce);
		pd.push("timestamp=" + timestamp);
		
		// karg: changed Dynamic postdata to Hash<String>
    for(key in postdata.keys())
			pd.push(key + "=" + Escape(postdata.get(key)));
			
		// karg: this one is not in the latest as3 version
    //pd.sort();
			
		//trace("\npresig: " + pd.join("&"));
			
		GenerateKey("section", section, pd);
		GenerateKey("action", action, pd);
		GenerateKey("signature", nonce + timestamp + section + action + url + Log.GUID, pd);
		
		
		
		//trace("\nposting\n" + pd.join("\n"));
		
		var pda:ByteArray = new ByteArray();
		pda.writeUTFBytes(pd.join("&"));
		pda.position = 0;
		
		var postvars:URLVariables = new URLVariables();
		
    // karg: doesnt work this way in HaXe
    //postvars["data"] = Escape(Encode.Base64(pda));
    postvars.data = Escape(Encode.Base64(pda));
		
		request.urlRequest = new URLRequest( url );
		request.urlRequest.method = "POST";
		request.urlRequest.data = postvars;
		
		//trace("posting data to " + url);

		
		try
		{
			request.load(request.urlRequest);
		}
		catch(s:Dynamic)
		{
			//trace("failed")
			request.completeHandler(request.callbackHandler, request.postdata, null, new Response(0, 1));
		}
		
		Queue.push(request);
	}
	
	public static function Escape(str:String):String
	{
		if(str == null)
			return "";
		
		str = str.split("%").join("%25");
		str = str.split(";").join("%3B");
		str = str.split("?").join("%3F");
		str = str.split("/").join("%2F");
		str = str.split(":").join("%3A");
		str = str.split("#").join("%23");
		str = str.split("&").join("%26");
		str = str.split("=").join("%3D");
		str = str.split("+").join("%2B");
		str = str.split("$").join("%24");
		str = str.split(",").join("%2C");
		str = str.split(" ").join("%20");
		str = str.split("<").join("%3C");
		str = str.split(">").join("%3E");
		str = str.split("~").join("%7E");
		return str;
	}
	
	private static function GenerateKey(name:String, key:String, arr:Array<String>):Void
	{
		arr.sort(sortCallback);

		//if(name == "section")
		//	//trace("joined is " + arr.join("&"));
			
		arr.push(name + "=" + Md5.encode(arr.join("&") + key));
	}

  private static inline function sortCallback(a : String, b : String)
  {
    if (a == b)
    {
      return 0;
    }

    if (a > b)
    {
      return 1;
    }
    else
    {
      return -1;
    }
  }

	// karg: portable version of Timer requires no arguments for the callback
  //private static function TimeoutHandler(e:Event):Void
	private static function TimeoutHandler():Void
	{
		var request:Request;
		var remove:Array<Request> = new Array<Request>();

		for(n in 0...Queue.length-1)
		{
			request = Queue[n];

      // karg: extra-check, should not ever happen :)
      if (request == null)
      {
        trace("request in Queue is null");
        continue;
      }

			if(!request.handled)
			{
				request.time++;

				if(request.time < 40)
					continue;
					
				if(request.logging)
        {
					// karg: calling a handler with different number and types of arguments is a quite a design flaw :)
          //request.completeHandler(false);
          Reflect.callMethod(request, "completeHandler", [false]);
        }
				else
					request.completeHandler(request.callbackHandler, request.postdata, null, new Response(0, 3));
			}

			remove.push(request);
		}

		for(req in remove)
		{
			// karg: :)
      //Queue.splice(Queue.indexOf(req), 1);
      Queue.remove(req);

			Dispose(req);
		}
	}
		
	private static function Complete(e:Event):Void
	{
		var request:Request = cast e.target;// as Request;

		if(request.handled)
			return;
			
		request.handled = true;
		
		/*if ( request.logging ) {
            // karg: calling a handler with different number and types of arguments is a quite a design flaw :)
            //request.completeHandler(true);
            if ( Reflect.isFunction( request.completeHandler ) ) {
                Reflect.callMethod(request, "completeHandler", [true]);
            }
			return;
		}*/
		
		//trace(Request.data);
		
		//var data:Xml = Xml.parse(request.data);
		
    // karg: haxe Xml works a bit different
    //var status:Int = Std.parseInt(data["status"]);
		//var errorcode:Int = Std.parseInt(data["errorcode"]);

    // karg: we should also be defensive and check if data xml actually has those attributes
    //var status:Int = data.exists("status") ? Std.parseInt(data.get("status")) : -1;
	//	var errorcode:Int = data.exists("errorcode") ? Std.parseInt(data.get("errorcode")) : -1;
		
    //request.completeHandler(request.callbackHandler, request.postdata, data, new Response(status, errorcode));
	}
	
	#if flash
	private static function Fail(e:Event):Void
	{
			//trace("fail");
			var request:Request = cast e.target;
			//trace(request.data);
			
			if(request.handled)
				return;
				
			request.handled = true;
			
			if(request.completeHandler == null)
				return;
			
			if(request.logging)
      {
  			// karg: calling a handler with different number and types of arguments is a quite a design flaw :)
        //request.completeHandler(false);
        Reflect.callMethod(request, "completeHandler", [false]);
      }
			else
				request.completeHandler(request.callbackHandler, request.postdata, null, new Response(0, 1));		    
	}

	private static function HTTPStatusIgnore(e:Event):Void
	{
	}
	#else
	private static function Fail():Void { }
	private static function HTTPStatusIgnore():Void { }
	#end
	
	private static function Dispose(request:Request):Void
	{
		if(!request.handled)
		{
			request.handled = true;
			request.close();
		}

		Pool.push(request);
	}		
}