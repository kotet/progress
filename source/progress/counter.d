module progress.counter;

import progress;

import std.algorithm : min;
import std.conv : to;

class Counter : Infinite
{
    this()
    {
        this.hide_cursor = true;
        super();
    }

    override void force_update()
    {
        this.write(this.index.to!string);
    }
}

class Countdown : Progress
{
    this()
    {
        this.hide_cursor = true;
        super();
    }

    override void force_update()
    {
        this.write(this.remaining.to!string);
    }
}

class Stack : Progress
{
    string[] phases;
    this()
    {
        this.hide_cursor = true;
        this.phases = [" ", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"];
        super();
    }

    override void force_update()
    {
        size_t nphases = this.phases.length;
        size_t index = min(nphases - 1, cast(size_t)(this.progress * nphases));
        this.write(this.phases[index]);
    }
}

class Pie : Stack
{
    this()
    {
        super();
        this.phases = ["○", "◔", "◑", "◕", "●"];
    }
}
