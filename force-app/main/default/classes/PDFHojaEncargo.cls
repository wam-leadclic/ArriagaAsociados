/*
Muestra la hoja de encargo según los campos que hay en el objeto de hoja de encargo y que muestre los estilos como están en el campo definido

FECHA		AUTOR		DESCRIPCION
04/06/2019	LCS -RMG	Creación
18/06/2019  LCS - RMG   Modificación. Como los usuarios de la comunidad no pueden acceder al objeto oportunidad y funciones de contacto de la oportunidad hay que guardar los datos 
                        en una wrapper class para poder mostrarlo en la VF
23/08/2019  LCS - RMG   Modificación. Se recupera el tipo de documento de las cuentas que son funciones de contacto de la oportundiad
18/03/2020	LCS - RDM	Modificación. Se añade el control del check para mostrar o no descuento en función de lo marcado en la opp

*/
public without sharing class PDFHojaEncargo {
	
    public HojaEncargo__c hojaEnc;
    public Id idOpp;
    transient Opportunity oportunidad;
    transient list<string> lVariablesDinamicasValidas;
    transient list<string> lVariablesDinamicasNoValidas;
    public wrapperOpportunityContactRole contratanteRol{get;set;}
    public list<wrapperOpportunityContactRole> lTitulares{get;set;}
    public list<wrapperOpportunityContactRole> lRepresentantes{get;set;}
    public wrapperOportunidad wOportunidad; 
    public boolean catalan{get;set;}
    
    public PDFHojaEncargo(){
        //Recuperamos de la url el id de la oportunidad
        idOpp = apexpages.currentpage().getparameters().get('id');
        //Buscamos los datos de la oportunidad que son estáticos y los que se usan en la cabecera del PDF
        oportunidad = [SELECT Id, HojaEncargo__c, HojaEncargo__r.PDFDatosArriaga__c, HojaEncargo__r.PDFObjetoEncargo__c, HojaEncargo__r.PDFHonorarios__c, 
                                HojaEncargo__r.PDFTerceros__c, HojaEncargo__r.PDFDesistimiento__c, HojaEncargo__r.PDFDatosDescuento__c, NumeroExpediente__c,
                                Owner.Name, Owner.Phone, CloseDate, AccountId, Owner.Contact.AccountId, Aplicar_Descuento_en_PF__c, HojaEncargo__r.catalan__c
                       FROM Opportunity 
                       WHERE id = :idOpp];  
           
        //Indicamos el nombre del fichero para cuando el usuario lo guarde
        string nombreFichero = 'HE';
        if(oportunidad.NumeroExpediente__c != null) nombreFichero += oportunidad.NumeroExpediente__c;
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+nombreFichero+'.pdf'); 

        //Inicializamos las variables
        
        lVariablesDinamicasValidas = new list<string>();
        lVariablesDinamicasNoValidas = new list<string>();
        contratanteRol = new wrapperOpportunityContactRole();
        lTitulares = new list<wrapperOpportunityContactRole>();
        lRepresentantes = new list<wrapperOpportunityContactRole>();
        if(oportunidad.HojaEncargo__c!= null){
		catalan = oportunidad.HojaEncargo__r.catalan__c;}
        //Buscamos los roles asociados a la oportunidad
        rolesContactoOportunidad();

        //Inicializamos los valores de la wrapper class de oportunidad
        wOportunidad = new wrapperOportunidad(oportunidad);
    }
    
    //Método que devuelve los datos de la oportunidad
    public wrapperOportunidad getWOportunidad(){
        return wOportunidad;
    }
    
    //Método que sustituye la parte dinámica de la hoja de encargo con su correspondientes valores
    public HojaEncargo__c gethojaEnc(){                
        //Creamos la hoja de encargo que se muestra en la VF
        HojaEncargo__c hojaEncargo = new HojaEncargo__c();
        hojaEncargo.PDFDatosArriaga__c = Oportunidad.HojaEncargo__r.PDFDatosArriaga__c;
        hojaEncargo.PDFObjetoEncargo__c = Oportunidad.HojaEncargo__r.PDFObjetoEncargo__c;
        hojaEncargo.PDFHonorarios__c = Oportunidad.HojaEncargo__r.PDFHonorarios__c;
        hojaEncargo.PDFTerceros__c = Oportunidad.HojaEncargo__r.PDFTerceros__c;
        hojaEncargo.PDFDesistimiento__c = Oportunidad.HojaEncargo__r.PDFDesistimiento__c;  
        hojaEncargo.PDFDatosDescuento__c = Oportunidad.HojaEncargo__r.PDFDatosDescuento__c;            
            

        //Recorremos los campos y si existe "{! nombre variable}" nos quedamos para buscar el dato a través de query
        list<string> lVariables = new list<string> ();
        obtenerCamposDinamicos(Oportunidad.HojaEncargo__r.PDFDatosArriaga__c, lVariables);
        obtenerCamposDinamicos(Oportunidad.HojaEncargo__r.PDFObjetoEncargo__c, lVariables);
        obtenerCamposDinamicos(Oportunidad.HojaEncargo__r.PDFHonorarios__c, lVariables);
        obtenerCamposDinamicos(Oportunidad.HojaEncargo__r.PDFTerceros__c, lVariables);
        obtenerCamposDinamicos(Oportunidad.HojaEncargo__r.PDFDesistimiento__c, lVariables);
        obtenerCamposDinamicos(Oportunidad.HojaEncargo__r.PDFDatosDescuento__c, lVariables);

        //Ejecutamos la query de oportunidades para buscar los datos dinámicos de la oportunidad
        sObject objQuery;
        if(!lVariables.isEmpty()) objQuery = queryOportunidad(lVariables);            
        
        //Recorremos los campos y se va sustituyendo la parte dinámica con los datos de la query obtenida anteriormente
        hojaEncargo.PDFDatosArriaga__c = sustituirCamposDinamicos (Oportunidad.HojaEncargo__r.PDFDatosArriaga__c, objQuery);
        hojaEncargo.PDFObjetoEncargo__c = sustituirCamposDinamicos (Oportunidad.HojaEncargo__r.PDFObjetoEncargo__c, objQuery);
        hojaEncargo.PDFHonorarios__c = sustituirCamposDinamicos (Oportunidad.HojaEncargo__r.PDFHonorarios__c, objQuery);
        hojaEncargo.PDFTerceros__c = sustituirCamposDinamicos (Oportunidad.HojaEncargo__r.PDFTerceros__c, objQuery);
        hojaEncargo.PDFDesistimiento__c = sustituirCamposDinamicos (Oportunidad.HojaEncargo__r.PDFDesistimiento__c, objQuery);  
        hojaEncargo.PDFDatosDescuento__c = sustituirCamposDinamicos (Oportunidad.HojaEncargo__r.PDFDatosDescuento__c, objQuery);                     
        
        return hojaEncargo;
    }

    /**
    * Método que se encarga de buscar los campos dinámicos indicados en el bloque correspondiente que se muestra en el PDF
    *
    * @param  bloque: campo que tiene los datos dinámicos
    * @param  lVariables: lista con los campos dinámicos que se tiene en el bloque
    */
    private void obtenerCamposDinamicos(string bloque, list<string> lVariables){
        //Recorremos los campos y si existe "{! nombre variable} nos quedamos para buscar el dato a través de query"                
        if(bloque != null){
            while(bloque.contains('{!') && bloque.contains('}')){
                integer inicio = bloque.indexOf('{!');
                integer fin = bloque.indexOf('}');            
                lVariables.add(bloque.substring(inicio+2, fin));            
                bloque  = bloque.substring(fin+1);                 
            }
        }
    }

    /**
    * Método que se encarga de realizar la query de oportunidades para obtener los campos dinámicos
    *
    * @param lVariables: lista con los campos dinámicos de los bloques
    */
    private sObject queryOportunidad(list<string> lVariables){
        //Validamos las variables dinámicas        
        validarCamposDinamicos(lVariables);        
        //Juntamos en un string los campos que hay que buscar separados por ,
        string queryField = string.join(lVariablesDinamicasValidas, ',');
        
        //Query para recuperar los datos relacionados con la oportunidad que son dinámicos de la plantilla de hoja de encargo
        string query = 'SELECT '+queryField+ ' FROM Opportunity WHERE Id = \''+idOpp+'\'';        
        
        sObject objQuery = Database.query(query);
        return objQuery;
    }

    /**
    * Método que valida que los campos que se han indicado como dinámicos existen en el objeto correspondiente
    *
    * @param    lVariables: lista con los campos dinámicos de los bloques
    */
    private void validarCamposDinamicos (list<string> lVariables) {        
        //Recuperamos el esquema de todos los objetos
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        //Guardamos en un set los campos que ya se han tratado
        set<string> sVariablesTratadas = new set<string>();
        //Recorremos las variables y validamos que existe el campo en el objeto indicado
        Integer i = 0;
        for(string campo :lVariables){            
            string campoInicial = campo;
            //Si la variable dinámica ya se ha tratado no se vuelve a analizar
            if(!sVariablesTratadas.contains(campoInicial)){
                sVariablesTratadas.add(campoInicial);
                string nombreObjetoAPI = 'Opportunity';
                while(campo.contains('.')){
                    integer fin = campo.indexOf('.');
                    nombreObjetoAPI = campo.substring(0,fin);
                    campo = campo.substring(fin+1);
                }
                //Recupero el esquema del objeto
                if(nombreObjetoAPI.contains('__r')) nombreObjetoAPI = nombreObjetoAPI.replace('__r', '__c');
                if(gd.containsKey(nombreObjetoAPI)){                
                    SObjectType objTipo = gd.get(nombreObjetoAPI);                
                    //Recuperamos los campos del objeto y si contiene el campo se añade como variable dinámica válida
                    if(objTipo.getDescribe().fields.getMap().containsKey(campo)) lVariablesDinamicasValidas.add(campoInicial);
                    else lVariablesDinamicasNoValidas.add(campoInicial);
                } 
            }
        }
        
    }

    /**
    * Método que sustituye la parte dinámica de la hoja de encargo
    *
    * @param    bloque: campo que tiene los datos dinámicos
    * @param    lVariables: lista con los campos dinámicos que se tiene en el bloque
    * @param    objQuery: registro de la oportunidad
    */
    private string sustituirCamposDinamicos(string bloque, sObject objQuery){               
       if(bloque != null){
        //Recorremos las variables dinámicas de la hoja de encargo y se sustituyen por los varoles devueltos en la query anterior
            for(string campo :lVariablesDinamicasValidas){
                string campoSustitucion = campo;
                sObject obj = objQuery;
                string dato = '';
            
                //Comprobamos que en el bloque tenemos la variable a sustituir
                if(bloque.contains('{!'+campoSustitucion+'}')){
                    //Si el campo dinámico tiene un . significa que no es el propio campo y que hay que ir a otro objeto relacionado con la oportunidad
                    while(campo.contains('.')){
                        integer fin = campo.indexOf('.');
                        obj = obj.getSObject(campo.substring(0,fin));
                        campo = campo.substring(fin+1);
                    }
                    dato = String.valueOf(obj.get(campo)); 
                    if(dato != null) bloque = bloque.replace('{!'+campoSustitucion+'}', dato.toUpperCase());
                }
            } 
            //Recorremos las variables que no son validas y se ponen en color rojo
            for(string campo :lVariablesDinamicasNoValidas){
                if(bloque.contains('{!'+campo+'}')){
                    bloque = bloque.replace(campo,'<span style=color:red>'+campo+'</span>');
                }
            }
        }
        return bloque;              
    }

    /**
    * Método que se encarga de recuperar los roles del contacto asociadas a la oportunidad
    * 
    */
    public void rolesContactoOportunidad(){        
        //Recuperamos los roles asociados con la oportunidad
        list<OpportunityContactRole> lRoles = [SELECT Id, OpportunityId, ContactId, Role, Contact.Name, Contact.Account.DocumentoIdentidad__c, 
                                                     Contact.Account.ShippingCity, Contact.Account.Phone, Contact.email, Contact.AccountId, Contact.Account.TipoDocumento__c
                                                FROM OpportunityContactRole
                                                WHERE OpportunityId = :idOpp];

        

        for(OpportunityContactRole rol :lRoles){
            //Creamos la wrapper class del rol
            wrapperOpportunityContactRole wRol = new wrapperOpportunityContactRole(rol);                                                
            //Guardamos el contratante en una variable aparte porque es el primero que se tiene que mostrar
            if(rol.Contact.AccountId == oportunidad.AccountId) contratanteRol = wRol;
            else{
            //Separamos los titulares en una lista diferente de los representantes
                if(rol.Role == system.label.TitularFuncionContactoOportunidad) lTitulares.add(wRol);
                else lRepresentantes.add(wRol);
            }
        }        
    } 

    /*Wrapper Class con los datos de la oportunidad*/   
    public class wrapperOportunidad{
        public id idOpp {get;set;}
        public string numeroExpediente {get;set;}
        public string propietarioNombre {get;set;}
        public datetime fechaCierre {get;set;}
        public string propietarioTelefono {get;set;}
        public Boolean descuentoPDF {get;set;}
		
        public wrapperOportunidad(Opportunity Oportunidad){
            idOpp = oportunidad.id;
            numeroExpediente = oportunidad.NumeroExpediente__c;
            //Si el propietario de la oportunidad (la cuenta asociada al contacto de la comunidad) es el mismo que la cuenta indicada en la oportunidad no se muestra información 
            // en los campos de propietario y teléfono, porque significa que viene de la comunidad y no tiene sentido indicar atendido por a el mismo usuario de la comunidad
            if(Oportunidad.AccountId != oportunidad.Owner.Contact.AccountId){
                propietarioNombre = oportunidad.Owner.Name;
                propietarioTelefono = oportunidad.Owner.Phone;
            }
            id HojaEnc = oportunidad.HojaEncargo__c;
            fechaCierre = Date.Today();
            descuentoPDF = oportunidad.Aplicar_Descuento_en_PF__c;
        }
    }

    
}