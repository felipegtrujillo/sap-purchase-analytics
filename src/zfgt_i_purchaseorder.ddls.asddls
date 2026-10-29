@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase order (basic view)'
define view entity ZFGT_I_PurchaseOrder
  as select from zfgt_po_head
  association [1..1] to ZFGT_I_Supplier as _Supplier
    on $projection.Supplier = _Supplier.Supplier
     association [1..*] to ZFGT_I_PurchaseOrderItem as _Item
    on $projection.PurchaseOrder = _Item.PurchaseOrder
{
  key po_id         as PurchaseOrder,
      supplier_id   as Supplier,
      company_code  as CompanyCode,
      purch_org     as PurchasingOrganization,
      doc_date      as DocumentDate,
      currency_code as Currency,
      status        as Status,

      /* Associations */
      _Supplier,
      _Item
}
