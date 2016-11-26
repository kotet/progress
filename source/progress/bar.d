module progress.bar;
import progress;
import std.format;
import std.string;
import std.array;

class Bar : Progress
{
    size_t width = 32;
    string delegate() message;
    string delegate() suffix;
    string bar_prefix = " |";
    string bar_suffix = "| ";
    string empty_fill = " ";
    string fill = "#";
    bool hide_cursor = true;

    this()
    {
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
