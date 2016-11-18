//
//  SZCalendarPicker.m
//  SZCalendarPicker
//
//  Created by Stephen Zhuang on 14/12/1.
//  Copyright (c) 2014年 Stephen Zhuang. All rights reserved.
//

#import "SZCalendarPicker.h"
#import "SZCalendarCell.h"
#import "UIColor+ZXLazy.h"
#import "POP.h"

NSString *const SZCalendarCellIdentifier = @"cell";

@interface SZCalendarPicker ()
@property (nonatomic , weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic , weak) IBOutlet UILabel *monthLabel;
@property (nonatomic , weak) IBOutlet UIButton *previousButton;
@property (nonatomic , weak) IBOutlet UIButton *nextButton;
@property (nonatomic , strong) NSArray *weekDayArray;
@property (nonatomic , strong) UIView *mask;
//当前圆点的位置
@property (nonatomic , assign) int currentIndex;
//当前圆点的大小
@property (nonatomic) CGFloat radiu;
//当前选中日期
@property (nonatomic) NSString *selectedDate;
//翻页完成之后，是否有需要添加圆点的地方
@property (nonatomic) int needPointIndex;
@end

@implementation SZCalendarPicker


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self addTap];
    [self addSwipe];
    [self show];
}

- (void)awakeFromNib
{
    [_collectionView registerClass:[SZCalendarCell class] forCellWithReuseIdentifier:SZCalendarCellIdentifier];
     _weekDayArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
}

- (void)customInterface
{
    CGFloat itemWidth = _collectionView.frame.size.width / 7;
    CGFloat itemHeight = _collectionView.frame.size.height / 7;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    [_collectionView setCollectionViewLayout:layout animated:YES completion:^(BOOL finished) {
        //加载完动画之后，添加当前日期的小圆点
        [self addCirclePoint:self.currentIndex];
    }];
    
}

- (void)setDate:(NSDate *)date
{
    //默认设置-1表示没有需要圆点的地方
    self.needPointIndex = -1;
    _date = date;
    [_monthLabel setText:[NSString stringWithFormat:@"%.2ld-%li",(long)[self month:date],(long)[self year:date]]];
    [_collectionView reloadData];
}

#pragma mark - date

//替换NSDate类型的日子
- (NSString *)getFormatterDateString:(NSDate *)date replaceStr:(NSString *)str
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSMutableString *mString = [[NSMutableString alloc] initWithString:[fmt stringFromDate:date]];
    NSString *day = [NSString stringWithFormat:@"%02d",[str intValue]];
    [mString replaceCharactersInRange:NSMakeRange(8, 2) withString:day];
    
    return [NSString stringWithString:mString];
}

- (NSInteger)day:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components day];
}


- (NSInteger)month:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components month];
}

- (NSInteger)year:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components year];
}


- (NSInteger)firstWeekdayInThisMonth:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar setFirstWeekday:1];//1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [calendar dateFromComponents:comp];
    
    NSUInteger firstWeekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDayOfMonthDate];
    return firstWeekday - 1;
}

- (NSInteger)totaldaysInThisMonth:(NSDate *)date{
    NSRange totaldaysInMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return totaldaysInMonth.length;
}

- (NSInteger)totaldaysInMonth:(NSDate *)date{
    NSRange daysInLastMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return daysInLastMonth.length;
}

- (NSDate *)lastMonth:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

- (NSDate*)nextMonth:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = +1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

#pragma -mark collectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return _weekDayArray.count;
    } else {
        return 42;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SZCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SZCalendarCellIdentifier forIndexPath:indexPath];
    if (indexPath.section == 0) {
        [cell.dateLabel setText:_weekDayArray[indexPath.row]];
        [cell.dateLabel setTextColor:[UIColor colorWithHexString:@"#15cc9c"]];
    } else {
        NSInteger daysInThisMonth = [self totaldaysInMonth:_date];
        NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
        
        NSInteger day = 0;
        NSInteger i = indexPath.row;
        
        if (i < firstWeekday) {
            [cell.dateLabel setText:@""];
            
        }else if (i > firstWeekday + daysInThisMonth - 1){
            [cell.dateLabel setText:@""];
        }else{
            day = i - firstWeekday + 1;
            [cell.dateLabel setText:[NSString stringWithFormat:@"%li",(long)day]];
            [cell.dateLabel setTextColor:[UIColor colorWithHexString:@"#6f6f6f"]];
            
            NSString *compareString = [self getFormatterDateString:self.date replaceStr:cell.dateLabel.text];
            if (self.selectedDate!=nil && [self.selectedDate isEqualToString:compareString]) {
                self.needPointIndex = (int)indexPath.row;
            }
            
            //this month
            if ([_today isEqualToDate:_date]) {
                if (day == [self day:_date]) {
                    [cell.dateLabel setTextColor:[UIColor colorWithHexString:@"#4898eb"]];
                    //找到当前位置
                    self.currentIndex = (int)indexPath.item;
                } else if (day > [self day:_date]) {
                    [cell.dateLabel setTextColor:[UIColor colorWithHexString:@"#cbcbcb"]];
                }
            } else if ([_today compare:_date] == NSOrderedAscending) {
                [cell.dateLabel setTextColor:[UIColor colorWithHexString:@"#cbcbcb"]];
            }
        }
    }
    return cell;
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        NSInteger daysInThisMonth = [self totaldaysInMonth:_date];
        NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
        
        NSInteger day = 0;
        NSInteger i = indexPath.row;
        
        if (i >= firstWeekday && i <= firstWeekday + daysInThisMonth - 1) {
            day = i - firstWeekday + 1;
            
            //this month
            if ([_today isEqualToDate:_date]) {
                if (day <= [self day:_date]) {
                    return YES;
                }
            } else if ([_today compare:_date] == NSOrderedDescending) {
                return YES;
            }
        }
    }
    return NO;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self.date];
    NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
    
    NSInteger day = 0;
    NSInteger i = indexPath.row;
    day = i - firstWeekday + 1;
    if (self.calendarBlock) {
        self.calendarBlock(day, [comp month], [comp year]);
    }
    
    if (self.currentIndex != (int)indexPath.row) {
        //将之前的小圆点去掉
        [self removeCirclePoint:self.currentIndex animation:YES];
        //添加小圆点
        [self addCirclePoint:(int)indexPath.row];
    }
    //取消点击之后的隐藏
//    [self hide];
}

//为cell添加一个小圆点
- (void)addCirclePoint:(int)index{
    //设置当前点击item
    self.currentIndex = index;
    
    SZCalendarCell *cell = (SZCalendarCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
    
    CGFloat unit = (cell.bounds.size.width>cell.bounds.size.height) ? cell.bounds.size.height : cell.bounds.size.width;
    //给当前圆点的半径赋值
    self.radiu = unit;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(cell.dateLabel.frame.origin.x,cell.dateLabel.frame.origin.y,0,0)];
    imageView.center = cell.dateLabel.center;
    imageView.backgroundColor = [UIColor cyanColor];
    imageView.layer.cornerRadius = unit / 2.0;
    [cell.contentView insertSubview:imageView atIndex:0];
    
    //设置当前选中日期
    self.selectedDate = [self getFormatterDateString:self.date replaceStr:cell.dateLabel.text];
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect rect = imageView.frame;
        imageView.frame = CGRectMake(rect.origin.x, rect.origin.y, unit, unit);
        imageView.center = cell.dateLabel.center;
    } completion:^(BOOL finished) {
        POPSpringAnimation *sprintAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        sprintAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0.9, 0.9)];
        sprintAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
        sprintAnimation.springBounciness = 20.f;
        [imageView pop_addAnimation:sprintAnimation forKey:@"springAnimation"];
    }];
}

//移除cell上的小圆点
- (void)removeCirclePoint:(int)index animation:(BOOL)animation{
    SZCalendarCell *preCell = (SZCalendarCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];
    
    for (UIView *subview in preCell.contentView.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            if (animation) {
                [UIView animateWithDuration:0.5 animations:^{
                    subview.bounds = CGRectMake(0, 0, 0, 0);
                } completion:^(BOOL finished) {
                    [subview removeFromSuperview];
                }];
            }else{
                [subview removeFromSuperview];
            }
            
        }
    }
}

- (IBAction)previouseAction:(UIButton *)sender
{
    //翻页之前，移除圆点
    [self removeCirclePoint:self.currentIndex animation:NO];
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCurlDown animations:^(void) {
        self.date = [self lastMonth:self.date];
    } completion:^(BOOL finished) {
        if (self.needPointIndex > 0) {
            [self addCirclePoint:self.needPointIndex];
        }
    }];
}

- (IBAction)nexAction:(UIButton *)sender
{
    //翻页之前，移除圆点
    [self removeCirclePoint:self.currentIndex animation:NO];
    [UIView transitionWithView:self duration:0.5 options:(UIViewAnimationOptionTransitionCurlUp) animations:^{
        self.date = [self nextMonth:self.date];
    } completion:^(BOOL finished) {
        if (self.needPointIndex > 0) {
            [self addCirclePoint:self.needPointIndex];
        }
    }];
}

+ (instancetype)showOnView:(UIView *)view
{
    SZCalendarPicker *calendarPicker = [[[NSBundle mainBundle] loadNibNamed:@"SZCalendarPicker" owner:self options:nil] firstObject];
//    calendarPicker.mask = [[UIView alloc] initWithFrame:view.bounds];
//    calendarPicker.mask.backgroundColor = [UIColor blackColor];
//    calendarPicker.mask.alpha = 0.3;
//    [view addSubview:calendarPicker.mask];
    [view addSubview:calendarPicker];
    return calendarPicker;
}

- (void)show
{
    self.transform = CGAffineTransformTranslate(self.transform, 0, - self.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL isFinished) {
        [self customInterface];
    }];
}

- (void)hide
{
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.transform = CGAffineTransformTranslate(self.transform, 0, - self.frame.size.height);
        self.mask.alpha = 0;
    } completion:^(BOOL isFinished) {
        [self.mask removeFromSuperview];
        [self removeFromSuperview];
    }];
}


- (void)addSwipe
{
    UISwipeGestureRecognizer *swipLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nexAction:)];
    swipLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipLeft];
    
    UISwipeGestureRecognizer *swipRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previouseAction:)];
    swipRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipRight];
}

- (void)addTap
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self.mask addGestureRecognizer:tap];
}
@end
