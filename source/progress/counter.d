module progress.counter;
import progress;

import std.conv;
import std.algorithm : min;

class Counter : Infinite
{
    this()
    {
        this.hide_cursor = true;
        super();
    }
    override void update()
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
    override void update()
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
    override void update()
    {
        size_t nphases = this.phases.length;
        size_t index = min(nphases-1,cast(size_t)(this.progress * nphases));
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
