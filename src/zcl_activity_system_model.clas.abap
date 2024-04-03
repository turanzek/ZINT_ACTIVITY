class ZCL_ACTIVITY_SYSTEM_MODEL definition
  public
  final
  create public .

public section.

  class-data MO_INSTANCE type ref to ZCL_ACTIVITY_SYSTEM_MODEL .

  class-methods INIT_APPLICATION
    importing
      !IV_APP type ZINT_DE_ACT_APPLICATION
      !IV_GUID type SYSUUID_C32 .
  class-methods SET_DATA_MODEL .
  class-methods SET_UI_MODEL .
  class-methods GET_APPLICATION_MODEL
    returning
      value(RS_APP_MODEL) type ZINT_S_ACT_APP_MODEL .
  class-methods SET_APPLICATION_MODEL
    importing
      value(IV_APP) type ZINT_DE_ACT_APP_ID
      !IV_GUID type SYSUUID_C32 .
  class-methods FILL_MAIN_MASTERS
    changing
      !CT_MODEL type ZINT_TT_ACT_DATA_MODEL .
protected section.

  class-data MS_MODEL type ZINT_S_ACT_APP_MODEL .
private section.
ENDCLASS.



CLASS ZCL_ACTIVITY_SYSTEM_MODEL IMPLEMENTATION.


  METHOD fill_main_masters.


    DATA: ls_data_model TYPE zint_s_act_data_model,
          lt_master     TYPE TABLE OF zint_t_act_data.


    DATA(ls_app_model) =  zcl_activity_system_model=>get_application_model( ).
*    DATA: lr_process_type TYPE RANGE OF ZINT_S_ACT_DATA_MODEL-process_type,
*          lr_status       TYPE RANGE OF zmm_t_may_master-status.
*
*    DATA: lv_tabix   TYPE sy-tabix,
*          lv_matched.
*
*
*    CASE  ls_app_model-app.
*      WHEN zif_may_constants=>mc_app_creation.
*
*        lr_process_type = VALUE #( ( sign = 'I' option = 'EQ' low =  zif_may_constants=>mc_process_creation ) ).
*        lr_status = VALUE #( ( sign = 'I' option = 'NE' low =  zif_may_constants=>mc_status_completed ) ) .


    SELECT *
      FROM zint_t_act_data
      INTO TABLE lt_master.

    LOOP AT lt_master INTO DATA(ls_master).
      MOVE-CORRESPONDING ls_master TO ls_data_model.
      APPEND ls_data_model TO ct_model.
    ENDLOOP.


*    ENDCASE.



*    SORT ct_model BY request_no DESCENDING matnr ASCENDING.
*
*
*    LOOP AT ct_model ASSIGNING FIELD-SYMBOL(<ls_model>) WHERE request_no IS INITIAL.
*      <ls_model>-request_no = zif_may_constants=>mc_request_none.
*    ENDLOOP.
*
**    SORT ct_model BY request_no DESCENDING matnr ASCENDING.
*
*
*
*    LOOP AT ct_model ASSIGNING <ls_model>.
*
*      MOVE-CORRESPONDING ls_app_model-session_person TO <ls_model>-person_info.
*      <ls_model>-guid            = ls_app_model-guid.
*
*
*    ENDLOOP.



*
*    LOOP AT ct_model ASSIGNING <ls_model>.
*
*      zcl_may_logic=>determine_states(  CHANGING cs_model = <ls_model> ) .
*    ENDLOOP.







  ENDMETHOD.


  METHOD get_application_model.

    rs_app_model = ms_model.
  ENDMETHOD.


  METHOD init_application.
    zcl_activity_system_model=>set_application_model( EXPORTING iv_guid = iv_guid
                                                                iv_app  = iv_app ) .

    zcl_activity_system_model=>set_data_model( ) .
*****    zcl_activity_system_model=>set_ui_model( ) .

  ENDMETHOD.


  METHOD set_application_model.

    ms_model-session_person = zcl_int_activity_system_helper=>get_session_person( ) .
    ms_model-app = iv_app.
    ms_model-guid = iv_guid.

  ENDMETHOD.


  METHOD set_data_model.


    DATA: lt_data_model TYPE ZINT_TT_ACT_DATA_MODEL.

    ZCL_ACTIVITY_SYSTEM_MODEL=>fill_main_masters( CHANGING ct_model = lt_data_model ).
*    ZCL_ACTIVITY_SYS_DATA_PROVIDER=>fill_ui_configs( CHANGING ct_model = lt_data_model ).
*    ZCL_ACTIVITY_SYS_DATA_PROVIDER=>fill_other_masters( CHANGING ct_model = lt_data_model ).
*    ZCL_ACTIVITY_SYS_DATA_PROVIDER=>fill_active_values( CHANGING ct_model = lt_data_model ).


    ms_model-data_model = lt_data_model.

  ENDMETHOD.


  METHOD set_ui_model.

    DATA: ls_ui_model TYPE zmm_s_may_ui_model.

    CASE ms_model-app.
      WHEN zif_may_constants=>mc_app_creation.

        ls_ui_model-create_active = abap_true.

        IF zcl_may_logic=>is_general_mavy( ms_model-session_person-uname ).
          ls_ui_model-purchase_view_active = abap_true.
          ls_ui_model-purchase_view_editable = abap_true.
        ENDIF.

      WHEN zif_may_constants=>mc_app_change.
      WHEN zif_may_constants=>mc_app_expand.
      WHEN zif_may_constants=>mc_app_delete.
      WHEN zif_may_constants=>mc_app_release.
      WHEN OTHERS.
    ENDCASE.


    ms_model-ui_model = ls_ui_model.

  ENDMETHOD.
ENDCLASS.
