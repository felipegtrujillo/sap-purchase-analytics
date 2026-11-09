@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase order item (RAP child)'
define view entity ZFGT_R_PurchaseOrderItem
  as select from zfgt_po_item
  association to parent ZFGT_R_PurchaseOrder as _PurchaseOrder
    on $projection.PurchaseOrder = _PurchaseOrder.PurchaseOrder
{
  key po_id         as PurchaseOrder,
  key item_no       as PurchaseOrderItem,
      material_id   as Material,
      plant         as Plant,

      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      quantity      as OrderQuantity,
      order_unit    as OrderQuantityUnit,

      @Semantics.amount.currencyCode: 'Currency'
      net_price     as NetPrice,
      @Semantics.amount.currencyCode: 'Currency'
      net_amount    as NetAmount,
      currency_code as Currency,

      delivery_date as DeliveryDate,

      /* Associations */
      _PurchaseOrder
}
