//
//  STPTestAddressStore.m
//  StripeExample
//
//  Created by Jack Flintermann on 9/30/14.
//  Copyright (c) 2014 Stripe. All rights reserved.
//

#import "STPTestAddressStore.h"

@interface STPTestAddressStore()
@property(nonatomic)NSArray *allItems;
@end

@implementation STPTestAddressStore

@synthesize selectedItem;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.allItems = @[
                          @{
                              @"name": @"Apple HQ",
                              @"line1": @"1 Infinite Loop",
                              @"line2": @"",
                              @"city": @"Cupertino",
                              @"state": @"CA",
                              @"zip": @"95014",
                              @"country": @"US",
                              @"phone": @"888 555-1212",
                              },
                          @{
                              @"name": @"The White House",
                              @"line1": @"1600 Pennsylvania Ave NW",
                              @"line2": @"",
                              @"city": @"Washington",
                              @"state": @"DC",
                              @"zip": @"20500",
                              @"country": @"US",
                              @"phone": @"888 867-5309",
                              },
                          @{
                              @"name": @"Buckingham Palace",
                              @"line1": @"SW1A 1AA",
                              @"line2": @"",
                              @"city": @"London",
                              @"state": @"",
                              @"zip": @"",
                              @"country": @"UK",
                              @"phone": @"07 987 654 321",
                              },
                          ];
        self.selectedItem = self.allItems[0];
    }
    return self;
}

- (NSArray *)descriptionsForItem:(id)item {
    return @[item[@"name"], item[@"line1"]];
}

- (ABRecordRef)contactForSelectedItemObscure:(BOOL)obscure {
    id item = self.selectedItem;
    ABRecordRef record = ABPersonCreate();
    
    // address
    ABMutableMultiValueRef address = ABMultiValueCreateMutable(kABDictionaryPropertyType);
    CFStringRef keys[5];
    CFStringRef values[5];
    
    keys[0] = kABPersonAddressStreetKey;
    keys[1] = kABPersonAddressCityKey;
    keys[2] = kABPersonAddressStateKey;
    keys[3] = kABPersonAddressZIPKey;
    keys[4] = kABPersonAddressCountryKey;
    values[0] = obscure ? CFSTR("") : CFBridgingRetain(item[@"line1"]);
    values[1] = CFBridgingRetain(item[@"city"]);
    values[2] = CFBridgingRetain(item[@"state"]);
    values[3] = CFBridgingRetain(item[@"zip"]);
    values[4] = CFBridgingRetain(item[@"country"]);
    
    CFDictionaryRef aDict = CFDictionaryCreate(
                                               kCFAllocatorDefault,
                                               (void *)keys,
                                               (void *)values,
                                               5,
                                               &kCFCopyStringDictionaryKeyCallBacks,
                                               &kCFTypeDictionaryValueCallBacks
                                               );
    
    ABMultiValueIdentifier identifier;
    ABMultiValueAddValueAndLabel(address, aDict, kABHomeLabel, &identifier);
    CFRelease(aDict);
    ABRecordSetValue(record, kABPersonAddressProperty, address, nil);
    CFRelease(address);
    
    //add zip and country fields
    if (!obscure) {
        NSString *firstName = [self.selectedItem[@"name"] componentsSeparatedByString:@" "].firstObject;
        NSString *lastName = [self.selectedItem[@"name"] componentsSeparatedByString:@" "].lastObject;
        
        // phone
        ABMutableMultiValueRef phone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABRecordSetValue(record, kABPersonFirstNameProperty, CFBridgingRetain(firstName), nil);
        ABRecordSetValue(record, kABPersonLastNameProperty, CFBridgingRetain(lastName), nil);
        ABMultiValueAddValueAndLabel(phone, CFBridgingRetain(self.selectedItem[@"phone"]),
                                     kABPersonPhoneMainLabel, nil);
        ABRecordSetValue(record, kABPersonPhoneProperty, phone, nil);
        
        // email
        ABMutableMultiValueRef email = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABRecordSetValue(record, kABPersonFirstNameProperty, CFBridgingRetain(firstName), nil);
        ABRecordSetValue(record, kABPersonLastNameProperty, CFBridgingRetain(lastName), nil);
        ABMultiValueAddValueAndLabel(email, CFBridgingRetain(self.selectedItem[@"email"]),
                                     kABPersonPhoneMainLabel, nil);
        ABRecordSetValue(record, kABPersonEmailProperty, email, nil);
    }
    return record;
}

@end
