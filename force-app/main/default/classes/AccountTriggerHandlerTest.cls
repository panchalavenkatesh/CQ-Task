@isTest
public class AccountTriggerHandlerTest {
 
    @testSetup
    static void setupTestData() {
        // Create test permission set
        PermissionSet permSet = new PermissionSet(
            Name = 'Account_Admin_Permission_Set',
            Label = 'Account Admin Permission Set',
            Description = 'Permission set for account admin access'
        );
        insert permSet;

        // Assign permission set to the test user
        PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(
            AssigneeId = UserInfo.getUserId(),
            PermissionSetId = permSet.Id
        );
        insert permSetAssignment;
    }

    @isTest
    static void testDefaultValuesAndValidation() {
        Test.startTest();

        // Test new account creation
        Account newAccount = new Account(Name = 'Test Account');
        insert newAccount;
	    
        // Verify default values are set
        System.assertEquals(false, newAccount.Activate__c);
        List<SQX_Team_Members__c> teamMemberList = [Select Id,Member_Type__c from SQX_Team_Members__c where Account__c =: newAccount.Id LIMIT 2];
        System.assertEquals(2, teamMemberList.size());
        
        teamMemberList[0].Member_Type__c ='HR';
        teamMemberList[1].Member_Type__c ='Admin';
        update teamMemberList;
        
        // Activate account again
        newAccount.Activate__c = true;
        update newAccount;

        // Verify account is activated
        System.assertEquals(true, newAccount.Activate__c);
        List<SQX_Team_Members__c> teamMemberListUpdated = [Select Id,Member_Type__c from SQX_Team_Members__c where Account__c =: newAccount.Id AND  Member_Type__c IN ('HR', 'Admin')];
        System.assertEquals(2, teamMemberList.size());
        
        Test.stopTest();
    }
}