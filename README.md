## Case Study: Task Sequencer
## Brief: This implementation implements the Case Study: Task Sequencer requirements (create process tasks when a Process is chosen on Opportunity and progress tasks on completion).
## Author: Gaurav Suryawanshi

### 1) Salesforce Org Credentils
* Login URL : [Login | Salesforce](https://login.salesforce.com/)
* Username : gauravsuryvanshi+ubitricity@gmail.com
* Password : Dream@123

### 2) Data model and object relationship

#### &emsp; Opportunity (standard object)

* ```Process__c``` Holds picklist name of process ```for eg. EV Installation```

#### &emsp; Process_Task__c (custom object)

* ```Opportunity__c``` Lookup to opportunity object. 

* ```Sequence_Order__c``` Sequence of process tasks associated with a specific process for an opportunity.

* ```Status__c``` It holds the current status of the process task, with available picklist values: Not Started, In Progress, Completed, and Failed. The default value is Not Started when a new process task record is created.

* ```Task_Description__c``` Description of the process task 


* ```Created_By_System__c``` Set true for system-created tasks to distinguish them from manually created tasks.

### 3) Logic behind key automation

#### &emsp; 1. Opportunity ```Process__c``` (insert or update)

* ```OpportunityTrigger``` runs (via ```OpportunityTriggerHandler```).

* ```OpportunityTriggerHelper.createProcessTask()``` is called which:

    * Determines which opportunities need first task 

    * Uses ```ProcessTaskGenerationService``` to read metadata for that Process value and create first ```Process_Task__c``` with ```Sequence_Order__c = 1```, ```Status__c = 'Not Started'```, ```Created_By_System__c = true```, ```Process_Name__c = Name of process from opportunity record``` and ```Task_Description__c = populated from metadata configuration```
    
    

#### &emsp; 2. Process_Task__c status changes (user marks a process task Completed)

* ```ProcessTaskTrigger``` runs and ```ProcessTaskTriggerHandler.afterUpdate``` calls ```ProcessTaskTriggerHelper.createNextProcessTask```.

* The helper detects status changed into ```Completed``` and calls ```ProcessTaskGenerationService``` to create the next task for the same ```Process__c``` from opportunity with ```Sequence_Order__c + 1``` (if a next configured proces task exist in configuration metadata).

* The code avoids creating duplicates via dedup checks and uses Database insert with SaveResults to handle partial failures and log issues.

#### &emsp; 3. Prevent Process change while in-progress process tasks exist

* ```OpportunityTriggerHelper.restrictProcessFieldToChange()``` queries for in-progress process tasks for Opportunities whose ```Process__c``` changed; it adds an ```addError()``` on ```Opportunity.Process__c``` to block changes with a clear label message (the message text is in ```labels``` and visible to users).

#### &emsp; 4. Trigger control

* All triggers are run through the shared TriggerHandler which reads ```Trigger_Setting__mdt``` to allow enabling/disabling trigger behavior (e.g., turn off for data loads).

### 4) Configuration assumptions and trade-offs
#### &emsp; Assumptions

* ```Process__c``` picklist on Opportunity contains values mapped by ```Field_Configuration__mdt```.

* A process task is defined as system-created when ```Created_By_System__c = true```.

* Admins will not enter duplicate ```Field_Value__c``` values for a given ```Field_Configuration__mdt``` and system expects unique task order per field configuration.
* The admin will provide the correct API name ```(Object_API_Name__c)``` of the object and its field ```(Field_API_Name__c)``` in the object configuration ```(Object_Configuration__mdt)```.

* ```Process__c``` picklist on Opportunity contains values mapped by ```Field_Configuration__mdt```.

#### &emsp; Trade-offs
* **Lookup vs. Master-Detail:** Choose a lookup relationship to allow the opportunity and process task to have flexibility of different owners.

### 5) Design approach and rationale

* Lookup to Opportunity : Enable flexible ownership and sharing across all departments

* Custom Metadata Configuration : Provides no code configuration for any object and field's value to create sequential process task.

* Trigger Settings Metadata : Allow runtime control of DML execution without deployment.

### 6) Configuration guide for administrators

#### &emsp; 1) Create Object Configuration

* Go to ```Object Configuration``` custom metadata type and add a record linking:

    * ```Object_API_Name__c``` => ```Opportunity```

    * ```Field_API_Name__```c => ```Process__c```


#### &emsp; 2) Add Field Configuration (one row per process field value)

* Create ```Field_Configuration__mdt``` record:

    * ```Object_Configuration__c``` => (reference to the Object Configuration you created)

    * ```Field_Value__c``` => the picklist value in ```Opportunity.Process__c``` (e.g., ```EV Installation```)

    * ```Active__c``` => ```true```

#### &emsp; 3) Add Task Configuration Steps

* For each step in the process, create ```Task_Configuration__mdt``` records:

    * ```Field_Configuration__c``` => (reference to the Field Configuration you created)

    * ```Task_Order__c``` => 1, 2, 3, ...

    * ```Task_Name__c``` => e.g., ```Step 1 : Site Survery```

    * ```Task_Description__c``` => optional description

* Order is determined by ```Task_Order__c```. Ensure numbers are sequential and unique per ```Field_Configuration__mdt```.

#### &emsp; 4) Trigger Setting

* Optionally edit ```Trigger_Setting__mdt``` records to disable automation or change which trigger events run.

### 7) Potential improvements or extensions
* Notifications when the task is created or completed (for eg. push notification, chatter, email)
* A Lightning custom related list designed to categorize sequential tasks based on different processes.


<!--

# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

-->