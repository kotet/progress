module progress;

import core.time : dur, Duration;

public import progress.bar;
public import progress.counter;
public import progress.spinner;

static import std.algorithm;
import std.concurrency : Generator, yield;
import std.conv : to;
import std.datetime : StopWatch;
import std.math : ceil;
import std.range.primitives : walkLength;
import std.range : ElementType, isInfinite, isInputRange;
import std.stdio : stderr;
import std.string : countchars, leftJustify;

package immutable SHOW_CURSOR = "\x1b[?25h";
package immutable HIDE_CURSOR = "\x1b[?25l";

package class Infinite
{
private:
    size_t sma_window = 10;
    StopWatch sw;
    Duration ts;
    Duration[] dt;
    size_t _width;
    size_t _height;
    Duration last_draw;

protected:
    alias file = stderr;
    void write(string s)
    {
        string message = this.message();
        string result = (message ~ s).leftJustify(this._width);
        file.write("\r", result);
        this._width = std.algorithm.max(this._width, (message ~ s).walkLength);
        file.flush();
    }

    void writeln(string s)
    {
        file.write("\r\x1b[K", repeat("\x1b[1A\x1b[K", _height));
        file.write(s);
        _height = s.countchars("\n");
    }

public:
    size_t index;
    bool hide_cursor = false;
    string delegate() message;
    Duration refresh_rate = dur!"seconds"(1) / 60;
    this()
    {
        this.index = 0;
        this.message = { return ""; };
        this.sw.start();
        this.ts = Duration.zero;
        this.last_draw = Duration.zero;
        if (hide_cursor)
            file.write(HIDE_CURSOR);
    }

    @property Duration avg()
    {
        return (dt.length == 0) ? Duration.zero : std.algorithm.reduce!((a, b) {
            return a + b;
        })(dt) / dt.length;
    }

    @property Duration elapsed()
    {
        return sw.peek().to!Duration;
    }

    void update()
    {
        if (refresh_rate < sw.peek() - this.last_draw)
        {
            this.last_draw = sw.peek().to!Duration;
            force_update();
        }
    }

    void force_update()
    {
    }

    void start()
    {

    }

    void finish()
    {
        force_update();
        if (hide_cursor)
        {
            file.write(SHOW_CURSOR);
            file.flush();
        }
        file.writeln();
    }

    void next(size_t n = 1)
    {
        if (n > 0)
        {
            immutable Duration now = sw.peek().to!Duration;
            immutable Duration _dt = (now - ts) / n;
            this.dt = this.dt[($ < sma_window) ? 0 : $ - sma_window + 1 .. $] ~ _dt;
            this.ts = now;
        }
        this.index += n;
        this.update();
    }

    auto iter(R)(R it) if (isInputRange!R && !isInfinite!R)
    {
        return new Generator!(ElementType!R)({
            foreach (i; 0 .. it.length)
            {
                yield(it.front);
                it.popFront();
                this.next();
            }
            this.finish();
        });
    }
}

class Progress : Infinite
{
    size_t max;
    this(size_t max = 100)
    {
        this.max = max;
    }

    @property Duration eta()
    {
        return this.avg * this.remaining;
    }

    @property real percent()
    {
        return this.progress * 100;
    }

    @property real progress()
    {
        return std.algorithm.min(1, cast(real) this.index / this.max);
    }

    @property size_t remaining()
    {
        return std.algorithm.max(this.max - this.index, 0);
    }

    override void start()
    {
        this.force_update();
    }

    void goto_index(size_t index)
    {
        size_t incr = index - this.index;
        this.next(incr);
    }

    auto iter(R)(R it) if (isInputRange!R && !isInfinite!R)
    {
        this.max = it.length;
        return new Generator!(ElementType!R)({
            foreach (i; 0 .. it.length)
            {
                yield(it.front);
                it.popFront();
                this.next();
            }
            this.finish();
        });
    }
}

package string repeat(string s, size_t n)
{
    string result;
    foreach (i; 0 .. n)
    {
        result ~= s;
    }
    return result;
}
