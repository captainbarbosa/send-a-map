//
//  CustomDrawingView.h
//  send-a-map
//
//  Created by Nadia Barbosa on 12/19/18.
//  Copyright © 2018 Nadia Barbosa. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface CustomDrawingView : UIView

@property (nonatomic, weak) id delegate;

@end

@protocol CustomDrawingViewDelegate
@required
-(void)didFinishDrawing;

@end

NS_ASSUME_NONNULL_END
