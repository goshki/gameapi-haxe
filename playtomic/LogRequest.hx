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

class LogRequest
{
	private static var Pool:Array<LogRequest> = new Array<LogRequest>();
	
	private var _data:String;
	private var _hasView:Bool;
	private var _hasPlay:Bool;
	public var ready:Bool;

	public function new()
	{
		_data = "";
		_hasView = false;
		_hasPlay = false;
		ready = false;
	}

	/**
	 * Creates a log request or re-uses an old one from the pool
	 */
	public static function Create():LogRequest
	{
		var request:LogRequest = Pool.length > 0 ? Pool.pop() : new LogRequest();
		request._data = "";
		request._hasView = false;
		request._hasPlay = false;
		request.ready = false;
		
		return request;
	}
	
	/**
	 * Adds queued events to the data
	 */
	public function MassQueue(data:Array<String>):Void
	{
		while(data.length > 0)
		{
			Queue(data.pop());

			if(ready)
			{
				Send();	
				
				var request:LogRequest = Create();
				request.MassQueue(data);
				return;
			}
		}
		
		Log.LogQueue = this;
	}		

	/**
	 * Queues a single event
	 */
	public function Queue(data:String):Void
	{
		_data += (_data == "" ? "" : "~") + data;
		
		if(_data.indexOf("v/") == 0)
			_hasView = true;
			
		if(_data.indexOf("p/") == 0)
			_hasPlay = true;

		if(_data.length > 300)
		{
			ready = true;
		}
	}

	/**
	 * Sends the data 
	 */
	public function Send():Void
	{
		if(_data == "")
			return;
			
		playtomic.Request.SendStatistics(Complete, "/tracker/q.aspx?q=" + _data + "&url=" + (_hasView ? Log.SourceUrl : Log.BaseUrl));
	}
	
	/**
	 * Increases views/plays counter if successful and stores the request for re-use
   * karg: Added additional parameters to compile, but using callback with variable parameter count is wrong :)
	 */
	private function Complete(success:Bool, dummy1 : Int, dummy2 : Int, dummy3 : Int):Void
	{
		if(success)
		{
			if(_hasView)
				Log.IncreaseViews();

			if(_hasPlay)
				Log.IncreasePlays();
		}

		Pool.push(this);
	}
}