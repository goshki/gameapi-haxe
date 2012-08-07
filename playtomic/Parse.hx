﻿//  Parse.com bridge for Playtomic Flash users
// -------------------------------------------------------------------------
//  Note:  This requires a Playtomic.com account AND a Parse.com account,
//  you will have to register at Parse and configure the settings in your
//  Playtomic dashboard.
//
//  http://parse.com/
//
//  If you are using Objective C or Android you should use the official
//  Parse SDKs available directly through Parse.com.
//
//
// -------------------------------------------------------------------------
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

class Parse 
{
	private static var SECTION:String;
	private static var SAVE:String;
	private static var DELETE:String;
	private static var LOAD:String;
	private static var FIND:String;
	
	public static function Initialise(apikey:String):Void
	{
		SECTION = Md5.encode("parse-" + apikey);
		SAVE = Md5.encode("parse-save-" + apikey);
		DELETE = Md5.encode("parse-delete-" + apikey);
		LOAD = Md5.encode("parse-load-" + apikey);
		FIND = Md5.encode("parse-find-" + apikey);
	}
			
	/**
	 * Creates or updates an object in your Parse.com database
	 * @param	pobject		A ParseObject, if it has an objectId it will update otherwise save
	 * @param	callbackhandler	Callback function to receive the data:  function(pobject:ParseObject, response:Response)
	 */
	public static function Save(pobject:PFObject, callbackhandler:Void->Void = null):Void
	{
		Request.Load(SECTION, SAVE, SaveComplete, callbackhandler, ObjectPostData(pobject));
	}
	
	/**
	 * Processes the response received from the server, returns the data and response to the user's callbackhandler
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	postdata	The data that was posted
	 * @param	data		The XML returned from the server
	 * @param	response	The response from the server
	 */
	private static function SaveComplete(callbackhandler:Dynamic->Dynamic->Void, postdata:Hash<String>, ?data:Xml, ?response:Response):Void
	{
		if(callbackhandler == null)
			return;
			
		var fast = new haxe.xml.Fast(data.firstElement());

		var pobject:PFObject = new PFObject();
		pobject.ObjectId = Std.string(fast.node.id);
		pobject.ClassName = postdata.get("classname");
		pobject.Password = postdata.get("password");
					
		for(key in postdata.keys())
		{
			if(key.indexOf("data") == 0)
			{					
				pobject.Data.set(key.substr(4), postdata.get("key"));
			}
			
			// karg: this code doesn't seem to exists in as3 v3.46
      /*
      if(key.indexOf("pointer") == 0 && key.indexOf("fieldname") > -1)
			{
				var s:String = key.substr(7);
				s = s.substr(0, s.indexOf("fieldname"));
				
				var fieldname:String = postdata.getField("pointer" + s + "fieldname");

				var pointerobj:PFObject = new PFObject();
				pointerobj.ClassName = postdata.getField("pointer" + s + "classname");
				pointerobj.ObjectId = postdata.getField("pointer" + s + "id");
				pobject.Pointers.push(new PFPointer(fieldname, pointerobj));
			}
      */
		}
		
		if(response.Success)
		{
			pobject.CreatedAt = DateParse(Std.string(fast.node.created));
			pobject.UpdatedAt = DateParse(Std.string(fast.node.updated));
		}
		
		callbackhandler(pobject, response);
	}
	
	/**
	 * Deletes an object in your Parse.com database
	 * @param	pobject		A ParseObject that must include the ObjectId
	 * @param	callbackhandler	Callback function to receive the data:  function(response:Response)
	 */
	public static function Delete(pobject:PFObject, callbackhandler:Void->Void = null):Void
	{
		Request.Load(SECTION, DELETE, DeleteComplete, callbackhandler, ObjectPostData(pobject));
	}
	
	/**
	 * Processes the response received from the server, returns the data and response to the user's callbackhandler
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	postdata	The data that was posted
	 * @param	data		The XML returned from the server
	 * @param	response	The response from the server
	 */
	private static function DeleteComplete(callbackhandler:Dynamic->Void, postdata:Hash<String>, data:Xml = null, response:Response = null):Void
	{
		if(callbackhandler == null)
			return;

		callbackhandler(response);	
	}
	
	/**
	 * Loads a specific object from your Parse.com database
	 * @param	pobject		A ParseObject that must include the ObjectId and className
	 * @param	callbackhandler	Callback function to receive the data:  function(pobject:ParseObject, response:Response)
	 */
	public static function Load(pobjectid:String, classname:String, callbackhandler:Void->Void = null):Void
	{
		var pobject:PFObject = new PFObject();
		pobject.ObjectId = pobjectid;
		pobject.ClassName = classname;
		
		Request.Load(SECTION, LOAD, LoadComplete, callbackhandler, ObjectPostData(pobject));
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
			
		var pobject:PFObject = new PFObject();
		pobject.ObjectId = postdata.get("objectid");
		pobject.ClassName = postdata.get("classname");

		var fast = new haxe.xml.Fast(data.firstElement());
			
		if(response.Success)
		{
			pobject.CreatedAt = DateParse(Std.string(fast.att.created));
			pobject.UpdatedAt = DateParse(Std.string(fast.att.updated));
			
			if(fast.hasNode.fields)
			{			
				var fields = fast.nodes.fields;
        
        for(field in fields)
				{
					Reflect.setField(pobject, field.att.name, field.att.innerText);
				}
			}
			
			if(fast.hasNode.pointers)
			{		
				var pointers = fast.nodes.pointers;
        
        for(pointer in pointers)
				{
					var pfieldname:String = pointer.att.fieldname;
					
					var pchild:PFObject = new PFObject();
					pchild.ClassName = pointer.att.classname;
					pchild.ObjectId = pointer.att.id;
					
					pobject.Pointers.push(new PFPointer(pfieldname, pchild));
				}
			}
		}
		
		callbackhandler(pobject, response);
	}
	
	/**
	 * Finds objects matching the criteria in your ParseQuery
	 * @param	pquery		A ParseQuery object
	 * @param	callbackhandler	Callback function to receive the data:  function(objects:Array, response:Response)
	 */
	public static function Find(pquery:PFQuery, callbackhandler:Void->Void = null):Void
	{
		var postdata = new Hash<String>();
		postdata.set("classname", pquery.ClassName);
		postdata.set("limit", Std.string(pquery.Limit));
		postdata.set("order", pquery.Order != null && pquery.Order != "" ? pquery.Order : "created_at");
		
		for(key in pquery.WhereData.keys())
		{
			//Reflect.setField(postdata, "data" + key, Reflect.field(pquery.WhereData, key));
      postdata.set("data" + key, pquery.WhereData.get(key));
		}
		
		for(i in 0...(pquery.WherePointers.length-1))
		{
			//Reflect.setField(postdata, "pointer" + i + "fieldname", pquery.WherePointers[i].FieldName);
			//Reflect.setField(postdata, "pointer" + i + "classname", pquery.WherePointers[i].PObject.ClassName);
			//Reflect.setField(postdata, "pointer" + i + "id", pquery.WherePointers[i].PObject.ObjectId);
      postdata.set("pointer" + i + "fieldname", pquery.WherePointers[i].FieldName);
      postdata.set("pointer" + i + "classname", pquery.WherePointers[i].PObject.ClassName);
      postdata.set("pointer" + i + "id", pquery.WherePointers[i].PObject.ObjectId);
		}

		Request.Load(SECTION, FIND, FindComplete, callbackhandler, postdata);
	}
	
	/**
	 * Processes the response received from the server, returns the data and response to the user's callbackhandler
	 * @param	callbackhandler	The user's callbackhandler function
	 * @param	postdata	The data that was posted
	 * @param	data		The XML returned from the server
	 * @param	response	The response from the server
	 */
	private static function FindComplete(callbackhandler:Dynamic->Dynamic->Void, postdata:Hash<String>, data:Xml = null, response:Response = null):Void
	{
		if(callbackhandler == null)
			return;
			
		var objs:Array<PFObject> = new Array<PFObject>();
		
		if(response.Success)
		{
			var fast = new haxe.xml.Fast(data.firstElement());
			
			for(object in fast.nodes.objects)
			{				
				var pobject:PFObject = new PFObject();
				pobject.ObjectId = object.att.id;
				pobject.CreatedAt = DateParse(object.att.created);
				pobject.UpdatedAt = DateParse(object.att.updated);
				
				if(object.hasNode.fields)
				{				
					var fields = object.nodes.fields;
          
          for(field in fields)
					{
						Reflect.setField(pobject, field.att.name, field.att.innerText);
					}
				}
				
				// karg: xml fix
        //if(object.contains("pointers"))
        if (object.hasNode.pointers)
				{
					//var pointers:XMLList = object["pointers"];
          var pointers = object.nodes.pointers;
					
					//for(pointer in pointers.children())
          for(pointer in pointers)
					{
						var pfieldname:String = pointer.att.fieldname;
						
						var pchild:PFObject = new PFObject();
						pchild.ClassName = pointer.att.classname;
						pchild.ObjectId = pointer.att.id;
						
						pobject.Pointers.push(new PFPointer(pfieldname, pchild));
					}
				}
				
				objs.push(pobject);
			}
		}
		
		callbackhandler(objs, response);
		
	}
		
	/**
	 * Turns a ParseObject into data to be POST'd for saving, finding 
	 * @param	pobject		The ParseObject
	 */	
	private static function ObjectPostData(pobject:PFObject):Hash<String>
	{
		var postobject = new Hash<String>();

		postobject.set("classname", pobject.ClassName);
		postobject.set("id", (pobject.ObjectId == null ? "" : pobject.ObjectId));
		postobject.set("password", (pobject.Password == null ? "" : pobject.Password));
		
		for(key in pobject.Data)
    {
			//Reflect.setField(postobject, "data" + key, Reflect.field(pobject.Data, key));
      postobject.set("data" + key, Reflect.field(pobject.Data, key));
    }
			
		for(i in 0...pobject.Pointers.length-1)
		{
			postobject.set("pointer" + i + "fieldname", pobject.Pointers[i].FieldName);
			postobject.set("pointer" + i + "classname", pobject.Pointers[i].PObject.ClassName);
			postobject.set("pointer" + i + "id", pobject.Pointers[i].PObject.ObjectId);
      
      //Reflect.setField(postobject, "pointer" + i + "fieldname", pobject.Pointers[i].FieldName);
			//Reflect.setField(postobject, "pointer" + i + "classname", pobject.Pointers[i].PObject.ClassName);
			//Reflect.setField(postobject, "pointer" + i + "id", pobject.Pointers[i].PObject.ObjectId);
		}
		
		return postobject;
	}
	
	/**
	 * Converts the server's MM/dd/yyyy hh:mm:ss into a Flash Date
	 * @param	date		The date from the XML
	 */	
	private static function DateParse(date:String):Date
	{
		var parts:Array<String> = date.split(" ");
		    
    // karg: parts[i] is of String type :)
    //var dateparts:Array<String> = (parts[0].toStd.string()).split("/");
		//var timeparts:Array<String> = (parts[1].toStd.string()).split(":");
    var dateparts:Array<String> = parts[0].split("/");
		var timeparts:Array<String> = parts[1].split(":");

		var day:Int = Std.parseInt(dateparts[1]);
		var month:Int = Std.parseInt(dateparts[0]);
		var year:Int = Std.parseInt(dateparts[2]);
		var hours:Int = Std.parseInt(timeparts[0]);
		var minutes:Int = Std.parseInt(timeparts[1]);
		var seconds:Int = Std.parseInt(timeparts[2]);

		// karg: this seems redundant
    //return new Date(Date.UTC(year, month, day, hours, minutes, seconds));
    return new Date(year, month, day, hours, minutes, seconds);
	}
}