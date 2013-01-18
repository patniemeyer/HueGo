//
//  EffectNavView.h
//  HueEffects
//
//  Created by pat on 12/18/12.
//  Copyright (c) 2012 pat. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EffectNavDelegate
-(void)startEffect;
-(void)stopEffect;
-(void)back;
@end

@interface EffectNavView : UIView
- (IBAction)backButton:(id)sender;
- (IBAction)effectSwitch:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *swtch;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) id<EffectNavDelegate> delegate;


@end

