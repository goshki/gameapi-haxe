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

#if flash
import flash.display.Loader;
#end

class PlayerLevel
{
	public function new() 
	{ 
		// karg: haxe Date has different interface
    //SDate = new Date();
    SDate = Date.now();
		RDate = "Just now";
		PlayerSource = "";
		PlayerId = "";
		PlayerName = "";
    CustomData = new Hash();
	}

	public var LevelId:String;
	public var PlayerSource:String;
	public var PlayerId:String;
	public var PlayerName:String;
	public var Permalink:String;
	public var Name:String;
	public var Data:String;
	#if Flash
	public var Thumb:Loader;
	#else
	public var Thumb:Dynamic;
	#end
	public var Votes:Int;
	public var Starts:Int;
	public var Quits:Int;
	public var Retries:Int;
	public var Flags:Int;
	public var Wins:Int;
	public var Rating:Float;
	public var Score:Int;
	public var SDate:Date;
	public var RDate:String;

  // karg: previously Dynamic, now Hash<String>; safety first! :)
	//public var CustomData:Dynamic;
  public var CustomData : Hash<String>;
	
	#if flash
	public function SetThumb(thumbdata:String):Void
	{
		if(thumbdata == null || thumbdata == "")
			return;

		Thumb = new Loader();
		Thumb.loadBytes(Encode.Base64Decode(thumbdata));
	}

	public function Thumbnail():String
	{
		return "http://g" + Log.GUID + ".api.playtomic.com/playerlevels/thumb.aspx?swfid=" + Log.SWFID + "&levelid=" + this.LevelId;
	}
	#else
	public function SetThumb(thubmdata:string):Void
	{
	}

	public function Thumbnail():String
	{
		return "";
	}
	#end
}