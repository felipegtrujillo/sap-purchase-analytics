@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase order item (RAP projection)'
@Metadata.allowExtensions: true
define view entity ZFGT_C_PurchaseOrderItemTP
  as projection on ZFGT_R_PurchaseOrderItem
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
      OrderQuantity,
      OrderQuantityUnit,
      @EndUserText.label: 'Net Price'
      NetPrice,
      @EndUserText.label: 'Net Amount'
      NetAmount,
      Currency,
      @EndUserText.label: 'Delivery Date'
      DeliveryDate,

      /* Associations */
      _PurchaseOrder : redirected to parent ZFGT_C_PurchaseOrderTP
}
