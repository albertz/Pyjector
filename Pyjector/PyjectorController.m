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

#define PyjectorURL @"https://github.com/albertz/Pyjector"

@implementation PyjectorController

// derived from TETextWatcher.m in Mike Ferris's TextExtras
+ (void)installMenu;
{
    static BOOL alreadyInstalled = NO;
    NSMenu *mainMenu = nil;
    
    if (!alreadyInstalled && ((mainMenu = [NSApp mainMenu]) != nil)) {
        NSMenu *insertIntoMenu = nil;
        NSMenuItem *item;
        unsigned long insertLoc = NSNotFound;
        NSBundle *bundle = [NSBundle bundleForClass:self];
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
			
            //[[FSAWindowManager sharedManager] setWindowMenu: fsaMenu];
        }
    }
	
}

+ (void)createInterpreterWindow:(id)sender;
{
	PyjectorController* w = [self alloc];
    [w init];
	[[w window] setLevel: NSFloatingWindowLevel];
}

+ (void)showInfo:(id)sender;
{
    long result = NSRunInformationalAlertPanel(@"About Pyjector", @"Pyjector lets you embed a PyTerminal in a Cocoa application while it is running.\n\nFor more information about Pyjector, please visit its Web site %@.", @"OK", @"Visit Web Site", nil, PyjectorURL);
    if (result == NSAlertAlternateReturn) {
        [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: PyjectorURL]];
    }
}

+ (void)load;
{
    [self installMenu];
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
		printf("foobar!!\n");
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
