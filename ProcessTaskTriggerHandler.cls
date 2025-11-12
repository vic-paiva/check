/**
 * @description : This class holds all/required methods which will be fire various DML event on process task records.
 * @author : Gaurav Suryawanshi
 */
public with sharing class ProcessTaskTriggerHandler extends TriggerHandler{
    

    /**
     * @description : This method will execute on after update of process task record
     * @param : Map<Id, SObject> newMap : new map of process task Id and SObject which apparently holds after changed of process task record.
     *          Map<Id, SObject> oldMap : old map of process task Id and SObject which holds before changed of process task record.
     *         
     * @return : void
     */
    public override void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){
        ProcessTaskTriggerHelper.createNextProcessTask((Map<Id, Process_Task__c>) newMap, (Map<Id, Process_Task__c>) oldMap);
        ErrorLogUtil.logCommit();
    }
}