//
//  DataURLConnection.h
//  HueEffects
//
//  Created by pat on 12/16/12.
//  Copyright (c) 2012 pat. All rights reserved.
//

#import <Foundation/Foundation.h>

// TODO: rip this out and use NSURLConnection sendAsynchronousRequest.
// TODO: I wrote this before I was aware there is now a block oriented API (doh).
@interface DataURLConnection : NSURLConnection {
}
@property(nonatomic, strong) NSMutableData *data;
@property(nonatomic, copy) void (^onComplete)(DataURLConnection *);
@property(nonatomic, strong) NSURLRequest *request;

- (id)initWithRequest:(NSURLRequest *)aRequest onComplete:(void (^)(DataURLConnection *))anOnComplete;

+ (id)objectWithRequest:(NSURLRequest *)aRequest onComplete:(void (^)(DataURLConnection *))anOnComplete;


@end

