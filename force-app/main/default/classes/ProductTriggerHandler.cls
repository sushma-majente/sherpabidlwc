public class ProductTriggerHandler{
    
    public static Boolean restrictMultipleInsert = true;    
    public static Decimal Montreal=0.0,Toronto=0.0,NumberinInventory=0.0,TorontoShowroom =0.0,MontrealShowroom=0.0,MTLHub=0.0,TORHub=0.0,price=0.0,suggestedPrice=0.0,LastCostPrice=0.0,AverageCostPrice=0.0;
    Public static string description1,description2, groupC;
    public static void creatingDuplicateRecord(Map<String,List<Product2>> productsMapRecieved,List<String> productNames) {
        
        List<String> UpdatedProductNames = new  List<String>();
        List<Product2> UpdateDuplicateProducts = new  List<Product2>();
        List<Product2> CreateDuplicateProducts = new  List<Product2>();
        List<Product2> CalculatedProducts = new  List<Product2>();
        Map<String, Product2> mapExistingProduct = new Map<String, Product2>();                
        List<String> existingKeys = new List<String>();             
        List<Product2> needToUpdate = new List<Product2>();
        List<String> notAvailableProducts = new List<String>();
        List<Product2> newDuplicateProducts = new List<Product2>();
        system.debug(productsMapRecieved);
        for(String s: productNames)
        {
            string temp = s +'(Summary Product)';
            UpdatedProductNames.add(temp);
            
        }
        system.debug(UpdatedProductNames);
        // Checking and getting all existing Duplicate Records 
        List<Product2> existingDuplicateProducts = [SELECT Id, Name, Montreal__c
                                                    , Toronto__c, Number_in_Inventory__c
                                                    , Toronto_Showroom__c, Montreal_Showroom__c, MTL_Hub__c
                                                    , TOR_Hub__c, Quantity_Available__c, Serial_Number__c
                                                    ,Unique_Product__c FROM Product2
                                                    where Serial_Number__c = NULL AND
                                                    Unique_Product__c IN: UpdatedProductNames];
        system.debug(existingDuplicateProducts);
        for(Product2 product: existingDuplicateProducts) {
            
            mapExistingProduct.put(product.Name, product);
            existingKeys.add(product.Name);
            System.debug('mapExistingProduct::'+mapExistingProduct);
            System.debug('existingKeys::'+existingKeys);
        }
        for(String productKey: ProductNames) {
            if(existingKeys.contains(productKey)) {
                needToUpdate.add(mapExistingProduct.get(productKey));
            }
            else {
                notAvailableProducts.add(productKey);
            }
        }
        system.debug(needToUpdate);
        system.debug(notAvailableProducts);
        // Calculating the values from existing Talend products Records to update in duplicate record. 
        if(needToUpdate != null && needToUpdate.size()> 0) {
            System.debug('needToUpdate::'+needToUpdate);
            for(Product2 prod : needToUpdate) {  //Test Product1
                system.debug(productsMapRecieved.get(prod.name));
                List<Product2> innerProdList = productsMapRecieved.get(prod.name);
                System.debug('innerProdList::'+innerProdList);
                calculateValues(innerProdList);
                // calculateValuesRefactor(innerProdList, prod);
                //System.debug('innerProdList::'+innerProdList);
                createDuplicateProduct(prod ,'', true);
                ResetValues();
            }
        }
        //Creating new Duplicate Records 
        if(notAvailableProducts != null && notAvailableProducts.size() > 0) {
            System.debug('notAvailableProducts::'+notAvailableProducts);
            for(String productKey : notAvailableProducts)
            {
                List<Product2> lst = productsMapRecieved.get(productKey);
                if(lst != null && lst.size() > 0) {
                    Product2 dupProduct = new Product2();
                    calculateValues(lst);
                    createDuplicateProduct(dupProduct , productKey, false);
                    // adding to the existing collection to upsert 
                    newDuplicateProducts.add(dupProduct);
                    ResetValues();
                    
                }
            }
        }
        
        // Upserting the records
        if(needToUpdate != null && needToUpdate.size() > 0) {
            System.debug('needToUpdate:: '+needToUpdate);
            upsert needToUpdate;
        }
        
        if(newDuplicateProducts != null && newDuplicateProducts.size() > 0) {
            System.debug('needToUpdate:: '+needToUpdate);
            insert newDuplicateProducts;
        }
        
        
    }
    public static void calculateValues(List<Product2> lst) {
        for(Product2 p : lst) {
            if(p.Montreal__c !=null)
            {
                System.debug('p.Montreal__c for' +p.Name);
                System.debug('p.Montreal__c for' +p.Montreal__c);
                
                Montreal= p.Montreal__c+Montreal;
                System.debug('Montreal for' +Montreal);
            }
            if(p.Toronto__c != null)
            {
                System.debug('p.Toronto__c for' +p.Name);
                System.debug('p.Toronto__c for' +p.Toronto__c);
                Toronto= p.Toronto__c+Toronto;
                System.debug('Montreal for' +Toronto);
            }
            if(p.Number_in_Inventory__c !=null)
            {
                NumberinInventory= p.Number_in_Inventory__c+NumberinInventory;
                
            }
            if(p.Toronto_Showroom__c !=null)
            {
                TorontoShowroom= p.Toronto_Showroom__c+TorontoShowroom;
                
            }
            if(p.Montreal_Showroom__c !=null)
            {
                MontrealShowroom= p.Montreal_Showroom__c+MontrealShowroom;
                
            }
            if(p.MTL_Hub__c !=null)
            {
                MTLHub= p.MTL_Hub__c+MTLHub;
                
            }
            if(p.TOR_Hub__c !=null)
            {
                TORHub= p.TOR_Hub__c+TORHub;
            }
            if(p.Price__c !=null)
            {
                price = p.Price__c;
            }
            if(p.Description_1__c !=null)
            {
                description1 = p.Description_1__c;
            }
            if(p.Description_2__c != null)
            {
                description2 = p.Description_2__c; 
            }
            if(p.Price_Suggested__c != null)
            {
                suggestedPrice = p.Price_Suggested__c;
            }
            if(p.Group__c != null)
            {
                System.debug('p.Group__c::'+p.Group__c);
                groupC = p.Group__c;
            }
            if(p.Last_Cost_Price__c != null)
            {
                LastCostPrice = p.Last_Cost_Price__c;
            }
            if(p.Average_Cost_Price__c != null)
            {
                AverageCostPrice = p.Average_Cost_Price__c;
            }
        }
    }
    public static void createDuplicateProduct(Product2 dupProduct , String productKey, Boolean isUpdate) {
        if(!isUpdate) {
            
            dupProduct.Name = productKey;
            System.debug('dupProduct.Name::' +dupProduct.Name);
            dupProduct.Product_Type__c = 'Summary Product';
            System.debug('dupProduct.Product_Type__c::' +dupProduct.Product_Type__c);
            dupProduct.Unique_Product__c = productKey + '(Summary Product)';
            System.debug('dupProduct.Unique_Product__c::' +dupProduct.Unique_Product__c);
            dupProduct.IsActive = true;
            dupProduct.Price__c=price;
            dupProduct.Description_2__c = description2;
            dupProduct.Description_1__c = description1;
            dupProduct.Price_Suggested__c =suggestedPrice;
            dupProduct.Group__c =GroupC;
            dupProduct.Last_Cost_Price__c =LastCostPrice;
            dupProduct.Average_Cost_Price__c =AverageCostPrice;
            
        }
        dupProduct.Montreal__c = dupProduct.Montreal__c!=null ? dupProduct.Montreal__c + Montreal : Montreal;
        dupProduct.Toronto__c = dupProduct.Toronto__c!=null ? dupProduct.Toronto__c+Toronto :Toronto;
        dupProduct.TOR_Hub__c = dupProduct.TOR_Hub__c!=null ? dupProduct.TOR_Hub__c+TORHub :TORHub;
        dupProduct.Toronto_Showroom__c = dupProduct.Toronto_Showroom__c!=null ? dupProduct.Toronto_Showroom__c+TorontoShowroom :TorontoShowroom;
        dupProduct.Montreal_Showroom__c = dupProduct.Montreal_Showroom__c!=null ? dupProduct.Montreal_Showroom__c+MontrealShowroom :MontrealShowroom;
        dupProduct.Number_in_Inventory__c = dupProduct.Number_in_Inventory__c!=null ? dupProduct.Number_in_Inventory__c+NumberinInventory :NumberinInventory;
        dupProduct.MTL_Hub__c = dupProduct.MTL_Hub__c!=null ? dupProduct.MTL_Hub__c+MTLHub :MTLHub;
        dupProduct.Quantity_Available__c = dupProduct.Montreal__c + dupProduct.Toronto__c + dupProduct.TOR_Hub__c + dupProduct.Toronto_Showroom__c + dupProduct.Montreal_Showroom__c + dupProduct.Number_in_Inventory__c+dupProduct.MTL_Hub__c;
        
    }
    public static void ResetValues() {
        Montreal=0.0; Toronto=0.0 ;NumberinInventory=0.0 ;TorontoShowroom =0.0 ;MontrealShowroom=0.0 ;MTLHub=0.0 ;TORHub=0.0;price=0.0;suggestedPrice=0.0;
        description1=null;description2=null;
    }
    
    public static void CalculateUpdatedProducts(List<Product2> Products)
    {
        
        Decimal Montrealc=0,Torontoc=0,NumberinInventoryc=0,TorontoShowroomc=0,MontrealShowroomc=0,MTLHubc=0,TORHubc=0;
        Set<String> productNames = new Set<String>();
        List<String> productNamesToUpdate = new List<String>();
        List<Product2> SummaryProductsToUpdate = new List<Product2>();
        for(product2 p: products)
        {
            String temp = p.Name + '(Summary Product)';
            productNames.add(temp);
        }
        
        productNamesToUpdate.addALL(productNames);
        System.debug('productNamesToUpdate::' +productNamesToUpdate);
        
        List<Product2> existingDuplicateProducts = [SELECT Id, Name, Montreal__c
                                                    , Toronto__c, Number_in_Inventory__c
                                                    , Toronto_Showroom__c, Montreal_Showroom__c, MTL_Hub__c
                                                    , TOR_Hub__c, Quantity_Available__c, Serial_Number__c
                                                    ,Unique_Product__c FROM Product2
                                                    where Serial_Number__c = NULL AND
                                                    Unique_Product__c IN: productNamesToUpdate];
        System.debug('existingDuplicateProducts to update::' +existingDuplicateProducts);
        for(product2 p: existingDuplicateProducts)
        {
            for(product2 prod: products)
            {
                if(p.Name == prod.Name)
                { 
                    if(prod.Montreal__c !=null && p.Montreal__c >0)
                    {
                        Montrealc = Montrealc+prod.Montreal__c;
                    }
                    if(prod.Montreal_Showroom__c !=null && p.Montreal_Showroom__c >0)
                    {
                        MontrealShowroomc = MontrealShowroomc + prod.Montreal_Showroom__c;
                    }
                    if(prod.MTL_Hub__c !=null && p.MTL_Hub__c >0)
                    {
                        MTLHubc = MTLHubc + prod.MTL_Hub__c;
                    }
                    if(prod.Number_in_Inventory__c!=null && p.Number_in_Inventory__c >0)
                    {
                        NumberinInventoryc = NumberinInventoryc + prod.Number_in_Inventory__c;
                    }
                    if(prod.TOR_Hub__c !=null && p.TOR_Hub__c >0)
                    {
                        TORHubc = TORHubc + prod.TOR_Hub__c;
                    }
                    if(prod.Toronto__c !=null && p.Toronto__c >0 )
                    {
                        Torontoc = Torontoc + prod.Toronto__c;
                        system.debug(p.Toronto__c);
                    }
                    system.debug(p.Toronto_Showroom__c);
                    system.debug(TorontoShowroomc);
                    //&& p.Toronto_Showroom__c>0
                    if(prod.Toronto_Showroom__c !=null && p.Toronto_Showroom__c>0)
                    {
                        TorontoShowroomc = TorontoShowroomc + prod.Toronto_Showroom__c;
                        system.debug(TorontoShowroomc);
                        system.debug(p.Toronto_Showroom__c);
                    }
                }
            }
            p.Montreal__c = p.Montreal__c - Montrealc;
            p.Montreal_Showroom__c = p.Montreal_Showroom__c -MontrealShowroomc ;
            p.MTL_Hub__c =p.MTL_Hub__c -MTLHubc;
            p.Number_in_Inventory__c =p.Number_in_Inventory__c -NumberinInventoryc;
            p.TOR_Hub__c = p.TOR_Hub__c -TORHubc;
            p.Toronto__c = p.Toronto__c - Torontoc;
            system.debug(TorontoShowroomc);
            p.Toronto_Showroom__c = p.Toronto_Showroom__c - TorontoShowroomc;
            system.debug(p.Toronto_Showroom__c);
            system.debug(p.Quantity_Available__c);
            p.Quantity_Available__c = p.Montreal__c+p.Montreal_Showroom__c+p.MTL_Hub__c+p.Number_in_Inventory__c+p.TOR_Hub__c+p.Toronto__c+p.Toronto_Showroom__c;
            system.debug(p.Quantity_Available__c);
            SummaryProductsToUpdate.add(p);  
            system.debug(SummaryProductsToUpdate);
        }
        
        try{
            update SummaryProductsToUpdate;
        }
        catch(exception e)
        {
            System.debug('e::'+e);
        }
    }
    
    public static void deleteDuplicateProduct(List<String> productNames){
        List<String> UpdatedProductNames = new  List<String>();
        
        for(String s: productNames)
        {
            string temp = s +'(Summary Product)';
            UpdatedProductNames.add(temp);
            system.debug(temp);
            
        }
        
        List<Product2> existingDuplicateSummaryProducts = [SELECT Id, Name, Serial_Number__c
                                                           ,Unique_Product__c FROM Product2
                                                           where Serial_Number__c = NULL AND
                                                           Unique_Product__c IN: UpdatedProductNames];
        system.debug(existingDuplicateSummaryProducts);
        delete existingDuplicateSummaryProducts;   
        
    }
    
    
    
    public static void UpdateDuplicateProduct(List<Product2> productsneedtobeupdated,List<product2> oldProducts)
    {
        Map<String, Product2> mapExistingProduct = new Map<String, Product2>();                
        List<String> existingKeys = new List<String>();             
        List<Product2> needToUpdate = new List<Product2>();
         List<Product2> updatedupprodlist = new List<Product2>();
        List<String> notAvailableProducts = new List<String>();
        Set<String> productNames = new Set<String>();
        List<String> productNamesList = new List<String>();
        List<Product2> updatedproductsfromtalend = new List<Product2>();
         Map<String,List<Product2>>  mapTalendPro = new Map<String,List<Product2>>();
         List<String> UpdatedProductNames = new  List<String>();
        for(product2 prod:productsneedtobeupdated)
        {
            productNames.add(prod.name);
        }
        productNamesList.addAll(productNames);
          for(String productName: productNamesList) {
               for(Product2 p : productsneedtobeupdated) {
                 updatedproductsfromtalend.add(p);
               }
               mapTalendPro.put(productName, updatedproductsfromtalend);
          }
        
         for(String s: productNamesList)
        {
            string temp = s +'(Summary Product)';
            UpdatedProductNames.add(temp);
            
        }
          List<Product2> existingDuplicateProducts = [SELECT Id, Name, Montreal__c
                                                    , Toronto__c, Number_in_Inventory__c
                                                    , Toronto_Showroom__c, Montreal_Showroom__c, MTL_Hub__c
                                                    , TOR_Hub__c, Quantity_Available__c, Serial_Number__c
                                                    ,Unique_Product__c FROM Product2
                                                    where Serial_Number__c = NULL AND
                                                    Unique_Product__c IN: UpdatedProductNames];
        system.debug(existingDuplicateProducts);
         for(Product2 product: existingDuplicateProducts) {
            
            mapExistingProduct.put(product.Name, product);
            existingKeys.add(product.Name);
            System.debug('mapExistingProduct::'+mapExistingProduct);
            System.debug('existingKeys::'+existingKeys);
        }
        for(String productKey: ProductNames) {
            if(existingKeys.contains(productKey)) {
                needToUpdate.add(mapExistingProduct.get(productKey));
            }
            else {
                notAvailableProducts.add(productKey);
            }
        }
        
        
        if(needToUpdate != null && needToUpdate.size()> 0) { 
         
           for(Product2 prod:needToUpdate)
             {
             List<Product2> innerProdList = mapTalendPro.get(prod.name);
              Decimal Montrealforup=0.0,Montrealforminus=0.0,Torontoforup=0.0,Torontoforminus=0.0,NumberinInventoryforup=0.0,
                  NumberinInventoryforminus=0.0,TorontoShowroomforup =0.0,TorontoShowroomforminus=0.0,MontrealShowroomforup=0.0,
                  Montrealshowroomforminus=0.0,MTLHubforup=0.0,MTLHubforminus=0.0,TORHubforup=0.0,TORHubforminus=0.0,
                  priceforup=0.0,suggestedPriceforup=0.0,LastCostPriceforup=0.0,AverageCostPriceforup=0.0;
              string description1forup,description2forup, groupCforup;
              for(Product2 p : innerProdList) {  
                   for(Product2 p1 : oldProducts)
                      {
                       if(p.Id == p1.Id)
                        {
                           if((p.Montreal__c==p1.Montreal__c && p.Montreal_Showroom__c ==p1.Montreal_Showroom__c && p.TOR_Hub__c ==p1.TOR_Hub__c &&
                                        p.Toronto__c ==p1.Toronto__c && p.Toronto_Showroom__c==p1.Toronto_Showroom__c && p.MTL_Hub__c ==p1.MTL_Hub__c &&
                                        p.Number_in_Inventory__c==p1.Number_in_Inventory__c)&&(p.IsActive==true))
                            { 
                             priceforup=p.Price__c;
                             description2forup  = p.Description_2__c;
                             description1forup = p.Description_1__c;
                             suggestedPriceforup =p.Price_Suggested__c;
                             groupCforup=p.Group__c;
                             LastCostPriceforup =p.Last_Cost_Price__c;
                             AverageCostPriceforup=p.Average_Cost_Price__c;
                           }else
                           {
                               if(p.Montreal__c != p1.Montreal__c )
                               {
                                   if(p.Montreal__c!=null)
                                   {
                                       Montrealforup = Montrealforup+p.Montreal__c;
                                   }
                                   else
                                   {
                                       Montrealforminus =Montrealforminus+1 ;
                                   }
                                  
                               }
                               if(p.Montreal_Showroom__c != p1.Montreal_Showroom__c )
                               {
                                   if(p.Montreal_Showroom__c!=null)
                                   {
                                       MontrealShowroomforup = MontrealShowroomforup+p.Montreal_Showroom__c;
                                   }
                                   else
                                   {
                                    Montrealshowroomforminus =Montrealshowroomforminus+1 ;
                                   }
                               }
                                if(p.MTL_Hub__c != p1.MTL_Hub__c)
                               {
                                   if(p.MTL_Hub__c!=null)
                                   {
                                       MTLHubforup = MTLHubforup+p.MTL_Hub__c;
                                   }
                                   else
                                   {
                                     MTLHubforminus=MTLHubforminus+1 ;
                                   }
                               }
                                if(p.TOR_Hub__c != p1.TOR_Hub__c )
                               {
                                   if(p.TOR_Hub__c!=null)
                                   {
                                       TORHubforup = TORHubforup+p.TOR_Hub__c;
                                   }
                                   else
                                   {
                                    TORHubforminus =TORHubforminus+1 ;
                                   }
                               }
                                if(p.Toronto__c != p1.Toronto__c )
                               {
                                   if(p.Toronto__c!=null)
                                   {
                                        Torontoforup= Torontoforup+p.Toronto__c;
                                   }
                                   else
                                   {
                                    Torontoforminus =Torontoforminus+1 ;
                                   }
                               }
                                if(p.Toronto_Showroom__c != p1.Toronto_Showroom__c )
                               {
                                   if(p.Toronto_Showroom__c!=null)
                                   {
                                       TorontoShowroomforup = TorontoShowroomforup+p.Toronto_Showroom__c;
                                   }
                                   else
                                   {
                                     TorontoShowroomforminus=TorontoShowroomforminus+1 ;
                                   }
                               }
                                if(p.Number_in_Inventory__c != p1.Number_in_Inventory__c)
                               {
                                   if(p.Number_in_Inventory__c!=null)
                                   {
                                       NumberinInventoryforup = NumberinInventoryforup+p.Number_in_Inventory__c;
                                   }
                                   else
                                   {
                                     NumberinInventoryforminus=NumberinInventoryforminus+1 ;
                                   }
                               }
                           
                           }
                        }
                    }
                }
               prod.Price__c =priceforup;
               prod.Description_2__c=description2forup;
               prod.Description_1__c =description1forup;
               prod.Price_Suggested__c=suggestedPriceforup;
               prod.Group__c =groupCforup;
               prod.Last_Cost_Price__c =LastCostPriceforup;
               prod.Average_Cost_Price__c=AverageCostPriceforup;
               prod.Montreal__c =prod.Montreal__c+(Montrealforup-Montrealforminus);
               prod.Montreal_Showroom__c =prod.Montreal_Showroom__c+(MontrealShowroomforup-Montrealshowroomforminus);
               prod.MTL_Hub__c =prod.MTL_Hub__c+(MTLHubforup-MTLHubforminus);
               prod.TOR_Hub__c =prod.TOR_Hub__c+(TORHubforup-TORHubforminus);
               prod.Toronto__c =prod.Toronto__c+(Torontoforup-Torontoforminus);
               prod.Toronto_Showroom__c =prod.Toronto_Showroom__c+(TorontoShowroomforup-TorontoShowroomforminus);
               prod.Number_in_Inventory__c =prod.Number_in_Inventory__c+(NumberinInventoryforup-NumberinInventoryforminus);
               prod.Quantity_Available__c = prod.Montreal__c+prod.Montreal_Showroom__c+prod.MTL_Hub__c+prod.Number_in_Inventory__c+prod.TOR_Hub__c+prod.Toronto__c+prod.Toronto_Showroom__c;
               updatedupprodlist.add(prod);    
             
                
            }
           update updatedupprodlist;
        }
        }
        
    }