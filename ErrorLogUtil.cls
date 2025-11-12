/**
 * @description : This util class allow user to log errors, warnings, infos and later commit to database
 * @author : Gaurav Suryawanshi
 */
public with sharing class ErrorLogUtil {
 
    static List<Error__c> logs = new List<Error__c>();

    /**
     * @description : This method will add an error if any save result has failed result
     * @param : List<Database.SaveResult> saveResultList : Results of DML of sobjectList
     *          List<SObject> sobjectList : List of sobject on DML has performed
     * @return : void
     */
    public static void addSaveResult(List<Database.SaveResult> saveResultList, List<SObject> sobjectList){
        if((saveResultList != null && sobjectList != null) &&
           (saveResultList.size() != 0 && sobjectList.size() != 0) &&
           (saveResultList.size() == sobjectList.size())){
                Integer index = 0;
                for(Database.SaveResult result : saveResultList){
                    if(!result.isSuccess()){
                        String error = 'Error Log : ' +JSON.serializePretty(result.getErrors())+'\n\n Saleforce Record : '+JSON.serializePretty(sobjectList[index]);
                        ErrorLogUtil.addErrorLog(new ErrorLogUtil.ErrorLogDTO(error, 
                                                                      'Error while inserting/updating SF object record : '+result.getId()));
                    }
                    index++;
                }
        }else{
            if((saveResultList != null && sobjectList != null) &&
                (saveResultList.size() != sobjectList.size())){
                    ErrorLogUtil.addErrorLog(new ErrorLogUtil.ErrorLogDTO('Save Result Records : '+JSON.serializePretty(saveResultList)+'\n\n Saleforce Object Records : '+JSON.serializePretty(sobjectList), 
                                                                 'Save result list and sObject list size does not match on '+Datetime.now()));
            }
        }
    }

    /**
     * @description : This method will create an instance of Error__c for "Error" severity and add in static variable
     * @param : ErrorLogDTO errorLog : The paramater holds error information 
     * @return : void
     */
    public static void addErrorLog(ErrorLogDTO errorLog){
        if(errorLog != null){
            Error__c error = new Error__c();
            error.Severity__c = 'Error';
            error.Error_Message__c = errorLog.message;
            error.Description__c = errorLog.description;
            error.User__c = UserInfo.getUserId();
            logs.add(error);
        }
    }

    /**
     * @description : This method will create an instance of Error__c for "Info" severity and add in static variable
     * @param : ErrorLogDTO infoLog : The paramater holds info severity information 
     * @return : void
     */
    public static void addInfoLog(ErrorLogDTO infoLog){
        if(infoLog != null){
            Error__c error = new Error__c();
            error.Severity__c = 'Info';
            error.Error_Message__c = infoLog.message;
            error.Description__c = infoLog.description;
            error.User__c = UserInfo.getUserId();
            logs.add(error);
        }
    }

    /**
     * @description : This method will create an instance of Error__c for "Warning" severity and add in static variable
     * @param : ErrorLogDTO warningLog : The paramater holds Warning severity information 
     * @return : void
     */
    public static void addWarningLog(ErrorLogDTO warningLog){
        if(warningLog != null){
            Error__c error = new Error__c();
            error.Severity__c = 'Warning';
            error.Error_Message__c = warningLog.message;
            error.Description__c = warningLog.description;
            error.User__c = UserInfo.getUserId();
            logs.add(error);
        }
    }

    /**
     * @description : This method will commits errors to database 
     * @param : 
     * @return : void
     */
    public static void logCommit() {
        try{
            if(!logs.isEmpty()){
                UPSERT as user logs;
            }
        }catch(Exception e){
            System.debug('Exception while Inserting Error Log '+e.getMessage());
            System.debug('\nStackTrace : '+e.getStackTraceString());
            System.debug('\nUser Id : '+UserInfo.getUserId());
            System.debug('\nOrganization Id : '+UserInfo.getOrganizationId());
            System.debug('\nLog Data : '+JSON.serializePretty(logs)) ;
        }
    }

    public class ErrorLogDTO {
        String message;
        String description;
        public ErrorLogDTO(String message, String description){
            this.message  = message;
            this.description = description;
        }
    }

}