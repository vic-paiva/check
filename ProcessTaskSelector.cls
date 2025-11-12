/**
 * @description : This class is selector class for Process Task object.  All SOQL on Process Task object saved in this class
 * @author : Gaurav Suryawanshi
 */
public with sharing class ProcessTaskSelector {

    /**
     * @description : This method will get count of process task who has more than 0 in progress task against opportunity.
     * @param : List<Opportunity> opportunitinies : list of opportunity to group process task records
     * @return : List<AggregateResult> : Result of the query
     */
    public static List<AggregateResult> getCountOfInitiatedOppFromProcessTask(List<Opportunity> opportunitinies){
        return [SELECT count(Id), Opportunity__c
                FROM Process_Task__c
                WHERE Status__c = :ProcessTaskConstant.STATUS_PICKLIST_IN_PROGRESS
                AND Opportunity__c IN :opportunitinies
                WITH USER_MODE
                GROUP BY Opportunity__c
                HAVING count(Id) > 0];
    }

    /**
     * @description : This method will get count of process task against the opportunity having filter of list of process names and opportunity ids
     * @param : Set<String> processNames : Set of process name to add filter in query
     *          Set<Id> oppIds           : Set of id to add filter in query
     * @return : List<AggregateResult> : Result of the query
     */
    public static List<AggregateResult> getExistingCountOfProcessTask(Set<String> processNames, Set<Id> oppIds){
        return [SELECT count(Id), Opportunity__c
                FROM Process_Task__c
                WHERE Process_Name__c IN :processNames
                AND Opportunity__c IN :oppIds
                WITH USER_MODE
                GROUP BY Opportunity__c
                HAVING count(Id) > 0];
    }

    /**
     * @description : This method will return process task filtering opportunity ids, process names and sequence numbers.
     * @param : Set<Id> oppIds           : Set of opportunity id
     *          Set<String> processNames : Set of process name
     *          Set<Integer> sequenceNumber : Set of sequence number
     * @return : List<Process_Task__c> : list of process task
     */
    public static List<Process_Task__c> getExistingProcessTaskForOppBasedOnSequenceAndProcessName(Set<Id> oppIds, Set<String> processNames, Set<Integer> sequenceNumbers){
        return [SELECT Opportunity__c, Process_Name__c, Sequence_Order__c
                FROM Process_Task__c
                WHERE Process_Name__c IN :processNames
                AND Sequence_Order__c IN :sequenceNumbers
                AND Opportunity__c IN :oppIds
                WITH USER_MODE];
    }
}