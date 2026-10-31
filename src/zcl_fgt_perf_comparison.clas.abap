CLASS zcl_fgt_perf_comparison DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_total,
        po_id         TYPE zfgt_po_item-po_id,
        currency_code TYPE zfgt_po_item-currency_code,
        total         TYPE zfgt_po_item-net_amount,
        items         TYPE i,
      END OF ty_total,
      tt_total TYPE SORTED TABLE OF ty_total
               WITH UNIQUE KEY po_id currency_code.

    CONSTANTS c_runs TYPE i VALUE 5.

    METHODS via_abap_loop RETURNING VALUE(rt_totals) TYPE tt_total.
    METHODS via_open_sql  RETURNING VALUE(rt_totals) TYPE tt_total.
    METHODS via_cds       RETURNING VALUE(rt_totals) TYPE tt_total.

    METHODS measure
      IMPORTING iv_variant       TYPE string
                io_out           TYPE REF TO if_oo_adt_classrun_out
      RETURNING VALUE(rt_totals) TYPE tt_total.
ENDCLASS.


CLASS zcl_fgt_perf_comparison IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA(lt_loop) = measure( iv_variant = `ABAP LOOP` io_out = out ).
    DATA(lt_cds)  = measure( iv_variant = `CDS VIEW`  io_out = out ).
    DATA(lt_sql)  = measure( iv_variant = `OPEN SQL`  io_out = out ).


    IF lt_loop = lt_sql AND lt_sql = lt_cds.
      out->write( |Check: all three results are identical ({ lines( lt_sql ) } totals).| ).
    ELSE.
      out->write( |Check FAILED: results differ. LOOP={ lines( lt_loop ) } | &&
                  |SQL={ lines( lt_sql ) } CDS={ lines( lt_cds ) }| ).
    ENDIF.
  ENDMETHOD.


  METHOD measure.
    DATA lv_start   TYPE utclong.
    DATA lv_seconds TYPE decfloat34.

    " One extra run as warm-up; it is not counted
    DO c_runs + 1 TIMES.
      DATA(lv_run) = sy-index.
      lv_start = utclong_current( ).

      CASE iv_variant.
        WHEN `ABAP LOOP`. rt_totals = via_abap_loop( ).
        WHEN `OPEN SQL`.  rt_totals = via_open_sql( ).
        WHEN `CDS VIEW`.  rt_totals = via_cds( ).
      ENDCASE.

      IF lv_run > 1.
        lv_seconds = lv_seconds + utclong_diff( high = utclong_current( )
                                                low  = lv_start ).
      ENDIF.
    ENDDO.

    DATA(lv_avg_ms) = lv_seconds / c_runs * 1000.
    io_out->write( |{ iv_variant WIDTH = 10 }: { lv_avg_ms DECIMALS = 1 } ms (avg of { c_runs } runs)| ).
  ENDMETHOD.


  METHOD via_abap_loop.
    " Classic style: fetch every item, aggregate on the application server
    SELECT po_id, currency_code, net_amount
      FROM zfgt_po_item
      INTO TABLE @DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item).
      READ TABLE rt_totals ASSIGNING FIELD-SYMBOL(<ls_total>)
           WITH TABLE KEY po_id         = ls_item-po_id
                          currency_code = ls_item-currency_code.
      IF sy-subrc <> 0.
        INSERT VALUE #( po_id         = ls_item-po_id
                        currency_code = ls_item-currency_code )
               INTO TABLE rt_totals ASSIGNING <ls_total>.
      ENDIF.
      <ls_total>-total = <ls_total>-total + ls_item-net_amount.
      <ls_total>-items = <ls_total>-items + 1.
    ENDLOOP.
  ENDMETHOD.


  METHOD via_open_sql.
    " Code pushdown: the database aggregates, only totals travel back
    SELECT po_id,
           currency_code,
           SUM( net_amount ) AS total,
           COUNT(*)          AS items
      FROM zfgt_po_item
      GROUP BY po_id, currency_code
      INTO CORRESPONDING FIELDS OF TABLE @rt_totals.
  ENDMETHOD.


  METHOD via_cds.
    " Same pushdown, but the logic lives in a reusable CDS view
    SELECT PurchaseOrder  AS po_id,
           Currency       AS currency_code,
           TotalNetAmount AS total,
           NumberOfItems  AS items
      FROM zfgt_i_purchaseordertotal
      INTO CORRESPONDING FIELDS OF TABLE @rt_totals.
  ENDMETHOD.

ENDCLASS.
