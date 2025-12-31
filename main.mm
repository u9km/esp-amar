#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

[span_6](start_span)// واجهة التحكم الخاصة بنظام ESP التعليمي[span_6](end_span)
@interface ESPViewController : UIViewController
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, assign) BOOL espEnabled;
@end

@implementation ESPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    self.view.layer.cornerRadius = 15;
    self.view.clipsToBounds = YES;
    
    [span_7](start_span)// إنشاء زر التفعيل[span_7](end_span)
    self.toggleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.toggleButton setTitle:@"تفعيل ESP (تعليمي)" forState:UIControlStateNormal];
    [self.toggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.toggleButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:1.0];
    self.toggleButton.layer.cornerRadius = 10;
    self.toggleButton.frame = CGRectMake(50, 80, 200, 50);
    [self.toggleButton addTarget:self action:@selector(toggleESP:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.toggleButton];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 300, 30)];
    label.text = @"🛡️ لوحة تحكم Sovereign";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:18];
    [self.view addSubview:label];
}

- (void)toggleESP:(UIButton *)sender {
    self.espEnabled = !self.espEnabled;
    NSString *status = self.espEnabled ? @"🟢 ESP مفعل" : @"🔴 ESP معطل";
    [sender setTitle:status forState:UIControlStateNormal];
    NSLog(@"[Sovereign] حالة النظام تغيرت: %@", status);
}

@end
