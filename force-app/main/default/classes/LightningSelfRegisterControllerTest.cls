@IsTest(SeeAllData = true)
public with sharing class LightningSelfRegisterControllerTest {

 /* Verifies that IsValidPassword method with various password combinations. */
 @IsTest
 static void testIsValidPassword() {
  System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'password?@12334') == true);
  System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'dummyPassword') == false);
  System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', null) == false);
  System.assert(LightningSelfRegisterController.isValidPassword(null, 'fakePwd') == false);
 }

 @IsTest
 static void testSiteAsContainerEnabled() {
  System.assertNotEquals(null, LightningSelfRegisterController.siteAsContainerEnabled('https://portal-developer-edition.force.com'));
 }

 /* Verifies the selfRegistration method flow with various invalid inputs */
 @IsTest
 static void testSelfRegistration() {
  Map < String, String > paramsMap = initializeParams();
  System.assertNotEquals(null, paramsMap);
  System.assertEquals(Label.Site.lastname_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), '', paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, true, paramsMap.get('movil'), true));
  System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, true, paramsMap.get('movil'), true));
  System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', null, paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, true, paramsMap.get('movil'), true));
  System.assertEquals(Label.site.passwords_dont_match, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, true, paramsMap.get('movil'), true));
  System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false, true, paramsMap.get('movil'), true));
  LightningSelfRegisterController.selfRegister(null, paramsMap.get('lastName'), '', null, paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, true, paramsMap.get('movil'), true);     
  LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), null, paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, false, paramsMap.get('movil'), true);     
  LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), null, paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, true, null, true);          
 }
    /*Introducion del test con la comprobación de si existe o no el contacto o candidato ya en SF*/
    @isTest
    static void testValidarRegistro() {
        Lead candidato = new Lead();
        candidato.FirstName = 'test';
        candidato.LastName = 'TEst';
        candidato.email = 'testUser@salesforce.com';
        candidato.PostalCode = '28224';
        insert candidato;
        
        Map < String, String > paramsMap = initializeParams();
        
        system.Test.startTest();
            LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), null, null, null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, true, paramsMap.get('movil'), true);          
        system.Test.stopTest();
    }
    
    /*Introducion del test con la comprobación de si existe o no el contacto o candidato ya en SF*/
    @isTest
    static void testValidarRegistroContacto() {
        Contact contacto = new Contact();
        contacto.FirstName = 'TEst';
        contacto.LastName = 'TEst';
        contacto.email = 'testUser@salesforce.com';
        insert contacto;
        
        Map < String, String > paramsMap = initializeParams();
        
        system.Test.startTest();
            LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), null, null, null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, true, paramsMap.get('movil'), true);                  	
        system.Test.stopTest();
    }
    
    /*Introducion del test con la comprobación de si existe o no el contacto o candidato ya en SF*/
    @isTest
    static void testValidarRegistroContactoYCandidato(){
        //Para poder insertar duplicados
        Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true; 
        
        Contact contacto = new Contact();
        contacto.FirstName = 'TEst';
        contacto.LastName = 'TEst';
        contacto.email = 'testUser@salesforce.com';
        insert contacto;
        
        Lead candidato = new Lead();
        candidato.FirstName = 'TEst';
        candidato.LastName = 'TEst';
        candidato.email = 'testUser@salesforce.com';
        Database.SaveResult sr = Database.insert(candidato, dml);         
        
        Map < String, String > paramsMap = initializeParams();
        
        system.Test.startTest();
            LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), null, null, null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, true, paramsMap.get('movil'), true);                  	
        system.Test.stopTest();
    }
    
    /*Introducion del test con la comprobación de si existe o no el contacto o candidato ya en SF*/
    @isTest
    static void testValidarRegistroUsuario(){        
        Account cuenta = new Account();
        cuenta.Name = 'test';
        cuenta.Phone = '600000000';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.FirstName = 'TEst';
        contacto.LastName = 'TEst';
        contacto.email = 'testUser@salesforce.com';
        contacto.AccountId = cuenta.id;
        insert contacto;                     
        
        //Creamos el usuario de la comunidad
        Profile p = [SELECT Id FROM Profile WHERE Name='Comunidad Arriaga'];
		        
        
        User u1 = new User( email='testUser@salesforce.com',
                profileid = p.id, 
                UserName='testArriaga160419@arriaga.com', 
                Alias = 'test',
                TimeZoneSidKey='America/New_York',
                EmailEncodingKey='ISO-8859-1',
                LocaleSidKey='en_US', 
                LanguageLocaleKey='en_US',
                ContactId = contacto.Id,
                FirstName = 'Test',
                LastName = 'Test');
        
        insert u1;
        
        Map < String, String > paramsMap = initializeParams();
        
        system.Test.startTest();
            LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), null, null, null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, true, paramsMap.get('movil'), true);                  	
        system.Test.stopTest();
    }


 /* Verifies the selfRegistration flow for valid inputs */
 @IsTest
 static void testSelfRegisterWithProperCredentials() {
  Map < String, String > paramsMap = initializeParams();
  System.assertEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true, true, paramsMap.get('movil'), true));
 }

 /* Verifies SelfRegistration flow with an accounId that is created within the test */
 @IsTest
 static void testSelfRegisterWithCreatedAccount() {
  Account acc = new Account(name = 'test acc',Phone = '600000000');
  insert acc;
  List < Account > accounts = [SELECT Id FROM Account LIMIT 1];
  System.assert(!accounts.isEmpty(), 'There must be at least one account in this environment!');
  String accountId = accounts[0].Id;
  Map < String, String > paramsMap = initializeParams();
  System.assertEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), accountId, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false, true, paramsMap.get('movil'), true));
 }

 @IsTest
 static void testGetNullExtraFields() {
  System.assertEquals(new List < Map < String, Object >> (), LightningSelfRegisterController.getExtraFields(null));
 }

 @IsTest
 static void testGetNonEmptyExtraFields() {
  System.assertEquals(new List < Map < String, Object >> (), LightningSelfRegisterController.getExtraFields('field1'));
 }

 /* Verifies validation of extraFields within the Self Registration flow */
 @IsTest
 static void testGetExtraFieldsInSelfRegistration() {
  List < Map < String, Object >> fieldlist = new List < Map < String, Object >> ();
  Map < String, String > paramsMap = initializeParams();
  Map < String, Object > fieldMap = new Map < String, Object > ();
  fieldMap.put('description', 'new field');
  fieldMap.put('fieldPath', 'dummyPath');
  fieldlist.add(fieldMap);
  String extraFields = JSON.serialize(fieldlist);
  System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), extraFields, paramsMap.get('startUrl'), true, true, paramsMap.get('movil'), true));
 }

 @IsTest
 static void LightningSelfRegisterControllerInstantiation() {
  LightningSelfRegisterController controller = new LightningSelfRegisterController();
  System.assertNotEquals(controller, null);
 }

 /* Helper method to initialize the parameters required for SelfRegistration. */
 private static Map < String, String > initializeParams() {
  Map < String, String > paramsMap = new Map < String, String > ();
  String firstName = 'test';
  String lastName = 'User';
  String email = 'testUser@salesforce.com';
  String password = 'testuser123';
  String confirmPasswordCorrect = 'testuser123';
  String confirmPasswordWrong = 'wrongpassword';
  String accountId = 'testuser123';
  String regConfirmUrl = 'http://registration-confirm.com';
  String startUrl = 'http://my.company.salesforce.com';
  string movil = '665656565';
  paramsMap.put('firstName', firstName);
  paramsMap.put('lastName', lastName);
  paramsMap.put('email', email);
  paramsMap.put('password', password);
  paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
  paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
  paramsMap.put('accountId', accountId);
  paramsMap.put('regConfirmUrl', regConfirmUrl);
  paramsMap.put('startUrl', startUrl);
  paramsMap.put('movil', movil);
  return paramsMap;
 }
}