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
        cd.max = 200;
        cd.message = { return "Countdown: "; };
        foreach (i; 0 .. 200)
        {
            Thread.sleep(dur!("msecs")(50));
            cd.next();
        }
        cd.finish();
    }
    {
        Stack s = new Stack();
        s.max = 50;
        s.message = { return "Stack: "; };
        foreach (i; 0 .. 50)
        {
            Thread.sleep(dur!("msecs")(200));
            s.next();
        }
        s.finish();
    }
    {
        Pie p = new Pie();
        p.message = { return "Pie: "; };
        foreach (i; 0 .. 100)
        {
            Thread.sleep(dur!("msecs")(100));
            p.next();
        }
        p.finish();
    }
}
