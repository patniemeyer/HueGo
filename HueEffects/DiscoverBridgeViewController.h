//
//  DiscoverBridgeViewController.h
//  HueEffects
//
//  Created by pat on 12/16/12.
//  Copyright (c) 2012 pat. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DiscoverBridgeDelegate

-(void)didFindBridge:(NSString *) host;
-(void)didFailToFindBridge;

@end

@interface DiscoverBridgeViewController : UIViewController <DiscoverBridgeDelegate>

@property(nonatomic, strong) id ssdpSock;
@property(nonatomic, strong) NSMutableData *responseData;
@property(nonatomic, strong) id<DiscoverBridgeDelegate> delegate;
@property(atomic, copy) NSString *bridgeHost;
@property(nonatomic, strong) NSString *bridgeKey;

@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (weak, nonatomic) IBOutlet UITextField *messages;

@property(nonatomic) int tryCount;
@property(nonatomic) int verifyTryCount;

@property(nonatomic) NSUInteger lightCount;

+(NSURL *) urlForBridge:(NSString *)host key:(NSString *)key;

@end


