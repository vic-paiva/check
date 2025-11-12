/**
 * @description : This is test clss for ErrorLogUtil.cls
 * @author : Gaurav Suryawanshi
 */
@isTest
public with sharing class ErrorLogUtilTest {

    @TestSetup
    public static void createTestData(){
        INSERT TestUtility.createBulkOpportunities();
    }

    @isTest
    public static void testAddSaveResultMethod1(){
        List<Opportunity> opps = new List<Opportunity>();
        for(Opportunity opp : [SELECT Id FROM Opportunity]){
           opp.Name = null;
           opps.add(opp);
        }
        //Asserted no error should be in the system
        System.assertEquals(0, [SELECT count() FROM Error__c]);
        System.Test.startTest();
        List<Database.SaveResult> results = Database.update(opps, false);
        ErrorLogUtil.addSaveResult(results, opps);
        ErrorLogUtil.logCommit();
        System.Test.stopTest();
        //Asserted same size of errors should be in the system as opportunity records size
        System.assertEquals(opps.size(), [SELECT count() FROM Error__c]);
    }

    @isTest
    public static void testAddSaveResultMethod2(){
        List<Opportunity> opps = new List<Opportunity>();
        for(Opportunity opp : [SELECT Id FROM Opportunity]){
           opp.Name = null;
           opps.add(opp);
        }
        //Asserted no error should be in the system
        System.assertEquals(0, [SELECT count() FROM Error__c]);
        System.Test.startTest();
        List<Database.SaveResult> results = Database.update(opps, false);
        results.remove(0);
        ErrorLogUtil.addSaveResult(results, opps);
        ErrorLogUtil.logCommit();
        System.Test.stopTest();
        //System should create 1 record of error if the size of saveresult and list of object is not matching
        System.assertEquals(1, [SELECT count() FROM Error__c]);
    }

    @isTest
    public static void testWarningLog(){
        //Asserted no error should be in the system
        System.assertEquals(0, [SELECT count() FROM Error__c WHERE Severity__c = 'Warning']);
        System.Test.startTest();
        for(Integer i = 0; i < 210; i++){
            ErrorLogUtil.addWarningLog(new ErrorLogUtil.ErrorLogDTO('Warning Message : '+i, 'Warning Description : '+i));
        }
        ErrorLogUtil.logCommit();
        System.Test.stopTest();
        //System should create 210 record of warning
        System.assertEquals(210, [SELECT count() FROM Error__c WHERE Severity__c = 'Warning']);
    }

    @isTest
    public static void testInfogLog(){
        //Asserted no error should be in the system
        System.assertEquals(0, [SELECT count() FROM Error__c WHERE Severity__c = 'Info']);
        System.Test.startTest();
        for(Integer i = 0; i < 210; i++){
            ErrorLogUtil.addInfoLog(new ErrorLogUtil.ErrorLogDTO('Info Message : '+i, 'Info Description : '+i));
        }
        ErrorLogUtil.logCommit();
        System.Test.stopTest();
        //System should create 210 record of info
        System.assertEquals(210, [SELECT count() FROM Error__c WHERE Severity__c = 'Info']);
    }
    
}