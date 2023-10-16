/*
@author LeadClic Solutions S.L.
@date 14/03/2019
@description Clase para acceder a los datos del contacto desde la comunidad

 FECHA		AUTOR		Descripción
14/03/2019	LCS-RMG 	Creación. Clase creada para que devuelva la información del usuario que ha iniciado sesión en la comunidad

*/

public class MiContactoControlador {
	@AuraEnabled
    public static User getInformacionUsuario(){
        return [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() limit 1];
    }
}