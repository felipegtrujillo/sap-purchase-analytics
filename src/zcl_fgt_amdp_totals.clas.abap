CLASS zcl_fgt_amdp_totals DEFINITION
  PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_amdp_marker_hdb.

    TYPES:
      BEGIN OF ty_total,
        po_id         TYPE zfgt_po_item-po_id,
        currency_code TYPE zfgt_po_item-currency_code,
        total         TYPE zfgt_po_item-net_amount,
        items         TYPE i,
      END OF ty_total,
      tt_total TYPE STANDARD TABLE OF ty_total WITH EMPTY KEY.

    CLASS-METHODS get_totals AMDP OPTIONS READ-ONLY CDS SESSION CLIENT DEPENDENT
      EXPORTING VALUE(et_totals) TYPE tt_total.
ENDCLASS.


CLASS zcl_fgt_amdp_totals IMPLEMENTATION.

  METHOD get_totals BY DATABASE PROCEDURE
                    FOR HDB
                    LANGUAGE SQLSCRIPT
                    USING zfgt_po_item.

    et_totals = SELECT po_id,
                       currency_code,
                       CAST( SUM( net_amount ) AS DECIMAL(15,2) ) AS total,
                       CAST( COUNT(*) AS INTEGER )                AS items
                  FROM zfgt_po_item
                 WHERE "CLIENT" = SESSION_CONTEXT( 'CDS_CLIENT' )
                 GROUP BY po_id, currency_code;

  ENDMETHOD.

ENDCLASS.
