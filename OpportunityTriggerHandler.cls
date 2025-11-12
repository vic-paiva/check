/**
 * @description : This class holds all/required methods which will be fire various DML event on opportunity records.
 * @author : Gaurav Suryawanshi
 */
public with sharing class OpportunityTriggerHandler extends TriggerHandler{
    
    /**
     * @description : This method will execute on after insert of opportunity record
     * @param : Map<Id, SObject> newMap : new map of opportunity Id and SObject which apparently holds opportunity record.
     * @return : void
     */
    public override void afterInsert(Map<Id, SObject> newMap){
        OpportunityTriggerHelper.createProcessTask((Map<Id, Opportunity>) newMap, null);
        ErrorLogUtil.logCommit();
    }

    /**
     * @description : This method will execute on before update of opportunity record
     * @param : Map<Id, SObject> newMap : new map of opportunity Id and SObject which apparently holds after changed opportunity record.
     *          Map<Id, SObject> oldMap : old map of opportunity Id and SObject which holds before changed opportunity record.
     *         
     * @return : void
     */
    public override void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){
        OpportunityTriggerHelper.restrictProcessFieldToChange((Map<Id, Opportunity>) newMap, (Map<Id, Opportunity>) oldMap);
        ErrorLogUtil.logCommit();
    }

    /**
     * @description : This method will execute on after update of opportunity record
     * @param : Map<Id, SObject> newMap : new map of opportunity Id and SObject which apparently holds after changed opportunity record.
     *          Map<Id, SObject> oldMap : old map of opportunity Id and SObject which holds before changed opportunity record.
     *         
     * @return : void
     */
    public override void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){
        OpportunityTriggerHelper.createProcessTask((Map<Id, Opportunity>) newMap, (Map<Id, Opportunity>) oldMap);
        ErrorLogUtil.logCommit();
    }
}