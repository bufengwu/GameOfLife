//
//  FarmlandViewModel.h
//  GameOfLife
//
//  Created by XYDM001 on 2017/4/10.
//  Copyright © 2017年 xydSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FarmlandViewModel : NSObject

@property (nonatomic, strong) NSArray<NSArray *> *mapArray;

@property (nonatomic, assign) float activityRate;
@property (nonatomic, assign) NSUInteger generationCount;

- (void)refreshMap;

- (void)reBuildMapWithArrayLenth:(NSUInteger)length activityRate:(float)activityRate;

@end
