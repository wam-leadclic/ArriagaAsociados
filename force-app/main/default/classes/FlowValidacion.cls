/*
@author LeadClic Solutions S.L.
@date 29/04/2019
@description Clase que se encarga de validar el DNI, CIF, o pasaporte del flujo

<pre>
FECHA                 AUTOR           ACCION
29/04/2019			LCS - RDM		 Creación.
17/07/2019			LCS - RDM		 Modificación. Comprobamos si el DNI es enviado o no
 
*/
global class FlowValidacion {
	@InvocableMethod(description = 'Método invocable para validar el DNI')
    global static list<SendParam> MetodoInvocable (list<GetParam> datosValidacion){
        list<SendParam> listres = new list<SendParam>();
        SendParam res = new SendParam();        
        
        //llamamos la clase que valida el dni y obtenemos el mensaje y lo enviamos al flujo
        if(!String.isBlank(datosValidacion[0].dni)) res.respuestaDNI = ValidacionDNI.validarCif(datosValidacion[0].dni);
        
        if(datosValidacion[0].Tlf.isNumeric() && datosValidacion[0].Tlf.length() > 8)  res.respuestaTlf = 'OK';
        else res.respuestaTlf = Label.TlfErroneo;
       
		//comprobamos si hay errores, si es así, enviamos un true
		if((!String.isBlank(datosValidacion[0].dni) && res.respuestaDNI != 'OK') || res.respuestaTlf != 'OK') res.respuesta = true;
        else res.respuesta = false;
        
        
        listres.add(res);
        
        return listres;
    }
    
    /**
     *  Clase que recoge los parametros del flujo
	*/
    global class GetParam{
        @InvocableVariable (label='dni' description='DNI introducido en el flujo donde validamos el valor introducido')
        public String dni;
        @InvocableVariable (label='Tlf' description='Telefono introducido en el flujo donde validamos si el valor es numerico')
        public String Tlf;
    }    
    /**
     *  Clase que envia los parametros del flujo
	*/
    global class SendParam{
        @InvocableVariable (label='respuesta' description='Indica true o false en función de si hay errores')
        public Boolean respuesta;
        @InvocableVariable (label='respuestaDNI' description='Indicaremos si esta OK el DNI o si no enviando el mensaje resultante')
        public String respuestaDNI;  
        @InvocableVariable (label='respuestaTlf' description='Indicaremos si esta OK el telefono o si no enviando el mensaje resultante')
        public String respuestaTlf;       
    }
}