/************************************************************************************************************************************
* @Name         :ProductCreationWithoutSerialNumberTest 
* @Date         :03/05/2022
* @Group        :Altokk Software Solutions
* @Description  :This class is test class for trigger when a product is created.
*************************************************************************************************************************************/
@isTest
public class ProductCreationWithoutSerialNumberTest {    
    @TestSetup
    static void createTestData() {
        Product2 newProduct1 = new Product2();
        newProduct1.Name = 'Test Product1';
        newProduct1.Serial_Number__c='12345';
        newProduct1.Unique_Product__c = '111';
        insert newProduct1;
    }
    
    @isTest
    public static void cloneProductsTest() {
        List<Product2> newProductList = new List<Product2>();
        
        Product2 newProduct1 = new Product2();
        newProduct1.Name = 'Test Product1';
        newProduct1.Serial_Number__c='123456';
        newProduct1.Unique_Product__c = '11';
        newProduct1.Montreal__c=1;
        newProduct1.TOR_Hub__c=1;
        newProduct1.Toronto__c=1;
        newProduct1.Toronto_Showroom__c=1;
        newProduct1.Montreal_Showroom__c=1;
        newProduct1.MTL_Hub__c=1;
        newProduct1.Number_in_Inventory__c=1;
        
        Product2 newProduct2 = new Product2();
        newProduct2.Name = 'Test Product2';
        newProduct2.Serial_Number__c='1234567';
        newProduct2.Unique_Product__c = '22';
        
        newProductList.add(newProduct1);
        newProductList.add(newProduct2);
        
         Test.startTest();
        Database.SaveResult[] srList = Database.insert(newProductList);
        Test.stopTest();
        
    }
    
}