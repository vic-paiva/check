/**
 * @description : This is service class of task sequencer
 * @author : Gaurav Suryawanshi
 */
public with sharing class ProcessTaskGenerationService {
    
    Map<String, Map<Integer, Task_Configuration__mdt>> stepOrderToTaskConfiguration = new Map<String, Map<Integer, Task_Configuration__mdt>>();

    /**
     * @description : This counstructor have query on configuration metadata and put in map in order of process name, sequence number, task configuration metadata
     * @param : String sObjectName : Name of sobject name 
     *          String fieldName : Name of field name from sobject which is passed in first parameter
     */
    public ProcessTaskGenerationService(String sObjectName, String fieldName){
        for(Task_Configuration__mdt taskConfiguration : [SELECT Id, Task_Name__c, Task_Order__c, Task_Description__c, Field_Configuration__r.Field_Value__c 
                                                        FROM Task_Configuration__mdt
                                                        WHERE Field_Configuration__r.Object_Configuration__r.Field_API_Name__c = :fieldName 
                                                        AND Field_Configuration__r.Object_Configuration__r.Object_API_Name__c = :sObjectName
                                                        AND Field_Configuration__r.Active__c = true
                                                        WITH USER_MODE
                                                        ORDER BY Task_Order__c]){
            if(!stepOrderToTaskConfiguration.containskey(taskConfiguration.Field_Configuration__r.Field_Value__c)){
                stepOrderToTaskConfiguration.put(taskConfiguration.Field_Configuration__r.Field_Value__c, new Map<Integer, Task_Configuration__mdt>());
            }
            stepOrderToTaskConfiguration.get(taskConfiguration.Field_Configuration__r.Field_Value__c).put(Integer.valueOf(taskConfiguration.Task_Order__c), taskConfiguration);
        }
    }

    /**
     * @description : This method will return the first task to be created on process task against sobject
     * @param : String fieldValue : Name of field value 
     * @return : Task_Configuration__mdt : configuration task record
     */
    public Task_Configuration__mdt getFirstTaskToCreate(String fieldValue){
        
        Map<Integer, Task_Configuration__mdt> taskConfigurations = stepOrderToTaskConfiguration.get(fieldValue);
        if(taskConfigurations == null){
            return null;
        }
        Task_Configuration__mdt firstTask = taskConfigurations.get(1);
        return firstTask;
    }

    /**
     * @description : This method will return the count of total task related field value
     * @param : String fieldValue : Name of field value 
     * @return : Integer : count of task configuration
     */
    public Integer getCountOfTaskForProcess(String fieldValue){
        Map<Integer, Task_Configuration__mdt> taskConfigurations = stepOrderToTaskConfiguration.get(fieldValue);
        if(taskConfigurations == null){
            return null;
        }
        return taskConfigurations.size();
    }

    /**
     * @description : This method will return the task configuration metadata based on field value and next task number
     * @param : String fieldValue : Name of field value 
     *        : Integer nextTaskNumber : number of next task number
     * @return : Task_Configuration__mdt : next task configuration record
     */
    public Task_Configuration__mdt getNextProcessTask(String fieldValue, Integer nextTaskNumber){
        Map<Integer, Task_Configuration__mdt> taskConfigurations = stepOrderToTaskConfiguration.get(fieldValue);
        if(taskConfigurations == null){
            return null;
        }
        Task_Configuration__mdt nextTask = taskConfigurations.get(nextTaskNumber);
        return nextTask;
    }

    /**
     * @description : This method will create an instance of process task record
     * @param : Task_Configuration__mdt taskConfiguration : Task configuration metadata to mapped process field field values 
     *        : String processName : Name of process.
     * @return : Process_Task__c : New instance of process task
     */
    public Process_Task__c createProcessTask(Task_Configuration__mdt taskConfiguration, String processName){
        Process_Task__c processTask = new Process_Task__c();
        processTask.Process_Name__c = processName;
        processTask.Name = taskConfiguration.Task_Name__c;
        processTask.Task_Description__c = taskConfiguration.Task_Description__c;
        processTask.Sequence_Order__c = taskConfiguration.Task_Order__c;
        processTask.Created_By_System__c = true;
        return processTask;
    }
}