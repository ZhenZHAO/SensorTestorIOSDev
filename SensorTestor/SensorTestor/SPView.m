//
//  SPView.m
//  StockPlotting
//
//  Created by EZ on 13-11-5.
//  Copyright (c) 2013年 cactus. All rights reserved.
//

#define NLSystemVersionGreaterOrEqualThan(version)  ([[[UIDevice currentDevice] systemVersion] floatValue] >= version)

#define IOS7_OR_LATER   NLSystemVersionGreaterOrEqualThan(7.0)
#define GraphColor      [[UIColor blueColor] colorWithAlphaComponent:0.5]
#define FontColor       [[UIColor redColor] colorWithAlphaComponent:0.5]

//#define str(index)    [NSString stringWithFormat : @"%.f", [[self.values objectAtIndex:(index)] floatValue] * kYScale]

#define str(index)    [NSString stringWithFormat : @"%.1f", [[self.values objectAtIndex:(index)] floatValue]]
#define point(x, y)   CGPointMake((x) * kXScale, yOffset + (y) * kYScale)

#import "SPView.h"
@interface SPView ()
@property (nonatomic, strong)   dispatch_source_t timer;

@end

@implementation SPView


extern bool     isChangeShow; // change only if reader changes --> TBC
bool            isDataNew = true;
const CGFloat   kXScale = 15.0;
const CGFloat   kYScale = 10.0;
extern double resistorNewReader;

static inline CGAffineTransform
CGAffineTransformMakeScaleTranslate(CGFloat sx, CGFloat sy,
    CGFloat dx, CGFloat dy)
{
    return CGAffineTransformMake(sx, 0.f, 0.f, sy, dx, dy);
      //return CGAffineTransformMake(sx, 0.f, 10.0f, sy, dx, dy);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        // Initialization code
    }

    return self;
}

- (void)awakeFromNib
{
    [self setContentMode:UIViewContentModeRight];
    _values = [NSMutableArray array];

    __weak id   weakSelf = self;
    double      delayInSeconds = 0.25;
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), (unsigned)(delayInSeconds * NSEC_PER_SEC), 0);
    
    dispatch_source_set_event_handler(_timer, ^{
            [weakSelf updateValues];
        });
    dispatch_resume(_timer);
}

- (void)updateValues
{
//    [delegate passValue:self.newValue]; // 具体的实现在第一个VC里。
//    NSLog(@"self.newValue is%f", _newValue[0]);
    //double nextValue = sin(CFAbsoluteTimeGetCurrent()) + ((double)rand() / (double)RAND_MAX); // 从蓝牙模块获取
    //double nextValue = ((double)rand() / (double)RAND_MAX) * 20.0f;
    double nextValue =  resistorNewReader;
    NSUInteger   previousIndex = [self.values count];
    double previousValue = 0;
    if (previousIndex > 0) {
        previousValue =[[self.values objectAtIndex: previousIndex-1] floatValue];
    }
    
    if (fabs(nextValue - previousValue)<= 0.02) { // 检查是否是最新的数据
        isDataNew = false;
    }else{
        isDataNew = true;
    }
    
    if ((isChangeShow==true)&&(isDataNew == false)) {     // 如果只有数据变化才画,老数据不进队列
        return;
    }
    
    [self.values addObject:
    [NSNumber numberWithDouble:nextValue]];
    CGSize size = self.bounds.size;         // 获取当前view窗口的大小
    /*
     *   UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
     *   if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
     *
     *   }
     */
    // 计算出窗口最多能画多少个值，并作超出处理
    CGFloat     maxDimension = size.width; // MAX(size.height, size.width);
    NSUInteger  maxValues =
        (NSUInteger)floorl(maxDimension / kXScale);
    //kXscale代表x轴一个单位的长度

    if ([self.values count] > maxValues) {
        [self.values removeObjectsInRange:
        NSMakeRange(0, [self.values count] - maxValues)];
    }

    [self setNeedsDisplay];
}

- (void)dealloc
{
    dispatch_source_cancel(_timer);
}

- (void)drawRect:(CGRect)rect // 画这个图，又上角是零零位置，注意怎么调整
{
    //isChangeShow = true;
    if ([self.values count] == 0) {
        return;
    }
    if ( (isChangeShow==true) && (isDataNew==false)) {
        return;
    }

    // 先生成并设置划线的对象
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx,
        [GraphColor CGColor]);

    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineWidth(ctx, 3);

    CGMutablePathRef path = CGPathCreateMutable();

    // 画二分之一的基准 (x轴)
    //CGFloat             yOffset = self.bounds.size.height / 2;
    CGFloat             yOffset = self.bounds.size.height - 10; //调整x轴的位置
    CGAffineTransform   transform =
        CGAffineTransformMakeScaleTranslate(kXScale, kYScale,
            0, yOffset);
    
    CGPathMoveToPoint(path, &transform, 0, 0);
    CGPathAddLineToPoint(path, &transform, self.bounds.size.width, 0); // self.bounds.size.width其实大了kXScale倍

    // 画x轴  (基准)
    CGFloat             yBottom = self.bounds.size.height / 2 + 15;
    CGAffineTransform   transformBottom = CGAffineTransformMakeScaleTranslate(kXScale, kYScale,0, yBottom);
    CGPathMoveToPoint(path, &transformBottom, 0, 0);
    CGPathAddLineToPoint(path, &transformBottom, self.bounds.size.width, 0); //
    
    // 画数据
    CGFloat y = [[self.values objectAtIndex:0] floatValue];
    CGFloat yTemp = 0-y;
    CGPathMoveToPoint(path, &transform, 0, yTemp);
    [self drawAtPoint:point(0, yTemp) withStr:str(0)];

    for (NSUInteger x = 1; x < [self.values count]; ++x) {
        y = [[self.values objectAtIndex:x] floatValue];
         yTemp = 0-y;
        CGPathAddLineToPoint(path, &transform, x, yTemp);
        [self drawAtPoint:point(x, yTemp) withStr:str(x)];
    }

    CGContextAddPath(ctx, path);
    CGPathRelease(path);
    CGContextStrokePath(ctx);
}

- (void)drawAtPoint:(CGPoint)point withStr:(NSString *)str
{
    
    if (IOS7_OR_LATER) {
       #if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
        [str drawAtPoint:point withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:5], NSStrokeColorAttributeName:GraphColor}];
       #endif
    } else {
        [str drawAtPoint:point withFont:[UIFont systemFontOfSize:5]];
    }
     
}

@end