module progress;

import core.time : dur, Duration;

public import progress.bar;
public import progress.counter;
public import progress.spinner;

static import std.algorithm;
import std.array : uninitializedArray;
import std.concurrency : Generator, yield;
import std.conv : to;
import std.exception : assumeUnique;
import std.math : ceil;
import std.range.primitives : walkLength;
import std.range : ElementType, isInfinite, isInputRange;
import std.stdio : stderr;
import std.string : leftJustify;

package enum SHOW_CURSOR = "\x1b[?25h";
package enum HIDE_CURSOR = "\x1b[?25l";
package enum LINEFEED = "\r";
package enum ERASE_IN_LINE = "\x1b[K";
package enum CURSOR_UP = "\x1b[1A";

package class Infinite
{
private:
    size_t sma_window = 10;
    static if (2077 <= __VERSION__)
    {
        import std.datetime.stopwatch;

        StopWatch sw;
    }
    else
    {
        import std.datetime;

        StopWatch sw;
    }
    Duration ts;
    Duration[] dt;
    size_t _width;
    size_t _height;
    Duration last_draw;

protected:
    alias file = stderr;
    void writeln(string[] s...)
    {
        import std.array : Appender;

        static Appender!(char[]) buffer;
        buffer.clear();

        buffer.put(LINEFEED ~ ERASE_IN_LINE);
        foreach (_; 0 .. _height)
        {
            buffer.put(CURSOR_UP ~ ERASE_IN_LINE);
        }
        size_t tempHeight = 0;
        foreach (t; s)
        {
            buffer.put(t);
            tempHeight = std.algorithm.count(t, '\n');
        }
        file.write(buffer.data);
        _height = tempHeight;
    }

    void writeln(string s)
    {
        file.write(LINEFEED ~ ERASE_IN_LINE, repeat(CURSOR_UP ~ ERASE_IN_LINE, _height), s);
        _height = std.algorithm.count(s, "\n");
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

package string repeat(string s, size_t n) pure nothrow @trusted
{
    immutable len = s.length;
    auto buffer = uninitializedArray!(char[])(len * n);
    for (size_t i, pos; i < n; i++, pos += len)
    {
        buffer[pos .. pos + len] = s[];
    }
    return assumeUnique(buffer);
}
