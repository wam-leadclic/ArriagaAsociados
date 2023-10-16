/*
@author LeadClic Solutions S.L.
@date 17/04/2019
@description Clase que se encarga de actualizar la información del usuario de la comunidad, no se puede hacer la actualización del objeto de cuenta personal y usuario todo en la misma
			ejecución y por eso se necesita la clase a futuro

<pre>
FECHA                 AUTOR           ACCION
17/04/2019			LCS - RMG		 Creación.
 
*/
public class ActualizarInfoUsuarioComunidad {
	
     /**
     *  Método que se llama desde el trigger de cuenta
     *  
     * @param  lista de id de los contactos que han sufrido cambio en su correo electrónico
     */
    
    @future
    public static void actualizarEmailUsuarios(List<ID> lIdContactos){
        //Buscamos si los contactos tienen un usuario de la comunidad relacionado
        list<User> lUsuariosComunidad = new list<User>();
        if(!lIdContactos.isEmpty()){
            lUsuariosComunidad = [SELECT Id, ContactId, Username, Email, Contact.AccountId, Contact.Account.PersonEmail
                                    FROM User
                                    WHERE ContactId = :lIdContactos
                                    AND IsActive = true];
        }

        //Actualizamos la información del usuario de la comunidad para modificar el email y el nombre de usuario
        list<User> lUsuariosModificados = new list<User>();               
                
        //Recorro los contactos que han modificado el email y si tienen un usuario de la comunidad les cambiamos el email y el nombre de usuario
        for(User usuario :lUsuariosComunidad){
            usuario.Email = usuario.Contact.Account.PersonEmail;
            usuario.Username = usuario.Contact.Account.PersonEmail;
			lUsuariosModificados.add(usuario);
        }
        
        //Modificamos los usuarios
        if(!lUsuariosModificados.isEmpty()) Update lUsuariosModificados;
    }
}