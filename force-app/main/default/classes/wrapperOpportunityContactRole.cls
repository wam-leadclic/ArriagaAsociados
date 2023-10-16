/*Wrapper class con los datos de las funciones de contacto de la oportunidad

FECHA		AUTOR		DESCRIPCION
04/06/2019	LCS -RMG	Creación. Se usa en clase aparte porque sino el componente no puede llamar a la wraper class de dentro de otra clase. Se usa para la generación de la hoja de encargo.
                        No se puede usar directamente el objeto de funciones de contacto de la oportunidad porque el usuario de la comunidad no tiene acceso a esos datos
23/08/2019  LCS - RMG   Modificación. Se añade la variable de tipo de docmento de identidad

*/

public class wrapperOpportunityContactRole{
    public string idRole {get;set;}
    public string role {get;set;}
    public string contactoNombre {get;set;}
    public string contactoTipoDocumentoIdentidad {get;set;}
    public string contactoDocumentoIdentidad {get;set;}
    public string contactoCiudad {get;set;}
    public string contactoTelefono {get;set;}
    public string contactoEmail {get;set;}
    
    public wrapperOpportunityContactRole (){}
    
    public wrapperOpportunityContactRole (OpportunityContactRole oppContactRole){
        idRole = oppContactRole.id;
        role = oppContactRole.Role;
        contactoNombre = oppContactRole.Contact.Name;
        contactoTipoDocumentoIdentidad = oppContactRole.Contact.Account.TipoDocumento__c;
        contactoDocumentoIdentidad = oppContactRole.Contact.Account.DocumentoIdentidad__c;
        contactoCiudad = oppContactRole.Contact.Account.ShippingCity;
        contactoTelefono = oppContactRole.Contact.Account.Phone;
        contactoEmail = oppContactRole.Contact.email;
    }        
}