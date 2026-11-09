@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Purchase order analysis (consumption)'
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZFGT_C_PurchaseOrderAnalysis
  as select from ZFGT_I_PurchaseOrderAnalysis
   association [0..*] to ZFGT_C_PurchaseOrderItem as _Item
    on $projection.PurchaseOrder = _Item.PurchaseOrder
{
      @EndUserText.label: 'Purchase Order'
      @Search.defaultSearchElement: true
  key PurchaseOrder,

      @EndUserText.label: 'Supplier'
      Supplier,

      @EndUserText.label: 'Supplier Name'
      @Search.defaultSearchElement: true
      SupplierName,

      @EndUserText.label: 'Supplier Country'
      SupplierCountry,

      @EndUserText.label: 'Company Code'
      CompanyCode,

      @EndUserText.label: 'Purchasing Org.'
      PurchasingOrganization,

      @EndUserText.label: 'Document Date'
      DocumentDate,

      @EndUserText.label: 'Year'
      DocumentYear,

      @EndUserText.label: 'Status'
      StatusText,

      Currency,

      @EndUserText.label: 'Total Net Amount'
      @Semantics.amount.currencyCode: 'Currency'
      TotalNetAmount,

      @EndUserText.label: 'Items'
      NumberOfItems,
         /* Associations */
      _Item
}
