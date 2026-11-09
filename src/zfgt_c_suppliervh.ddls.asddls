@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier value help'
@Search.searchable: true
define view entity ZFGT_C_SupplierVH
  as select from ZFGT_I_Supplier
{
      @EndUserText.label: 'Supplier'
      @Search.defaultSearchElement: true
  key Supplier,

      @EndUserText.label: 'Supplier Name'
      @Search.defaultSearchElement: true
      SupplierName,

      @EndUserText.label: 'Country'
      Country,

      @EndUserText.label: 'City'
      CityName
}
