@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier spend per year (composite view)'
define view entity ZFGT_I_SupplierSpend
  as select from ZFGT_I_PurchaseOrderAnalysis
{
  key Supplier,
  key DocumentYear,
  key Currency,
      SupplierName,
      SupplierCountry,

      @Semantics.amount.currencyCode: 'Currency'
      sum( TotalNetAmount ) as TotalSpend,

      count( * )            as NumberOfOrders
}
group by Supplier,
         DocumentYear,
         Currency,
         SupplierName,
         SupplierCountry
