import core.thread : Thread, dur;
import std.string : format;
import progress.spinner;

void main()
{
    {
        Spinner s = new Spinner();
        foreach (i; 0 .. 100)
        {
            Thread.sleep(dur!("msecs")(100));
            s.message = { return format("Basic spinner %s/100:", i + 1); };
            s.next();
        }
        s.finish();
    }
    {
        PieSpinner ps = new PieSpinner();
        scope (exit)
            ps.finish();
        foreach (i; 0 .. 100)
        {
            Thread.sleep(dur!("msecs")(100));
            ps.message = { return format("Pie spinner %s/100:", i + 1); };
            ps.next();
        }
    }
    {
        MoonSpinner ms = new MoonSpinner();
        scope (exit)
            ms.finish();
        foreach (i; 0 .. 100)
        {
            Thread.sleep(dur!("msecs")(100));
            ms.message = { return format("Moon spinner %s/100:", i + 1); };
            ms.next();
        }
    }
    {
        LineSpinner ls = new LineSpinner();
        scope (exit)
            ls.finish();
        foreach (i; 0 .. 100)
        {
            Thread.sleep(dur!("msecs")(100));
            ls.message = { return format("Line spinner %s/100:", i + 1); };
            ls.next();
        }
    }
}
