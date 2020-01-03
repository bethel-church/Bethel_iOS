//
//  WebCalls.m
//  BethelMissionsReceiptApp
//
//  Created by Vivek Bhuria on 9/8/15.
//  Copyright (c) 2015 Calico. All rights reserved.
//

#import "WebCalls.h"
#import "AFNetworking.h"

static WebCalls *webCalls;
@implementation WebCalls
+(WebCalls*)sharedWebCalls
{
    if (!webCalls)
    {
        webCalls = [[super alloc] init];
    }
    
    return webCalls;
}

-(void) showAlertWithTitle:(NSString*)title message:(NSString*)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
      
        if ([message isEqualToString:@"network failure message"])
        {
          
            [[[UIAlertView alloc] initWithTitle:@"No Internet!" message:@"You don't seem to be connected to the Internet. Please get connected and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
       
    });
    
}



-(void) getCurrencies
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://www.floatrates.com/daily/usd.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:@"CURRENCIES"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)getTripList:(NSString*) category caller:(id)caller
{
    [Internet addActivityIndicator];
    NSString *url = [NSString stringWithFormat:@"%@%@",bethelMissionsBaseURL,@"get_trip_list"];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:category,@"trip_category", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [caller didGetWebResponse:responseObject forWebCall:@"get_trip_list"];
        [Internet removeActivityIndicator];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Internet removeActivityIndicator];
        [self showAlertWithTitle:@"Error!" message:@"network failure message"];
    }];
}

-(void)login:(NSString *)tripId passcode:(NSString*)passcode caller:(id)caller
{
    [Internet addActivityIndicator];
    NSString *url = [NSString stringWithFormat:@"%@%@",bethelMissionsBaseURL,@"login"];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:tripId,@"trip_id",passcode,@"passcode", nil];
  
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([caller respondsToSelector:@selector(didGetWebResponse:forWebCall:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
               
                [caller didGetWebResponse:responseObject forWebCall:@"login"];
                [Internet removeActivityIndicator];
            });
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Internet removeActivityIndicator];
        [self showAlertWithTitle:@"Error!" message:@"network failure message"];
    }];
        
    
}

-(void)getTripBudget:(NSString*)tripId caller:(id)caller
{
    [Internet addActivityIndicator];
    NSString *url = [NSString stringWithFormat:@"%@%@",bethelMissionsBaseURL,@"get_budget_details"];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:tripId,@"trip_id", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([caller respondsToSelector:@selector(didGetWebResponse:forWebCall:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSUserDefaults standardUserDefaults] setValue:responseObject forKey:@"trip_budget"];
                [caller didGetWebResponse:responseObject forWebCall:@"get_budget_details"];
                [Internet removeActivityIndicator];
            });
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [caller didGetWebResponse:[[NSUserDefaults standardUserDefaults] valueForKey:@"trip_budget"] forWebCall:@"get_budget_details"];
            [Internet removeActivityIndicator];
        });
       
       
    }];
}

-(void)setTripBudget:(NSString*)tripId tripBudget:(NSString*)budget caller:(id)caller
{
    [Internet addActivityIndicator];
    NSString *url = [NSString stringWithFormat:@"%@%@",bethelMissionsBaseURL,@"set_trip_budget"];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:tripId,@"trip_id",budget,@"trip_budget", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([caller respondsToSelector:@selector(didGetWebResponse:forWebCall:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [caller didGetWebResponse:responseObject forWebCall:@"set_trip_budget"];
                [Internet removeActivityIndicator];
            });
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Internet removeActivityIndicator];
        [self showAlertWithTitle:@"Error!" message:@"network failure message"];
    }];
}


-(void)getTripCurrencies:(NSString*)tripId caller:(id)caller
{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",bethelMissionsBaseURL,@"get_trip_currencies"];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:tripId,@"trip_id", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([caller respondsToSelector:@selector(didGetWebResponse:forWebCall:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                 [[NSUserDefaults standardUserDefaults] setValue:responseObject forKey:@"trip_currencies"];
                [caller didGetWebResponse:responseObject forWebCall:@"get_trip_currencies"];
               
            });
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
         dispatch_async(dispatch_get_main_queue(), ^{
             
             [caller didGetWebResponse:[[NSUserDefaults standardUserDefaults] valueForKey:@"trip_currencies"] forWebCall:@"get_trip_currencies"];
         });
        
        
    }];
}

-(void)setTripCurrencies:(NSString*)tripId currencies:(NSArray*)currencies caller:(id)caller
{
    [Internet addActivityIndicator];
    if ([currencies count] == 0)
    {
        currencies = @[];
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",bethelMissionsBaseURL,@"set_trip_currencies"];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:tripId,@"trip_id",currencies,@"currencies", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([caller respondsToSelector:@selector(didGetWebResponse:forWebCall:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [caller didGetWebResponse:responseObject forWebCall:@"set_trip_currencies"];
                 [Internet removeActivityIndicator];
            });
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Internet removeActivityIndicator];
        [self showAlertWithTitle:@"Error!" message:@"network failure message"];
    }];
}

-(void)addUpdateReceipt:(NSString*)tripId receiptId:(NSString*)receiptId priceOtherCurrency:(NSString*)priceOtherCurrency priceUSD:(NSString*)priceUSD  currency:(NSString*)currrency type:(NSString*)type description:(NSString*)description userName:(NSString*)userName image:(UIImage*)img date:(NSString*)date caller:(id)caller
{
    [Internet addActivityIndicator];
     NSString *forCall;
    NSArray *components = [userName componentsSeparatedByString:@" "];
    NSString *firstName =  [components objectAtIndex:0];
    NSString *middleName = @"";
    NSString *lastName;
    
    if ([components count] == 3)
    {
        middleName = [components objectAtIndex:1] ;
        lastName = [components objectAtIndex:2];
    }
    else
    {
        lastName = [components objectAtIndex:1];
    }
    
    NSString *url;
    NSDictionary* params;
    if (receiptId)
    {
        forCall = @"update_receipt";
        url = [NSString stringWithFormat:@"%@%@",bethelMissionsBaseURL,@"update_receipt"];
        params = [NSDictionary dictionaryWithObjectsAndKeys:tripId,@"trip_id",receiptId, @"receipt_id",priceOtherCurrency,@"price_other_currency",priceUSD,@"price_usd", currrency,@"currency",type,@"type",description,@"description",firstName,@"first_name",middleName,@"middle_name",lastName,@"last_name",date,@"receipt_date", nil];
    }
    else
    {
        forCall = @"add_receipt";
        url = [NSString stringWithFormat:@"%@%@",bethelMissionsBaseURL,@"add_receipt"];
        params = [NSDictionary dictionaryWithObjectsAndKeys:tripId,@"trip_id",priceOtherCurrency,@"price_other_currency",priceUSD,@"price_usd", currrency,@"currency",type,@"type",description,@"description",firstName,@"first_name",middleName,@"middle_name",lastName,@"last_name",date,@"receipt_date", nil];
    }
    
    NSData *imgData = nil;
    if (img)
    {
      imgData = UIImageJPEGRepresentation(img, 0.5);
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    AFHTTPRequestOperation *op = [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (imgData)
        {
            [formData appendPartWithFileData:imgData name:@"receipt_image" fileName:@"receipt.jpg" mimeType:@"image/jpeg"];
        }
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([caller respondsToSelector:@selector(didGetWebResponse:forWebCall:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [caller didGetWebResponse:responseObject forWebCall:forCall];
                [Internet removeActivityIndicator];
            });
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Internet removeActivityIndicator];
         dispatch_async(dispatch_get_main_queue(), ^{
             
             [caller networkIssueHandler];
             
         });
        //[self showAlertWithTitle:@"Error!" message:@"network failure message"];
       
    }];
    
    [op start];
}

-(void)getReceipts:(NSString*)tripId userName:(NSString*)name caller:(id)caller
{
    [Internet addActivityIndicator];
    
    NSString *url;
    NSString *forCall;
    NSArray *components = [name componentsSeparatedByString:@" "];
    NSString *firstName =  [components objectAtIndex:0];
    NSString *middleName = @"";
    NSString *lastName;
    NSDictionary* params;
    
    if (name)
    {
       
        if ([components count] == 3)
        {
            middleName = [components objectAtIndex:1] ;
            lastName = [components objectAtIndex:2];
        }
        else
        {
            lastName = [components objectAtIndex:1];
        }
        url = [NSString stringWithFormat:@"%@%@",bethelMissionsBaseURL,@"get_user_receipts"];
        forCall = @"get_user_receipts";
        params = [NSDictionary dictionaryWithObjectsAndKeys:tripId,@"trip_id",firstName,@"first_name",middleName,@"middle_name",lastName,@"last_name", nil];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@%@",bethelMissionsBaseURL,@"get_all_receipts"];
        forCall = @"get_all_receipts";
        params = [NSDictionary dictionaryWithObjectsAndKeys:tripId,@"trip_id", nil];
    }
   
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([caller respondsToSelector:@selector(didGetWebResponse:forWebCall:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(name)
                {
                    [[NSUserDefaults standardUserDefaults] setValue:responseObject forKey:name];
                }
                else{
                    [[NSUserDefaults standardUserDefaults] setValue:responseObject forKey:@"uploaded_receipts"];
                }
                
                [caller didGetWebResponse:responseObject forWebCall:forCall];
                [Internet removeActivityIndicator];
            });
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
         dispatch_async(dispatch_get_main_queue(), ^{
             
              if(name)
              {
                  [caller didGetWebResponse:[[NSUserDefaults standardUserDefaults] valueForKey:name] forWebCall:forCall];
              }
              else{
                  
                  [caller didGetWebResponse:[[NSUserDefaults standardUserDefaults] valueForKey:@"uploaded_receipts"] forWebCall:forCall];
              }
             
             [Internet removeActivityIndicator];
         });
    }];
}

-(void)deleteReceipt:(NSString*)receiptId caller:(id)caller
{
    [Internet addActivityIndicator];
    NSString *url = [NSString stringWithFormat:@"%@%@",bethelMissionsBaseURL,@"delete_receipt"];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:receiptId,@"receipt_id",nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([caller respondsToSelector:@selector(didGetWebResponse:forWebCall:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [caller didGetWebResponse:responseObject forWebCall:@"delete_receipt"];
                [Internet removeActivityIndicator];
            });
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Internet removeActivityIndicator];
        [self showAlertWithTitle:@"Error!" message:@"network failure message"];
    }];
}

-(void) isTripArchived:(NSString*) tripId caller:(id)caller
{
    [Internet addActivityIndicator];
    NSString *url = [NSString stringWithFormat:@"%@%@",bethelMissionsBaseURL,@"isArchived"];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:tripId,@"trip_id",nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([caller respondsToSelector:@selector(didGetWebResponse:forWebCall:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[NSUserDefaults standardUserDefaults] setValue:responseObject forKey:@"isArchived"];
                [caller didGetWebResponse:responseObject forWebCall:@"isArchived"];
                [Internet removeActivityIndicator];
            });
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
         dispatch_async(dispatch_get_main_queue(), ^{
             
             [caller didGetWebResponse:[[NSUserDefaults standardUserDefaults] valueForKey:@"isArchived"] forWebCall:@"isArchived"];
             [Internet removeActivityIndicator];
         });
        
        //[self showAlertWithTitle:@"Error!" message:@"network failure message"];
    }];
}


+(NSDictionary*)currencyFullNamesDictionary
{
    NSDictionary *fullNamesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Arab Emirates Dirham",@"AED",
                                @"Afghanistan Afghani",@"AFN",
                                @"Albanian Lek",@"ALL",
                                @"Armenian Dram",@"AMD",
                                @"Netherlands Guilder",@"ANG",//Netherlands Antillean Guilder
                                @"Angolan Kwanza",@"AOA",
                                @"Argentine Peso",@"ARS",
                                @"Australian Dollar",@"AUD",
                                @"Aruban Guilder",@"AWG",
                                @"Azerbaijan New Manat",@"AZN",
                                @"Marka",@"BAM",
                                @"Barbados Dollar",@"BBD",
                                @"Bangladeshi Taka",@"BDT",
                                @"Bulgarian Lev",@"BGN",
                                @"Bahraini Dinar",@"BHD",
                                @"Burundi Franc",@"BIF",
                                @"Bermudian Dollar",@"BMD",
                                @"Brunei Dollar",@"BND",
                                @"Boliviano",@"BOB",
                                @"Brazilian Real",@"BRL",
                                @"Bahamian Dollar",@"BSD",
                                @"Bhutan Ngultrum",@"BTN",
                                @"Botswana Pula",@"BWP",
                                @"Belarussian Ruble",@"BYN",
                                @"Belize Dollar",@"BZD",
                                @"Canadian Dollar",@"CAD",
                                @"Francs",@"CDF",
                                @"Swiss Franc",@"CHF",
                                @"Chilean Fomento",@"CLF",//Chilean Unidad de Fomento
                                @"Chilean Peso",@"CLP",
                                @"Chinese Yuan",@"CNY",                                
                                @"Colombian Peso",@"COP",
                                @"Costa Rican Colon",@"CRC",
                                @"Cuban Peso",@"CUP",
                                @"Cape Verde Escudo",@"CVE",
                                @"Czech Koruna",@"CZK",                                
                                @"Djibouti Franc",@"DJF",
                                @"Danish Krone",@"DKK",
                                @"Dominican Peso",@"DOP",
                                @"Algerian Dinar",@"DZD",                                
                                @"Egyptian Pound",@"EGP",
                                @"Eritrean Nakfa",@"ERN",
                                @"Ethiopian Birr",@"ETB",
                                @"Euro",@"EUR",
                                @"Fiji Dollar",@"FJD",
                                @"Falkland Islands Pound",@"FKP",                                
                                @"Great Britain Pound",@"GBP",
                                @"Georgian Lari",@"GEL",
                                @"Ghanaian Cedi",@"GHS",
                                @"Gibraltar Pound",@"GIP",
                                @"Gambian Dalasi",@"GMD",
                                @"Guinea Franc",@"GNF",
                                @"Guatemalan Quetzal",@"GTQ",
                                @"Guyana Dollar",@"GYD",
                                @"Hong Kong Dollar",@"HKD",
                                @"Honduran Lempira",@"HNL",
                                @"Croatian Kuna",@"HRK",
                                @"Haitian Gourde",@"HTG",
                                @"Hungarian Forint",@"HUF",
                                @"Indonesian Rupiah",@"IDR",                              
                                @"Israeli New Shekel",@"ILS",
                                @"Indian Rupee",@"INR",
                                @"Iraqi Dinar",@"IQD",
                                @"Iranian Rial",@"IRR",
                                @"Iceland Krona",@"ISK",                                
                                @"Jamaican Dollar",@"JMD",
                                @"Jordanian Dinar",@"JOD",
                                @"Japanese Yen",@"JPY",
                                @"Kenyan Shilling",@"KES",
                                @"Som",@"KGS",
                                @"Kampuchean Riel",@"KHR",
                                @"Comoros Franc",@"KMF",
                                @"North Korean Won",@"KPW",
                                @"Korean Won",@"KRW",
                                @"Kuwaiti Dinar",@"KWD",
                                @"Cayman Islands Dollar",@"KYD",
                                @"Kazakhstan Tenge",@"KZT",
                                @"Lao Kip",@"LAK",
                                @"Lebanese Pound",@"LBP",
                                @"Sri Lanka Rupee",@"LKR",
                                @"Liberian Dollar",@"LRD",
                                @"Lesotho Loti",@"LSL",                                
                                @"Libyan Dinar",@"LYD",
                                @"Moroccan Dirham",@"MAD",
                                @"Moldovan Leu",@"MDL",
                                @"Malagasy Ariary ",@"MGA",
                                @"Denar",@"MKD",
                                @"Myanmar Kyat",@"MMK",
                                @"Mongolian Tugrik",@"MNT",
                                @"Macau Pataca",@"MOP",
                                @"Mauritanian Ouguiya",@"MRU",
                                @"Mauritius Rupee",@"MUR",
                                @"Maldive Rufiyaa",@"MVR",
                                @"Malawi Kwacha",@"MWK",
                                @"Mexican Nuevo Peso",@"MXN",
                                @"Mexican Inversion",@"MXV ",//Mexican Unidad De Inversion
                                @"Malaysian Ringgit",@"MYR",
                                @"Mozambique Metical",@"MZN",
                                @"Namibian Dollar",@"NAD",
                                @"Nigerian Naira",@"NGN",
                                @"Nicaraguan Cordoba Oro",@"NIO",
                                @"Norwegian Krone",@"NOK",
                                @"Nepalese Rupee",@"NPR",
                                @"New Zealand Dollar",@"NZD",
                                @"Omani Rial",@"OMR",
                                @"Panamanian Balboa",@"PAB",
                                @"Peruvian Nuevo Sol",@"PEN",
                                @"Papua New Guinea Kina",@"PGK",
                                @"Philippine Peso",@"PHP",
                                @"Pakistan Rupee",@"PKR",
                                @"Polish Zloty",@"PLN",
                                @"Paraguay Guarani",@"PYG",
                                @"Qatari Rial",@"QAR",
                                @"Romanian New Leu",@"RON",
                                @"Dinar",@"RSD",
                                @"Russian Ruble",@"RUB",
                                @"Rwanda Franc",@"RWF",
                                @"Saudi Riyal",@"SAR",
                                @"Solomon Islands Dollar",@"SBD",
                                @"Seychelles Rupee",@"SCR",
                                @"Sudanese Pound",@"SDG",
                                @"Swedish Krona",@"SEK",
                                @"Singapore Dollar",@"SGD",
                                @"St. Helena Pound",@"SHP",                                
                                @"Sierra Leone Leone",@"SLL",
                                @"Somali Shilling",@"SOS",
                                @"Surinam Dollar",@"SRD",
                                @"South Sudanese Pound",@"SSP",
                                @"Dobra",@"STN",
                                @"El Salvador Colon",@"SVC",
                                @"Syrian Pound",@"SYP",
                                @"Swaziland Lilangeni",@"SZL",
                                @"Thai Baht",@"THB",
                                @"Tajik Somoni",@"TJS",
                                @"Manat",@"TMT",
                                @"Tunisian Dollar",@"TND",
                                @"Tongan Pa'anga",@"TOP",
                                @"Turkish Lira",@"TRY",
                                @"Trinidad&Tobago Dollar",@"TTD",
                                @"Taiwan Dollar",@"TWD",
                                @"Tanzanian Shilling",@"TZS",
                                @"Ukraine Hryvnia",@"UAH",
                                @"Uganda Shilling",@"UGX",
                                @"Uruguayan Peso",@"UYU",
                                @"Uzbekistan Sum",@"UZS",
                                @"Venezuelan Bolivar",@"VES",
                                @"Vietnamese Dong",@"VND",
                                @"Vanuatu Vatu",@"VUV",
                                @"Samoan Tala",@"WST",
                                @"CFA Franc BEAC",@"XAF",
                                @"East Caribbean Dollar",@"XCD",
                                @"Special Drawing Rights ",@"XDR",
                                @"CFA Franc BCEAO",@"XOF",
                                @"CFP Franc",@"XPF",
                                @"Yemeni Rial",@"YER",
                                @"South African Rand",@"ZAR",
                                @"Zambian Kwacha",@"ZMW",
                                @"Zimbabwean dollar",@"ZWL", nil];
    
    return fullNamesDictionary;
}

-(void)uploadReceipt:(NSString*)tripId receiptId:(NSString*)receiptId priceOtherCurrency:(NSString*)priceOtherCurrency priceUSD:(NSString*)priceUSD  currency:(NSString*)currrency type:(NSString*)type description:(NSString*)description userName:(NSString*)userName image:(UIImage*)img date:(NSString*)date caller:(id)caller
{
    [Internet addActivityIndicator];
    NSString *forCall;
    NSArray *components = [userName componentsSeparatedByString:@" "];
    NSString *firstName =  [components objectAtIndex:0];
    NSString *middleName = @"";
    NSString *lastName;
    
    if ([components count] == 3)
    {
        middleName = [components objectAtIndex:1] ;
        lastName = [components objectAtIndex:2];
    }
    else
    {
        lastName = [components objectAtIndex:1];
    }
    
    NSString *url;
    NSDictionary* params;
    
    forCall = @"upload_receipt";
    url = [NSString stringWithFormat:@"%@%@",bethelMissionsBaseURL,@"add_receipt"];
    params = [NSDictionary dictionaryWithObjectsAndKeys:tripId,@"trip_id",priceOtherCurrency,@"price_other_currency",priceUSD,@"price_usd", currrency,@"currency",type,@"type",description,@"description",firstName,@"first_name",middleName,@"middle_name",lastName,@"last_name",date,@"receipt_date", nil];
    
    NSData *imgData = nil;
    if (img)
    {
        imgData = UIImageJPEGRepresentation(img, 0.5);
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    AFHTTPRequestOperation *op = [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (imgData)
        {
            [formData appendPartWithFileData:imgData name:@"receipt_image" fileName:@"receipt.jpg" mimeType:@"image/jpeg"];
        }
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([caller respondsToSelector:@selector(didGetWebResponse:forWebCall:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [caller didGetWebResponse:responseObject forWebCall:forCall];
                [Internet removeActivityIndicator];
            });
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Internet removeActivityIndicator];
        
        [caller hideUploadProgress];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"We are having trouble uploading receipt right now.\nPlease make sure you are connected to internet and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
    }];
    
    [op setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
        [caller showUploadProgress:totalBytesWritten remaining:totalBytesExpectedToWrite];
        
        
    }];
    
    [op start];
}

-(void)uploadAllReceipts:(NSString*)tripId receiptId:(NSString*)receiptId priceOtherCurrency:(NSString*)priceOtherCurrency priceUSD:(NSString*)priceUSD  currency:(NSString*)currrency type:(NSString*)type description:(NSString*)description userName:(NSString*)userName image:(UIImage*)img date:(NSString*)date caller:(id)caller
{
    [Internet addActivityIndicator];
    NSString *forCall;
    NSArray *components = [userName componentsSeparatedByString:@" "];
    NSString *firstName =  [components objectAtIndex:0];
    NSString *middleName = @"";
    NSString *lastName;
    
    if ([components count] == 3)
    {
        middleName = [components objectAtIndex:1] ;
        lastName = [components objectAtIndex:2];
    }
    else
    {
        lastName = [components objectAtIndex:1];
    }
    
    NSString *url;
    NSDictionary* params;
    
    forCall = @"upload_all_receipts";
    url = [NSString stringWithFormat:@"%@%@",bethelMissionsBaseURL,@"add_receipt"];
    params = [NSDictionary dictionaryWithObjectsAndKeys:tripId,@"trip_id",priceOtherCurrency,@"price_other_currency",priceUSD,@"price_usd", currrency,@"currency",type,@"type",description,@"description",firstName,@"first_name",middleName,@"middle_name",lastName,@"last_name",date,@"receipt_date", nil];
    
    NSData *imgData = nil;
    if (img)
    {
        imgData = UIImageJPEGRepresentation(img, 0.5);
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    AFHTTPRequestOperation *op = [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (imgData)
        {
            [formData appendPartWithFileData:imgData name:@"receipt_image" fileName:@"receipt.jpg" mimeType:@"image/jpeg"];
        }
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([caller respondsToSelector:@selector(didGetWebResponse:forWebCall:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [caller didGetWebResponse:responseObject forWebCall:forCall];
                [Internet removeActivityIndicator];
            });
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Internet removeActivityIndicator];
        [caller hideUploadAllProgress];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"We are having trouble uploading receipt right now.\nPlease make sure you are connected to internet and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
    }];
    
    
    
    [op start];
}

-(void) getStudentBudgetDetails:(NSString*)tripId userName:(NSString*)userName caller:(id)caller
{
    
    [Internet addActivityIndicator];
    
    
    NSString *url = [NSString stringWithFormat:@"%@%@",bethelMissionsBaseURL,@"get_student_budget_details"];
    
    
    NSArray *components = [userName componentsSeparatedByString:@" "];
    NSString *firstName =  [components objectAtIndex:0];
    NSString *middleName = @"";
    NSString *lastName;
    
    if ([components count] == 3)
    {
        middleName = [components objectAtIndex:1] ;
        lastName = [components objectAtIndex:2];
    }
    else
    {
        lastName = [components objectAtIndex:1];
    }
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:tripId,@"trip_id",firstName,@"first_name",middleName,@"middle_name",lastName,@"last_name", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([caller respondsToSelector:@selector(didGetWebResponse:forWebCall:)])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSUserDefaults standardUserDefaults] setValue:responseObject forKey:@"student_budget"];
                [caller didGetWebResponse:responseObject forWebCall:@"get_student_budget_details"];
                [Internet removeActivityIndicator];
            });
        }
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [caller didGetWebResponse:[[NSUserDefaults standardUserDefaults] valueForKey:@"student_budget"] forWebCall:@"get_student_budget_details"];
            [Internet removeActivityIndicator];
        });
        
        
    }];
    
}

-(void) getUserDetails:(NSString*)tripId caller:(id)caller
{
    [Internet addActivityIndicator];
    NSString *url = [NSString stringWithFormat:@"%@%@",bethelMissionsBaseURL,@"get_user_details"];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:tripId,@"trip_id", nil];
    //NSString *params = [NSString stringWithFormat:@"{trip_id:%@}",tripId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults] setValue:responseObject forKey:@"get_user_details"];
            [caller didGetWebResponse:responseObject forWebCall:@"get_user_details"];
            [Internet removeActivityIndicator];
        });
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [caller didGetWebResponse:[[NSUserDefaults standardUserDefaults] valueForKey:@"get_user_details"]  forWebCall:@"get_user_details"];
            [Internet removeActivityIndicator];
        });
       
    }];
}
@end
