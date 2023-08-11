/**
 * @Author:  Paras Dhingra 
 * @Source: https://github.com/pozil/sfdc-ui-lookup-lwc
 * @Date: 14th April 2020
 * @description: SFDC-2734 test class for LookupSearchResult wrapper class
 */
@isTest
public class TestLookupSearchResult {
    @isTest
    static void compareToShouldWorkwithTwoNullTitles() {
        LookupSearchResult r1 = getSearchResult(null);
        LookupSearchResult r2 = getSearchResult(null);

        Integer compareResult = r1.compareTo(r2);

        System.assertEquals(0, compareResult,'Result Mismatch');
    }

    @isTest
    static void compareToShouldWorkWithThisNullTitle() {
        LookupSearchResult r1 = getSearchResult(null);
        LookupSearchResult r2 = getSearchResult('a');

        Integer compareResult = r1.compareTo(r2);

        System.assertEquals(1, compareResult,'Result Mismatch');
    }

    @isTest
    static void compareToShouldWorkWithOtherNullTitle() {
        LookupSearchResult r1 = getSearchResult('a');
        LookupSearchResult r2 = getSearchResult(null);

        Integer compareResult = r1.compareTo(r2);

        System.assertEquals(-1, compareResult,'Result Mismatch');
    }

    @isTest
    static void compareToShouldWorkWithNonNullTitles() {
        LookupSearchResult r1 = getSearchResult('a');
        LookupSearchResult r2 = getSearchResult('b');

        Integer compareResult = r1.compareTo(r2);

        System.assertEquals(-1, compareResult,'Result Mismatch');
    }

    @isTest
    static void testGetters() {
        // For the sake of code coverage
        LookupSearchResult r = new LookupSearchResult('0010R00000yvEyRQAU', 'type', 'icon', 'title', 'subtitle');

        System.assertEquals('0010R00000yvEyRQAU', r.getId(),'Id missing');
        System.assertEquals('type', r.getSObjectType(),'type missing');
        System.assertEquals('icon', r.getIcon(),'icon missing');
        System.assertEquals('title', r.getTitle(),'title missing');
        System.assertEquals('subtitle', r.getSubtitle(),'subtitle missing');
    }

    private static LookupSearchResult getSearchResult(String title) {
        return new LookupSearchResult(null, null, null, title, null);
    }
}