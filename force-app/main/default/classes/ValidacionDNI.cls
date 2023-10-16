/*
@author LeadClic Solutions S.L.
@date 29/04/2019
@description Clase que se encarga de validar el DNI, CIF, o pasaporte

<pre>
FECHA                 AUTOR           ACCION
29/04/2019			LCS - RDM		 Creación.
 
*/
public class ValidacionDNI {
   	public static string validarCif(string cif){
   		//Si la longitud del cif es menor de 9 no es correcto
   		if(cif.length() < 9){
   			return Label.DNIincorrecto;
   		}
   		
        //Quitamos el primer caracter y el ultimo digito
        string valueCif = cif.substring(1,cif.length()-1);
        
        Integer suma=0;
        
        //Si al quitar el primer caracter y el último dígito el texto que queda no son todos números no es correcto
        if(!valueCif.isNumeric()){
            return Label.DNIincorrecto;
        }
        //Sumamos las cifras pares de la cadena
        for(Integer i=1;i<valueCif.length();i=i+2)
        {
            suma=suma+Integer.valueOf(valueCif.substring(i,i+1));
        }
        
        Integer suma2=0;
        
        //Sumamos las cifras impares de la cadena
        for(Integer i=0;i<valueCif.length();i=i+2){
            Integer result=Integer.valueOf(valueCif.substring(i,i+1))*2;
            if(String.valueOf(result).length()==1)
            {
                // Un solo caracter
                suma2=suma2+Integer.valueOf(result);
            }else{
                // Dos caracteres. Los sumamos...
                suma2=suma2+Integer.valueOf(String.valueOf(result).substring(0,1))+Integer.valueOf(String.valueOf(result).substring(1,2));
            }
        }
        
        // Sumamos las dos sumas que hemos realizado 
        suma=suma+suma2; 
        
        string unidad;
        
        //Si la suma es menor de 10 se realiza 10 - suma en caso contrario se coge 10 - 2º dígito de la suma.
        if(suma < 10){
            unidad=string.valueOf(10-suma);
            //return false;
        }
        else{
            unidad = String.valueOf(suma).substring(1,2);
            if(unidad != '0'){ 
                unidad=string.valueOf(10-Integer.valueOf(unidad));
            }
        }
        
        string primerCaracter=cif.substring(0,1).toUpperCase(); 
        string primerCaracterPosible = 'FJNPQRSUVWK';
        string primerCaracterPosible2 = 'XYZ';
        string primerCaracterPosible3 = 'ABCDEFGHLM';
        if(primerCaracterPosible.indexOf(primerCaracter) != -1) {
            //Empieza por .... Comparamos la ultima letra 
            //Segun el valor de la unidad obtenemos el digito de control
            //J = 0, A = 1, B = 2, C= 3, D = 4, E = 5, F = 6, G = 7, H = 8, I = 9
            string valorAscii;
            if(unidad == '0') valorAscii='J';
            else if(unidad == '1') valorAscii='A';
            else if(unidad == '2') valorAscii='B';
            else if(unidad == '3') valorAscii='C';
            else if(unidad == '4') valorAscii='D';
            else if(unidad == '5') valorAscii='E';
            else if(unidad == '6') valorAscii='F';
            else if(unidad == '7') valorAscii='G';
            else if(unidad == '8') valorAscii='H';
            else if(unidad == '9') valorAscii='I';
            //Si el ultimo valor coincide con la letra o con el numero que le corresponde el cif es correcto
            if(cif.substring(cif.length()-1,cif.length()).toUpperCase() == valorAscii || cif.substring(cif.length()-1,cif.length()).toUpperCase() == unidad.substring(unidad.length()-1, unidad.length())) return 'OK'; 
        }else if(primerCaracterPosible2.indexOf(primerCaracter) != -1){ 
            //Se valida como un NIE 
            string newcif; 
            if(primerCaracter=='X') newcif=cif.substring(1); 
            else if(primerCaracter=='Y') newcif='1'+cif.substring(1); 
            else if(primerCaracter=='Z') newcif='2'+cif.substring(1); 
            return validarNif(newcif); 
        }else if(primerCaracterPosible3.indexOf(primerCaracter) != -1){ 
            //Se revisa que el ultimo valor coincida con el calculo 
            if(unidad=='10') unidad='0'; 
            if(cif.substring(cif.length()-1,cif.length())==String.valueOf(unidad)) return 'OK'; 
        }else{ 
            //Se valida como un dni 
            return validarNif(cif); 
        } 
        return Label.DNIincorrecto;     
    }
    
    //Metodo para validar el nif
    public static string validarNif(string dni){
        try{
            // Tiene que recibir el dni sin espacios ni guiones
            string lockup = 'TRWAGMYFPDXBNJZSQVHLCKE'; 
            string valueDni=dni.substring(0,dni.length()-1); 
            string letra=dni.substring(dni.length()-1,dni.length()).toUpperCase(); 
            if(lockup.substring(math.mod(Integer.valueOf(valueDni),23),math.mod(Integer.valueOf(valueDni),23)+1)==letra) return 'OK'; 
            return Label.DNIincorrecto; 
        }catch (exception e){
            return Label.DNIErrorNoGestionado;
            //system.debug('Error : ' + e.getMessage());
        }        
    }
}