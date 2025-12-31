#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// تعريف محرك الحماية
@interface ShadowMasterCore : NSObject
+ (instancetype)master;
- (void)initializeWithOverride:(NSDictionary *)config;
- (void)startExploitation;
@end

// --- زر عائم بسيط وآمن ---
@interface SovereignButton : UIButton
@end

@implementation SovereignButton
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.6 blue:1.0 alpha:0.8];
        self.layer.cornerRadius = 25;
        [self setTitle:@"S" forState:UIControlStateNormal];
        self.tag = 777; // تعريف مميز للزر
    }
    return self;
}
@end

// --- الحقن الآمن عبر UIViewController ---
%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    
    // تأكد أننا لا نضيف الزر أكثر من مرة
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window && ![window viewWithTag:777]) {
        SovereignButton *btn = [[SovereignButton alloc] initWithFrame:CGRectMake(50, 150, 50, 50)];
        [window addSubview:btn];
        
        // إضافة خاصية السحب
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleBtnDrag:)];
        [btn addGestureRecognizer:pan];
    }
}

%new
- (void)handleBtnDrag:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}
%end

// تفعيل المحرك بشكل آمن
%hook UIApplication
- (void)didFinishLaunchingWithOptions:(id)options {
    %orig;
    // تشغيل المحرك في الخلفية لتجنب تجميد اللعبة
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[%c(ShadowMasterCore) master] initializeWithOverride:@{@"safe": @YES}];
    });
}
%end
