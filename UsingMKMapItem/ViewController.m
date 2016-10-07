//
//  ViewController.m
//  UsingMKMapItem
//
//  Created by devzkn on 07/10/2016.
//  Copyright © 2016 DevKevin. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *startLocationTextField;
@property (weak, nonatomic) IBOutlet UITextField *endLocationTextField;
/** 用于反地理编码*/
@property (nonatomic,strong) CLGeocoder *geoCoder;

@end

@implementation ViewController

- (CLGeocoder *)geoCoder{
    if (nil == _geoCoder) {
        CLGeocoder *tmpView = [[CLGeocoder alloc]init];
        _geoCoder = tmpView;
    }
    return _geoCoder;
}

- (MKMapItem*) getMKMapItemClPlaceMark:(CLPlacemark*)clPlaceMark{
    MKPlacemark *startPlaceMark = [[MKPlacemark alloc]initWithPlacemark:clPlaceMark];
    MKMapItem *startMapItem = [[MKMapItem alloc]initWithPlacemark:startPlaceMark];
    return startMapItem;
}
#define weakSelf(weakSelf)  __weak __typeof(&*self)weakSelf = self;


- (IBAction)go:(UIButton *)sender {
    NSString *startStr =self.startLocationTextField.text;
    NSString *endStr =self.endLocationTextField.text;
    if (startStr.length == 0 || endStr.length == 0) {
        return;
    }
    //需要发起网络请求数据，异步处理
    weakSelf(weakSelf);
    /** 知识点：
     1>block会在定义那一刻，直接拿到外部的局部变量task的值。以后block中局部变量task的值就固定不变
     2>block中 对被————block修饰的变量的一直引用
     3》block中 对被————static修饰的变量的一直引用；对全局变量、成员变量也是能一致引用*/
    [self.geoCoder geocodeAddressString:startStr completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
        if (placemarks.count == 0) {
            return ;
        }
        CLPlacemark *startPlaceMark =   (CLPlacemark*)[placemarks firstObject];
        //进一步获取endPlaceMark
        [self.geoCoder geocodeAddressString:endStr completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
            if (placemarks.count == 0) {
                return ;
            }
            CLPlacemark *endPlaceMark =   (CLPlacemark*)[placemarks firstObject];
            //开始导航
            [weakSelf startNavigateWithStartCLPlacemark:startPlaceMark endPlacemark:endPlaceMark];
        }];
    }];
}




- (void)startNavigateWithStartCLPlacemark:(CLPlacemark*)startPlacemark  endPlacemark:(CLPlacemark*)endPlacemark{
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:[self getMKMapItemClPlaceMark:startPlacemark]];
    [items addObject:[self getMKMapItemClPlaceMark:endPlacemark]];
    /**
     Constants
     MKLaunchOptionsDirectionsModeKey
     MKLaunchOptionsMapTypeKey
     MKLaunchOptionsMapCenterKey
     MKLaunchOptionsMapSpanKey
     MKLaunchOptionsShowsTrafficKey
     MKLaunchOptionsCameraKey*/
    NSMutableDictionary *launchOptions = [NSMutableDictionary dictionary];//Launch Options Dictionary Keys
    launchOptions[MKLaunchOptionsMapTypeKey] = @(MKMapTypeStandard);
    launchOptions[MKLaunchOptionsShowsTrafficKey] = @YES;
    launchOptions[MKLaunchOptionsDirectionsModeKey] = MKLaunchOptionsDirectionsModeDriving;

    
    [MKMapItem openMapsWithItems:items launchOptions:launchOptions];
}


@end
