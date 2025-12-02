#if !MOBILE_BUILD
// ============================================================
// FULL VISUALIZER (Desktop Only)
// ============================================================

package graphics.audio;

import funkin.vis.dsp.SpectralAnalyzer;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import openfl.display.BlendMode;

typedef VisualizerPararms =
{
    var barCount:Int;
    var width:Int;
    var height:Int;
    var spacing:Int;
    var peakLines:Bool;
    var color:FlxColor;
    var ?minFrequency:Float;
    var ?maxFrequency:Float;
    var ?peakColor:FlxColor;
    var ?gradient:Array<FlxColor>;
}

class SpectrogramVisualizer extends FlxSpriteGroup
{
    var analyzer:SpectralAnalyzer;
    var bars:FlxSpriteGroup = new FlxSpriteGroup();
    var peakLines:FlxSpriteGroup = new FlxSpriteGroup();

    public var minFrequency(default, set):Float;
    function set_minFrequency(value:Float):Float {
        if (analyzer != null) analyzer.minFreq = value;
        return minFrequency = value;
    }

    public var maxFrequency(default, set):Float;
    function set_maxFrequency(value:Float):Float {
        if (analyzer != null) analyzer.maxFreq = value;
        return maxFrequency = value;
    }

    var barCount:Int;
    var sound:FlxSound;

    public var havePeakLines(default, set):Bool;
    function set_havePeakLines(value:Bool):Bool {
        havePeakLines = value;
        for (i in peakLines.members) i.visible = value;
        return value;
    }

    public var visualizerColor(default, set):FlxColor = FlxColor.WHITE;
    function set_visualizerColor(value:FlxColor):FlxColor {
        for (i in bars.members) i.color = value;
        return visualizerColor = value;
    }

    public var peakColor(default, set):FlxColor = FlxColor.WHITE;
    function set_peakColor(value:FlxColor):FlxColor {
        if (havePeakLines)
            for (i in peakLines.members) i.color = value;
        return peakColor = value;
    }

    public var gradientColor(default, set):Array<FlxColor>;
    function set_gradientColor(value:Array<FlxColor>):Array<FlxColor> {
        for (i in bars.members)
            FlxGradient.overlayGradientOnFlxSprite(i, Std.int(i.width), Std.int(i.height), [FlxColor.WHITE]);

        switch (value.length) {
            case 0: set_visualizerColor(visualizerColor);
            case 1: set_visualizerColor(value[0]);
            default:
                for (i in bars.members)
                    FlxGradient.overlayGradientOnFlxSprite(i, Std.int(i.width), Std.int(i.height), value);
        }
        return gradientColor = value;
    }

    public var blendMode(default, set):BlendMode;
    function set_blendMode(value:BlendMode):BlendMode {
        for (i in bars.members) i.blend = value;
        for (i in peakLines.members) i.blend = value;
        return blendMode = value;
    }

    public var visualizerWidth(default, null):Int;
    public var visualizerHeight(default, null):Int;

    public function new(params:VisualizerPararms) {
        super();

        this.barCount = params.barCount;
        this.visualizerWidth = params.width;
        this.visualizerHeight = params.height;

        add(bars);
        add(peakLines);

        generateLines(params.barCount, visualizerWidth, visualizerHeight, params.spacing);
        generatePeakLines(params.barCount, params.width, params.spacing);

        if (params.gradient != null)
            gradientColor = params.gradient;
        else
            visualizerColor = params.color;

        this.peakColor = params.peakColor ?? params.color;
        this.havePeakLines = params.peakLines;
    }

    override function draw():Void {
        if (sound != null) {
            var levels = analyzer.getLevels();
            for (i in 0...min(bars.members.length, levels.length)) {
                bars.members[i].scale.y = levels[i].value;
                if (havePeakLines)
                    peakLines.members[i].y = this.y + height - (levels[i].peak * height);
            }
        }
        super.draw();
    }

    @:generic
    static inline function min<T:Float>(x:T, y:T):T return x > y ? y : x;

    public function start(sound:FlxSound):Void {
        this.sound = sound;
        @:privateAccess var source = cast sound._channel.__audioSource;

        analyzer = new SpectralAnalyzer(source, barCount, 0.1, 10, sound);
        analyzer.fftN = 512;
    }

    public function stop():Void {
        sound = null;
        analyzer = null;
    }

    function generateLines(barCount:Int, width:Int, height:Int, spacing:Int) {
        for (i in 0...barCount) {
            var spr = new FlxSprite((i / barCount) * width, 0)
                .makeGraphic(Std.int((1 / barCount) * width) - spacing, height, FlxColor.WHITE);
            spr.origin.set(0, spr.height);
            bars.add(spr);
        }
    }

    function generatePeakLines(barCount:Int, width:Int, spacing:Int) {
        for (i in 0...barCount) {
            var spr = new FlxSprite((i / barCount) * width, 0)
                .makeGraphic(Std.int((1 / barCount) * width) - spacing, 1, FlxColor.WHITE);
            peakLines.add(spr);
        }
    }

    override function set_visible(value:Bool) {
        super.set_visible(value);
        for (i in peakLines.members) i.visible = value;
        this.havePeakLines = this.havePeakLines;
        return value;
    }
}

#else

// ============================================================
// MOBILE STUB (Compiles but does nothing)
// ============================================================

package graphics.audio;

import flixel.group.FlxSpriteGroup;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;

typedef VisualizerPararms =
{
    var barCount:Int;
    var width:Int;
    var height:Int;
    var spacing:Int;
    var peakLines:Bool;
    var color:FlxColor;
    var ?minFrequency:Float;
    var ?maxFrequency:Float;
    var ?peakColor:FlxColor;
    var ?gradient:Array<FlxColor>;
}

class SpectrogramVisualizer extends FlxSpriteGroup
{
    public function new(params:VisualizerPararms) super();
    public function start(sound:FlxSound):Void {}
    public function stop():Void {}
}

#end
