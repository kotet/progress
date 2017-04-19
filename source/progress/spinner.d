module progress.spinner;
import progress;

class Spinner : Infinite
{
    string[] phases = ["-", "\\", "|", "/"];
    this()
    {
        this.message = { return ""; };
        hide_cursor = true;
        super();
    }

    override void force_update()
    {
        size_t i = this.index % this.phases.length;
        this.write(this.phases[i]);
    }
}

class PieSpinner : Spinner
{
    this()
    {
        phases = ["◷", "◶", "◵", "◴"];
    }
}

class MoonSpinner : Spinner
{
    this()
    {
        phases = ["◑", "◒", "◐", "◓"];
    }
}

class LineSpinner : Spinner
{
    this()
    {
        phases = ["⎺", "⎻", "⎼", "⎽", "⎼", "⎻"];
    }
}
