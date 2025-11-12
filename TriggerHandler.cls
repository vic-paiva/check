/**
 * @description : This class executes trigger event based on configuration in trigger setting metadata.
 * @author : Gaurav Suryawanshi
 */
public with sharing abstract class TriggerHandler {

    Trigger_Setting__mdt triggerSetting;

    public virtual void beforeInsert(List<SObject> newList) {}

    public virtual void afterInsert(Map<Id, SObject> newMap) {}

    public virtual void beforeUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {}

    public virtual void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {}

    public virtual void beforeDelete(Map<Id, SObject> oldMap) {}

    public virtual void afterDelete(Map<Id, SObject> oldMap) {}

    public virtual void afterUnDelete(Map<Id, SObject> newMap) {}

    /**
     * @description : This method will initiate the trigger event methods
     * @param : String triggerName : Name of object trigger
     */
    public void run(String triggerName){
        triggerSetting = [SELECT Is_Active__c, Is_After__c, Is_Before__c, Is_Delete__c, Is_Insert__c, Is_Undelete__c, Is_Update__c
                          FROM Trigger_Setting__mdt 
                          WHERE DeveloperName = :triggerName
                          WITH USER_MODE
                          LIMIT 1];
        if(triggerSetting == null){
            throw new UbitricityException('Trigger name not found. Please configured from Trigger Setting custom metadata.');
        }

        if(triggerSetting.Is_Active__c){
            if(Trigger.isInsert && triggerSetting.Is_Insert__c){
                if(Trigger.isAfter && triggerSetting.Is_After__c){
                    afterInsert(Trigger.newMap);
                }else if(Trigger.isBefore && triggerSetting.Is_Before__c){
                    beforeInsert(Trigger.new);
                }
            }else if(Trigger.isUpdate && triggerSetting.Is_Update__c){
                if(Trigger.isAfter && triggerSetting.Is_After__c){
                    afterUpdate(Trigger.newMap, Trigger.oldMap);
                }else if(Trigger.isBefore && triggerSetting.Is_Before__c){
                    beforeUpdate(Trigger.newMap, Trigger.oldMap);
                }
            }else if(Trigger.isDelete && triggerSetting.Is_Delete__c){
                 if(Trigger.isAfter && triggerSetting.Is_After__c){
                    afterDelete(Trigger.oldMap);
                }else if(Trigger.isBefore && triggerSetting.Is_Before__c){
                    beforeDelete(Trigger.oldMap);
                }
            }else if(Trigger.isUndelete && triggerSetting.Is_Undelete__c){
                if(Trigger.isAfter && triggerSetting.Is_After__c){
                    afterUnDelete(Trigger.newMap);
                }
            }
        }
    }
    
}