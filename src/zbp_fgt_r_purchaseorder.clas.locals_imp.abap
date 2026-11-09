CLASS lhc_purchaseorder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR PurchaseOrder
      RESULT result.
ENDCLASS.

CLASS lhc_purchaseorder IMPLEMENTATION.
  METHOD get_global_authorizations.
    " Everyone may create, update and delete for now.
    " Real authorization checks come later.
    result = VALUE #( %create = if_abap_behv=>auth-allowed
                      %update = if_abap_behv=>auth-allowed
                      %delete = if_abap_behv=>auth-allowed ).
  ENDMETHOD.
ENDCLASS.
