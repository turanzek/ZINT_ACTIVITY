class ZCL_ZINT_VALUE_HELPER_DPC_EXT definition
  public
  inheriting from ZCL_ZINT_VALUE_HELPER_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZINT_VALUE_HELPER_DPC_EXT IMPLEMENTATION.


  method /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY.
**TRY.
*CALL METHOD SUPER->/IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
*  EXPORTING
**    iv_entity_name          =
**    iv_entity_set_name      =
**    iv_source_name          =
*    IO_DATA_PROVIDER        =
**    it_key_tab              =
**    it_navigation_path      =
*    IO_EXPAND               =
**    io_tech_request_context =
**  IMPORTING
**    er_deep_entity          =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
  endmethod.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset.
    DATA: lv_name       TYPE zabap_s_value_help-name,
          ls_value_help TYPE zabap_s_value_help,
          lt_value_help TYPE TABLE OF zabap_s_value_help.

    CASE iv_entity_name.
      WHEN 'ValueHelp'.
      WHEN OTHERS.
        RETURN.
    ENDCASE.

    DATA(ls_app_id) =  it_filter_select_options[ property = 'Name' ].
    lv_name = ls_app_id-select_options[ 1 ]-low.

    CHECK lv_name IS NOT INITIAL.

    ls_value_help-name = lv_name.

    DATA(lr_criter1) = CORRESPONDING ZINT_TT_ACT_CRITERIA_RANGE( VALUE #( it_filter_select_options[ property = 'Criteria1'  ]-select_options OPTIONAL ) ) .
    DATA(lr_criter2) = CORRESPONDING ZINT_TT_ACT_CRITERIA_RANGE( VALUE #( it_filter_select_options[ property = 'Criteria2'  ]-select_options OPTIONAL ) ) .
    DATA(lr_criter3) = CORRESPONDING ZINT_TT_ACT_CRITERIA_RANGE( VALUE #( it_filter_select_options[ property = 'Criteria3'  ]-select_options OPTIONAL ) ) .


    zcl_int_act_fiori_value_helper=>prepare_value_help( EXPORTING ir_criter1  = lr_criter1
                                                                   ir_criter2  = lr_criter2
                                                                   ir_criter3  = lr_criter3
                                                 CHANGING cs_value_help   = ls_value_help ) .


    LOOP AT ls_value_help-values ASSIGNING FIELD-SYMBOL(<ls_value>).
      <ls_value>-name = lv_name.
    ENDLOOP.


    APPEND ls_value_help TO lt_value_help.

    copy_data_to_ref( EXPORTING  is_data = lt_value_help
                       CHANGING  cr_data = er_entityset ).


  ENDMETHOD.
ENDCLASS.
