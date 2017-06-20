//
//  FarmlandViewModel.m
//  GameOfLife
//
//  Created by XYDM001 on 2017/4/10.
//  Copyright © 2017年 xydSDK. All rights reserved.
//

#import "FarmlandViewModel.h"

@implementation FarmlandViewModel

- (void)refreshMap {
    self.generationCount++;
    self.mapArray = [self updateMap:self.mapArray];
}

- (void)reBuildMapWithArrayLenth:(NSUInteger)length activityRate:(float)activityRate {
    self.generationCount = 0;
    self.mapArray = [self setSeedWithWidth:length percentage:activityRate];
}

- (float)activityRate {
    float survival = 0;
    for (int i = 0; i < self.mapArray.count; i++) {
        for (int j = 0; j < self.mapArray.count; j++) {
            if ([self.mapArray[i][j] boolValue]) {
                survival++;
            }
        }
    }
    return survival/pow(self.mapArray.count, 2);
}

/**
 更新下一幅画
 
 @param map 现在的画像
 @return 下一幅画像
 */
- (NSArray<NSArray *> *)updateMap:(NSArray<NSArray *> *)map {
    NSUInteger mapWidth = map.count;
    NSMutableArray<NSMutableArray *> *newMap = [NSMutableArray arrayWithCapacity:mapWidth];
    for (int i = 0; i < mapWidth; i++) {
        newMap[i] = [NSMutableArray arrayWithCapacity:mapWidth];
        for (int j = 0; j < mapWidth; j++) {
            newMap[i][j] = @(NO);
        }
    }
    
    for (int i = 0; i < mapWidth; i++) {
        for (int j = 0; j < mapWidth; j++) {
            //统计邻居点存活数目：剔除越界、自身
            int neighbor = 0;
            for (int m = i-1; m <= i+1; m++) {
                if(m < 0 || m >= mapWidth)
                    continue;
                for (int n = j-1; n <= j+1; n++) {
                    if(n < 0 || n >= mapWidth)
                        continue;
                    if(m == i && n == j)
                        continue;
                    bool tmp = [map[m][n] boolValue];
                    if (tmp) {
                        neighbor++;
                    }
                }
            }
            
            //生死规则
            switch (neighbor) {
                case 2:
                    newMap[i][j] = map[i][j];
                    break;
                case 3:
                    newMap[i][j] = @(YES);
                    break;
            }
            
        }
    }
    return newMap;
}

/**
 初始化二维数组
 
 @param mapWidth 二维数组边长
 @param percentage 初始生命占比
 @return 二维数组
 */
- (NSArray<NSArray *> *)setSeedWithWidth:(NSUInteger)mapWidth percentage:(float)percentage {
    NSMutableArray<NSMutableArray *> *map = [NSMutableArray arrayWithCapacity:mapWidth];
    for (int i = 0; i < mapWidth; i++) {
        map[i] = [NSMutableArray arrayWithCapacity:mapWidth];
        for (int j = 0; j < mapWidth; j++) {
            map[i][j] = @(NO);
        }
    }
    
    NSUInteger seedNum = mapWidth*mapWidth * percentage;
    NSArray *a = [self randSeedWithNum:seedNum ofTotal:mapWidth*mapWidth];
    
    for (int i = 0; i < seedNum; i++) {
        int x = [a[i] intValue]/mapWidth;
        int y = [a[i] intValue]%mapWidth;
        
        map[x][y] = @(YES);
    }
    return map;
}

/**
 total个数内，随机选出num个数
 
 @param num 要选出的个数
 @param total 备选集合
 @return 结果数组，取前num个
 */
- (NSArray *)randSeedWithNum:(NSUInteger)num ofTotal:(NSUInteger)total {
    NSMutableArray<NSNumber *> *a = [NSMutableArray arrayWithCapacity:total];
    for (int i = 0; i < total; i++) {
        a[i] = @(i);
    }
    for (int i = 0; i < num; i++) {
        int w = arc4random()%(total-i) + i;
        NSNumber *t = a[i];
        a[i] = a[w];
        a[w] = t;
    }
    return a;
}

@end
