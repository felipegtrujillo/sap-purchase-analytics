@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase order (RAP projection)'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZFGT_C_PurchaseOrderTP
  provider contract transactional_query
  as projection on ZFGT_R_PurchaseOrder
{
      @EndUserText.label: 'Purchase Order'
      @Search.defaultSearchElement: true
  key PurchaseOrder,

      @EndUserText.label: 'Supplier'
      @Consumption.valueHelpDefinition: [ { entity: { name:    'ZFGT_C_SupplierVH',
                                                      element: 'Supplier' } } ]
      Supplier,

      @EndUserText.label: 'Company Code'
      CompanyCode,

      @EndUserText.label: 'Purchasing Org.'
      PurchasingOrganization,

      @EndUserText.label: 'Document Date'
      DocumentDate,

      @EndUserText.label: 'Currency'
      Currency,

      @EndUserText.label: 'Status'
      Status,

      @EndUserText.label: 'Created By'
      CreatedBy,
      @EndUserText.label: 'Created At'
      CreatedAt,
      @EndUserText.label: 'Changed By'
      LastChangedBy,
      @EndUserText.label: 'Changed At'
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _Item : redirected to composition child ZFGT_C_PurchaseOrderItemTP,
      _Supplier
}
