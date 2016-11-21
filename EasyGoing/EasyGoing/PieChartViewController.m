//
//  PieChartViewController.m
//  EasyGoing
//
//  Created by King on 16/11/17.
//  Copyright © 2016年 kf. All rights reserved.
//

#import "PieChartViewController.h"
#import "ObjectC-Bridging-Header.h"

#define BgColor [UIColor colorWithRed:230/255.0f green:253/255.0f blue:253/255.0f alpha:1]
#define KScreenWidth [[UIScreen mainScreen] bounds].size.width
#define KScreenHeight [[UIScreen mainScreen] bounds].size.height


@interface PieChartViewController()<ChartViewDelegate>

@property (nonatomic, strong) PieChartView *pieChartView;
@property (nonatomic, strong) PieChartData *data;

@end

@implementation PieChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = BgColor;
}

#pragma mark - 加载视图
- (void)loadPieChartView{
    //创建饼状图
    self.pieChartView = [[PieChartView alloc] init];
    self.pieChartView.backgroundColor = BgColor;
    [self.view addSubview:self.pieChartView];
    
//    self.pieChartView.frame = self.showFrame;
    [self.pieChartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(self.showFrame.size.width, self.showFrame.size.height));
        make.top.mas_equalTo(self.view).offset((100/414.0) * KScreenWidth);
        make.left.mas_equalTo(self.view);
    }];
    
    self.pieChartView.delegate = self;
    
    //基本样式
    [self.pieChartView setExtraOffsetsWithLeft:30 top:0 right:30 bottom:0];//饼状图距离边缘的间隙
    self.pieChartView.usePercentValuesEnabled = YES;//是否根据所提供的数据, 将显示数据转换为百分比格式
    self.pieChartView.dragDecelerationEnabled = YES;//拖拽饼状图后是否有惯性效果
    self.pieChartView.drawSliceTextEnabled = YES;//是否显示区块文本
    //空心饼状图样式
    self.pieChartView.drawHoleEnabled = YES;//饼状图是否是空心
    self.pieChartView.holeRadiusPercent = 0.5;//空心半径占比
    self.pieChartView.holeColor = [UIColor clearColor];//空心颜色
    self.pieChartView.transparentCircleRadiusPercent = 0.3;//半透明空心半径占比
    self.pieChartView.transparentCircleColor = [UIColor colorWithRed:210/255.0 green:145/255.0 blue:165/255.0 alpha:0.3];//半透明空心的颜色
    //实心饼状图样式
    //    self.pieChartView.drawHoleEnabled = NO;
    //饼状图中间描述
    if (self.pieChartView.isDrawHoleEnabled == YES) {
        self.pieChartView.drawCenterTextEnabled = YES;//是否显示中间文字
        //普通文本
        //        self.pieChartView.centerText = @"饼状图";//中间文字
        //富文本
        NSMutableAttributedString *centerText = [[NSMutableAttributedString alloc] initWithString:self.centerDateString];
        [centerText setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                    NSForegroundColorAttributeName: [UIColor orangeColor]}
                            range:NSMakeRange(0, centerText.length)];
        self.pieChartView.centerAttributedText = centerText;
    }
    //饼状图描述
    self.pieChartView.descriptionText = @"消费项目占比图";
    self.pieChartView.descriptionFont = [UIFont systemFontOfSize:10];
    self.pieChartView.descriptionTextColor = [UIColor grayColor];
    //饼状图图例
    self.pieChartView.legend.maxSizePercent = 1;//图例在饼状图中的大小占比, 这会影响图例的宽高
    self.pieChartView.legend.formToTextSpace = 5;//文本间隔
    self.pieChartView.legend.font = [UIFont systemFontOfSize:10];//字体大小
    self.pieChartView.legend.textColor = [UIColor grayColor];//字体颜色
    self.pieChartView.legend.position = ChartLegendPositionBelowChartCenter;//图例在饼状图中的位置
    self.pieChartView.legend.form = ChartLegendFormCircle;//图示样式: 方形、线条、圆形
    self.pieChartView.legend.formSize = 12;//图示大小
    
    //为饼状图提供数据
    self.data = [self setData];
    self.pieChartView.data = self.data;
    
    if (self.animation) {
        //设置动画效果
        [self.pieChartView animateWithXAxisDuration:1.0f easingOption:ChartEasingOptionEaseOutExpo];
    }
    
}


- (void)updateData{
    //为饼状图提供数据
    self.data = [self setData];
    self.pieChartView.data = self.data;
    //饼状图中间描述
    if (self.pieChartView.isDrawHoleEnabled == YES) {
        self.pieChartView.drawCenterTextEnabled = YES;//是否显示中间文字
        //富文本
        NSMutableAttributedString *centerText = [[NSMutableAttributedString alloc] initWithString:self.centerDateString];
        [centerText setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                    NSForegroundColorAttributeName: [UIColor orangeColor]}
                            range:NSMakeRange(0, centerText.length)];
        self.pieChartView.centerAttributedText = centerText;
    }
    
    if (self.animation) {
        //设置动画效果
        [self.pieChartView animateWithXAxisDuration:1.0f easingOption:ChartEasingOptionEaseOutExpo];
    }
    
}

- (PieChartData *)setData{

    //每个区块的数据
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    //每个区块的名称或描述
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    //饼状图总共有几块组成
    NSArray *keys = self.categoryDictionary.allKeys;
    for (int i = 0; i<keys.count; i++) {
        BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithValue:[self.costDictionary[keys[i]] doubleValue] xIndex:i];
        
        [yVals addObject:entry];
        [xVals addObject:[[NSString alloc] initWithFormat:@"%@：%@",keys[i],self.costDictionary[keys[i]]]];
    }
    
    //dataSet
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithYVals:yVals label:@""];
    dataSet.drawValuesEnabled = YES;//是否绘制显示数据
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    [colors addObjectsFromArray:ChartColorTemplates.vordiplom];
    [colors addObjectsFromArray:ChartColorTemplates.joyful];
    [colors addObjectsFromArray:ChartColorTemplates.colorful];
    [colors addObjectsFromArray:ChartColorTemplates.liberty];
    [colors addObjectsFromArray:ChartColorTemplates.pastel];
    [colors addObject:[UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f]];
    dataSet.colors = colors;//区块颜色
    dataSet.sliceSpace = 3;//相邻区块之间的间距
    dataSet.selectionShift = 8;//选中区块时, 放大的半径
    
    dataSet.xValuePosition = PieChartValuePositionOutsideSlice;//名称位置
    dataSet.yValuePosition = PieChartValuePositionInsideSlice;//数据位置
    //数据与区块之间的用于指示的折线样式
    dataSet.valueLinePart1OffsetPercentage = 0.85;//折线中第一段起始位置相对于区块的偏移量, 数值越大, 折线距离区块越远
    dataSet.valueLinePart1Length = 0.5;//折线中第一段长度占比
    dataSet.valueLinePart2Length = 0.4;//折线中第二段长度最大占比
    dataSet.valueLineWidth = 1;//折线的粗细
    dataSet.valueLineColor = [UIColor brownColor];//折线颜色
    
    //data
    PieChartData *data = [[PieChartData alloc] initWithXVals:xVals dataSet:dataSet];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterPercentStyle;
    formatter.maximumFractionDigits = 0;//小数位数
    formatter.multiplier = @1.f;
    [data setValueFormatter:formatter];//设置显示数据格式
    [data setValueTextColor:[UIColor brownColor]];
    [data setValueFont:[UIFont systemFontOfSize:10]];
    
    return data;
}

#pragma mark - 饼状图代理方法
- (void)chartValueSelected:(ChartViewBase *)chartView entry:(ChartDataEntry *)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight *)highlight{
    NSLog(@"当前选中下标为 = %li",entry.xIndex);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
