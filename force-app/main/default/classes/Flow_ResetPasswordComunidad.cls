/*
@author LeadClic Solutions S.L.
@date 23/04/2019
@description Clase que resetea la contraseña de los usuarios. Este método se llama desde el flujo "Comunidad Reset Password"

<pre>
FECHA                 AUTOR           ACCION
23/04/2019			LCS - RMG		 Creación.
 
*/
public class Flow_ResetPasswordComunidad {
	/**
     *  Método que envia un email al usuario para que pueda realizar el cambio de contraseña del usuario de la comunidad
     */
    @InvocableMethod(label='Llamada flujo' description='Llamada desde el flujo')
    public static void resetearPassword(){
        id IdUsuario = system.UserInfo.getUserId();
        //Método del sistema para resetear la contraseña indicando la plantilla de email que hay que mandar al usuario
        system.resetPasswordWithEmailTemplate(IdUsuario, true, system.label.plantillaEmailCambioContrasena);
    }
}