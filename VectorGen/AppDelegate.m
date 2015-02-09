//
//  AppDelegate.m
//  VectorGen
//
//  Created by Phillip Riscombe-Burton on 24/11/2014.
//  Copyright (c) 2014 Phillip Riscombe-Burton. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a
//	copy of this software and associated documentation files (the
//	"Software"), to deal in the Software without restriction, including
//	without limitation the rights to use, copy, modify, merge, publish,
//	distribute, sublicense, and/or sell copies of the Software, and to
//	permit persons to whom the Software is furnished to do so, subject to
//	the following conditions:
//
//	The above copyright notice and this permission notice shall be included
//	in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "AppDelegate.h"
#import "PRBVectorScreenView.h"
#import "PRBMasterView.h"

@interface AppDelegate ()

@property(nonatomic,assign) IBOutlet NSMenuItem *showGridItem;
@property(nonatomic,assign) IBOutlet NSMenuItem *snapToGridItem;
@property(nonatomic,assign) IBOutlet NSMenuItem *optimiseOnSave;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
   
    [self applySettings];

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - Menu actions
//Show / Hide grid
-(IBAction)showGridItem:(NSMenuItem*)sender{

    if(sender.state != NSOnState) [sender setState:NSOnState];
    else [sender setState:NSOffState];
    
    NSNumber *showBool = sender.state == NSOnState ? @YES : @NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowGridNotification object:nil userInfo:@{kShowValue:showBool}];
}

//Toggle 'Snap to Grid'
-(IBAction)toggleSnapToGridItem:(NSMenuItem*)sender{
    
    if(sender.state != NSOnState) [sender setState:NSOnState];
    else [sender setState:NSOffState];
    
    NSNumber *snapBool = sender.state == NSOnState ? @YES : @NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kSnapToGridGridNotification object:nil userInfo:@{kSnapValue:snapBool}];
    
}

//Toggle 'Optimise on Save'
- (IBAction)toggleOptimiseOnSave:(NSMenuItem *)sender {
	[sender setState:!sender.state];
	
	NSNumber *optOnSaveBool = (sender.state == NSOnState) ? @YES : @NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:kOptOnSaveNotification object:nil userInfo:@{kOptOnSaveValue:optOnSaveBool}];
}

//Create an image overlay
-(IBAction)newImageOverlay:(NSMenuItem*)sender{
    
     [[NSNotificationCenter defaultCenter] postNotificationName:kNewImageOverlayNotification object:nil userInfo:nil];
}

//Simulate current vector doc on a Vectrex
-(IBAction)simulateItem:(NSMenuItem*)sender{
    //TODO Show simulation of current vector doc on a Vectrex
}


-(void)applySettings{
    
    //Settings
    NSUserDefaults  *defaults = [NSUserDefaults standardUserDefaults];
    
    if(![defaults objectForKey:kSnapToGrid])
    {
        //Default is YES
        [defaults setBool:YES forKey:kSnapToGrid];
        [defaults synchronize];
    }
    else
    {
        //Update menu item
        [_snapToGridItem setState: [defaults boolForKey:kSnapToGrid] ? NSOnState : NSOffState];
    }
    
    if(![defaults objectForKey:kShowGrid])
    {
        //Default is YES
        [defaults setBool:YES forKey:kShowGrid];
        [defaults synchronize];
    }
    else
    {
        //Update menu item
        [_showGridItem setState: [defaults boolForKey:kShowGrid] ? NSOnState : NSOffState];
    }

    if (![defaults objectForKey:kOptimiseOnSave])
	{
		//Default is YES
		[defaults setBool:YES forKey:kOptimiseOnSave];
		[defaults synchronize];
	}
	else
	{
		//Update menu item
		bool value = [defaults boolForKey:kOptimiseOnSave];
		[_optimiseOnSave setState:value ? NSOnState : NSOffState];
	}
}




@end
