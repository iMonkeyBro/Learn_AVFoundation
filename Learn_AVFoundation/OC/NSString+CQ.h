//
//  NSString+CQ.h
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/8/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CQ)

- (NSString *)stringByMatchingRegex:(NSString *)regex capture:(NSUInteger)capture;

- (BOOL)containsString:(NSString *)substring;

@end

NS_ASSUME_NONNULL_END
