/*
@author LeadClic Solutions S.L.
@date 21/05/2019
@description Trigger para el objeto usuario

<pre>
FECHA             AUTOR           ACCION
21/05/2019		LCS - RMG	   	  Creación. Cuando se crea un usuario de la comunidad se tiene que actualizar la información GDPR del contacto
26/10/2021		LCS - SRG	   	  Modificación. El cliente solicita desactivarlo porque choca con darlo de alta desde la comunidad y le corre prisa.
 
*/
public without sharing class TriggerUsuarioHandler {
    /**
     * Método que se ejecuta al insertar un usuario
     * 
     * @param	Lista con los usuarios que se han insertado
     **/
	public static void afterInsert (list <User> lNewUser) {

    	// list<Id> lIdUsuarioComunidad = new list<Id>();
		// //Recorremos los usuarios y si son de la comunidad los guardamos en la lista
        // for(User usuario :lNewUser){
        //     if(usuario.ContactId != null) lIdUsuarioComunidad.add(usuario.ContactId);
        // }
		
		// //Buscamos los contactos asociados con los usuarios de la comunidad
		// map<Id, Contact> mContactosComunidad = new map<Id, Contact>([SELECT Id, IndividualId 
        //                                     						FROM Contact
        //                                     						WHERE Id IN :lIdUsuarioComunidad]);
        
		// // Actualizamos la información de GDPR del contacto asociado al usuario de la comunidad		
        // list<Individual> lIndividualUpdate = new list<Individual>();
        // for(User usuario :lNewUser){
        //     if(usuario.ContactId != null && mContactosComunidad.containsKey(usuario.ContactId)){
        //         Individual persona = new Individual();
        //         persona.Id =  mContactosComunidad.get(usuario.ContactId).IndividualId;
        //         persona.DeseoRecibirComunicacionesComerciales__c = usuario.DeseoRecibirComunicaciones__c;
        //         persona.AceptoPoliticaPrivacidad__c = usuario.AceptaPoliticaPrivacidad__c;
        //         lIndividualUpdate.add(persona);
        //     }
        // }
       
        // if(!lIndividualUpdate.isEmpty()) update lIndividualUpdate;
    } 
}