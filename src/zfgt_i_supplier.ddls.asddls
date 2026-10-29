@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier (basic view)'
define view entity ZFGT_I_Supplier
  as select from zfgt_supplier
{
  key supplier_id as Supplier,
      name        as SupplierName,
      country     as Country,
      city        as CityName
}
