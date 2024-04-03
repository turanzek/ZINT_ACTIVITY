class ZCL_ZINT_ACTIVITY_SYST_DPC_EXT definition
  public
  inheriting from ZCL_ZINT_ACTIVITY_SYST_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET
    redefinition .
protected section.

  methods DATAMODELSET_CREATE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZINT_ACTIVITY_SYST_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.

    DATA: ls_model  TYPE zint_s_act_process_model,
          lv_app_id TYPE zint_de_act_app_id.
    DATA: lo_exception TYPE REF TO /iwbep/cx_mgw_tech_exception.

    DATA lv_text TYPE bapi_msg.


    CASE iv_entity_name.
      WHEN 'ProcessModel'.
      WHEN OTHERS.
        RETURN.
    ENDCASE.


    io_data_provider->read_entry_data( IMPORTING es_data = ls_model ).

    zcl_int_act_process_manager=>action_handle( CHANGING  cs_model = ls_model ) .


    DATA(lt_return) = zcl_int_act_process_manager=>get_return( ) .


*    ls_model-last_time = sy-uzeit.
*    ls_model-last_date = sy-datum.
*    ls_model-last_user = sy-uname.


    LOOP AT lt_return INTO DATA(ls_return) WHERE type CA 'EAX'.
    ENDLOOP.
    IF sy-subrc IS INITIAL.
      CREATE OBJECT lo_exception.
      lo_exception->get_msg_container( )->add_messages_from_bapi( it_bapi_messages = lt_return ).


      MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number WITH ls_return-message_v1
                                                                               ls_return-message_v2
                                                                               ls_return-message_v3
                                                                               ls_return-message_v4 INTO lv_text.

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          textid            = /iwbep/cx_mgw_busi_exception=>business_error
          message           = lv_text
          message_container = lo_exception->get_msg_container( ).
    ENDIF.

    copy_data_to_ref( EXPORTING  is_data = ls_model
                       CHANGING  cr_data = er_deep_entity ).

  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset.

    DATA: lv_guid TYPE sysuuid_c32,
          lv_app  TYPE zmm_app_id.
    DATA: lt_model TYPE TABLE OF zint_s_act_app_model.

    CASE iv_entity_name.
      WHEN 'Application'.

      WHEN OTHERS.
        RETURN.
    ENDCASE.

    DATA(ls_app) =  it_filter_select_options[ property = 'App' ].
    lv_app = ls_app-select_options[ 1 ]-low.

    DATA(ls_guid) =  it_filter_select_options[ property = 'Guid' ].
    lv_guid = ls_guid-select_options[ 1 ]-low.


    CHECK lv_guid IS NOT INITIAL AND lv_app IS NOT INITIAL.

    zcl_activity_system_model=>init_application( EXPORTING  iv_guid   = lv_guid
                                                            iv_app = lv_app ) .

    APPEND zcl_activity_system_model=>get_application_model( ) TO lt_model.

    copy_data_to_ref( EXPORTING  is_data = lt_model
                       CHANGING  cr_data = er_entityset ).


  ENDMETHOD.


  method DATAMODELSET_CREATE_ENTITY.
**TRY.
*CALL METHOD SUPER->DATAMODELSET_CREATE_ENTITY
*  EXPORTING
*    IV_ENTITY_NAME          =
*    IV_ENTITY_SET_NAME      =
*    IV_SOURCE_NAME          =
*    IT_KEY_TAB              =
**    io_tech_request_context =
*    IT_NAVIGATION_PATH      =
**    io_data_provider        =
**  IMPORTING
**    er_entity               =
*    .
** CATCH /iwbep/cx_mgw_busi_exception .
** CATCH /iwbep/cx_mgw_tech_exception .
**ENDTRY.
  endmethod.
ENDCLASS.
