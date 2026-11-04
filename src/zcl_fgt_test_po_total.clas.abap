"! @testing ZFGT_I_PURCHASEORDERTOTAL
CLASS zcl_fgt_test_po_total DEFINITION
  PUBLIC FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA go_env TYPE REF TO if_cds_test_environment.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.

    METHODS sums_items_per_order      FOR TESTING.
    METHODS no_row_for_order_wo_items FOR TESTING.
    METHODS separates_currencies      FOR TESTING.
ENDCLASS.


CLASS zcl_fgt_test_po_total IMPLEMENTATION.

  METHOD class_setup.
    " Replace the view's data sources with test doubles
    go_env = cl_cds_test_environment=>create(
               i_for_entity = 'ZFGT_I_PURCHASEORDERTOTAL' ).
  ENDMETHOD.


  METHOD class_teardown.
    go_env->destroy( ).
  ENDMETHOD.


  METHOD setup.
    " Every test starts with empty doubles
    go_env->clear_doubles( ).
  ENDMETHOD.


  METHOD sums_items_per_order.
    " Given: two orders, the first with two items
    DATA lt_items TYPE STANDARD TABLE OF zfgt_i_purchaseorderitem WITH EMPTY KEY.
    lt_items = VALUE #(
      ( PurchaseOrder = 'PO1' PurchaseOrderItem = '00010' NetAmount = '100.00' Currency = 'USD' )
      ( PurchaseOrder = 'PO1' PurchaseOrderItem = '00020' NetAmount = '50.50'  Currency = 'USD' )
      ( PurchaseOrder = 'PO2' PurchaseOrderItem = '00010' NetAmount = '10.00'  Currency = 'EUR' ) ).
    go_env->insert_test_data( i_data = lt_items ).

    " When: reading the view
    SELECT * FROM zfgt_i_purchaseordertotal
      ORDER BY PurchaseOrder
      INTO TABLE @DATA(lt_totals).

    " Then: one row per order, with correct sum and count
    cl_abap_unit_assert=>assert_equals(
      exp = 2  act = lines( lt_totals )  msg = 'One row per order expected' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV zfgt_po_item-net_amount( '150.50' )
      act = lt_totals[ 1 ]-TotalNetAmount
      msg = 'PO1: total must be the sum of its items' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2  act = CONV i( lt_totals[ 1 ]-NumberOfItems )
      msg = 'PO1: two items expected' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV zfgt_po_item-net_amount( '10.00' )
      act = lt_totals[ 2 ]-TotalNetAmount
      msg = 'PO2: total of its single item' ).
  ENDMETHOD.


  METHOD no_row_for_order_wo_items.
    " Given: no items at all
    " When: reading the view
    SELECT * FROM zfgt_i_purchaseordertotal
      INTO TABLE @DATA(lt_totals).

    " Then: the aggregation returns no rows
    cl_abap_unit_assert=>assert_initial(
      act = lt_totals  msg = 'No items must produce no totals' ).
  ENDMETHOD.


  METHOD separates_currencies.
    " Given: one order with items in two different currencies
    DATA lt_items TYPE STANDARD TABLE OF zfgt_i_purchaseorderitem WITH EMPTY KEY.
    lt_items = VALUE #(
      ( PurchaseOrder = 'PO1' PurchaseOrderItem = '00010' NetAmount = '100.00' Currency = 'USD' )
      ( PurchaseOrder = 'PO1' PurchaseOrderItem = '00020' NetAmount = '80.00'  Currency = 'EUR' ) ).
    go_env->insert_test_data( i_data = lt_items ).

    " When: reading the view
    SELECT * FROM zfgt_i_purchaseordertotal
      ORDER BY PurchaseOrder, Currency
      INTO TABLE @DATA(lt_totals).

    " Then: one row per currency, amounts never mixed
    cl_abap_unit_assert=>assert_equals(
      exp = 2  act = lines( lt_totals )
      msg = 'Each currency must produce its own row' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV zfgt_po_item-currency_code( 'EUR' )
      act = lt_totals[ 1 ]-Currency
      msg = 'First row must be EUR (sorted by currency)' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV zfgt_po_item-net_amount( '80.00' )
      act = lt_totals[ 1 ]-TotalNetAmount
      msg = 'EUR total must not include USD amounts' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV zfgt_po_item-net_amount( '100.00' )
      act = lt_totals[ 2 ]-TotalNetAmount
      msg = 'USD total must not include EUR amounts' ).
  ENDMETHOD.

ENDCLASS.
