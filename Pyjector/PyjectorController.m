//
//  PyjectorController.m
//  Pyjector
//
//  Created by Albert Zeyer on 31.08.11.
//  Copyright 2011 Albert Zeyer. All rights reserved.
//

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
            NSMenu *fsaMenu = [[NSMenu allocWithZone: [NSMenu menuZone]] initWithTitle:NSLocalizedStringFromTableInBundle(@"FSA", @"FSA", bundle, @"Title of F-Script Anywhere menu")];
			
            item = [insertIntoMenu insertItemWithTitle: NSLocalizedStringFromTableInBundle(@"FSA", @"FSA", bundle, @"Title of F-Script Anywhere menu") action:NULL keyEquivalent:@"" atIndex:insertLoc];
            [insertIntoMenu setSubmenu:fsaMenu forItem:item];
            [fsaMenu release];
			
            // Add the items for the commands.
            item = [fsaMenu addItemWithTitle: NSLocalizedStringFromTableInBundle(@"New F-Script Workspace", @"FSA", bundle, @"Title of F-Script Workspace menu item") action:@selector(createInterpreterWindow:) keyEquivalent: @""];
            [item setTarget: self];
            [fsaMenu addItemWithTitle: NSLocalizedStringFromTableInBundle(@"Associate With Interface", @"FSA", bundle, @"Title of Associate with Interface menu item") action: @selector(FSA_associateWithInterface:) keyEquivalent: @""];
            [fsaMenu addItem: [NSMenuItem separatorItem]];
            item = [fsaMenu addItemWithTitle: NSLocalizedStringFromTableInBundle(@"About F-Script Anywhere...", @"FSA", bundle, @"Title of Info Panel menu item") action:@selector(showInfo:) keyEquivalent: @""];
            [item setTarget: self];
			
            //[[FSAWindowManager sharedManager] setWindowMenu: fsaMenu];
        }
    }
	
}

+ (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem
{
    SEL sel;
    NSAssert([menuItem target] == self, @"menu item does not target FSAController!");
    sel = [menuItem action];
    if (sel == @selector(showInfo:) || sel == @selector(createInterpreterWindow:)) return YES;
   // FSALog(@"+[FSAController validateMenuItem:] unknown menu item for validation: %@", menuItem);
    return NO;
}

+ (void)createInterpreterWindow:(id)sender;
{
    [[self alloc] init];
}

+ (void)showInfo:(id)sender;
{
    long result = NSRunInformationalAlertPanel([NSString stringWithFormat: @"About Pyjector (version %s)", "0.1"], @"Pyjector lets you embed a PyTerminal in a Cocoa application while it is running.\n\nFor more information about Pyjector, please visit its Web site %@.", @"OK", @"Visit Web Site", nil, PyjectorURL);
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
