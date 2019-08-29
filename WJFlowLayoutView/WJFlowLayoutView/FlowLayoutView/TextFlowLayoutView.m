//
//  TextFlowLayoutView.m
//  HongheTeacher
//
//  Created by EDZ on 2018/3/2.
//  Copyright © 2018年 HH. All rights reserved.
//

#import "TextFlowLayoutView.h"
#import "UIButton+XQAdd.h"
#import "UIColor+XQAdd.h"
#import "UIImage+XQAdd.h"

NSString *const TextFlowLayoutViewImage = @"image";
NSString *const TextFlowLayoutViewTitle = @"title";
NSString *const TextFlowLayoutViewItemColor = @"itemColor";
NSString *const TextFlowLayoutViewTitleColor = @"titleColor";
NSString *const TextFlowLayoutViewSelectItemColor = @"itemSelectColor";
NSString *const TextFlowLayoutViewSelectTitleColor = @"titleSelectColor";
NSString *const TextFlowLayoutViewItemRadius = @"itemRadius";
NSString *const TextFlowLayoutViewItemBorderWidth = @"itemBorderWidth";
NSString *const TextFlowLayoutViewItemBorderColor = @"itemBorderColor";
NSString *const TextFlowLayoutViewFontSize = @"fontSize";

@interface TextFlowLayoutView() {
    BOOL contain;
    CGPoint startPoint;
    CGPoint originPoint;
}

@property (nonatomic, assign) CGFloat viewHeight;              ///< view高度
@property (nonatomic, assign) CGFloat totalWidth;              ///< 总宽度
@property (nonatomic, assign) CGFloat itemHight;               ///< 标签高度
@property (nonatomic, assign) CGFloat itemMaxWidth;            ///< 最大宽度（上限）
@property (nonatomic, assign) CGFloat edgeWidth;               ///< 标签间距
@property (nonatomic, assign) CGFloat rowSpacing;              ///< 行间距
@property (nonatomic, assign) CGFloat extraWidth;              ///< 设置标签中文字与边缘的距离（单边）
@property (nonatomic, assign) NSInteger selectIndex;           ///< 单选模式初始选中下标
@property (nonatomic, assign) BOOL isShanking;                 ///< 是否正在抖动
@property (nonatomic, assign) BOOL deleteMode;                 ///< 是否为单击删除模式
@property (nonatomic, strong) NSMutableArray <UIButton *>*buttonArray;     ///< button数组

/// 保存当前状态（button，view）
@property (nonatomic, assign) CGFloat cur_xPoint;              ///< 目前的x位置
@property (nonatomic, assign) CGFloat cur_yPoint;              ///< 目前的y位置
@property (nonatomic, strong) UIFont *font;                    ///< 字体
@property (nonatomic, strong) UIColor *curBackColor;           ///< 当前按钮背景颜色
@property (nonatomic, strong) UIColor *curTextColor;           ///< 当前字体颜色
@property (nonatomic, assign) CGFloat curRadius;               ///< 当前按钮圆角

@end

@implementation TextFlowLayoutView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        self.buttonArray = [NSMutableArray new];
        _edgeWidth = 10;
        _rowSpacing = 10;
        _extraWidth = 7;
        _font = [UIFont systemFontOfSize:10];
        [self setupUIWithFrame:frame];
    }
    return self;
}

- (void)setupUIWithFrame:(CGRect)frame {
    [self.buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.buttonArray removeAllObjects];
    float now_xPoint = 0;
    float now_yPoint = 0;
    
    _itemHight = [self.delegate flowLayoutView:self itemHeightFoxIndex:0];
    if ([self.delegate respondsToSelector:@selector(flowLayoutView:minimumLineSpacingFoxIndex:)]) {
        _rowSpacing = [self.delegate flowLayoutView:self minimumLineSpacingFoxIndex:0];
    }
    NSInteger total = [self.dataSource flowLayoutViewNumberOfRows:self];
    
    for (int i = 0; i < total; i++) {
        // 取每个按钮的配置
        NSDictionary *dic = [self.dataSource flowLayoutView:self buttonConfigForRowAtIndex:i];
        NSArray *keyArr = [dic allKeys];
        UIFont *font;
        UIColor *backColor;
        UIColor *titleColor;
        if ([keyArr containsObject:@"fontSize"]) {
           font = [UIFont systemFontOfSize:[dic[@"fontSize"] floatValue]];
        } else {
           font = _font;
        }
        NSString *content = dic[@"title"];
        if ([keyArr containsObject:@"itemColor"]) {
            backColor = [UIColor colorWithHexString:dic[@"itemColor"]];
        } else {
            backColor = [UIColor blueColor];
        }
        
        if ([keyArr containsObject:@"titleColor"]) {
            titleColor = [UIColor colorWithHexString:dic[@"titleColor"]];
        } else {
            titleColor = [UIColor blackColor];
        }
        
        UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        selectBtn.tag = 1000 + i;
        [selectBtn setTitle:content forState:UIControlStateNormal];
        if ([keyArr containsObject:@"image"]) {
            [selectBtn setImage:[UIImage imageNamed:dic[@"image"]] forState:0];
            if ([self.delegate respondsToSelector:@selector(flowLayoutViewForExtraWidth:)]) {
                _extraWidth = [self.delegate flowLayoutViewForExtraWidth:self];
            } else {
                _extraWidth = 17.5f;
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(flowLayoutViewForExtraWidth:)]) {
                _extraWidth = [self.delegate flowLayoutViewForExtraWidth:self];
            }
        }
        selectBtn.layer.masksToBounds = YES;
        if ([keyArr containsObject:@"itemRadius"]) {
            selectBtn.layer.cornerRadius = [dic[@"itemRadius"] floatValue];
        }
        if ([keyArr containsObject:@"itemBorderWidth"]) {
            selectBtn.layer.borderWidth = [dic[@"itemBorderWidth"] floatValue];
        }
        if ([keyArr containsObject:@"itemBorderColor"]) {
            selectBtn.layer.borderColor = [UIColor colorWithHexString:dic[@"itemBorderColor"]].CGColor;
        }
        
        selectBtn.titleLabel.font = font;
        [selectBtn setTitleColor:titleColor forState:UIControlStateNormal];
        [selectBtn setBackgroundImage:[UIImage imageWithColor:backColor] forState:UIControlStateNormal];
        if ([keyArr containsObject:@"itemSelectColor"]) {
            UIColor *selectColor = [UIColor colorWithHexString:dic[@"itemSelectColor"]];
            [selectBtn setBackgroundImage:[UIImage imageWithColor:selectColor] forState:UIControlStateSelected];
        }
        if ([keyArr containsObject:@"titleSelectColor"]) {
            UIColor *selectTitleColor = [UIColor colorWithHexString:dic[@"titleSelectColor"]];
            [selectBtn setTitleColor:selectTitleColor forState:UIControlStateSelected];
        }
        /// 为按钮增加Action
        [selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClick:)];
        [selectBtn addGestureRecognizer:longPress];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panClick:)];
        [selectBtn addGestureRecognizer:pan];
        
        /// 计算UI位置
        if ([self.delegate respondsToSelector:@selector(flowLayoutView:minimumInteritemSpacingFoxIndex:)]) {
            _edgeWidth = [self.delegate flowLayoutView:self minimumInteritemSpacingFoxIndex:i];
        }
        CGSize size = [self sizeWithString:content UIHeight:_itemHight font:font];
        /// 如果额外留白没有的话就不向下取整了，如果有留白就可以向下取整
        CGFloat width = _extraWidth ? floor(size.width + _extraWidth * 2) : size.width;
        if (_itemMaxWidth) {
            width = _itemMaxWidth;
        }
        float edge_width = _edgeWidth;
        
        if ((now_xPoint + edge_width + width) < frame.size.width) {
            if (now_xPoint == 0) {
                selectBtn.frame = CGRectMake(now_xPoint, now_yPoint, width, _itemHight);
                now_xPoint += width;
            } else {
                selectBtn.frame = CGRectMake(now_xPoint+edge_width, now_yPoint, width, _itemHight);
                now_xPoint += width +edge_width;
            }
        } else {
            now_xPoint = 0;
            now_yPoint += _itemHight + _rowSpacing;
            if (now_xPoint == 0) {
                selectBtn.frame = CGRectMake(now_xPoint, now_yPoint, width, _itemHight);
                now_xPoint += width;
            } else {
                selectBtn.frame = CGRectMake(now_xPoint+edge_width, now_yPoint, width, _itemHight);
                now_xPoint += width +edge_width;
            }
        }
        if ([keyArr containsObject:@"image"]) {
            [selectBtn setImagePosition:LXMImagePositionRight spacing:6];
        }
        if (i == _selectIndex && _singleSelectMode) {
            selectBtn.selected = YES;
        }
        [self.buttonArray addObject:selectBtn];
        [self addSubview:selectBtn];
    }
    
    now_yPoint += _itemHight;
    // 记录当前位置
    _cur_xPoint = now_xPoint;
    _cur_yPoint = now_yPoint;
    self.viewHeight = now_yPoint;
    self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, now_yPoint);
}

- (void)reloadData {
    [self setupUIWithFrame:self.frame];
}

#pragma mark - Action
- (void)selectBtnClick:(UIButton *)btn {
    if (self.isShanking) {
        for (UIButton *btn in self.buttonArray) {
            [btn.layer removeAllAnimations];
        }
        self.isShanking = NO;
        return;
    }
    if (self.singleSelectMode) {
        [self setSelectIndex:[self.buttonArray indexOfObject:btn]];
    }
    if ([self.delegate respondsToSelector:@selector(clickTagViewWithIndex:text:)]) {
        [self.delegate clickTagViewWithIndex:btn.tag - 1000 text:btn.titleLabel.text];
    }
}

- (void)longClick:(UILongPressGestureRecognizer *)sender {
    if (self.allowShank) {
        for (UIButton *btn in self.buttonArray) {
            [self addShakingAnimation:btn];
        }
        self.isShanking = YES;
        [self tranformWithSender:sender];
    }
    
}

- (void)panClick:(UIPanGestureRecognizer *)sender {
    if (self.isShanking) {
        [self tranformWithSender:sender];
    }
}

/// 拖动动作
- (void)tranformWithSender:(UIGestureRecognizer *)sender {
    UIButton *btn = (UIButton *)sender.view;
    if (sender.state == UIGestureRecognizerStateBegan) {
        startPoint = [sender locationInView:sender.view];
        originPoint = btn.center;
        NSTimeInterval Duration = 0.5;
        [UIView animateWithDuration:Duration animations:^{
            btn.transform = CGAffineTransformMakeScale(1.1, 1.1);
            btn.alpha = 0.7;
        }];
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint newPoint = [sender locationInView:sender.view];
        CGFloat deltaX = newPoint.x-startPoint.x;
        CGFloat deltaY = newPoint.y-startPoint.y;
        CGPoint newCenter = CGPointMake(btn.center.x+deltaX,btn.center.y+deltaY);
        /// 限制移动区域，不能超出父视图
        newCenter.y = MAX(sender.view.bounds.size.height/2, newCenter.y);
        newCenter.y = MIN(self.bounds.size.height - sender.view.bounds.size.height/2,  newCenter.y);
        newCenter.x = MAX(sender.view.bounds.size.width/2, newCenter.x);
        newCenter.x = MIN(self.bounds.size.width - sender.view.bounds.size.width/2,newCenter.x);
        btn.center = newCenter;
        //NSLog(@"center = %@",NSStringFromCGPoint(btn.center));
        NSInteger index = [self indexOfPoint:btn.center withButton:btn];
        if (index<0) {
            contain = NO;
        } else {
            [UIView animateWithDuration:0.5 animations:^{
                CGPoint temp = CGPointZero;
                UIButton *button = self.buttonArray[index];
                temp = button.center;
                button.center = self->originPoint;
                btn.center = temp;
                self->originPoint = btn.center;
                self->contain = YES;
            }];
        }
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.5 animations:^{
            btn.transform = CGAffineTransformIdentity;
            btn.alpha = 1.0;
            if (!self->contain) {
                btn.center = self->originPoint;
            }
        }];
    }
}

- (NSInteger)indexOfPoint:(CGPoint)point withButton:(UIButton *)btn {
    for (NSInteger i = 0;i<_buttonArray.count;i++) {
        UIButton *button = _buttonArray[i];
        if (button != btn) {
          if (CGRectContainsPoint(button.frame, point)) {
            return i;
          }
        }
    }
    return -1;
    
}

#pragma mark - 抖动动画
#define Angle2Radian(angle) ((angle) / 180.0 * M_PI)
- (void)addShakingAnimation:(UIButton *)btn {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"transform.rotation";
    anim.values = @[@(Angle2Radian(-5)), @(Angle2Radian(5)), @(Angle2Radian(-5))];
    anim.duration = 0.25;
    // 动画次数设置为最大
    anim.repeatCount = MAXFLOAT;
    // 保持动画执行完毕后的状态
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    [btn.layer addAnimation:anim forKey:@"shake"];
}

#pragma mark - Setter && Getter
- (CGFloat)getViewHeight {
    return self.viewHeight;
}

/** 设置标签高度*/
- (void)setItemHeight:(CGFloat)height {
    _itemHight = height;
}

/** 设置最大宽度*/
- (void)setMaxItemWidth:(CGFloat)maxWidth {
    _itemMaxWidth = maxWidth;
}
/** 设置标签间距*/
- (void)setEdgeWidth:(CGFloat)width {
    _edgeWidth = width;
}

/** 设置标签中文字与边缘的距离*/
- (void)setExtraWidth:(CGFloat)extraWidth {
    _extraWidth = extraWidth;
}

/** 设置行间距*/
- (void)setRowSpacing:(CGFloat)spacing {
    _rowSpacing = spacing;
}

/** 设置字体*/
- (void)setTitleFont:(UIFont *)font {
    _font = font;
    for (UIButton *btn in self.buttonArray) {
        btn.titleLabel.font = font;
    }
}

/** 设置标签圆角*/
- (void)setRadius:(CGFloat)radius {
    _curRadius = radius;
    for (UIButton *btn in self.buttonArray) {
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = radius;
    }
}

/** 设置标签边框宽度*/
- (void)setBorderWidth:(CGFloat)width {
    for (UIButton *btn in self.buttonArray) {
        btn.layer.borderWidth = width;
    }
}
/** 设置标签边框颜色*/
- (void)setBorderColor:(UIColor *)color {
    for (UIButton *btn in self.buttonArray) {
        btn.layer.borderColor = color.CGColor;
    }
}

/** 设置标签背景颜色*/
- (void)setTagbackgroundColor:(UIColor *)color {
    _curBackColor = color;
    for (UIButton *btn in self.buttonArray) {
        btn.backgroundColor = color;
    }
}

/** 设置标签字体颜色*/
- (void)setTagTitleColor:(UIColor *)color {
    _curTextColor = color;
    for (UIButton *btn in self.buttonArray) {
        [btn setTitleColor:color forState:UIControlStateNormal];
    }
}

/** 设置选中下标（单选模式）*/
- (void)setSelectIndex:(NSInteger)index {
    _selectIndex = index;
    for (int i = 0; i < _buttonArray.count; i++) {
        UIButton *btn = _buttonArray[i];
        if (i == _selectIndex) {
            btn.selected = YES;
        } else {
            btn.selected = NO;
        }
    }
}

#pragma mark - Private
- (CGSize)sizeWithString:(NSString *)string UIHeight:(CGFloat)height font:(UIFont *)font {
    CGRect rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                       options: NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:font}
                                       context:nil];
    return rect.size;
}

@end
