package;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.util.FlxStringUtil;
import lime.utils.Assets;
import states.FreeplayState.SongMetadata;
#if desktop
import Discord.DiscordClient;
#end
using StringTools;

class ExtrendedFreeplayState extends MusicBeatState
{
    var songs:Array<SongMetadata> = [];

    var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('backgrounds/SUSSUS AMOGUS'));
    var curSelected:Int = 0;

    private var iconArray:Array<HealthIcon> = [];

    var swagText:FlxText = new FlxText(0, 0, 0, 'my poop is brimming', 85);

    var songColors:Array<FlxColor> = [
    	0xFFca1f6f, // GF
		0xFF4965FF, // DAVE
		0xFF00B515, // MISTER BAMBI r slur (i cant reclaim)
		0xFF00FFFF, //SPLIT THE THONNNNN
		0xFF000000 // sart.
    ];

	public static var category:Int = 0;
    
    private var grpSongs:FlxTypedGroup<Alphabet>;

    override function create() 
	{	
		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

        #if desktop DiscordClient.changePresence("In the Extra Songs Menu", null); #end

        bg.loadGraphic('backgrounds/freeplay/speis');
		bg.screenCenter();
		add(bg);

		addWeek(['Black-Spikes'], 2, ['dembo']);
		addWeek(['Blue-Stars'], 2, ['bamblix']);
		addWeek(['Figures'], 2, ['figumbi']);
		addWeek(['Contented'], 2, ['bambiminion']);
		addWeek(['Burger-Blast'], 2, ['bamburg']);
		addWeek(['Breakpoint'], 2, ['yambi']);
		addWeek(['Deep-Dish'], 2, ['cruster']);
		addWeek(['Fully-Breakfast'], 2, ['fully-breakfast']);

        grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

        swagText.setFormat(Paths.font("vcr.ttf"), 47, FlxColor.BLACK, LEFT);
		swagText.screenCenter(X);
		swagText.y += 50;
		add(swagText);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

            var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			iconArray.push(icon);
			add(icon);
		}

		changeSelection();

        super.create();
    }

    public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
            if ((song.toLowerCase() == 'dave-x-bambi-shipping-cute' && !FlxG.save.data.shipUnlocked) || (song.toLowerCase() == 'recovered-project' && !FlxG.save.data.foundRecoveredProject))
                addSong('unknown', weekNum, songCharacters[num], true);
            else
			    addSong(song, weekNum, songCharacters[num], false);

			if (songCharacters.length != 1)
				num++;
		}
	}

    public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		#if (flixel < "4.11.0")
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
		#end
	}

    override function update(p:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}


	super.update(p);

	if (controls.UI_UP)
            changeSelection(-1);

        if (controls.UI_DOWN)
            changeSelection(1);

        if (controls.BACK)
            FlxG.switchState(new MainMenuState());

        if (controls.ACCEPT)
		{
            switch (songs[curSelected].songName.toLowerCase()) {
                case 'unknown':
                    FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
                default:   
                    var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), 1);

                    trace(poop);

                    PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
                    PlayState.isStoryMode = false;
                    PlayState.storyDifficulty = 1;
                    PlayState.storyWeek = songs[curSelected].week;
					if(songs[curSelected].songName.toLowerCase() == 'cuberoot' || songs[curSelected].songName.toLowerCase() == 'cycles')
					{
						LoadingState.loadAndSwitchState(new PlayState());
					}
            }
		}
    }

	override function beatHit() {
		super.beatHit();

		for (i in 0...iconArray.length){
			iconArray[i].scale.x = 1.1;
			iconArray[i].scale.y = 1.1;
			FlxTween.tween(iconArray[i].scale, {x: 1, y: 1}, 0.2);
		}
	}

    function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;

		if (curSelected >= songs.length)
			curSelected = 0;

        switch(songs[curSelected].songName.toLowerCase()) {
            case 'unknown':
                swagText.text = 'A secret is required to unlock this song!';
                swagText.visible = true;
            default:
                swagText.visible = false;
        }

		#if PRELOAD_ALL
		if(songs[curSelected].songName.toLowerCase() != 'unknown')
			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		var bullShit:Int = 0;

        for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
		FlxTween.color(bg, 0.25, bg.color, songColors[songs[curSelected].week]);
	}
}
