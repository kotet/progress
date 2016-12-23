# progress
[![Build Status](https://travis-ci.org/kotet/progress.svg?branch=master)](https://travis-ci.org/kotet/progress) 
[![Dub version](https://img.shields.io/dub/v/progress.svg)](https://code.dlang.org/packages/progress) 
[![Go to progress](https://img.shields.io/dub/dt/progress.svg)](https://code.dlang.org/packages/progress) 
[![LICENSE](https://img.shields.io/dub/l/progress.svg)](http://code.dlang.org/packages/progress)

Easy progress reporting for D inspired by [Python's one with the same name](https://github.com/verigak/progress).  
There are 6 progress bar, 4 spinner, 4 counter, and... Dman.

## Progress bar 
 - Bar
 - ChargingBar
 - FillingSquaresBar
 - FillingCirclesBar
 - IncrementalBat
 - ShadyBar

## Spinner
 - Spinner
 - PieSpinner
 - MoonSpinner
 - LineSpinner

## Counter
 - Counter
 - Countdown
 - Stack
 - Pie

## Dman
 - DmanSpinner

# Usage
## progress bars
Call `next` to advance and `finish` to finish.

```d
Bar b = new Bar();
b.message = {return "Processing";};
b.max = 20;
foreach(i; 0 .. 20)
{
    //Do some work
    b.next();
}
b.finish();
```
```
Processing |##################              | 12/20
```

In the general case, you can use the `iter` method to write simply

```d
import std.range : iter;

Bar b = new Bar();
foreach(i; b.iter(iota(20)) )
{
    //Do something
}
```
Progress bars are very customizable, you can change their width, their fill character, their suffix and more.
```d
import std.conv : to;

b.message = {return "Loading";};
b.fill = '@';
b.suffix = {return b.percent.to!string ~ "%";};
```
This will produce a bar like the following:
```
Loading |@@@@@@@                         | 24%
```
There are various properties that can be used in `message` and `suffix`.

| name      | type     | value                               |
|-----------|----------|-------------------------------------|
| index     | size_t   | current value                       |
| max       | size_t   | maximum value                       |
| remaining | size_t   | max - index                         |
| progress  | real     | index / max                         |
| percent   | real     | progress * 100                      |
| avg       | Duration | simple moving average time per item |
| elapsed   | Duration | elapsed time in seconds             |
| eta       | Duration | avg * remaining                     |

Instead of passing all configuration options on instatiation, you can create your custom subclass:
```d
class CustomBar : Bar
{
    this()
    {
        super();
        bar_prefix = "/";
        bar_suffix = "/";
        empty_fill = " ";
        fill = "/";
        suffix = {return "Custom";};
    }
```
You can also override any of the arguments or create your own:
```d
class SlowBar : Bar
{
    this()
    {
        super();
        suffix = {return this.remaining_hours.to!string ~ "hours remaining";};
    }
    @property long remaining_hours()
    {
        return this.eta.total!"hours";
    }
}
```

Please see example projects if you want to learn more.
