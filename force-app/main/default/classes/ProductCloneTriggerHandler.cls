/************************************************************************************************************************************
* @Name         :ProductCloneTriggerHandler 
* @Date         :03/05/2022
* @Group        :Altokk Software Solutions
* @Description  :This class is handler class for trigger when a product is created.
* @Dependencies : ProductTrigger
*************************************************************************************************************************************/
public class ProductCloneTriggerHandler {
    public static Boolean isFirst = true;
    public static void creatingDuplicateRecord(Product2 Product){
        //Finding out if there is any record already with triggered product name as its unique name.
        List<Product2> ProductsNotMatched = [SELECT Id,Name,Unique_Product__c FROM Product2 where Unique_Product__c=:product.Name];
       //If there is no record then create a new record.
        if(ProductsNotMatched.size()==0)
        { 
            if(product.Serial_Number__c != null)
            { 
                Product2 newProduct = new Product2();
                newProduct.Description_1__c = product.Description_1__c;
                newProduct.Description_2__c = product.Description_2__c;
                newProduct.Description = product.Description;
                newProduct.Name = product.Name;
                newProduct.IsActive=true;
                newProduct.Price__c=product.Price__c;
                newProduct.Unique_Product__c = product.Name;
                newProduct.Serial_Number__c = null;
                insert newProduct;
            }
            else
            {
                System.debug('product.Serial_Number__c is null');
            }
        }
        else
        {
            System.debug('Already one duplicate product is there with unique name and serial number null::'+Product.Name);
            
        }
    }
    
}