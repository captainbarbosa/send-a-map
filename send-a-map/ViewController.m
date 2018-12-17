// This is just a test

#import "ViewController.h"
#import <Mapbox/Mapbox.h>

@import MapboxStatic;

@interface ViewController () <MGLMapViewDelegate>

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


-(void)mapViewDidFinishLoadingMap:(MGLMapView *)mapView {
    
}

- (void)configureMapView {
    // create a map view
    self.mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds styleURL:MGLStyle.streetsStyleURL];
    
    //TODO: set ourselves up to be the mapView's delegate; don't enable snapshot button until style finished loading
    
    // constrain it to the edges
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // add it to the view hierarchy
    [self.view addSubview:self.mapView];
    self.mapView.delegate = self;
    
    //    UIView *greyMask = [[UIView alloc] initWithFrame:self.view.bounds];
    //    greyMask.backgroundColor  =[UIColor colorWithRed:0.961 green:0.957 blue:0.961 alpha:0.4];
    //    [self.view addSubview:greyMask];
    
    //    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(self.mapView.center.x - 150, self.mapView.center.y - 150, 300, 300)];
    //
    //    overlayView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    //    self.mapView.maskView = overlayView;
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
    
    
    self.snapshotter = [[MGLMapSnapshotter alloc] initWithOptions:options];
    
    // Start the snapshot process
    [self.snapshotter startWithCompletionHandler:^(MGLMapSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        // If an error occurs, display an alert
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
        
        [self snapshotterDidCompleteWithImage:snapshot.image];
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

@end


