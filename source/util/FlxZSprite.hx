package util;

import flixel.FlxSprite;

/**
 * Extension wrapper to give ANY FlxSprite a safe z-index metadata field.
 * Does NOT modify Flixel internals.
 */
class FlxZSprite extends FlxSprite
{
    /** Metadata only! Does NOT affect rendering unless you sort manually */
    public var zIndex:Int = 0;

    public function new(x:Float = 0, y:Float = 0)
    {
        super(x, y);
    }
}
