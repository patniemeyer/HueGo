//
//  EffectsBaseViewController.m
//  HueEffects
//
//  Created by pat on 12/18/12.
//  Copyright (c) 2012 pat. All rights reserved.
//

#import "EffectsBaseViewController.h"

@interface EffectsBaseViewController ()

@end

@implementation EffectsBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"EffectNavView" owner:self options:nil] lastObject];
    EffectNavView *env = (EffectNavView *) view;
    view.frame= CGRectMake(0, 0, env.frame.size.width, env.frame.size.height);
    env.delegate = self;
    [self.view addSubview:view];
}

// Play audio

-(void)prepareToPlay:(NSString *)soundFileName
{
    //NSLog(@"soundFileName = %@", soundFileName);
    NSString *filePath = [[NSBundle mainBundle] pathForResource:soundFileName ofType:@"mp3" inDirectory:@"Sounds"];
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:soundFileName ofType:@"mp3"];
    //NSLog(@"filePath = %@", filePath);
    NSData   *fileData = [NSData dataWithContentsOfFile:filePath];
    NSError  *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData error:&error];
    //NSLog(@"error = %@", error);
}

-(void)play {
    [self play:0 loop:NO];
}

-(void)play:(NSTimeInterval)offset loop:(BOOL)doLoop
{
    if (self.audioPlayer == nil) {
        return;
    }

    self.audioPlayer.delegate = self;
    self.audioPlayer.currentTime = offset;
    if ( doLoop ) {
        self.audioPlayer.numberOfLoops = -1;
    }
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
    //NSLog(@"playing = %d", playing);
}

// end Play audio


// Nav view delegate

- (void)startEffect
{
    [self performSelectorInBackground:@selector(run) withObject:nil];
}

- (void)stopEffect
{
    self.isRunning = NO;
    if ( self.audioPlayer != nil ) {
        [self.audioPlayer stop];
    }
}

-(void) onEffectStopped {
    [NSThread sleepForTimeInterval:0.25];
    [self restoreLights];
}

-(void)run
{
    self.isRunning = YES;
    [self beforeRunLoop];

    while (self.isRunning ) {
        [self doOneRunLoop];
    }

    [self onEffectStopped];
}

-(void) beforeRunLoop {}

-(void)doOneRunLoop {
    // todo: find a better way
    [NSThread sleepForTimeInterval:0.5];
}

- (void)back
{
    if ( self.isRunning ) {
        [self stopEffect];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

// end Nav view delegate

-(void)setLight:(int)lightNum withPost:(NSString *)postString
{
    NSString *urlString= [NSString stringWithFormat:@"http://%@/api/%@/lights/%d/state/",  self.bridgeHost, self.bridgeKey, lightNum];
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *requestData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:1.0];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];

    // Sending synchronous for now
    //void (^onComplete)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {  };
    //[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:onComplete];
    NSURLResponse *response = nil;
    NSError *err = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    if ( err != nil ) {
        NSLog(@"light error: %@", err);
    }
}
/*
# Light number, hue, saturation, brightness, transition time
#
# hue 0-65535
# sat 0-255?
# transition time 1/10 seconds
#
lightNHSBT()
{
        _lightNum=$1
        _hue=$2
        _sat=$3
        _brightness=$4
        _ttime=$5
        curl -s --request PUT --data "{\"hue\":$_hue, \"sat\":$_sat, \"bri\":$_brightness, \"on\":true, \"transitiontime\":$_ttime}" http://$IP/api/$KEY/lights/$_lightNum/state/ > /dev/null
}
 */
-(void)setLight:(int)lightNum hue:(int)hue sat:(int)sat brightness:(int)brightness ttime:(int)ttime
{
    NSString *postString = [NSString stringWithFormat:
            @"{\"hue\":%d, \"sat\":%d, \"bri\":%d, \"on\":true, \"transitiontime\":%d}",
            hue, sat, brightness, ttime ];
    [self setLight:lightNum withPost:postString ];
}

/*
lightNCTBT()
{
    _lightNum=$1
    _ct=$2
    _brightness=$3
    _ttime=$4
    curl -s --request PUT --data "{\"ct\":$_ct, \"bri\":$_brightness, \"on\":true, \"transitiontime\":$_ttime}" http://$IP/api/$KEY/lights/$_lightNum/state/ > /dev/null
}
*/
-(void)setLight:(int)lightNum colortemp:(int)colortemp brightness:(int)brightness ttime:(int)ttime
{
    NSString *postString = [NSString stringWithFormat:
            @"{\"ct\":%d, \"bri\":%d, \"on\":true, \"transitiontime\":%d}",
            colortemp, brightness, ttime ];

    [self setLight:lightNum withPost:postString ];
}

-(void)restoreLights
{
    for (int i=1; i<=self.lightCount; i++ ) {
        [self setLight:i colortemp:250 brightness:255 ttime:5];
    }

}


@end
