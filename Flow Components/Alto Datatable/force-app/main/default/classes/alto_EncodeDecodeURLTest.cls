/**
 * @author Eric Smith
 * @group DataTable
 */
@SuppressWarnings('PMD.ClassNamingConventions')
@isTest
public with sharing class alto_EncodeDecodeURLTest {
    @isTest
    public static void testEncodeDecode() {
        string decoded = '2:{class: slds-theme_shade slds-theme_error}';
        string encoded = '2%3A%7Bclass%3A+slds-theme_shade+slds-theme_error%7D';

        alto_EncodeDecodeURL.Requests testRequest = new alto_EncodeDecodeURL.Requests();

        /* Decode */
        List<alto_EncodeDecodeURL.Requests> testDecodeRequestList = new List<alto_EncodeDecodeURL.Requests>();
        testRequest.inputStr = encoded;
        testDecodeRequestList.add(testRequest);
        List<alto_EncodeDecodeURL.Results> testDecodeResponseList = alto_EncodeDecodeURL.decodeStringForURL(
            testDecodeRequestList
        );
        System.assertEquals(decoded, testDecodeResponseList[0].outputStr);

        /* Encode */
        List<alto_EncodeDecodeURL.Requests> testEncodeRequestList = new List<alto_EncodeDecodeURL.Requests>();
        testRequest.inputStr = decoded;
        testRequest.encode = true;
        testEncodeRequestList.add(testRequest);
        List<alto_EncodeDecodeURL.Results> testEncodeResponseList = alto_EncodeDecodeURL.decodeStringForURL(
            testEncodeRequestList
        );
        System.assertEquals(encoded, testEncodeResponseList[0].outputStr);
    }
}