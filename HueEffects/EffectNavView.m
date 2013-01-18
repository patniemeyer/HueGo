//
//  EffectNavView.m
//  HueEffects
//
//  Created by pat on 12/18/12.
//  Copyright (c) 2012 pat. All rights reserved.
//

#import "EffectNavView.h"

@implementation EffectNavView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)backButton:(id)sender
{
    //if ( self.swtch.on ) {
        //[self.delegate stopEffect];
    //}
    [self.delegate back];
}

// hiding the activity spinner isn't working properly, so I set "hide on inactive" in IB
- (IBAction)effectSwitch:(id)sender {
    UISwitch *sw = sender;
    if ( sw.on ) {
        [self.delegate startEffect];
        self.spinner.hidden= NO;
        [self.spinner startAnimating];
    } else {
        [self.delegate stopEffect];
        [self.spinner stopAnimating];
        self.spinner.hidden= YES;
    }
}
@end
