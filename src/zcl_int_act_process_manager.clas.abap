class ZCL_INT_ACT_PROCESS_MANAGER definition
  public
  final
  create public .

public section.

  class-methods GET_RETURN
    returning
      value(ET_RETURN) type BAPIRET2_TT .
  class-methods INIT_APPLICATION
    importing
      !IV_APP type ZINT_DE_ACT_APP_ID
      !IV_GUID type SYSUUID_C32 .
  class-methods ACTION_HANDLE
    changing
      !CS_MODEL type ZINT_S_ACT_PROCESS_MODEL optional .
protected section.
private section.

  class-data MT_RETURN type BAPIRET2_TT .

  class-methods PERFORM_VALIDATIONS
    changing
      !CS_MODEL type ZINT_S_ACT_PROCESS_MODEL optional .
ENDCLASS.



CLASS ZCL_INT_ACT_PROCESS_MANAGER IMPLEMENTATION.


  METHOD ACTION_HANDLE.

*
*    DATA(ls_person) = zcl_may_helper=>get_session_person( ) .
*
*    DATA: ls_valuation TYPE zmm_s_may_valuation.
*
*    cs_model-person_info  = CORRESPONDING #( ls_person ) .
*
*    perform_validations( CHANGING cs_model = cs_model ).
*
*    READ TABLE mt_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
*    IF sy-subrc IS INITIAL .
*      RETURN.
*    ENDIF.
*
*    update_defaults( CHANGING cs_model = cs_model ).
*
*
*    CASE cs_model-action_type.
*
*      WHEN zif_may_constants=>mc_action_send.
*
*        send( CHANGING  cs_model = cs_model ) .
*
*      WHEN zif_may_constants=>mc_action_approve OR  zif_may_constants=>mc_action_reject OR  zif_may_constants=>mc_action_review.
*
*        approve_reject_review( CHANGING cs_model = cs_model  ) .
*
*    ENDCASE.
*
*    update_actions( CHANGING cs_model = cs_model ) .
*
*
*    LOOP AT mt_return INTO DATA(ls_return) WHERE type CA 'EAX'.
*    ENDLOOP.
*    IF sy-subrc IS NOT INITIAL.
*      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*        EXPORTING
*          wait = 'X'.
*
*      IF cs_model-status EQ zif_may_constants=>mc_status_completed AND (
*         cs_model-process_type EQ zif_may_constants=>mc_process_creation OR
*         cs_model-process_type EQ zif_may_constants=>mc_process_change ) .
*
*        APPEND LINES OF zcl_may_business_apis=>extend_material_valuation( EXPORTING  is_model = cs_model ) TO mt_return.
*        APPEND LINES OF zcl_may_business_apis=>save_material_text( EXPORTING is_model = cs_model ) TO mt_return.
*        APPEND LINES OF zcl_may_business_apis=>save_material_note( EXPORTING is_model = cs_model )   TO mt_return.
*        APPEND LINES OF zcl_may_file_handler=>update_files_material( EXPORTING is_model = cs_model ) TO mt_return.
*
*
*        LOOP AT mt_return TRANSPORTING NO FIELDS WHERE type CA 'EAX'.
*        ENDLOOP.
*        IF sy-subrc IS NOT INITIAL.
*          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*            EXPORTING
*              wait = 'X'.
*
*        ELSE.
*          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*        ENDIF.
*      ENDIF.
*
*      zcl_may_helper=>send_email( is_model = cs_model ).
*    ELSE.
*      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*    ENDIF.
*
*
*
*
**    CASE is_model-process_model-process_type.
**      WHEN zif_may_constants=>mc_process_creation.
**      WHEN zif_may_constants=>mc_process_change.
**      WHEN zif_may_constants=>mc_process_expand.
**      WHEN zif_may_constants=>mc_process_delete.
**      WHEN OTHERS.
**    ENDCASE.
*
**    CASE is_model-app.
**
**      WHEN zif_may_constants=>mc_app_creation.
**      WHEN zif_may_constants=>mc_a.
***
**      WHEN zif_may_constants=>mc_expand_app.
***
**      WHEN zif_may_constants=>mc_delete_app.
***
***      WHEN zif_may_constants=>mc_release_app.
***
***      WHEN zif_may_constants=>mc_complete_app.
**
**      WHEN OTHERS.
**        RETURN.
**    ENDCASE.
**    start_release( EXPORTING is_model = is_model ).
*

  ENDMETHOD.


  METHOD GET_RETURN.
    et_return = mt_return.
  ENDMETHOD.


  METHOD INIT_APPLICATION.

    zcl_may_model=>set_application_model( EXPORTING iv_guid = iv_guid
                                                    iv_app  = iv_app ) .

    zcl_may_model=>set_data_model( ) .
    zcl_may_model=>set_ui_model( ) .


  ENDMETHOD.


  METHOD PERFORM_VALIDATIONS.

*    LOOP AT cs_model-storages INTO DATA(ls_storage).
*      IF ls_storage-lgort IS INITIAL AND ls_storage-lgpbe IS NOT INITIAL.
*        APPEND zcl_may_utils=>message_number_to_return( EXPORTING iv_type = 'E'  iv_number = '006' ) TO mt_return.
*      ENDIF.
*    ENDLOOP.
*
*
*    LOOP AT cs_model-valuations INTO DATA(ls_valuation).
*      IF ls_valuation-currency IS INITIAL AND ls_valuation-stprs IS NOT INITIAL.
*        APPEND zcl_may_utils=>message_number_to_return( EXPORTING iv_type = 'E'  iv_number = '008' ) TO mt_return.
*      ENDIF.
*
*      IF ls_valuation-currency IS NOT INITIAL AND ls_valuation-stprs IS INITIAL.
*        APPEND zcl_may_utils=>message_number_to_return( EXPORTING iv_type = 'E'  iv_number = '009' ) TO mt_return.
*      ENDIF.
*    ENDLOOP.
*
*
*    CASE cs_model-action_type.
*      WHEN zif_may_constants=>mc_action_send.
*
*        IF cs_model-matnr NE zif_may_constants=>mc_material_new.
*
*          SELECT SINGLE *
*            FROM zmm_t_may_master
*            INTO @DATA(ls_master)
*            WHERE matnr EQ @cs_model-matnr  AND
*                  status NE @zif_may_constants=>mc_status_completed AND
*                  status NE @zif_may_constants=>mc_status_rejected.
*          IF sy-subrc IS INITIAL.
*            APPEND zcl_may_utils=>message_number_to_return( EXPORTING iv_type = 'E'  iv_number = '007' ) TO mt_return.
*            RETURN.
*          ENDIF.
*
*        ENDIF.
*
*      WHEN OTHERS.
*
*        SELECT COUNT(*)
*         FROM zmm_t_may_master
*         WHERE matnr EQ cs_model-matnr  AND
*               request_no   EQ cs_model-request_no AND
*               status       EQ cs_model-status AND
*               active_step  EQ cs_model-active_step .
*        IF sy-subrc IS NOT INITIAL.
*          APPEND zcl_may_utils=>message_number_to_return( EXPORTING iv_type = 'E'  iv_number = '007' ) TO mt_return.
*          RETURN.
*        ENDIF.
*
*    ENDCASE.


  ENDMETHOD.
ENDCLASS.
