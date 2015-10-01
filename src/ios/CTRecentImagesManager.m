/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CTRecentImagesManager.h"
#import "CTRecentImages.h"

@implementation CTRecentImagesManager

@synthesize callbackId;

- (void) getRecentImages:(CDVInvokedUrlCommand *)command {
    self.callbackId = command.callbackId;
	NSDictionary *options = [command.arguments objectAtIndex: 0];
    CTRecentImages *recentImage = [[CTRecentImages alloc] init];
    
    [recentImage fetchRecentPhotosWithImageOptions:options completion:^(NSArray *images) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:images];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }];
}
@end