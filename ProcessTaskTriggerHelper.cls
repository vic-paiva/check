/**
 * @description : This class holds business logic to be perform on process task DML events
 * @author : Gaurav Suryawanshi
 */
public with sharing class ProcessTaskTriggerHelper {
    
    /**
     * @description : This method will create next process task based on previous sequential task number
     * @param : Map<Id, Process_Task__c> newOppMap : New map of process task.
     *          Map<Id, Process_Task__c> oldOppMap : Old map of process task.
     * @return : void
     */
    public static void createNextProcessTask(Map<Id, Process_Task__c> newProcessTasks, Map<Id, Process_Task__c> oldProcessTasks){
        try{
            String STATUS_PICKLIST_COMPLETED = ProcessTaskConstant.STATUS_PICKLIST_COMPLETED;
            //Initiated the task generation process service
            ProcessTaskGenerationService taskGenerationForProcessObj = new ProcessTaskGenerationService(OpportunityConstant.OBJECT_API_NAME, OpportunityConstant.PROCESS_FIELD_API_NAME);
            Map<Id, Process_Task__c> opportunityIdTOProcessTask = new Map<Id, Process_Task__c>();
            Set<String> processNames = new Set<String>();
            Set<Integer> sequenceNumber = new Set<Integer>();
            for(Process_Task__c processTask : newProcessTasks.values()){
                if(processTask.Status__c == STATUS_PICKLIST_COMPLETED &&
                processTask.Status__c != oldProcessTasks.get(processTask.Id).Status__c){
                    //get total number of sequence task related to the process stored in metadata configuration
                    Integer totalTasks = taskGenerationForProcessObj.getCountOfTaskForProcess(processTask.Process_Name__c);
                    if(totalTasks == null){
                        ErrorLogUtil.addErrorLog(new ErrorLogUtil.ErrorLogDTO('Process Task Record : '+System.JSON.serializePretty(processTask), 
                                                                            'No configuration meta found for : '+processTask.Process_Name__c+' on '+ProcessTask.opportunity__c));
                        continue;
                    }
                    //If current process task sequence number is less than total number of task then allow to create next process task.
                    if(processTask.Sequence_Order__c < totalTasks){
                        Integer nextTaskSequenceNumber = Integer.valueOf(processTask.Sequence_Order__c) + 1;
                        Task_Configuration__mdt nextTask = taskGenerationForProcessObj.getNextProcessTask(processTask.Process_Name__c, nextTaskSequenceNumber);
                        if(nextTask == null){
                            ErrorLogUtil.addErrorLog(new ErrorLogUtil.ErrorLogDTO('Process Task Record : '+System.JSON.serializePretty(processTask), 
                                                                            'No configuration proccess task found for : '+processTask.Process_Name__c+' on '+ProcessTask.opportunity__c+' for this sequence number : '+nextTaskSequenceNumber));
                            continue;
                        }
                        Process_Task__c newProcessTask = taskGenerationForProcessObj.createProcessTask(nextTask, processTask.Process_Name__c);
                        newProcessTask.Opportunity__c = processTask.Opportunity__c;
                        opportunityIdTOProcessTask.put(newProcessTask.Opportunity__c, newProcessTask);
                        processNames.add(processTask.Process_Name__c);
                        sequenceNumber.add(nextTaskSequenceNumber);
                    }
                }
            }
            opportunityIdTOProcessTask = preventDuplicateCreationOfTask(opportunityIdTOProcessTask, processNames, sequenceNumber);
            List<Database.SaveResult> saveResultList = Database.insert(opportunityIdTOProcessTask.values(), false, System.AccessLevel.USER_MODE);
            ErrorLogUtil.addSaveResult(saveResultList, opportunityIdTOProcessTask.values());
        }catch(Exception e){
            ErrorLogUtil.addErrorLog(new ErrorLogUtil.ErrorLogDTO('Error Message : '+e.getMessage()+'\nStackTrace : '+e.getStackTraceString(), 'Exception occured during creation of process task.'));
        }
    }

    /**
     * @description : This method will prevent the duplicate creation of next process task
     * @param : Map<Id, Process_Task__c> opportunityIdTOProcessTask : map of opportunity id and process task to remove duplicate next process task
     *          Set<String> processNames : Set of process to check existing process task
     *          Set<Integer> sequenceNumbers : Set of integer to check existing process task
     * @return : Map<Id, Process_Task__c> : Map of opportunity and process task after removing the duplicate process task
     */
    private static Map<Id, Process_Task__c> preventDuplicateCreationOfTask(Map<Id, Process_Task__c> opportunityIdTOProcessTask, Set<String> processNames, Set<Integer> sequenceNumbers){
        for(Process_Task__c processTask : ProcessTaskSelector.getExistingProcessTaskForOppBasedOnSequenceAndProcessName(opportunityIdTOProcessTask.keyset(), processNames, sequenceNumbers)){
            if(opportunityIdTOProcessTask.containskey(processTask.Opportunity__c)){
                Process_Task__c existingProcessTask = opportunityIdTOProcessTask.get(processTask.Opportunity__c);
                if(existingProcessTask.Process_Name__c == processTask.Process_Name__c && 
                existingProcessTask.Sequence_Order__c == processTask.Sequence_Order__c){
                    opportunityIdTOProcessTask.remove(processTask.Opportunity__c);
                }
            }
        }
        return opportunityIdTOProcessTask;
    }
}