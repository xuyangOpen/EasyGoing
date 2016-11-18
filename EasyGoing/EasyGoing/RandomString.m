//
//  RandomString.m
//  EasyGoing
//
//  Created by King on 16/11/10.
//  Copyright © 2016年 kf. All rights reserved.
//

#import "RandomString.h"

@implementation RandomString

+ (NSString *)uuidString
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

@end
