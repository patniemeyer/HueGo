//
//  DiscoverBridgeViewController.m
//  HueEffects
//
//  Created by pat on 12/16/12.
//  Copyright (c) 2012 pat. All rights reserved.
//

#import "DiscoverBridgeViewController.h"
#import "AsyncUdpSocket.h"
#import "DataURLConnection.h"
#import "RegisterBridgeViewController.h"
#import "SelectEffectViewController.h"

int MAX_VER_TRIES = 15;

@implementation DiscoverBridgeViewController

@synthesize ssdpSock, delegate, bridgeHost, bridgeKey, tryCount, spinner, messages, verifyTryCount, lightCount;


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
    self.delegate = self;
    //self.spinner.transform= CGAffineTransformMakeScale(3.0, 3.0);
    [self findBridge];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];

    if ([segue.identifier isEqualToString:@"toRegister"]) {
        RegisterBridgeViewController *rbvc = (RegisterBridgeViewController *) segue.destinationViewController;
        rbvc.bridgeHost = bridgeHost;
        rbvc.onRegisteredKey = ^(NSString *key){
            NSLog(@"onRegisteredKey = %@", key);
            if ( key == nil ) {
                self.messages.text=@"Failed to register bridge...";
                self.bridgeHost = nil;
                self.bridgeKey = nil;
                [self findBridge]; // try again
                return;
            }
            [self onRegisteredBridge:bridgeHost withKey:key];
        };
    }
    if ([segue.identifier isEqualToString:@"toEffects"]) {
        NSLog(@"segue to toEffects");
        SelectEffectViewController *sevc = (SelectEffectViewController*) segue.destinationViewController;
        sevc.bridgeHost = self.bridgeHost;
        sevc.bridgeKey = self.bridgeKey;
        sevc.lightCount = self.lightCount;
    }
}

// discover devices using SSDP

-(void)findBridge {

    // TODO: remember host... need try once verify functionality
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSString *savedHost = [defaults stringForKey:@"bridgeHost"];

    [self discoverDevices];
}

-(void)discoverDevices
{
    ssdpSock = [[AsyncUdpSocket alloc] initWithDelegate:self];
    [ssdpSock enableBroadcast:TRUE error:nil];
    NSString *str = @"M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: \"ssdp:discover\"\r\nMX: 1\r\nST: ssdp:all\r\n\r\n";
    [ssdpSock bindToPort:0 error:nil];
    [ssdpSock joinMulticastGroup:@"239.255.255.250" error:nil];
    [ssdpSock sendData:[str dataUsingEncoding:NSUTF8StringEncoding]
                toHost: @"239.255.255.250" port: 1900 withTimeout:-1 tag:1];
    [ssdpSock receiveWithTimeout: -1 tag:1];
    [NSTimer scheduledTimerWithTimeInterval: 5 target: self selector:@selector(completeSearch:) userInfo: self repeats: NO];
}

-(void) completeSearch: (NSTimer *)t
{
    NSLog(@"Search complete");
    [ssdpSock close];
    ssdpSock = nil;

    if ( bridgeHost == nil )
    {
        if ( tryCount++ < 2 ) {
            NSLog(@"Trying again...");
            self.messages.text=[NSString stringWithFormat:@"Trying again (%d)", tryCount];
            [self discoverDevices];
            return;
        } else {
            [delegate didFailToFindBridge];
        }
    }
}

// Note: This is UDP, so we presumably don't have to accumulate test here.
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    self.messages.text= [NSString stringWithFormat:@"Checking device: %@", host];
    NSString *upnpString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

    // Only check root devices
    if ( [upnpString rangeOfString:@"upnp:rootdevice"].length == 0 ) {
        return NO;
    }

    // Find the LOCATION: <url> and kick off a fetch of the description URL
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"LOCATION: *(.*)[\r\n]" options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:upnpString options:0 range:NSMakeRange(0, [upnpString length])];
    if ( match ) {
        //NSString *url = [upnpString substringWithRange:match.range];
        NSString *url = [upnpString substringWithRange:[match rangeAtIndex:1]]; // capture group 1
        [self fetchDescription:url];
    } else {
        NSLog(@"NO LOCATION from: %@", host);
    }

    return NO;
}

// end discover devices using SSDP

// Fetch description using NSURLConnection

- (void)fetchDescription:(NSString *)urlString
{
    NSURL *myURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:30];

    // TODO: rip this out and use NSURLConnection sendAsynchronousRequest:
    void (^onComplete)(DataURLConnection *) = ^(DataURLConnection *con) {
        [self checkDescriptionForBridge:con];
    };
    [DataURLConnection objectWithRequest:request onComplete:onComplete];
}

// end Fetch

// Begin utils

-(void)checkDescriptionForBridge:(DataURLConnection *)connection
{
    NSMutableData *data = ((DataURLConnection *) connection).data;
    NSString *txt = [[NSString alloc] initWithData:data encoding: NSASCIIStringEncoding] ;
    NSString *host = connection.originalRequest.URL.host;
    [self checkForBridge:txt fromIP:host];
}

-(void)checkForBridge:(NSString *)description fromIP:(NSString *)ip
{
    if ( bridgeHost != nil ) {
        //NSLog(@"already found bridge, ignoring response from: %@", ip);
        return;
    }

    if ( [description rangeOfString:@"Philips hue bridge" options:NSCaseInsensitiveSearch].length == 0 ) {
        return;
    }

    self.bridgeHost = ip;
    [delegate didFindBridge: ip];
}


-(void)verifyOrRegisterBridge:(NSString *)host
{
    NSLog(@"verify host = %@", host);
    // Get the stored bridge key
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [defaults stringForKey:@"bridgeKey"];
    if ( key == nil ) {
        NSLog(@"no key stored, let's register...");
        [self performSegueWithIdentifier:@"toRegister" sender:self]; // setup in prepareForSegue
    } else{
        [self tryVerifyBridge:host withKey:key];
    }
}

// Back from register controller
-(void)onRegisteredBridge:(NSString *)host withKey:(NSString *)key
{
    // Save it
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:key forKey:@"bridgeKey"];
    [self tryVerifyBridge:host withKey:key];
}


// verify

+(NSURL *) urlForBridge:(NSString *)host key:(NSString *)key
{
    NSString *urlString= [NSString stringWithFormat:@"http://%@/api/%@", host, key];
    return [NSURL URLWithString:urlString];
}

-(void)tryVerifyBridge:(NSString *)host withKey:(NSString *)key
{
    if ( self.verifyTryCount > MAX_VER_TRIES) {
        NSLog(@"Giving up verify...");
        self.messages.text= @"too many tries...";
        return;
    }

    NSLog(@"verify bridge: %@", key);
    NSURL *url = [DiscoverBridgeViewController urlForBridge:host key:key];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:2.0];

    void (^onComplete)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if ( data != nil && data.length > 0 )
        {
            NSString *verResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ( [verResponse rangeOfString:@"lights"].length != 0 && [verResponse rangeOfString:@"state"].length != 0 )
            {
                [self getLightsCount:verResponse];
                self.messages.text=@"Verified...";
                [self verifyBridgeSuccess:key];
                return;
            }
            if ( [verResponse rangeOfString:@"unauthorized user"].length != 0 )
            {
                self.messages.text=@"Key unauthorized...";
                NSLog(@"unauthorized key");
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults removeObjectForKey:@"bridgeKey"];
                [self verifyOrRegisterBridge:host];
                return;
            }
        }
        // reschedule
        self.messages.text=@"Error, trying again...";
        [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector: @selector(retryVerifyTime:) userInfo: key repeats: NO];
    };
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:onComplete];
    self.verifyTryCount++;
}

- (void)getLightsCount:(NSString *)verResponse
{
    NSData *jsonData = [verResponse dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&err];

    if (err) {
        NSLog(@"Error parsing JSON: %@", err);
    } else {
        NSDictionary *lightsDict = [json objectForKey:@"lights"];
        self.lightCount = lightsDict.count;
        NSLog(@"self.lightCount = %u", self.lightCount);
    }
}

// Note: a little inconsistent, get bridgeHost from instance, try key from userinfo
- (void)retryVerifyTime:(NSTimer *)timer
{
    NSString *key = [timer userInfo];
    NSLog(@"retrying key: %@", key);
    [self tryVerifyBridge:self.bridgeHost withKey:key];
}

-(void)verifyBridgeSuccess: (NSString *)key
{
    self.bridgeKey = key;
    [self performSegueWithIdentifier:@"toEffects" sender:self]; // setup in prepareForSegue
}

// end verify

// Begin utils

// begin DiscoverBridgeDelegate

- (void)didFindBridge:(NSString *)host {
    NSLog(@"Found bridge: host = %@", host);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:host forKey:@"bridgeHost"];
    [self verifyOrRegisterBridge:host];
}

- (void)didFailToFindBridge {
    NSLog(@"Failed to find bridge");
}

// end DiscoverBridgeDelegate

@end
