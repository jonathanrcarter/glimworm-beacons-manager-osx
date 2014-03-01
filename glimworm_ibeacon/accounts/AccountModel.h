//
//  Account.h
//  glimworm_ibeacon
//
//  Created by Jonathan Carter on 25/12/2013.
//  Copyright (c) 2013 Jonathan Carter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AccountModel : NSObject {
    NSString * name;
    NSString * type;
    NSString * url;
    NSString * username;
    NSString * password;
}
@property(retain, readwrite) NSString * name;
@property(retain, readwrite) NSString * type;
@property(retain, readwrite) NSString * url;
@property(retain, readwrite) NSString * username;
@property(retain, readwrite) NSString * password;

@end
