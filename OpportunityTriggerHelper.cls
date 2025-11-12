/**
 * @description : This class holds business logic to be perform on opportuity DML events
 * @author : Gaurav Suryawanshi
 */
public with sharing class OpportunityTriggerHelper {

    /**
     * @description : This method will create process task
     * @param : Map<Id, Opportunity> newOppMap : New map of opportunity.
     *          Map<Id, Opportunity> oldOppMap : Old map of opportunity.
     * @return : void
     */
    public static void createProcessTask(Map<Id, Opportunity> newOppMap, Map<Id, Opportunity> oldOppMap){
        try{
            Map<Id, Process_Task__c> oppIdTOProcessTask = new Map<Id, Process_Task__c>();
            Set<String> proccessValues = new Set<String>();
            //Initiated the task generation process service
            ProcessTaskGenerationService taskGenerationForProcessObj = new ProcessTaskGenerationService(OpportunityConstant.OBJECT_API_NAME, OpportunityConstant.PROCESS_FIELD_API_NAME);
            for(Opportunity opp : newOppMap.values()){
                if(String.isNotBlank(opp.Process__c) && (oldOppMap == null || (String.isNotBlank(opp.Process__c) && 
                                                                               newOppMap.get(opp.Id).Process__c != oldOppMap.get(opp.Id).Process__c))){
                    Task_Configuration__mdt firstTask = taskGenerationForProcessObj.getFirstTaskToCreate(opp.Process__c);
                    if(firstTask == null){
                        opp.Process__c.addError(System.Label.Task_metadata_not_found);
                        continue;
                    }
                    Process_Task__c processTask = taskGenerationForProcessObj.createProcessTask(firstTask, opp.Process__c);
                    processTask.Opportunity__c = opp.Id;
                    oppIdTOProcessTask.put(processTask.Opportunity__c, processTask);
                    proccessValues.add(opp.Process__c);
                }
            }
            if(oldOppMap != null){
                oppIdTOProcessTask = preventDuplicationOfProcessTask(proccessValues, oppIdTOProcessTask);
            }
            List<Database.SaveResult> saveResultList = Database.insert(oppIdTOProcessTask.values(), false, System.AccessLevel.USER_MODE);
            ErrorLogUtil.addSaveResult(saveResultList, oppIdTOProcessTask.values());
        }catch(Exception e){
            ErrorLogUtil.addErrorLog(new ErrorLogUtil.ErrorLogDTO('Error Message : '+e.getMessage()+'\nStackTrace : '+e.getStackTraceString(), 'Exception occured during creation of process task.'));
        }
    }

    /**
     * @description : This method will check the duplicate record is in map. If it is then removed from the map to avoid duplication of task on same opportunity
     * @param : Set<String> proccessValues : Set of string to compare with existing process task
     *          Map<Id, Process_Task__c> oppIdTOProcessTask : Map of opportunity id and process task to remove duplicate process task
     * @return : Map<Id, Process_Task__c> : Map of opportuity Id and process task after removing the duplicate process task.
     */
    public static Map<Id, Process_Task__c> preventDuplicationOfProcessTask(Set<String> proccessValues, Map<Id, Process_Task__c> oppIdTOProcessTask){
        for(AggregateResult aggResult : ProcessTaskSelector.getExistingCountOfProcessTask(proccessValues, oppIdTOProcessTask.keyset())){
            oppIdTOProcessTask.remove((Id) aggResult.get('Opportunity__c'));
        }
        return oppIdTOProcessTask;
    }

    /**
     * @description : This method will check whether opportunity has in progress task. If yes restrict the user to change the field value
     * @param : Map<Id, Opportunity> newOppMap : New map of opportunity.
     *          Map<Id, Opportunity> oldOppMap : Old map of opportunity.
     * @return : void
     */
    public static void restrictProcessFieldToChange(Map<Id, Opportunity> newOppMap, Map<Id, Opportunity> oldOppMap){
        try{
            List<Opportunity> changedOppWithProcessValues = new List<Opportunity>();
            for(Opportunity opp : newOppMap.values()){
                if(opp.Process__c != oldOppMap.get(opp.Id).Process__c){
                    changedOppWithProcessValues.add(opp);
                }
            }

            for(AggregateResult aggResult : ProcessTaskSelector.getCountOfInitiatedOppFromProcessTask(changedOppWithProcessValues)){
                newOppMap.get((Id) aggResult.get('Opportunity__c')).Process__c.addError(System.Label.Can_not_modify_process_field);
            }
        }catch(Exception e){
            ErrorLogUtil.addErrorLog(new ErrorLogUtil.ErrorLogDTO('Error Message : '+e.getMessage()+'\nStackTrace : '+e.getStackTraceString(), 'Exception occured during restriction process on process field.'));
        }
    }    
}