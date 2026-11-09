@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase order (RAP root)'
define root view entity ZFGT_R_PurchaseOrder
  as select from zfgt_po_head
  composition [0..*] of ZFGT_R_PurchaseOrderItem as _Item
  association [0..1] to ZFGT_I_Supplier          as _Supplier
    on $projection.Supplier = _Supplier.Supplier
{
  key po_id                 as PurchaseOrder,
      supplier_id           as Supplier,
      company_code          as CompanyCode,
      purch_org             as PurchasingOrganization,
      doc_date              as DocumentDate,
      currency_code         as Currency,
      status                as Status,

      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      /* Associations */
      _Item,
      _Supplier
}
