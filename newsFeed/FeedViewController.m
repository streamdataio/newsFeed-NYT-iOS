//
//  ViewController.m
//  newsFeed
//
//  Created by Thibault Devillers on 03/08/15.
//  Copyright (c) 2015 Streamdata.io. All rights reserved.
//

#import "FeedViewController.h"
#import "JSONTools.h"
#import "TRVSEventSource.h"
#import "NewsTableViewCell.h"
#import "DetailsViewController.h"

// Queue for asynchronous images loading
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

// News feed URL called by the event source
// ATTENTION!! You need to replace YOUR_NYT_API_KEY with your news feed API key from NYT Developers page
// and YOUR_STREAMDATA_APP_TOKEN with your Streamdata app token from Streamdata.io
static NSString * const NEWSFEED_URL = @"https://streamdata.motwin.net/http://api.nytimes.com/svc/news/v3/content/all/all.json?api-key=YOUR_NYT_API_KEY&X-Sd-Token=YOUR_STREAMDATA_APP_TOKEN";

// Specific TableView constants
static const float TABLEVIEW_SECTION_HEADER_HEIGHT = 22;
static const float TABLEVIEW_SECTION_HEADER_LABEL_SPACING = 22;
static const float TABLEVIEW_CELL_HEIGHT = 46;
static const float TABLEVIEW_CELL_HEIGHT_SPACING = 17;
static const float WEBVIEW_HEIGHT = 200;

@interface FeedViewController ()
{
    NSURL *URL;                         // URL for the API request
    TRVSEventSource *event;             // Server Sent Event Client

    NSMutableDictionary *dataObject;    // Json object as an Array
    NSMutableArray *dataResults;        // Json results as an Array
    NSNumber *resultId;                 // Result ID
    NSString *resultStatus;             // Result Status

    // Displayed news feed data
    NSNumber *currentResultId;
    NSMutableArray *currentSections;
    NSMutableArray *currentFeed;
    NSMutableDictionary *currentFeedBySection;
    
    // Last update timer data
    NSDate *lastUpdateDate;
    NSTimer *lastUpdateTimer;

    // Data for the loading alert view
    UIAlertView *alertView;
    UIActivityIndicatorView *activityIndicatorView;

    // Global boolean variables
    BOOL alertShowing;
    BOOL showTableBySection;
    BOOL newResult;
    BOOL detailsShowing;
    BOOL reopenEvent;
    
    float titleHeight;
}

@end

@implementation FeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Handling app state transitions to Background and Foreground
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnteredBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnteredForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTerminated) name:UIApplicationWillTerminateNotification object:nil];
    
    // Initialize the 2 TableViews
    titleHeight = 0;
    UINib *cellNib = [UINib nibWithNibName:@"NewsTableViewCell" bundle:nil];
    [self.feedTableView registerNib:cellNib forCellReuseIdentifier:@"tableViewCell"];
    [self.feedBySectionTableView registerNib:cellNib forCellReuseIdentifier:@"tableViewCell"];
    self.feedTableView.hidden = NO;
    self.feedBySectionTableView.hidden = YES;
    showTableBySection = NO;
    [self.switchButton setImage:[UIImage imageNamed:@"sections.png"] forState:UIControlStateNormal];
    
    newResult = NO;
    currentResultId = 0;
    detailsShowing = NO;
    reopenEvent = NO;
    
    // Initialize the loading alert view
    alertView = [[UIAlertView alloc] initWithTitle:@"Loading news" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
    activityIndicatorView = [[UIActivityIndicatorView alloc]
                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [alertView setValue:activityIndicatorView forKey:@"accessoryView"];
    
    // Display the loading alert view
    [activityIndicatorView startAnimating];
    [alertView show];
    alertShowing = YES;
    
    // Initialize the TRVSEventSource event with url string
    URL = [NSURL URLWithString:NEWSFEED_URL];
    event = [[TRVSEventSource alloc] initWithURL:URL];
    event.delegate = self;

    // Open the event
    [event open];
    
    // Initiate the call to the Streamdata service in the JSON WebView
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:requestObj];
    self.webView.delegate = self;
    
    // Hide all of the WebView but 1px (+1px separator image) before initial load
    // in order to apply specific JavaScript functions when the view starts loading
    self.webViewHeight.constant = 2;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TRVSEventSourceDelegate

- (void)eventSource:(TRVSEventSource *)eventSource didReceiveEvent:(TRVSServerSentEvent *)anEvent
{
    //NSLog(@"%@", anEvent.data);
    NSLog(@"New data received");

    newResult = NO;
    BOOL eventClosed = NO;

    NSError *e;
    if([anEvent.event isEqualToString:@"data"]==TRUE)   // if event of type "data"
    {
        NSLog(@"Global data type");
        
        // Reading data from JSON
        dataObject = [NSJSONSerialization JSONObjectWithData:anEvent.data options:NSJSONReadingMutableContainers error:&e];
        
        if (e != NULL)
        {
            NSLog(@"Error reading data from JSON : %@", e);
            eventClosed = YES;
        }
        else
        {
            resultStatus = [dataObject objectForKey:@"status"];
            if ([resultStatus isEqualToString:@"OK"])
            {
                resultId = [dataObject objectForKey:@"num_results"];
                NSLog(@"resultId = %@", resultId);
                if (resultId > currentResultId)
                { newResult = YES; }
            }
            else
            {
                NSLog(@"Data status NOK : %@", dataObject);
                eventClosed = YES;
            }
        }
    }
    else if ([anEvent.event isEqualToString:@"patch"]==TRUE)    // if event of type "patch"
    {
        NSLog(@"Patch type");
        //eventClosed = YES; // Uncomment to test event reopening
        
        // Reading data from JSON
        NSArray *patch =[NSJSONSerialization JSONObjectWithData:anEvent.data options:NSJSONReadingMutableContainers error:&e];
        
        if (e != NULL)
        {
            NSLog(@"Error reading patch from JSON : %@", e);
            eventClosed = YES;
        }
        else
        {
            // Applying patch to data
            @try
            { [JSONPatch applyPatches:patch toCollection:dataObject]; }
            @catch (NSException *exception)
            {
                NSLog(@"Exception while applying patch : %@", exception.name);
                NSLog(@"Exception details : %@", exception.reason);
                eventClosed = YES;
            }
            
            if (!eventClosed)
            {
                NSLog(@"Patch applied to data object");
                //NSLog(@"Data : %@", dataObject);
                
                resultStatus = [dataObject objectForKey:@"status"];
                if ([resultStatus isEqualToString:@"OK"])
                {
                    resultId = [dataObject objectForKey:@"num_results"];
                    NSLog(@"resultId = %@", resultId);
                    if (resultId > currentResultId)
                    { newResult = YES; }
                }
                else
                { NSLog(@"Data status NOK : %@", anEvent.data); }
            }
        }
    }
    else if ([anEvent.event isEqualToString:@"error"]==TRUE)    // if event of type "error"
    {
        NSLog(@"Error type");
        NSMutableDictionary *errorObject = [NSJSONSerialization JSONObjectWithData:anEvent.data options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"Error : %@", errorObject);
        eventClosed = YES;
    }
    else    // if event of unknown type
    {
        NSLog(@"Unknown event type  : %@", anEvent.event);
        NSMutableDictionary *errorObject = [NSJSONSerialization JSONObjectWithData:anEvent.data options:NSJSONReadingMutableContainers error:&e];
        NSLog(@"Unknown data : %@", errorObject);
        eventClosed = YES;
    }
    
    // if event needs to be closed (error or exception encoutered)
    if (eventClosed)
    {
        newResult = NO;
        reopenEvent = YES;
        NSLog(@"Event closing");
        [event close];
        
        if (alertShowing)
        {
            [activityIndicatorView stopAnimating];
            [alertView dismissWithClickedButtonIndex:-1 animated:YES];
            alertShowing = NO;
        }
    }
    
    // if a new result has arrived that needs updating tables
    if (newResult)
    {
        NSLog(@"News feed update started");
        if ( (!alertShowing) && (!detailsShowing) )
        {
            [activityIndicatorView startAnimating];
            [alertView show];
            alertShowing = YES;
        }
        
        dataResults = [dataObject objectForKey:@"results"];
        currentResultId = resultId;
        
        currentFeed = [[NSMutableArray alloc] init];
        currentSections = [[NSMutableArray alloc] init];
        currentFeedBySection = [[NSMutableDictionary alloc] init];
        for (NSDictionary *news in dataResults)
        {
            NewsItem *newsItem = [[NewsItem alloc] initWithJSONDictionary:news];
            [currentFeed addObject:newsItem];
            
            if (![currentSections containsObject:newsItem.section])
            {
                [currentSections addObject:newsItem.section];
                NSMutableArray *newItem = [[NSMutableArray alloc] init];
                [newItem addObject:newsItem];
                [currentFeedBySection setObject:newItem forKey:newsItem.section];
            }
            else
            {
                [(NSMutableArray*)[currentFeedBySection objectForKey:newsItem.section] addObject:newsItem];
            }
        }
        
        // Refresh the content of both TableViews with new result
        NSLog(@"Refresh TableViews");
        [self.feedTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        [self.feedBySectionTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];

        // Start last update timer if needed & reset last update time
        lastUpdateDate = [NSDate date];
        if (lastUpdateTimer == nil)
        {
            lastUpdateTimer = [NSTimer timerWithTimeInterval:1.0 target:self
                                        selector:@selector(updateTimer:) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:lastUpdateTimer forMode:NSDefaultRunLoopMode];
        }
    }
    else
    {
        NSLog(@"No news feed update");
    }
    
    //[self webViewGotoBottom:self.webView];
}

- (void)eventSourceDidOpen:(TRVSEventSource *)eventSource
{
    NSLog(@"Event did open");
    
    if (reopenEvent)
    { reopenEvent = NO; }
}

- (void)eventSourceDidClose:(TRVSEventSource *)eventSource
{
    NSLog(@"Event did close");
    
    // Reopen the closed event if needed
    if (reopenEvent)
    {
        NSLog(@"Event reopening");
        event = [event initWithURL:URL];
        [event open];
    }
}

- (void)eventSource:(TRVSEventSource *)eventSource didFailWithError:(NSError *)error
{
    NSLog(@"Event failed with error : %@", error);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Set number of sections for both TableViews
    if (tableView == self.feedBySectionTableView)
    { return [currentSections count]; }
    else
    { return 1; }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Set number of rows in section for both TableViews
    if (tableView == self.feedBySectionTableView)
    {
        NSString *sectionTitle = [currentSections objectAtIndex:section];
        NSMutableArray *sectionArray = [currentFeedBySection objectForKey:sectionTitle];
        return [sectionArray count];
    }
    else
    { return [dataResults count]; }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.feedBySectionTableView)
    {
        // Create custom view to display section header
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, TABLEVIEW_SECTION_HEADER_HEIGHT)];
        
        // Initialize the section header label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(TABLEVIEW_SECTION_HEADER_LABEL_SPACING, 0, tableView.frame.size.width - TABLEVIEW_SECTION_HEADER_LABEL_SPACING, TABLEVIEW_SECTION_HEADER_HEIGHT)];
        [label setFont:[UIFont boldSystemFontOfSize:15]];
        [label setText:[currentSections objectAtIndex:section]];
        [label setTextColor:[UIColor whiteColor]];

        // Add label to custom view
        [view addSubview:label];
        [view setBackgroundColor:[UIColor darkGrayColor]];

        return view;
    }
    else
    { return nil; }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCell" forIndexPath:indexPath];
    
    // Get specific news item to display in cell
    NewsItem *newsItem;
    if (tableView == self.feedBySectionTableView)
    {
        NSString *sectionTitle = [currentSections objectAtIndex:indexPath.section];
        NSMutableArray *sectionArray = [currentFeedBySection objectForKey:sectionTitle];
        newsItem = [sectionArray objectAtIndex:indexPath.row];
    }
    else
    { newsItem = [currentFeed objectAtIndex:indexPath.row]; }

    // Set the default thumbnail image
    cell.newsImage.image = [UIImage imageNamed:@"noImage.png"];
    
    // If the news item has a thumbnail image URL, asynchronously load and display the image
    if (newsItem.thumbnail_standard.length > 0)
    {
        dispatch_async(kBgQueue, ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:newsItem.thumbnail_standard]];
            if (imgData)
            {
                UIImage *image = [UIImage imageWithData:imgData];
                if (image)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NewsTableViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) { updateCell.newsImage.image = image; }
                    });
                }
            }
        });
    }

    // Hide & display correct labels depending on TableView
    if (tableView == self.feedBySectionTableView)
    {
        cell.newsSection.hidden = YES;
        cell.newsTitle.hidden = YES;
        cell.newsBySectionTitle.text = newsItem.title;
    }
    else
    {
        cell.newsBySectionTitle.hidden = YES;
        
        // Set news section label text
        cell.newsSection.text = newsItem.section;
        
        // Get initial news title label frame
        CGRect initLabelFrame = cell.newsTitle.frame;
        //NSLog(@"init label size = %f - %f", initLabelFrame.size.width, initLabelFrame.size.height);

        // Set news title label text & type
        cell.newsTitle.lineBreakMode = NSLineBreakByWordWrapping;
        cell.newsTitle.numberOfLines = 0;
        cell.newsTitle.text = newsItem.title;
        
        // Adapt news title label frame to text
        CGRect labelRect = [cell.newsTitle.text
                                boundingRectWithSize:CGSizeMake(initLabelFrame.size.width, CGFLOAT_MAX)
                                options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName:cell.newsTitle.font} context:nil];
        cell.newsTitle.frame = CGRectMake(initLabelFrame.origin.x, initLabelFrame.origin.y, initLabelFrame.size.width, fmax(initLabelFrame.size.height, labelRect.size.height));
        //NSLog(@"label size = %f - %f", cell.newsTitle.frame.size.width, cell.newsTitle.frame.size.height);

        // Save news title label height to adapt cell height in method "heightForRowAtIndexPath"
        titleHeight = cell.newsTitle.frame.size.height;
    }

    return cell;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Close the alert view if visible at end of loading the tableview
    if ( (alertShowing) && ([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row) )
    {
        NSLog(@"Data loaded");
        [activityIndicatorView stopAnimating];
        [alertView dismissWithClickedButtonIndex:-1 animated:YES];
        alertShowing = NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // Set section header height for both TableViews
    if (tableView == self.feedBySectionTableView)
    { return TABLEVIEW_SECTION_HEADER_HEIGHT; }
    else
    { return 1; }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Adapt the cell height to the news title label content
    if (titleHeight > 0)
    {
        float cellHeight = fmax((titleHeight + TABLEVIEW_CELL_HEIGHT_SPACING), TABLEVIEW_CELL_HEIGHT);
        //NSLog(@"cellHeight = %f", cellHeight);
        titleHeight = 0;
        return cellHeight;
    }

    return TABLEVIEW_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Invoke the segue to open the news details view
    [self performSegueWithIdentifier:@"ShowDetails" sender:self];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // Wait 5s when WebView starts loading before calling selector method
    [self performSelector:@selector(webViewGotoBottom:) withObject:webView afterDelay:5.0];
}

- (void)webViewGotoBottom:(UIWebView *)webView
{
    // Perform some JavaScript changes to the WebView content on initial load
    NSString *jsString;
    
    // Change the background color of the WebView content to black
    jsString = [NSString stringWithFormat:@"document.getElementsByTagName('pre')[0].style.backgroundColor = 'black'"];
    [webView stringByEvaluatingJavaScriptFromString:jsString];
    
    // Change the font color of the WebView content to white
    jsString = [NSString
                stringWithFormat:@"document.getElementsByTagName('pre')[0].style.color = 'white'"];
    [webView stringByEvaluatingJavaScriptFromString:jsString];
    
    // Change the font size of the WebView content
    jsString = [NSString
                stringWithFormat:@"document.getElementsByTagName('pre')[0].style.fontSize = '11px'"];
    [webView stringByEvaluatingJavaScriptFromString:jsString];

    // Scroll down to the bottom of the WebView atfer initial load
    NSInteger height = [[webView
                         stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] intValue];
    jsString = [NSString stringWithFormat:@"window.scrollBy(0, %ld);", (long)height];
    [webView stringByEvaluatingJavaScriptFromString:jsString];
    
    //Hide the WebView after the changes are done on initial load
    //self.webViewHeight.constant = 1;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowDetails"])
    {
        // Get specific news item from selected cell
        NewsItem *newsItem;
        if (showTableBySection)
        {
            NSIndexPath *selectedCellIndexPath = [self.feedBySectionTableView indexPathForSelectedRow];
            NSString *sectionTitle = [currentSections objectAtIndex:selectedCellIndexPath.section];
            NSMutableArray *sectionArray = [currentFeedBySection objectForKey:sectionTitle];
            newsItem = [sectionArray objectAtIndex:selectedCellIndexPath.row];
        }
        else
        { newsItem = [currentFeed objectAtIndex:[self.feedTableView indexPathForSelectedRow].row]; }
        
        // Pass selected news item to destination view controller
        DetailsViewController *destViewController = segue.destinationViewController;
        destViewController.newsItem = newsItem;
        detailsShowing = YES;
        
        // Display news details view
        //[self.navigationController pushViewController:destViewController animated:YES];
    }
}

- (IBAction)unwindToFeedView:(UIStoryboardSegue *)segue
{
    NSLog(@"unwindToFeedView");
    detailsShowing = NO;
    
    // Unselect the previously selected cell when coming back from news details view
    if (showTableBySection)
    { [self.feedBySectionTableView deselectRowAtIndexPath:
            [self.feedBySectionTableView indexPathForSelectedRow] animated: YES]; }
    else
    { [self.feedTableView deselectRowAtIndexPath:
            [self.feedTableView indexPathForSelectedRow] animated: YES]; }
}

- (void)handleEnteredBackground
{
    NSLog(@"App entering background");

    // Close the event when entering background mode
    reopenEvent = NO;
    NSLog(@"Event closing");
    [event close];
    
    // Close the Streamdata.io request connection in the JSON WebView
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    
    // Close the alert view if visible
    if (alertShowing)
    {
        [activityIndicatorView stopAnimating];
        [alertView dismissWithClickedButtonIndex:-1 animated:YES];
        alertShowing = NO;
    }
}

- (void)handleEnteredForeground
{
    NSLog(@"App entering foreground");

    // Reopen the event when entering foreground mode
    NSLog(@"Event reopening");
    event = [event initWithURL:URL];
    [event open];
    
    // Reload the call to the Streamdata.io service in the JSON WebView & hide the WebView
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:URL];
    [self.webView loadRequest:requestObj];
}

- (void)handleTerminated
{
    NSLog(@"App terminating");
    
    // Close the event when terminating the app
    reopenEvent = NO;
    NSLog(@"Event closing");
    [event close];
    
    // Close the Streamdata.io request connection in the JSON WebView
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}

- (void)updateTimer:(NSTimer *)timer
{
    // Calculate the time interval since last update
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:lastUpdateDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    // Format the time interval
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    [dateFormatter setDateFormat:@"mm:ss"];

    // Display the updated time interval in the label
    NSString *timeString = [dateFormatter stringFromDate:timerDate];
    self.timeLabel.text = timeString;
}

- (IBAction)clickSwitchButton:(id)sender
{
    // When clicking the Switch button, switch between the 2 TableViews
    if (showTableBySection)
    {
        self.feedTableView.hidden = NO;
        self.feedBySectionTableView.hidden = YES;
        showTableBySection = NO;
        [self.switchButton setImage:[UIImage imageNamed:@"sections.png"] forState:UIControlStateNormal];
    }
    else
    {
        self.feedTableView.hidden = YES;
        self.feedBySectionTableView.hidden = NO;
        showTableBySection = YES;
        [self.switchButton setImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)clickJsonButton:(id)sender
{
    // When clicking the JSON button, display or hide the JSON WebView
    if (self.webViewHeight.constant == 2)
    { self.webViewHeight.constant = WEBVIEW_HEIGHT; }
    else
    { self.webViewHeight.constant = 2; }
}

@end
