//
//  ViewController.m
//  WJFlowLayoutView
//
//  Created by XIYUN on 2019/8/29.
//  Copyright © 2019 WJ. All rights reserved.
//

#import "ViewController.h"
#import "TextFlowLayoutView.h"

@interface ViewController ()<TextFlowLayoutViewDelegate,TextFlowLayoutViewDataSource>

@property (nonatomic, copy) NSArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = @[@"第一个标签",@"第二个标签",@"短一点",@"特别长长长长长长长长长长",@"最后一个"];
    TextFlowLayoutView *tagView = [[TextFlowLayoutView alloc] initWithFrame:CGRectMake(12, 56, self.view.bounds.size.width - 24, 0)];
    tagView.delegate = self;
    tagView.dataSource = self;
    tagView.singleSelectMode = YES;
    tagView.allowShank = YES;
    [tagView reloadData];
    [self.view addSubview:tagView];
}

#pragma mark - TextFlowLayoutViewDelegate && TextFlowLayoutViewDataSource
- (CGFloat)flowLayoutView:(TextFlowLayoutView *)flowLayoutView itemHeightFoxIndex:(NSInteger)index {
    return 28.f;
}

- (CGFloat)flowLayoutView:(TextFlowLayoutView *)flowLayoutView minimumLineSpacingFoxIndex:(NSInteger)index {
    return 18.f;
}

- (NSInteger)flowLayoutViewNumberOfRows:(TextFlowLayoutView *)flowLayoutView {
    return _dataArray.count;
}

- (NSDictionary *)flowLayoutView:(TextFlowLayoutView *)flowLayoutView buttonConfigForRowAtIndex:(NSInteger)index {
    NSDictionary *dic = @{TextFlowLayoutViewTitle : _dataArray[index],TextFlowLayoutViewFontSize : @"14", TextFlowLayoutViewItemColor : @"#f5f6f7", TextFlowLayoutViewTitleColor : @"#999999", TextFlowLayoutViewSelectItemColor : @"#2798fc",TextFlowLayoutViewSelectTitleColor : @"ffffff",TextFlowLayoutViewItemRadius : @"2"};
    return dic;
}

- (void)clickTagViewWithIndex:(NSInteger)index text:(NSString *)text {
   
}

@end
