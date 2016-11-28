module progress;

public import progress.bar;
public import progress.counter;
public import progress.spinner;

import std.stdio;
import std.datetime;
import std.algorithm;
import std.concurrency;
import std.math;

immutable SHOW_CURSOR = "\x1b[?25h";
immutable HIDE_CURSOR = "\x1b[?25l";

class Infinite
{
    alias file = stderr;
    size_t sma_window = 10;
    size_t index;
    StopWatch sw;
    long ts;
    long[] dt;
    bool hide_cursor = false;
    size_t _width;

    this()
    {
        this.index = 0;
        this.sw.start();
        ts = 0;
    }

    @property real avg()
    {
        return (dt.length == 0)?0:sum(dt) / dt.length / (10 ^^ 6);
    }

    @property real elapsed()
    {
        return sw.peek().usecs / (10 ^^ 6);
    }

    void update()
    {
        
    }
    void start()
    {
        file.writeln();
    }
    void finish()
    {
        if (hide_cursor)
        {
            file.write(SHOW_CURSOR);
            file.flush();
        }
        file.writeln();
    }
    void next(size_t n=1)
    {
        if (n > 0)
        {
            long now = sw.peek().usecs;
            long _dt = (now - ts) / n;
            this.dt = this.dt[($<sma_window)?0:$-sma_window+1 .. $] ~ _dt;
            this.ts = now;
        }
        this.index += n;
        this.update();
    }
    auto iter(T)(T[] it)
    {
        return new Generator!T(
        {
            foreach(x;it)
            {
                yield(x);
                this.next();
            }
            this.finish();
        }
        );
    }
    void write(string s)
    {
        string b = repeat("\b",_width);
        file.write(b,s);
        this._width = s.length;
        file.flush();
    }
}

class Progress : Infinite
{
    size_t max;
    this(size_t max=100)
    {
        this.max = max;
    }

    @property long eta()
    {
        return cast(long)ceil(this.avg * this.remaining);
    }
    @property real percent()
    {
        return this.progress * 100;
    }
    @property real progress()
    {
        return min(1,cast(real)this.index / this.max);
    }
    @property real remaining()
    {
        return std.algorithm.comparison.max(this.max - this.index,0);
    }
    override void start()
    {
        this.update();
    }
    void goto_index(size_t index)
    {
        size_t incr = index - this.index;
        this.next(incr);
    }
    auto iter(T)(T[] it)
    {
        try{
            this.max = it.length;
        }
        catch (Exception e)
        {
            
        }
        return new Generator!T(
        {
            foreach(x;it)
            {
                yield(x);
                this.next();
            }
            this.finish();
        }
        );
    }
}

string repeat(string s,size_t n)
{
    string result;
    foreach(i;0 .. n)
    {
        result ~= s;
    }
    return result;
}
