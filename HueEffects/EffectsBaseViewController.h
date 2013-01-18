//
//  EffectsBaseViewController.h
//  HueEffects
//
//  Created by pat on 12/18/12.
//  Copyright (c) 2012 pat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EffectNavView.h"
#import <AVFoundation/AVFoundation.h>

@interface EffectsBaseViewController : UIViewController <EffectNavDelegate,AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property(nonatomic, strong) NSString *bridgeHost;
@property(nonatomic, strong) NSString *bridgeKey;
@property(nonatomic) NSUInteger lightCount;

@property(atomic) BOOL isRunning;

-(void)setLight:(int)lightNum hue:(int)hue sat:(int)sat brightness:(int)brightness ttime:(int)ttime;
-(void)setLight:(int)lightNum colortemp:(int)colortemp brightness:(int)brightness ttime:(int)ttime;
-(void)doOneRunLoop;

- (void)prepareToPlay:(NSString *)soundFileName;
- (void)play;
- (void)play:(NSTimeInterval)offset loop:(BOOL)doLoop;

- (void)stopEffect;

-(void) beforeRunLoop ;


@end

enum {
    RED_COLOR=0,
    ORANGE_COLOR=6000,
    YELLOW_COLOR=19000,
    GREEN_COLOR=25000,
    BLUE_COLOR=45600,
    VIOLET_COLOR=57000,
};


