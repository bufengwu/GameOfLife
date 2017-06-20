//
//  ViewController.m
//  GameOfLife
//
//  Created by XYDM001 on 2017/4/10.
//  Copyright © 2017年 xydSDK. All rights reserved.
//

#import "ViewController.h"
#import "FarmlandView.h"
#import "FarmlandViewModel.h"

@interface ViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) FarmlandViewModel *viewModel;

@property (nonatomic, strong) NSTimer *timer;

@property (weak, nonatomic) IBOutlet FarmlandView *farmland;
@property (weak, nonatomic) IBOutlet UIView *dashboard;

@property (weak, nonatomic) IBOutlet UITextField *rowsField;
@property (weak, nonatomic) IBOutlet UITextField *originSurvivalRateField;
@property (weak, nonatomic) IBOutlet UITextField *fpsNumField;

@property (weak, nonatomic) IBOutlet UILabel *generationLabel;
@property (weak, nonatomic) IBOutlet UILabel *survivalRateLabel;

@end

@implementation ViewController {
    unsigned int _fpsNum;
    
    CGRect _originViewFrame;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewModel = [[FarmlandViewModel alloc] init];

    
    self.rowsField.delegate = self;
    self.rowsField.keyboardType = UIKeyboardTypeNumberPad;
    self.originSurvivalRateField.delegate = self;
    self.originSurvivalRateField.keyboardType = UIKeyboardTypeDecimalPad;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self.farmland addGestureRecognizer:pan];//给图片添加手势
    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.farmland addGestureRecognizer:pinchGestureRecognizer];
    
    [self restart:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _originViewFrame = self.farmland.frame;
}

// 处理缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
}

#pragma mark - 手势执行的方法
-(void)handlePan:(UIPanGestureRecognizer *)rec {
    
    CGPoint point=[rec translationInView:self.view];
    
    CGFloat goalX = rec.view.center.x+point.x;
    CGFloat goalY = rec.view.center.y+point.y;
    
    if (goalX < _originViewFrame.origin.x) {
        goalX = _originViewFrame.origin.x;
    }

    if (goalX > _originViewFrame.origin.x+_originViewFrame.size.width) {
        goalX = _originViewFrame.origin.x+_originViewFrame.size.width;
    }
        
    if (goalY < _originViewFrame.origin.y) {
        goalY = _originViewFrame.origin.y;
    }
    
    if (goalY > _originViewFrame.origin.y+_originViewFrame.size.height) {
        goalY = _originViewFrame.origin.y+_originViewFrame.size.height;
    }
    
    rec.view.center = CGPointMake(goalX, goalY);

    //拖动完之后，每次都要用setTranslation:方法制0这样才不至于不受控制般滑动出视图
    [rec setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(void)keyboardWillShow:(NSNotification *)notification {
    //这样就拿到了键盘的位置大小信息frame，然后根据frame进行高度处理之类的信息
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIApplication sharedApplication].keyWindow.center = CGPointMake(self.view.center.x, self.view.center.y - frame.size.height);
}

- (void)keyboardWillHide:(NSNotification *)notification {
    //    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIApplication sharedApplication].keyWindow.center = CGPointMake(self.view.center.x, self.view.center.y);
}

#pragma mark -
- (IBAction)resetFrame:(id)sender {
    self.farmland.frame = _originViewFrame;
}

- (IBAction)restart:(id)sender {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    NSInteger row = [self.rowsField.text integerValue] ?: 15;
    float rate = [self.originSurvivalRateField.text floatValue]/1000 ?: 0.37;
    
    [self.viewModel reBuildMapWithArrayLenth:row activityRate:rate];
    
    self.farmland.mapArray = self.viewModel.mapArray;
    self.survivalRateLabel.text = [NSString stringWithFormat:@"%.3f", self.viewModel.activityRate];
    self.generationLabel.text = [NSString stringWithFormat:@"%lu", self.viewModel.generationCount];
}

- (IBAction)nextStep:(id)sender {
    [self.viewModel refreshMap];
    
    self.farmland.mapArray = self.viewModel.mapArray;
    self.survivalRateLabel.text = [NSString stringWithFormat:@"%.3f", self.viewModel.activityRate];
    self.generationLabel.text = [NSString stringWithFormat:@"%lu", self.viewModel.generationCount];
}

- (IBAction)forever:(id)sender {
    if (!self.timer) {
        _fpsNum = [self.fpsNumField.text intValue];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/(_fpsNum ?: 2) target:self selector:@selector(nextStep:) userInfo:nil repeats:YES];
    } else {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (IBAction)stop:(id)sender {
    // 停止定时器
    [self.timer invalidate];
    self.timer = nil;
}

@end
