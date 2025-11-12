/**
 * @description : This trigger will fire on DML events of opportunity records.
 * @author : Gaurav Suryawanshi
 */
trigger OpportunityTrigger on Opportunity (before insert, after insert, after update, before update, before delete, after delete, after undelete) {
    new OpportunityTriggerHandler().run('OpportunityTrigger');
}