module progress;

public import progress.bar;
public import progress.counter;
public import progress.spinner;

import std.stdio;
import std.datetime;
import std.algorithm;
import std.concurrency;
import std.math;
import std.string : countchars;
import std.range : isInfinite,isInputRange,ElementType;

package immutable SHOW_CURSOR = "\x1b[?25h";
package immutable HIDE_CURSOR = "\x1b[?25l";

class Infinite
{
    private:
        size_t sma_window = 10;
        StopWatch sw;
        long ts;
        long[] dt;
        size_t _width;
        size_t _height;

    protected:
        alias file = stderr;
        void write(string s)
        {
            string b = repeat("\b",_width);
            string message = this.message();
            file.write(b,message,s);
            this._width = message.length + s.length;
            file.flush();
        }
        void writeln(string s)
        {
            file.write(repeat("\r\x1b[K\x1b[1A",_height));
            file.write(s);
            _height = s.countchars("\n");
        }
    public:
        size_t index;
        bool hide_cursor = false;
        string delegate() message;
        this()
        {
            this.index = 0;
            this.message = {return "";};
            this.sw.start();
            ts = 0;
            if (hide_cursor) file.write(HIDE_CURSOR);
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
        auto iter(R)(R it) if(isInputRange!R && !isInfinite!R)
        {
            return new Generator!(ElementType!R)(
            {
                foreach(i;0 .. it.length)
                {
                    yield(it.front);
                    it.popFront();
                    this.next();
                }
                this.finish();
            }
            );
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
    auto iter(R)(R it) if (isInputRange!R && !isInfinite!R)
    {
        this.max = it.length;
        return new Generator!(ElementType!R)(
        {
            foreach(i;0 .. it.length)
            {
                yield(it.front);
                it.popFront();
                this.next();
            }
            this.finish();
        }
        );
    }
}

package string repeat(string s,size_t n)
{
    string result;
    foreach(i;0 .. n)
    {
        result ~= s;
    }
    return result;
}
