/**
 * @description : This utility class holds test data required in test classes
 * @author : Gaurav Suryawanshi
 */
@isTest
public with sharing class TestUtility {
    private static Integer index = 1;

    public static List<Opportunity> createBulkOpportunities(){
        List<Opportunity> opportunities = new List<Opportunity>();
        for(Integer i = 0; i < 210; i++){
            opportunities.add(new Opportunity(Name = 'Test Opportunity : '+i,
                                              CloseDate = Date.today().addDays(7),
                                              StageName = 'Prospecting'));
        }
        return opportunities;
    }

    public static List<Process_Task__c> createBulkTaskProcessForOpp(List<Opportunity> opportunities, String Status, Integer order){
        List<Process_Task__c> processTasks = new List<Process_Task__c>();
        for(Opportunity opp : opportunities){
            processTasks.add(new Process_Task__c(Opportunity__c = opp.Id,
                                                Name = 'Step 1 : Installation',
                                                Status__c = Status,
                                                Process_Name__c = 'EV Installation',
                                                Sequence_Order__c = order));
        }
        return processTasks;
    }

    public static Id getFakeSalesforceId(Schema.SObjectType sot) {
        String indexStr = String.valueOf(index++);
        String keyPrefix = sot.getDescribe().getKeyPrefix();
        return keyPrefix + '0'.repeat(12 - indexStr.length()) + indexStr;
    }
}