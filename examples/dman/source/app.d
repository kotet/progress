import progress.dman;
import core.thread;

void main()
{
    {
		DmanSpinner ds = new DmanSpinner();
		ds.message = {return "Dman spinner";};
		foreach(i;0 .. 20)
		{
		    Thread.sleep(dur!("msecs")(500));
			ds.next();
		}
		ds.finish();
	}
}
