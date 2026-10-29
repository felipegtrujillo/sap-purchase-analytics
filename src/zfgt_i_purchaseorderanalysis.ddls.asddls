@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Purchase order analysis (composite view)'
define view entity ZFGT_I_PurchaseOrderAnalysis
  as select from ZFGT_I_PurchaseOrder
  association [0..1] to ZFGT_I_PurchaseOrderTotal as _Total
    on $projection.PurchaseOrder = _Total.PurchaseOrder
{
  key PurchaseOrder,
      Supplier,
      _Supplier.SupplierName,
      _Supplier.Country          as SupplierCountry,
      CompanyCode,
      PurchasingOrganization,
      DocumentDate,
      substring( DocumentDate, 1, 4 ) as DocumentYear,
      substring( DocumentDate, 5, 2 ) as DocumentMonth,
      Status,
      case Status
        when 'O' then cast( 'Open'     as abap.char(10) )
        when 'R' then cast( 'Released' as abap.char(10) )
        when 'C' then cast( 'Closed'   as abap.char(10) )
        else          cast( 'Unknown'  as abap.char(10) )
      end                        as StatusText,
      Currency,

      @Semantics.amount.currencyCode: 'Currency'
      _Total.TotalNetAmount,
      _Total.NumberOfItems,

      /* Associations */
      _Supplier,
      _Item,
      _Total
}
