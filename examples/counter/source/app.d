import progress.counter;
import core.thread;

void main()
{
    {
        Counter c = new Counter();
        c.message = { return "Basic counter: "; };
        foreach (i; 0 .. 100)
        {
            Thread.sleep(dur!("msecs")(100));
            c.next();
        }
        c.finish();
    }
    {
        Countdown cd = new Countdown();
        scope (exit)
            cd.finish();
        cd.max = 200;
        cd.message = { return "Countdown: "; };
        foreach (i; 0 .. 200)
        {
            Thread.sleep(dur!("msecs")(50));
            cd.next();
        }
    }
    {
        Stack s = new Stack();
        scope (exit)
            s.finish();
        s.max = 50;
        s.message = { return "Stack: "; };
        foreach (i; 0 .. 50)
        {
            Thread.sleep(dur!("msecs")(200));
            s.next();
        }
    }
    {
        Pie p = new Pie();
        scope (exit)
            p.finish();
        p.message = { return "Pie: "; };
        foreach (i; 0 .. 100)
        {
            Thread.sleep(dur!("msecs")(100));
            p.next();
        }
    }
}
