CLASS zcl_fgt_data_generator DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES:
      tt_supplier TYPE STANDARD TABLE OF zfgt_supplier WITH EMPTY KEY,
      tt_head     TYPE STANDARD TABLE OF zfgt_po_head  WITH EMPTY KEY,
      tt_item     TYPE STANDARD TABLE OF zfgt_po_item  WITH EMPTY KEY,
      BEGIN OF ty_material,
        id         TYPE c LENGTH 18,
        base_cents TYPE i,
        unit       TYPE c LENGTH 3,
      END OF ty_material,
      tt_material TYPE STANDARD TABLE OF ty_material WITH EMPTY KEY.

    CONSTANTS:
      c_seed      TYPE i VALUE 42,
      c_suppliers TYPE i VALUE 50,
      c_materials TYPE i VALUE 500,
      c_orders    TYPE i VALUE 20000,
      c_max_items TYPE i VALUE 15,
      c_days      TYPE i VALUE 664.

    DATA mo_random TYPE REF TO cl_abap_random_int.

    METHODS rand
      IMPORTING iv_min          TYPE i
                iv_max          TYPE i
      RETURNING VALUE(rv_value) TYPE i.

    METHODS clear_tables.

    METHODS build_suppliers
      RETURNING VALUE(rt_suppliers) TYPE tt_supplier.

    METHODS build_materials
      RETURNING VALUE(rt_materials) TYPE tt_material.

    METHODS build_orders
      IMPORTING it_suppliers TYPE tt_supplier
                it_materials TYPE tt_material
      EXPORTING et_heads     TYPE tt_head
                et_items     TYPE tt_item.
ENDCLASS.


CLASS zcl_fgt_data_generator IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    mo_random = cl_abap_random_int=>create( seed = c_seed
                                            min  = 0
                                            max  = 999999 ).
    clear_tables( ).

    DATA(lt_suppliers) = build_suppliers( ).
    DATA(lt_materials) = build_materials( ).

    build_orders( EXPORTING it_suppliers = lt_suppliers
                            it_materials = lt_materials
                  IMPORTING et_heads     = DATA(lt_heads)
                            et_items     = DATA(lt_items) ).

    INSERT zfgt_supplier FROM TABLE @lt_suppliers.
    INSERT zfgt_po_head  FROM TABLE @lt_heads.
    INSERT zfgt_po_item  FROM TABLE @lt_items.
    COMMIT WORK.

    out->write( |Suppliers:       { lines( lt_suppliers ) }| ).
    out->write( |Purchase orders: { lines( lt_heads ) }| ).
    out->write( |Items:           { lines( lt_items ) }| ).
  ENDMETHOD.


  METHOD rand.
    rv_value = iv_min + mo_random->get_next( ) MOD ( iv_max - iv_min + 1 ).
  ENDMETHOD.


  METHOD clear_tables.
    " Re-runnable: always start from empty tables
    DELETE FROM zfgt_po_item.
    DELETE FROM zfgt_po_head.
    DELETE FROM zfgt_supplier.
  ENDMETHOD.


  METHOD build_suppliers.
    TYPES: BEGIN OF ty_location,
             country TYPE c LENGTH 3,
             city    TYPE c LENGTH 40,
           END OF ty_location.
    DATA lt_locations TYPE STANDARD TABLE OF ty_location WITH EMPTY KEY.

    lt_locations = VALUE #( ( country = 'CL' city = 'Santiago' )
                            ( country = 'US' city = 'Houston' )
                            ( country = 'DE' city = 'Hamburg' )
                            ( country = 'BR' city = 'Sao Paulo' )
                            ( country = 'MX' city = 'Monterrey' )
                            ( country = 'CN' city = 'Shenzhen' ) ).

    DO c_suppliers TIMES.
      DATA(lv_i)   = sy-index.
      DATA(ls_loc) = lt_locations[ rand( iv_min = 1 iv_max = lines( lt_locations ) ) ].
      APPEND VALUE #( supplier_id = |SUP{ lv_i WIDTH = 7 ALIGN = RIGHT PAD = '0' }|
                      name        = |Supplier { lv_i }|
                      country     = ls_loc-country
                      city        = ls_loc-city ) TO rt_suppliers.
    ENDDO.
  ENDMETHOD.


  METHOD build_materials.
    DO c_materials TIMES.
      DATA(lv_i) = sy-index.
      APPEND VALUE #( id         = |MAT-{ lv_i WIDTH = 6 ALIGN = RIGHT PAD = '0' }|
                      base_cents = rand( iv_min = 100 iv_max = 50000 )
                      unit       = COND #( WHEN lv_i MOD 5 = 0 THEN 'KG' ELSE 'EA' ) )
             TO rt_materials.
    ENDDO.
  ENDMETHOD.


  METHOD build_orders.
    DATA ls_head    TYPE zfgt_po_head.
    DATA ls_item    TYPE zfgt_po_item.
    DATA lv_ts      TYPE timestampl.
    DATA lv_start   TYPE d VALUE '20250101'.
    DATA lv_f       TYPE decfloat34.
    DATA lv_qty     TYPE decfloat34.
    DATA lv_price   TYPE decfloat34.
    DATA lv_sup_idx TYPE i.
    DATA lv_n_items TYPE i.

    CLEAR: et_heads, et_items.
    GET TIME STAMP FIELD lv_ts.
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).

    DO c_orders TIMES.
      DATA(lv_order) = sy-index.
      CLEAR ls_head.

      " Pareto-like distribution: low supplier numbers get most orders
      lv_f       = CONV decfloat34( rand( iv_min = 0 iv_max = 9999 ) ) / 10000.
      lv_sup_idx = 1 + floor( lv_f * lv_f * c_suppliers ).

      ls_head-po_id       = |{ lv_order WIDTH = 10 ALIGN = RIGHT PAD = '0' }|.
      ls_head-supplier_id = it_suppliers[ lv_sup_idx ]-supplier_id.
      ls_head-doc_date    = lv_start + rand( iv_min = 0 iv_max = c_days ).

      IF rand( iv_min = 1 iv_max = 100 ) <= 70.
        ls_head-company_code = '1000'.
        ls_head-purch_org    = 'P100'.
      ELSE.
        ls_head-company_code = '2000'.
        ls_head-purch_org    = 'P200'.
      ENDIF.

      ls_head-currency_code = COND #( WHEN rand( iv_min = 1 iv_max = 100 ) <= 80
                                      THEN 'USD' ELSE 'EUR' ).

      " Older orders are mostly closed; recent ones are mixed
      DATA(lv_s) = rand( iv_min = 1 iv_max = 100 ).
      IF ls_head-doc_date < '20260101'.
        ls_head-status = COND #( WHEN lv_s <= 90 THEN 'C' ELSE 'R' ).
      ELSE.
        ls_head-status = COND #( WHEN lv_s <= 30 THEN 'O'
                                 WHEN lv_s <= 70 THEN 'R'
                                 ELSE 'C' ).
      ENDIF.

      ls_head-created_by            = lv_user.
      ls_head-created_at            = lv_ts.
      ls_head-last_changed_by       = lv_user.
      ls_head-last_changed_at       = lv_ts.
      ls_head-local_last_changed_at = lv_ts.
      APPEND ls_head TO et_heads.

      lv_n_items = rand( iv_min = 1 iv_max = c_max_items ).
      DO lv_n_items TIMES.
        DATA(lv_item) = sy-index.
        CLEAR ls_item.
        DATA(ls_mat) = it_materials[ rand( iv_min = 1 iv_max = c_materials ) ].

        ls_item-po_id       = ls_head-po_id.
        ls_item-item_no     = lv_item * 10.
        ls_item-material_id = ls_mat-id.
        ls_item-plant       = |PL0{ rand( iv_min = 1 iv_max = 4 ) }|.
        ls_item-order_unit  = ls_mat-unit.

        IF ls_mat-unit = 'KG'.
          lv_qty = CONV decfloat34( rand( iv_min = 100 iv_max = 50000 ) ) / 100.
        ELSE.
          lv_qty = rand( iv_min = 1 iv_max = 100 ).
        ENDIF.

        " Outliers: about 0.5% of items with abnormally large quantities
        IF rand( iv_min = 1 iv_max = 1000 ) <= 5.
          lv_qty = lv_qty * 50.
        ENDIF.

        " Price varies +/-10% around the material's base price
        lv_price = CONV decfloat34( ls_mat-base_cents ) / 100
                   * rand( iv_min = 90 iv_max = 110 ) / 100.

        ls_item-quantity      = lv_qty.
        ls_item-net_price     = round( val = lv_price dec = 2 ).
        ls_item-net_amount    = round( val = lv_qty * ls_item-net_price dec = 2 ).
        ls_item-currency_code = ls_head-currency_code.
        ls_item-delivery_date = ls_head-doc_date + rand( iv_min = 7 iv_max = 60 ).
        APPEND ls_item TO et_items.
      ENDDO.
    ENDDO.
  ENDMETHOD.

ENDCLASS.
