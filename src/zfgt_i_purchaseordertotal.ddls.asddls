@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase order totals (composite view)'
define view entity ZFGT_I_PurchaseOrderTotal
  as select from ZFGT_I_PurchaseOrderItem
{
  key PurchaseOrder,
      Currency,

      @Semantics.amount.currencyCode: 'Currency'
      sum( NetAmount ) as TotalNetAmount,

      count( * )       as NumberOfItems
}
group by PurchaseOrder,
         Currency
