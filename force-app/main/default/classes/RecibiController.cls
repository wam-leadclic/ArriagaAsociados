/*
@author Leadclic Solutions S.L.
@date 02/08/2019
@description Clase controladora para el PDF recibí

FECHA               AUTOR   
31/07/2019			LCS - RDM		Creación.
18/03/2020			LCS - RDM		Modificación. Se añade el control del check para mostrar o no descuento en función de lo marcado en la opp

*/
public class RecibiController {
    
    public boolean errorObtencion { get;set; }  
   
    public string numExpediente { get;set; }  
    public string fechaHoy {get;set;}
    public string asesor {get;set;}
    public string telefonoAsesor {get;set;}
    public string nombreCliente {get;set;}
    public string importePago {get;set;}
    public string metodoPago {get;set;}
    public Boolean descuentoPDF {get;set;}
    
    public string idOpp {get;set;}
    
    public RecibiController(){
        this.errorObtencion = false;
        //recogemos el id de la Oportunidad
        this.idOpp = apexpages.currentpage().getparameters().get('Id');  
    }

    public void getDatosOpp(){
        Opportunity opp = new Opportunity();
        
        try{
            opp = [SELECT Id, NumeroExpediente__c, PrecioTotal__c, Tipo__c, OwnerId, Owner.Name, Owner.MobilePhone, AccountId, Account.Name, Aplicar_Descuento_en_PF__c
                   FROM Opportunity WHERE Id =:this.idOpp];
            
            DateTime fecha = system.now();
            this.fechaHoy = fecha.format('dd/MM/yyyy');
            
            this.numExpediente = opp.NumeroExpediente__c;
            this.asesor = opp.Owner.Name;
            this.telefonoAsesor = opp.Owner.MobilePhone;
            this.nombreCliente = opp.Account.Name;
            this.importePago = string.valueOf(opp.PrecioTotal__c);
            this.metodoPago = opp.Tipo__c;
            this.descuentoPDF = opp.Aplicar_Descuento_en_PF__c;
        }
        catch(Exception e){
            this.errorObtencion = true;            
        }
    }
}