@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Purchase order item (consumption view)'
@Metadata.allowExtensions: true
define view entity ZFGT_C_PurchaseOrderItem
  as select from ZFGT_I_PurchaseOrderItem
  association [1..1] to ZFGT_C_PurchaseOrderAnalysis as _PurchaseOrder
    on $projection.PurchaseOrder = _PurchaseOrder.PurchaseOrder
{
      @EndUserText.label: 'Purchase Order'
  key PurchaseOrder,

      @EndUserText.label: 'Item'
  key PurchaseOrderItem,

      @EndUserText.label: 'Material'
      Material,

      @EndUserText.label: 'Plant'
      Plant,

      @EndUserText.label: 'Quantity'
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      OrderQuantity,

      OrderQuantityUnit,

      @EndUserText.label: 'Net Price'
      @Semantics.amount.currencyCode: 'Currency'
      NetPrice,

      @EndUserText.label: 'Net Amount'
      @Semantics.amount.currencyCode: 'Currency'
      NetAmount,

      Currency,

      @EndUserText.label: 'Delivery Date'
      DeliveryDate,

      /* Associations */
      _PurchaseOrder
}
