package;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;
#if mobile
import mobile.CopyState;
#end

#if windows
@:buildXml('
<target id="haxe">
	<lib name="wininet.lib" if="windows" />
	<lib name="dwmapi.lib" if="windows" />
</target>
')
@:cppFileCode('
#include <windows.h>
#include <winuser.h>
#pragma comment(lib, "Shell32.lib")
extern "C" HRESULT WINAPI SetCurrentProcessExplicitAppUserModelID(PCWSTR AppID);
')
#end

using StringTools;

class Main extends Sprite
{
	var game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: TitleState, // initial game state
		zoom: -1.0, // game state bounds
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		// #if debug //ivan code
		// skipSplash: false, // if the default flixel splash screen should be skipped
		// #end
		// vomit fullscreen
		startFullscreen: false // fullscreen sucks booty //extremely common ivan L
	};

	public static var noLeaksMode:Bool = true;
	public static var fpsVar:FPS;
	public static var fpsText(default, set):String = "FPS";
	public static var memoryText(default, set):String = "Memory";
	static var oldFpsText:String = "FPS";
	static var oldMemoryText:String = "Memory";

	public static function set_fpsText(v:String):String
	{
		oldFpsText = fpsText;
		fpsText = v;
		return v;
	}

	public static function set_memoryText(v:String):String
	{
		oldMemoryText = memoryText;
		memoryText = v;
		return v;
	}

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
		#if cpp
		cpp.NativeGc.enable(true);
		#elseif hl
		hl.Gc.enable(true);
		#end
	}

	public function new()
	{
		super();

		#if mobile
		#if android
		StorageUtil.requestPermissions();
		#end
		Sys.setCwd(StorageUtil.getStorageDirectory());
		#end

		CrashHandler.init();

		#if windows
		// DPI Scaling fix for windows 
		// this shouldn't be needed for other systems
		// Credit to YoshiCrafter29 for finding this function
		untyped __cpp__("SetProcessDPIAware();");

		var display = lime.system.System.getDisplay(0);
		if (display != null) {
			var dpiScale:Float = display.dpi / 96;
			Application.current.window.width = Std.int(gameWidth * dpiScale);
			Application.current.window.height = Std.int(gameHeight * dpiScale);

			Application.current.window.x = Std.int((Application.current.window.display.bounds.width - Application.current.window.width) / 2);
			Application.current.window.y = Std.int((Application.current.window.display.bounds.height - Application.current.window.height) / 2);
		}
		#end
		
		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		#if desktop
		WindowsAPI.setDarkMode(true);
		#end

		//BetterLogs.init();
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		hxvlc.util.Handle.init();
		ClientPrefs.loadDefaultKeys();
		var game = new FlxGame(game.width, game.height, #if (mobile && MODS_ALLOWED) !CopyState.checkExistingFiles() ? CopyState : #end game.initialState, game.framerate, game.framerate,
			game.skipSplash, game.startFullscreen);

		@:privateAccess
		game._customSoundTray = FunkinSoundTray;

		addChild(game);

		fpsVar = new FPS(5, 3, 0xFFFFFF);
		#if !mobile
		addChild(fpsVar);
		#else
		FlxG.game.addChild(fpsVar);
		#end
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if (fpsVar != null)
		{
			fpsVar.visible = ClientPrefs.showFPS;
		}

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
		
		#if mobile
		lime.system.System.allowScreenTimeout = ClientPrefs.screensaver;
		#if android
		FlxG.android.preventDefaultKeys = [BACK]; 
		#end
		#end

		#if desktop
		DiscordClient.prepare();
		#end

		// shader coords fix
		FlxG.signals.gameResized.add(function(w, h)
		{
			if (FlxG.cameras != null)
			{
				for (cam in FlxG.cameras.list)
					@:privateAccess {
					if (cam != null && cam._filters != null)
						resetSpriteCache(cam.flashSprite);
				}
			}
			if (FlxG.game != null)
				resetSpriteCache(FlxG.game);
			if (FlxG.stage != null)
				resetSpriteCache(FlxG.stage);
		});
	}

	static function resetSpriteCache(sprite:Dynamic):Void
	{
		@:privateAccess {
			sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}
}
