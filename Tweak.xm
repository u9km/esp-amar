// Tweak.xm
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// دالة البحث عن نافذة اللعبة
UIWindow *findGameWindow() {
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows) {
        if (window.rootViewController) {
            return window;
        }
    }
    return nil;
}

// واجهة ESP
@interface ESPSettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *settings;
@end

@implementation ESPSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"🛡️ إعدادات ESP";
    self.view.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.9];
    
    // إنشاء جدول الإعدادات
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    // الإعدادات الافتراضية
    self.settings = [@{
        @"esp_enabled": @NO,
        @"show_boxes": @YES,
        @"show_health": @YES,
        @"show_names": @YES,
        @"aim_assist": @NO,
        @"max_distance": @500.0
    } mutableCopy];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = @"تفعيل نظام الرؤية";
            UISwitch *switcher = [[UISwitch alloc] init];
            [switcher setOn:[self.settings[@"esp_enabled"] boolValue]];
            [switcher addTarget:self action:@selector(toggleESP:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switcher;
            break;
        }
        case 1: {
            cell.textLabel.text = @"إظهار المربعات";
            UISwitch *switcher = [[UISwitch alloc] init];
            [switcher setOn:[self.settings[@"show_boxes"] boolValue]];
            [switcher addTarget:self action:@selector(toggleBoxes:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switcher;
            break;
        }
        case 2: {
            cell.textLabel.text = @"إظهار أشرطة الصحة";
            UISwitch *switcher = [[UISwitch alloc] init];
            [switcher setOn:[self.settings[@"show_health"] boolValue]];
            [switcher addTarget:self action:@selector(toggleHealth:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switcher;
            break;
        }
        case 3: {
            cell.textLabel.text = @"مساعدة التصويب";
            UISwitch *switcher = [[UISwitch alloc] init];
            [switcher setOn:[self.settings[@"aim_assist"] boolValue]];
            [switcher addTarget:self action:@selector(toggleAim:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switcher;
            break;
        }
        case 4: {
            cell.textLabel.text = [NSString stringWithFormat:@"أقصى مسافة: %.0fm", 
                                  [self.settings[@"max_distance"] floatValue]];
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
            slider.minimumValue = 50;
            slider.maximumValue = 1000;
            slider.value = [self.settings[@"max_distance"] floatValue];
            [slider addTarget:self action:@selector(distanceChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = slider;
            break;
        }
        case 5: {
            cell.textLabel.text = @"إغلاق القائمة";
            cell.textLabel.textColor = [UIColor redColor];
            break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 5) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Actions

- (void)toggleESP:(UISwitch *)sender {
    self.settings[@"esp_enabled"] = @(sender.isOn);
    NSLog(@"[ESP] ESP %@", sender.isOn ? @"مفعل" : @"معطل");
}

- (void)toggleBoxes:(UISwitch *)sender {
    self.settings[@"show_boxes"] = @(sender.isOn);
}

- (void)toggleHealth:(UISwitch *)sender {
    self.settings[@"show_health"] = @(sender.isOn);
}

- (void)toggleAim:(UISwitch *)sender {
    self.settings[@"aim_assist"] = @(sender.isOn);
}

- (void)distanceChanged:(UISlider *)sender {
    self.settings[@"max_distance"] = @(sender.value);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end

// زر عائم للقائمة
@interface FloatingButton : UIButton
@property (nonatomic, strong) ESPSettingsController *settingsController;
@end

@implementation FloatingButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.7];
        self.layer.cornerRadius = 25;
        self.layer.masksToBounds = YES;
        [self setTitle:@"🎮" forState:UIControlStateNormal];
        [self addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        
        // إضافة حركة السحب
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)showMenu {
    if (!self.settingsController) {
        self.settingsController = [[ESPSettingsController alloc] init];
        self.settingsController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC presentViewController:self.settingsController animated:YES completion:nil];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    UIView *view = pan.view;
    CGPoint translation = [pan translationInView:view.superview];
    
    view.center = CGPointMake(view.center.x + translation.x, view.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:view.superview];
}

@end

// Hook للتطبيق
%hook UIApplication

- (void)didFinishLaunching {
    %orig;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        // إنشاء زر عائم
        FloatingButton *floatingButton = [[FloatingButton alloc] initWithFrame:CGRectMake(20, 100, 50, 50)];
        [window addSubview:floatingButton];
        
        // جعل الزر في المقدمة دائماً
        [window bringSubviewToFront:floatingButton];
    });
}

%end