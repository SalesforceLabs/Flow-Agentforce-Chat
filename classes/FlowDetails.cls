@JsonAccess(serializable='always' deserializable='always')
global class FlowDetails {
    
    @AuraEnabled
    global String flowApiName;
    
    @AuraEnabled
    global String flowLabel;
    
    @AuraEnabled
    global String inputVariables;
    
    @AuraEnabled
    global String outputVariables;
    
    @AuraEnabled
    global String flowStatus;
    
    @AuraEnabled
    global String sessionId;
}
