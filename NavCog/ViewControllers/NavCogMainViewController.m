/*******************************************************************************
 * Copyright (c) 2015 Chengxiong Ruan
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *******************************************************************************/

#import "NavCogMainViewController.h"

@interface NavCogMainViewController ()

@property (strong, nonatomic) UIPickerView *fromPicker;
@property (strong, nonatomic) UIPickerView *toPicker;
@property (strong, nonatomic) NavCogFuncViewController *navFuncViewCtrl;
@property (strong, nonatomic) NavCogChooseLogViewController *navLogViewCtrl;
@property (strong, nonatomic) NavCogDataSamplingViewController *dataSamplingViewCtrl;
@property (strong, nonatomic) NavCogHelpPageViewController *helpPageViewCtrl;
@property (strong, nonatomic) TopoMap *topoMap;
@property (strong, nonatomic) NSString *mapDataString;
@property (strong, nonatomic) NavMachine *navMachine;
@property (strong, nonatomic) NSMutableArray *allFromLocationName;
@property (strong, nonatomic) NSMutableArray *allToLocationName;
@property (strong, nonatomic) NSString *fromNodeName;
@property (strong, nonatomic) NSString *toNodeName;
@property (strong, nonatomic) UIButton *startNavButton;
@property (strong, nonatomic) NSArray *pathNodes;
@property (nonatomic) Boolean isWebViewLoaded;
@property (nonatomic) Boolean isSpeechEnabled;
@property (nonatomic) Boolean isClickEnabled;
@property (nonatomic) Boolean isSpeechFast;
@property (weak, nonatomic) IBOutlet UIButton *getDataBtn;
@property (weak, nonatomic) IBOutlet UIButton *logReplayBtn;

@end

@implementation NavCogMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    _dataSamplingViewCtrl = [[NavCogDataSamplingViewController alloc] init];
    _helpPageViewCtrl = [[NavCogHelpPageViewController alloc] init];
    _navFuncViewCtrl = [NavCogFuncViewController sharedNavCogFuntionViewController];
    _navFuncViewCtrl.delegate = self;
    _navMachine = [[NavMachine alloc] init];
    _navMachine.delegate = self;
    _isWebViewLoaded = false;
    _allFromLocationName = [[NSMutableArray alloc] init];
    _allToLocationName = [[NSMutableArray alloc] init];
    _fromNodeName = nil;
    _toNodeName = nil;
    _isSpeechEnabled = true;
    _isClickEnabled = false;
    _isSpeechFast = true;
    [NavCogChooseMapViewController setMapChooserDelegate:self];
    [NavCogChooseLogViewController setLogChooserDelegate:self];
}

- (void)setupUI {
    float sw = [[UIScreen mainScreen] bounds].size.width;
    float sh = [[UIScreen mainScreen] bounds].size.height;
    float bt = 20; // button top
    float bm = 5; // button margin
    float bh = 50; // button height
    float bw = (sw - 3 * bm) / 2;
    float bb = bt + bh;
    float ot = sh - 150;
    
    // buttons
    UIButton *initalizeOriButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [initalizeOriButton addTarget:self action:@selector(initializeOrientation) forControlEvents:UIControlEventTouchUpInside];
    initalizeOriButton.frame = CGRectMake(bm, bt, bw, bh);
    initalizeOriButton.bounds = CGRectMake(0, 0, bw, bh);
    initalizeOriButton.layer.cornerRadius = 3;
    initalizeOriButton.backgroundColor = [UIColor clearColor];
    initalizeOriButton.layer.borderWidth = 2.0;
    initalizeOriButton.layer.borderColor = [UIColor blackColor].CGColor;
    [initalizeOriButton setTitle:NSLocalizedString(@"initOrientationButton", @"Button to initialize orientation") forState:UIControlStateNormal];
    [initalizeOriButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [initalizeOriButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.view addSubview:initalizeOriButton];
    
    _startNavButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_startNavButton addTarget:self action:@selector(startNavigation) forControlEvents:UIControlEventTouchUpInside];
    _startNavButton.frame = CGRectMake(bw + 2 * bm + 1, bt, bw, bh);
    _startNavButton.bounds = CGRectMake(0, 0, bw, bh);
    _startNavButton.layer.cornerRadius = 3;
    _startNavButton.backgroundColor = [UIColor clearColor];
    _startNavButton.layer.borderWidth = 2.0;
    _startNavButton.layer.borderColor = [UIColor blackColor].CGColor;
    [_startNavButton setTitle:NSLocalizedString(@"startNavigationButton", @"Button to start navigation") forState:UIControlStateNormal];
    [_startNavButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_startNavButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    _startNavButton.enabled = false;
    [self.view addSubview:_startNavButton];
    
    // pickers
    float ph = (ot - bb - 2 * bm) / 2;
    float pw = (sw - 2 * bm) * 5 / 4;
    float par = 0.8;
    _fromPicker = [[UIPickerView alloc] initWithFrame:CGRectMake((sw - pw) / 2, bb + bm + 8, pw, ph)];
    _fromPicker.bounds = CGRectMake(0, 0, pw, ph);
    //_fromPicker.backgroundColor = [UIColor lightGrayColor];
    _fromPicker.delegate = self;
    _fromPicker.dataSource = self;
    _fromPicker.transform = CGAffineTransformMakeScale(par, par);
    _fromPicker.layer.borderWidth = 1;
    [self.view addSubview:_fromPicker];
    _toPicker = [[UIPickerView alloc] initWithFrame:CGRectMake((sw - pw) / 2, bb + ph + 2 * bm + 8, pw, ph)];
    _toPicker.bounds = CGRectMake(0, 0, pw, ph);
    //_toPicker.backgroundColor = [UIColor lightGrayColor];
    _toPicker.delegate = self;
    _toPicker.dataSource = self;
    _toPicker.transform = CGAffineTransformMakeScale(par, par);
    _toPicker.layer.borderWidth = 1;
    [self.view addSubview:_toPicker];
    
    // labels
    pw = (sw - 2 * bm) * 10 / 9;
    par = 0.9;
    float lh = 32;
    UILabel *fromLabel = [[UILabel alloc] initWithFrame:CGRectMake((sw - pw) / 2, bb + bm, pw, lh)];
    fromLabel.text = NSLocalizedString(@"fromLabel", @"Label for the source location picker");
    fromLabel.textAlignment = NSTextAlignmentCenter;
    fromLabel.transform = CGAffineTransformMakeScale(par, par);
    fromLabel.backgroundColor = [UIColor lightGrayColor];
    fromLabel.layer.borderWidth = 1;
    [self.view addSubview:fromLabel];
    UILabel *toLabel = [[UILabel alloc] initWithFrame:CGRectMake((sw - pw) / 2, bb + ph + 2 * bm, pw, lh)];
    toLabel.text = NSLocalizedString(@"toLabel", @"Label for the destination location picker");
    toLabel.textAlignment = NSTextAlignmentCenter;
    toLabel.transform = CGAffineTransformMakeScale(par, par);
    toLabel.backgroundColor = [UIColor lightGrayColor];
    toLabel.layer.borderWidth = 1;
    [self.view addSubview:toLabel];
}

- (void)defaultsChanged:(NSNotification*) notification {
    [self checkDevMode];
}

- (void)viewDidAppear:(BOOL)animated {
    [self checkDevMode];
    if (_fromNodeName == nil || _toNodeName == nil) {
        NavCogChooseMapViewController *mapChooser = [NavCogChooseMapViewController sharedMapChooser];
        [self.view addSubview:mapChooser.view];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void) checkDevMode{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"devmode_preference"]) {
        self.getDataBtn.hidden = NO;
        self.logReplayBtn.hidden = NO;
    } else {
        self.getDataBtn.hidden = YES;
        self.logReplayBtn.hidden = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initializeOrientation {
    [_navMachine initializeOrientation];
    _startNavButton.enabled = true;
}

- (void)startNavigation {
    if (_fromNodeName == nil || _toNodeName == nil ||[_fromNodeName isEqualToString:_toNodeName]) {
        return;
    }
    
    [_navMachine startNavigationOnTopoMap:_topoMap fromNodeWithName:_fromNodeName toNodeWithName:_toNodeName usingBeaconsWithUUID:[_topoMap getUUIDString] andMajorID:[_topoMap getMajorIDString].intValue withSpeechOn:_isSpeechEnabled withClickOn:_isClickEnabled withFastSpeechOn:_isSpeechFast];
}

// picker delegate's methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == _fromPicker) {
        return [_allFromLocationName count];
    }  else {
        return [_allToLocationName count];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == _fromPicker) {
        return [_allFromLocationName objectAtIndex:row];
    } else {
        return [_allToLocationName objectAtIndex:row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([_allFromLocationName count] == 0 || [_allToLocationName count] == 0) {
        return;
    }
    if (pickerView == _fromPicker) {
        _fromNodeName = [_allFromLocationName objectAtIndex:row];
    } else if (pickerView == _toPicker) {
        _toNodeName = [_allToLocationName objectAtIndex:row];
    }
}

// State Machine delegate's methods
- (void)navigationFinished {
    [_navFuncViewCtrl.view removeFromSuperview];
    [_navFuncViewCtrl runCmdWithString:@"stopNavigation()"];
}

- (void)navigationReadyToGo {
    [self.view addSubview:_navFuncViewCtrl.view];
    if (_isWebViewLoaded) {
        _pathNodes = [_navMachine getPathNodes];
        NavNode *startNode = [_pathNodes lastObject];
        NSMutableString *cmd = [[NSMutableString alloc] init];
        [cmd appendString:@"setStartNode("];
        [cmd appendFormat:@"%f,", startNode.lat];
        [cmd appendFormat:@"%f)", startNode.lng];
        [_navFuncViewCtrl runCmdWithString:cmd];
        cmd = [[NSMutableString alloc] init];
        [cmd appendString:@"startNavigation(["];
        for (int i = (int)[_pathNodes count] - 2; i >= 0; i--) {
            [cmd appendFormat:@"'%@'", ((NavNode *)[_pathNodes objectAtIndex:i]).nodeID];
            if (i > 0) {
                [cmd appendString:@","];
            }
        }
        [cmd appendString:@"])"];
        [_navFuncViewCtrl runCmdWithString:cmd];
    }
}

// Function View delegate's methods
- (void)didTriggerPreviousInstruction {
    [_navMachine repeatInstruction];
}

- (void)didTriggerAccessInstruction {
    [_navMachine announceAccessibilityInfo];
}

- (void)didTriggerSurroundInstruction {
    [_navMachine announceSurroundInfo];
}

- (void)didTriggerStopNavigation {
    [_navFuncViewCtrl.view removeFromSuperview];
    [_navMachine stopNavigation];
    [_navFuncViewCtrl runCmdWithString:@"stopNavigation()"];
}

- (void)webViewLoaded {
    _isWebViewLoaded = true;
    NSString *setDataCMD = [NSString stringWithFormat:@"setMapData(%@)", _mapDataString];
    [_navFuncViewCtrl runCmdWithString:setDataCMD];
    _pathNodes = [_navMachine getPathNodes];
    NavNode *startNode = [_pathNodes lastObject];
    NSMutableString *cmd = [[NSMutableString alloc] init];
    [cmd appendString:@"setStartNode("];
    [cmd appendFormat:@"%f,", startNode.lat];
    [cmd appendFormat:@"%f)", startNode.lng];
    [_navFuncViewCtrl runCmdWithString:cmd];
    cmd = [[NSMutableString alloc] init];
    [cmd appendString:@"startNavigation(["];
    for (int i = (int)[_pathNodes count] - 2; i >= 0; i--) {
        [cmd appendFormat:@"'%@'", ((NavNode *)[_pathNodes objectAtIndex:i]).nodeID];
        if (i > 0) {
            [cmd appendString:@","];
        }
    }
    [cmd appendString:@"])"];
    [_navFuncViewCtrl runCmdWithString:cmd];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//start simulation TODO: change to picker subview
- (IBAction)switchToLogChooseUI:(id)sender {
    _navLogViewCtrl = [NavCogChooseLogViewController sharedLogChooser];
    [self.view addSubview:_navLogViewCtrl.view];
}

// go to map list table view
- (IBAction)switchToMapChooseUI:(id)sender {
    NavCogChooseMapViewController *mapChooser = [NavCogChooseMapViewController sharedMapChooser];
    [self.view addSubview:mapChooser.view];
}

// go to data sampling view
- (IBAction)switchToDataSamplingUI:(id)sender {
    [self.view addSubview:_dataSamplingViewCtrl.view];
}

// go to help page
- (IBAction)switchToHelpPage:(id)sender {
    [self.view addSubview:_helpPageViewCtrl.view];
}

// change speech rate
- (IBAction)speechRateChanged:(UISegmentedControl *)sender {
    _isSpeechFast = (int)sender.selectedSegmentIndex > 0 ? true : false;
}

- (IBAction)speechOnAndOff:(UISwitch *)sender {
    _isSpeechEnabled = [sender isOn];
}

- (IBAction)clickOnAndOff:(UISwitch *)sender {
    _isClickEnabled = [sender isOn];
}

// new topo map loaded
- (void)topoMapLoaded:(TopoMap *)topoMap withMapDataString:(NSString *)dataStr{
    _topoMap = topoMap;
    NSArray *locations = [_topoMap getAllLocationNamesOnMap];
    [_allFromLocationName removeAllObjects];
    [_allToLocationName removeAllObjects];
    for (NSString *name in locations) {
        [_allFromLocationName addObject:name];
        [_allToLocationName addObject:name];
    }
    if ([_allFromLocationName count] > 0 && [_allToLocationName count] > 0) {
        _fromNodeName = [_allFromLocationName objectAtIndex:0];
        _toNodeName = [_allToLocationName objectAtIndex:0];
        [_allFromLocationName addObject:NSLocalizedString(@"currentLocation", @"Current Location")];
    } else {
        _fromNodeName = nil;
        _toNodeName = nil;
    }
    
    [_fromPicker reloadAllComponents];
    [_toPicker reloadAllComponents];
    if (_isWebViewLoaded) {
        NSString *cmd = [NSString stringWithFormat:@"setMapData(%@)", dataStr];
        [_navFuncViewCtrl runCmdWithString:cmd];
    } else {
        _mapDataString = dataStr;
    }
}

// new topo map loaded
- (void)logToSimulate:(NSString *)logName {
    _startNavButton.enabled = false;
    [_navLogViewCtrl.view removeFromSuperview];

    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    [_navMachine simulateNavigationOnTopoMap:_topoMap usingLogFileWithPath: [documentsPath stringByAppendingPathComponent:logName] usingBeaconsWithUUID:[_topoMap getUUIDString] withSpeechOn:_isSpeechEnabled withClickOn:_isClickEnabled withFastSpeechOn:_isSpeechFast];
}

@end
