//
//  AMYMainTableViewController.m
//  DreamGame
//
//  Created by Amy Joscelyn on 1/19/16.
//  Copyright © 2016 Amy Joscelyn. All rights reserved.
//

#import "AMYMainTableViewController.h"
#import "AMYStoryDataStore.h"

@interface AMYMainTableViewController ()

//@property (nonatomic, strong) NSMutableArray *mainStorypoints;
//@property (nonatomic, strong) NSMutableArray *branchingOptions;
//@property (nonatomic, strong) NSMutableArray *choices;
//@property (nonatomic, strong) NSMutableArray *effects;
//@property (nonatomic) BOOL endingTriggered;

@property (nonatomic, strong) AMYStoryDataStore *dataStore;
@property (strong, nonatomic) Question *currentQuestion;
@property (strong, nonatomic) NSArray *sortedChoices;

@property (nonatomic) CGFloat textHue;

@end

@implementation AMYMainTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.dataStore = [AMYStoryDataStore sharedStoryDataStore];
    
    [self.dataStore fetchData];
    
    [self setCurrentQuestionOfStory:self.dataStore.playthrough.currentQuestion];
    //self.sortedChoices = [self.dataStore.currentQuestion.choiceOuts sortedArrayUsingDescriptors:@[self.dataStore.sortByStoryIDAsc]];
}

- (void)setCurrentQuestionOfStory:(Question *)currentQuestion
{
    _currentQuestion = currentQuestion;
    _sortedChoices = [currentQuestion.choiceOuts sortedArrayUsingDescriptors:@[self.dataStore.sortByStoryIDAsc]];
    
    _dataStore.playthrough.currentQuestion = currentQuestion;
    
    [_dataStore saveContext];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
        {
            return 1;
        }
        case 1:
        {
            NSInteger choiceOutsCount = self.currentQuestion.choiceOuts.count;
            if (choiceOutsCount > 0)
            {
                return choiceOutsCount;
            }
            else
            {
                return 1;
            }
        }
        default:
        {
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StoryCell" forIndexPath:indexPath];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSUInteger green = 230;
    CGFloat textHue = green/359.0;
    
    if (section == 0)
    {
        cell.textLabel.text = self.currentQuestion.content;
        cell.textLabel.textColor = [UIColor colorWithHue:self.textHue saturation:1.0 brightness:0.25 alpha:1.0];
        cell.textLabel.numberOfLines = 0;
        
        cell.detailTextLabel.hidden = YES;
        
        cell.userInteractionEnabled = NO;
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 45;
    }
    else if (section == 1)
    {
//        NSLog(@"there are %lu choices for this question", self.currentQuestion.choiceOuts.count);
//        NSLog(@"~~~~~~~~~sorted choices: %@", self.sortedChoices);
        
        if (self.sortedChoices.count > 0)
        {
            Choice *choice = self.sortedChoices[row];
//            NSLog(@"choice: %@", choice);
            
           /* if (choice.prerequisites.count > 0)
            {
                ZhuLi *zhuLi = [ZhuLi new];
                
                //                NSLog(@"CHOICE PREREQ: %@", choice.prerequisites);
                for (Prerequisite *prereq in choice.prerequisites)
                {
                    [zhuLi checkPrerequisite:prereq];
                }
            } */
            
            cell.textLabel.text = choice.content;
        }
        else if (self.currentQuestion.questionAfter)
        {//maybe this should be in section 3, and hide section 2?
            cell.textLabel.text = @"Continue";
        }
        else if ([self.currentQuestion.content isEqualToString:@"THE END."])
        {
            cell.textLabel.text = @"(tap to restart)";
        }
        else
        {
            cell.textLabel.text = @"You have reached a precarious end with no further content! (Hang here for a bit or tap to restart)";
        }
        
        cell.textLabel.textColor = [UIColor colorWithHue:textHue saturation:1.0 brightness:0.5 alpha:1.0];
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.hidden = YES;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = indexPath.section;
    NSUInteger indentation = 0;
    
    if (section)
    {
        indentation += 3;
    }
    return indentation;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) { return; }
    
    NSUInteger row = indexPath.row;
    
    /* ZhuLi *zhuLi = [ZhuLi new];
    
    if (self.currentQuestion.effects.count > 0)
    { //this takes care of effects the currentQuestion might incur
        for (Effect *thing in self.currentQuestion.effects)
        {
            [zhuLi doThe:thing];
        }
    } */
    
    if (self.currentQuestion.questionAfter)
    {
        [self setCurrentQuestionOfStory:self.currentQuestion.questionAfter];
    }
    else if (self.dataStore.playthrough.currentQuestion.choiceOuts.count > 0)
    {
        Choice *selectedChoice = self.sortedChoices[row];
        
        /* if (selectedChoice.effects.count)
        {
            for (Effect *thing in selectedChoice.effects)
            {
                if ([thing.stringValue isEqualToString:@""])
                {
                    Choice *selectedChoice = self.sortedChoices[row];
                    thing.stringValue = selectedChoice.content;
                }
                [zhuLi doThe:thing];
            }
        } */
        
        [self setCurrentQuestionOfStory:selectedChoice.questionOut];
    }
    else
    {
        [self setCurrentQuestionOfStory:self.dataStore.questions[0]];
        // go to next chapter or restart
        
        // below resets the properties
        //I don't have any properties that need to be changed yet; this is good for effect properties, mostly
        
        [_dataStore saveContext];
    }
    
    [self.tableView reloadData];
}

@end
