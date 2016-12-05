module progress.dman;
import progress;

import std.string : countchars;
import std.regex : regex,replaceAll;

immutable string[] DMANS = [
q"{

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
  |__/  |__/
}",
q"{
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
     |   |
     |   |
     |   |
   _ |   |__
  |__/  |__/
}"
];

class DmanSpinner : Infinite
{
    size_t _height=0;
    this()
    {
        this.message = {return "";};
        hide_cursor = true;
        super();
    }
    override void update()
    {
        size_t i = this.index % DMANS.length;
        file.write(repeat("\r\x1b[K\x1b[1A",_height));
        string message = this.message();
        string padding = "\n" ~ repeat(" ",message.length);
        file.write(message,DMANS[i].replaceAll(regex(r"\n","g"), padding));
        _height = DMANS[i].countchars("\n");
    }
}
