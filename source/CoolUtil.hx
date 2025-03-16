package;

import flixel.util.FlxColor;
import flixel.FlxG;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import flixel.util.FlxColor;
import flixel.system.FlxSound;
#if sys
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end

using StringTools;

#if cpp
@:cppFileCode('#include <thread>')
#end
class CoolUtil
{
	public static var defaultDifficulties:Array<String> = ['Easy', 'Normal', 'Hard'];
	public static var defaultDifficulty:String = 'Normal'; // The chart that has no suffix and starting difficulty on Freeplay/Story Mode

	public static var difficulties:Array<String> = [];

	inline public static function quantize(f:Float, snap:Float)
	{
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		trace(snap);
		return (m / snap);
	}

	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if (num == null)
			num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num];
		if (fileSuffix != defaultDifficulty)
		{
			fileSuffix = '-' + fileSuffix;
		}
		else
		{
			fileSuffix = '';
		}
		return Paths.formatToSongPath(fileSuffix);
	}

	public static function difficultyString():String
	{
		return difficulties[PlayState.storyDifficulty].toUpperCase();
	}

	public static inline function last<T>(array:Array<T>):T
	{
		return array[array.length - 1];
	}

	public static inline function getMacroAbstractClass(className:String)
	{
		return Type.resolveClass('${className}_HSC');
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		return Math.max(min, Math.min(max, value));
	}

	public static function readTextFile(text:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = text.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		#if sys
		if (FileSystem.exists(path))
			daList = File.getContent(path).trim().split('\n');
		#else
		if (Assets.exists(path))
			daList = Assets.getText(path).trim().split('\n');
		#end

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function colorFromString(color:String):FlxColor
	{
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if(color.startsWith('0x')) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if(colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}
	
	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		for (col in 0...sprite.frameWidth)
		{
			for (row in 0...sprite.frameHeight)
			{
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel != 0)
				{
					if (countByColor.exists(colorOfThisPixel))
					{
						countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					}
					else if (countByColor[colorOfThisPixel] != 13520687 - (2 * 13520687))
					{
						countByColor[colorOfThisPixel] = 1;
					}
				}
			}
		}
		var maxCount = 0;
		var maxKey:Int = 0; // after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
		for (key in countByColor.keys())
		{
			if (countByColor[key] >= maxCount)
			{
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	// uhhhh does this even work at all? i'm starting to doubt
	public static function precacheSound(sound:String, ?library:String = null):Void
	{
		Paths.sound(sound, library);
	}

	public static function precacheMusic(sound:String, ?library:String = null):Void
	{
		Paths.music(sound, library);
	}

	public static function browserLoad(site:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}
	
	public static function showPopUp(message:String, title:String):Void
	{
		#if android
		android.Tools.showAlertDialog(title, message, {name: "OK", func: null}, null);
		#else
		FlxG.stage.window.alert(message, title);
		#end
	}

	#if cpp
    @:functionCode('
        return std::thread::hardware_concurrency();
    ')
	#end
    public static function getCPUThreadsCount():Int
    {
        return 1;
    }

	public static function mouseOverlaps(object:flixel.FlxObject, ignoreX:Bool = false, ignoreY:Bool = false, ?offsetX:Float = 0, ?offsetY:Float = 0,
			?camera:flixel.FlxCamera):Bool
	{
		final overlapX:Bool = (FlxG.mouse.getWorldPosition(camera).x + offsetX) >= object.x
			&& (FlxG.mouse.getWorldPosition(camera).x + offsetX) <= object.x
				+ object.width;
		final overlapY:Bool = (FlxG.mouse.getWorldPosition(camera).y + offsetY) >= object.y
			&& (FlxG.mouse.getWorldPosition(camera).y + offsetY) <= object.y
				+ object.height;

		return (overlapX || ignoreX) && (overlapY || ignoreY);
	}

	public static function pointOverlaps(point:flixel.math.FlxPoint, object:flixel.FlxObject, ignoreX:Bool = false, ignoreY:Bool = false, ?offsetX:Float = 0,
			?offsetY:Float = 0, ?camera:flixel.FlxCamera):Bool
	{
		final overlapX:Bool = (point.x + offsetX) >= object.x && (point.x + offsetX) <= object.x + object.width;
		final overlapY:Bool = (point.y + offsetY) >= object.y && (point.y + offsetY) <= object.y + object.height;

		return (overlapX || ignoreX) && (overlapY || ignoreY);
	}

	public static function formatMemory(num:UInt):String
	{
		var size:Float = num;
		var data = 0;
		var dataTexts = ["B", "KB", "MB", "GB"];
		while (size > 1024 && data < dataTexts.length - 1)
		{
			data++;
			size = size / 1024;
		}

		size = Math.round(size * 100) / 100;
		var formatSize:String = formatAccuracy(size);
		return '${formatSize} ${dataTexts[data]}';
	}

	public static function formatAccuracy(value:Float)
	{
		var conversion:Map<String, String> = [
			'0' => '0.00',
			'0.0' => '0.00',
			'0.00' => '0.00',
			'00' => '00.00',
			'00.0' => '00.00',
			'00.00' => '00.00', // gotta do these as well because lazy
			'000' => '000.00'
		]; // these are to ensure you're getting the right values, instead of using complex if statements depending on string length

		var stringVal:String = Std.string(value);
		var converVal:String = '';
		for (i in 0...stringVal.length)
		{
			if (stringVal.charAt(i) == '.')
				converVal += '.';
			else
				converVal += '0';
		}

		var wantedConversion:String = conversion.get(converVal);
		var convertedValue:String = '';

		for (i in 0...wantedConversion.length)
		{
			if (stringVal.charAt(i) == '')
				convertedValue += wantedConversion.charAt(i);
			else
				convertedValue += stringVal.charAt(i);
		}

		if (convertedValue.length == 0)
			return '$value';

		return convertedValue;
	}

	public static function runCodeInOtherThread(func:Dynamic)
	{
		var thread:sys.thread.Thread;
		thread = sys.thread.Thread.createWithEventLoop(function()
		{
			sys.thread.Thread.current().events.promise();
		});
		thread.events.run(function()
		{
			func();
		});
		thread.events.runPromised(function()
		{
			// close the thing
		});
	}

	public static function capitalize(string:String):String
	{
		var withoutFirstLetter = "";
		for (i in 0...string.length)
		{
			if (i != 0)
				withoutFirstLetter += string.charAt(i).toLowerCase();
		}
		return string.charAt(0).toUpperCase() + withoutFirstLetter;
	}

	public static function parseVersion(s:String):Version
	{
		var vars = s.trim().split(".");
		return makeVersion(makeVersionNumber(vars[0]), makeVersionNumber(vars[1]), makeVersionNumber(vars[2]), vars[3]);
	}

	public static function makeVersion(major:Int, minor:Int, patch:Int, suffix:String):Version
		return {
			MAJOR: major,
			MINOR: minor,
			PATCH: patch,
			SUFFIX: suffix
		};

	static function makeVersionNumber(s:String):Int
	{
		var num = Std.parseInt(s != null ? s.trim() : "0");
		if (num < 0)
			num = 0;
		return num;
	}

	public static function basicVersionCheck(v:Version, v2:Version):VersionStatus
	{
		if (v.MAJOR < v2.MAJOR)
			return OUTDATED;
		else if (v.MAJOR > v2.MAJOR)
			return UPDATED;

		if (v.MINOR < v2.MINOR)
			return OUTDATED;
		else if (v.MINOR > v2.MINOR)
			return UPDATED;

		if (v.PATCH < v2.PATCH)
			return OUTDATED;
		else if (v.PATCH > v2.PATCH)
			return UPDATED;

		return UP_TO_DATE;
	}

	public static function newVersionCheck(v:Version, v2:Version):VersionStatus
	{ // demo to full second check

		if (v.SUFFIX != null && v2.SUFFIX != null) {
			if (v.SUFFIX.toLowerCase().contains("demo")
				&& (v2.SUFFIX.toLowerCase().contains("full") || !v2.SUFFIX.toLowerCase().contains("demo")))
				return OUTDATED;
	
			if (v.SUFFIX.toLowerCase().contains("full")
				&& (v2.SUFFIX.toLowerCase().contains("demo") || !v2.SUFFIX.toLowerCase().contains("full")))
				return UPDATED;
		}

		return basicVersionCheck(v, v2);
	}

	public static function versionCheck(v:Version, v2:Version):VersionStatus
	{
		// actual version check oh fuck why is haxe doesnt have that by default

		if (v.SUFFIX != null && v2.SUFFIX != null)
		{
			// demo to full first check
			if (v.SUFFIX.toLowerCase().contains("demo") && !v2.SUFFIX.toLowerCase().contains("demo"))
				return OUTDATED;
			else if (!v.SUFFIX.toLowerCase().contains("full") && v2.SUFFIX.toLowerCase().contains("full"))
				return OUTDATED;
		}

		return newVersionCheck(v, v2);
	}

	public static function isVersionDemo(v:Version):Bool
	{
		if (v.SUFFIX.toLowerCase().contains("demo") || !v.SUFFIX.toLowerCase().contains("full"))
			return true;

		return false;
	}

	public static final defVersionFormat:String = "$MAJOR.$MINOR.$PATCH";

	public static function getDisplayVersion(v:Version, versionFormat:String = "", allowTrim:Bool = true):String
	{
		var format = versionFormat.trim() == "" ? defVersionFormat : versionFormat;
		if (format.trim() == defVersionFormat.trim() && allowTrim)
		{
			if (v.PATCH == 0)
			{
				if (v.MINOR == 0)
					format = "$MAJOR";
				else
					format = "$MAJOR.$MINOR";
			}
		}

		return format.replace("$MAJOR", Std.string(v.MAJOR))
			.replace("$MINOR", Std.string(v.MINOR))
			.replace("$PATCH", Std.string(v.PATCH))
			.replace("$SUFFIX", v.SUFFIX != null ? v.SUFFIX.trim() : "");
	}

	static public function coolLerp(base:Float, target:Float, ratio:Float):Float
	{
		return base + cameraLerp(ratio) * (target - base);
	}

	static public function cameraLerp(lerp:Float):Float
	{
		return lerp * (FlxG.elapsed / 0.016666666666666666);
	}

	// i hated every second of doing that
	public static function int_desat(col:FlxColor, sat:Float):FlxColor
	{
		var hsv = rgb2hsv(int2rgb(col));
		hsv.saturation *= (1 - sat);
		var rgb = hsv2rgb(hsv);
		return FlxColor.fromRGBFloat(rgb.red, rgb.green, rgb.blue);
	}

	public static function int2rgb(col:FlxColor):RGBColor
	{
		return {red: (col >> 16) & 0xff, green: (col >> 8) & 0xff, blue: col & 0xff}
	};

	public static function rgb2hsv(col:RGBColor):HSVColor
	{
		var hueRad = Math.atan2(Math.sqrt(3) * (col.green - col.blue), 2 * col.red - col.green - col.blue);
		var hue:Float = 0;
		if (hueRad != 0)
			hue = 180 / Math.PI * hueRad;
		hue = hue < 0 ? hue + 360 : hue;
		var bright:Float = Math.max(col.red, Math.max(col.green, col.blue));
		var sat:Float = (bright - Math.min(col.red, Math.min(col.green, col.blue))) / bright;
		return {hue: hue, saturation: sat, brightness: bright};
	}

	public static function hsv2rgb(col:HSVColor):RGBColor
	{
		var chroma:Float = col.brightness * col.saturation;
		var match:Float = col.brightness - chroma;

		var hue:Float = col.hue % 360;
		var hueD = hue / 60;
		var mid = chroma * (1 - Math.abs(hueD % 2 - 1)) + match;
		chroma += match;

		chroma /= 255; // joy emoji
		mid /= 255;
		match /= 255;

		switch (Std.int(hueD))
		{
			case 0:
				return {red: chroma, green: mid, blue: match};
			case 1:
				return {red: mid, green: chroma, blue: match};
			case 2:
				return {red: match, green: chroma, blue: mid};
			case 3:
				return {red: match, green: mid, blue: chroma};
			case 4:
				return {red: mid, green: match, blue: chroma};
			case 5:
				return {red: chroma, green: match, blue: mid};
			case _:
				return {red: chroma, green: mid, blue: match};
		}
	}

	public static function filterNull<T>(a:Array<Null<T>>):Array<T>
	{
		var arr:Array<T> = [];
		for (v in a)
			if (null != v)
				arr.push(v);
		return arr;
	}
}

typedef RGBColor =
{
	var red:Float;
	var green:Float;
	var blue:Float;
}

typedef HSVColor =
{
	var saturation:Float;
	var hue:Float;
	var brightness:Float;
}

enum VersionStatus
{
	UP_TO_DATE;
	OUTDATED;
	UPDATED;
}

typedef Version =
{
	var MAJOR:Int;
	var MINOR:Int;
	var PATCH:Int;
	@:optional var SUFFIX:String;
}
