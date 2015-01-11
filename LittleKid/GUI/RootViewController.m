//
//  RootViewController.m
//  象棋Demo
//
//  Created by QzydeMac on 14/11/30.
//  Copyright (c) 2014年 Qzy. All rights reserved.
//

#import "RootViewController.h"
#import "CheseInterface.h"
#import "CheseTools.h"
//extern int ischessReverse;
@interface RootViewController ()
@property (weak, nonatomic) IBOutlet UIView *moreView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *bacakGroundImage = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    
    bacakGroundImage.image = [UIImage imageNamed:@"象棋主界面.png"];
    bacakGroundImage.userInteractionEnabled = YES;
    [self.view addSubview:bacakGroundImage];
    
    self.view.backgroundColor = [UIColor blackColor];
//    ischessReverse = self.blackOrRed;
//    _cheseInterface = [[CheseInterface alloc]initWithFrame:CGRectMake(0+self.blackOrRed, chessboardStartPointy, chessboardWidth, chessboardHight)];
    _cheseInterface = [[CheseInterface alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    _cheseInterface.center = CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0);
    _cheseInterface.delegate = self;
    [self.view addSubview:_cheseInterface];
    _cheseInterface.ischessReverse = self.blackOrRed;
    UIButton * moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(0, 510, 60, 60);
    UIImage * tmpimage = [UIImage imageNamed:@"菜单.png"];
    [moreButton setBackgroundImage:tmpimage forState:UIControlStateNormal];

    [moreButton addTarget:self action:@selector(more) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreButton];
    
 /*  UIButton * restartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    restartButton.frame = CGRectMake(40, 20, 80, 40);
    
    restartButton.backgroundColor = [UIColor brownColor];
    
    restartButton.layer.cornerRadius = 10;
    
    restartButton.layer.borderColor = [UIColor grayColor].CGColor;
    
    restartButton.layer.borderWidth = 1;
    
    [restartButton setTitle:@"Restart" forState:UIControlStateNormal];
    
    restartButton.titleLabel.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;

    [restartButton addTarget:self action:@selector(Restart) forControlEvents:UIControlEventTouchUpInside];
    
    [bacakGroundImage addSubview:restartButton];
    
   _label = [[UILabel alloc]initWithFrame:CGRectMake(240, chessStartPointY, 80, 40)];
    
    _label.backgroundColor = [UIColor brownColor];
    
    _label.layer.cornerRadius = 10;
    
    _label.layer.borderColor = [UIColor grayColor].CGColor;
    
    _label.layer.borderWidth = 1;
    _label.textAlignment = NSTextAlignmentCenter;
*///    [self.view addSubview:_label];
    UIImageView *myphoto = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    myphoto.image = [UIImage imageNamed:@"象棋界面（人头男）.png"];
    [myphoto setFrame:CGRectMake(130, 490, 70, 70)];
    [bacakGroundImage addSubview:myphoto];
    UIImageView *opponentphoto = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    opponentphoto.image = [UIImage imageNamed:@"象棋界面（人头）"];
    [opponentphoto setFrame:CGRectMake(130, 20, 70, 70)];
    [bacakGroundImage addSubview:opponentphoto];
    UILabel *myname = [[UILabel alloc]initWithFrame:CGRectMake(210, 500, 80, 20)];
    UILabel *mygrade = [[UILabel alloc]initWithFrame:CGRectMake(210, 520, 80, 20)];
    UILabel *opponentname = [[UILabel alloc]initWithFrame:CGRectMake(210, 30, 80, 20)];
    UILabel *opponentgrade = [[UILabel alloc]initWithFrame:CGRectMake(210,50, 80, 20)];
    myname.text =@"习近平";
    mygrade.text =@"国王";
    opponentname.text = @"李克强";
    opponentgrade.text = @"相";
    myname.font = [UIFont boldSystemFontOfSize:20];
    opponentname.font =[UIFont boldSystemFontOfSize:20];
    myname.textColor = [UIColor whiteColor];
    opponentname.textColor = [UIColor whiteColor];
    mygrade.font = opponentgrade.font =[UIFont boldSystemFontOfSize:20];
    mygrade.textColor = opponentgrade.textColor =[UIColor orangeColor];
    
    
    [bacakGroundImage addSubview:myname];
    [bacakGroundImage addSubview:mygrade];
    [bacakGroundImage addSubview:opponentgrade];
    [bacakGroundImage addSubview:opponentname];
    [bacakGroundImage addSubview:myphoto];
 //   RNLongPressGestureRecognizer *longPress = [[RNLongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//    [self.view addGestureRecognizer:longPress];
    [self showWhoShouldPlayChese:0];
}

- (void)Restart
{
    [_cheseInterface removeFromSuperview];
    
    _cheseInterface = [[CheseInterface alloc]initWithFrame:CGRectMake(0, chessStartPointY, 300, 300)];
    _cheseInterface.center = CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0);
    _cheseInterface.delegate = self;
    [self.view addSubview:_cheseInterface];
    [self showWhoShouldPlayChese:0];
}
#pragma mark - RNGridMenuDelegate

- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    NSLog(@"Dismissed with item %d: %@", itemIndex, item.title);
}

#pragma mark - Private

- (void)showImagesOnly {
    NSInteger numberOfOptions = 5;
    NSArray *images = @[
                        [UIImage imageNamed:@"arrow"],
                        [UIImage imageNamed:@"attachment"],
                        [UIImage imageNamed:@"block"],
                        [UIImage imageNamed:@"bluetooth"],
                        [UIImage imageNamed:@"cube"],
                        [UIImage imageNamed:@"download"],
                        [UIImage imageNamed:@"enter"],
                        [UIImage imageNamed:@"file"],
                        [UIImage imageNamed:@"github"]
                        ];
    RNGridMenu *av = [[RNGridMenu alloc] initWithImages:[images subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}

- (void)showList {
    NSInteger numberOfOptions = 5;
    NSArray *options = @[
                         @"Next",
                         @"Attach",
                         @"Cancel",
                         @"Bluetooth",
                         @"Deliver",
                         @"Download",
                         @"Enter",
                         @"Source Code",
                         @"Github"
                         ];
    RNGridMenu *av = [[RNGridMenu alloc] initWithTitles:[options subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    //    av.itemTextAlignment = NSTextAlignmentLeft;
    av.itemFont = [UIFont boldSystemFontOfSize:18];
    av.itemSize = CGSizeMake(150, 55);
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}

- (void)showGrid {
    NSInteger numberOfOptions = 3;
    NSArray *items = @[
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"菜单二级(悔棋）"] title:@"悔棋"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"菜单二级（求和）"] title:@"求和"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"菜单二级（认输）"] title:@"认输"],
                     //  [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"bluetooth"] title:@"聊天"],
                     //  [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"cube"] title:@"设置"],
                     //  [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"download"] title:@"视频"],
                    //   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"enter"] title:@"Enter"],
                    //   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"file"] title:@"Source Code"],
                   //    [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"github"] title:@"Github"]
                       ];
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    //    av.bounces = NO;
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, 2*self.view.bounds.size.height/3.f)];
}

- (void)showGridWithHeaderFromPoint:(CGPoint)point {
    NSInteger numberOfOptions = 4;
    NSArray *items = @[
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"attachment"] title:@"Attach"],
                       
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"bluetooth"] title:@"Bluetooth"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"cube"] title:@"Deliver"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"download"] title:@"Download"],
                      
                       ];
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    av.bounces = NO;
    av.animationDuration = 0.2;
    av.blurExclusionPath = [UIBezierPath bezierPathWithOvalInRect:self.imageView.frame];
    av.backgroundPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.f, 0.f, av.itemSize.width*3, av.itemSize.height*3)];
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    header.text = @"Example Header";
    header.font = [UIFont boldSystemFontOfSize:18];
    header.backgroundColor = [UIColor clearColor];
    header.textColor = [UIColor whiteColor];
    header.textAlignment = NSTextAlignmentCenter;
    // av.headerView = header;
    
    [av showInViewController:self center:point];
}

- (void)showGridWithPath {
    NSInteger numberOfOptions = 9;
    NSArray *items = @[
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"arrow"] title:@"Next"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"attachment"] title:@"Attach"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"block"] title:@"Cancel"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"bluetooth"] title:@"Bluetooth"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"cube"] title:@"Deliver"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"download"] title:@"Download"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"enter"] title:@"Enter"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"file"] title:@"Source Code"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"github"] title:@"Github"]
                       ];
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    //    av.bounces = NO;
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}
-(void)more
{
  //  UIView *moreView = [UIView init]
    [self showGrid];
    // [self showGridWithHeaderFromPoint:CGPointMake(40, 400)];
}
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self showGridWithHeaderFromPoint:[longPress locationInView:self.view]];
    }
}
- (void)showWhoShouldPlayChese:(NSInteger)num
{
 /*   if (num==0)
    {
        _label.text = @"准备";
    }
    else if (num==1)//黑色
    {
        _label.text = @"黑色";
    }
    else
    {
        _label.text = @"红色";
    }
  */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 