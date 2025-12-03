@isTest(SeeAllData=true)
private class FlowHeaderControllerTest {
    
    @isTest
    static void testGetUserInfoWithData() {
        // Query syusr to find one that has an employee set
        List<rstk__syusr__c> syusrRecords = [
            SELECT rstk__syusr_employee__c
            FROM rstk__syusr__c
            WHERE rstk__syusr_employee__c != null
            LIMIT 1
        ];
        
        System.assert(!syusrRecords.isEmpty(), 'Should have at least one syusr record with employee set');
        
        String userId = syusrRecords[0].rstk__syusr_employee__c;
        
        Test.startTest();
        FlowHeaderController.UserInfoResult result = FlowHeaderController.getUserInfo(userId);
        Test.stopTest();
        
        // Assert that result is not null
        System.assertNotEquals(null, result, 'Result should not be null');
    }
    
    @isTest
    static void testGetUserInfoNoData() {
        // Create a new user that won't have a syusr record
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'tst123',
            Email = 'test123@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser' + System.now().getTime() + '@example.com'
        );
        insert testUser;
        
        Test.startTest();
        FlowHeaderController.UserInfoResult result = FlowHeaderController.getUserInfo(testUser.Id);
        Test.stopTest();
        
        // Result should be returned but with no data
        System.assertNotEquals(null, result, 'Result should not be null');
    }
    
    @isTest
    static void testGetUserInfoNullUserId() {
        Test.startTest();
        FlowHeaderController.UserInfoResult result = FlowHeaderController.getUserInfo(null);
        Test.stopTest();
        
        // Should handle gracefully
        System.assertNotEquals(null, result, 'Result should not be null');
    }
}
