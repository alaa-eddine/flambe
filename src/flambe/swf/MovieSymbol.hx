//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.swf;

import flambe.display.Sprite;
import flambe.math.FMath;
import flambe.math.Matrix;
import flambe.swf.Format;

using flambe.util.Arrays;

/**
 * Defines a Flump movie.
 */
class MovieSymbol
    implements Symbol
{
    public var name (get_name, null) :String;

    public var layers (default, null) :Array<MovieLayer>;

    /**
     * The total number of frames in this movie.
     */
    public var frames (default, null) :Int;

    /**
     * The rate that this movie is played, in frames per second.
     */
    public var frameRate (default, null) :Float;

    /**
     * The duration of this animation in seconds.
     */
    public var duration (default, null) :Float;

    public function new (lib :Library, json :MovieFormat)
    {
        _name = json.id;
        frameRate = lib.frameRate;

        frames = 0;
        layers = Arrays.create(json.layers.length);
        for (ii in 0...layers.length) {
            var layer = new MovieLayer(json.layers[ii]);
            frames = cast Math.max(layer.frames, frames);
            layers[ii] = layer;
        }
        duration = frames / frameRate;
    }

    public function get_name () :String
    {
        return _name;
    }

    public function createSprite () :Sprite
    {
        return new MovieSprite(this);
    }

    private var _name :String;
}

class MovieLayer
{
    public var name (default, null) :String;
    public var keyframes (default, null) :Array<MovieKeyframe>;
    public var frames (get_frames, null) :Int;

    /** The symbol in the last keyframe that has one, or null if there are no symbol keyframes. */
    public var lastSymbol :Symbol = null;

    /** True if this layer contains keyframes with at least two different symbols. */
    public var multipleSymbols :Bool = false;

    public function new (json :LayerFormat)
    {
        name = json.name;

        var prevKf = null;
        keyframes = Arrays.create(json.keyframes.length);
        for (ii in 0...keyframes.length) {
            prevKf = new MovieKeyframe(json.keyframes[ii], prevKf);
            keyframes[ii] = prevKf;
        }
    }

    private function get_frames () :Int
    {
        var lastKf = keyframes[keyframes.length - 1];
        return lastKf.index + Std.int(lastKf.duration);
    }
}

class MovieKeyframe
{
    public var index (default, null) :Int;

    /** The length of this keyframe in frames. */
    public var duration (default, null) :Int;

    public var symbolName (default, null) :String;
    public var symbol :Symbol = null;

    public var label (default, null) :String;

    public var x (default, null) :Float = 0;
    public var y (default, null) :Float = 0;
    public var scaleX (default, null) :Float = 1;
    public var scaleY (default, null) :Float = 1;
    public var skewX (default, null) :Float = 0;
    public var skewY (default, null) :Float = 0;

    public var pivotX (default, null) :Float = 0;
    public var pivotY (default, null) :Float = 0;

    public var alpha (default, null) :Float = 1;

    public var visible (default, null) :Bool = true;

    /** Whether this keyframe should be tweened to the next. */
    public var tweened (default, null) :Bool = true;

    /** Easing amount, if tweened is true. */
    public var ease (default, null) :Float = 0;

    public function new (json :KeyframeFormat, prevKf :MovieKeyframe)
    {
        index = (prevKf != null) ? prevKf.index + prevKf.duration : 0;

        duration = json.duration;
        label = json.label;
        symbolName = json.ref;

        var loc = json.loc;
        if (loc != null) {
            x = loc[0];
            y = loc[1];
        }

        var scale = json.scale;
        if (scale != null) {
            scaleX = scale[0];
            scaleY = scale[1];
        }

        var skew = json.skew;
        if (skew != null) {
            skewX = skew[0];
            skewY = skew[1];
        }

        var pivot = json.pivot;
        if (pivot != null) {
            pivotX = pivot[0];
            pivotY = pivot[1];
        }

        if (json.alpha != null) {
            alpha = json.alpha;
        }

        if (json.visible != null) {
            visible = json.visible;
        }

        if (json.tweened != null) {
            tweened = json.tweened;
        }

        if (json.ease != null) {
            ease = json.ease;
        }
    }
}
