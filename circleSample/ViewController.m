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
    //circle
    UIImageView *circle;
    CAShapeLayer *arcLayer;
    UILabel *theLoadingNum;
    float forward_step;//每次動畫前進的範圍大小
    float forward_time;//每次前進的時間
    float finishTime;//持續時間
    float currentTime;//目前時間
    NSTimer *circle_time;
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
    
    
    CGFloat circle_Origin_x = (CGRectGetWidth(self.view.frame) - 100)/2;
    CGRect circleFrame = CGRectMake(circle_Origin_x, self.view.center.y-50, 100, 100);
    [self initCircle:circleFrame andBaseOnView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btn_activity
{
    [self circle_start:Nil];
}

#pragma mark - circle countdown
- (void)initCircle:(CGRect)setFrame andBaseOnView:(UIView *)baseView
{
    circle = [[UIImageView alloc]initWithFrame:setFrame];
    circle.backgroundColor = [UIColor clearColor];
    circle.alpha = 1;
    [baseView addSubview:circle];
    
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
    theUnit.text = @"s";
    theUnit.textColor = [UIColor whiteColor];
    theUnit.textAlignment = NSTextAlignmentCenter;
    theUnit.font = [UIFont systemFontOfSize:12];
    [circle addSubview:theUnit];
    
    theLoadingNum = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    theLoadingNum.backgroundColor = [UIColor clearColor];
    theLoadingNum.textColor = [UIColor whiteColor];
    theLoadingNum.textAlignment = NSTextAlignmentRight;
    theLoadingNum.font = [UIFont systemFontOfSize:24];
    theLoadingNum.center = CGPointMake(45, 50);
    [circle addSubview:theLoadingNum];
    
    
    //參數設定
    [self circle_setting];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(error_finish)
     name:UIApplicationWillEnterForegroundNotification
     object:nil];
    
    
    
    
    
}

#pragma mark 每次前進的速度
- (void)stepCount
{
    currentTime = forward_step + currentTime;
    theLoadingNum.text = [NSString stringWithFormat:@"%.f",finishTime - currentTime];
    if (currentTime>=finishTime) {
        [self circle_stop:nil];
    }
}

#pragma mark 初始參數設定
- (void)circle_setting
{
    //持續時間
    finishTime = 15.0;
    theLoadingNum.text = [NSString stringWithFormat:@"%.f",finishTime];
    //每次前進速度
    forward_step = 1.0;
    //前進一次於幾秒內
    forward_time = 1.0;
    //目前時間
    currentTime = 0.0;
}

#pragma mark 啟動
- (void)circle_start:(id)sender
{
    circle_time = [NSTimer scheduledTimerWithTimeInterval:forward_time target:self selector:@selector(stepCount) userInfo:nil repeats:YES];
    arcLayer.strokeColor=[UIColor colorWithRed:0 green:1 blue:1 alpha:0.7].CGColor;
    [self drawLineAnimation:arcLayer];
}

- (void)circle_stop:(id)sender
{
    [self circle_setting];
    [circle_time invalidate];
}

- (void)drawLineAnimation:(CALayer*)layer
{
    CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    [bas setValue:@"time" forKey:@"animation_circle"];
    bas.duration=finishTime;
    bas.delegate=self;
    bas.fromValue=[NSNumber numberWithInteger:0];
    bas.toValue=[NSNumber numberWithInteger:1];
    [layer addAnimation:bas forKey:@"key"];
}

#pragma mark 結束
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    NSLog(@"time finish");
    [self circle_stop:nil];
}

#pragma mark 意外結束再開啟
- (void)error_finish
{
    [self circle_stop:nil];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"請重新執行動態密碼" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alertController addAction:defaultAction];
        
        [[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController presentViewController:alertController animated:YES completion:^{}];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"請重新執行動態密碼" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
}

@end
