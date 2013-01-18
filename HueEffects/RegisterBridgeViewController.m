//
//  RegisterBridgeViewController.m
//  HueEffects
//
//  Created by pat on 12/17/12.
//  Copyright (c) 2012 pat. All rights reserved.
//

#import "RegisterBridgeViewController.h"
#import "DiscoverBridgeViewController.h"

@implementation RegisterBridgeViewController {
    NSString *uuid;
}
int MAX_REG_TRIES =30;

// TODO: Inconsistent use of props, obsolete @synthesize...
// TODO: I started this before I was aware of the recent changes.
@synthesize bridgeHost, onRegisteredKey;
@synthesize tryCount;
@synthesize uuid;


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
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self registerWithBridge];
}

- (void)registerWithBridge {
    [self tryRegisteringWithBridge];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)getOrGenerateUUID 
{
    if ( self.uuid == nil ) {
        self.uuid = [[[[NSUUID UUID] UUIDString] substringToIndex:32] stringByReplacingOccurrencesOfString:@"-" withString:@"9"];
    }
    return self.uuid;
}

-(void)tryRegisteringWithBridge
{
    if ( self.tryCount >= MAX_REG_TRIES)
    {
        NSLog(@"Giving up...");
        self.messages.text=@"Timeout registering bridge...";
        [self.spinner stopAnimating];
        self.spinner.hidden=YES;
        [self failureRegisteringWithBridge];
        return;
    }

    NSString *key = [self getOrGenerateUUID];
    NSString *postString = [NSString stringWithFormat:@"{\"username\": \"%@\", \"devicetype\": \"Philips hue\"}", key];
    NSString *urlString= [NSString stringWithFormat:@"http://%@/api", self.bridgeHost];
    NSData *requestData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];

    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:2.0];

    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];

    void (^onComplete)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if ( data != nil && data.length > 0 )
        {
            NSString *regResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ( [regResponse rangeOfString:@"success"].length != 0 ) {
                self.messages.text=@"Success...";
                [self successRegisteringWithBridge:key];
                return;
            }
            if ( [regResponse rangeOfString:@"link button not pressed"].length != 0 ) {
                self.messages.text= [NSString stringWithFormat:@"Waiting for button: %d",  (MAX_REG_TRIES-self.tryCount)];
            }
        } else {
            self.messages.text=@"Error, trying again...";
        }

        // reschedule
        [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector: @selector(retryRegisterTime:) userInfo: nil repeats: NO];
    };

    NSLog(@"Trying register with: %@", key);
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:onComplete];
    self.tryCount++;
}

- (void) retryRegisterTime: (id) theTimer {
    NSLog(@"retrying...");
    [self tryRegisteringWithBridge];
}


-(void)failureRegisteringWithBridge
{
    [self successRegisteringWithBridge:nil]; // nil indicates failure
}

-(void)successRegisteringWithBridge:(NSString *)key
{
    if ( key ) {
        NSLog(@"success registering: %@", key);
    } else{
        NSLog(@"failure registering...");
    }
    void (^dismissComplete)() = ^{
        onRegisteredKey(key);
    };
    [self dismissViewControllerAnimated:YES completion:dismissComplete];
}


@end
