//
//  ViewController.m
//  testing swiping
//
//  Created by Richard Kim on 5/21/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for updates and requests

#import "ViewController.h"
//#import "DraggableViewBackground.h"
#import "DraggableView.h"


static const int MAX_BUFFER_SIZE = 3; //%%% max number of cards loaded at any given time, must be greater than 1

//static const float CARD_HEIGHT = 386; //%%% height of the draggable card
//static const float CARD_WIDTH = 290; //%%% width of the draggable card

static const float CARD_INTERVAL_HEIGHT = 8.0F;
static const float CARD_INTERVAL_WIDTH = 4.0f;



@interface ViewController ()<DraggableViewDelegate> {
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    NSInteger numLoadedCardsCap;
    
    UIButton* menuButton;
    UIButton* messageButton;
    UIButton* checkButton;
    UIButton* xButton;
    
    float cardWidth, cardHeight;
    NSMutableArray *removedCards;
}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (retain,nonatomic)NSArray* exampleCardLabels; //%%% the labels the cards
@property (retain,nonatomic)NSMutableArray* allCards; //%%% the labels the cards
@end


@implementation ViewController
@synthesize exampleCardLabels;
@synthesize allCards;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
}


- (void) initData
{
    [self setupView];
    exampleCardLabels = [[NSArray alloc]initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7", @"8",@"9",@"10", nil]; //%%% placeholder for card-specific information
    loadedCards = [[NSMutableArray alloc] init];
    allCards = [[NSMutableArray alloc] init];
    removedCards = [[NSMutableArray alloc] init];
    cardsLoadedIndex = 0;
    
    
    cardWidth = self.contentView.frame.size.width;
    cardHeight = self.contentView.frame.size.height;
    NSLog(@" Card W, H = %f, %f", cardWidth, cardHeight);
    
    [self loadCards];
}

//%%% sets up the extra buttons on the screen
-(void)setupView
{
}



-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    
    int i = (int) index ;
    CGRect frame = CGRectMake(0,0,cardWidth,cardHeight);
    
    frame.origin.x += CARD_INTERVAL_WIDTH * i ;
    frame.origin.y += CARD_INTERVAL_HEIGHT * i * 3;
    frame.size.width -= 2 * CARD_INTERVAL_WIDTH * i;
    frame.size.height -= 2* CARD_INTERVAL_HEIGHT * i;
    
    DraggableView *draggableView = [[DraggableView alloc]initWithFrame:frame];
    [draggableView setBackgroundColor:[UIColor lightGrayColor]];
    
    draggableView.information.text = [exampleCardLabels objectAtIndex:index]; //%%% placeholder for card-specific information
    draggableView.delegate = self;
    return draggableView;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if([exampleCardLabels count] > 0) {
        numLoadedCardsCap =(([exampleCardLabels count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[exampleCardLabels count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        
        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
        for (int i = 0; i<[exampleCardLabels count]; i++) {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
            [allCards addObject:newCard];
            
            if (i<numLoadedCardsCap) {
                //%%% adds a small number of cards to be loaded
                [loadedCards addObject:newCard];
            }
        }
        
        //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        for (int i = 0; i<[loadedCards count]; i++) {
            if (i>0) {
                [self.contentView insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            } else {
                [self.contentView addSubview:[loadedCards objectAtIndex:i]];
            }
            cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
        }
    }
}

-(void)cardSwipedLeft:(UIView *)card;
{
    //do whatever you want with the card that was swiped
    //    DraggableView *c = (DraggableView *)card;
    
    [removedCards addObject:loadedCards[0]];
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self.contentView insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
    
    [self resizeLoadCards];

}

-(void)cardSwipedRight:(UIView *)card
{
    
    [removedCards addObject:loadedCards[0]];
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self.contentView insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
    [self resizeLoadCards];
}

//%%% when you hit the right button, this is called and substitutes the swipe
-(void)swipeRight
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}

//%%% when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView leftClickAction];
}


#pragma mark - Customize/ Resizing LoadCards after swiping
- (void) resizeLoadCards
{
    // Custom - After swiping, Resizing loadCards
    if (loadedCards.count > 0)
    {
        for (int i = 0; i < loadedCards.count; i++)
        {
            CGRect frame = CGRectMake(0, 0, cardWidth, cardHeight);
            frame.origin.x += CARD_INTERVAL_WIDTH * i;
            frame.origin.y += CARD_INTERVAL_HEIGHT * i * 3;
            frame.size.width -= 2 * CARD_INTERVAL_WIDTH * i;
            frame.size.height -= 2* CARD_INTERVAL_HEIGHT * i;
            
            DraggableView *loadCard = (DraggableView*)loadedCards[i];
            [loadCard setFrame:frame];
        }
    }
    
}
- (IBAction)onLeft:(id)sender {
    [self swipeLeft];
}

- (IBAction)onRight:(id)sender {
    [self swipeRight];
}

- (IBAction)onUndo:(id)sender
{
    if (removedCards.count == 0 )
        return;
    
    [loadedCards insertObject:[removedCards lastObject] atIndex:0];

    if (loadedCards.count > numLoadedCardsCap) {
        [loadedCards removeLastObject];        
        cardsLoadedIndex--;
    }
    [removedCards removeLastObject];
    
    if (loadedCards.count == 1) {
        [self.contentView addSubview:loadedCards[0]];
//        [self.contentView insertSubview:[loadedCards objectAtIndex:0] belowSubview:xButton];
    } else {
        [self.contentView insertSubview:[loadedCards objectAtIndex:0] aboveSubview:[loadedCards objectAtIndex:1]];
    }
    
    
    DraggableView *dragView = [loadedCards firstObject];
    CGPoint undoPoint = CGPointMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height/2);
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         dragView.center = undoPoint;
                         dragView.transform = CGAffineTransformMakeRotation(0);
                     }completion:^(BOOL complete){
                         [self resizeLoadCards];
                     }];
}
@end
