//
//  Created by Murphy on 11/06/17.
//  Copyright © 2017 Murphy. All rights reserved.
//


#import "Utils.h"

@implementation Utils

+ (BOOL)isJailbroken
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:@"/bin/bash"]) {
        return YES;
    } else if ([fileManager fileExistsAtPath:@"/bin/ls"]) {
        return YES;
    }
    
    return NO;
}

+ (NSString *)decryption:(NSString *)string withKey:(NSString *)key
{
  
    // Create data object from the string
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    // Get pointer to data to obfuscate
    char *dataPtr = (char *) [data bytes];
    
    // Get pointer to key data
    char *keyData = (char *) [[key dataUsingEncoding:NSUTF8StringEncoding] bytes];
    
    // Points to each char in sequence in the key
    char *keyPtr = keyData;
    int keyIndex = 0;
    
    // For each character in data, xor with current value in key
    for (int x = 0; x < [data length]; x++)
    {
        // Replace current character in data with
        // current character xor'd with current key value.
        // Bump each pointer to the next character
        *dataPtr = *dataPtr ^ *keyPtr;
        dataPtr++;
        keyPtr++;
        
        // If at end of key data, reset count and
        // set key pointer back to start of key value
        if (++keyIndex == [key length])
            keyIndex = 0, keyPtr = keyData;
    }
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


@end
