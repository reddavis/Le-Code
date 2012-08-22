//
//  LCUserPreferences.h
//  Le Code
//
//  Created by Red Davis on 08/08/2012.
//  Copyright (c) 2012 Riot. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LCUserPreferences : NSObject

@property (readwrite, nonatomic) NSString *username;
@property (readwrite, nonatomic) NSString *credential;
@property (readwrite, nonatomic) NSString *selectedPlaylist;

+ (LCUserPreferences *)sharedPreferences;

@end
