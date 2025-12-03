public with sharing class FlowHeaderController {
    
    public class UserInfoResult {
        @AuraEnabled public String companyName;
        @AuraEnabled public String divisionName;
        @AuraEnabled public String logoUrl;
    }
    
    @AuraEnabled(cacheable=true)
    public static UserInfoResult getUserInfo(String userId) {
        UserInfoResult result = new UserInfoResult();
        
        try {
            // Query the rstk__syusr__c record for the current user
            List<rstk__syusr__c> userRecords = [
                SELECT 
                    rstk__syusr_lastcmpno__r.Name,
                    rstk__syusr_lastcmpno__r.rstk__sycmp_intlogourl__c,
                    rstk__syusr_lastdiv__r.Name
                FROM rstk__syusr__c 
                WHERE rstk__syusr_employee__c = :userId
                LIMIT 1
            ];
            
            if (!userRecords.isEmpty()) {
                rstk__syusr__c userRecord = userRecords[0];
                
                if (userRecord.rstk__syusr_lastcmpno__r != null) {
                    result.companyName = userRecord.rstk__syusr_lastcmpno__r.Name;
                    result.logoUrl = userRecord.rstk__syusr_lastcmpno__r.rstk__sycmp_intlogourl__c;
                }
                
                if (userRecord.rstk__syusr_lastdiv__r != null) {
                    result.divisionName = userRecord.rstk__syusr_lastdiv__r.Name;
                }
            }
            
        } catch (Exception e) {
            System.debug('Error retrieving user info: ' + e.getMessage());
        }
        
        return result;
    }
}
