@IsTest
private class RollupNumberHelperTest {
    
    @IsTest
    static void testSumRollup() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1', AnnualRevenue = 100),
            new Account(Name = 'Test 2', AnnualRevenue = 200),
            new Account(Name = 'Test 3', AnnualRevenue = 300)
        };
        
        RollupNumberHelper.RollupRequest request = new RollupNumberHelper.RollupRequest();
        request.records = accounts;
        request.fieldApiName = 'AnnualRevenue';
        request.rollupOption = 'SUM';
        
        List<Decimal> results = RollupNumberHelper.calculateRollup(new List<RollupNumberHelper.RollupRequest>{ request });
        
        Assert.areEqual(600, results[0], 'Sum should be 600');
    }
    
    @IsTest
    static void testAverageRollup() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1', NumberOfEmployees = 10),
            new Account(Name = 'Test 2', NumberOfEmployees = 20),
            new Account(Name = 'Test 3', NumberOfEmployees = 30)
        };
        
        RollupNumberHelper.RollupRequest request = new RollupNumberHelper.RollupRequest();
        request.records = accounts;
        request.fieldApiName = 'NumberOfEmployees';
        request.rollupOption = 'AVERAGE';
        
        List<Decimal> results = RollupNumberHelper.calculateRollup(new List<RollupNumberHelper.RollupRequest>{ request });
        
        Assert.areEqual(20, results[0], 'Average should be 20');
    }
    
    @IsTest
    static void testMedianRollupOddCount() {
        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Opp 1', Amount = 100),
            new Opportunity(Name = 'Opp 2', Amount = 200),
            new Opportunity(Name = 'Opp 3', Amount = 300)
        };
        
        RollupNumberHelper.RollupRequest request = new RollupNumberHelper.RollupRequest();
        request.records = opps;
        request.fieldApiName = 'Amount';
        request.rollupOption = 'MEDIAN';
        
        List<Decimal> results = RollupNumberHelper.calculateRollup(new List<RollupNumberHelper.RollupRequest>{ request });
        
        Assert.areEqual(200, results[0], 'Median should be 200');
    }
    
    @IsTest
    static void testMedianRollupEvenCount() {
        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Opp 1', Amount = 100),
            new Opportunity(Name = 'Opp 2', Amount = 200),
            new Opportunity(Name = 'Opp 3', Amount = 300),
            new Opportunity(Name = 'Opp 4', Amount = 400)
        };
        
        RollupNumberHelper.RollupRequest request = new RollupNumberHelper.RollupRequest();
        request.records = opps;
        request.fieldApiName = 'Amount';
        request.rollupOption = 'MEDIAN';
        
        List<Decimal> results = RollupNumberHelper.calculateRollup(new List<RollupNumberHelper.RollupRequest>{ request });
        
        Assert.areEqual(250, results[0], 'Median should be 250');
    }
    
    @IsTest
    static void testMinRollup() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1', AnnualRevenue = 300),
            new Account(Name = 'Test 2', AnnualRevenue = 100),
            new Account(Name = 'Test 3', AnnualRevenue = 200)
        };
        
        RollupNumberHelper.RollupRequest request = new RollupNumberHelper.RollupRequest();
        request.records = accounts;
        request.fieldApiName = 'AnnualRevenue';
        request.rollupOption = 'MIN';
        
        List<Decimal> results = RollupNumberHelper.calculateRollup(new List<RollupNumberHelper.RollupRequest>{ request });
        
        Assert.areEqual(100, results[0], 'Min should be 100');
    }
    
    @IsTest
    static void testMaxRollup() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1', AnnualRevenue = 100),
            new Account(Name = 'Test 2', AnnualRevenue = 300),
            new Account(Name = 'Test 3', AnnualRevenue = 200)
        };
        
        RollupNumberHelper.RollupRequest request = new RollupNumberHelper.RollupRequest();
        request.records = accounts;
        request.fieldApiName = 'AnnualRevenue';
        request.rollupOption = 'MAX';
        
        List<Decimal> results = RollupNumberHelper.calculateRollup(new List<RollupNumberHelper.RollupRequest>{ request });
        
        Assert.areEqual(300, results[0], 'Max should be 300');
    }
    
    @IsTest
    static void testCountRollup() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1'),
            new Account(Name = 'Test 2'),
            new Account(Name = 'Test 3')
        };
        
        RollupNumberHelper.RollupRequest request = new RollupNumberHelper.RollupRequest();
        request.records = accounts;
        request.fieldApiName = 'AnnualRevenue';
        request.rollupOption = 'COUNT';
        
        List<Decimal> results = RollupNumberHelper.calculateRollup(new List<RollupNumberHelper.RollupRequest>{ request });
        
        Assert.areEqual(3, results[0], 'Count should be 3');
    }
    
    @IsTest
    static void testEmptyListWithCount() {
        List<Account> accounts = new List<Account>();
        
        RollupNumberHelper.RollupRequest request = new RollupNumberHelper.RollupRequest();
        request.records = accounts;
        request.fieldApiName = 'AnnualRevenue';
        request.rollupOption = 'COUNT';
        
        List<Decimal> results = RollupNumberHelper.calculateRollup(new List<RollupNumberHelper.RollupRequest>{ request });
        
        Assert.areEqual(0, results[0], 'Count of empty list should be 0');
    }
    
    @IsTest
    static void testEmptyListWithSum() {
        List<Account> accounts = new List<Account>();
        
        RollupNumberHelper.RollupRequest request = new RollupNumberHelper.RollupRequest();
        request.records = accounts;
        request.fieldApiName = 'AnnualRevenue';
        request.rollupOption = 'SUM';
        
        List<Decimal> results = RollupNumberHelper.calculateRollup(new List<RollupNumberHelper.RollupRequest>{ request });
        
        Assert.isNull(results[0], 'Sum of empty list should be null');
    }
    
    @IsTest
    static void testNullValues() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1', AnnualRevenue = 100),
            new Account(Name = 'Test 2', AnnualRevenue = null),
            new Account(Name = 'Test 3', AnnualRevenue = 200)
        };
        
        RollupNumberHelper.RollupRequest request = new RollupNumberHelper.RollupRequest();
        request.records = accounts;
        request.fieldApiName = 'AnnualRevenue';
        request.rollupOption = 'SUM';
        
        List<Decimal> results = RollupNumberHelper.calculateRollup(new List<RollupNumberHelper.RollupRequest>{ request });
        
        Assert.areEqual(300, results[0], 'Sum should skip null values and be 300');
    }
    
    @IsTest
    static void testAllNullValues() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1', AnnualRevenue = null),
            new Account(Name = 'Test 2', AnnualRevenue = null)
        };
        
        RollupNumberHelper.RollupRequest request = new RollupNumberHelper.RollupRequest();
        request.records = accounts;
        request.fieldApiName = 'AnnualRevenue';
        request.rollupOption = 'SUM';
        
        List<Decimal> results = RollupNumberHelper.calculateRollup(new List<RollupNumberHelper.RollupRequest>{ request });
        
        Assert.isNull(results[0], 'Sum of all null values should be null');
    }
    
    @IsTest
    static void testAllNullValuesWithCount() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1', AnnualRevenue = null),
            new Account(Name = 'Test 2', AnnualRevenue = null)
        };
        
        RollupNumberHelper.RollupRequest request = new RollupNumberHelper.RollupRequest();
        request.records = accounts;
        request.fieldApiName = 'AnnualRevenue';
        request.rollupOption = 'COUNT';
        
        List<Decimal> results = RollupNumberHelper.calculateRollup(new List<RollupNumberHelper.RollupRequest>{ request });
        
        Assert.areEqual(2, results[0], 'Count should return total records even with null values');
    }
    
    @IsTest
    static void testNullFieldName() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1', AnnualRevenue = 100)
        };
        
        RollupNumberHelper.RollupRequest request = new RollupNumberHelper.RollupRequest();
        request.records = accounts;
        request.fieldApiName = null;
        request.rollupOption = 'SUM';
        
        List<Decimal> results = RollupNumberHelper.calculateRollup(new List<RollupNumberHelper.RollupRequest>{ request });
        
        Assert.isNull(results[0], 'Null field name should return null');
    }
    
    @IsTest
    static void testEmptyFieldName() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1', AnnualRevenue = 100)
        };
        
        RollupNumberHelper.RollupRequest request = new RollupNumberHelper.RollupRequest();
        request.records = accounts;
        request.fieldApiName = '';
        request.rollupOption = 'SUM';
        
        List<Decimal> results = RollupNumberHelper.calculateRollup(new List<RollupNumberHelper.RollupRequest>{ request });
        
        Assert.isNull(results[0], 'Empty field name should return null');
    }
    
    @IsTest
    static void testDefaultRollupOption() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1', AnnualRevenue = 100),
            new Account(Name = 'Test 2', AnnualRevenue = 200)
        };
        
        RollupNumberHelper.RollupRequest request = new RollupNumberHelper.RollupRequest();
        request.records = accounts;
        request.fieldApiName = 'AnnualRevenue';
        request.rollupOption = null;
        
        List<Decimal> results = RollupNumberHelper.calculateRollup(new List<RollupNumberHelper.RollupRequest>{ request });
        
        Assert.areEqual(300, results[0], 'Default option should be SUM');
    }
    
    @IsTest
    static void testUnknownRollupOption() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1', AnnualRevenue = 100),
            new Account(Name = 'Test 2', AnnualRevenue = 200)
        };
        
        RollupNumberHelper.RollupRequest request = new RollupNumberHelper.RollupRequest();
        request.records = accounts;
        request.fieldApiName = 'AnnualRevenue';
        request.rollupOption = 'UNKNOWN';
        
        List<Decimal> results = RollupNumberHelper.calculateRollup(new List<RollupNumberHelper.RollupRequest>{ request });
        
        Assert.areEqual(300, results[0], 'Unknown option should default to SUM');
    }
    
    @IsTest
    static void testDecimalValues() {
        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'Opp 1', Amount = 100.50),
            new Opportunity(Name = 'Opp 2', Amount = 200.25),
            new Opportunity(Name = 'Opp 3', Amount = 300.75)
        };
        
        RollupNumberHelper.RollupRequest request = new RollupNumberHelper.RollupRequest();
        request.records = opps;
        request.fieldApiName = 'Amount';
        request.rollupOption = 'SUM';
        
        List<Decimal> results = RollupNumberHelper.calculateRollup(new List<RollupNumberHelper.RollupRequest>{ request });
        
        Assert.areEqual(601.50, results[0], 'Sum should handle decimal values');
    }
    
    @IsTest
    static void testSingleRecord() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test 1', AnnualRevenue = 100)
        };
        
        RollupNumberHelper.RollupRequest request = new RollupNumberHelper.RollupRequest();
        request.records = accounts;
        request.fieldApiName = 'AnnualRevenue';
        request.rollupOption = 'MEDIAN';
        
        List<Decimal> results = RollupNumberHelper.calculateRollup(new List<RollupNumberHelper.RollupRequest>{ request });
        
        Assert.areEqual(100, results[0], 'Median of single value should be that value');
    }
}
