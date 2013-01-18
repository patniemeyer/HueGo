//
//  CycleColorsEffectViewController.m
//  HueEffects
//
//  Created by pat on 12/18/12.
//  Copyright (c) 2012 pat. All rights reserved.
//

#import "KlaxonEffectViewController.h"

@implementation KlaxonEffectViewController {
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) beforeRunLoop
{
    [self prepareToPlay:@"klaxon-fake2"];
}

- (void)doOneRunLoop 
{
    [self play];

    for (int i=1; i<=self.lightCount; i++ )
    {
        if ( !self.isRunning ) { break; } // yield
        [self setLight:i hue:0 sat:255 brightness:255 ttime:9];
    }
    [NSThread sleepForTimeInterval:0.5];
    if ( !self.isRunning ) { return; } // yield
    [NSThread sleepForTimeInterval:0.5];

    for (int i=1; i<=self.lightCount; i++ )
    {
        if ( !self.isRunning ) { return; } // yield
        [self setLight:i hue:0 sat:255 brightness:30 ttime:9];
    }
    [NSThread sleepForTimeInterval:0.5];
    if ( !self.isRunning ) { return; } // yield
    [NSThread sleepForTimeInterval:0.5];

}


@end
