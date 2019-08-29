//
//  TextFlowLayoutView.h
//  HongheTeacher
//
//  Created by EDZ on 2018/3/2.
//  Copyright © 2018年 HH. All rights reserved.
//

#import <UIKit/UIKit.h>

/** item参数key 对应value全部为字符串 */
extern NSString *const TextFlowLayoutViewImage;           ///< 图片（文件名）
extern NSString *const TextFlowLayoutViewTitle;           ///< 标题
extern NSString *const TextFlowLayoutViewItemColor;       ///< item背景颜色（16进制色值）
extern NSString *const TextFlowLayoutViewTitleColor;      ///< item标题颜色（16进制色值）
extern NSString *const TextFlowLayoutViewSelectItemColor; ///< item选中背景颜色（16进制色值）
extern NSString *const TextFlowLayoutViewSelectTitleColor;///< item选中标题颜色（16进制色值）
extern NSString *const TextFlowLayoutViewItemRadius;      ///< item圆角
extern NSString *const TextFlowLayoutViewItemBorderWidth; ///< item边框宽度
extern NSString *const TextFlowLayoutViewItemBorderColor; ///< item边框颜色（16进制色值）
extern NSString *const TextFlowLayoutViewFontSize;        ///< 标题字号

@class TextFlowLayoutView;
@protocol TextFlowLayoutViewDelegate <NSObject>
@required;
/// 设置item高度(暂时不支持index设置)
- (CGFloat)flowLayoutView:(TextFlowLayoutView *)flowLayoutView itemHeightFoxIndex:(NSInteger)index;

@optional;
/// 设置item水平间距
- (CGFloat)flowLayoutView:(TextFlowLayoutView *)flowLayoutView minimumInteritemSpacingFoxIndex:(NSInteger)index;
/// 设置item垂直间距（暂时不支持index设置）
- (CGFloat)flowLayoutView:(TextFlowLayoutView *)flowLayoutView minimumLineSpacingFoxIndex:(NSInteger)index;
/// 设置item中文字与标签边缘距离
- (CGFloat)flowLayoutViewForExtraWidth:(TextFlowLayoutView *)flowLayoutView;
/// 点击item
- (void)clickTagViewWithIndex:(NSInteger)index text:(NSString *)text;

@end

@protocol TextFlowLayoutViewDataSource <NSObject>
@required;
/// item个数
- (NSInteger)flowLayoutViewNumberOfRows:(TextFlowLayoutView *)flowLayoutView;
/// item参数
- (NSDictionary *)flowLayoutView:(TextFlowLayoutView *)flowLayoutView buttonConfigForRowAtIndex:(NSInteger)index;

@optional;


@end

/**
  文字标签式流式布局
 */
@interface TextFlowLayoutView : UIView

@property (nonatomic, assign) CGFloat itemHeight;                        ///< item高度
@property (nonatomic, assign) BOOL allowShank;                           ///< 是否允许长按抖动、拖动 缺省值为NO
@property (nonatomic, assign) BOOL singleSelectMode;                     ///< 是否为单选模式 缺省值为NO
@property (nonatomic, weak) id<TextFlowLayoutViewDelegate> delegate;
@property (nonatomic, weak) id<TextFlowLayoutViewDataSource> dataSource;

/** 刷新数据*/
- (void)reloadData;
/** 获得控件高度*/
- (CGFloat)getViewHeight;
/** 设置标签高度*/
- (void)setItemHeight:(CGFloat)height;
/** 设置最大宽度*/
- (void)setMaxItemWidth:(CGFloat)maxWidth;
/** 设置标签间距*/
- (void)setEdgeWidth:(CGFloat)width;
/** 设置标签中文字与边缘的距离（单边）*/
- (void)setExtraWidth:(CGFloat)extraWidth;
/** 设置行间距*/
- (void)setRowSpacing:(CGFloat)spacing;
/** 设置标签圆角*/
- (void)setRadius:(CGFloat)radius;
/** 设置标签边框宽度*/
- (void)setBorderWidth:(CGFloat)width;
/** 设置标签边框颜色*/
- (void)setBorderColor:(UIColor *)color;
///** 设置字体*/
- (void)setTitleFont:(UIFont *)font;
/** 设置标签背景颜色*/
- (void)setTagbackgroundColor:(UIColor *)color;
/** 设置标签字体颜色*/ 
- (void)setTagTitleColor:(UIColor *)color;
/** 设置选中下标（单选模式）*/
- (void)setSelectIndex:(NSInteger)index;

@end
