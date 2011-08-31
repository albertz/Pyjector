Pyjector
========

Injects [PyTerminal](https://github.com/albertz/PyTerminal) into any running application via [SIMBL](http://culater.net/software/SIMBL/SIMBL.php).

It is basically the same as [FScriptAnywhereSIMBL](https://github.com/albertz/FScriptAnywhereSIMBL) but for Python.

Installation
------------

* Install [SIMBL](http://culater.net/software/SIMBL/SIMBL.php).

* Install IPython. `easy_install ipython` should do.

* Either compile the `Pyjector.bundle` yourself or download it from [here](https://github.com/downloads/albertz/Pyjector/Pyjector.bundle.zip).

* Copy the `Pyjector.bundle` to `~/Library/Application Support/SIMBL/Plugins/`.

Example
-------

Run `Utilities/Console.app`. You will see the menu entry `Python`. Open a new PyTerminal from it. And type:

    import AppKit
    app = AppKit.NSApp()
    app.windows()[0].setAlphaValue_(0.8)

![screenshot](https://github.com/albertz/Pyjector/raw/master/Screenshots/Shot1.png)

Current restrictions
--------------------

* In some cases, the bundle cannot be injected. E.g., for some applications, you might get the error `GC capability mismatch`.

* PyTerminal uses `openpty`. Most `sandboxd`'d applications (e.g. TextEdit) will fail with `deny file-read-data /dev/ptmx`. This can be fixed by providing an alternative PyTerminal implementation which avoids `openpty`.

* You should note that you don't see the real stdout in the PyTerminal. You only see everything which is printed to `sys.stdout` / `sys.stderr`. Also, the readline lib is a bit buggy in this usage (not sure really what to blame; maybe CPython, maybe readline, maybe PyTerminal; there are countless bugs on this in every of those projects; see the source code for details and references).

-- Albert Zeyer, <http://www.az2000.de>
