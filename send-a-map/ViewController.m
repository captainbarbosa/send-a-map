// This is just a test

#import "ViewController.h"
#import <Mapbox/Mapbox.h>
#import "CustomDrawingView.h"

@import MapboxStatic;

@interface ViewController () <MGLMapViewDelegate, UIGestureRecognizerDelegate, CustomDrawingViewDelegate>

@property (strong, nonatomic) MGLMapView *mapView;
@property (strong, nonatomic) MGLMapSnapshotter *snapshotter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureMapView];
    
    // TODO - add draw arrow with CAShapeLayer instead to rotate & change fill
    // when user location is being tracked
    UIImage *arrowImage = [UIImage imageNamed:@"arrow"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:arrowImage style:UIBarButtonItemStylePlain target:self action:@selector(toggleUserLocation:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didTapButton:)];
}

- (void)configureMapView {
    // create a map view
    self.mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds styleURL:MGLStyle.streetsStyleURL];
    
    // constrain it to the edges
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // add it to the view hierarchy
    [self.view addSubview:self.mapView];
    self.mapView.delegate = self;
    
    UIButton *toggleDrawingButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 120, 140, 60)];
    [toggleDrawingButton setTitle:@"Enable drawing" forState:UIControlStateNormal];
    toggleDrawingButton.backgroundColor = UIColor.greenColor;
    [toggleDrawingButton addTarget:self action:@selector(toggleDrawing:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:toggleDrawingButton];
}

-(void)toggleDrawing:(UIButton *)sender {
    // If user interaction is disabled, enable it
    if (self.mapView.userInteractionEnabled == NO) {
        self.mapView.userInteractionEnabled = YES;
        NSLog(@"❌ user interaction enabled");
    } else {
        // Otherwise, disable it
        self.mapView.userInteractionEnabled = NO;
        NSLog(@"✅ user interaction disabled");
        
        CustomDrawingView *drawingView = [[CustomDrawingView alloc] initWithFrame:self.mapView.frame];
        drawingView.delegate = self;
        [self.view addSubview:drawingView];
    }
}

-(void)toggleUserLocation:(UIBarButtonItem *)button {
    switch (self.mapView.userTrackingMode) {
        case MGLUserTrackingModeNone:
            self.mapView.userTrackingMode = MGLUserTrackingModeFollow;
            break;
        case MGLUserTrackingModeFollow:
            self.mapView.showsUserLocation = NO;
            break;
        default:
            break;
    }
}

- (void)didTapButton:(UIBarButtonItem *)button {
    
    button.enabled = NO;
    
    // DIsplay loading indicator while beginning snapshot process
    UIApplication.sharedApplication.networkActivityIndicatorVisible = YES;
    
    // Create snapshot options with current camera/zoom/bounds
    MGLMapSnapshotOptions *options = [[MGLMapSnapshotOptions alloc] initWithStyleURL:self.mapView.styleURL camera:self.mapView.camera size:CGSizeMake(512, 512)];
    options.zoomLevel = self.mapView.zoomLevel;
    options.coordinateBounds = self.mapView.visibleCoordinateBounds;
    
    MBSnapshotCamera *snapshotCamera = [MBSnapshotCamera cameraLookingAtCenterCoordinate:self.mapView.centerCoordinate zoomLevel:self.mapView.zoomLevel];
    
    MBSnapshotOptions *snapshotOptions = [[MBSnapshotOptions alloc] initWithStyleURL:self.mapView.styleURL camera:snapshotCamera size:self.mapView.frame.size];
    
    MBSnapshot *snapshot = [[MBSnapshot alloc] initWithOptions:snapshotOptions];
    
    [snapshot imageWithCompletionHandler:^(UIImage * _Nullable image, NSError * _Nullable error) {
        if (error != nil) {
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                message:@"Could not generate image"
                                                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [errorAlert addAction:defaultAction];
            [self presentViewController:errorAlert animated:YES completion:nil];
        }

        // Re-enable the snapshot button if successful
        UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
        
        // Stop the loading indicator
        button.enabled = YES;
        
        [self snapshotterDidCompleteWithImage:image];
    }];
}

- (void)snapshotterDidCompleteWithImage:(UIImage *)image {
    // Let go of the snapshotter to prevent memory usage
    self.snapshotter = nil;
    
    // Display a share action sheet
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
    activityViewController.popoverPresentationController.sourceView = self.view;
    [self presentViewController:activityViewController animated:true completion:nil];
}

-(void)didFinishDrawing{
    NSLog(@"Finished drawing");
}

@end


