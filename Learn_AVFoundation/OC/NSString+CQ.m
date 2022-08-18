//
//  NSString+CQ.m
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/8/18.
//

#import "NSString+CQ.h"

@implementation NSString (CQ)

- (NSString *)stringByMatchingRegex:(NSString *)regex capture:(NSUInteger)capture {
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:nil];
    NSTextCheckingResult *result = [expression firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
    if (capture < [result numberOfRanges]) {
        NSRange range = [result rangeAtIndex:capture];
        return [self substringWithRange:range];
    }
    return nil;
}

- (BOOL)containsString:(NSString *)substring {
    NSRange range = [self rangeOfString:substring];
    return range.location != NSNotFound;
}

@end
