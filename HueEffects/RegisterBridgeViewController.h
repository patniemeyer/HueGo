//
//  RegisterBridgeViewController.h
//  HueEffects
//
//  Created by pat on 12/17/12.
//  Copyright (c) 2012 pat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterBridgeViewController : UIViewController {
    int tryCount;
}

@property(nonatomic, copy) NSString *bridgeHost;
@property(nonatomic, copy) void (^onRegisteredKey)(NSString *);

@property (weak, nonatomic) IBOutlet UITextField *messages;
@property(nonatomic) int tryCount;
@property(nonatomic, copy) NSString *uuid;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIImageView *fingerImageView;

@end
