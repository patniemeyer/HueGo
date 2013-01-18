//
//  DataURLConnection.m
//  HueEffects
//
//  Created by pat on 12/16/12.
//  Copyright (c) 2012 pat. All rights reserved.
//

#import "DataURLConnection.h"

// TODO: rip this out and use NSURLConnection sendAsynchronousRequest
// TODO: I wrote this before I was aware there is now a block oriented API (doh).
@implementation DataURLConnection
@synthesize data, onComplete, request;

- (id)initWithRequest:(NSURLRequest *)aRequest onComplete:(void (^)(DataURLConnection *))anOnComplete
{
    self = [super init];
    if (self)
    {
        // use self. here?  generated does not
        self.request = aRequest;
        self.onComplete = anOnComplete;
    }
    (void)[self initWithRequest:request delegate:self];

    return self;
}

+ (id)objectWithRequest:(NSURLRequest *)aRequest onComplete:(void (^)(DataURLConnection *))anOnComplete {
    return [[DataURLConnection alloc] initWithRequest:aRequest onComplete:anOnComplete];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
    [self.data appendData:d];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"error: %@", error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"onComplete");
    self.onComplete(self);
}


@end
