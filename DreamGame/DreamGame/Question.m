//
//  Question.m
//
//
//  Created by Amy Joscelyn on 2/1/16.
//
//

#import "Question.h"
#import "Choice.h"

@implementation Question

+ (Question *)createQuestionFromCSVRow:(NSArray *)csvRow managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    Question *question = [NSEntityDescription insertNewObjectForEntityForName:@"Question" inManagedObjectContext:managedObjectContext];
    question.storyID = csvRow[0];
    question.comment = csvRow[1];
    // 2 is questionBefores
    // 3 is questionAfter
    // 4 is choiceIns
    // 5 is choiceOuts
    question.content = csvRow[6];
    
//    NSLog(@"Question: %@", question);
    return question;
}

- (NSString *)description
{
    NSMutableString *description = [[NSMutableString alloc] initWithString:@"Question - "];
    [description appendFormat:@"%@ - %@", self.storyID, self.comment];
    [description appendFormat:@"\n %@", self.content];
    
    return description;
}

@end
