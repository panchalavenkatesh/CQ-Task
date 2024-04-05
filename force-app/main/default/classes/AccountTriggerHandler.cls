public class AccountTriggerHandler {
    
   public static void setDefaultValues(List<Account> accountList) {
      for (Account acc : accountList) {
      	  acc.Activate__c = false;
      }
   }
       
   public static void insertTeamMembers(List<Account> accountList) {
        
        List<SQX_Team_Members__c> teamMembers = new List<SQX_Team_Members__c>();
            for (Account acc : accountList) {
                for(Integer i=1 ; i <=2 ; i++){
                    SQX_Team_Members__c teammember = new SQX_Team_Members__c();
                    teammember.Name = 'Team Member '+i;
                    teammember.Account__c = acc.Id;
                    teamMembers.add(teammember);
                }
            }
        // insert team members to account
        if(!teamMembers.isEmpty()){
            try{
                insert teamMembers;
            }catch(Exception e){
                System.debug('Error Occured :'+e.getMessage());
            }
            
        }
    }
    
    public static void validateAccounts(Map<Id, Account> newAccountsMap, Map<Id, Account> oldAccountsMap) {
        List<Account> accountsToValidate = new List<Account>();
        List<Id> activatedAccountIds = new List<Id>();
        List<Account> accountsFinal = new List<Account>();
        
        
        // Check if accounts are being activated
        for (Account acc : newAccountsMap.values()) {
            Account oldAccount = oldAccountsMap.get(acc.Id);
            if (acc.Activate__c && !oldAccount.Activate__c) {
                activatedAccountIds.add(acc.Id);
            }
        }
        
        List<Account> accList = [Select id,Name,(Select Id,Member_Type__c,Account__c from SQX_Team_Members__r where Member_Type__c IN ('HR', 'Admin')) from Account where Id IN: activatedAccountIds ];
        for(Account acc : accList){
            Boolean hasHRMember = false;
            Boolean hasAdminMember = false;
        
            List<SQX_Team_Members__c> sqxTeamMembers  = acc.SQX_Team_Members__r;
            for(SQX_Team_Members__c tm : sqxTeamMembers){
                if (tm.Member_Type__c == 'HR') {
                	hasHRMember = true;
                }
                if (tm.Member_Type__c == 'Admin') {
                    hasAdminMember = true;
                }
                
            }
            if( hasHRMember && hasAdminMember){
                    accountsFinal.add(acc);
            }else{
            	acc.addError('Accounts must have team members of HR and Admin member type to be activated.');
        	}
        }
        
        // Validate accounts
        if(!accountsFinal.isEmpty()){
            validateActivation(accountsFinal);
        }
        
    }
    
    private static void validateActivation(List<Account> accounts) {
        Integer permisssionSetCount = [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'Account_Admin'];
        Boolean hasAccountAdminPermission = permisssionSetCount > 0 ? true : false;
        
        for (Account acc : accounts) {
            // Check if the current user has the required permission set
            if (!hasAccountAdminPermission) {
                acc.addError('You do not have permission to activate accounts.');
            }
            
        }
    }
}