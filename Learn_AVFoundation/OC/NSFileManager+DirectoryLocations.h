//
//  NSFileManager+DirectoryLocations.h
//  Learn_AVFoundation
//
//  Created by 刘超群 on 2022/3/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 DirectoryLocations is a set of global methods for finding the fixed location directoriess.
 */
@interface NSFileManager (DirectoryLocations)

- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                           inDomain:(NSSearchPathDomainMask)domainMask
                appendPathComponent:(NSString *)appendComponent
                              error:(NSError **)errorOut;

- (NSString *)applicationSupportDirectory;

@end

NS_ASSUME_NONNULL_END
