package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxDestroyUtil;
import openfl.system.System;

using flixel.util.FlxSpriteUtil;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	private var _titleText:FlxText;
	private var _startButton:FlxButton;
	private var _creditsButton:FlxButton;
	private var _quitButton:FlxButton;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		_titleText = new FlxText(0, 0, 100, "LD30", 14);
		_titleText.screenCenter();
		_titleText.alignment = "center";
		add(_titleText);
		
		_startButton = new FlxButton(0, 0, "Play", startGame);
		_startButton.setPosition((FlxG.width - _startButton.width) / 2, FlxG.height / 2 + _startButton.height);
		add(_startButton);
		
		_creditsButton = new FlxButton(0, 0, "Credits", showCredits);
		_creditsButton.setPosition((FlxG.width - _creditsButton.width) / 2, FlxG.height / 2 + _creditsButton.height * 2);
		add(_creditsButton);
		
		_quitButton = new FlxButton(0, 0, "Exit", exitGame);
		_quitButton.setPosition((FlxG.width - _quitButton.width) / 2, FlxG.height / 2 + _quitButton.height * 3);
		add(_quitButton);
		
		super.create();
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		_titleText = FlxDestroyUtil.destroy(_titleText);
		_startButton = FlxDestroyUtil.destroy(_startButton);
		_quitButton = FlxDestroyUtil.destroy(_quitButton);
		_creditsButton = FlxDestroyUtil.destroy(_creditsButton);
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
	}
	
	private function startGame():Void
	{
		FlxG.switchState(new PlayState());
	}
	
	private function exitGame():Void
	{
		System.exit(0);
	}
	
	private function showCredits():Void
	{
		FlxG.switchState(new CreditsState());
	}
}