/**
 * @description : This is test clss for Opportunity object trigger and dependent classes
 * @author : Gaurav Suryawanshi
 */
@isTest
public with sharing class OpportunityTriggerTest {
    
    @TestSetup
    static void makeTestData(){
       List<Opportunity> opportunities = TestUtility.createBulkOpportunities();
       INSERT opportunities;
    }

    @isTest
    public static void testCreationOfProcessTaskOnAfterInsert(){
        //Deleted setup opportunities
        DELETE [SELECT Id FROM Opportunity];
        //Assert to check no process task is available in the system
        System.assertEquals(0, [SELECT count() FROM Process_Task__c]);
        System.Test.startTest();
            List<Opportunity> opportunities = new List<Opportunity>();
            for(Opportunity opp : TestUtility.createBulkOpportunities()){
                opp.Process__c = 'EV Installation';
                opportunities.add(opp);
            }
            INSERT opportunities;
        System.Test.stopTest();
        List<Process_Task__c> processTasks = [SELECT Id, Opportunity__c, Sequence_Order__c FROM Process_Task__c];
        Set<Id> oppIds = new Set<Id>();
        //Assert to check same size of process task should have created
        System.assertEquals(opportunities.size(), processTasks.size());
        for(Process_Task__c processTask : processTasks){
            //Assert to check first task order should create on all opps.
            System.assertEquals(1, processTask.Sequence_Order__c);
            oppIds.add(processTask.Opportunity__c);
        }
        //Assert to check all opportunty have first sequential task.
        System.assertEquals(opportunities.size(), oppIds.size());
    }

    @isTest
    public static void testRestrictProcessFieldToChangeOnBeforeUpdate(){
       List<Opportunity> opportunities = TestUtility.createBulkOpportunities();
       INSERT opportunities;
       INSERT TestUtility.createBulkTaskProcessForOpp(opportunities, 'In Progress', 1);
       System.Test.startTest();
        for(Opportunity opp : opportunities){
            opp.Process__c = 'EV Installation';
        }
        List<Database.SaveResult> results = Database.update(opportunities, false);
        Integer countOfFailedRecords = 0;
        for(Database.SaveResult saveResult : results){
            if(!saveResult.isSuccess()){
                String jsoStringOfError = JSON.serialize(saveResult.getErrors());
                //Assert to check all failed records should contain error message
                System.assert(jsoStringOfError.contains(System.Label.Can_not_modify_process_field));
                countOfFailedRecords++;
            }
        }
        //Assert to check all failed records should count of all opportunity
        System.assertEquals(countOfFailedRecords, opportunities.size());
       System.Test.stopTest();
    }

    @isTest
    public static void testRestrictProcessFieldToChangeOnAfterUpdate(){
       List<Opportunity> opportunities = TestUtility.createBulkOpportunities();
       INSERT opportunities;
       List<Opportunity> oppsToUpdate = new List<Opportunity>();
       for(Opportunity opp : opportunities){
            opp.Process__c = 'EV Installation';
            oppsToUpdate.add(opp);
       }
       System.assertEquals(0, [SELECT count() FROM Process_Task__c]);
       System.Test.startTest();
        UPDATE oppsToUpdate;
       System.Test.stopTest();
       List<Process_Task__c> processTasks = [SELECT Id, Opportunity__c, Sequence_Order__c FROM Process_Task__c];
        Set<Id> oppIds = new Set<Id>();
        //Assert to check same size of process task should have created
        System.assertEquals(opportunities.size(), processTasks.size());
        for(Process_Task__c processTask : processTasks){
            //Assert to check first task order should create on all opps.
            System.assertEquals(1, processTask.Sequence_Order__c);
            oppIds.add(processTask.Opportunity__c);
        }
        //Assert to check all opportunty have first sequential task.
        System.assertEquals(opportunities.size(), oppIds.size());
    }

    @isTest
    public static void testPreventDuplicationAfterUpdate(){
       List<Opportunity> opportunities = TestUtility.createBulkOpportunities();
       INSERT opportunities;
       List<Opportunity> oppsToUpdate = new List<Opportunity>();
       for(Opportunity opp : opportunities){
            opp.Process__c = 'EV Installation';
            oppsToUpdate.add(opp);
       }
       System.assertEquals(0, [SELECT count() FROM Process_Task__c]);
       System.Test.startTest();
        UPDATE oppsToUpdate;
        for(Opportunity opp : oppsToUpdate){
            opp.Process__c = null;
        }
        UPDATE oppsToUpdate;
        for(Opportunity opp : oppsToUpdate){
            opp.Process__c = 'EV Installation';
        }
        UPDATE oppsToUpdate;
       System.Test.stopTest();
       List<Process_Task__c> processTasks = [SELECT Id, Opportunity__c, Sequence_Order__c FROM Process_Task__c];
        Set<Id> oppIds = new Set<Id>();
        //Assert to check same size of process task should have created
        System.assertEquals(opportunities.size(), processTasks.size());
        for(Process_Task__c processTask : processTasks){
            //Assert to check first task order should create on all opps.
            System.assertEquals(1, processTask.Sequence_Order__c);
            oppIds.add(processTask.Opportunity__c);
        }
        //Assert to check all opportunty have first sequential task.
        System.assertEquals(opportunities.size(), oppIds.size());
    }

    @isTest
    public static void testMetadataNotFoudForProcess(){
        List<Opportunity> opportunities = new List<Opportunity>();
        for(Opportunity opp : TestUtility.createBulkOpportunities()){
            opp.Process__c = 'Dummy Process';
            opp.Id = TestUtility.getFakeSalesforceId(Opportunity.SObjectType);
            opportunities.add(opp);
        }
        //Assert no process task should create before execution of trigger
        System.assertEquals(0, [SELECT count() FROM Process_Task__c]);
        System.Test.startTest();
            new OpportunityTriggerHandler().afterInsert((Map<Id, SObject>)new Map<Id, Opportunity>(opportunities));
        System.Test.stopTest();
        //Assert no process task should create after execution of trigger
        System.assertEquals(0, [SELECT count() FROM Process_Task__c]);
    }
}