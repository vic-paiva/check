/**
 * @description : This is test clss for Process_Task__c object trigger and dependent classes
 * @author : Gaurav Suryawanshi
 */
@isTest
public with sharing class ProcessTaskTriggerTest {
    
    @TestSetup
    public static void makeTestData(){
        List<Opportunity> opportunities = new List<Opportunity>();
        for(Opportunity opp : TestUtility.createBulkOpportunities()){
            opp.Process__c = 'EV Installation';
            opportunities.add(opp);
        }
        INSERT opportunities;
    }

    @isTest
    public static void testCreateNextProcessTaskAfterUpdate(){
        List<Process_Task__c> existingProcessTask = new List<Process_Task__c>();
        Integer totalOpps = [SELECT count() FROM Opportunity];
        for(Process_Task__c processTask : [SELECT Id, Status__c 
                                           FROM Process_Task__c]){
            processTask.Status__c = 'Completed';
            existingProcessTask.add(processTask);
        }
        //Asserted the process records should be same as opportunities
        System.assertEquals(totalOpps, existingProcessTask.size());
        System.Test.startTest();
            UPDATE existingProcessTask;
        System.Test.stopTest();
        //Asserted the process records should be same as opportunities
        Integer countOfNextSequenceTask = 0; 
        List<Process_Task__c> allProcessTasks = [SELECT Sequence_Order__c FROM Process_Task__c];
        for(Process_Task__c processTask : allProcessTasks){
            if(processTask.Sequence_Order__c == 2){
                countOfNextSequenceTask++;
            }
        }
        //Asserted each opportunity should have 2 process task
        System.assertEquals(totalOpps * 2, allProcessTasks.size());
        //Asserted each opportunity have next process task created
        System.assertEquals(totalOpps, countOfNextSequenceTask);
    }

    @isTest
    public static void testPreventDuplicationOfTaskAfterUpdate(){
        List<Process_Task__c> existingProcessTask = new List<Process_Task__c>();
        Integer totalOpps = [SELECT count() FROM Opportunity];
        for(Process_Task__c processTask : [SELECT Id, Status__c 
                                           FROM Process_Task__c]){
            processTask.Status__c = 'Completed';
            existingProcessTask.add(processTask);
        }

        UPDATE existingProcessTask;

        for(Process_Task__c processTask : existingProcessTask){
            processTask.Status__c = 'Failed';
        }
        
        UPDATE existingProcessTask;

        for(Process_Task__c processTask : existingProcessTask){
            processTask.Status__c = 'Completed';
        }
        //Asserted to result before updating the process task should be twice as opportunity
        System.assertEquals(totalOpps * 2, [SELECT count() FROM Process_Task__c]);
        System.Test.startTest();
        UPDATE existingProcessTask; 
        System.Test.stopTest();
        //Asserted to result before updating the process task should be twice as opportunity
        System.assertEquals(totalOpps * 2, [SELECT count() FROM Process_Task__c]);
    }

    @isTest
    public static void testNoProcessNameAvailableAfterUpdate(){
        List<Process_Task__c> existingProcessTask = new List<Process_Task__c>();

        for(Process_Task__c processTask : [SELECT Id, Status__c, Process_Name__c 
                                           FROM Process_Task__c]){
            processTask.Status__c = 'Completed';
            processTask.Process_Name__c = 'Dummy Process';
            existingProcessTask.add(processTask);
        }
        //Asserted no error log should created 
        System.assertEquals(0, [SELECT count() FROM Error__c]);
        System.Test.startTest();
        UPDATE existingProcessTask; 
        System.Test.stopTest();
        //Asserted same size of error log for process task should create
        System.assertEquals(existingProcessTask.size(), [SELECT count() FROM Error__c]);
    }
}