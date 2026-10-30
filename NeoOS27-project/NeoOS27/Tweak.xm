#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <objc/message.h>

static NSString * const kPrefsPath = @"/var/mobile/Library/Preferences/com.neoos27.tweak.plist";
static UIWindow *gNeoWindow;
static UIView *gIsland;
static UILabel *gIslandLabel;
static BOOL gExpanded = NO;
static BOOL gEnabled = YES;
static BOOL gIslandEnabled = YES;
static BOOL gGestureEnabled = YES;
static BOOL gShowDemoStatus = YES;
static CGFloat gGlassOpacity = 0.82;

static NSDictionary *NeoPrefs(void) {
    NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:kPrefsPath];
    return d ?: @{};
}

static void NeoLoadPrefs(void) {
    NSDictionary *p = NeoPrefs();
    gEnabled = p[@"Enabled"] ? [p[@"Enabled"] boolValue] : YES;
    gIslandEnabled = p[@"IslandEnabled"] ? [p[@"IslandEnabled"] boolValue] : YES;
    gGestureEnabled = p[@"GestureEnabled"] ? [p[@"GestureEnabled"] boolValue] : YES;
    gShowDemoStatus = p[@"ShowDemoStatus"] ? [p[@"ShowDemoStatus"] boolValue] : YES;
    gGlassOpacity = p[@"GlassOpacity"] ? [p[@"GlassOpacity"] doubleValue] : 0.82;
    gGlassOpacity = MIN(1.0, MAX(0.35, gGlassOpacity));
}

@interface NeoIslandView : UIView
@end

@implementation NeoIslandView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;

    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = frame.size.height / 2.0;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 0.7;
    self.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.28].CGColor;

    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterialDark];
    UIVisualEffectView *glass = [[UIVisualEffectView alloc] initWithEffect:blur];
    glass.frame = self.bounds;
    glass.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    glass.alpha = gGlassOpacity;
    [self addSubview:glass];

    UIView *tint = [[UIView alloc] initWithFrame:self.bounds];
    tint.backgroundColor = [UIColor colorWithWhite:0.02 alpha:0.65 * gGlassOpacity];
    tint.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:tint];

    gIslandLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 13, 0)];
    gIslandLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gIslandLabel.textColor = UIColor.whiteColor;
    gIslandLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    gIslandLabel.textAlignment = NSTextAlignmentCenter;
    gIslandLabel.text = gShowDemoStatus ? @"◖  NeoOS 27  ·  Ready  ◗" : @"";
    [self addSubview:gIslandLabel];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(neo_toggle)];
    [self addGestureRecognizer:tap];
    return self;
}
- (void)neo_toggle {
    gExpanded = !gExpanded;
    [UIView animateWithDuration:0.28 delay:0 usingSpringWithDamping:0.78 initialSpringVelocity:0.3 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        CGRect f = self.frame;
        f.size.width = gExpanded ? MIN(300, UIScreen.mainScreen.bounds.size.width - 36) : 176;
        f.size.height = gExpanded ? 82 : 34;
        f.origin.x = (UIScreen.mainScreen.bounds.size.width - f.size.width) / 2.0;
        self.frame = f;
        self.layer.cornerRadius = f.size.height / 2.0;
        gIslandLabel.text = gExpanded ? @"♪  Now Playing  ·  NeoOS Demo" : (gShowDemoStatus ? @"◖  NeoOS 27  ·  Ready  ◗" : @"");
    } completion:nil];
}
@end

static void NeoShowUI(void) {
    NeoLoadPrefs();
    if (!gEnabled || !gIslandEnabled || !UIApplication.sharedApplication) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!gNeoWindow) {
            CGRect bounds = UIScreen.mainScreen.bounds;
            gNeoWindow = [[UIWindow alloc] initWithFrame:bounds];
            gNeoWindow.windowLevel = UIWindowLevelStatusBar + 2;
            gNeoWindow.backgroundColor = UIColor.clearColor;
            gNeoWindow.userInteractionEnabled = YES;
            gNeoWindow.rootViewController = [UIViewController new];
            gNeoWindow.rootViewController.view.backgroundColor = UIColor.clearColor;
            gNeoWindow.hidden = NO;
            CGFloat top = UIApplication.sharedApplication.statusBarFrame.size.height;
            if (top < 20) top = 20;
            gIsland = [[NeoIslandView alloc] initWithFrame:CGRectMake((bounds.size.width - 176)/2, top - 2, 176, 34)];
            [gNeoWindow.rootViewController.view addSubview:gIsland];
        } else {
            gNeoWindow.hidden = NO;
        }
    });
}

// A small bottom-edge gesture recognizer. The physical Home/Touch ID button remains available.
@interface NeoGestureCatcher : NSObject
@property(nonatomic, strong) UIScreenEdgePanGestureRecognizer *edge;
@end

@implementation NeoGestureCatcher
- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    UIWindow *target = UIApplication.sharedApplication.keyWindow;
    if (!target) return self;
    _edge = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(neo_edge:)];
    _edge.edges = UIRectEdgeBottom;
    _edge.cancelsTouchesInView = NO;
    [target addGestureRecognizer:_edge];
    return self;
}
- (void)neo_edge:(UIScreenEdgePanGestureRecognizer *)gr {
    if (gr.state != UIGestureRecognizerStateEnded || !gGestureEnabled) return;
    CGPoint v = [gr velocityInView:gr.view];
    if (v.y < -250) {
        // Private API availability varies. Do not disable the hardware Home button as a fallback.
        UIApplication *app = UIApplication.sharedApplication;
        SEL homeSel = NSSelectorFromString(@"_simulateHomeButtonPress");
        if ([app respondsToSelector:homeSel]) {
            ((void (*)(id, SEL))objc_msgSend)(app, homeSel);
        } else {
            // Safe fallback: show a brief visual acknowledgement; user can still press Home.
            UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
            [feedback impactOccurred];
        }
    }
}
@end

static NeoGestureCatcher *gGestureCatcher;

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NeoShowUI();
        NeoLoadPrefs();
        if (gEnabled && gGestureEnabled && !gGestureCatcher) {
            gGestureCatcher = [NeoGestureCatcher new];
        }
    });
}
%end

static void NeoPreferencesChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NeoLoadPrefs();
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!gEnabled || !gIslandEnabled) {
            gNeoWindow.hidden = YES;
        } else {
            NeoShowUI();
        }
    });
}

%ctor {
    @autoreleasepool {
        NeoLoadPrefs();
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            NULL,
            NeoPreferencesChanged,
            CFSTR("com.neoos27.tweak/preferences.changed"),
            NULL,
            CFNotificationSuspensionBehaviorDeliverImmediately
        );
    }
}
