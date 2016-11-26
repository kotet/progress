module progress.bar;
import progress;
import std.format : format;
import std.array : join,back;
import std.conv : to;
import std.algorithm : max;

class Bar : Progress
{
    size_t width = 32;
    string delegate() message;
    string delegate() suffix;
    string bar_prefix;
    string bar_suffix;
    string empty_fill;
    string fill;
    bool hide_cursor;

    this()
    {
        width = 32;
        bar_prefix = " |";
        bar_suffix = "| ";
        empty_fill = " ";
        fill = "#";
        hide_cursor = true;
        this.message = {return "";};
        this.suffix = {return format("%s/%s",this.index,this.max);};
        if(hide_cursor) file.write(HIDE_CURSOR);
    }
    override void update()
    {
        size_t filled_length = cast(size_t)(this.width * this.progress);
        size_t empty_length = this.width - filled_length;
        string message = this.message();
        string bar = repeat(this.fill,filled_length);
        string empty = repeat(this.empty_fill,empty_length);
        string suffix = this.suffix();
        string line = [
            message,
            this.bar_prefix,
            bar,
            empty,
            this.bar_suffix,
            suffix].join("");
        file.write("\r\x1b[K",line);
    }
}
class ChargingBar : Bar
{
    this()
    {
        super();
        bar_prefix = " ";
        bar_suffix = " ";
        empty_fill = "∙";
        fill = "█";
        suffix = {return this.percent.to!string() ~ "%";};
    }
}
class FillingSquaresBar : ChargingBar
{
    this()
    {
        super();
        empty_fill = "▢";
        fill = "▣";
    }
}
class FillingCirclesBar : ChargingBar
{
    this()
    {
        super();
        empty_fill = "◯";
        fill = "◉";
    }
}
class IncrementalBar : Bar
{
    string[] phases;
    this()
    {
        super();
        phases = [" ", "▏", "▎", "▍", "▌", "▋", "▊", "▉", "█"];
    }
    override void update()
    {
        size_t nphases = this.phases.length;
        size_t expanded_length = cast(size_t)(nphases * this.width * this.progress);
        size_t filled_length = cast(size_t)(this.width * this.progress);
        size_t empty_length = this.width - filled_length;
        size_t phase = expanded_length - (filled_length * nphases);

        string message = this.message();
        string bar = repeat(phases.back, filled_length);
        string current = (0<=phase)?this.phases[phase]:"";
        string empty = repeat(this.empty_fill, std.algorithm.max(0,empty_length));
        string suffix = this.suffix();
        string line = [
            message,
            this.bar_prefix,
            bar,
            current,
            empty,
            this.bar_suffix,
            suffix].join("");
            file.write("\r\x1b[K",line);
    }
}
class ShadyBar : IncrementalBar
{
    this()
    {
        super();
        phases = [" ", "░", "▒", "▓", "█"];
    }
}
