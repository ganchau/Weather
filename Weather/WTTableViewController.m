//
//  WTTableViewController.m
//  Weather
//
//  Created by Scott on 26/01/2013.
//  Updated by Joshua Greene 16/12/2013.
//
//  Copyright (c) 2013 Scott Sherwood. All rights reserved.
//

#import "WTTableViewController.h"
#import "WeatherAnimationViewController.h"
#import "NSDictionary+weather.h"
#import "NSDictionary+weather_package.h"
#import "Constants.h"
#import <UIImageView+AFNetworking.h>


@interface WTTableViewController ()
@property (nonatomic, strong) NSDictionary *weather;
@property (nonatomic, strong) NSMutableDictionary *currentDictionary;   // current section being parsed
@property (nonatomic, strong) NSMutableDictionary *xmlWeather;          // completed parsed xml response
@property (nonatomic, strong) NSString *elementName;
@property (nonatomic, strong) NSMutableString *outString;
@end

@implementation WTTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.toolbarHidden = NO;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"WeatherDetailSegue"]){
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        WeatherAnimationViewController *wac = (WeatherAnimationViewController *)segue.destinationViewController;
        
        NSDictionary *w;
        switch (indexPath.section) {
            case 0: {
                w = self.weather.currentCondition;
                break;
            }
            case 1: {
                w = [self.weather upcomingWeather][indexPath.row];
                break;
            }
            default: {
                break;
            }
        }
        wac.weatherDictionary = w;
    }
}

#pragma mark - Actions

- (IBAction)clear:(id)sender
{
    self.title = @"";
    self.weather = nil;
    [self.tableView reloadData];
}

- (IBAction)jsonTapped:(id)sender
{
    // step 1
    NSString *urlString = [NSString stringWithFormat:@"%@weather.php?format=json", BaseURLString];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    // step 2
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // step 3
        self.weather = (NSDictionary *)responseObject;
        self.title = @"JSON Retrieved";
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // step 4
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error Retrieving Weather"
                                                                                 message:error.localizedDescription
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       [self dismissViewControllerAnimated:YES completion:nil];
                                                   }];
        
        [alertController addAction:ok];
        
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
    }];
    
    // step 5
    [operation start];
}

- (IBAction)plistTapped:(id)sender
{
    NSString *urlString = [NSString stringWithFormat:@"%@weather.php?format=plist", BaseURLString];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    
    // use the property list response serializer
    operation.responseSerializer = [AFPropertyListResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.weather = (NSDictionary *)responseObject;
        self.title = @"PLIST Retrieved";
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error Retrieving Weather"
                                                                                 message:error.localizedDescription
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       [self dismissViewControllerAnimated:YES completion:nil];
                                                   }];
        
        [alertController addAction:ok];
        
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
    }];
    
    [operation start];
}

- (IBAction)xmlTapped:(id)sender
{
    NSString *urlString = [NSString stringWithFormat:@"%@weather.php?format=xml", BaseURLString];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    
    // use the xml response serializer
    operation.responseSerializer = [AFXMLParserResponseSerializer serializer];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSXMLParser *xmlParser = (NSXMLParser *)responseObject;
        [xmlParser setShouldProcessNamespaces:YES];
        xmlParser.delegate = self;
        [xmlParser parse];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error Retrieving Weather"
                                                                                 message:error.localizedDescription
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       [self dismissViewControllerAnimated:YES completion:nil];
                                                   }];
        
        [alertController addAction:ok];
        
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
    }];
    
    [operation start];
}

- (IBAction)clientTapped:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"AFHTTPSessionManager"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"HTTP GET", @"HTTP POST", nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}



- (IBAction)apiTapped:(id)sender
{
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.weather) {
        return 0;
    }
    switch (section) {
        case 0: {
            return 1;
        }
        case 1: {
            NSArray *upcomingWeather = [self.weather upcomingWeather];
            return upcomingWeather.count;
        }
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WeatherCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *daysWeather = nil;
    
    switch (indexPath.section) {
        case 0: {
            daysWeather = [self.weather currentCondition];
            break;
        }
        case 1: {
            NSArray *upcomingWeather = [self.weather upcomingWeather];
            daysWeather = upcomingWeather[indexPath.row];
            break;
        }
        default:
            break;
    }
    
    cell.textLabel.text = [daysWeather weatherDescription];
    
    NSURL *url = [NSURL URLWithString:[daysWeather weatherIconURL]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
    
    __weak UITableViewCell *weakCell = cell;
    weakCell.imageView.alpha = 0;

    [cell.imageView setImageWithURLRequest:request
                          placeholderImage:placeholderImage
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       weakCell.imageView.image = image;
                                       [UIView animateWithDuration:0.3
                                                        animations:^{
                                                            weakCell.imageView.alpha = 1;
                                                            [self.view layoutIfNeeded];
                                                        }];
                                       [weakCell setNeedsLayout];
                                   }
                                   failure:nil];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
}

#pragma mark - XML parser delegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.xmlWeather = [NSMutableDictionary dictionary];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self.elementName = qName;
    
    if ([qName isEqualToString:@"current_condition"] ||
        [qName isEqualToString:@"weather"] ||
        [qName isEqualToString:@"request"]) {
        self.currentDictionary = [NSMutableDictionary dictionary];
    }
    self.outString = [NSMutableString string];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (!self.elementName) {
        return;
    }
    
    [self.outString appendFormat:@"%@", string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // step 1
    if ([qName isEqualToString:@"current_condition"] ||
        [qName isEqualToString:@"request"]) {
        self.xmlWeather[qName] = @[self.currentDictionary];
        self.currentDictionary = nil;
    }
    
    // step 2
    else if ([qName isEqualToString:@"weather"]) {
        // initialize the list of weather items if it doesn't exist
        NSMutableArray *array = self.xmlWeather[@"weather"] ?: [NSMutableArray array];
        
        // add the current weather object
        [array addObject:self.currentDictionary];
        
        // set the new array to the "weather" key on xmlWeather dictionary
        self.xmlWeather[@"weather"] = array;
        
        self.currentDictionary = nil;
    }
    
    // step 3
    else if ([qName isEqualToString:@"value"]) {
        // ignore value tags, they only appear in the two conditions below
    }
    
    // step 4
    else if ([qName isEqualToString:@"weatherDesc"] ||
             [qName isEqualToString:@"weatherIconUrl"]) {
        NSDictionary *dictionary = @{ @"value" : self.outString };
        NSArray *array = @[dictionary];
        self.currentDictionary[qName] = array;
    }
    
    // step 5
    else if (qName) {
        self.currentDictionary[qName] = self.outString;
    }
    
    self.elementName = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    self.weather = @{ @"data" : self.xmlWeather };
    self.title = @"XML Retrieved";
    [self.tableView reloadData];
}

#pragma mark = action sheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        // user pressed cancel button
        return;
    }
    
    // step 1
    NSURL *baseUrl = [NSURL URLWithString:BaseURLString];
    NSDictionary *params = @{ @"format" : @"json" };
    
    // step 2
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // step 3
    if (buttonIndex == 0) {
        [manager GET:@"weather.php"
          parameters:params
             success:^(NSURLSessionDataTask *task, id responseObject) {
                 self.weather = responseObject;
                 self.title = @"HTTP GET";
                 [self.tableView reloadData];
             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                                     message:[error localizedDescription]
                                                                    delegate:nil
                                                           cancelButtonTitle:@"Ok"
                                                           otherButtonTitles:nil];
                 [alertView show];
             }];
    }
    
    // step 4
    else if (buttonIndex == 1) {
        [manager POST:@"weather.php"
           parameters:params
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  self.weather = responseObject;
                  self.title = @"HTTP POST";
                  [self.tableView reloadData];
              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                                      message:[error localizedDescription]
                                                                     delegate:nil
                                                            cancelButtonTitle:@"Ok"
                                                            otherButtonTitles:nil];
                  [alertView show];
              }];
    }
}





























@end