#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// تعريف محرك الحماية
@interface ShadowMasterCore : NSObject
+ (instancetype)master;
- (void)initializeWithOverride:(NSDictionary *)config;
- (void)startExploitation;
@end

// --- واجهة المستخدم ---
@interface SovereignMenu : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation SovereignMenu
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.1 alpha:0.9];
    self.title = @"SOVEREIGN V1.0";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return 3; }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.05];
    cell.textLabel.textColor = [UIColor whiteColor];
    if (indexPath.row == 0) cell.textLabel.text = @"تفعيل ESP";
    else if (indexPath.row == 1) cell.textLabel.text = @"حماية الحساب";
    else { cell.textLabel.text = @"إغلاق"; cell.textLabel.textColor = [UIColor redColor]; }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) [self dismissViewControllerAnimated:YES completion:nil];
}
@end

// --- حل مشكلة keyWindow وإضافة الزر ---
%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIWindow *window = nil;
        // الطريقة الحديثة المتوافقة مع iOS 13+ لتجنب خطأ keyWindow
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    window = scene.windows.firstObject;
                    break;
                }
            }
        } else {
            window = [UIApplication sharedApplication].keyWindow;
        }

        if (window && ![window viewWithTag:99]) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = 99;
            btn.frame = CGRectMake(50, 150, 50, 50);
            btn.backgroundColor = [UIColor systemBlueColor];
            btn.layer.cornerRadius = 25;
            [btn setTitle:@"S" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(openMenu) forControlEvents:UIControlEventTouchUpInside];
            [window addSubview:btn];
        }
    });
}

%new
- (void)openMenu {
    SovereignMenu *menu = [[SovereignMenu alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:menu];
    [self presentViewController:nav animated:YES completion:nil];
}
%end
