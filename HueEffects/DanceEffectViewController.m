
#import "DanceEffectViewController.h"

@implementation DanceEffectViewController {
    int it, last; // light nums
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
    [self prepareToPlay:@"theofficialchemist-skydive-master"];

    it=1;
    last=2;

    for (int i=1; i<=self.lightCount; i++ )
    {
        if ( !self.isRunning ) { return; } // yield
        [self setLight:i hue:BLUE_COLOR sat:255 brightness:255 ttime:10];
    }

    [self play:0 loop:YES];
    //[NSThread sleepForTimeInterval:2.0];
}

- (void)doOneRunLoop 
{

    [self setLight:last hue:BLUE_COLOR sat:255 brightness:255 ttime:0];
    if ( !self.isRunning ) { return; } // yield
    [self setLight:it hue:RED_COLOR sat:255 brightness:255 ttime:0];
    if ( !self.isRunning ) { return; } // yield
    [NSThread sleepForTimeInterval:0.1];

    last=it++;
    if ( it > self.lightCount ) { it = 1; }
    if ( last > self.lightCount ) { last = 1; }
}


@end
