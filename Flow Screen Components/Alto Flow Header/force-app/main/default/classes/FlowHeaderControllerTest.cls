@IsTest
private class FlowHeaderControllerTest {

    @TestSetup
    static void setupData() {
        RootstockTestDataFactory.createTestSyConfig();
        RootstockTestDataFactory.createTestData();
    }

    @IsTest
    static void testGetUserInfoWithData() {
        rstk__syusr__c syusrRecord = [
            SELECT rstk__syusr_employee__c,
                   rstk__syusr_lastcmpno__r.Name,
                   rstk__syusr_lastcmpno__r.rstk__sycmp_intlogourl__c,
                   rstk__syusr_lastdiv__r.Name
            FROM rstk__syusr__c
            WHERE rstk__syusr_employee__c != null
            LIMIT 1
        ];

        Test.startTest();
        FlowHeaderController.UserInfoResult result =
            FlowHeaderController.getUserInfo(syusrRecord.rstk__syusr_employee__c);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(syusrRecord.rstk__syusr_lastcmpno__r.Name, result.companyName,
            'Company name should come from the synthetic syusr record');
        System.assertEquals(syusrRecord.rstk__syusr_lastcmpno__r.rstk__sycmp_intlogourl__c, result.logoUrl,
            'Logo URL should come from the synthetic syusr record');
        System.assertEquals(syusrRecord.rstk__syusr_lastdiv__r.Name, result.divisionName,
            'Division name should come from the synthetic syusr record');
    }

    @IsTest
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

    @IsTest
    static void testGetUserInfoNullUserId() {
        Test.startTest();
        FlowHeaderController.UserInfoResult result = FlowHeaderController.getUserInfo(null);
        Test.stopTest();

        // Should handle gracefully
        System.assertNotEquals(null, result, 'Result should not be null');
    }
}