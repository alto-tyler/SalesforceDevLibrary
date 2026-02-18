@IsTest
public class alto_NumberToFrenchWordsTest {

    // Helper method to assert conversion dynamically
    private static void assertConversion(Integer majorValue, Integer minorValue, String majorUnit, String minorUnit, String expectedFrench) {
        System.assertEquals(expectedFrench, alto_NumberToFrenchWords.convert(majorValue, minorValue, majorUnit, minorUnit));
    }

    @IsTest
    static void testBasicNumbers() {
        // euros/centimes
        assertConversion(0, 0, 'euro', 'centime', 'zéro');
        assertConversion(1, 0, 'euro', 'centime', 'un euro');
        assertConversion(2, 0, 'euro', 'centime', 'deux euros');
        assertConversion(10, 0, 'euro', 'centime', 'dix euros');
        assertConversion(11, 0, 'euro', 'centime', 'onze euros');

        // dollars/centime
        assertConversion(1, 1, 'dollar', 'centime', 'un dollar et un centime');
        assertConversion(2, 5, 'dollar', 'centime', 'deux dollars et cinq centimes');

        // pounds/centime
        assertConversion(3, 10, 'livre', 'centime', 'trois livres et dix centimes');
    }

    @IsTest
    static void testTensAndEt() {
        // euros
        assertConversion(21, 0, 'euro', 'centime', 'vingt-et-un euros');
        assertConversion(71, 15, 'euro', 'centime', 'soixante-et-onze euros et quinze centimes');

        // dollars
        assertConversion(31, 0, 'dollar', 'centime', 'trente-et-un dollars');
        assertConversion(81, 25, 'dollar', 'centime', 'quatre-vingt-un dollars et vingt-cinq centimes');

        // pounds
        assertConversion(99, 99, 'livre', 'centime', 'quatre-vingt-dix-neuf livres et quatre-vingt-dix-neuf centimes');
    }

    @IsTest
    static void testHundredsAndThousands() {
        // euros
        assertConversion(100, 0, 'euro', 'centime', 'cent euros');
        assertConversion(201, 50, 'euro', 'centime', 'deux cent un euros et cinquante centimes');

        // dollars
        assertConversion(1000, 0, 'dollar', 'centime', 'mille dollars');
        assertConversion(2550, 75, 'dollar', 'centime', 'deux mille cinq cent cinquante dollars et soixante-quinze centimes');

        // pounds
        assertConversion(999999, 99, 'livre', 'centime', 'neuf cent quatre-vingt-dix-neuf mille neuf cent quatre-vingt-dix-neuf livres et quatre-vingt-dix-neuf centimes');
    }

    @IsTest
    static void testMillions() {
        // euros
        assertConversion(1000000, 0, 'euro', 'centime', 'un million euros');
        assertConversion(2300000, 70, 'euro', 'centime', 'deux millions trois cent mille euros et soixante-dix centimes');

        // dollars
        assertConversion(2000000, 50, 'dollar', 'centime', 'deux millions dollars et cinquante centimes');

        // pounds
        assertConversion(1000001, 1, 'livre', 'centime', 'un million un livres et un centime');
    }

    @IsTest
    static void testInvocableMethodWithCustomCurrencies() {
        List<alto_NumberToFrenchWords.Request> requests = new List<alto_NumberToFrenchWords.Request>();

        alto_NumberToFrenchWords.Request req1 = new alto_NumberToFrenchWords.Request();
        req1.inputNumber = 71.15;
        req1.majorUnit = 'euro';
        req1.minorUnit = 'centime';
        requests.add(req1);

        alto_NumberToFrenchWords.Request req2 = new alto_NumberToFrenchWords.Request();
        req2.inputNumber = 81.25;
        req2.majorUnit = 'dollar';
        req2.minorUnit = 'centime';
        requests.add(req2);

        alto_NumberToFrenchWords.Request req3 = new alto_NumberToFrenchWords.Request();
        req3.inputNumber = 1000001.01;
        req3.majorUnit = 'livre';
        req3.minorUnit = 'centime';
        requests.add(req3);

        List<alto_NumberToFrenchWords.Response> responses = alto_NumberToFrenchWords.convertInvocable(requests);

        System.assertEquals('soixante-et-onze euros et quinze centimes', responses[0].frenchWords);
        System.assertEquals('quatre-vingt-un dollars et vingt-cinq centimes', responses[1].frenchWords);
        System.assertEquals('un million un livres et un centime', responses[2].frenchWords);
    }
}