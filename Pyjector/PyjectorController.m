//
//  PyjectorController.m
//  Pyjector
//
//  Created by Albert Zeyer on 31.08.11.
//  Copyright 2011 Albert Zeyer. All rights reserved.
//
// see http://code.google.com/p/simbl/wiki/Tutorial
// loosely based on [FScriptAnywhereSIMBL](https://github.com/albertz/FScriptAnywhereSIMBL )

#import "PyjectorController.h"
#import <PyTerminal/PyTerminalView.h>
#import <Python/Python.h>

#define PyjectorURL @"https://github.com/albertz/Pyjector"

@implementation PyjectorController

// derived from TETextWatcher.m in Mike Ferris's TextExtras
+ (void)installMenu;
{
    static BOOL alreadyInstalled = NO;
    NSMenu *mainMenu = nil;
    
    if (!alreadyInstalled) {
		static BOOL alreadyCheckedMenu = NO;
		if((mainMenu = [NSApp mainMenu]) == nil) {
			if(!alreadyCheckedMenu) {
				alreadyCheckedMenu = YES;
				[[self class] performSelector: @selector(installMenu)
								   withObject: nil
								   afterDelay: 1.0];
			}
			return;
		}
		
		static BOOL alreadyCheckedMenuCount = NO;
		if(!alreadyCheckedMenuCount) {
			alreadyCheckedMenuCount = YES;
			size_t c = [[mainMenu itemArray] count];
			if(c <= 2) {
				NSLog(@"main Menu entry count: %lu", c);
				[[self class] performSelector: @selector(installMenu)
								   withObject: nil
								   afterDelay: 1.0];
				return;
			}
		}

        NSMenu *insertIntoMenu = nil;
        NSMenuItem *item;
        unsigned long insertLoc = NSNotFound;
        NSMenu * beforeSubmenu = [NSApp windowsMenu];
        // Succeed or fail, we do not try again.
        alreadyInstalled = YES;
		
        // Add it to the main menu.  We try to put it right before the Windows menu if there is one, or right before the Services menu if there is one, and if there's neither we put it right before the the last submenu item (ie above Quit and Hide on Mach, at the end on Windows.)
		
        if (!beforeSubmenu) {
            beforeSubmenu = [NSApp servicesMenu];
        }
		
        insertIntoMenu = mainMenu;
		
        if (beforeSubmenu) {
            NSArray *itemArray = [insertIntoMenu itemArray];
            unsigned long i, c = [itemArray count];
			
            // Default to end of menu
            insertLoc = c;
			
            for (i=0; i<c; i++) {
                if ([[itemArray objectAtIndex:i] target] == beforeSubmenu) {
                    insertLoc = i;
                    break;
                }
            }
        } else {
            NSArray *itemArray = [insertIntoMenu itemArray];
            unsigned long i = [itemArray count];
			
            // Default to end of menu
            insertLoc = i;
			
            while (i-- > 0) {
                if ([[itemArray objectAtIndex:i] hasSubmenu]) {
                    insertLoc = i+1;
                    break;
                }
            }
        }
        if (insertIntoMenu) {
			NSString* titleStr = @"Python";
            NSMenu *pyjectorMenu = [[NSMenu allocWithZone: [NSMenu menuZone]] initWithTitle:titleStr];
			
            item = [insertIntoMenu insertItemWithTitle: titleStr action:NULL keyEquivalent:@"" atIndex:insertLoc];
            [insertIntoMenu setSubmenu:pyjectorMenu forItem:item];
            [pyjectorMenu release];
			
            // Add the items for the commands.
            item = [pyjectorMenu addItemWithTitle: @"new Python terminal" action:@selector(createInterpreterWindow:) keyEquivalent: @""];
            [item setTarget: self];
            [pyjectorMenu addItem: [NSMenuItem separatorItem]];
            item = [pyjectorMenu addItemWithTitle: @"About Pyjector..." action:@selector(showInfo:) keyEquivalent: @""];
            [item setTarget: self];			
        }
    }
	
}

+ (void)createInterpreterWindow:(id)sender;
{
	PyjectorController* w = [self alloc];
    [w init];
}

+ (void)showInfo:(id)sender;
{
    long result = NSRunInformationalAlertPanel(@"About Pyjector", @"Pyjector lets you embed a PyTerminal in a Cocoa application while it is running.\n\nFor more information about Pyjector, please visit its Web site %@.", @"OK", @"Visit Web Site", nil, PyjectorURL);
    if (result == NSAlertAlternateReturn) {
        [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: PyjectorURL]];
    }
}

+ (void)runPythonStartupScript:(NSString*)pyFile;
{
	FILE* fp = fopen([pyFile UTF8String], "r");
	if(!fp) {
		NSLog(@"runPythonStartupScript: cannot open %@\n", pyFile);
		return;
	}
	NSLog(@"runPythonStartupScript: %@\n", pyFile);

	PyThreadState* tstate = NULL;
	PyInterpreterState* interp = NULL;
	interp = PyInterpreterState_Head();
	tstate = PyThreadState_New(interp);

	PyEval_AcquireThread(tstate);
	{
		PyObject* m = PyImport_AddModule("__main__");
		PyObject* d = PyModule_GetDict(m);
		PyObject* f = PyString_FromString([pyFile UTF8String]);
		PyDict_SetItemString(d, "__file__", f);
		Py_DECREF(f);
		{
			// In some cases, [NSBundle mainBundle] is messed up, e.g. when the binary path is strange.
			// The info via NSRunningApplication is correct, though.
			NSString* bundleIdentifier = nil;
			NSRunningApplication* app = [NSRunningApplication runningApplicationWithProcessIdentifier:getpid()];
			if(app)
				bundleIdentifier = [app bundleIdentifier];
			if(!bundleIdentifier)
				bundleIdentifier = @"";				
			PyObject* sysargv = PyList_New(2);
			PyList_SetItem(sysargv, 0, PyString_FromString("Python"));
			PyList_SetItem(sysargv, 1, PyString_FromString([bundleIdentifier UTF8String]));
			PySys_SetObject("argv", sysargv);
			Py_DECREF(sysargv);
		}
		PyObject* v = PyRun_FileExFlags(fp, [pyFile UTF8String], /*start*/Py_file_input, d, d, /*closeit*/1, NULL);
		if(v == NULL) {
			if(!PyErr_ExceptionMatches(PyExc_SystemExit)) // ignore SystemExit exception. we don't want to exit
				PyErr_Print();
		}
		PyErr_Clear();
		Py_XDECREF(v);
		PyDict_DelItemString(d, "__file__");
		PyErr_Clear();
	}
	if(PyThreadState_Swap(NULL) != tstate)
		NSLog(@"runPythonStartupScript warning: tstate messed up\n");
	PyEval_ReleaseLock();
	
	NSLog(@"runPythonStartupScript finished: %@\n", pyFile);
}

+ (void)runPythonStartupScripts;
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSAllDomainsMask, YES);
	for (NSString* libraryPath in paths) {
		NSString* subPath = [libraryPath stringByAppendingPathComponent:@"Application Support/Pyjector/StartupScripts"];
		NSArray* pyFiles = [[[NSFileManager defaultManager] directoryContentsAtPath:subPath] pathsMatchingExtensions:[NSArray arrayWithObject:@"py"]];
		for (NSString* pyFile in pyFiles) {
			[self runPythonStartupScript:[subPath stringByAppendingPathComponent:pyFile]];
		}
	}	
}

+ (void)load;
{
    [self installMenu];
	initPython();
	[self runPythonStartupScripts];
}

- (id)init {
	
    self = [super initWithWindowNibName:@"PyTerminalWindow" owner:self];	    
	[self showWindow: self];
	//[self loadWindow];

	NSWindow *window = [self window];
	NSAssert(window != nil, @"Can’t get window!");
	
	NSView* v = allocPyTermialView();
	[v init];
	[v setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
	[v setFrame:[[window contentView] bounds]];
	[[window contentView] addSubview:v];
	
	[window makeKeyAndOrderFront: self];

	return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

@end
