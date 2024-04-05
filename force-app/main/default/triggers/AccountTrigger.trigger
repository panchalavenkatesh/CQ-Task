trigger AccountTrigger on Account (before insert, after insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
                AccountTriggerHandler.setDefaultValues(Trigger.New);
        }
        if (Trigger.isUpdate) {
            // Call method to validate updates to accounts
            AccountTriggerHandler.validateAccounts(Trigger.newMap, Trigger.oldMap);
        }
    }
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            AccountTriggerHandler.insertTeamMembers(Trigger.New);
        }
    }
}