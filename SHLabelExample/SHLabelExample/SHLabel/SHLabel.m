//
//  SHLabel.m
//  SHFriendTimeLineUI
//
//  Created by CSH on 2017/4/6.
//  Copyright © 2017年 CSH. All rights reserved.
//

#import "SHLabel.h"
#import <CoreText/CoreText.h>

@implementation SHLabelModel

@end

@implementation SHLabel

#pragma mark - 实例化
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //初始化
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self setup];
}

#pragma mark - 初始化
- (void)setup{
    
    self.userInteractionEnabled = YES;
    //添加点击
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAction:)]];
}

#pragma mark - Action
- (void)handleAction:(UITapGestureRecognizer *)tap{
    
    //点击了父视图的位置
    CGPoint point = [tap locationInView:self];
    //找到点击位置
    CFIndex index = [self characterIndexAtPoint:point];

    __block SHLabelModel *model;
    //查找点击位置
    [self.modelArr enumerateObjectsUsingBlock:^(SHLabelModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //是否在点击位置
        if (index >= obj.range.location && index <= (obj.range.location + obj.range.length)) {
            if (self.isEffect) {
                [self addEffectWithRange:obj.range];
            }
            model = obj;
            *stop = YES;
        }
    }];
    
    if (self.block) {
        self.block(self, model);
    }
    return ;
}

#pragma mark - 添加效果
- (void)addEffectWithRange:(NSRange)range{
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
    [att addAttribute:NSTextEffectAttributeName value:NSTextEffectLetterpressStyle range:range];
    self.attributedText = att;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [att removeAttribute:NSTextEffectAttributeName range:range];
        self.attributedText = att;
    });
}

#pragma mark - 获取点击的字符
- (CFIndex)characterIndexAtPoint:(CGPoint)p {
    if (!CGRectContainsPoint(self.bounds, p)) {
        return NSNotFound;
    }
    
    CGRect textRect = [self textRectForBounds:self.bounds limitedToNumberOfLines:self.numberOfLines];
    if (!CGRectContainsPoint(textRect, p)) {
        return NSNotFound;
    }
    
    // Offset tap coordinates by textRect origin to make them relative to the origin of frame
    p = CGPointMake(p.x - textRect.origin.x, p.y - textRect.origin.y);
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    p = CGPointMake(p.x, textRect.size.height - p.y);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedText);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, (CFIndex)[self.attributedText length]), path, NULL);
    if (frame == NULL) {
        CGPathRelease(path);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = (self.numberOfLines > 0 ? MIN(self.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines));
    if (numberOfLines == 0) {
        CFRelease(frame);
        CGPathRelease(path);
        return NSNotFound;
    }
    
    CFIndex idx = NSNotFound;
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        //lineOrigin.y-=(numberOfLines-1)*[self lineSp];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        // Get bounding information of line
        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
        CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = (CGFloat)floor(lineOrigin.y - descent);
        CGFloat yMax = (CGFloat)ceil(lineOrigin.y + ascent);
        // Apply penOffset using flushFactor for horizontal alignment to set lineOrigin since this is the horizontal offset from drawFramesetter
        CGFloat flushFactor = TTTFlushFactorForTextAlignment(self.textAlignment);
        CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, textRect.size.width);
        lineOrigin.x = penOffset;
        
        // Check if we've already passed the line
        if (p.y > yMax) {
            break;
        }
        // Check if the point is within this line vertically
        if (p.y >= yMin) {
            // Check if the point is within this line horizontally
            if (p.x >= lineOrigin.x && p.x <= lineOrigin.x + width) {
                // Convert CT coordinates to line-relative coordinates
                CGPoint relativePoint = CGPointMake(p.x - lineOrigin.x, p.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                break;
            }
        }
    }
    CFRelease(framesetter);
    CFRelease(frame);
    CGPathRelease(path);
    if (idx > self.attributedText.length) {
        idx = -1;
    }
    return idx;
}

- (CGRect)textRectForBounds:(CGRect)bounds
     limitedToNumberOfLines:(NSInteger)numberOfLines {
    bounds = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsZero);
    if (!self.attributedText) {
        return [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    }
    
    CGRect textRect = bounds;
    
    // Calculate height with a minimum of double the font pointSize, to ensure that CTFramesetterSuggestFrameSizeWithConstraints doesn't return CGSizeZero, as it would if textRect height is insufficient.
    textRect.size.height = MAX(self.font.lineHeight * MAX(2, numberOfLines), bounds.size.height);
    
    // Adjust the text to be in the center vertically, if the text size is smaller than bounds
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedText);
    
    CGSize textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, (CFIndex)[self.attributedText length]), NULL, textRect.size, NULL);
    textSize = CGSizeMake(ceil(textSize.width), ceil(textSize.height)); // Fix for iOS 4, CTFramesetterSuggestFrameSizeWithConstraints sometimes returns fractional sizes
    
    if (textSize.height < bounds.size.height) {
        CGFloat yOffset = 0.0f;
        switch (0) {
            case 0:
                yOffset = floor((bounds.size.height - textSize.height) / 2.0f);
                break;
            case 1:
                yOffset = bounds.size.height - textSize.height;
                break;
            case 2:
            default:
                break;
        }
        textRect.origin.y += yOffset;
    }
    CFRelease(framesetter);
    return textRect;
}

static inline CGFloat TTTFlushFactorForTextAlignment(NSTextAlignment textAlignment) {
    switch (textAlignment) {
        case NSTextAlignmentCenter:
            return 0.5f;
        case NSTextAlignmentRight:
            return 1.0f;
        case NSTextAlignmentLeft:
        default:
            return 0.0f;
    }
}

@end
