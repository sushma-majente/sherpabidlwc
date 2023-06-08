@isTest
public class ProductTriggerTestClass {
     @TestSetup
    public static void AddDuplicateProduct() {
         List<Product2> newProductList = new List<Product2>();
        
        Product2 newProduct1 = new Product2();
        newProduct1.Name = 'ABC';
        newProduct1.Serial_Number__c ='1';
        newProduct1.Unique_Product__c = newProduct1.Name + '-' + newProduct1.Serial_Number__c;
        newProduct1.Montreal__c = 9;
        newProduct1.IsActive = true;
        newProduct1.Price__c =20.0;
        newProduct1.Price_Suggested__c=22.0;
        newProduct1.Group__c ='Alberta';
        newProduct1.Last_Cost_Price__c=30.0;
        newProduct1.Description_1__c='desc1';
        newProduct1.Description_2__c='des2';
        newProduct1.Average_Cost_Price__c=20.0;
        
        
        Product2 newProduct2 = new Product2();
        newProduct2.Name = 'ABC';
        newProduct2.Serial_Number__c ='2';
        newProduct2.Unique_Product__c = newProduct2.Name;
        newProduct2.Montreal__c = 4;
        newProduct2.IsActive = true;
        
        Product2 newProduct3 = new Product2();
        newProduct3.Name = 'ABC';
        newProduct3.Serial_Number__c ='3';
        newProduct3.Unique_Product__c = newProduct3.Name + '-' + newProduct3.Serial_Number__c;
        newProduct3.Montreal__c = 10;
        newProduct3.Toronto__c = 10;
        newProduct3.Number_in_Inventory__c = 10;
        newProduct3.Toronto_Showroom__c = 10;
        newProduct3.Montreal_Showroom__c =10;
        newProduct3.MTL_Hub__c =10;
        newProduct3.TOR_Hub__c =10;
        newProduct3.IsActive = true;
        
        Product2 newProduct4 = new Product2();
        newProduct4.Name = 'XYZ';
        newProduct4.Serial_Number__c ='1';
        newProduct4.Unique_Product__c = newProduct4.Name + '-' + newProduct4.Serial_Number__c;
        newProduct4.Montreal__c = 10;
        newProduct4.IsActive = true;
        
        
        newProductList.add(newProduct1);
        //newProductList.add(newProduct2); 
        newProductList.add(newProduct3);
        //newProductList.add(newProduct4);
        
        Database.SaveResult[] srList = Database.insert(newProductList);
        
        System.assert(true);
        Product2 newProduct8 = new Product2();
        newProduct8.Name = 'Test Product Drafts';
         newProduct8.Serial_Number__c=' ';
        newProduct8.Unique_Product__c = 'Test Product Draftsnull';
        newProduct8.Montreal_Showroom__c =1;
        newProduct8.IsActive = true;
        Insert newProduct8;

    }
    static testMethod void UpdateDuplicateProduct() {
       Product2 newProductUpdateList = [Select Id from Product2 where name ='ABC' AND Serial_Number__c ='3'];
       newProductUpdateList.IsActive = false;
        
       Update newProductUpdateList;
       System.debug('newProductUpdateList::'+newProductUpdateList);

    }
    static testMethod void UpdateDuplicateProduct1() {
       Product2 newProductUpdateList = [Select Id from Product2 where name ='ABC' AND Serial_Number__c ='3'];
      newProductUpdateList.Price__c=22.0;
       Update newProductUpdateList;
       System.debug('newProductUpdateList::'+newProductUpdateList);

    }
    
}