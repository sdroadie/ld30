package ;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTileblock;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.group.FlxTypedGroup;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxSort;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;

/**
 * ...
 * @author Jeremy Neal
 */
class PlayState extends FlxState  
{
	
	private var _player:Player;
	private var _platform:PlatformNormal;
	private var _lastPlatform:PlatformNormal;
	private var _platforms:FlxTypedGroup<PlatformNormal>;
	private var _backgroundImage:FlxBackdrop;
	private var collisionsAllowed:Int;
	private var secondCamera:FlxCamera;
	private var propFactory:PropFactory;
	private var props:FlxSpriteGroup;
	
	private static var BG_WIDTH:Int = 2048;
	
	public static var GRAPHIC_PREFIX_PLATFORM:String;
	public static var GRAPHIC_PREFIX_PLATFORM_V1:String = "images/v1/platform_";
	public static var GRAPHIC_PREFIX_PLATFORM_V2:String = "images/v2/platform_";
	public static var GRAPHIC_PREFIX_PLATFORM_V3:String = "images/v3/platform_";
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		GRAPHIC_PREFIX_PLATFORM = GRAPHIC_PREFIX_PLATFORM_V1;
		
		secondCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		secondCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(secondCamera);
		
		_backgroundImage = new FlxBackdrop("images/star.png", 1, 1, true, false);
		add(_backgroundImage);
		
		// Map one camera to background, other to foreground.
		_backgroundImage.cameras = [FlxG.camera];
		FlxCamera.defaultCameras = [secondCamera];
		
		// Adjust camera to fit background.
		FlxG.camera.zoom = FlxG.width / BG_WIDTH;
		FlxG.camera.setSize(BG_WIDTH, BG_WIDTH);
		
		// Setup platforms and props
		_platforms = new FlxTypedGroup<PlatformNormal>();
		propFactory = new PropFactory();
		props = new FlxSpriteGroup();
		
		for (i in 1...100) {
			var randomDistance = FlxRandom.floatRanged(6, 10) * 100;
			var randomHeight = FlxRandom.floatRanged( 5, 12.5) * 10;
			_platform = new PlatformNormal(i * randomDistance, FlxG.height - randomHeight);
			
			// Add prop
			var prop = propFactory.getRandomProp(_platform.m_x + _platform.m_width / 2, _platform.height);
			props.add(prop);
			
			_platforms.add(_platform);
		}
		
		_platforms.sort(byX);
		
		collisionsAllowed = 3;
		
		_player = new Player(0, 0, 1);
		_player.setPosition(0, FlxG.height - _player.height);
		
		add(props);
		add(_platforms);
		add(_player);
		
		FlxG.mouse.visible = false;
		
		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		_player = FlxDestroyUtil.destroy(_player);
		_platform = FlxDestroyUtil.destroy(_platform);
		_platforms = FlxDestroyUtil.destroy(_platforms);
		_backgroundImage = FlxDestroyUtil.destroy(_backgroundImage);
		
		FlxG.mouse.visible = true;
		
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		FlxG.collide(_platforms, _player, checkCollision);
		
		FlxG.camera.setBounds(0, 0, 100000, BG_WIDTH, true);
		FlxG.camera.follow(_player, FlxCamera.STYLE_PLATFORMER, new FlxPoint(-BG_WIDTH, 0));
		
		secondCamera.setBounds(0, 0, 100000, FlxG.height, true);
		secondCamera.follow(_player, FlxCamera.STYLE_PLATFORMER);
		
		if (collisionsAllowed == 0) {
			_player.animation.curAnim.stop();
			_player.animation.play("cry");
			new FlxTimer(2.0, callBack, 1); 
		}
		
		_platforms.forEachDead(addToScene);
		_platforms.forEachAlive(cull);
		
		super.update();
	}
	
	private function checkCollision(obstacle:FlxSprite, player:FlxSprite):Void
	{
		// If player hits the side, change obstacle color.
		if (player.y + player.height > obstacle.y)
		{
			// Show the collision, and count it.
			collisionsAllowed -= 1;
			secondCamera.shake();
			
			if (player.animation.curAnim != null)
				player.animation.curAnim.stop();
			player.animation.play("fall", true);
			
			// Move the player away.
			player.x -= 150;
			player.velocity.x = 0;
			player.acceleration.x = 0;
			
		}
		
		FlxObject.separate(obstacle, player);
	}
	
	private function byX(Order:Int, Obj1:FlxObject, Obj2:FlxObject):Int
	{
		return FlxSort.byValues(Order, Obj1.x, Obj2.x);
	}
	
	private function addToScene(platform:Platform)
	{
		// If within three screen lengths, add to scene.
		if (platform.members[0].x < _player.x + FlxG.width * 3)
		{
			platform.revive();
		}
	}
	
	private function cull(platform:Platform)
	{
		if (platform.members[0].x < _player.x - FlxG.width * 3)
		{
			platform.kill();
		}
	}
	
	private function callBack(Timer:FlxTimer):Void
	{
		FlxG.switchState(new GameOverState());
	}
}