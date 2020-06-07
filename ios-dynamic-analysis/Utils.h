//  Created by Murphy on 11/06/17.
//  Copyright © 2017 Murphy. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface Utils : NSObject

+ (BOOL)isJailbroken;
+ (NSString *)decryption:(NSString *)string withKey:(NSString *)key;

@end
