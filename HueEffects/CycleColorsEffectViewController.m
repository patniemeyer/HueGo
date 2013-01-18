//
//  CycleColorsEffectViewController.m
//  HueEffects
//
//  Created by pat on 12/18/12.
//  Copyright (c) 2012 pat. All rights reserved.
//

#import "CycleColorsEffectViewController.h"

@implementation CycleColorsEffectViewController {
    int hue;
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
    hue=0;
}

- (void)doOneRunLoop 
{
    for (int i=1; i<=self.lightCount; i++ )
    {
        if ( !self.isRunning ) { return; } // yield
        [self setLight:i hue:hue sat:255 brightness:255 ttime:5];
    }
    hue+=5000;
    if ( hue > 65000 ) {
        hue = 0;
    }
    [NSThread sleepForTimeInterval:0.5];
}



@end
