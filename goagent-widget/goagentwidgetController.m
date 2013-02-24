#import "BBWeeAppController-Protocol.h"
#import <stdlib.h>
#import <sys/stat.h>
#import "iniparser/iniparser.h"

static NSBundle *_goagentwidgetWeeAppBundle = nil;

@interface goagentwidgetController: NSObject <BBWeeAppController> {
	UIView *_view;
	UIImageView *_backgroundView;
    dictionary* iniDic;
}

@property (nonatomic, retain) UIView *view;
-(void)setupUI;

@end

@implementation goagentwidgetController
@synthesize view = _view;

+ (void)initialize {
	_goagentwidgetWeeAppBundle = [[NSBundle bundleForClass:[self class]] retain];
}

- (id)init {
	if((self = [super init]) != nil) {
		
	} return self;
}

- (void)dealloc {
	[_view release];
	[_backgroundView release];
    if (iniDic) {
        iniparser_freedict(iniDic);
    }
	[super dealloc];
}

- (void)loadFullView {
	// Add subviews to _backgroundView (or _view) here.
    //[self setupUI];
}

- (void)loadPlaceholderView {
	// All widgets are 316 points wide. Image size calculations match those of the Stocks widget.
	_view = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, {316.f, [self viewHeight]}}];
	_view.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	NSString* image_path = [_goagentwidgetWeeAppBundle pathForResource:@"WeeAppBackground" ofType:@"png"];
    UIImage *bgImg = [UIImage imageWithContentsOfFile:image_path];
	_backgroundView = [[UIImageView alloc] initWithImage:bgImg];
	_backgroundView.frame = CGRectInset(_view.bounds, 2.f, 0.f);
	_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
	[_view addSubview:_backgroundView];
    [self setupUI];
}

- (void)unloadView {
	[_view release];
	_view = nil;
	[_backgroundView release];
	_backgroundView = nil;
}

- (float)viewHeight {
	return 130.f;
}

- (void)setupUI
{
    NSString* ini_filepath = @"/Applications/goagent-ios.app/goagent-local/proxy.ini";
    //NSLog(@"%@", ini_filepath);
    if(!iniDic)
    {
        iniDic = iniparser_load([ini_filepath UTF8String]);
    }
    
    NSString* proxy_filepath = @"/Applications/goagent-ios.app/goagent-local/proxy.py";
    //NSLog(@"%@", proxy_filepath);
    
    NSString *data = [NSString stringWithContentsOfFile:proxy_filepath encoding:NSUTF8StringEncoding error:nil];
    NSString* version_ptn = @"__version__[ ?]=[ ?]'(.*)'";
    NSRegularExpression * version_reg = [NSRegularExpression regularExpressionWithPattern:version_ptn options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSTextCheckingResult* result = [version_reg firstMatchInString:data options:0 range:NSMakeRange(0, 1024)];

    NSString* version_str = [data substringWithRange:[result rangeAtIndex:result.numberOfRanges-1]];
    
    NSLog(@"%@",version_str);
    
    CGRect rootRect = [self.view frame];
    float left_x_offset = 15.0;
    float left_y_offset = 15.0;
    float left_font_size = 12.0;
    float right_border_offset = 20.0;
    float button_offset = 85.0;
    float title_label_offset = 102.0;
    
    NSLog(@"self.view frame is %@",NSStringFromCGRect(rootRect));
    
    UILabel* version_label = [[UILabel alloc] initWithFrame:CGRectMake(rootRect.origin.x + left_x_offset,
                                                                       rootRect.origin.y + left_y_offset,
                                                                       20.0,20.0)];
    [version_label setText:[NSString stringWithFormat:@"Version : %@", version_str]];
    [version_label setTextColor:[UIColor whiteColor]];
    [version_label setBackgroundColor:[UIColor clearColor]];
    [version_label setFont:[UIFont systemFontOfSize:left_font_size]];
    [version_label sizeToFit];
    
    UILabel* listen_label = [[UILabel alloc] initWithFrame:CGRectMake(rootRect.origin.x + left_x_offset,
                                                                      rootRect.origin.y + 2*left_y_offset,
                                                                      20.0, 20.0)];
    [listen_label setText:[NSString stringWithFormat:@"Listen Addr : %s:%d",
                           iniparser_getstring(iniDic, "listen:ip", NULL),
                           iniparser_getint(iniDic, "listen:port", 0)]];
    [listen_label setTextColor:[UIColor whiteColor]];
    [listen_label setBackgroundColor:[UIColor clearColor]];
    [listen_label setFont:[UIFont systemFontOfSize:left_font_size]];
    [listen_label sizeToFit];
    
    UILabel* mode_label = [[UILabel alloc] initWithFrame:CGRectMake(rootRect.origin.x + left_x_offset,
                                                                    rootRect.origin.y + 3*left_y_offset,
                                                                    20.0, 20.0)];
    [mode_label setText:[NSString stringWithFormat:@"GAE Mode : %s", iniparser_getstring(iniDic,[[NSString stringWithFormat:@"%s:mode",iniparser_getstring(iniDic, "gae:profile", "google_cn")] UTF8String],NULL)]];
    [mode_label setTextColor:[UIColor whiteColor]];
    [mode_label setBackgroundColor:[UIColor clearColor]];
    [mode_label setFont:[UIFont systemFontOfSize:left_font_size]];
    [mode_label sizeToFit];
    
    UILabel* profile_label = [[UILabel alloc] initWithFrame:CGRectMake(rootRect.origin.x + left_x_offset,
                                                                       rootRect.origin.y + 4*left_y_offset,
                                                                       20.0, 20.0)];
    [profile_label setText:[NSString stringWithFormat:@"GAE Profile : %s", iniparser_getstring(iniDic, "gae:profile", NULL)]];
    [profile_label setTextColor:[UIColor whiteColor]];
    [profile_label setBackgroundColor:[UIColor clearColor]];
    [profile_label setFont:[UIFont systemFontOfSize:left_font_size]];
    [profile_label sizeToFit];
    
    UILabel* appid_label = [[UILabel alloc] initWithFrame:CGRectMake(rootRect.origin.x + left_x_offset,
                                                                     rootRect.origin.y + 5*left_y_offset,
                                                                     20.0, 20.0)];
    [appid_label setText:[NSString stringWithFormat:@"GAE APPID : %s", iniparser_getstring(iniDic, "gae:appid", NULL)]];
    [appid_label setTextColor:[UIColor whiteColor]];
    [appid_label setBackgroundColor:[UIColor clearColor]];
    [appid_label setFont:[UIFont systemFontOfSize:left_font_size]];
    [appid_label sizeToFit];
    
    UILabel* pac_label = [[UILabel alloc] initWithFrame:CGRectMake(rootRect.origin.x + left_x_offset,
                                                                   rootRect.origin.y + 6*left_y_offset,
                                                                   20.0, 20.0)];
    [pac_label setText:[NSString stringWithFormat:@"Pac Server : %s:%d/%s",
                        iniparser_getstring(iniDic, "pac:ip", NULL),
                        iniparser_getint(iniDic, "pac:port", 0),
                        iniparser_getstring(iniDic, "pac:file", NULL)]];
    [pac_label setTextColor:[UIColor whiteColor]];
    [pac_label setBackgroundColor:[UIColor clearColor]];
    [pac_label setFont:[UIFont systemFontOfSize:left_font_size]];
    [pac_label sizeToFit];
    
    UILabel* title_label = [[UILabel alloc] initWithFrame:CGRectMake(rootRect.size.width - title_label_offset,
                                                                     rootRect.origin.y + right_border_offset,
                                                                     20.0, 20.0)];
    [title_label setText:@"GoAgent iOS"];
    [title_label setTextColor:[UIColor whiteColor]];
    [title_label setBackgroundColor:[UIColor clearColor]];
    [title_label sizeToFit];
    
    NSLog(@"title_label frame is %@", NSStringFromCGRect(title_label.frame));
    
    
    UISwitch* toggle_btn = [[UISwitch alloc] init];
    [toggle_btn setFrame:CGRectMake(rootRect.size.width - button_offset,
                                    rootRect.origin.y + 3.0 * right_border_offset,
                                    toggle_btn.frame.size.width, toggle_btn.frame.size.height)];
    
    [toggle_btn addTarget:self action:@selector(runGoAgent:) forControlEvents:UIControlEventValueChanged];
    
    struct stat st;
	if(stat("/tmp/goagent.pid",&st)==0)
    {
        [toggle_btn setOn:YES];
    }
    else
    {
        [toggle_btn setOn:NO];
    }
	
    
    NSLog(@"toggle_btn frame is %@",NSStringFromCGRect(toggle_btn.frame));
    
    [_view addSubview:version_label];
    [_view addSubview:listen_label];
    [_view addSubview:mode_label];
    [_view addSubview:profile_label];
    [_view addSubview:appid_label];
    [_view addSubview:pac_label];
    [_view addSubview:title_label];
    [_view addSubview:toggle_btn];
    
    [version_label release];
    [listen_label release];
    [mode_label release];
    [profile_label release];
    [appid_label release];
    [pac_label release];
    [title_label release];
    [toggle_btn release];
}

- (void)runGoAgent:(id)sender {
    UISwitch* btn = (UISwitch*)sender;
    if ([btn isOn])
    {
        system("touch /tmp/goagent.pid");
    }
    else 
    {
        system("echo 'stop' >> /tmp/goagent/stop");
    }
}
@end
