//
//  NSURL+Utilities.h
//  mCampus
//
//  Created by Ashish Maheshwari on 7/21/10.
//  Copyright 2010 Erixir Inc Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSURL (Utilities)

- (NSURL*) urlByReplacingHost:(NSString*)host andPort:(NSUInteger)port ;

@end
