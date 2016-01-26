//
//  ViewController.m
//  circleSample
//
//  Created by jhaoheng on 2016/1/26.
//  Copyright © 2016年 max. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    UIImageView *circle;
    CAShapeLayer *arcLayer;
    UILabel *theLoadingNum;
    float forward_step;//每次動畫前進的範圍大小
    float persistTime;
    NSTimer *stepTime;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 50, 50);
    [btn setTitle:@"btn" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btn_activity) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btn_activity
{
    [self circle_activity:Nil];
}

#pragma makr - 旋轉圖示
#pragma mark - 百分比計數器
- (void)loadingCircle
{
    circle = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    circle.backgroundColor = [UIColor clearColor];
    circle.alpha = 1;
    circle.center = CGPointMake(160, 230);
    [self.view addSubview:circle];
    
    //
    UIGraphicsBeginImageContext(circle.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetRGBStrokeColor(context, 0.57, 0.57, 0.57, .1);//線條灰色
    CGContextSetRGBFillColor(context, 0.25, 0.25, 0.25, .3);//填充色
    CGContextSetLineWidth(context, 0.2);//線條粗細
    
    double radius=46;        //半徑
    int startX=50;           //圓心x坐標
    int startY=50;          //y坐標
    int clockwise=0;         //0＝順時針,1＝逆時針
    
    CGContextAddArc(context, startX, startY, radius, 0, 6.3, clockwise);
    CGContextFillPath(context);
    
    circle.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //
    
    
    UIBezierPath *path=[UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(circle.bounds.size.width/2, circle.bounds.size.height/2) radius:circle.frame.size.height/2 startAngle:0 endAngle:2*M_PI clockwise:YES];
    arcLayer=[CAShapeLayer layer];
    arcLayer.path=path.CGPath;
    arcLayer.fillColor=[UIColor clearColor].CGColor;
    arcLayer.lineWidth=3;
    arcLayer.frame=self.view.bounds;
    [circle.layer addSublayer:arcLayer];
    
    //
    UILabel *theUnit = [[UILabel alloc]initWithFrame:CGRectMake(66, 36, 20, 12)];
    theUnit.backgroundColor = [UIColor clearColor];
    theUnit.text = @"%";
    theUnit.textColor = [UIColor whiteColor];
    theUnit.textAlignment = NSTextAlignmentCenter;
    theUnit.font = [UIFont systemFontOfSize:12];
    [circle addSubview:theUnit];
    
    theLoadingNum = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    theLoadingNum.backgroundColor = [UIColor clearColor];
    theLoadingNum.text = @"0";
    theLoadingNum.textColor = [UIColor whiteColor];
    theLoadingNum.textAlignment = NSTextAlignmentRight;
    theLoadingNum.font = [UIFont systemFontOfSize:24];
    theLoadingNum.center = CGPointMake(45, 50);
    [circle addSubview:theLoadingNum];
}

- (void)stepCount
{
    forward_step = forward_step + 10/persistTime;
    //    NSLog(@"%f, %f",step,10/persistTime);
    //    NSInteger tempStep = step;
    theLoadingNum.text = [NSString stringWithFormat:@"%.0f",forward_step];
    if (forward_step>=100) {
        [stepTime invalidate];
    }
}

- (void)circle_activity:(id)sender
{
    
    stepTime = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(stepCount) userInfo:nil repeats:YES];
    forward_step = 0.0;
    
    //穩定訊號(pendingToGetSignalTime)＋取值(serialSignal_TimeInterval)＋鎖定環境時間(6)
    persistTime = 21.0;
    
    arcLayer.strokeColor=[UIColor colorWithRed:0 green:1 blue:1 alpha:0.7].CGColor;
    [self drawLineAnimation:arcLayer];
}

-(void)drawLineAnimation:(CALayer*)layer
{
    CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    [bas setValue:@"camera" forKey:@"animation_circle"];
    bas.duration=persistTime;
    bas.delegate=self;
    bas.fromValue=[NSNumber numberWithInteger:0];
    bas.toValue=[NSNumber numberWithInteger:1];
    [layer addAnimation:bas forKey:@"key"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    NSLog(@"finish");
}

@end
