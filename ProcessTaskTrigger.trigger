/**
 * @description : This trigger will fire on DML events of opportunity records.
 * @author : Gaurav Suryawanshi
 */
trigger ProcessTaskTrigger on Process_Task__c (before insert, after insert, after update, before update, before delete, after delete, after undelete) {
    new ProcessTaskTriggerHandler().run('ProcessTaskTrigger');
}