package;

import haxe.io.Path;
import scripting.*;
import scripting.events.*;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import openfl.display.Bitmap;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSave;
import flixel.animation.FlxAnimationController;
import animateatlas.AtlasFrameMaker;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
import Conductor.Rating;
import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.MouseButton;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.Window;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.display.Sprite;
import openfl.utils.Assets;
#if !flash
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end
#if sys
import sys.FileSystem;
import sys.io.File;
#end
#if VIDEOS_ALLOWED
import hxvlc.flixel.FlxVideoSprite;
#end
import MosaicEffect;

using StringTools;

class PlayState extends MusicBeatState
{
	// GIT STUFF DONT TOUCH
	public static final GIT_REPO:String = GitCommit.getGitRepoName();
	public static final GIT_BRANCH:String = GitCommit.getGitBranch();
	public static final GIT_HASH:String = GitCommit.getGitCommitHash();
	public static final GIT_HAS_LOCAL_CHANGES:Bool = GitCommit.getGitHasLocalChanges();

	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['ohNo', 0.2], // From 0% to 19%
		['uhOh', 0.4], // From 20% to 39%
		['ohBoy', 0.5], // From 40% to 49%
		['comeOn', 0.6], // From 50% to 59%
		['mamaMia', 0.69], // From 60% to 68%
		['nice', 0.7], // 69% //Only quote that isn't from Mario
		['yahoo', 0.8], // From 70% to 79%
		['great', 0.9], // From 80% to 89%
		['letsAGo', 1], // From 90% to 99%
		['perfect', 1] // At 100% ////The value on this one isn't used actually, since Perfect is always "1"
	]; // TO CHANGE IT GO TO THE LANG JSON THESE ARE JUST THE VARS TO LOOK INTO THE JSON

	// event variables
	private var isCameraOnForcedPos:Bool = false;

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	public var modchartBackdrops:Map<String, ModchartBackdrop> = new Map<String, ModchartBackdrop>();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	public var modchartTexts:Map<String, ModchartText> = new Map();
	public var modchartSaves:Map<String, FlxSave> = new Map();
	public var modchartBackdrops:Map<String, ModchartBackdrop> = new Map();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var pixelation:MosaicEffect;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	private var toadCloud1:FlxSprite;
	private var toadCloud2:FlxSprite;

	private var erecttoadCloud1:FlxSprite;
	private var erecttoadCloud2:FlxSprite;

	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	// Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;

	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingInterval:Int = 4;
	public var camZoomingDecay:Float = 1;

	public static var keMode:Bool = false;

	private var curSong:String = "";

	public var videoPlaying:Bool = false;

	public var gfSpeed:Int = 1;
	public var health(default, set):Float = 1;

	public function set_health(v:Float)
	{
		health = v;
		if (hasCoolHealth)
			updatehealthbar();
		return v;
	}

	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;

	public var healthBar:FlxBar;

	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;

	public var timeBar:FlxBar;

	public var ratingsData:Array<Rating> = [];
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;

	public var endingSong:Bool = false;
	public var startingSong:Bool = false;

	private var updateTime:Bool = true;

	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	// Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;

	public var cpuControlled(default, set):Bool = false;

	function set_cpuControlled(v:Bool):Bool
	{
		cpuControlled = v;
		if (botplayTxt != null)
			botplayTxt.visible = v;
		return v;
	}

	public var practiceMode:Bool = false;

	public static var opponentMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camOverlay:FlxCamera;
	public var camExtra:FlxCamera;
	public var camVideo:FlxCamera;
	public var camLoad:FlxCamera;
	public var camDialogue:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialoguenew:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueend:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	var dadbattleBlack:BGSprite;
	var dadbattleLight:BGSprite;
	var dadbattleSmokes:FlxSpriteGroup;

	var doof2:DialogueBox;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;

	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignAccuracy:Float = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;

	var videoSprite:FlxVideoSprite;

	var songLength:Float = 0;

	var hasendingdialog:Bool = false;
	var startdialog:Bool = false;

	public static var endingcutscenefade:Bool = false;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	public var fire:FlxTypedGroup<FlxEmitter>;

	private var crystal:FlxSprite;
	private var overlay:FlxSprite;

	private var damnTween:FlxTween = null;
	private var sugarcoat:FlxSprite;
	private var yPress:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	// Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;

	public var luaArray:Array<FunkinLua> = [];

	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;

	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>;

	// average accuracy
	// public static var weekAccuracy:Float = 0;
	// static var weekAccuracyCalc:Array<Float> = [];
	var precacheList:Map<String, String> = new Map<String, String>();

	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo sprite object
	public static var lastCombo:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];

	var windowStar1:Window;
	var windowStar2:Window;

	var songsWithCoolHealth:Array<String> = [
		"Star-Festival",
		"Toad-Brigade", "Toad-Brigade-Erect",
		"Hey-There",
		"Luminous-Swing",
		"Gusty-Garden",
		"Cosmic-Battle", "Cosmic-Battle-Erect", "Cosmic-Battle-Old",
		"Purple-Comet",
		"Funky-Factory",
		"Hell-Prominence",
		"Rooftop-Shame",
		"Astronomical",
		"Deluded-Sensation",
		"Starship-Mario",
		"Hell-Valley", "Hell-Valley-Erect"
	];
	var songsWithDareDevil:Array<String> = ["Stalagnance"];
	var hasCoolHealth:Bool = false;

	var winTitleLen:Int = 0;
	var abberationShaderIntensity:Float;
	var beatShaderAmount:Float = 0.05;
	var chromFNF:FlxRuntimeShader;

	static var funnyDiscordImage:String;

	override public function create()
	{
		funnyDiscordImage = FlxG.random.bool(50) ? "https://i.imgur.com/HcFwcrp.gif" : "https://i.imgur.com/e1abFEi.gif";
		// trace('Playback Rate: ' + playbackRate);
		Paths.clearStoredMemory();
		hasCoolHealth = songsWithCoolHealth.contains(Paths.formatToSongPathNoLowerCase(SONG.song));

		// for lua
		instance = this;

		pixelation = new MosaicEffect();
		pixelation.setStrength(0, 0);

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; // Reset to default

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		controlArray = ['NOTE_LEFT', 'NOTE_DOWN', 'NOTE_UP', 'NOTE_RIGHT'];

		// Ratings
		ratingsData.push(new Rating('sick')); // default rating

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.7;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.4;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('miss');
		rating.ratingMod = 0;
		rating.noteSplash = false;
		ratingsData.push(rating);

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);
		if (Paths.formatToSongPathNoLowerCase(SONG.song).startsWith("Cosmic-Battle") || Paths.formatToSongPathNoLowerCase(SONG.song).startsWith("Hell-Valley"))
		{
			opponentMode = false;
		} else {
			opponentMode = ClientPrefs.getGameplaySetting('opponentMode', false);
		}

		// var gameCam:FlxCamera = FlxG.camera;
		camLoad = new FlxCamera();
		camGame = new FlxCamera();
		camVideo = new FlxCamera();
		camOverlay = new FlxCamera();
		camExtra = new FlxCamera();
		camHUD = new FlxCamera();
		camDialogue = new FlxCamera();
		camOther = new FlxCamera();
		camLoad.bgColor.alpha = 0;
		camVideo.bgColor.alpha = 0;
		camOverlay.bgColor.alpha = 0;
		camExtra.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;
		camDialogue.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.add(camLoad, false);
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camVideo, false);
		FlxG.cameras.add(camOverlay, false);
		FlxG.cameras.add(camExtra, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camDialogue, false);
		FlxG.cameras.add(camOther, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		trace('stage is: ' + curStage);
		if (SONG.stage == null || SONG.stage.length < 1)
		{
			switch (songName)
			{
				default:
					curStage = 'stage';
			}
		}
		SONG.stage = curStage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if (stageData == null)
		{ // Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if (stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if (boyfriendCameraOffset == null) // Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if (opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if (girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'stage': // Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
				if (!ClientPrefs.lowQuality)
				{
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
				dadbattleSmokes = new FlxSpriteGroup(); // troll'd

			case 'toadBrigade':
				var toadSky:FlxSprite = new FlxSprite(-1200, -575).loadGraphic(Paths.image('stages/toad/ToadSky', 'example_mods'));
				toadSky.setGraphicSize(Std.int(1.4 * toadSky.width));
				toadSky.scrollFactor.set(1, 1);
				add(toadSky);

				toadCloud1 = new FlxSprite(-1000, -100).loadGraphic(Paths.image('stages/toad/ToadCloud', 'example_mods'));
				toadCloud1.antialiasing = ClientPrefs.globalAntialiasing;
				toadCloud1.scrollFactor.set(1, 1);
				add(toadCloud1);

				toadCloud2 = new FlxSprite(toadCloud1.x + toadCloud1.width, toadCloud1.y).loadGraphic(Paths.image('stages/toad/ToadCloud', 'example_mods'));
				toadCloud2.antialiasing = ClientPrefs.globalAntialiasing;
				toadCloud2.scrollFactor.set(1, 1);
				add(toadCloud2);

			case 'toadErectBrigade':
				var erecttoadSky:FlxSprite = new FlxSprite(-1200, -575).loadGraphic(Paths.image('stages/toad/ErectToadSky', 'example_mods'));
				erecttoadSky.setGraphicSize(Std.int(1.4 * erecttoadSky.width));
				erecttoadSky.scrollFactor.set(1, 1);
				add(erecttoadSky);

				erecttoadCloud1 = new FlxSprite(-1000, -100).loadGraphic(Paths.image('stages/toad/ErectToadCloud', 'example_mods'));
				erecttoadCloud1.antialiasing = ClientPrefs.globalAntialiasing;
				erecttoadCloud1.scrollFactor.set(1, 1);
				add(erecttoadCloud1);

				erecttoadCloud2 = new FlxSprite(erecttoadCloud1.x + erecttoadCloud1.width,
					erecttoadCloud1.y).loadGraphic(Paths.image('stages/toad/ErectToadCloud', 'example_mods'));
				erecttoadCloud2.antialiasing = ClientPrefs.globalAntialiasing;
				erecttoadCloud2.scrollFactor.set(1, 1);
				add(erecttoadCloud2);

			case meltyMolten:
				fire = new FlxTypedGroup<FlxEmitter>();
				for (i in 0...5)
				{
					var fireRise:FlxEmitter = new FlxEmitter(-1115, 1100);
					fireRise.launchMode = FlxEmitterMode.SQUARE;
					fireRise.velocity.set(-350, -400, 350, -800, -400, 250, 400, -1050);
					fireRise.scale.set(0.2, 0.2, 0.3, 0.4, 0.5, 0.4, 0.3, 0.2);
					fireRise.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
					fireRise.width = 4000;
					fireRise.blend = ADD;
					fireRise.alpha.set(1, 1, 0, 0);
					fireRise.lifespan.set(3, 5);
					fireRise.loadParticles(Paths.image('stages/molten/fireEmber' + i, 'example_mods'), 1000, 16, true);

					fireRise.start(false, FlxG.random.float(0.1, 0.15), 1000000);
					fire.add(fireRise);
				}

				crystal = new FlxSprite(1460, 800).loadGraphic(Paths.image('stages/molten/crystal', 'example_mods'));
				crystal.scrollFactor.set(0.9, 0.9);
				crystal.setGraphicSize(Std.int(1.4 * crystal.width));
				crystal.antialiasing = ClientPrefs.globalAntialiasing;

				if (ClientPrefs.shaders)
				{
					overlay = new FlxSprite(-500, -150).loadGraphic(Paths.image('stages/molten/overlay', 'example_mods'));
					overlay.blend = ADD;
				}
		}

		if (isPixelStage)
		{
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup); // Needed for blammed lights

		add(dadGroup);
		add(boyfriendGroup);

		if (curStage == 'pipstage')
		{
			dadGroup.alpha = 0;
			boyfriendGroup.alpha = 0;
			remove(gfGroup);
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var hxPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if (Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));

		for (mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if (FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if (file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if (FileSystem.exists(Paths.modFolders(luaFile)))
		{
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		}
		else
		{
			luaFile = Paths.getPreloadPath(luaFile);
			if (FileSystem.exists(luaFile))
			{
				doPush = true;
			}
		}

		if (doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end

		if (curStage == 'meltyMolten')
		{
			add(fire);
			add(crystal);
			add(overlay);
		}

		try
		{
			if (Paths.formatToSongPathNoLowerCase(SONG.song).startsWith('Cosmic-Battle'))
			{
				chromFNF = new FlxRuntimeShader(Shaders.chromShader);
				if (ClientPrefs.shaders)
				{
					FlxG.stage.filters = [new ShaderFilter(chromFNF)];
					chromFNF.setFloat('aberration', 0);
				}
			}
		}
		catch (e)
		{
		}

		var gfVersion:String = SONG.gfVersion;
		if (gfVersion == null || gfVersion.length < 1)
		{
			switch (curStage)
			{
				default:
					gfVersion = 'gf';
			}

			switch (Paths.formatToSongPath(SONG.song))
			{
				case 'stress':
					gfVersion = 'pico-speaker';
			}
			SONG.gfVersion = gfVersion; // Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);
		}

		dad = new Character(0, 0, SONG.opponent);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.boyfriend);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		boyfriend.fixArrowRGB();
		dad.fixArrowRGB();

		var camPoses = gf != null ? girlfriendCameraOffset : boyfriendCameraOffset;
		var char:Character = gf != null ? gf : boyfriend;
		var camPos:FlxPoint = new FlxPoint(camPoses[0], camPoses[1]);
		if (char != null)
		{
			camPos.x += char.getGraphicMidpoint().x + char.cameraPosition[0];
			camPos.y += char.getGraphicMidpoint().y + char.cameraPosition[1];
		}

		if (dad.curCharacter.startsWith('gf'))
		{
			dad.setPosition(GF_X, GF_Y);
			if (gf != null)
				gf.visible = false;
		}

		startdialog = false;

		var file:String = Paths.json(songName + '/dialogue'); // Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file))
		{
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); // Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file))
		{
			dialogue = CoolUtil.coolTextFile(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'DialogueNew'); // Checks for new cutscene dialogue
		if (FileSystem.exists(file))
		{
			startdialog = true;
			dialoguenew = CoolUtil.coolTextFile(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'DialogueNewEnd');
		if (FileSystem.exists(file))
		{
			dialogueend = CoolUtil.coolTextFile(file);
			hasendingdialog = true;
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		// doof.nextDialogueThing = startNextDialogue;
		// doof.skipDialogueThing = skipDialogue;

		var doof1:DialogueBox = new DialogueBox(false, dialoguenew);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof1.scrollFactor.set();
		doof1.finishThing = startCountdown;
		// doof.nextDialogueThing = startNextDialogue;
		// doof.skipDialogueThing = skipDialogue;

		doof2 = new DialogueBox(false, dialogueend);
		doof2.scrollFactor.set();
		doof2.finishThing = endReturn;

		Conductor.songPosition = -5000 / Conductor.songPosition;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if (ClientPrefs.downScroll)
			strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = keMode ? false : (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if (ClientPrefs.downScroll)
			timeTxt.y = FlxG.height - 44;

		if (ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; // How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if (ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong();

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if (ClientPrefs.downScroll)
			healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4,
			(opponentMode ? (SONG.flippedHealth ? RIGHT_TO_LEFT : LEFT_TO_RIGHT) : (SONG.flippedHealth ? LEFT_TO_RIGHT : RIGHT_TO_LEFT)),
			Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), null, 'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		if (keMode)
		{
			scoreTxt.x = healthBarBG.x + healthBarBG.width / 2 - 150;
			scoreTxt.y = healthBarBG.y + 50;
			scoreTxt.setFormat(Paths.font("original.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		else
		{
			scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		if (hasCoolHealth)
		{
			scoreTxt.y = (ClientPrefs.downScroll ? 25 : 675);
			iconP1.visible = iconP2.visible = healthBar.visible = healthBarBG.visible = false;
		}
		add(scoreTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if (ClientPrefs.downScroll)
		{
			botplayTxt.y = timeBarBG.y - 78;
		}

		for (obj in [doof, doof1, doof2])
			obj.cameras = [camDialogue];

		var objs = [
			strumLineNotes, grpNoteSplashes, notes, healthBar, healthBarBG, iconP1, iconP2, scoreTxt, botplayTxt, timeBar, timeBarBG, timeTxt
		];
		if (keMode)
		{
			// Add Kade Engine watermark
			var kadeEngineWatermark = new FlxText(4, FlxG.height * 0.9
				+ 45, 0,
				SONG.song
				+ " "
				+ CoolUtil.capitalize(CoolUtil.difficultyString())
				+ " - KE "
				+ MainMenuState.kadeEngineVersion
				+ " (PE "
				+ MainMenuState.psychEngineVersion
				+ ")",
				16);
			kadeEngineWatermark.setFormat(Paths.font("original.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			kadeEngineWatermark.scrollFactor.set();
			add(kadeEngineWatermark);
			objs.push(kadeEngineWatermark);
		}

		var text = 'v${CoolUtil.getDisplayVersion(CoolUtil.parseVersion(MainMenuState.modVersion.trim()))} (${GIT_REPO}:${GIT_BRANCH} #${GIT_HASH}${GIT_HAS_LOCAL_CHANGES ? ' (LOCAL EDITS)' : ''})';
		var updateWorkingWatermark = new FlxText(4, FlxG.height * 0.9 + 45, FlxG.width - 8, text, 16);
		updateWorkingWatermark.setFormat(Paths.font("original.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		updateWorkingWatermark.scrollFactor.set();
		add(updateWorkingWatermark);
		objs.push(updateWorkingWatermark);

		for (obj in objs)
			obj.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if (FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if (FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
			if (OpenFlAssets.exists(luaToLoad))
				luaArray.push(new FunkinLua(luaToLoad));
			#end
		}
		for (event in eventPushedMap.keys())
		{
			#if MODS_ALLOWED
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if (FileSystem.exists(luaToLoad))
				luaArray.push(new FunkinLua(luaToLoad));
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if (FileSystem.exists(luaToLoad))
					luaArray.push(new FunkinLua(luaToLoad));
			}
			#elseif sys
			var luaToLoad:String = Paths.getPreloadPath('custom_events/' + event + '.lua');
			if (OpenFlAssets.exists(luaToLoad))
				luaArray.push(new FunkinLua(luaToLoad));
			#end
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var hxPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if (Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));

		for (mod in Paths.getGlobalMods())
			foldersToCheck.insert(0,
				Paths.mods(mod + '/data/' + Paths.formatToSongPath(SONG.song) +
					'/')); // using push instead of insert because these should run after everything else
		#end

		for (folder in foldersToCheck)
		{
			if (FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if (file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{
				default:
					if (startdialog == true)
					{
						schoolIntro(doof1);
					}
					else
					{
						startCountdown();
					}
			}
			seenCutscene = true;
		}
		else
		{
			startCountdown();
		}
		if (!keMode)
			RecalculateRating();

		// PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if (ClientPrefs.hitsoundVolume > 0)
			precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');
		precacheList.set('coinget', 'preload/sound');

		if (PauseSubState.songName != null)
		{
			precacheList.set(PauseSubState.songName, 'music');
		}
		else if (ClientPrefs.pauseMusic != 'None')
		{
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');
		}

		precacheList.set('alphabet', 'image');

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter());
		#end

		if (!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		callOnLuas('onCreatePost', []);

		for (event in eventNotes)
		{
			switch (event.event)
			{
				case 'Change Character':
					var newCharacter:String = event.value2;
					var newColor = dad.getArrowRGB(newCharacter);
					switch (event.value1.toLowerCase())
					{
						case 'gf' | 'girlfriend' | '1':
						case 'dad' | 'opponent' | '0':
							setAllNotesRGBAfterTime(newColor, event.strumTime, false);
						default:
							setAllNotesRGBAfterTime(newColor, event.strumTime, true);
					}
			}
		}

		if (SONG.hideCombo)
			showCombo = showComboNum = showRating = false;

		if (curSong == "Panic Club")
		{
			FlxG.camera.setFilters([new ShaderFilter(pixelation.shader)]);
			pixelation.setStrength(50, 50);
			FlxTween.num(MosaicEffect.DEFAULT_STRENGTH, 1, 2, {type: FlxTweenType.PERSIST}, function(z)
			{
				pixelation.setStrength(z, z);
			});
		}

		if (curSong == "Love Driven")
		{
			var displayNoteProperties:Map<String, Dynamic> = [];
			displayNote = new Note(0, 0, null, false, false, false);
			displayNote.alpha = 0;
			displayNote.x = 1049;
			displayNote.y = 270;
			displayNoteProperties.set("defaultX", displayNote.x);
			displayNoteProperties.set("defaultY", displayNote.y);
			var rColorSprite = new FlxSprite();
			var gColorSprite = new FlxSprite();
			var bColorSprite = new FlxSprite();
			displayNoteProperties.set("rColorSprite", rColorSprite);
			displayNoteProperties.set("gColorSprite", gColorSprite);
			displayNoteProperties.set("bColorSprite", bColorSprite);
			var alphaTimer = new FlxTimer();
			displayNoteProperties.set("timer", alphaTimer);
			displayNote.setGraphicSize(Std.int(boyfriend.width * 0.7));
			displayNoteProperties.set('oldData', -1);
			insert(members.indexOf(strumLineNotes), displayNote);
			displayNoteProperties.set('noteAngles', [
				0 => [0 => 0, 1 => -90, 2 => 90, 3 => 180,],
				1 => [0 => 0, 1 => -90, 2 => 90, 3 => -180],
				2 => [0 => 0, 1 => -90, 2 => 90, 3 => 180],
				3 => [0 => 0, 1 => -90, 2 => 90, 3 => 180,],
			]);
			displayNote.data.displayNoteProperties = displayNoteProperties;
		}

		super.create();

		FlxG.mouse.visible = true;
		MouseCursors.loadCursor("galaxy");

		cacheCountdown();
		cachePopUpScore();
		for (key => type in precacheList)
		{
			// trace('Key $key is type $type');
			switch (type)
			{
				case 'image':
					Paths.image(key, "shared");
				case "preload/image":
					Paths.image(StringTools.replace(key, "preload/", ""), 'preload');
				case "sparrow/image":
					Paths.getSparrowAtlas(StringTools.replace(key, "sparrow/", ""));
				case "preload/sparrow/image":
					Paths.getSparrowAtlas(StringTools.replace(key, "preload/sparrow/", ""), "preload");
				case 'sound':
					Paths.sound(key, "shared");
				case "preload/sound":
					Paths.sound(StringTools.replace(key, "preload/", ""), 'preload');
				case 'music':
					Paths.music(key, "shared");
				case "preload/music":
					Paths.music(StringTools.replace(key, "preload/", ""), 'preload');
			}
		}

		CustomFadeTransition.nextCamera = camOther;

		FlxG.stage.window.title = (FlxG.stage.window.title + " | " + SONG.song + " - " + SONG.songComposer);

		winTitleLen = FlxG.stage.window.title.length;
	}

	var displayNote:Note;

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();

	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if (!ClientPrefs.shaders)
			return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if (!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 100)
	{
		if (!ClientPrefs.shaders)
			return false;

		if (runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if (Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/shaders/'));

		for (mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/shaders/'));

		for (folder in foldersToCheck)
		{
			if (FileSystem.exists(folder))
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				if (FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else
					frag = null;

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else
					vert = null;

				if (found)
				{
					runtimeShaders.set(name, [frag, vert]);
					// trace('Found shader $name!');
					return true;
				}
			}
		}
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		return false;
	}
	#end

	function set_songSpeed(value:Float):Float
	{
		if (generatedMusic)
		{
			var ratio:Float = value / songSpeed; // funny word huh
			if (ratio != 1)
			{
				for (note in notes.members)
					note.resizeByRatio(ratio);
				for (note in unspawnNotes)
					note.resizeByRatio(ratio);
			}
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		if (generatedMusic)
		{
			if (vocals != null)
				vocals.pitch = value;
			FlxG.sound.music.pitch = value;
			var ratio:Float = playbackRate / value; // funny word huh
			if (ratio != 1)
			{
				for (note in notes.members)
					note.resizeByRatio(ratio);
				for (note in unspawnNotes)
					note.resizeByRatio(ratio);
			}
		}
		iconP1.timeScale = value;
		iconP2.timeScale = value;
		playbackRate = value;
		FlxAnimationController.globalSpeed = value;
		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000 * value;
		setOnLuas('playbackRate', playbackRate);
		return value;
	}

	public function addTextToDebug(text:String, color:FlxColor)
	{
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText)
		{
			spr.y += 20;
		});

		if (luaDebugGroup.members.length > 34)
		{
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}

	public function reloadHealthBarColors()
	{
		var col1:FlxColor = FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);
		var col2:FlxColor = FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]);
		if (keMode)
		{
			col1 = 0xFFFF0000;
			col2 = 0xFF66FF33;
		}
		if (opponentMode)
			healthBar.createFilledBar(col2, col1);
		else
			healthBar.createFilledBar(col1, col2);

		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int)
	{
		switch (type)
		{
			case 0:
				if (!boyfriendMap.exists(newCharacter))
				{
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if (!dadMap.exists(newCharacter))
				{
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if (gf != null && !gfMap.exists(newCharacter))
				{
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modFolders(luaFile)))
		{
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		}
		else
		{
			luaFile = Paths.getPreloadPath(luaFile);
			if (FileSystem.exists(luaFile))
			{
				doPush = true;
			}
		}
		#else
		luaFile = Paths.getPreloadPath(luaFile);
		if (Assets.exists(luaFile))
		{
			doPush = true;
		}
		#end

		if (doPush)
		{
			for (script in luaArray)
			{
				if (script.scriptName == luaFile)
					return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool = true):FlxSprite
	{
		if (modchartSprites.exists(tag))
			return modchartSprites.get(tag);
		if (modchartBackdrops.exists(tag))
			return modchartBackdrops.get(tag);
		if (text && modchartTexts.exists(tag))
			return modchartTexts.get(tag);
		if (variables.exists(tag))
			return variables.get(tag);
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false)
	{
		if (gfCheck && char.curCharacter.startsWith('gf'))
		{ // IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function preloadVideo(name:String) {
		if (FileSystem.exists(Paths.video(name))) {
			videoSprite.load(Paths.video(name));
		}
	}

	public function startVideo(name:String, x:Float, y:Float, camera:Dynamic) {
		#if VIDEOS_ALLOWED
      	// inCutscene = true; //OK SO I HAD TO REMOVE THIS AND STARTANDEND FUNCTION FUCK YOU

		videoPlaying = true;


		var file:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(file))
		#else
		if(!OpenFLAssets.exists(file))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			videoPlaying = false;
			return;
		}

		videoSprite = new FlxVideoSprite(x, y);
		videoSprite.antialiasing = true;
		videoSprite.cameras = camera;
		videoSprite.bitmap.onFormatSetup.add(function():Void
		{
			if (videoSprite.bitmap != null && videoSprite.bitmap.bitmapData != null)
			{
				final scale:Float = Math.min(FlxG.width / videoSprite.bitmap.bitmapData.width, FlxG.height / videoSprite.bitmap.bitmapData.height);

				videoSprite.setGraphicSize(Std.int(videoSprite.bitmap.bitmapData.width * scale), Std.int(videoSprite.bitmap.bitmapData.height * scale));
				videoSprite.updateHitbox();
				videoSprite.screenCenter();
			}
		});
		videoSprite.bitmap.onEndReached.add(function() {
			videoSprite.destroy();
			videoPlaying = false;
		});
		if (videoSprite.load(file))
			videoSprite.play();
		add(videoSprite);
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		videoPlaying = false;
		return;
		#end
	}

	function startAndEnd()
	{
		if (endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;

	public var psychDialogue:DialogueBoxPsych;

	// You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if (psychDialogue != null)
			return;

		if (dialogueFile.dialogue.length > 0)
		{
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if (endingSong)
			{
				psychDialogue.finishThing = function()
				{
					psychDialogue = null;
					endSong();
				}
			}
			else
			{
				psychDialogue.finishThing = function()
				{
					psychDialogue = null;
					startCountdown();
				}
			}
			// psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		}
		else
		{
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if (endingSong)
			{
				endSong();
			}
			else
			{
				startCountdown();
			}
		}
	}

	public function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 6, FlxG.height * 6, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			if (dialogueBox != null)
			{
				if (Paths.formatToSongPath(SONG.song) == 'thorns')
				{
					add(senpaiEvil);
					senpaiEvil.alpha = 0;
					new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
					{
						senpaiEvil.alpha += 0.15;
						if (senpaiEvil.alpha < 1)
						{
							swagTimer.reset();
						}
						else
						{
							senpaiEvil.animation.play('idle');
							FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
							{
								remove(senpaiEvil);
								remove(red);
								FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
								{
									add(dialogueBox);
									camHUD.visible = true;
								}, true);
							});
							new FlxTimer().start(3.2, function(deadTime:FlxTimer)
							{
								FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
							});
						}
					});
				}
				else
				{
					add(dialogueBox);
					new FlxTimer().start(1, function(swagTimer:FlxTimer)
					{
						remove(black);
					});
				}
			}
			else
				startCountdown();
		});
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua and hscript
	public var countdownSpr:FlxSprite = new FlxSprite();

	public static var startOnTime:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

		var introAlts:Array<String> = introAssets.get('default');
		if (isPixelStage)
			introAlts = introAssets.get('pixel');

		for (asset in introAlts)
			Paths.image(asset);

		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}

	public function startCountdown():Void
	{
		if (startedCountdown)
		{
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', [], false);
		if (ret != FunkinLua.Function_Stop)
		{
			if (skipCountdown || startOnTime > 0)
				skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length)
			{
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length)
			{
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				// if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if (startOnTime < 0)
				startOnTime = 0;

			if (startOnTime > 0)
			{
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				if (gf != null
					&& tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0
					&& gf.animation.curAnim != null
					&& !gf.animation.curAnim.name.startsWith("sing")
					&& !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0
					&& boyfriend.animation.curAnim != null
					&& !boyfriend.animation.curAnim.name.startsWith('sing')
					&& !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0
					&& dad.animation.curAnim != null
					&& !dad.animation.curAnim.name.startsWith('sing')
					&& !dad.stunned)
				{
					dad.dance();
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if (isPixelStage)
				{
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				var sndNum = (swagCounter == 0 ? "3" : (swagCounter == 1 ? "2" : (swagCounter == 2 ? "1" : "Go")));
				var imgNum = switch (swagCounter)
				{
					case 1: 0;
					case 2: 1;
					case 3: 2;
					default: 0;
				}
				var event = {
					volume: 0.6,
					soundPath: 'intro$sndNum$introSoundsSuffix',
					spritePath: introAlts[imgNum],
					antialiasing: antialias,
				};
				if (!skipCountdown)
				{
					doCountdown(swagCounter, event.spritePath, event.antialiasing);

					if (swagCounter < 4)
					{
						FlxG.sound.play(Paths.sound(event.soundPath), event.volume);
					}

					notes.forEachAlive(function(note:Note)
					{
						if (ClientPrefs.opponentStrums || note.mustPress)
						{
							note.copyAlpha = false;
							note.alpha = note.multAlpha;
							if (ClientPrefs.middleScroll && !note.mustPress)
							{
								note.alpha *= 0.35;
							}
						}
					});

					swagCounter += 1;
					// generateSong();
				}
			}, 5);
		}
	}

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}

	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}

	public function addBehindDad(obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float, shouldHitThem:Bool = false)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0)
		{
			var daNote:Note = unspawnNotes[i];
			if (daNote.strumTime - 350 < time)
			{
				if (shouldHitThem)
				{
					goodNoteHit(daNote);
				}
				else
				{
					daNote.active = false;
					daNote.visible = false;
					daNote.ignoreNote = true;

					daNote.kill();
					unspawnNotes.remove(daNote);
					daNote.destroy();
				}
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0)
		{
			var daNote:Note = notes.members[i];
			if (daNote.strumTime - 350 < time)
			{
				if (shouldHitThem)
				{
					goodNoteHit(daNote);
				}
				else
				{
					daNote.active = false;
					daNote.visible = false;
					daNote.ignoreNote = true;

					daNote.kill();
					unspawnNotes.remove(daNote);
					daNote.destroy();
				}
			}
			--i;
		}
	}

	public function setAllNotesRGBAfterTime(arrRgb:Array<Array<FlxColor>>, time:Float, mustPress:Null<Bool>)
	{
		if (mustPress == null)
			return;
		var theFunc = function(daNote:Note)
		{
			if (daNote.strumTime >= time && daNote.mustPress == mustPress)
			{
				daNote.updateRgb(arrRgb[daNote.noteData]);
			}
		};
		for (note in unspawnNotes)
			theFunc(note);
		notes.forEach(theFunc);
	}

	function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	private var keAccuracy:Float = 0;
	private var keFc:Bool = false;

	function updateKeAccuracy()
	{
		if (songMisses > 0 || keAccuracy < 96)
			keFc = false;
		else
			keFc = true;
		keAccuracy = totalNotesHit / totalPlayed * 100;
	}

	public function updateScore(miss:Bool = false)
	{
		if (!keMode)
		{
			scoreTxt.text = '${Language.getString("gameplay.score")}: '
				+ (ClientPrefs.scoreMode == "Rounded Accurate" ? Math.round(songScore / 10) * 10 : songScore)
				+ ' | ${Language.getString("gameplay.misses")}: '
				+ songMisses
				+ ' | ${Language.getString("gameplay.rating")}: '
				+ ratingName
				+ (ratingName != '?' ? ' (${Highscore.floorDecimal(ratingPercent * 100, 2)}%) - $ratingFC' : '');
		}

		if ((ClientPrefs.scoreZoom && !keMode) && !miss && !cpuControlled)
		{
			if (scoreTxtTween != null)
			{
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween)
				{
					scoreTxtTween = null;
				}
			});
		}
		callOnLuas('onUpdateScore', [miss]);
	}

	public function setSongTime(time:Float)
	{
		if (time < 0)
			time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			vocals.pitch = playbackRate;
		}
		vocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	function startNextDialogue()
	{
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue()
	{
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();

		if (startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if (paused)
		{
			// trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		needSongLength = songLength = FlxG.sound.music.length;
		setSongLength(songLength, false); // fuck that sign
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLength);
		#end

		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	private function generateSong():Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype', 'multiplicative');

		switch (songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		vocals.pitch = playbackRate;
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		if (hasCoolHealth)
			setuphealthbar();

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.sections;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file))
		{
		#else
		if (OpenFlAssets.exists(file))
		{
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) // Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3 && !opponentMode)
				{
					gottaHitNote = !section.mustHitSection;
				}
				else if (songNotes[1] <= 3 && opponentMode)
				{
					gottaHitNote = !section.mustHitSection;
				}
				var oldNote:Note;

				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);

				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1] < 4));
				swagNote.noteType = songNotes[3];
				if (!Std.isOfType(songNotes[3], String))
					swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; // Backward compatibility + compatibility with Week 7 charts
				swagNote.scrollFactor.set();
				var susLength:Float = swagNote.sustainLength / Conductor.stepCrochet;

				var fixNoteColorShit = function(dunceNote:Note)
				{
					if (["Deluded-Sensation"].contains(Paths.formatToSongPathNoLowerCase(SONG.song)) && !dunceNote.mustPress)
					{
						dunceNote.rgbShader.r = 0xFFEBE71C;
						dunceNote.rgbShader.g = 0xFFFFFFFF;
						dunceNote.rgbShader.b = 0xFF915116;
						dunceNote.rgbShader.enabled = false;
					}
					if (!["Add Song Time", "Remove Song Time", "Luigi", "Blammed Note", "Hurt Note", "Heal Note"].contains(dunceNote.noteType))
					{
						// unreadable i know but it works
						dunceNote.updateRgb((!dunceNote.mustPress ? (opponentMode ? boyfriend : dad) : (!opponentMode ? boyfriend : dad))
							.arrowRGB[dunceNote.noteData]);
						if (Paths.formatToSongPathNoLowerCase(SONG.song).startsWith('Cosmic-Battle'))
						{
							var oppNoteOnNormal = !dunceNote.mustPress;
							var oppNoteOnOppMode = dunceNote.mustPress;
							if (opponentMode ? oppNoteOnOppMode : oppNoteOnNormal)
								dunceNote.texture = "cosmicnote";
						}
					}
					if (keMode)
					{
						dunceNote.rgbShader.enabled = true;
						dunceNote.noteSplashDisabled = true;
						dunceNote.updateRgb(ClientPrefs.defaultArrowRGB[dunceNote.noteData]);
						if (dunceNote.isSustainNote)
						{
							dunceNote.scale.set(1, 1);
						}
					}
				}

				fixNoteColorShit(swagNote);
				unspawnNotes.push(swagNote);
				var floorSus:Int = Math.floor(susLength);

				if (floorSus > 0)
				{
					for (susNote in 0...floorSus + 1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						var sustainNote:Note = new Note(daStrumTime
							+ (Conductor.stepCrochet * susNote)
							+ (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote,
							true);

						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1] < 4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);
						fixNoteColorShit(sustainNote);
						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if (ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if (daNoteData > 1) // Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}
				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if (ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if (daNoteData > 1) // Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}
				if (!noteTypeMap.exists(swagNote.noteType))
				{
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) // Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}
		// trace(unspawnNotes.length);
		// playerCounter += 1;
		unspawnNotes.sort(sortByShit);
		if (eventNotes.length > 1)
		{ // No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote)
	{
		switch (event.event)
		{
			case 'Change Character':
				var charType:Int = 0;
				switch (event.value1.toLowerCase())
				{
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if (Math.isNaN(charType)) charType = 0;
				}

				addCharacterToList(event.value2, charType);

			case 'Dadbattle Spotlight':
				dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
				dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				dadbattleBlack.alpha = 0.25;
				dadbattleBlack.visible = false;
				add(dadbattleBlack);

				dadbattleLight = new BGSprite('spotlight', 400, -400);
				dadbattleLight.alpha = 0.375;
				dadbattleLight.blend = ADD;
				dadbattleLight.visible = false;

				dadbattleSmokes.alpha = 0.7;
				dadbattleSmokes.blend = ADD;
				dadbattleSmokes.visible = false;
				add(dadbattleLight);
				add(dadbattleSmokes);

				var offsetX = 200;
				var smoke:BGSprite = new BGSprite('smoke', -1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(15, 22);
				smoke.active = true;
				dadbattleSmokes.add(smoke);
				var smoke:BGSprite = new BGSprite('smoke', 1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
				smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
				smoke.updateHitbox();
				smoke.velocity.x = FlxG.random.float(-15, -22);
				smoke.active = true;
				smoke.flipX = true;
				dadbattleSmokes.add(smoke);
		}

		if (!eventPushedMap.exists(event.event))
		{
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float
	{
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if (returnedValue != 0)
		{
			return returnedValue;
		}

		switch (event.event)
		{
			case 'Kill Henchmen': // Better timing so that the kill sound matches the beat intended
				return 280; // Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; // for lua

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if (!ClientPrefs.opponentStrums)
					targetAlpha = 0;
				else if (ClientPrefs.middleScroll)
					targetAlpha = 0.35;
			}

			var flippedPlayer = (player == 0 ? 1 : 0);
			if (ClientPrefs.middleScroll)
				flippedPlayer = player;

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i,
				SONG.flippedNotes ? flippedPlayer : player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				// babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				babyArrow.defaultRGB = boyfriend.arrowRGB;
				if (keMode)
				{
					babyArrow.rgbShader.enabled = false;
					babyArrow.defaultRGB = ClientPrefs.defaultArrowRGB;
				}
				if (!opponentMode || (opponentMode && ClientPrefs.middleScroll))
					playerStrums.add(babyArrow);
				else
				{
					opponentStrums.add(babyArrow);
					babyArrow.opponentArrow = true;
				}
				if (opponentMode && ClientPrefs.middleScroll)
					babyArrow.defaultRGB = dad.arrowRGB;
			}
			else
			{
				babyArrow.defaultRGB = dad.arrowRGB;
				babyArrow.opponentArrow = true;
				if (["Deluded-Sensation"].contains(Paths.formatToSongPathNoLowerCase(SONG.song)))
					babyArrow.useRGBShader = false;
				if (keMode)
				{
					babyArrow.rgbShader.enabled = false;
					babyArrow.defaultRGB = ClientPrefs.defaultArrowRGB;
				}
				if (ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if (i > 1)
					{ // Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				if (!opponentMode || opponentMode && ClientPrefs.middleScroll)
					opponentStrums.add(babyArrow);
				else
					playerStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
			new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(_)
			{
				babyArrow.finishedSetup();
			});
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (videoPlaying) {
				videoSprite.pause();
			}
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars)
			{
				if (char != null && char.colorTween != null)
				{
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens)
			{
				tween.active = false;
			}
			for (timer in modchartTimers)
			{
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (videoPlaying) {
				videoSprite.resume();
			}
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars)
			{
				if (char != null && char.colorTween != null)
				{
					char.colorTween.active = true;
				}
			}

			for (tween in modchartTweens)
			{
				tween.active = true;
			}
			for (timer in modchartTimers)
			{
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);
		}

		super.closeSubState();

		#if desktop
		if (startTimer != null && startTimer.finished)
		{
			DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
		}
		else
		{
			DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter());
		}
		#end
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song, iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if (finishTimer != null)
			return;

		vocals.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.pitch = playbackRate;
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			vocals.pitch = playbackRate;
		}
		vocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;
	var caption:FlxText;
	var captionicon:BGSprite;
	var immunity:Bool = true;
	var immunitytime:Float = 0;

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.Y)
		{
			if (!yPress)
				yPress = true;
			if (sugarcoat != null)
				sugarcoat.destroy();
			if (damnTween != null)
			{
				damnTween.cancel();
				damnTween = null;
			}
			sugarcoat = new FlxSprite().loadGraphic(Paths.image('sugarcoat', 'example_mods'));
			sugarcoat.scrollFactor.set(0, 0);
			sugarcoat.screenCenter();
			sugarcoat.antialiasing = ClientPrefs.globalAntialiasing;
			sugarcoat.alpha = 0;
			sugarcoat.cameras = [camOther];
			add(sugarcoat);
			FlxG.sound.play(Paths.sound('sugarcoat'));
			damnTween = FlxTween.tween(sugarcoat, {alpha: 1}, 0.01, {
				ease: FlxEase.quartIn,
				onComplete: damn ->
				{
					damnTween = FlxTween.tween(sugarcoat, {alpha: 0}, 0.55, {
						startDelay: 0.5,
						onComplete: damnAgain ->
						{
							sugarcoat.destroy();
							damnTween = null;
							#if ACHIEVEMENTS_ALLOWED
							if (achievementObj == null)
							{
								var achieve:String = checkForAchievement(['sugarcoat']);

								if (achieve != null)
								{
									startAchievement(achieve);
								}
							}
							#end
						}
					});
				}
			});
		}
		callOnLuas('onUpdate', [elapsed]);

		if (keMode)
			scoreTxt.text = '${Language.getString("gameplay.score")}:'
				+ songScore
				+ ' | ${Language.getString("gameplay.misses")}:'
				+ songMisses
				+ ' | ${Language.getString("gameplay.accuracy")}:'
				+ (keAccuracy == 0 ? 0 : truncateFloat(keAccuracy, 2))
				+ "% "
				+ (keFc ? "| FC" : songMisses == 0 ? "| A" : keAccuracy <= 75 ? "| BAD" : "");

		if (immunity)
		{
			immunitytime += elapsed;
			if (immunitytime >= (Conductor.crochet * 2) / 1000)
			{
				immunity = false;
				immunitytime = 0;
			}
		}

		if (!inCutscene)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed * playbackRate, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if (!startingSong
				&& !endingSong
				&& boyfriend.animation.curAnim != null
				&& boyfriend.animation.curAnim.name.startsWith('idle'))
			{
				boyfriendIdleTime += elapsed;
				if (boyfriendIdleTime >= 0.15)
				{ // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			}
			else
			{
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);

		if (curStage == 'toadBrigade')
		{
			toadCloud1.x--;
			toadCloud2.x--;

			if (toadCloud1.x < -3700)
				toadCloud1.x = toadCloud2.x + toadCloud2.width;
			if (toadCloud2.x < -3700)
				toadCloud2.x = toadCloud1.x + toadCloud1.width;
		}

		if (curStage == 'toadErectBrigade')
		{
			erecttoadCloud1.x--;
			erecttoadCloud2.x--;

			if (erecttoadCloud1.x < -3700)
				erecttoadCloud1.x = erecttoadCloud2.x + erecttoadCloud2.width;
			if (erecttoadCloud2.x < -3700)
				erecttoadCloud2.x = erecttoadCloud1.x + erecttoadCloud1.width;
		}

		if (botplayTxt.visible)
		{
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', [], false);
			if (ret != FunkinLua.Function_Stop)
			{
				openPauseMenu();
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		healthBar.value = FlxMath.lerp(health, healthBar.value, FlxMath.bound(1 - (elapsed * 7.5), 0, 1));

		iconP1.flipX = iconP2.flipX = SONG.flippedHealth;

		if (!keMode)
		{
			var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
			iconP1.scale.set(mult, mult);
			iconP1.updateHitbox();

			var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
			iconP2.scale.set(mult, mult);
			iconP2.updateHitbox();

			var iconOffset:Int = 26;
			var fakeIconScale:Float = 1.2;
			if (SONG.flippedHealth)
			{
				iconP1.x = (opponentMode ? 593 : 0)
					+ healthBar.x
					+ healthBar.width
					- (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, (opponentMode ? -100 : 100), 100, 0) * 0.01))
					- (150 * fakeIconScale) / 2
					- iconOffset * 2;
				iconP2.x = (opponentMode ? 593 : 0)
					+ healthBar.x
					+ healthBar.width
					- (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, (opponentMode ? -100 : 100), 100, 0) * 0.01))
					+ (150 * fakeIconScale - 150) / 2
					- iconOffset;
			}
			else
			{
				iconP1.x = (opponentMode ? -593 : 0)
					+ healthBar.x
					+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, (opponentMode ? -100 : 100), 100, 0) * 0.01))
					+ (150 * fakeIconScale - 150) / 2
					- iconOffset;
				iconP2.x = (opponentMode ? -593 : 0)
					+ healthBar.x
					+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, (opponentMode ? -100 : 100), 100, 0) * 0.01))
					- (150 * fakeIconScale) / 2
					- iconOffset * 2;
			}
			iconP1.x += iconP1.toAdd.x;
			iconP1.y += iconP1.toAdd.y;
			iconP2.x += iconP2.toAdd.x;
			iconP2.y += iconP2.toAdd.y;
		}
		else
		{
			iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
			iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

			iconP1.updateHitbox();
			iconP2.updateHitbox();

			var iconOffset:Int = 26;
			if (SONG.flippedHealth)
			{
				iconP1.x = (opponentMode ? 593 : 0)
					+ healthBar.x
					+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, (opponentMode ? -100 : 100), 100, 0) * 0.01))
					+ (150 * iconP1.scale.x) / 2
					- iconOffset;
				iconP2.x = (opponentMode ? 593 : 0)
					+ healthBar.x
					+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, (opponentMode ? -100 : 100), 100, 0) * 0.01))
					- (150 * iconP2.scale.x - 150) / 2
					- iconOffset * 2;
			}
			else
			{
				iconP1.x = (opponentMode ? -593 : 0)
					+ healthBar.x
					+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, (opponentMode ? -100 : 100), 100, 0) * 0.01))
					+ (150 * iconP1.scale.x - 150) / 2
					- iconOffset;
				iconP2.x = (opponentMode ? -593 : 0)
					+ healthBar.x
					+ (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, (opponentMode ? -100 : 100), 100, 0) * 0.01))
					- (150 * iconP2.scale.x) / 2
					- iconOffset * 2;
			}
		}

		if (health > (hasCoolHealth ? (!hasDareDevil ? 3 : 1) : 2))
			health = (hasCoolHealth ? (!hasDareDevil ? 3 : 1) : 2);

		try
		{
			if (Paths.formatToSongPathNoLowerCase(SONG.song).startsWith('Cosmic-Battle'))
			{
				chromFNF.setFloat('aberration', -abberationShaderIntensity);
				abberationShaderIntensity = FlxMath.lerp(abberationShaderIntensity, 0, CoolUtil.boundTo(elapsed * 3.125 * camZoomingDecay * playbackRate, 0, 1));
			}
		}
		catch (e)
		{
		}

		if (!hasCoolHealth)
			healthBar.value = FlxMath.lerp(healthBar.value, health, CoolUtil.boundTo(elapsed * 24, 0, 1));

		if (healthBar.percent < 20)
			(opponentMode ? iconP2 : iconP1).animation.curAnim.curFrame = 1;
		else
			(opponentMode ? iconP2 : iconP1).animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			(opponentMode ? iconP1 : iconP2).animation.curAnim.curFrame = 1;
		else
			(opponentMode ? iconP1 : iconP2).animation.curAnim.curFrame = 0;

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene)
		{
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.opponent));
		}

		if (startedCountdown)
		{
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;
		}

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if (!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else
		{
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if (updateTime)
				{
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if (curTime < 0)
						curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if (ClientPrefs.timeBarType == 'Time Elapsed')
						songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if (secondsTotal < 0)
						secondsTotal = 0;

					if (ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom,
				keMode ? 0.95 : CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, keMode ? 0.95 : CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}

		songLength = FlxMath.lerp(needSongLength, songLength, CoolUtil.boundTo(1 - (elapsed * 3.125 * playbackRate), 0, 1));

		FlxG.watch.addQuick("songLength", songLength);
		FlxG.watch.addQuick("needSongLength", needSongLength);

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;
			if (songSpeed < 1)
				time /= songSpeed;
			if (unspawnNotes[0].multSpeed < 1)
				time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned = true;

				callOnLuas('onSpawnNote', [
					notes.members.indexOf(dunceNote),
					dunceNote.noteData,
					dunceNote.noteType,
					dunceNote.isSustainNote
				]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic && !inCutscene)
		{
			if (!cpuControlled)
			{
				keyShit();
			}
			else if (boyfriend.animation.curAnim != null
				&& boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration
					&& boyfriend.animation.curAnim.name.startsWith('sing')
					&& !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				// boyfriend.animation.curAnim.finish();
			}
			if (cpuControlled
				&& opponentMode
				&& dad.holdTimer > Conductor.stepCrochet * 0.001 * dad.singDuration
				&& dad.animation.curAnim.name.startsWith('sing')
				&& !dad.animation.curAnim.name.endsWith('miss'))
			{
				dad.dance();
			}

			if (startedCountdown)
			{
				var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
				notes.forEachAlive(function(daNote:Note)
				{
					var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
					if (!daNote.mustPress)
						strumGroup = opponentStrums;
					var strumX:Float = strumGroup.members[daNote.noteData].x;
					var strumY:Float = strumGroup.members[daNote.noteData].y;
					var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
					var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
					var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
					var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;
					strumX += daNote.offsetX;
					strumY += daNote.offsetY;
					strumAngle += daNote.offsetAngle;
					strumAlpha *= daNote.multAlpha;
					if (strumScroll) // Downscroll
					{
						// daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}
					else // Upscroll
					{
						// daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}
					var angleDir = strumDirection * Math.PI / 180;
					if (daNote.copyAngle)
						daNote.angle = strumDirection - 90 + strumAngle;
					if (daNote.copyAlpha)
						daNote.alpha = strumAlpha;
					if (daNote.copyX)
						daNote.x = strumX + Math.cos(angleDir) * daNote.distance;
					if (daNote.copyY)
					{
						daNote.y = strumY + Math.sin(angleDir) * daNote.distance;
						// Jesus fuck this took me so much mother fucking time AAAAAAAAAA
						if (strumScroll && daNote.isSustainNote)
						{
							if (daNote.animation.curAnim.name.endsWith('end'))
							{
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
								if (PlayState.isPixelStage)
								{
									daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
								}
								else
								{
									daNote.y -= 19;
								}
							}
							daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
						}
					}
					if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
					{
						opponentNoteHit(daNote);
					}
					if (!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit)
					{
						if (daNote.isSustainNote)
						{
							if (daNote.canBeHit)
							{
								goodNoteHit(daNote);
							}
						}
						else if (daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote)
						{
							goodNoteHit(daNote);
						}
					}
					var center:Float = strumY + Note.swagWidth / 2;
					if (strumGroup.members[daNote.noteData].sustainReduce
						&& daNote.isSustainNote
						&& (daNote.mustPress || !daNote.ignoreNote)
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						if (strumScroll)
						{
							if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;
								daNote.clipRect = swagRect;
							}
						}
						else
						{
							if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;
								daNote.clipRect = swagRect;
							}
						}
					}
					// Kill extremely late notes and cause misses
					if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
					{
						if (daNote.mustPress && !cpuControlled && !daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit))
						{
							noteMiss(daNote);
						}

						if (daNote.healNote)
						{
							trace('MISSED A HEAL NOTE!!!!');
							spawnCoinNote();
						}
						daNote.active = false;
						daNote.visible = false;
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}
			else
			{
				notes.forEachAlive(function(daNote:Note)
				{
					daNote.canBeHit = false;
					daNote.wasGoodHit = false;
				});
			}
		}
		checkEventNote();

		#if debug
		if (!endingSong && !startingSong)
		{
			if (FlxG.keys.justPressed.ONE)
			{
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if (FlxG.keys.justPressed.TWO)
			{ // Go into the future :O
				var addSeconds = FlxG.keys.pressed.SHIFT ? 20 : 10;
				setSongTime(Conductor.songPosition + (addSeconds * 1000));
				clearNotesBefore(Conductor.songPosition, false);
			}
		}
		#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
	}

	var starBG1:Bitmap;
	var starBG2:Bitmap;

	function popupWindowStar1()
	{
		var oldAutoPause = FlxG.autoPause;
		var display = Application.current.window.display.currentMode;

		windowStar1 = Lib.application.createWindow({
			title: "Star",
			width: 500,
			height: 500,
			borderless: true,
			alwaysOnTop: true
		});
		windowStar1.x = Std.int(display.width - (display.width + 500));
		windowStar1.y = 50;
		windowStar1.stage.color = 0xFF010101;
		@:privateAccess
		windowStar1.stage.addEventListener("keyDown", FlxG.keys.onKeyDown);
		@:privateAccess
		windowStar1.stage.addEventListener("keyUp", FlxG.keys.onKeyUp);

		starBG1 = new Bitmap(Assets.getBitmapData(Paths.getPath("images/star-festival/star.png", IMAGE, "shared")));
		windowStar1.stage.addChild(starBG1);
		WindowsAPI.getWindowsTransparent();
		Application.current.window.focus();
		FlxG.autoPause = oldAutoPause;
	}

	function popupWindowStar2()
	{
		var oldAutoPause = FlxG.autoPause;
		var display = Application.current.window.display.currentMode;

		windowStar2 = Lib.application.createWindow({
			title: "Star",
			width: 600,
			height: 600,
			borderless: true,
			alwaysOnTop: true
		});

		windowStar2.x = Std.int(display.width + 500);
		windowStar2.y = Std.int(display.height - (500 + 50));
		windowStar2.stage.color = 0xFF010101;
		@:privateAccess
		windowStar2.stage.addEventListener("keyDown", FlxG.keys.onKeyDown);
		@:privateAccess
		windowStar2.stage.addEventListener("keyUp", FlxG.keys.onKeyUp);

		starBG2 = new Bitmap(Assets.getBitmapData(Paths.getPath("images/star-festival/star.png", IMAGE, "shared")));
		starBG2.y = 50;
		windowStar2.stage.addChild(starBG2);
		WindowsAPI.getWindowsTransparent();
		Application.current.window.focus();
		FlxG.autoPause = oldAutoPause;
	}

	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}

		if (videoPlaying) {
			videoSprite.pause();
		}
		/*var sub;
		if (!chartingMode) sub = new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y);
		else sub = new PauseSubStateOG(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y);
		*/
		var sub = new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y);

		#if desktop
		sub.openCallback = () ->
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song, iconP2.getCharacter());
		};
		#end
		openSubState(sub);
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false; // Don't mess with this on Lua!!!

	function doDeathCheck(?force:Bool = false)
	{
		if (force || (health <= 0 && !practiceMode && !isDead))
		{
			var ret:Dynamic = callOnLuas('onGameOver', [], false);
			if (ret != FunkinLua.Function_Stop)
			{
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens)
				{
					tween.active = true;
				}
				for (timer in modchartTimers)
				{
					timer.active = true;
				}
				var sub = new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0],
					boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y);

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				sub.openCallback = () ->
				{
					DiscordClient.changePresence("Game Over - " + detailsText, SONG.song, iconP2.getCharacter());
				};
				#end
				openSubState(sub);
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote()
	{
		while (eventNotes.length > 0)
		{
			var leStrumTime:Float = eventNotes[0].strumTime;
			if (Conductor.songPosition < leStrumTime)
			{
				break;
			}

			var value1:String = '';
			if (eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if (eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String)
	{
		var pressed:Bool = Reflect.getProperty(controls, key);
		// trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String)
	{
		switch (eventName)
		{
			case 'Dadbattle Spotlight':
				var val:Null<Int> = Std.parseInt(value1);
				if (val == null)
					val = 0;

				switch (Std.parseInt(value1))
				{
					case 1, 2, 3: // enable and target dad
						if (val == 1) // enable
						{
							dadbattleBlack.visible = true;
							dadbattleLight.visible = true;
							dadbattleSmokes.visible = true;
							defaultCamZoom += 0.12;
						}

						var who:Character = dad;
						if (val > 2)
							who = boyfriend;
						// 2 only targets dad
						dadbattleLight.alpha = 0;
						new FlxTimer().start(0.12, function(tmr:FlxTimer)
						{
							dadbattleLight.alpha = 0.375;
						});
						dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 50);

					default:
						dadbattleBlack.visible = false;
						dadbattleLight.visible = false;
						defaultCamZoom -= 0.12;
						FlxTween.tween(dadbattleSmokes, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween)
							{
								dadbattleSmokes.visible = false;
							}
						});
				}

			case 'Hey!':
				var value:Int = 2;
				switch (value1.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if (Math.isNaN(time) || time <= 0)
					time = 0.6;

				if (value != 0)
				{
					if (dad.curCharacter.startsWith('gf'))
					{ // Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					}
					else if (gf != null)
					{
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}
				}
				if (value != 1)
				{
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if (Math.isNaN(value) || value < 1)
					value = 1;
				gfSpeed = value;

			case "The Star Moment":
				#if windows
				popupWindowStar1();
				popupWindowStar2();
				#else
				trace("bimbows exclusive event");
				#end

			case "The Star Moment The Sequel":
				#if windows
				var display = Application.current.window.display.currentMode;
				starBG1.rotation = -5;
				starBG2.rotation = 5;
				FlxTween.tween(starBG1, {rotation: 5}, 2, {ease: FlxEase.circInOut, type: PINGPONG});
				FlxTween.tween(starBG2, {rotation: -5}, 2, {ease: FlxEase.circInOut, type: PINGPONG});
				FlxTween.tween(windowStar1, {x: 50, y: 50}, 1, {ease: FlxEase.circInOut});
				FlxTween.tween(windowStar2, {x: Std.int(display.width - (500 + 50)), y: Std.int(display.height - (500 + 50))}, 1, {ease: FlxEase.circInOut});
				#else
				trace("bimbows exclusive event");
				#end

			case 'Add Camera Zoom':
				if (ClientPrefs.camZooms && FlxG.camera.zoom < 1.35)
				{
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if (Math.isNaN(camZoom))
						camZoom = 0.015;
					if (Math.isNaN(hudZoom))
						hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
					try
					{
						if (Paths.formatToSongPathNoLowerCase(SONG.song).startsWith('Cosmic-Battle'))
							abberationShaderIntensity += beatShaderAmount;
					}
					catch (e)
					{
					}
				}

			case 'Play Animation':
				// trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch (value2.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if (Math.isNaN(val2))
							val2 = 0;

						switch (val2)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if (camFollow != null)
				{
					var val1:Float = Std.parseFloat(value1);
					var val2:Float = Std.parseFloat(value2);
					if (Math.isNaN(val1))
						val1 = 0;
					if (Math.isNaN(val2))
						val2 = 0;

					isCameraOnForcedPos = false;
					if (!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2)))
					{
						camFollow.x = val1;
						camFollow.y = val2;
						isCameraOnForcedPos = true;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch (value1.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if (Math.isNaN(val))
							val = 0;

						switch (val)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length)
				{
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if (split[0] != null)
						duration = Std.parseFloat(split[0].trim());
					if (split[1] != null)
						intensity = Std.parseFloat(split[1].trim());
					if (Math.isNaN(duration))
						duration = 0;
					if (Math.isNaN(intensity))
						intensity = 0;

					if (duration > 0 && intensity != 0)
					{
						targetsArray[i].shake(intensity, duration);
					}
				}

			case 'Change Character':
				var charType:Int = 0;
				switch (value1.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if (Math.isNaN(charType)) charType = 0;
				}

				switch (charType)
				{
					case 0:
						if (boyfriend.curCharacter != value2)
						{
							if (!boyfriendMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.fixArrowRGB();
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if (dad.curCharacter != value2)
						{
							if (!dadMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							dad.fixArrowRGB();
							if (!dad.curCharacter.startsWith('gf'))
							{
								if (wasGf && gf != null)
								{
									gf.visible = true;
								}
							}
							else if (gf != null)
							{
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if (gf != null)
						{
							if (gf.curCharacter != value2)
							{
								if (!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if (Math.isNaN(val1))
					val1 = 1;
				if (Math.isNaN(val2))
					val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if (val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2 / playbackRate, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}

			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if (killMe.length > 1)
				{
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length - 1], value2);
				}
				else
				{
					FunkinLua.setVarInArray(this, value1, value2);
				}

			// lua events
			case "CosmicMoveArrowsSwap":
				FlxTween.tween(thehealth, {x: 320 / 2 - 100}, 0.6, {ease: FlxEase.quartInOut});

			case "Must Press Swap":
				FlxTween.tween(thehealth, {x: 2180 / 2 - 100}, 0.8, {ease: FlxEase.quartInOut});

			case "Cinematics":
				if (thehealth != null)
				{
					if (["Star-Festival", "Toad-Brigade", "Toad-Brigade-Erect", "Hell-Prominence-Erect"].contains(Paths.formatToSongPathNoLowerCase(SONG.song)))
					{
						FlxTween.tween(thehealth, {alpha: (value1 == "1" ? 0 : 1)}, (value1 == "1" ? 0.75 : 0.5), {ease: FlxEase.cubeInOut});
					}
					else
					{
						FlxTween.tween(thehealth, {y: (value1 == "1" ? 135 : 50)}, 1.6, {ease: FlxEase.linear});
					}
				}

			case "startcountdown":
				var time = Conductor.crochet / 1000;
				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);
				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if (isPixelStage)
				{
					introAlts = introAssets.get('pixel');
					antialias = false;
				}
				for (ints in 0...4)
				{
					new FlxTimer().start(time * ints, (_) ->
					{
						var sndNum = (ints == 0 ? "3" : (ints == 1 ? "2" : (ints == 2 ? "1" : "Go")));
						var imgNum = switch (ints)
						{
							case 1: 0;
							case 2: 1;
							case 3: 2;
							default: 0;
						}
						FlxG.sound.play(Paths.sound('intro$sndNum$introSoundsSuffix'), 0.6);
						doCountdown(ints, introAlts[imgNum], antialias);
					});
				}

			case "Cam Boom Speed":
				var val1:Int = Std.parseInt(value1);
				var val2:Float = Std.parseFloat(value2);
				if (Math.isNaN(val1))
					val1 = 4;
				if (Math.isNaN(val2))
					val2 = 1;
				camZoomingInterval = val1;
				camZoomingMult = val2;
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection():Void
	{
		if (SONG.sections[curSection] == null)
			return;

		if (gf != null && SONG.sections[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.sections[curSection].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;

	public function moveCamera(isDad:Bool)
	{
		if (isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];

			tweenCamIn();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {
					ease: FlxEase.elasticInOut,
					onComplete: function(twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn()
	{
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3)
		{
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {
				ease: FlxEase.elasticInOut,
				onComplete: function(twn:FlxTween)
				{
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float)
	{
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; // In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if (ClientPrefs.noteOffset <= 0 || ignoreNoteOffset)
		{
			finishCallback();
		}
		else
		{
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer)
			{
				finishCallback();
			});
		}
	}

	public var transitioning = false;

	function endReturn():Void
	{
		hasendingdialog = false;
		FlxG.sound.playMusic(Paths.music('freakyMenu'));
		MusicBeatState.switchState(new MainMenuState());
	}

	public function endSong():Void
	{
		// Should kill you if you tried to cheat
		if (!startingSong)
		{
			notes.forEach(function(daNote:Note)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					health -= 0.05 * healthLoss;
				}
			}

			#if !debug
			if (doDeathCheck())
			{
				return;
			}
			#end
		}

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if (achievementObj != null)
		{
			return;
		}
		else
		{
			var achieve:String = checkForAchievement([
				'love-driven_nomiss',
				'star-festival_nomiss',
				'toad-brigade_nomiss',
				'hey-there_nomiss',
				'gusty-garden_nomiss',
				'funky-factory_nomiss',
				'cosmic-battle_nomiss',
				'hell-prominence_nomiss',
				'purple-comet_nomiss',
				'luminous-swing_nomiss',
				'panic-club_nomiss',
				'revolution_nomiss',
				'sports-mix_nomiss',
				'rooftop-shame_nomiss',
				'wii-modder_nomiss',
				'sexy-luigi_nomiss',
				'deluded-sensation_nomiss',
				'chuckster_nomiss',
				'starship-mario_nomiss',
				'hell-valley_nomiss',
				'astronomical_nomiss',
				'purple-coin-lyrics_nomiss',
				'prankster-club_nomiss',
				'toad-brigade-erect_nomiss',
				'cosmic-battle-erect_nomiss',
				'gusty-garden-erect_nomiss',
				'hell-valley-erect_nomiss',
				'the-wish_nomiss',
				'gusty-garden-old_nomiss'
			]);

			if (achieve != null)
			{
				startAchievement(achieve);
				return;
			}

			/*var assignFC:Int = 0;
				for (i in 4...25)
				{
					var name:String = Achievements.achievementsStuff[i][2];
					trace(name);
					if (Achievements.achievementsMap.get(name) == null)
						break;
					assignFC++;
					if (assignFC == 21)
					{
						var achieve:String = checkForAchievement(['nomiss_finish']);
						if(achieve != null)
							startAchievement(achieve);
					}
			}*/
		}
		#end

		var ret:Dynamic = callOnLuas('onEndSong', [], false);
		if (ret != FunkinLua.Function_Stop && !transitioning)
		{
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if (keMode)
					percent = (keAccuracy / 100);
				if (Math.isNaN(percent))
					percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}
			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;
				campaignAccuracy += ratingPercent;

				if (storyPlaylist[storyPlaylist.indexOf(SONG.song) + 1] == null)
				{
					WeekData.loadTheFirstEnabledMod();

					cancelMusicFadeTween();
					if (FlxTransitionableState.skipNextTransIn)
					{
						CustomFadeTransition.nextCamera = null;
					}

					campaignAccuracy = campaignAccuracy / storyPlaylist.length;
					campaignAccuracy = campaignAccuracy * 100;
					campaignAccuracy = Math.round(campaignAccuracy * 100) / 100; // to the nearest hundredth

					// if ()
					if (!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false))
					{
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						ClientPrefs.saveToSlot("weekCompleted", StoryMenuState.weekCompleted);
					}
					changedDifficulty = false;

					// local variable, used for the average accuracy calculation
					/*var accCalc:Float = 0;

						for (acc in weekAccuracyCalc) {
						 accCalc += acc;
						}

						accCalc /= weekAccuracyCalc.length;

						weekAccuracy = FlxMath.roundDecimal(accCalc * 100, 2);
						weekAccuracyCalc = []; */

					if (hasendingdialog)
					{
						camHUD.visible = false;
						endingcutscenefade = true;
						schoolIntro(doof2);
					}
					else
					{
						exitSong(true);
					}
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[PlayState.storyPlaylist.indexOf(SONG.song) + 1]) + difficulty);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[PlayState.storyPlaylist.indexOf(SONG.song) + 1] + difficulty,
						PlayState.storyPlaylist[PlayState.storyPlaylist.indexOf(SONG.song) + 1]);
					FlxG.sound.music.stop();

					cancelMusicFadeTween();
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				WeekData.loadTheFirstEnabledMod();
				cancelMusicFadeTween();
				if (FlxTransitionableState.skipNextTransIn)
				{
					CustomFadeTransition.nextCamera = null;
				}
				exitSong(true);
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;

	function startAchievement(achieve:String)
	{
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}

	function achievementEnd():Void
	{
		achievementObj = null;
		if (endingSong && !inCutscene)
		{
			endSong();
		}
	}
	#end

	public function KillNotes()
	{
		while (notes.length > 0)
		{
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;
	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	private function cachePopUpScore()
	{
		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';
		if (isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		Paths.image(pixelShitPart1 + "sick" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "good" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "bad" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "shit" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "combo" + pixelShitPart2);

		for (i in 0...10)
		{
			Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2);
		}
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		// trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();

		// tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.getRatingByName(Scoring.judgeNote(noteDiff / playbackRate,
			ClientPrefs.scoreMode == "Legacy" ? LEGACY : PBOT1));

		if (daRating.name.toLowerCase() == "miss")
		{
			noteMiss(note);
			return;
		}

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if (!note.ratingDisabled)
			daRating.increase();
		note.rating = daRating.name;

		if (daRating.noteSplash && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if (!note.ratingDisabled)
		{
			songHits++;
			totalPlayed++;
			RecalculateRating(false);
		}

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
		rating.y = boyfriend.y + 50;
		rating.x = boyfriend.x - 255;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.scale.set(0.65, 0.65);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.x = rating.x - 55;
		comboSpr.y = rating.y + 20;
		comboSpr.scale.set(0.45, 0.45);
		comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		comboSpr.visible = (!ClientPrefs.hideHud && showCombo);
		comboSpr.y += 60;
		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;

		insert(members.indexOf(strumLineNotes), rating);

		if (!ClientPrefs.comboStacking)
		{
			if (lastRating != null)
				lastRating.kill();
			lastRating = rating;
		}

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if (combo >= 1000)
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		if (combo >= 100 || keMode)
			seperatedScore.push(Math.floor(combo / 100) % 10);
		if (combo >= 10 || keMode)
			seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (showCombo)
		{
			if (combo >= 10)
			{
				insert(members.indexOf(strumLineNotes), comboSpr);
			}
		}
		if (!ClientPrefs.comboStacking && !keMode)
		{
			if (lastCombo != null)
				lastCombo.kill();
			lastCombo = comboSpr;
		}
		if (lastScore != null)
		{
			while (lastScore.length > 0)
			{
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.x = rating.x + (43 * daLoop) - 55;
			numScore.y = rating.y + 105;
			numScore.scale.set(0.5, 0.5);

			if (!ClientPrefs.comboStacking)
				lastScore.push(numScore);

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.hideHud;

			// if (combo >= 10 || combo == 0)
			if (showComboNum)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
			if (numScore.x > xThing)
				xThing = numScore.x;
		}
		comboSpr.x = xThing + 50;
		/*
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
	}

	public var strumsBlocked:Array<Bool> = [];

	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		// trace('Pressed: ' + eventKey);

		if (!cpuControlled
			&& startedCountdown
			&& !paused
			&& key > -1
			&& (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if (!boyfriend.stunned && generatedMusic && !endingSong)
			{
				// more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				// var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (strumsBlocked[daNote.noteData] != true
						&& daNote.canBeHit
						&& daNote.mustPress
						&& !daNote.tooLate
						&& !daNote.wasGoodHit
						&& !daNote.isSustainNote
						&& !daNote.blockHit)
					{
						if (daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							// notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0)
				{
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes)
						{
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1)
							{
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							}
							else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped)
						{
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}
					}
				}
				else
				{
					callOnLuas('onGhostTap', [key]);
					if (canMiss)
					{
						noteMissPress(key);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				// more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if (strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		// trace('pressed: ' + controlArray);
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if (!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if (spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
				if (spr.cover != null)
				{
					if (spr.cover.animation.curAnim.name != 'end')
						spr.cover.visible = false;
					var note = spr.heldNote;
					if (note != null)
					{
						for (child in note.tail)
						{
							if (!child.wasGoodHit)
							{
								child.blockHit = true;
							}
						}
						note.tail = [];
						spr.heldNote = null;
					}
				}
			}

			callOnLuas('onKeyRelease', [key]);
		}
		// trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if (key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if (key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	function noteCheck(key:Bool, keyP:Bool, note:Note):Void // sorry lol
	{
		if (keyP && ((note.canBeHit && !note.blockHit) && !note.tooLate))
		{
			goodNoteHit(note);
		}
		else if ((key && ((note.canBeHit && !note.blockHit) && !note.tooLate)) && note.isSustainNote)
		{
			goodNoteHit(note);
		}
		else
		{
			badNoteCheck(note);
		}
	}

	function badNoteCheck(note:Note)
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var parsedHoldArray:Array<Bool> = parseKeys("_P");

		if (parsedHoldArray.contains(true) && note.isSustainNote)
		{
			trace("aaaaaa");
			noteMiss(note);
			updateKeAccuracy();
		}
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var parsedHoldArray:Array<Bool> = parseKeys();
		var parsedArray:Array<Bool> = parseKeys("_P");

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if (ClientPrefs.controllerMode)
		{
			if (parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if (parsedArray[i] && strumsBlocked[i] != true)
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		var char:Character = boyfriend;
		if (opponentMode)
			char = dad;
		if (!char.stunned && generatedMusic)
			if (startedCountdown && !char.stunned && generatedMusic)
			{
				// rewritten inputs???
				if (keMode)
				{
					// FlxG.watch.addQuick('asdfa', upP);
					if (parsedHoldArray.contains(true) && !char.stunned && generatedMusic)
					{
						char.holdTimer = 0;

						var possibleNotes:Array<Note> = [];

						var ignoreList:Array<Int> = [];

						notes.forEachAlive(function(daNote:Note)
						{
							if (daNote.canBeHit && !daNote.blockHit && daNote.mustPress && !daNote.tooLate)
							{
								// the sorting probably doesn't need to be in here? who cares lol
								possibleNotes.push(daNote);
								possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

								ignoreList.push(daNote.noteData);
							}
						});

						if (possibleNotes.length > 0)
						{
							var daNote = possibleNotes[0];

							// Jump notes
							if (possibleNotes.length >= 2)
							{
								if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
								{
									for (coolNote in possibleNotes)
									{
										if (parsedHoldArray[coolNote.noteData] && (daNote.canBeHit && !daNote.blockHit))
											goodNoteHit(coolNote);
										else
										{
											var inIgnoreList:Bool = false;
											for (shit in 0...ignoreList.length)
											{
												if (parsedHoldArray[ignoreList[shit]])
													inIgnoreList = true;
											}
										}
									}
								}
								{
									for (coolNote in possibleNotes)
									{
										noteCheck(parsedHoldArray[coolNote.noteData], parsedArray[daNote.noteData], coolNote);
									}
								}
							}
							else // regular notes?
							{
								noteCheck(parsedHoldArray[daNote.noteData], parsedArray[daNote.noteData], daNote);
							}
						}
					}
				}
				else
				{
					notes.forEachAlive(function(daNote:Note)
					{
						// hold note functions
						if (strumsBlocked[daNote.noteData] != true
							&& daNote.isSustainNote
							&& parsedHoldArray[daNote.noteData]
							&& daNote.canBeHit
							&& daNote.mustPress
							&& !daNote.tooLate
							&& !daNote.wasGoodHit
							&& !daNote.blockHit)
						{
							goodNoteHit(daNote);
						}
					});
				}

				if (parsedHoldArray.contains(true) && !endingSong)
				{
					#if ACHIEVEMENTS_ALLOWED
					////var achieve:String = checkForAchievement(['oversinging']);
					////if (achieve != null) {
					////	startAchievement(achieve);
					////}
					#end
				}
				else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration
					&& boyfriend.animation.curAnim.name.startsWith('sing')
					&& !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.dance();
					// boyfriend.animation.curAnim.finish();
				}
				if (parsedHoldArray.contains(true) && !endingSong && opponentMode)
				{/*bruh*/}
				else if (dad.holdTimer > Conductor.stepCrochet * 0.001 * dad.singDuration
					&& dad.animation.curAnim.name.startsWith('sing')
					&& !dad.animation.curAnim.name.endsWith('miss'))
					dad.dance();
			}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if (ClientPrefs.controllerMode || strumsBlocked.contains(true))
		{
			var parsedArray:Array<Bool> = parseKeys('_R');
			if (parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if (parsedArray[i] || strumsBlocked[i] == true)
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	private function parseKeys(?suffix:String = ''):Array<Bool>
	{
		var ret:Array<Bool> = [];
		for (i in 0...controlArray.length)
		{
			ret[i] = Reflect.getProperty(controls, controlArray[i] + suffix);
		}
		return ret;
	}

	var hasDareDevil:Bool = false;
	var thehealth:FlxSprite;

	function setuphealthbar()
	{
		var thex:Float = (ClientPrefs.downScroll ? 2180 : 250) / 2 - 100;
		var they:Float = (!ClientPrefs.downScroll ? 450 : 50);
		if (Paths.formatToSongPathNoLowerCase(SONG.song) == "Deluded-Sensation")
			thex = (ClientPrefs.downScroll ? 2180 / 2 - 255 : 250 / 2 - -50);
		if (Paths.formatToSongPathNoLowerCase(SONG.song) == "Cosmic-Battle"
			|| Paths.formatToSongPathNoLowerCase(SONG.song) == "Cosmic-Battle-Erect"
			|| Paths.formatToSongPathNoLowerCase(SONG.song) == "Cosmic-Battle-Old"
			|| Paths.formatToSongPathNoLowerCase(SONG.song) == "Rooftop-Shame"
			|| Paths.formatToSongPathNoLowerCase(SONG.song) == "Rooftop-Shame-Old")
		{
			thex = 2180 / 2 - 100;
			they = 50;
		}
		thehealth = new FlxSprite(thex, they);
		thehealth.frames = Paths.getSparrowAtlas('healthSprite', "shared");
		thehealth.animation.addByPrefix("3", "full", 1, false, false, false);
		thehealth.animation.addByPrefix("2", "mid", 1, false, false, false);
		thehealth.animation.addByPrefix("1", "low", 1, false, false, false);
		thehealth.animation.addByPrefix("0", "low", 1, false, false, false);
		thehealth.animation.addByPrefix("dareDevil-3", "dareDevil-full", 1, false, false, false);
		thehealth.animation.addByPrefix("dareDevil-2", "dareDevil-mid", 1, false, false, false);
		thehealth.animation.addByPrefix("dareDevil-1", "dareDevil-low", 1, false, false, false);
		thehealth.animation.addByPrefix("dareDevil-0", "dareDevil-low", 1, false, false, false);
		add(thehealth);
		thehealth.camera = camHUD;
		hasDareDevil = songsWithDareDevil.contains(Paths.formatToSongPathNoLowerCase(SONG.song));
		health = (hasDareDevil ? 1 : 3);
	}

	function updatehealthbar()
		thehealth.animation.play((hasDareDevil ? "dareDevil-" : "") + Std.string(health));

	function noteMiss(daNote:Note):Void
	{ // You didn't hit the key and let it go offscreen, also used by Hurt Notes
		if (keMode && daNote.tail.length != 0)
		{
			daNote.blockHit = daNote.tooLate = true;

			if (daNote.blockHit)
				trace("died");
			else
				trace("forgor to die");

			// ඞ
			for (sus in daNote.tail)
			{
				sus.blockHit = sus.tooLate = true;
			}
		}
		// Dupe note remove
		notes.forEachAlive(function(note:Note)
		{
			if (daNote != note
				&& daNote.mustPress
				&& daNote.noteData == note.noteData
				&& daNote.isSustainNote == note.isSustainNote
				&& Math.abs(daNote.strumTime - note.strumTime) < 1)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		if (!hasCoolHealth)
			health -= daNote.missHealth * healthLoss;
		else
		{
			if (!immunity)
			{
				health -= 1;
				spawnCoinNote();
				immunity = true;
			}
		}

		if (instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		// For testing purposes
		// trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		if (!practiceMode)
			songScore -= 10;

		totalPlayed++;
		RecalculateRating(true);

		var char:Character = opponentMode ? dad : boyfriend;
		if (daNote.gfNote)
		{
			char = gf;
		}

		if (char != null && !daNote.noMissAnimation && char.hasMissAnimations)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daNote.animSuffix;
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [
			notes.members.indexOf(daNote),
			daNote.noteData,
			daNote.noteType,
			daNote.isSustainNote
		]);
	}

	function noteMissPress(direction:Int = 1):Void // You pressed a key when there was no notes to press for this key
	{
		if (ClientPrefs.ghostTapping)
			return; // fuck it

		if (!boyfriend.stunned)
		{
			health -= 0.05 * healthLoss;
			if (instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if (!practiceMode)
				songScore -= 10;
			if (!endingSong)
			{
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating(true);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

				// get stunned for 1/60 of a second, makes you able to
				new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
				{
					boyfriend.stunned = false;
			});*/

			if (boyfriend.hasMissAnimations)
			{
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
		callOnLuas('noteMissPress', [direction]);
	}

	function opponentNoteHit(note:Note):Void
	{
		if (SONG.needsVoices)
			vocals.volume = 1;
		StrumPlayAnim(opponentStrums, Conductor.stepCrochet * 1.25 / 1000 / playbackRate, note);
		note.hitByOpponent = true;

		if (opponentMode)
			boyfriendNoteHit(note);
		else
			dadNoteHit(note);
	}

	function dadNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if (note.noteType == 'Hey!' && dad.animOffsets.exists('hey'))
		{
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		}
		else if (!note.noAnimation)
		{
			var altAnim:String = note.animSuffix;

			if (SONG.sections[curSection] != null)
			{
				if (SONG.sections[curSection].altAnim && !SONG.sections[curSection].gfSection)
				{
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if (note.gfNote)
			{
				char = gf;
			}

			if (char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		callOnLuas('opponentNoteHit', [
			notes.members.indexOf(note),
			Math.abs(note.noteData),
			note.noteType,
			note.isSustainNote
		]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (curSong == "Love Driven" && !note.isSustainNote)
			{
				var displayNoteProperties:Map<String, Dynamic> = displayNote.data.displayNoteProperties;
				var angles = displayNoteProperties.get("noteAngles");
				if (displayNoteProperties.get('oldData') == -1)
				{
					displayNote.angle = angles.get(0).get(note.noteData);
					FlxTween.tween(displayNote, {alpha: 0.4}, 0.2, {ease: FlxEase.smootherStepOut});

					displayNote.rgbShader.r = note.rgbShader.r;
					displayNote.rgbShader.g = note.rgbShader.g;
					displayNote.rgbShader.b = note.rgbShader.b;
				}
				else
				{
					displayNoteProperties.get("timer").cancel();
					FlxTween.cancelTweensOf(displayNote);
					var the = 70;
					if ([0, 3].contains(note.noteData))
					{
						displayNote.x = displayNoteProperties.get("defaultX") + the * (note.noteData == 3 ? 1 : -1);
						displayNote.y = displayNoteProperties.get("defaultY");
					}
					else if ([1, 2].contains(note.noteData))
					{
						displayNote.y = displayNoteProperties.get("defaultY") + the * (note.noteData == 1 ? 1 : -1);
						displayNote.x = displayNoteProperties.get("defaultX");
					}
					FlxTween.tween(displayNote, {x: displayNoteProperties.get("defaultX"), y: displayNoteProperties.get("defaultY")}, 0.2,
						{ease: FlxEase.smootherStepOut});

					FlxTween.tween(displayNote, {angle: (angles.get(displayNoteProperties.get('oldData'))).get(note.noteData)}, 0.2,
						{ease: FlxEase.smootherStepOut});
					FlxTween.tween(displayNote, {alpha: 0.4}, 0.2, {ease: FlxEase.smootherStepOut});

					FlxTween.cancelTweensOf(displayNoteProperties.get("rColorSprite"));
					FlxTween.cancelTweensOf(displayNoteProperties.get("gColorSprite"));
					FlxTween.cancelTweensOf(displayNoteProperties.get("bColorSprite"));
					FlxTween.color(displayNoteProperties.get("rColorSprite"), 0.2, displayNote.rgbShader.r, note.rgbShader.r, {
						ease: FlxEase.smootherStepOut,
						onUpdate: function(_)
						{
							displayNote.rgbShader.r = displayNoteProperties.get("rColorSprite").color;
						}
					});
					FlxTween.color(displayNoteProperties.get("gColorSprite"), 0.2, displayNote.rgbShader.g, note.rgbShader.g, {
						ease: FlxEase.smootherStepOut,
						onUpdate: function(_)
						{
							displayNote.rgbShader.g = displayNoteProperties.get("gColorSprite").color;
						}
					});
					FlxTween.color(displayNoteProperties.get("bColorSprite"), 0.2, displayNote.rgbShader.b, note.rgbShader.b, {
						ease: FlxEase.smootherStepOut,
						onUpdate: function(_)
						{
							displayNote.rgbShader.b = displayNoteProperties.get("bColorSprite").color;
						}
					});
					displayNoteProperties.get("timer").start(1.5, function(_)
					{
						FlxTween.tween(displayNote, {alpha: 0}, 0.2, {ease: FlxEase.smootherStepOut});
					});
				}
				displayNoteProperties.set('oldData', note.noteData);
			}

			if (note.healNote && hasCoolHealth)
			{
				health += 1;
				note.wasGoodHit = true;
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				FlxG.sound.play(Paths.sound('coinget', 'preload'), 1);
				if (cpuControlled)
					StrumPlayAnim(playerStrums, Conductor.stepCrochet * 1.25 / 1000 / playbackRate, note);
			}

			var canAddScore = (!practiceMode && !cpuControlled);

			if (note.isSustainNote && ClientPrefs.scoreMode == "Legacy")
				canAddScore = false;

			if (canAddScore)
			{
				var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
				var score:Int = Scoring.scoreNote(noteDiff / playbackRate, ClientPrefs.scoreMode == "Legacy" ? LEGACY : PBOT1);
				songScore += score;
				updateScore(false);
			}

			if (cpuControlled && (note.ignoreNote || note.hitCausesMiss))
				return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if (note.hitCausesMiss)
			{
				noteMiss(note);
				if (!note.noteSplashDisabled && !note.isSustainNote)
				{
					spawnNoteSplashOnNote(note);
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				if (combo > 99999)
					combo = 99999; // up to 99999 just in case lol
				popUpScore(note);
			}
			if (!hasCoolHealth)
				health += note.hitHealth * healthGain;

			if (opponentMode)
				dadNoteHit(note);
			else
				boyfriendNoteHit(note);

			note.wasGoodHit = true;
			if (cpuControlled)
			{
				StrumPlayAnim(playerStrums, Conductor.stepCrochet * 1.25 / 1000 / playbackRate, note);
			}
			else
			{
				var spr = playerStrums.members[note.noteData];
				if (spr != null)
				{
					spr.updateRgb([note.rgbShader.r, note.rgbShader.g, note.rgbShader.b]);
					if (!keMode)
					{
						spr.coverLogic(note);
						if (note.tail.length > 0)
							spr.heldNote = note;
						if (!note.isSustainNote && (note.rating == 'bad' || note.rating == 'shit'))
						{
							makeGhostNote(note);
							combo = 0;
						}
					}
					if (spr.animation.curAnim.name != "confirm")
						spr.playAnim('confirm', true);
				}
			}
		}
	}

	function makeGhostNote(note:Note)
	{
		var ghost:Note = new Note(0, note.noteData, null, false, false, false);
		add(ghost);
		ghost.x = note.x;
		ghost.y = note.y;
		ghost.flipX = note.flipX;
		ghost.flipY = note.flipY;
		ghost.texture = note.texture;
		ghost.angle = note.angle;
		ghost.cameras = [camHUD];
		ghost.alpha = note.alpha * .5;
		ghost.ignoreNote = true;
		ghost.blockHit = true;
		ghost.rgbShader.r = CoolUtil.int_desat(note.rgbShader.r, 0.8); // desaturate note
		ghost.rgbShader.g = CoolUtil.int_desat(note.rgbShader.g, 0.8);
		ghost.rgbShader.b = CoolUtil.int_desat(note.rgbShader.b, 0.8);
		FlxTween.tween(ghost, {alpha: 0}, 1, {ease: FlxEase.quadOut, startDelay: 0.1, onComplete: (_) -> ghost.destroy()});
	}

	function boyfriendNoteHit(note:Note)
	{
		if (!note.noMissAnimation)
		{
			switch (note.noteType)
			{
				case 'Hurt Note': // Hurt note
					if (boyfriend.animation.getByName('hurt') != null)
					{
						boyfriend.playAnim('hurt', true);
						boyfriend.specialAnim = true;
					}
			}
		}

		if (!note.noAnimation)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

			if (note.gfNote)
			{
				if (gf != null)
				{
					gf.playAnim(animToPlay + note.animSuffix, true);
					gf.holdTimer = 0;
				}
			}
			else
			{
				boyfriend.playAnim(animToPlay + note.animSuffix, true);
				boyfriend.holdTimer = 0;
			}

			if (note.noteType == 'Hey!')
			{
				if (boyfriend.animOffsets.exists('hey'))
				{
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = 0.6;
				}

				if (gf != null && gf.animOffsets.exists('cheer'))
				{
					gf.playAnim('cheer', true);
					gf.specialAnim = true;
					gf.heyTimer = 0.6;
				}
			}
		}
		vocals.volume = 1;

		var isSus:Bool = note.isSustainNote; // GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
		var leData:Int = Math.round(Math.abs(note.noteData));
		var leType:String = note.noteType;
		callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	public function spawnNoteSplashOnNote(note:Note)
	{
		if (ClientPrefs.noteSplashes && note != null)
		{
			var strum:StrumNote = playerStrums.members[note.noteData];
			if (strum != null)
			{
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null)
	{
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, note);
		grpNoteSplashes.add(splash);
	}

	override function destroy()
	{
		for (lua in luaArray)
		{
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];

		#if hscript
		if (FunkinLua.hscript != null)
			FunkinLua.hscript = null;
		#end

		if (!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		FlxG.mouse.visible = false;
		MouseCursors.loadCursor("nintendo_normal");
		Application.current.window.title = GameConfig.defaultWindowName;
		FlxG.stage.filters = [];
		super.destroy();
	}

	public static function cancelMusicFadeTween()
	{
		if (FlxG.sound.music.fadeTween != null)
		{
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;

	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)))
		{
			resyncVocals();
		}

		if (curStep == lastStepHit)
		{
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', [curStep]);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var lastBeatHit:Int = -1;
	var needSongLength:Float = 0;

	function setSongLength(newLength:Float, funni:Bool = true)
	{
		needSongLength = newLength;
		if (newLength >= FlxG.sound.music.length)
			needSongLength = FlxG.sound.music.length;
		if (!funni)
		{
			songLength = newLength;
			if (newLength >= FlxG.sound.music.length)
				songLength = FlxG.sound.music.length;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (lastBeatHit >= curBeat)
		{
			// trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (((camZooming && !keMode) && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms) && curBeat % camZoomingInterval == 0)
		{
			FlxG.camera.zoom += 0.015 * camZoomingMult;
			camHUD.zoom += 0.03 * camZoomingMult;
			try
			{
				if (Paths.formatToSongPathNoLowerCase(SONG.song).startsWith('Cosmic-Battle'))
					abberationShaderIntensity += beatShaderAmount * camZoomingMult;
			}
			catch (e)
			{
			}
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (!keMode)
		{
			iconP1.bump();
			iconP2.bump();
		}
		else
		{
			iconP1.setGraphicSize(Std.int(iconP1.width + 30));
			iconP2.setGraphicSize(Std.int(iconP2.width + 30));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

		if ((keMode && camZooming) && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (gf != null
			&& curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0
			&& gf.animation.curAnim != null
			&& !gf.animation.curAnim.name.startsWith("sing")
			&& !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0
			&& boyfriend.animation.curAnim != null
			&& !boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0
			&& dad.animation.curAnim != null
			&& !dad.animation.curAnim.name.startsWith('sing')
			&& !dad.stunned)
		{
			dad.dance();
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); // DAWGG?????
		callOnLuas('onBeatHit', [curBeat]);
	}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.sections[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
			}

			if (SONG.sections[curSection].changeBPM)
			{
				Conductor.changeBPM(SONG.sections[curSection].bpm);
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.sections[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.sections[curSection].altAnim);
			setOnLuas('gfSection', SONG.sections[curSection].gfSection);
		}

		setOnLuas('curSection', curSection);
		callOnLuas('onSectionHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic
	{
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if (exclusions == null)
			exclusions = [];
		for (script in luaArray)
		{
			if (exclusions.contains(script.scriptName))
				continue;

			var ret:Dynamic = script.call(event, args);
			if (ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;

			// had to do this because there is a bug in haxe where Stop != Continue doesnt work
			var bool:Bool = ret == FunkinLua.Function_Continue;
			if (!bool && ret != 0)
			{
				returnVal = cast ret;
			}
		}
		#end
		// trace(event, returnVal);
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic)
	{
		#if LUA_ALLOWED
		for (i in 0...luaArray.length)
		{
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(sprGroup:FlxTypedGroup<StrumNote>, time:Float, note:Note)
	{
		var spr:StrumNote = sprGroup.members[note.noteData];

		if (keMode)
			return;
		if (spr != null)
		{
			if (spr.animation.curAnim.name != "confirm")
				spr.playAnim('confirm', false);
			spr.updateRgb([note.rgbShader.r, note.rgbShader.g, note.rgbShader.b]);
			spr.coverLogic(note);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;

	public function RecalculateRating(badHit:Bool = false)
	{
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);
		if (keMode)
			updateKeAccuracy();

		var ret:Dynamic = callOnLuas('onRecalculateRating', [], false);
		if (ret != FunkinLua.Function_Stop && !keMode)
		{
			if (totalPlayed < 1) // Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				// trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if (ratingPercent >= 1)
				{
					ratingName = Language.getString('gameplay.ratings.${ratingStuff[ratingStuff.length - 1][0]}'); // Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length - 1)
					{
						if (ratingPercent < ratingStuff[i][1])
						{
							ratingName = Language.getString('gameplay.ratings.${ratingStuff[i][0]}');
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0)
				ratingFC = "SFC";
			if (goods > 0)
				ratingFC = "GFC";
			if (bads > 0 || shits > 0)
				ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10)
				ratingFC = "SDCB";
			else if (songMisses >= 10)
				ratingFC = "Clear";
		}
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		// if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) /*|| ClientPrefs.getGameplaySetting('botplay', false)*/);
		for (i in 0...achievesToCheck.length)
		{
			var achievementSongName:Array<String> = achievesToCheck[i].split('_');
			var achievementName:String = achievesToCheck[i];
			if (!Achievements.isAchievementUnlocked(achievementName) /* && !cpuControlled*/)
			{
				var unlock:Bool = false;

				if (achievementName.contains(WeekData.getWeekFileName())
					&& achievementName.endsWith('nomiss')) // any FC achievements, name should be "weekFileName_nomiss", e.g: "weekd_nomiss";
				{
					if (isStoryMode && campaignMisses + songMisses < 1 && storyPlaylist.length <= 1 && !usedPractice)
						unlock = true;
				}
				if (achievementName.contains(WeekData.getWeekFileName())
					&& achievementName.endsWith('beat')) // any beat week achievements, name should be "weekFileName_beat", e.g: "weekd_beat";
				{
					if (isStoryMode && storyPlaylist.length <= 1 && !usedPractice)
						unlock = true;
				}
				if (songMisses == 0
					&& achievementSongName[0] == Paths.formatToSongPath(SONG.song)
					&& achievementName.endsWith('nomiss')) // any beat song achievements, name should be "songname_beat", e.g: "weekd_beat";
				{
					if (!usedPractice)
						unlock = true;
				}
				if (achievementName.contains('sugarcoat') && yPress)
					unlock = true;

				if (unlock)
				{
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	public static var freeplayWeek:String = "";

	public static function exitSong(end:Bool = false)
	{
		FlxAnimationController.globalSpeed = 1;
		FlxG.sound.music.pitch = 1;
		instance.playbackRate = 1;
		instance.updateTime = false;
		instance.vocals.volume = 0;
		instance.vocals.pause();
		if (isStoryMode)
		{
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				MusicBeatState.switchStateStickers(new StoryMenuState());
			}
		}
		else
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			MusicBeatState.switchStateStickers(new FreeplaySelectState(freeplayWeek));
		}
	}

	function doCountdown(swagCounter:Int, spritePath:String, ?antialiasing:Bool)
	{
		var countdownSprite = countdownSpr.clone();
		callOnLuas('onCountdownTick', [swagCounter]);
		switch (swagCounter)
		{
			case 1 | 2 | 3:
				countdownSprite.loadGraphic(Paths.image(spritePath));
				countdownSprite.cameras = [camOther];
				countdownSprite.scrollFactor.set();
				countdownSprite.updateHitbox();

				if (PlayState.isPixelStage)
					countdownSprite.setGraphicSize(Std.int(countdownSprite.width * daPixelZoom));

				countdownSprite.screenCenter();
				countdownSprite.antialiasing = (antialiasing != null ? antialiasing : !PlayState.isPixelStage);
				insert(members.indexOf(notes), countdownSprite);

				var goal = keMode ? ({alpha: 0}) : {y: countdownSprite.y + 100, alpha: 0};
				FlxTween.tween(countdownSprite, goal, Conductor.crochet / 1000 / playbackRate, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						remove(countdownSprite);
						countdownSprite.destroy();
					}
				});
			case 4:
		}
	}

	var curLight:Int = -1;
	var curLightEvent:Int = -1;

	public function spawnCoinNote()
	{
		for (note in unspawnNotes)
		{
			if ((note.mustPress && note.noteType == "") && (!note.isSustainNote && note.tail.length == 0))
			{
				if (FlxG.random.bool(35))
				{
					trace('note number ${unspawnNotes.indexOf(note)} is now a heal note');
					note.noteType = "Heal Note"; // aka the coin note
					break;
				}
			}
		}
	}
}
