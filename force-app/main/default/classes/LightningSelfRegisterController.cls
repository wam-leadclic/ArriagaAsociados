/*
@author LeadClic Solutions S.L.
@date 29/04/2019
@description Clase que se encarga de validar el DNI, CIF, o pasaporte del flujo

<pre>
FECHA                 AUTOR           ACCION
29/04/2019			LCS - RDM         Creación.
30/01/2020          LCS - MMV         Cambio para marcar la casilla y que no se les envíe
 
*/
global without sharing class LightningSelfRegisterController {

    public LightningSelfRegisterController() {

    }

    @TestVisible 
    private static boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }
    
    @TestVisible 
    private static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl,'');
        return authConfig.isCommunityUsingSiteAsContainer();
    }
    
    @TestVisible 
    private static void validatePassword(User u, String password, String confirmPassword) {
        if(!Test.isRunningTest()) {
        Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }
    
    @AuraEnabled
    public static String selfRegister(String firstname ,String lastname, String email, String password, String confirmPassword, String accountId, 
                                      String regConfirmUrl, String extraFields, String startUrl, Boolean includePassword, Boolean politicaPrivacidad,
                                     String movil, Boolean recibirComunicaciones) {
        Savepoint sp = null;
        try {
            sp = Database.setSavepoint();
            
            if(firstname == null || firstname == ''){
                return 'El nombre es obligatorio';
            }
            
            if (lastname == null || String.isEmpty(lastname)) {
                return Label.Site.lastname_is_required;
            }
            
            if (email == null || String.isEmpty(email)) {
                return Label.Site.email_is_required;
            }
            
            if (movil == null || String.isEmpty(movil)) {
                return 'El móvil es obligatorio';
            }
            
            if(politicaPrivacidad == false || politicaPrivacidad == null){
                return 'Debe aceptar la política de privacidad';
            }
            
            User u = new User();
            u.Username = email;
            u.put('Email',email);
            u.AceptaPoliticaPrivacidad__c = politicaPrivacidad;
            u.DeseoRecibirComunicaciones__c = recibirComunicaciones;
            u.phone = movil;
            u.FirstName = firstname;
            u.LastName = lastname;
            
            String networkId = Network.getNetworkId();

            // If using site to host the community the user should not hit s1 after logging in from mobile.
            if(networkId != null && siteAsContainerEnabled(Network.getLoginUrl(networkId))) {
                u.put('UserPreferencesHideS1BrowserUI',true);
            }
            
            String nickname = ((firstname != null && firstname.length() > 0) ? firstname.substring(0,1) : '' ) + lastname.substring(0,1);
            nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
            u.put('CommunityNickname', nickname);
                     
            if (extraFields != null) {
                List<Object> extraFieldsList = (List<Object>) JSON.deserializeUntyped(extraFields);        
                for (Object thisFieldObject : extraFieldsList) {
                    Map<String,Object> thisField = (Map<String,Object>) thisFieldObject;
                    Schema.SObjectField sof = Schema.SObjectType.User.fields.getMap().get((String) thisField.get('fieldPath'));
                    u.put(sof, thisField.get('value'));
                }
            }
                        
            if (includePassword) {    
                if (!isValidPassword(password, confirmPassword)) {
                    return Label.site.passwords_dont_match;
                }
             validatePassword(u, password, confirmPassword);
            }
            else {
                password = null;
            }
            
            //30-05-2019 RMG - Creación de la lógica de búsqueda de contacto o candidato antes del registro
            boolean errorCreacionUsuario = false;
            //Antes de crear el usuario se busca si existe algún contacto que tenga el email indicado para el registro
            list<Contact> lContactos = [SELECT Id, Email, AccountId
                                       FROM Contact
                                       WHERE Email = :email];
            
            //Buscamos los candidatos que tienen el email indicado en el formulario de registro
            list<Lead> lCandidatos = [SELECT Id, Email
                                     FROM Lead
                                     WHERE Email = :email
                                     AND IsConverted  = :false];
            
            //Si se ha encontrado más de un usuario se lleva a la página de error
            if((!lContactos.isEmpty() && !lCandidatos.isEmpty() && lContactos.size() > 0 && lCandidatos.size() > 0)
              || (!lContactos.isEmpty() && lContactos.size() > 1) || (!lCandidatos.isEmpty() && lCandidatos.size() > 1) ){
                ApexPages.PageReference pagError = new PageReference(URL.getSalesforceBaseUrl().toExternalForm()  +system.label.PaginaErrorRegistroComunidad);
                if(!Test.isRunningTest()) aura.redirect(pagError);
                errorCreacionUsuario = true;
            }
            //Si se ha encontrado un contacto se busca si existe ya como usuario de la comunindad
            if(errorCreacionUsuario == false && !lcontactos.isEmpty() && lContactos.size() == 1){
                list<User> lUsuario = [SELECT Id 
                                      FROM User
                                      WHERE isActive = true
                                      AND ContactId = :lContactos.get(0).id];
                //Si es usuario de la comunidad le llevamos a una página de error donde se indica que ya es usuario de la comunidad 
                if(!lUsuario.isEmpty()){
                    ApexPages.PageReference pagError = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() +system.label.PaginaErrorRegistroComunidadUsuarioExistente);
                    if(!Test.isRunningTest()) aura.redirect(pagError); 
                    errorCreacionUsuario = true;
                }
            }
                
            //Si se ha encontrado un contacto el nuevo usuario se asocia al contacto y se actualiza la información del contacto
            if(errorCreacionUsuario == false && !lcontactos.isEmpty() && lContactos.size() == 1){
                u.contactId = lContactos.get(0).id;
                accountId = lContactos.get(0).AccountId;
                //Actualizamos la información del contacto
                Contact contactoUpdate = new Contact();
                contactoUpdate.id = lContactos.get(0).id;
                contactoUpdate.FirstName = FirstName;
                contactoUpdate.LastName = LastName;
                contactoUpdate.Phone = movil;
                update contactoUpdate;                
            }
            //Si se ha encontrado un candidato se convierte el candidato a contacto y se asocia el usuario de la comunidad con el candidato convertido 
            //y se actualiza la información del contacto
            if(errorCreacionUsuario == false && !lCandidatos.isEmpty() && lCandidatos.size() == 1){                
                //Actualizamos el candidato para indicar que la conversión se realiza en la comunidad
                Lead candidatoUpdate = new lead();
                candidatoUpdate.id = lCandidatos.get(0).id;
                candidatoUpdate.ConvertidoDesdeComunidad__c = true;
                candidatoUpdate.EnlaceSiteGDPREnviado__c = true;
                update candidatoUpdate;
                
                list<Id> lIdCandidato = new list<Id>();
                lIdCandidato.add(lCandidatos.get(0).id);
                
                //Convertimos el candidato
                map<Id, Id> mCandidatoConvertido = LeadCustomConvert.convertLeads(lIdCandidato);                
                //Si la conversión ha sido correcta asignamos el contacto al usuario
                if(mCandidatoConvertido.containsKey(lCandidatos.get(0).id)){
                    u.contactId = mCandidatoConvertido.get(lCandidatos.get(0).id);
                    //Actualizamos la información del contacto
                    Contact contactoUpdate = new Contact();
                    contactoUpdate.id = u.contactId;
                    contactoUpdate.FirstName = FirstName;
                    contactoUpdate.LastName = LastName;
                    contactoUpdate.Phone = movil;
                    update contactoUpdate; 
                    
                    //Buscamos el contacto que se ha convertido para obtener la cuenta y asignarla al usuario que se crea de la comunidad
                    list<Contact> lContactoConvertido = [SELECT Id, AccountId
                                                         FROM Contact
                                                         WHERE Id = :contactoUpdate.id];
                    
                    if(!lContactoConvertido.isEmpty()) accountId = lContactoConvertido.get(0).AccountId;
                    
                }                
            }            
            //FIN Cambios 30/05/2019
            
            if(errorCreacionUsuario == false){
                // lastName is a required field on user, but if it isn't specified, we'll default it to the username
                String userId = Site.createPortalUser(u, accountId, password);      
                //String userId = Site.createExternalUser(u, accountId, password); //Te da un error más detallado (troubleShoting)         
    
                // create a fake userId for test.
                if (Test.isRunningTest()) {
                    userId = 'fakeUserId';           
                }
                if (userId != null) { 
                    if (password != null && password.length() > 1) {
                        ApexPages.PageReference lgn = Site.login(email, password, startUrl);
                        if(!Test.isRunningTest()) {
                         aura.redirect(lgn);
                        }
                    }
                    else {
                        ApexPages.PageReference confirmRef = new PageReference(regConfirmUrl);
                        if(!Test.isRunningTest()) {
                        aura.redirect(confirmRef);
                       }
    
                    }
                }
            }
            return null;
        }
        catch (Exception ex) {
            Database.rollback(sp);
            return ex.getMessage();            
        }
    }
    
    @AuraEnabled
    public static List<Map<String,Object>> getExtraFields(String extraFieldsFieldSet) { 
        List<Map<String,Object>> extraFields = new List<Map<String,Object>>();
        Schema.FieldSet fieldSet = Schema.SObjectType.User.fieldSets.getMap().get(extraFieldsFieldSet);
        if(!Test.isRunningTest()) {
        if (fieldSet != null) {
            for (Schema.FieldSetMember f : fieldSet.getFields()) {
                Map<String, Object> fieldDetail = new Map<String, Object>();
                fieldDetail.put('dbRequired', f.getDBRequired());
                fieldDetail.put('fieldPath', f.getFieldPath());
                fieldDetail.put('label', f.getLabel());
                fieldDetail.put('required', f.getRequired());
                fieldDetail.put('type', f.getType());
                fieldDetail.put('value', '');   // client will populate
                extraFields.add(fieldDetail);
            }}}
        return extraFields;
    }
    
    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);   
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }        
    }  
}