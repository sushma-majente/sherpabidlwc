/************************************************************************************************************************************
* @Name         ProductTrigger 
* @Date         03/05/2022
* @Group        Majente
* @Description  This class is triggered when a product is created
*************************************************************************************************************************************/
trigger ProductTrigger on Product2 (After insert,After update) {
     Map<String,Case> previousRecords = new Map<String,Case>();
  	Product2__c switchVar = Product2__c.getInstance('products Trigger');
 if(switchVar != NULL && 'False'.equalsIgnorecase(String.valueOf(switchVar.Active__c))){ 
       return;
}
    if((Trigger.isAfter && Trigger.isInsert)) {
        List<String> productKeysTemp =new List<String>();
        Set<String> productKeysTempSet =new Set<String>();
        Map<String,List<Product2>>  mapTalendPro = new Map<String,List<Product2>>();
        Map<String,List<Product2>>  mapTalendProNull = new Map<String,List<Product2>>();
        List<String> productKeysfornull =new List<String>();
        Set<String> productKeysTempSetfornull =new Set<String>();
        // Getting all Product Names into List 
        for(Product2 product: Trigger.New) {
            //if(!productKeysTempSet.contains(product.Name))
            productKeysTempSet.add(product.Name);//Test Product1
        }
        System.debug('productKeysTempSet'+productKeysTempSet.size());
        productKeysTemp.addALL(productKeysTempSet);
        System.debug('productKeysTemp'+productKeysTemp.size());
        List<Product2> serialNumNullProductstohandler = new List<Product2>();
        
        
        // Getting all Product Names into Map along with its respective Talend Records 
        for(String productName: productKeysTemp) {
            List<Product2> serialNumNotNullProducts = new List<Product2>();
            List<Product2> serialNumNullProducts = new List<Product2>();
            for(Product2 pro : Trigger.New) {
                if(productName == pro.Name && !String.isBlank(pro.Serial_Number__c)) {
                    serialNumNotNullProducts.add(pro);
                    System.debug('pro' +pro);
                }
                else
                {
                    if( pro.Name == productName && pro.Unique_Product__c.contains('null'))
                    {
                        system.debug('pro.name' +pro.name);
                        serialNumNullProducts.add(pro);
                    }
                }
            }
            mapTalendPro.put(productName, serialNumNotNullProducts);
            for(Product2 p:serialNumNullProducts)
            {
                productKeysTempSetfornull.add(p.Name);
            }
            
            productKeysfornull.addALL(productKeysTempSetfornull);
        }
        System.debug('mapTalendPro::' +mapTalendPro);
        System.debug('mapTalendProNull::' +mapTalendProNull);
        
        system.debug('updating or inserting serial num null reocrds');
       ProductTriggerHandler.creatingDuplicateRecord(mapTalendPro,productKeysTemp);
        integer i = productKeysfornull.size();
        system.debug('productKeysfornull.size()>0::' +i);
        if(productKeysfornull.size()>0)
        {
          ProductTriggerHandler.deleteDuplicateProduct(productKeysfornull);
        }
        
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        System.debug('entered product update' +trigger.new);
        List<Product2> notSummaryProducts = new List<Product2>();
        List<Product2> notSummaryOldProducts = new List<Product2>();
        for(product2 p:trigger.new )
        {
              System.debug('updated product is' +p.Product_Type__c);
            if(p.Product_Type__c != 'Summary Product' && p.Serial_Number__c!= null)
            {
                notSummaryProducts.add(p);
            }
        }
         for(product2 p:trigger.old )
        {
              System.debug('updated product is' +p.Product_Type__c);
            if(p.Product_Type__c != 'Summary Product' && p.Serial_Number__c!= null)
            {
                notSummaryOldProducts.add(p);
            }
        }
      
        if(ProductTriggerHandler.restrictMultipleInsert) {
            ProductTriggerHandler.restrictMultipleInsert = false; 
            List<String> productKeysTemp =new List<String>();
            Set<String> productKeysTempSet =new Set<String>();
            Map<String,List<Product2>>  mapTalendPro = new Map<String,List<Product2>>();
            List<product2> productToBeUpdated = new List<product2>();
            List<product2> productNotNullToBeUpdated = new List<product2>();
            List<product2> productsToBeAddedInSummaryAgain = new List<product2>();
            List<String> ProductNames = new  List<String>();
            List<String> InvoiceProductNames = new  List<String>();
            List<product2> ProductInInvoiceAndNotToBeUpdated = new  List<product2>();
            for(Product2 p : notSummaryProducts)
            {
                ProductNames.add(p.Name);
            }
            List<Invoice_Product__c> productsinInvoice =[select Id,Product_Number__c from Invoice_Product__c where  Product_Number__c In :ProductNames];
            for(Invoice_Product__c p : productsinInvoice)
            {
                InvoiceProductNames.add(p.Product_Number__c);
            }
            for(Product2 p : notSummaryProducts)
            {
                for(Product2 p1 : notSummaryOldProducts){
                    if(p.Id == p1.Id){
                        if(InvoiceProductNames.contains(p.Name))
                        {
                            ProductInInvoiceAndNotToBeUpdated.add(p);
                        }
                        else 
                        {
                            if(p.IsActive == false && p1.IsActive != p.IsActive)
                            {
                                System.debug('product which became inactive::' +p);
                                productToBeUpdated.add(p); 
                            }
                            else
                            {
                                if(p.IsActive == true && p1.IsActive != p.IsActive)
                                {
                                    productsToBeAddedInSummaryAgain.add(p);
                                }
                                else
                                {
                                   
                                        productNotNullToBeUpdated.add(p);
                                    
                                }  
                            }
                        }
                    }
                }
            }
           ProductTriggerHandler.CalculateUpdatedProducts(productToBeUpdated);
           ProductTriggerHandler.UpdateDuplicateProduct(productNotNullToBeUpdated,notSummaryOldProducts);
            for(Product2 product: productsToBeAddedInSummaryAgain) {
                //if(!productKeysTempSet.contains(product.Name))
                productKeysTempSet.add(product.Name);//Test Product1
            }
            
            productKeysTemp.addALL(productKeysTempSet);
            
            // Getting all Product Names into Map along with its respective Talend Records 
            for(String productName: productKeysTemp) {
                List<Product2> serialNumNotNullProducts = new List<Product2>();
                List<Product2> serialNumNullProducts = new List<Product2>();
                for(Product2 pro : productsToBeAddedInSummaryAgain) {
                    if(productName == pro.Name && !String.isBlank(pro.Serial_Number__c)) {
                        serialNumNotNullProducts.add(pro);
                    }
                    
                }
                mapTalendPro.put(productName, serialNumNotNullProducts);
            }
          ProductTriggerHandler.creatingDuplicateRecord(mapTalendPro,productKeysTemp);
        }
    } 
}