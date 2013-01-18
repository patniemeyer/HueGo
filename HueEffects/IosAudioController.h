
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/*
#ifndef max
#define max( a, b ) ( ((a) > (b)) ? (a) : (b) )
#endif

#ifndef min
#define min( a, b ) ( ((a) < (b)) ? (a) : (b) )
#endif
*/

@protocol AudioVolumeDelegate

-(void)receiveVolume:(long)vol;

@end

@interface IosAudioController : NSObject {
	AudioComponentInstance audioUnit;
	AudioBuffer tempBuffer; // this will hold the latest data from the microphone
}

@property (readonly) AudioComponentInstance audioUnit;
@property (readonly) AudioBuffer tempBuffer;
@property(nonatomic, strong) id<AudioVolumeDelegate> volumeDelegate;

// used to accumulate results... mess.
@property(nonatomic) int xaudioCount;
@property(nonatomic) long xaudioTotal;


- (void) start;
- (void) stop;
//- (void) processAudio: (AudioBufferList*) bufferList;

@end

// setup a global iosAudio variable, accessible everywhere
extern IosAudioController* iosAudio;