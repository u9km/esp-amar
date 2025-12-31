#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// استدعاء واجهة المحرك من ملف SovereignSecurity.m
@interface ShadowMasterCore : NSObject
+ (instancetype)master;
- (void)initializeWithOverride:(NSDictionary *)config;
- (void)startExploitation;
@end

// --- لوحة التحكم ---
@interface SovereignMenuVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation SovereignMenuVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"🛡️ Sovereign Menu";
    self.view.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.1 alpha:0.95];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return 4; }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    UISwitch *sw = [[UISwitch alloc] init];
    if (indexPath.row == 0) cell.textLabel.text = @"تفعيل ESP";
    else if (indexPath.row == 1) cell.textLabel.text = @"تفعيل الحماية";
    else if (indexPath.row == 2) cell.textLabel.text = @"إخفاء التعديلات";
    else {
        cell.textLabel.text = @"إغلاق";
        cell.textLabel.textColor = [UIColor systemRedColor];
        return cell;
    }
    cell.accessoryView = sw;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) [self dismissViewControllerAnimated:YES completion:nil];
}
@end

// --- الربط الآمن بدون كراش ---
%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    
    // إضافة الزر العائم مرة واحدة فقط
    if (![self.view viewWithTag:999]) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 999;
        btn.frame = CGRectMake(40, 100, 60, 60);
        btn.backgroundColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.9 alpha:0.8];
        btn.layer.cornerRadius = 30;
        [btn setTitle:@"S" forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(openSovereign) forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
        [btn addGestureRecognizer:pan];
        
        [self.view addSubview:btn];
        [self.view bringSubviewToFront:btn];
    }
}

%new
- (void)openSovereign {
    SovereignMenuVC *menu = [[SovereignMenuVC alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:menu];
    [self presentViewController:nav animated:YES completion:nil];
}

%new
- (void)handleDrag:(UIPanGestureRecognizer *)p {
    UIView *v = p.view;
    CGPoint t = [p translationInView:v.superview];
    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [p setTranslation:CGPointZero inView:v.superview];
}
%end

