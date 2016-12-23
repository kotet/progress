import core.thread : Thread,dur;
import std.range : iota,array;
import std.conv : to;
import progress.bar;

void main()
{
    {
        Bar b = new Bar();
        b.message = {return "Basic progress bar";};
        b.start();
        foreach(i;0 .. b.max)
        {
            Thread.sleep(dur!("msecs")(100));
            b.next();
        }
        b.finish();
    }
    {
        ChargingBar cb = new ChargingBar();
        cb.message = {return "Charging bar";};
        cb.suffix = {return cb.elapsed.to!string;};
        cb.max = 200;
        cb.start();
        foreach(i;0 .. cb.max)
        {
            Thread.sleep(dur!("msecs")(50));
            cb.next();
        }
        cb.finish();
    }
    {
        FillingSquaresBar fsb = new FillingSquaresBar();
        fsb.message = {return "Filling squares bar";};
        foreach(i;fsb.iter(iota(100)))
        {
            Thread.sleep(dur!("msecs")(100));
        }
    }
    {
        FillingCirclesBar fcb = new FillingCirclesBar();
        fcb.message = {return "Filling circles bar";};
        fcb.suffix = {return fcb.eta.to!string;};
        foreach(i;fcb.iter(iota(100)))
        {
            Thread.sleep(dur!("msecs")(100));
        }
    }
    {
        IncrementalBar ib = new IncrementalBar();
        ib.message = {return "Incremental bar";};
        ib.suffix = {return ib.avg.to!string;};
        foreach(i;ib.iter(iota(1000)))
        {
            Thread.sleep(dur!("msecs")(10));
        }
    }
    {
        ShadyBar sb = new ShadyBar();
        sb.message = {return "Shady bar";};
        foreach(i;sb.iter(iota(1000)))
        {
            Thread.sleep(dur!("msecs")(10));
        }
    }
}
