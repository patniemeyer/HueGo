#import "GodVoiceEffectViewController.h"
#import "IosAudioController.h"

@implementation GodVoiceEffectViewController {

    //IosAudioController *audio;
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
    if ( !iosAudio) {
        iosAudio= [[IosAudioController alloc] init];
    }
    iosAudio.volumeDelegate = self;
    [iosAudio start];
}

// no run loop here

- (void)stopEffect
{
    [super stopEffect];
    if ( iosAudio ) {
        [iosAudio stop];
    }
}

- (void)receiveVolume:(long)vol
{
    //NSLog(@"vol = %li", vol);
    // todo: make this atomic
    if ( self.setting ) {
        return;
    }
    self.setting = true;

    double clippedVol = MAX(1, vol-25);
    double logVol = log(clippedVol);
    double logVolSq = logVol*logVol;
    double max= log(16384)* log(16384);
    int brightness = (int) MIN( logVolSq/max*255, 255 );
    //NSLog(@"brightness = %i", brightness);

    for (int i=1; i<=self.lightCount; i++ )
    {
        if ( !self.isRunning ) { break; } // yield
        [self setLight:i colortemp:250 brightness:brightness ttime:2];
        //[self setLight:i hue:BLUE_COLOR sat:255 brightness:brightness ttime:2];
    }
    self.setting = false;
}


@end
