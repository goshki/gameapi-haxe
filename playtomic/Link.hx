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

class Link
{
	private static var Clicks:Array = new Array();

	/**
	 * Attempts to open a URL, tracking the unique/total/failed clicks the user experiences.
	 * @param	url			The url to open
	 * @param	name		A name for the URL (eg splashscreen)
	 * @param	group		The group for the reports (eg sponsor links)
	 * @param	options		Dynamic with day, month, year properties or null for all time
	 */
	public static function Open(url:String, name:String, group:String):Bool
	{
		var unique:Int = 0;
		var bunique:Int = 0;
		var total:Int = 0;
		var btotal:Int = 0;
		var fail:Int = 0;
		var bfail:Int = 0;
		var key:String = url + "." + name;
		var result:Bool;

		var baseurl:String = url;
		baseurl = baseurl.replace("http://", ");
		
		if(baseurl.indexOf("/") > -1)
			baseurl = baseurl.substr(0, baseurl.indexOf("/"));
			
		if(baseurl.indexOf("?") > -1)
			baseurl = baseurl.substr(0, baseurl.indexOf("?"));				
			
		baseurl = "http://" + baseurl + "/";

		var baseurlname:String = baseurl;
		
		if(baseurlname.indexOf("//") > -1)
			baseurlname = baseurlname.substr(baseurlname.indexOf("//") + 2);
		
		baseurlname = baseurlname.replace("www.", ");

		if(baseurlname.indexOf("/") > -1)
		{
			baseurlname = baseurlname.substr(0, baseurlname.indexOf("/"));
		}

		try
		{
			navigateToURL(new URLRequest(url));

			if(Clicks.indexOf(key) > -1)
			{
				total = 1;
			}
			else
			{
				total = 1;
				unique = 1;
				Clicks.push(key);
			}

			if(Clicks.indexOf(baseurlname) > -1)
			{
				btotal = 1;
			}
			else
			{
				btotal = 1;
				bunique = 1;
				Clicks.push(baseurlname);
			}

			result = true;
		}
		catch(err:Error)
		{
			fail = 1;
			bfail = 1;
			result = false;
		}
					
		Log.Link(baseurl, baseurlname.toLowerCase(), "DomainTotals", bunique, btotal, bfail);
		Log.Link(url, name, group, unique, total, fail);
		Log.ForceSend();

		return result;
	}
}