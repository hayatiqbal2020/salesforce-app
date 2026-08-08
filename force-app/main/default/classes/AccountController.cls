public class AccountController {
	
	
    @future(callout=true)
    public static void syncWithOtherOrg(String accountIds){
        
        try{
            Account acc = [SELECT Id, Name, Type, BillingStreet, BillingCity, BillingState, 
                           BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, 
                           BillingGeocodeAccuracy, ShippingStreet, ShippingCity, ShippingState, 
                           ShippingPostalCode, ShippingCountry, ShippingLatitude, ShippingLongitude, 
                           ShippingGeocodeAccuracy, Phone, Fax, AccountNumber, Website, Sic, 
                           Industry, AnnualRevenue, NumberOfEmployees, TickerSymbol, 
                           Description, Rating, Site, Jigsaw, 
                           CleanStatus, AccountSource, DunsNumber, Tradestyle, 
                           NaicsCode, NaicsDesc, YearStarted, SicDesc 
                           FROM Account where Id=:accountIds limit 1];
            system.debug(acc);
            HttpRequest req = new HttpRequest();
            
			req.setEndpoint('callout:Deloitte_Org/services/data/v57.0/sobjects/Account');
            req.setMethod('POST');
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Map<String, Object> accountMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(acc));
			accountMap.remove('attributes');accountMap.remove('Id');
        	accountMap.put('Description', 'Created from '+Url.getOrgDomainUrl()+'/'+acc.Id);
            
            req.setBody(JSON.serialize(accountMap));
            Http http = new Http();
            HttpResponse res = new HttpResponse();
            if(!Test.isRunningTest()){
                res = http.send(req);
            } else {
                res.setStatusCode(201);
                res.setBody('{}');
            }
            if(res.getStatusCode() == 201){
                String responseBody = res.getBody();
				Map<String, Object> resJson = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
		
                String recordId = (String)resJson.get('id');system.debug('resJson' + resJson + '----' + recordId);
                update new Account(Id=accountIds, Is_Synced__c=true, Description = recordId);
            } else {
                update new Account(Id=accountIds, Is_Synced__c=true, Description = 'Status code: ' + res.getStatusCode() + 'Body: '+ res.getBody());
                System.debug('Callout failed with status code: ' + res.getStatusCode() + ' and body: ' + res.getBody());
            }
            
        } catch(Exception e){
            system.debug('Exception' + e);
        }
    }
    
    @InvocableMethod(
        label='Sync Account with Other Org' 
        description='This method will sync account with deloitte org' 
        category='Account'
    )
    public static void syncAccount(List<Id> accountIds) {        
        // Query to get AccountId from Case
        for(Id accountId : accountIds) {
            syncWithOtherOrg(accountId);
        }        
    }
}