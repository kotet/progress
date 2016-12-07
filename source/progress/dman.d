module progress.dman;
import progress;

import std.regex : regex,replaceAll;

immutable string[] DMANS = [
`
      ____
      L__L|
      /    \
    /        \
  / _______    \
  \ \#/  \/ \  /
   \|#| O| O|#\
    |#L _L__ #|
    |###|  |##|
    /###/  /##|
   /###/   /##|
  /###/___/###/
 /###########/
 /##########/
    /     \
    \     /
   _ \   /__
  |__/  |__/`,
`      ____
      L__L|
      /    \
    /        \
  / _______    \
  \ \#/  \/ \  /
   \|#| O| O|#\
    |#L _L__ #|
    |###|  |##|
    /###/  /##|
   /###/   /##|
  /###/___/###/
 /###########/
 /##########/
     |   |
     |   |
     |   |
   _ |   |__
  |__/  |__/`
];

class DmanSpinner : Infinite
{
    this()
    {
        this.message = {return "";};
        hide_cursor = true;
        super();
    }
    override void update()
    {
        size_t i = this.index % DMANS.length;
        string message = this.message();
        string padding = "\n" ~ repeat(" ",message.length);
        this.writeln(message ~ DMANS[i].replaceAll(regex(r"\n","g"), padding));
    }
}
