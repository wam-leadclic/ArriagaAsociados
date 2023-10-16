/*
@author LeadClic Solutions S.L.
@date 10/04/2019
@description Clase que convierte los candidatos en cuenta/contacto

<pre>
FECHA                 AUTOR           ACCION
10/04/2019		 LCS - RMG	   Creación.
17/07/2019           LCS - RMG        Modificación. Al crear la oportunidad se asocia la oportunidad con la campaña en la que el candidato es miembro de campaña 
28/08/2019           LCS - RMG        Modificación. Al crear la oportunidad se pone como propietario el mismo que el del candidato y en el campo oficina cita se pone el que se tiene en el evento
17/03/2020           LCS - RDM        Modificación. Al crear la oportunidad, esta hereda del candidato el origen.
*/
public class LeadCustomConvert {
     /**
          *  Método encargado de realizar la conversión de candidatos
          *  
          * @param  lista con los id de los candidatos que se van a convertir
          * @return	Mapa que devuelve el id del candidato que se ha convertido y su correspondiente contacto que se ha creado
          */
          public static map<Id, Id> convertLeads (list<Id> candidatos){
               //Mapa que se devuelve con el id del candidato y su correspondiente id de contacto
               map<Id,Id> mResultado = new map<Id, Id>();
               //Mapa para guardar el id del candidato y su correspondiente id de la cuenta
               map<Id,Id> mIdCandIdCuenta = new map<Id, Id>();
               //Configuración personalizada con los datos que son fijos en la creación de oportunidades y funciones de contacto
               ConversionCandidato__c cpConvCandidato = ConversionCandidato__c.getInstance('General');
     
               //Buscamos las campañas a las que pertenece los candidatos
               list<CampaignMember> lMiembrosCampanas = [SELECT CampaignId, LeadId
                                                            FROM CampaignMember
                                                            WHERE LeadId IN :candidatos
                                                            ORDER BY LastModifiedDate ASC 
                                                       ];      
     
               //Buscamos los eventos asociados con los candidatos convertidos
               list<Event> lEventos = [SELECT Id, Oficina__c, WhoId
                                        FROM Event
                                        WHERE WhoId IN :candidatos];
               
               //Mapa para guardar el candidato y el evento asociado
               map<Id, Event> mIdCandidatoCita = new map<Id, Event>();
               for(Event evento :lEventos){
                    mIdCandidatoCita.put(evento.WhoId, evento);
               }
     
     
               //Recorremos los miembros de campaña obtenidos y los guardamos en un mapa para luego relacionarlo con la oportunidad
               map<Id, Id> mIdCandidatoIdCampana = new map<Id, Id>();
               for(CampaignMember miembroCamp :lMiembrosCampanas){
                    mIdCandidatoIdCampana.put(miembroCamp.LeadId , miembroCamp.CampaignId);
               }                                            
     
               //Lista con los candidatos que se van a convertir y su configuración     
               list<Database.LeadConvert> lCandidatosConversion = new list<Database.LeadConvert>();
     
               //Recuperamos los estados del candidato que están marcados como convertidos, solo se va a tener un estado como convertido
               LeadStatus convertStatus = [SELECT Id, MasterLabel, Apiname FROM LeadStatus WHERE IsConverted=true LIMIT 1];
               
               //Recorremos los candidatos para crear la configuración de cada candidato
               for(Id IdCandidato :candidatos){
                    Database.LeadConvert lc = new database.LeadConvert();
                    //Esto nos permite indicar que no queremos que se cree una oportunidad cuando estamos realizando la conversión del candidato
                    lc.setDoNotCreateOpportunity(true);
                    //Asignamos el estado de convertido al candidato
                    lc.setConvertedStatus(convertStatus.Apiname);
                    //Indicamos el id del candidato a convertir
                    lc.setLeadId(IdCandidato);
     
                    lCandidatosConversion.add(lc);
               }
     
               //Realizamos la conversión de los candidatos
               Database.LeadConvertResult[] lcrList = Database.convertLead(lCandidatosConversion, false);
               //Recorremos los resultados devueltos de la conversion y nos quedamos con los candidatos que se han convertido sin problemas
               for(Database.LeadConvertResult lcr : lcrList){
                    system.debug('***lcr***'+lcr);
                    if(lcr.isSuccess()){ 
                         mResultado.put(lcr.getLeadId(), lcr.getContactId());
                         mIdCandIdCuenta.put(lcr.getLeadId(), lcr.getAccountId());
                    }
               }
     
               //Si se ha realizado la conversión de algún candidato correctamente pasamos a la creación de oportunidades
               if(!mResultado.isEmpty()){
                    //Buscamos los productos de interés que tienen asociado los candidatos convertidos
                    list<LeadProduct__c> lProductosInteres = [SELECT Id, Candidato__c, Candidato__r.LeadSource, Producto__c, Producto__r.Name, Candidato__r.OwnerId
                                                            FROM LeadProduct__c
                                                            WHERE Candidato__c IN :mResultado.keySet()];                               
     
                    //Metemos en un mapa los productos de interés que se han obtenido
                    map<Id, LeadProduct__c> mProdInteres = new map<Id, LeadProduct__c>();
                    list<Id> lIdProductos = new list<Id>();
                    for(LeadProduct__c prodInt :lProductosInteres){
                         mProdInteres.put(prodInt.Id, prodInt);
                         lIdProductos.add(prodInt.Producto__c);
                    }                                                       
                    //Buscamos el precio que tiene los productos que vamos a insertar como líneas de oportundiad
                    String idListaPrecio = (cpConvCandidato != null) ? cpConvCandidato.IdListaDePrecio__c : '';
                    list<PriceBookEntry> lPbe = [SELECT Id, UnitPrice, Product2Id 
                                                  FROM PriceBookEntry 
                                                  WHERE Pricebook2Id = :idListaPrecio
                                                  AND Product2Id IN :lIdProductos]; 
     
                    //Guardamos en un mapa para cada producto su correspondiente pbe
                    map<Id, PriceBookEntry> mIdProdPriceBookEntry = new map<Id, PriceBookEntry>();
                    for(PriceBookEntry pbe :lPbe){
                         mIdProdPriceBookEntry.put(pbe.Product2Id, pbe);
                    }                              
     
                    //Recorremos los productos de interés y creamos para cada producto de interés una oportunidad y su correspondiente linea de oportunidad
                    list<Opportunity> lOportunidadesNuevas = new list<Opportunity>();
                    list<OpportunityLineItem> lLineaOportunidadNueva = new list<OpportunityLineItem>();
                    list<OpportunityContactRole> lFuncionContacto = new list<OpportunityContactRole>();
     
                    //Creamos una oportunidad para cada producto de interés
                    for(LeadProduct__c prodInteres :lProductosInteres){
                         Opportunity opp = new Opportunity();
                         opp.OwnerId = prodInteres.Candidato__r.OwnerId;
                         opp.Name = prodInteres.Producto__r.Name;
                         opp.CloseDate = system.today();
                         opp.StageName = cpConvCandidato.EtapaOportunidad__c;
                         opp.AccountId = mIdCandIdCuenta.get(prodInteres.Candidato__c);
                         opp.Pricebook2Id = cpConvCandidato.IdListaDePrecio__c;
                         opp.ProductoInteres__c = prodInteres.id;
                         opp.LeadSource = prodInteres.Candidato__r.LeadSource;
                         if(mIdCandidatoIdCampana.containsKey(prodInteres.Candidato__c)) opp.CampaignId = mIdCandidatoIdCampana.get(prodInteres.Candidato__c);
                         if(mIdCandidatoCita.containsKey(prodInteres.Candidato__c)) opp.OficinaCita__c = mIdCandidatoCita.get(prodInteres.Candidato__c).Oficina__c;
     
                         lOportunidadesNuevas.add(opp);
                    }
                    if(!lOportunidadesNuevas.isEmpty()) insert lOportunidadesNuevas;
     
                    //Creamos las líneas de oportunidad y las funciones de contactos 
                    for(Opportunity opp :lOportunidadesNuevas){
                         //Linea de oportunidad
                         OpportunityLineItem oli = new OpportunityLineItem();
                         oli.OpportunityId = opp.id;
                         oli.Product2Id = mProdInteres.get(opp.ProductoInteres__c).Producto__c;
                         oli.Quantity = 1;                          
                         oli.TotalPrice = mIdProdPriceBookEntry.get(oli.Product2Id).UnitPrice;                              
                         lLineaOportunidadNueva.add(oli);
     
                         //Función de contacto
                         OpportunityContactRole rolContacto = new OpportunityContactRole();
                         rolContacto.OpportunityId = opp.id;
                         rolContacto.ContactId = mResultado.get(mProdInteres.get(opp.ProductoInteres__c).Candidato__c);
                         rolContacto.Role = cpConvCandidato.RolFuncionContacto__c;
                         rolContacto.IsPrimary = true;
                         lFuncionContacto.add(rolContacto);
                    }
                    
                    if(!lLineaOportunidadNueva.isEmpty())insert lLineaOportunidadNueva;
                    if(!lFuncionContacto.isEmpty())insert lFuncionContacto;               
               }
               return mResultado;
          }
     }