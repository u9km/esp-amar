#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// --- تعريف واجهات النظام المعكوس (Shadow Master) ---
@interface ShadowMasterCore : NSObject
+ (instancetype)master;
- (void)initializeWithOverride:(NSDictionary *)config;
- (void)startExploitation;
- (void)cloakCompletely;
@end

// --- واجهة التحكم ESP ---
@interface ESPSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *settings;
@end

@implementation ESPSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"🛡️ إعدادات Sovereign المتقدمة";
    self.view.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:0.95];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor darkGrayColor];
    [self.view addSubview:self.tableView];

    // الإعدادات الافتراضية بناءً على طلبك
    self.settings = [@{
        @"esp_enabled": @NO,
        @"show_boxes": @YES,
        @"show_health": @YES,
        @"aim_assist": @NO,
        @"stealth_active": @YES,
        @"max_distance": @500.0
    [span_3](start_span)} mutableCopy];[span_3](end_span)
}

#pragma mark - Table View DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [span_4](start_span)return 6;[span_4](end_span)
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.8];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    UISwitch *switcher = [[UISwitch alloc] init];
    switcher.onTintColor = [UIColor systemBlueColor];

    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"تفعيل نظام الرؤية (ESP)";
            [switcher setOn:[self.settings[@"esp_enabled"] boolValue]];
            [switcher addTarget:self action:@selector(toggleESP:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switcher;
            [span_5](start_span)break;[span_5](end_span)
        case 1:
            cell.textLabel.text = @"إظهار المربعات";
            [switcher setOn:[self.settings[@"show_boxes"] boolValue]];
            cell.accessoryView = switcher;
            [span_6](start_span)break;[span_6](end_span)
        case 2:
            cell.textLabel.text = @"مساعدة التصويب (Aim)";
            [switcher setOn:[self.settings[@"aim_assist"] boolValue]];
            cell.accessoryView = switcher;
            [span_7](start_span)break;[span_7](end_span)
        case 3:
            cell.textLabel.text = @"وضع التخفي (Stealth)";
            [switcher setOn:[self.settings[@"stealth_active"] boolValue]];
            cell.accessoryView = switcher;
            break;
        case 4:
            cell.textLabel.text = [NSString stringWithFormat:@"المسافة: %.0fm", [self.settings[@"max_distance"] floatValue]];
            [span_8](start_span)break;[span_8](end_span)
        case 5:
            cell.textLabel.text = @"إغلاق القائمة";
            cell.textLabel.textColor = [UIColor systemRedColor];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            [span_9](start_span)break;[span_9](end_span)
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 5) {
        [span_10](start_span)[self dismissViewControllerAnimated:YES completion:nil];[span_10](end_span)
    }
}

- (void)toggleESP:(UISwitch *)sender {
    self.settings[@"esp_enabled"] = @(sender.isOn);
    [span_11](start_span)NSLog(@"[Sovereign] ESP Status: %d", sender.isOn);[span_11](end_span)
}

@end

// --- الزر العائم المتطور ---
@interface FloatingButton : UIButton
@property (nonatomic, strong) ESPSettingsController *settingsController;
@end

@implementation FloatingButton
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.8 alpha:0.8];
        self.layer.cornerRadius = frame.size.width / 2;
        self.layer.shadowColor = [UIColor cyanColor].CGColor;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 5;
        [span_12](start_span)[self setTitle:@"🛡️" forState:UIControlStateNormal];[span_12](end_span)
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [span_13](start_span)[self addGestureRecognizer:pan];[span_13](end_span)
        [self addTarget:self action:@selector(openMenu) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)openMenu {
    if (!self.settingsController) {
        self.settingsController = [[ESPSettingsController alloc] init];
        self.settingsController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    [span_14](start_span)[root presentViewController:self.settingsController animated:YES completion:nil];[span_14](end_span)
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.superview];
    self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    [span_15](start_span)[pan setTranslation:CGPointZero inView:self.superview];[span_15](end_span)
}
@end

// --- نقطة الدخول والـ Hook ---
%hook UIApplication

- (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    %orig;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        // 1. تشغيل نظام الحماية المعكوس (Shadow Master)
        ShadowMasterCore *master = [%c(ShadowMasterCore) master];
        [master initializeWithOverride:@{@"attack_mode": @"stealth"}];
        [master startExploitation];
        [master cloakCompletely];

        // 2. إنشاء الواجهة العائمة
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        FloatingButton *btn = [[FloatingButton alloc] initWithFrame:CGRectMake(50, 150, 60, 60)];
        [window addSubview:btn];
        [span_16](start_span)[window bringSubviewToFront:btn];[span_16](end_span)
    });
}

%end
