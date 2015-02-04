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

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
   
    [self applySettings];

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(IBAction)showGridItem:(NSMenuItem*)sender{

    if(sender.state != NSOnState) [sender setState:NSOnState];
    else [sender setState:NSOffState];
    
    NSNumber *showBool = sender.state == NSOnState ? @YES : @NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowGridNotification object:nil userInfo:@{kShowValue:showBool}];
}

-(IBAction)toggleSnapToGridItem:(NSMenuItem*)sender{
    
    if(sender.state != NSOnState) [sender setState:NSOnState];
    else [sender setState:NSOffState];
    
    NSNumber *snapBool = sender.state == NSOnState ? @YES : @NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kSnapToGridGridNotification object:nil userInfo:@{kSnapValue:snapBool}];
    
}

-(IBAction)newImageOverlay:(NSMenuItem*)sender{
    
    //create imageOverlayView
     [[NSNotificationCenter defaultCenter] postNotificationName:kNewImageOverlayNotification object:nil userInfo:nil];
}

-(IBAction)simulateItem:(NSMenuItem*)sender{
    
    //TODO SHOW SIMULATION OF CURRENT WINDOW!
    
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

    
}




@end
