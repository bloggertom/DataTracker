//
//  DTSettingsViewController.m
//  DataTracker
//
//  Created by Thomas Wilson on 29/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import "DTSettingsViewController.h"
#import "DTMainViewController.h"
@interface DTSettingsViewController ()

@end

@implementation DTSettingsViewController

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
	// Do any additional setup after loading the view.
	//set up remove button
	self.view.backgroundColor = [UIColor whiteColor];
	
		
	[self setUpUI];
	
}
-(void)setUpUI{
	//check if 4G is possible
	if ([DTMainViewController FourGEnabledModel]) {
		UILabel *fGLabel = [[UILabel alloc]init];
		UISwitch *fGSwitch = [[UISwitch alloc]init];
			//set up label for switch
		fGLabel.font = [UIFont boldSystemFontOfSize:13];
		
		NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
		[dic setObject:fGLabel.font	forKey:NSFontAttributeName];
		[dic setObject:[UIColor darkTextColor] forKey:NSForegroundColorAttributeName];
		NSMutableAttributedString *labelString = [[NSMutableAttributedString alloc]initWithString:@"4G Mode:" attributes:dic];
		CGSize size = [labelString.string sizeWithAttributes:dic];
		
		fGLabel.frame = CGRectMake((self.view.bounds.size.width/2)-(size.width/2), ((self.view.bounds.size.height/2) + (size.height+fGSwitch.bounds.size.height)), size.width, size.height);
		fGLabel.attributedText = labelString;
		
			//set up switch
		fGSwitch.frame = CGRectMake(fGLabel.frame.origin.x, fGLabel.frame.origin.y+size.height, 0, 0);
		[fGSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		fGSwitch.on = [defaults boolForKey:kDataType4G];
		
		[self.view addSubview:fGSwitch];
		[self.view addSubview:fGLabel];
	}
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)switchValueChanged:(id)sender{
	if ([sender isKindOfClass:[UISwitch class]]) {
		UISwitch *fgSwitch = (UISwitch *)sender;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setBool:fgSwitch.on forKey:kDataType4G];
		[self.callBack switchValueDidChanged:fgSwitch.on];
	}
}
@end
