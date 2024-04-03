class ZCL_ACTIVITY_SYS_DATA_PROVIDER definition
  public
  final
  create public .

public section.

  class-methods FILL_UI_CONFIGS
    changing
      !CT_MODEL type ZINT_TT_ACT_DATA_MODEL .
protected section.
private section.

  methods FILL_MAIN_MASTERS
    changing
      !CT_MODEL type ZINT_TT_ACT_DATA_MODEL .
ENDCLASS.



CLASS ZCL_ACTIVITY_SYS_DATA_PROVIDER IMPLEMENTATION.


  METHOD fill_main_masters.

*
*    DATA: ls_data_model TYPE zmm_s_may_data_model,
*          lt_master     TYPE TABLE OF zmm_t_may_master,
*          lt_mara       TYPE TABLE OF mara.
*
*    DATA(ls_app_model) =     zcl_may_model=>get_application_model( ).
*    DATA: lr_process_type TYPE RANGE OF zmm_t_may_master-process_type,
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
*
*
*        SELECT *
*          FROM zmm_t_may_master
*          INTO TABLE lt_master
*          WHERE process_type    IN lr_process_type AND
*                status           NE zif_may_constants=>mc_status_completed AND
**                status           NE zif_may_constants=>mc_status_rejected AND
*                delete_indicator EQ space AND
*                create_uname EQ ls_app_model-session_person-uname.
*
*        LOOP AT lt_master INTO DATA(ls_master).
*          MOVE-CORRESPONDING ls_master TO ls_data_model.
*          APPEND ls_data_model TO ct_model.
*        ENDLOOP.
*
*      WHEN zif_may_constants=>mc_app_change OR zif_may_constants=>mc_app_delete OR zif_may_constants=>mc_app_expand.
*
*
*
*        SELECT mara~*
*          FROM mara
*          INNER JOIN zmm_t_may_kinds ON zmm_t_may_kinds~mtart EQ mara~mtart
*          INTO CORRESPONDING FIELDS OF TABLE @lt_mara
*          WHERE lvorm EQ @space.
*
*        SELECT *
*          FROM zmm_t_may_master
*          INTO TABLE lt_master
*          WHERE delete_indicator EQ space.
*
*
*        DATA(lt_master_rejected) = lt_master.
*        DATA(lt_master_completed) = lt_master.
*
*        DELETE lt_master WHERE status EQ zif_may_constants=>mc_status_rejected OR
*                               status EQ zif_may_constants=>mc_status_completed.
*
*        DELETE lt_master_completed WHERE status NE zif_may_constants=>mc_status_completed OR
*                                         ( process_type NE zif_may_constants=>mc_process_creation and
*                                           process_type NE zif_may_constants=>mc_process_change ).
*
*        SORT lt_master_completed BY matnr create_date DESCENDING create_time DESCENDING.
*
*        DELETE lt_master_rejected WHERE status NE zif_may_constants=>mc_status_rejected OR
*                                        create_uname NE ls_app_model-session_person-uname.
*
*
*        LOOP AT lt_mara INTO DATA(ls_mara).
*
*          CLEAR ls_data_model.
*          MOVE-CORRESPONDING ls_mara TO ls_data_model.
*          ls_data_model-create_date = ls_mara-ersda.
*
*
*          ls_data_model-storage_text  = zcl_may_business_apis=>read_material_text( ls_data_model-matnr ).
*          ls_data_model-material_note  = zcl_may_business_apis=>read_material_note( ls_data_model-matnr ).
*
*          READ TABLE lt_master_completed INTO DATA(ls_master_completed) WITH  KEY matnr = ls_data_model-matnr BINARY SEARCH.
*          IF sy-subrc IS INITIAL .
*            ls_data_model-vendor_choice = ls_master_completed-vendor_choice.
*          ENDIF.
*
*
**          LOOP AT lt_master INTO ls_master WHERE matnr EQ ls_master-matnr.
**          ENDLOOP.
**
*
*          SELECT SINGLE material_kind
*            FROM zmm_t_may_kinds
*            INTO ls_data_model-material_kind
*            WHERE mtart EQ ls_mara-mtart.
*
*          CASE ls_app_model-app.
*            WHEN zif_may_constants=>mc_app_change .
*
*              ls_data_model-process_type  = zif_may_constants=>mc_process_change.
*
*            WHEN zif_may_constants=>mc_app_delete .
*
*              ls_data_model-process_type  = zif_may_constants=>mc_process_delete.
*
*            WHEN zif_may_constants=>mc_app_expand..
*
*              ls_data_model-process_type  = zif_may_constants=>mc_process_expand.
*
*          ENDCASE.
*
*
*
*          READ TABLE lt_master INTO ls_master WITH KEY matnr = ls_data_model-matnr.
*          IF sy-subrc IS INITIAL.
*            IF ls_data_model-process_type NE ls_master-process_type.
*              CONTINUE.
*            ENDIF.
**            ls_data_model-process_type  = ls_master-process_type.
*            ls_data_model-status        = ls_master-status.
*            ls_data_model-active_step   = ls_master-active_step.
*            ls_data_model-last_date     = ls_master-last_date    .
*            ls_data_model-last_time     = ls_master-last_time    .
*            ls_data_model-last_user     = ls_master-last_user    .
*            ls_data_model-create_date   = ls_master-create_date  .
*            ls_data_model-create_time   = ls_master-create_time  .
*            ls_data_model-create_uname  = ls_master-create_uname .
*            ls_data_model-request_no    = ls_master-request_no.
*
*            ls_data_model-maktx               = ls_master-maktx          .
*            ls_data_model-material_kind       = ls_master-material_kind  .
*            ls_data_model-mtart               = ls_master-mtart          .
*            ls_data_model-matkl               = ls_master-matkl          .
*            ls_data_model-meins               = ls_master-meins          .
*            ls_data_model-extwg               = ls_master-extwg          .
*          ENDIF.
*
*
*          APPEND ls_data_model TO ct_model.
*        ENDLOOP.
*
*        LOOP AT lt_master_rejected INTO ls_master.
*
*          CLEAR ls_data_model.
*
*          READ TABLE lt_mara INTO ls_mara WITH KEY  matnr = ls_master-matnr.
*          CHECK sy-subrc IS INITIAL.
*
*          MOVE-CORRESPONDING ls_master TO ls_data_model.
*
**          SELECT SINGLE material_kind
**            FROM zmm_t_may_kinds
**            INTO ls_data_model-material_kind
**            WHERE mtart EQ ls_mara-mtart.
*
*          CASE ls_app_model-app.
*            WHEN zif_may_constants=>mc_app_change .
*
*              ls_data_model-process_type  = zif_may_constants=>mc_process_change.
*
*            WHEN zif_may_constants=>mc_app_delete .
*
*              ls_data_model-process_type  = zif_may_constants=>mc_process_delete.
*
*            WHEN zif_may_constants=>mc_app_expand..
*
*              ls_data_model-process_type  = zif_may_constants=>mc_process_expand.
*
*          ENDCASE.
*
*          ls_data_model-status        = ls_master-status.
*          ls_data_model-active_step   = ls_master-active_step.
*          ls_data_model-last_date     = ls_master-last_date    .
*          ls_data_model-last_time     = ls_master-last_time    .
*          ls_data_model-last_user     = ls_master-last_user    .
*          ls_data_model-create_date   = ls_master-create_date  .
*          ls_data_model-create_time   = ls_master-create_time  .
*          ls_data_model-create_uname  = ls_master-create_uname .
*          ls_data_model-request_no    = ls_master-request_no.
*
*          ls_data_model-maktx               = ls_master-maktx          .
*          ls_data_model-material_kind       = ls_master-material_kind  .
*          ls_data_model-mtart               = ls_master-mtart          .
*          ls_data_model-matkl               = ls_master-matkl          .
*          ls_data_model-meins               = ls_master-meins          .
*          ls_data_model-extwg               = ls_master-extwg          .
*
*          APPEND ls_data_model TO ct_model.
*        ENDLOOP.
*
*      WHEN  zif_may_constants=>mc_app_release.
*
*
*        lr_process_type = VALUE   #(  sign = 'I' option = 'EQ'
*                                   ( low =  zif_may_constants=>mc_process_creation )
*                                   ( low =  zif_may_constants=>mc_process_change   )
*                                   ( low =  zif_may_constants=>mc_process_delete   )
*                                   ( low =  zif_may_constants=>mc_process_expand   ) ) .
*
*        SELECT *
*          FROM zmm_t_may_master
*          INTO TABLE lt_master
*          WHERE process_type IN lr_process_type AND
*                status       NE zif_may_constants=>mc_status_completed  AND
**                status       NE zif_may_constants=>mc_status_rejected AND
*                delete_indicator EQ space AND
*                active_step NE zif_may_constants=>mc_step_requester.
*
*        LOOP AT lt_master INTO ls_master.
*
*          MOVE-CORRESPONDING ls_master TO ls_data_model.
*          APPEND ls_data_model TO ct_model.
*        ENDLOOP.
*
*    ENDCASE.
*
*
*
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
*    zcl_may_data_provider=>assign_approve_rules( CHANGING ct_model = ct_model ).
*
*
*    LOOP AT ct_model ASSIGNING <ls_model>.
*
*      zcl_may_logic=>determine_states(  CHANGING cs_model = <ls_model> ) .
*    ENDLOOP.







  ENDMETHOD.


  METHOD FILL_UI_CONFIGS.
*    DATA: ls_ui_config TYPE zmm_s_may_ui_config.
*    DATA(ls_app_model) =     zcl_may_model=>get_application_model( ).
*
*    LOOP AT ct_model ASSIGNING FIELD-SYMBOL(<ls_model>).
*
*      CLEAR ls_ui_config .
*
*      CASE  ls_app_model-app.
*        WHEN zif_may_constants=>mc_app_creation.
*
*          IF <ls_model>-active_step EQ zif_may_constants=>mc_step_requester AND
*             <ls_model>-status      EQ zif_may_constants=>mc_status_review  AND
*             <ls_model>-create_uname EQ <ls_model>-person_info-uname . " Onaya gittikten gözden geçirme ile geri gelirken
*
*            ls_ui_config-basis_view_editable      = abap_true.
*
*            ls_ui_config-mip_view_editable        = abap_true.
*
*
*            ls_ui_config-purchase_view_editable   = abap_true.
*
*            ls_ui_config-send_active              = abap_true.
*            ls_ui_config-upload_editable          = abap_true.
*            ls_ui_config-werks_editable           = abap_true.
*            ls_ui_config-lgort_editable           = abap_true.
*
*
*          ELSE. " Onaya gönderildikten sonra.
*            ls_ui_config-basis_view_editable      = abap_false.
*            ls_ui_config-mip_view_editable        = abap_false.
*            ls_ui_config-purchase_view_editable   = abap_false.
*            ls_ui_config-send_active              = abap_false.
*            ls_ui_config-upload_editable          = abap_false.
*
*          ENDIF.
*
*          ls_ui_config-basis_view_active        = abap_true.
*
*
*          ls_ui_config-mip_view_active          = abap_true.
*
*          IF ( zcl_may_logic=>is_general_mavy(  <ls_model>-person_info-uname ) ) .
*            ls_ui_config-purchase_view_active     = abap_true.
*          ENDIF.
*
*        WHEN zif_may_constants=>mc_app_change.
*
*          IF ( <ls_model>-active_step EQ zif_may_constants=>mc_step_requester AND
*               <ls_model>-status      EQ zif_may_constants=>mc_status_review  AND
*               <ls_model>-create_uname EQ  <ls_model>-person_info-uname ) OR " Onaya gittikten gözden geçirme ile geri gelirken
*               <ls_model>-status      EQ space. " Onaya gönderilmeden önce
*
*
*            IF ( zcl_may_logic=>is_general_mavy(  <ls_model>-person_info-uname ) ) .
*
*              ls_ui_config-basis_view_editable      = abap_true.
*              ls_ui_config-mip_view_editable        = abap_true.
*              ls_ui_config-purchase_view_editable   = abap_true.
*              ls_ui_config-upload_editable          = abap_true.
*
*            ELSE.
*
*              ls_ui_config-basis_view_editable      = abap_false.
*              ls_ui_config-mip_view_editable        = abap_false.
*              ls_ui_config-purchase_view_editable   = abap_false.
*              ls_ui_config-upload_editable          = abap_false.
*
*            ENDIF.
*
*            ls_ui_config-send_active              = abap_true.
*
*
*            ls_ui_config-supplier_codes_editable   = abap_true.
*            ls_ui_config-equipments_editable       = abap_true.
*            ls_ui_config-extwg_editable            = abap_true.
*            ls_ui_config-mabst_editable            = abap_true.
*            ls_ui_config-eislo_editable            = abap_true.
*            ls_ui_config-eisbe_editable            = abap_true.
*
*          ELSE.
*            ls_ui_config-basis_view_editable      = abap_false.
*            ls_ui_config-mip_view_editable        = abap_false.
*            ls_ui_config-purchase_view_editable   = abap_false.
*            ls_ui_config-send_active              = abap_false.
*            ls_ui_config-upload_editable          = abap_false.
*
*
*          ENDIF.
*
*          ls_ui_config-basis_view_active        = abap_true.
*          ls_ui_config-mip_view_active          = abap_true.
*          ls_ui_config-purchase_view_active     = abap_true.
*
*        WHEN zif_may_constants=>mc_app_delete.
*
*          ls_ui_config-basis_view_active        = abap_true.
*          ls_ui_config-mip_view_active          = abap_true.
*          ls_ui_config-purchase_view_active     = abap_true.
*
*          ls_ui_config-basis_view_editable      = abap_false.
*          ls_ui_config-mip_view_editable        = abap_false.
*          ls_ui_config-purchase_view_editable   = abap_false.
*
*          IF <ls_model>-status      EQ space.
*            ls_ui_config-send_active = abap_true.
*          ELSE.
*            ls_ui_config-send_active = abap_false.
*          ENDIF.
*
*        WHEN zif_may_constants=>mc_app_expand.
*
*          ls_ui_config-basis_view_active        = abap_true.
*          ls_ui_config-mip_view_active          = abap_true.
*          ls_ui_config-purchase_view_active     = abap_true.
*          ls_ui_config-basis_view_editable      = abap_false.
*          ls_ui_config-mip_view_editable        = abap_false.
*          ls_ui_config-purchase_view_editable   = abap_false.
*
*
*          IF <ls_model>-status      EQ space.
*            ls_ui_config-send_active = abap_true.
*
*
*            ls_ui_config-expand_werks_active                = abap_true.
*            IF <ls_model>-material_kind EQ zif_may_constants=>mc_material_type_stock.
*              ls_ui_config-expand_lgort_active                = abap_true.
*            ENDIF.
*
**            LOOP AT <ls_model>-plants TRANSPORTING NO FIELDS WHERE werks IS NOT INITIAL.
*            ls_ui_config-expand_werks_editable              = abap_true.
**            ENDLOOP.
*
**            LOOP AT <ls_model>-storages TRANSPORTING NO FIELDS WHERE lgort IS NOT INITIAL.
*
*            ls_ui_config-expand_lgort_editable              = abap_true.
*
*
**            ENDLOOP.
*
*
*          ELSE.
*
*            ls_ui_config-send_active                        = abap_false.
*            ls_ui_config-expand_werks_active                = abap_true.
*            ls_ui_config-expand_lgort_active                = abap_true.
*          ENDIF.
*
*
*        WHEN zif_may_constants=>mc_app_release.
*
*          ls_ui_config-basis_view_active        = abap_true.
*          ls_ui_config-mip_view_active          = abap_true.
*          ls_ui_config-purchase_view_active     = abap_true.
*          ls_ui_config-basis_view_editable      = abap_false.
*          ls_ui_config-mip_view_editable        = abap_false.
*
*
*          IF <ls_model>-active_step  EQ zif_may_constants=>mc_step_mavy AND
*             <ls_model>-process_type EQ zif_may_constants=>mc_process_creation AND
*             <ls_model>-person_info-is_releaser EQ abap_true.
*
*            ls_ui_config-purchase_view_editable   = abap_true.
*            ls_ui_config-lgort_editable           = abap_true.
*          ELSE.
*            ls_ui_config-purchase_view_editable   = abap_false.
*            ls_ui_config-lgort_editable           = abap_false.
*          ENDIF.
*
*
*          CASE <ls_model>-process_type.
*            WHEN zif_may_constants=>mc_process_creation.
*
*              ls_ui_config-approve_active = abap_true.
*              ls_ui_config-reject_active  = abap_true.
*              ls_ui_config-review_active  = abap_true.
*
*            WHEN zif_may_constants=>mc_process_change .
*
*              ls_ui_config-approve_active = abap_true.
*              ls_ui_config-reject_active  = abap_true.
*              ls_ui_config-review_active  = abap_true.
*
*              ls_ui_config-old_values = abap_true.
*
*            WHEN zif_may_constants=>mc_process_delete .
*
*              ls_ui_config-approve_active = abap_true.
*              ls_ui_config-reject_active  = abap_true.
*
*            WHEN zif_may_constants=>mc_process_expand .
*
*              ls_ui_config-approve_active = abap_true.
*              ls_ui_config-reject_active  = abap_true.
*
*              ls_ui_config-expand_werks_active                = abap_true.
*              ls_ui_config-expand_lgort_active                = abap_true.
*
*          ENDCASE.
*
*          IF <ls_model>-person_info-is_releaser EQ abap_false..
*            ls_ui_config-approve_active = abap_false.
*            ls_ui_config-reject_active  = abap_false.
*            ls_ui_config-review_active  = abap_false.
*          ENDIF.
*
*
*
*        WHEN OTHERS.
*      ENDCASE.
*
*      ls_ui_config-approvers_active          = abap_true.
*      ls_ui_config-comments_active           = abap_true.
*
*      <ls_model>-ui_config = ls_ui_config.
*
**      zcl_may_logic=>find_required_fields( CHANGING is_model = <ls_model> ) .
*
*    ENDLOOP.


  ENDMETHOD.
ENDCLASS.
