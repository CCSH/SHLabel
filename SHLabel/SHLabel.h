//
//  SHLabel.h
//  SHFriendTimeLineUI
//
//  Created by CSH on 2017/4/6.
//  Copyright © 2017年 CSH. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 点击的模型
 */
@interface SHLabelModel : NSObject

//携带参数(用户信息什么的)
@property (nonatomic, copy) id parameter;
//点击范围
@property (nonatomic, assign) NSRange range;

@end

@class SHLabel;
/**
 文字局部点击回调
 */
typedef void (^SHLabelBlock)(SHLabel *lab, SHLabelModel *model);
/**
 文字局部点击视图
 */
@interface SHLabel : UILabel

//是否有点击效果
@property (nonatomic, assign) BOOL isEffect;
//点击属性集合
@property (nonatomic, strong) NSArray <SHLabelModel *>*modelArr;
//回调
@property (nonatomic, weak) SHLabelBlock block;

//处理点击(如果在其他地方使用了点击 请调用此方法)
- (void)handleAction:(UITapGestureRecognizer *)tap;

@end

