#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// --- تعريف واجهات نظام الحماية الموجودة في SovereignSecurity.m ---
@interface ShadowMasterCore : NSObject
+ (instancetype)master;
- (void)initializeWithOverride:(NSDictionary *)config;
- (void)startExploitation;
- (void)cloakCompletely;
@end

// --- واجهة لوحة التحكم ---
@interface ESPSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *settings;
@end

@implementation ESPSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"🛡️ Sovereign Panel";
    self.view.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.08 alpha:0.95];
    
    // إعداد الجدول
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor grayColor];
    [self.view addSubview:self.tableView];

    // الإعدادات الافتراضية
    self.settings = [@{
        @"esp_enabled": @NO,
        @"show_boxes": @YES,
        @"aim_assist": @NO,
        @"stealth_mode": @YES
    } mutableCopy];
}

#pragma mark - Table View DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"ESPControlCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.8];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    if (indexPath.row == 4) {
        cell.textLabel.text = @"إغلاق القائمة (Close)";
        cell.textLabel.textColor = [UIColor systemRedColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }

    UISwitch *switcher = [[UISwitch alloc] init];
    switcher.tag = indexPath.row;
    [switcher addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];

    if (indexPath.row == 0) {
        cell.textLabel.text = @"تفعيل ESP";
        [switcher setOn:[self.settings[@"esp_enabled"] boolValue]];
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"إظهار المربعات";
        [switcher setOn:[self.settings[@"show_boxes"] boolValue]];
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"مساعدة التصويب";
        [switcher setOn:[self.settings[@"aim_assist"] boolValue]];
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"وضع التخفي (Stealth)";
        [switcher setOn:[self.settings[@"stealth_mode"] boolValue]];
    }
    
    cell.accessoryView = switcher;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 4) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)switchChanged:(UISwitch *)sender {
    // هنا يمكن إضافة الأوامر البرمجية لكل زر
    NSLog(@"[Sovereign] تم تغيير الإعداد رقم: %ld", (long)sender.tag);
}
@end

// --- الزر العائم ---
@interface FloatingButton : UIButton
@property (nonatomic, strong) ESPSettingsController *settingsController;
@end

@implementation FloatingButton
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.8];
        self.layer.cornerRadius = frame.size.width / 2;
        self.layer.masksToBounds = YES;
        [self setTitle:@"🎮" forState:UIControlStateNormal];
        
        // إضافة حركة السحب
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
        
        // فتح القائمة عند الضغط
        [self addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)showMenu {
    if (!self.settingsController) {
        self.settingsController = [[ESPSettingsController alloc] init];
        self.settingsController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow.rootViewController presentViewController:self.settingsController animated:YES completion:nil];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.superview];
    self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:self.superview];
}
@end

// --- Hooking ---
%hook UIApplication

- (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    %orig;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        // 1. تشغيل نظام الحماية المعكوس من SovereignSecurity.m
        ShadowMasterCore *master = [%c(ShadowMasterCore) master];
        if (master) {
            [master initializeWithOverride:@{@"attack_mode": @"stealth"}];
            [master startExploitation];
            [master cloakCompletely];
        }
        
        // 2. إظهار الزر العائم
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window) {
            FloatingButton *btn = [[FloatingButton alloc] initWithFrame:CGRectMake(20, 100, 55, 55)];
            [window addSubview:btn];
            [window bringSubviewToFront:btn];
        }
    });
}

%end
