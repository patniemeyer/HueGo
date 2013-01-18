//
//  SelectEffectViewController.h
//  HueEffects
//
//  Created by pat on 12/15/12.
//  Copyright (c) 2012 pat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscoverBridgeViewController.h"

@interface SelectEffectViewController : UITableViewController

@property(nonatomic, strong) NSString *bridgeHost;
@property(nonatomic, strong) NSString *bridgeKey;
@property(nonatomic) NSUInteger lightCount;

@end
