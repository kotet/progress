module progress.bar;

import progress;

static import std.algorithm;
import std.array : back, join;
import std.conv : to;
import std.format : format;

class Bar : Progress
{
    size_t width = 32;
    string delegate() suffix;
    string bar_prefix;
    string bar_suffix;
    string empty_fill;
    string fill;

    this()
    {
        width = 32;
        bar_prefix = " |";
        bar_suffix = "| ";
        empty_fill = " ";
        fill = "#";
        hide_cursor = true;
        this.message = { return ""; };
        this.suffix = { return format("%s/%s", this.index, this.max); };
        if (hide_cursor)
            file.write(HIDE_CURSOR);
    }

    override void force_update()
    {
        size_t filled_length = cast(size_t)(this.width * this.progress);
        size_t empty_length = this.width - filled_length;
        string message = this.message();
        string bar = repeat(this.fill, filled_length);
        string empty = repeat(this.empty_fill, empty_length);
        string suffix = this.suffix();
        string line = [this.bar_prefix, bar, empty, this.bar_suffix, suffix].join("");
        this.write(line);
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
        suffix = { return this.percent.to!string() ~ "%"; };
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

    override void force_update()
    {
        immutable size_t nphases = this.phases.length;
        size_t expanded_length = cast(size_t)(nphases * this.width * this.progress);
        size_t filled_length = cast(size_t)(this.width * this.progress);
        size_t empty_length = this.width - filled_length;
        size_t phase = expanded_length - (filled_length * nphases);

        string bar = repeat(phases.back, filled_length);
        string current = (phase <= nphases) ? this.phases[phase] : "";
        string empty = repeat(this.empty_fill, std.algorithm.max(0, empty_length));
        string suffix = this.suffix();
        string line = [this.bar_prefix, bar, current, empty, this.bar_suffix, suffix].join("");
        this.write(line);
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
