public with sharing class getLeadDetailscont {
    public string leadsearchString{get;set;}
    public list<leadReponse> leadReponselist{get;set;}
    public string access_token{get;set;}
    public String instanceURL{get;set;}
    
    public String fname{get;set;}
    public String lname{get;set;}
    public String Cname{get;set;}
    public String email{get;set;}
    public String lphone{get;set;}
    public string message{get;set;}


    public class leadReponse {
            public string Id{get;set;}
            public string Name{get;set;}
            public string Email{get;set;}
            public string Phone{get;set;}
            public string Company{get;set;}
            public string Mobilephone{get;set;}
    }
    public void getLeadDetailscont(){
        leadReponselist = new list<leadReponse>();
    }
    public void requestAccessToken(){

        //need to get the details of client id and client secret

    list <integrationEndpoint__mdt> integrationSetupList = [Select Client_Id__c,Client_Secret__c,IntegrationName__c,Username__c,Password__c 
                                                    from integrationEndpoint__mdt 
                                                    where IntegrationName__c ='curiousFoxInt'];


                       if(integrationSetupList != null && integrationSetupList.size()>0){


                        //endpoint

                        String accesstokenEndpoint = 'https://login.salesforce.com/services/oauth2/token';
                        accesstokenEndpoint = accesstokenEndpoint+ '?grant_type=password';
                        accesstokenEndpoint = accesstokenEndpoint+ '&client_id=' + integrationSetupList[0].Client_Id__c;
                        accesstokenEndpoint = accesstokenEndpoint+ '&client_secret=' +integrationSetupList[0].Client_Secret__c;
                        accesstokenEndpoint = accesstokenEndpoint+ '&username=' + integrationSetupList[0].Username__c;
                        accesstokenEndpoint = accesstokenEndpoint+ '&password=' + integrationSetupList[0].Password__c;

                        
                        // setting header, enpoint, authorization value and calling    

                        Http h = new Http();    
                        HttpRequest req = new HttpRequest();
                        HttpResponse hresp = new HttpResponse();
                        
                        req.setEndpoint(accesstokenEndpoint);
                        req.setMethod('POST');
                        blob headervalue = blob.valueof(integrationSetupList[0].Username__c+':'+integrationSetupList[0].Password__c);
                        string autorizationValue='BASIC'+EncodingUtil.base64Encode(headervalue);
                        req.setHeader('Authorization', autorizationValue);

                        hresp = h.send(req);
                        System.debug('hrep'+hresp);
                        System.debug('hrep.getbody'+hresp.getBody());
                        
                            // processing the response with JSON

                            JSONParser parser = JSON.createParser(hresp.getBody());

                            while(parser.nextToken()!=null){

                                if((parser.getCurrentToken()==JSONToken.FIELD_NAME) && (parser.getText()=='access_token')) {
                                        parser.nextToken();
                                        access_token = parser.getText();

                                }
                                if((parser.getCurrentToken()==JSONToken.FIELD_NAME) && (parser.getText()=='instance_url')) {
                                    parser.nextToken();
                                    instanceURL = parser.getText();
                                    
                            }
                            }
                       }                                 
    }

    public void leadReturn(){
        requestAccessToken(); //get aceess token
        String endpointURL =instanceURL + '/services/apexrest/LeadService/Name=' + leadsearchString;
        System.debug('access_token'+access_token);
        system.debug('endpointURL '+endpointURL);

        Http h= new Http();
        HttpRequest req= new HttpRequest();
        HttpResponse res = new HttpResponse();

            req.setMethod('GET');
            req.setEndpoint(endpointURL);
            req.setHeader('Authorization', 'Bearer ' + access_token);
            req.setHeader('Content-Type', 'application/json');

        res = h.send(req);
        system.debug(res);
        system.debug(res.getBody());

        if(res.getStatuscode()==200){

            leadReponselist=(list<leadReponse>)JSON.deserialize(res.getBody(), list<leadReponse>.class);


        }


    }

public void createLead(){

    requestAccessToken();
    String endpointURL = instanceURL + '/services/apexrest/LeadService/';

        Http h= new Http();
        HttpRequest req= new HttpRequest();
        HttpResponse res = new HttpResponse();

            req.setMethod('POST');
            req.setEndpoint(endpointURL);
            req.setHeader('Authorization', 'Bearer ' + access_token);
            req.setHeader('Content-Type', 'application/json');

            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('leadFirstName',fname);
            gen.writeStringField('leadLastName',lname);
            gen.writeStringField('leadCompanyName',Cname);
            gen.writeStringField('leadMail',email);
            gen.writeStringField('leadPhone',lphone);
            gen.writeEndObject();

            String requestJSON = gen.getAsString();

            req.setBody(requestJSON);

            res= h.send(req);
            message = res.getBody();
            System.debug(res.getBody());

}




}