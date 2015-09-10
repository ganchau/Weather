//
//  WeatherHTTPClient.m
//  Weather
//
//  Created by Gan Chau on 9/9/15.
//  Copyright (c) 2015 Scott Sherwood. All rights reserved.
//

#import "WeatherHTTPClient.h"
#import "Constants.h"

@implementation WeatherHTTPClient

+ (WeatherHTTPClient *)sharedWeatherHTTPClient
{
    static WeatherHTTPClient *_sharedWeatherHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWeatherHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:WorldWeatherOnlineURLString]];
    });
    
    return _sharedWeatherHTTPClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}

- (void)updateWeatherAtLocation:(CLLocation *)location forNumberOfDays:(NSUInteger)number
{
    NSMutableDictionary *params = [@{} mutableCopy];
    params[@"num_of_days"] = @(number);
    params[@"q"] = [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude];
    params[@"format"] = @"json";
    params[@"key"] = WorldWeatherOnlineAPIKey;
    
    [self GET:@"weather.ashx"
   parameters:params
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if ([self.delegate respondsToSelector:@selector(weatherHTTPClient:didUpdateWithWeather:)]) {
              [self.delegate weatherHTTPClient:self didUpdateWithWeather:responseObject];
          }
      } failure:^(NSURLSessionDataTask *task, NSError *error) {
          if ([self.delegate respondsToSelector:@selector(weatherHTTPClient:didFailWithError:)]) {
              [self.delegate weatherHTTPClient:self didFailWithError:error];
          }
      }];
}
@end
