module progress.dman;
import progress;

import std.regex : regex, replaceAll;

private immutable string[] DMANS = [import("dman0.txt"), import("dman1.txt")];

class DmanSpinner : Infinite
{
    this()
    {
        this.message = { return ""; };
        hide_cursor = true;
        super();
    }

    override void force_update()
    {
        size_t i = this.index % DMANS.length;
        string message = this.message();
        string padding = "\n" ~ repeat(" ", message.length);
        this.writeln(message ~ DMANS[i].replaceAll(regex(r"\n", "g"), padding));
    }
}
