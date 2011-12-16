﻿//  This file is part of the official Playtomic API for HaXe games.  //  Playtomic is a real time analytics platform for casual games //  and services that go in casual games.  If you haven't used it //  before check it out://  http://playtomic.com/////  Created by ben at the above domain on 10/5/11.//  Copyright 2011 Playtomic LLC. All rights reserved.////  Documentation is available at://  http://playtomic.com/api/haxe//// PLEASE NOTE:// You may modify this SDK if you wish but be kind to our servers.  Be// careful about modifying the analytics stuff as it may give you // borked reports.//// If you make any awesome improvements feel free to let us know!//// -------------------------------------------------------------------------// THIS SOFTWARE IS PROVIDED BY PLAYTOMIC, LLC "AS IS" AND ANY// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.package playtomic;#if flashimport flash.utils.ByteArray;import flash.display.BitmapData;#end // flashclass Encode{		// ----------------------------------------------------------------------------	// Base64 encoding	// ----------------------------------------------------------------------------	// http://dynamicflash.com/goodies/base64/	//	// Copyright (c) 2006 Steve Webster	// Permission is hereby granted, free of charge, to any person obtaining a copy of	// this software and associated documentation files (the "Software"), to deal in	// the Software without restriction, including without limitation the rights to	// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of	// the Software, and to permit persons to whom the Software is furnished to do so,	// subject to the following conditions: 	// The above copyright notice and this permission notice shall be included in all	// copies or substantial portions of the Software.	private static var BASE64_CHARS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";	public static function Base64(data:ByteArray):String 	{		var output:String = "";		var dataBuffer:Array<Int>;		var outputBuffer = new Array<Int>(/*4*/);		var i:UInt;		var j:UInt;		var k:UInt;    // karg: 4 elements in outputBuffer    for(i in 0...4)    {      outputBuffer.push(0);    }				data.position = 0;				while (data.bytesAvailable > 0) 		{			dataBuffer = new Array();						for(i in 0...3) 			{				if(data.bytesAvailable == 0)					break;				dataBuffer[i] = data.readUnsignedByte();			}						outputBuffer[0] = (dataBuffer[0] & 0xfc) >> 2;			outputBuffer[1] = ((dataBuffer[0] & 0x03) << 4) | ((dataBuffer[1]) >> 4);			outputBuffer[2] = ((dataBuffer[1] & 0x0f) << 2) | ((dataBuffer[2]) >> 6);			outputBuffer[3] = dataBuffer[2] & 0x3f;						// karg: backward iterator fun :)      for(j in dataBuffer.length...3)				outputBuffer[j + 1] = 64;						for (k in 0...outputBuffer.length-1)				output += BASE64_CHARS.charAt(outputBuffer[k]);		}				return output;	}		// BASE 64 decoding via http://www.foxarc.com/blog/article/60.htm	private static var decodeChars:Array<Int> =        [-1, -1, -1, -1, -1, -1, -1, -1,       -1, -1, -1, -1, -1, -1, -1, -1,       -1, -1, -1, -1, -1, -1, -1, -1,       -1, -1, -1, -1, -1, -1, -1, -1,       -1, -1, -1, -1, -1, -1, -1, -1,       -1, -1, -1, 62, -1, -1, -1, 63,       52, 53, 54, 55, 56, 57, 58, 59,       60, 61, -1, -1, -1, -1, -1, -1,       -1,  0,  1,  2,  3,  4,  5,  6,        7,  8,  9, 10, 11, 12, 13, 14,       15, 16, 17, 18, 19, 20, 21, 22,       23, 24, 25, -1, -1, -1, -1, -1,       -1, 26, 27, 28, 29, 30, 31, 32,       33, 34, 35, 36, 37, 38, 39, 40,       41, 42, 43, 44, 45, 46, 47, 48,       49, 50, 51, -1, -1, -1, -1, -1];   		public static function Base64Decode(str:String):ByteArray 	{           var c1:Int;           var c2:Int;           var c3:Int;           var c4:Int;           var i:Int;           var len:Int;           var out:ByteArray;           len = str.length;           i = 0;           out = new ByteArray();           while (i < len) {               // c1               do {                   c1 = decodeChars[str.charCodeAt(i++) & 0xff];               } while (i < len && c1 == -1);               if (c1 == -1) {                   break;               }               // c2                   do {                   c2 = decodeChars[str.charCodeAt(i++) & 0xff];               } while (i < len && c2 == -1);               if (c2 == -1) {                   break;               }               out.writeByte((c1 << 2) | ((c2 & 0x30) >> 4));               // c3               do {                   c3 = str.charCodeAt(i++) & 0xff;                   if (c3 == 61) {                       return out;                   }                   c3 = decodeChars[c3];               } while (i < len && c3 == -1);               if (c3 == -1) {                   break;               }               out.writeByte(((c2 & 0x0f) << 4) | ((c3 & 0x3c) >> 2));               // c4               do {                   c4 = str.charCodeAt(i++) & 0xff;                   if (c4 == 61) {                       return out;                   }                   c4 = decodeChars[c4];               } while (i < len && c4 == -1);               if (c4 == -1) {                   break;               }               out.writeByte(((c3 & 0x03) << 6) | c4);           }           return out;       }  		// ----------------------------------------------------------------------------	// PNG encoding	// ----------------------------------------------------------------------------	// http://code.google.com/p/as3corelib/source/browse/trunk/src/com/adobe/images/PNGEncoder.as	//	// Copyright (c) 2008, Adobe Systems Incorporated	// All rights reserved.		   public static function PNG(img:BitmapData):ByteArray    {		// Create output byte array		var png:ByteArray = new ByteArray();		png.writeUnsignedInt(0x89504e47);		png.writeUnsignedInt(0x0D0A1A0A);		var IHDR:ByteArray = new ByteArray();		IHDR.writeInt(Std.int(img.width));		IHDR.writeInt(Std.int(img.height));		IHDR.writeUnsignedInt(0x08060000); // 32bit RGBA		IHDR.writeByte(0);		writeChunk(png,0x49484452,IHDR);		var IDAT:ByteArray= new ByteArray();		var p:UInt;		var j:Int;				for(i in 0...img.height)		{			// no filter			IDAT.writeByte(0);			if (!img.transparent)			{				for(j in 0...img.width-1) 				{					p = img.getPixel(j,i);					IDAT.writeUnsignedInt(((p & 0xFFFFFF) << 8) | 0xFF);				}			} 			else 			{				for(j in 0...img.width-1) 				{					p = img.getPixel32(j,i);					IDAT.writeUnsignedInt(((p&0xFFFFFF) << 8) |	(p>>>24));				}			}		}				IDAT.compress();		writeChunk(png,0x49444154,IDAT);		writeChunk(png,0x49454E44, null);		return png;	}	private static var crcTable:Array<UInt>;	private static var crcTableComputed:Bool = false;	private static function writeChunk(png:ByteArray, type:UInt, data:ByteArray):Void 	{		if(!crcTableComputed) 		{			crcTableComputed = true;			crcTable = [];			var c:UInt;						for(n in 0...255) 			{				c = n;								for(k in 0...7)				{					if (c & 1 != 0) 					{						//c = UStd.parseInt(UStd.parseInt(0xedb88320) ^ UStd.parseInt(c >>> 1));						c = 0xedb88320 ^ (c >>> 1);					} 					else 					{						//c = UStd.parseInt(c >>> 1);						c = (c >>> 1);					}				}				crcTable[n] = c;			}		}				var len:UInt = 0;		if(data != null) 		{			len = data.length;		}		png.writeUnsignedInt(len);				var p:UInt = png.position;		png.writeUnsignedInt(type);				if(data != null) 		{			png.writeBytes(data);		}				var e:UInt = png.position;		png.position = p;		var c : UInt = 0xffffffff;				for(i in 0 ... (e - p - 1))		{			c = crcTable[(c ^ png.readUnsignedByte()) & (0xff)] ^ (c >>> 8);		}				c = c ^ 0xffffffff;		png.position = e;		png.writeUnsignedInt(c);	}}