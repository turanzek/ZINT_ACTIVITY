class ZCL_INT_ACTIVITY_SYSTEM_HELPER definition
  public
  final
  create public .

public section.

  class-methods GET_NEXT_REQUEST_NO
    importing
      !IV_PROCESS_TYPE type ZINT_DE_ACT_PROCESS_TYPE
    returning
      value(EV_REQUEST_NO) type ZINT_DE_ACT_REQUEST_NO .
  class-methods GET_SESSION_PERSON
    returning
      value(RS_PERSON) type ZINT_S_ACT_PERSON_INFO .
  class-methods SEND_EMAIL
    importing
      !IS_MODEL type ZINT_S_ACT_PROCESS_MODEL .
protected section.
private section.
ENDCLASS.



CLASS ZCL_INT_ACTIVITY_SYSTEM_HELPER IMPLEMENTATION.


  METHOD GET_NEXT_REQUEST_NO.

    DATA: lv_number TYPE CHAR10.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = iv_process_type
        object                  = 'ZMM_MAY_RE'
      IMPORTING
        number                  = lv_number
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
    ENDIF.

    ev_request_no =  lv_number.

  ENDMETHOD.


  METHOD GET_SESSION_PERSON.

    DATA(ls_pa0001) = zcl_int_act_hr_helper=>get_person_from_uname( iv_uname = sy-uname ).

    rs_person-pernr = ls_pa0001-pernr.
    rs_person-uname = sy-uname.
    rs_person-bukrs = ls_pa0001-bukrs.
    rs_person-orgeh = ls_pa0001-orgeh.
    rs_person-ename = ls_pa0001-ename.

*
*
*
*

  ENDMETHOD.


  METHOD SEND_EMAIL.
*
*    DATA: lt_return TYPE TABLE OF bapiret2,
*          lv_subrc  TYPE sy-subrc.
*
*
*    TYPES : BEGIN OF ty_user,
*              user TYPE sy-uname,
*            END OF ty_user.
*
*    TYPES : tt_user TYPE TABLE OF ty_user .
*
*    DATA: lt_receivers_user TYPE tt_user.
*    DATA: lv_subject         TYPE  string,
*          lv_body            TYPE  string,
*          lv_header_text     TYPE  string,
*          lv_sub_header_text TYPE  string,
*          lv_button_url      TYPE  string,
*          lv_button_text     TYPE  string,
*          ls_receiver        TYPE  zgnls_mail_receivers,
*          lt_receivers       TYPE  zgnltt_mail_receivers.
*
*    DATA: lv_core_text1 TYPE string.
*    DATA: lv_core_text2 TYPE string.
*    DATA: lv_core_text3 TYPE string.
*    DATA: lv_manage_release TYPE string.
*    DATA: lv_home       TYPE string.
*    DATA: lv_request    TYPE string.
*    DATA: lv_matur TYPE  zgnl_de_mail_tur.
*
*
*    CASE sy-sysid .
*      WHEN 'G4D'.
*        lv_manage_release = 'https://fioridev.gubretasmaden.com/sap/bc/ui2/flp#ZMM_MAY_MALZ_YONETIM_SEM-manageRelease'.
*        lv_home = 'https://fioridev.gubretasmaden.com/sap/bc/ui2/flp'.
*        lv_request = 'https://fiori.gubretasmaden.com/sap/bc/ui2/flp#ZMM_MAY_MALZ_YONETIM_SEM-requestTiles'.
*      WHEN 'G4Q'.
*        lv_manage_release = 'https://fioriqa.gubretasmaden.com/sap/bc/ui2/flp#ZMM_MAY_MALZ_YONETIM_SEM-manageRelease'.
*        lv_home = 'https://fioriqa.gubretasmaden.com/sap/bc/ui2/flp'.
*        lv_request = 'https://fiori.gubretasmaden.com/sap/bc/ui2/flp#ZMM_MAY_MALZ_YONETIM_SEM-requestTiles'.
*      WHEN 'G4P'.
*        lv_manage_release = 'https://fiori.gubretasmaden.com/sap/bc/ui2/flp#ZMM_MAY_MALZ_YONETIM_SEM-manageRelease'.
*        lv_home = 'https://fiori.gubretasmaden.com/sap/bc/ui2/flp'.
*        lv_request = 'https://fiori.gubretasmaden.com/sap/bc/ui2/flp#ZMM_MAY_MALZ_YONETIM_SEM-requestTiles'.
*      WHEN OTHERS.
*    ENDCASE.
*
*
*    LOOP AT is_model-approve_steps INTO DATA(ls_step).
*
*      " Kullanıcı, yarat/değiştir/genişlet/silme işareti taleplerini kaydettiği an MAV yöneticisine bilgi maili düşecek.
*      IF ls_step-step_code = zif_may_constants=>mc_step_mavy AND is_model-action_type EQ zif_may_constants=>mc_action_send.
*        DATA(ls_step_mavy) = ls_step.
*
*        IF ls_step-approver NE sy-uname.
*          APPEND VALUE #( user = ls_step-approver ) TO lt_receivers_user.
*        ENDIF.
*      ENDIF.
*
*      " Sırası gelen onaylayıcıya geldiğinde kişiye bilgilendirme maili gidecek.
*      IF is_model-active_step = ls_step-step_code.
*        DATA(ls_active_step) = ls_step.
*        APPEND VALUE #( user = ls_step-approver ) TO lt_receivers_user.
*      ENDIF.
*
**       Herhangi bir onay sırasında reddedilen formun reddedildi bilgilendirme maili daha önce onay veren kişilere gidecek.
**      IF is_model-active_step = zif_may_constants=>mc_step_rejected.
**
**        READ TABLE is_model-actions TRANSPORTING NO FIELDS WITH KEY active_step = ls_step-step_code .
**        IF sy-subrc IS INITIAL.
**          APPEND VALUE #( user = ls_step-approver ) TO lt_receivers_user.
**        ENDIF.
**
**      ENDIF.
*
*    ENDLOOP.
*
*    " Talep edene geri geldiğinde , talep eden kişiye bilgilendirme maili gidecek.
*    IF is_model-active_step = zif_may_constants=>mc_step_requester.
*      APPEND VALUE #( user = is_model-create_uname ) TO lt_receivers_user.
*    ENDIF.
*
*    " Talep reddedildiğinde, talep eden kişiye bilgilendirme maili gidecek.
*    IF is_model-active_step = zif_may_constants=>mc_step_rejected.
*      APPEND VALUE #( user = is_model-create_uname ) TO lt_receivers_user.
*    ENDIF.
*
*    " Onaylar tamamlandıktan sonra talebi açan kullanıcıya ve MAV yöneticisine bilgilendirme maili gidecek.
*    IF is_model-active_step = zif_may_constants=>mc_step_completed.
*      APPEND VALUE #( user = is_model-create_uname ) TO lt_receivers_user.
*      APPEND VALUE #( user = ls_step_mavy-approver ) TO lt_receivers_user.
*    ENDIF.
*
*
*    SORT lt_receivers_user.
*    DELETE ADJACENT DUPLICATES FROM lt_receivers_user.
*
*
*
*
*
*    CASE  is_model-process_type.
*      WHEN zif_may_constants=>mc_process_creation.
*        lv_header_text = 'Malzeme Anaveri Yaratma Talebi'.
*      WHEN zif_may_constants=>mc_process_change.
*        lv_header_text = 'Malzeme Anaveri Değişiklik Talebi'.
*      WHEN zif_may_constants=>mc_process_delete.
*        lv_header_text = 'Malzeme Anaveri Silme İşareti Talebi'.
*      WHEN zif_may_constants=>mc_process_expand.
*        lv_header_text = 'Malzeme Anaveri Genişletme Talebi'.
*      WHEN OTHERS.
*    ENDCASE.
*
*
*
*    CASE  is_model-action_type.
*      WHEN zif_may_constants=>mc_action_send.
*
*        lv_core_text1  = |{ is_model-request_no } numaralı { lv_header_text } onayınızı beklemektedir.|.
*
*
*        lv_sub_header_text = 'Onay bekliyor'.
*        lv_matur  = '01'.
*        lv_button_text = 'Belge onayı için tıklayınız'.
*        lv_button_url  = lv_manage_release.
*
*      WHEN zif_may_constants=>mc_action_approve.
*
*        CASE is_model-status.
*          WHEN zif_may_constants=>mc_status_completed.
*
*            CASE is_model-process_type.
*              WHEN zif_may_constants=>mc_process_creation.
*
*                lv_core_text1  = |{ is_model-request_no } numaralı { lv_header_text } belgesi onaylanmıştır.|.
*                lv_core_text2  = |Malzeme anaverisi otomatik olarak oluşturulmuştur.|.
*                lv_core_text3  = |Malzeme kodu { is_model-matnr } - { is_model-maktx } | .
*
*              WHEN zif_may_constants=>mc_process_delete.
*
*                lv_core_text1  = |{ is_model-request_no } numaralı { lv_header_text } belgesi onaylanmıştır.|.
*                lv_core_text2  = |Silme işareti eklenmiştir.|.
*                lv_core_text3  = |Malzeme kodu { is_model-matnr } - { is_model-maktx } | .
*              WHEN OTHERS.
*                lv_core_text1  = |{ is_model-request_no } numaralı { lv_header_text } belgesi onaylanmıştır.|.
*                lv_core_text2  = |Değişiklikler otomatik olarak oluşturulmuştur.|.
*                lv_core_text3  = |Malzeme kodu { is_model-matnr } - { is_model-maktx } | .
*            ENDCASE.
*
*            lv_sub_header_text = 'Onay tamamlandı bildirimi'.
*            lv_button_text = 'Fiori Anasayfa'.
*            lv_button_url  = lv_home.
*          WHEN OTHERS .
*            lv_core_text1  = |{ is_model-request_no } numaralı { lv_header_text } onayınızı beklemektedir.|.
*            lv_sub_header_text = 'Onay bekliyor'.
*            lv_button_text = 'Belge onayı için tıklayınız'.
*            lv_button_url  = lv_manage_release.
*        ENDCASE.
*
*        lv_matur  = '01'.
*
*      WHEN zif_may_constants=>mc_action_review.
*
*        lv_core_text1  = |{ is_model-request_no } numaralı { lv_header_text } belgesi  { is_model-person_info-ename } tarafından gözden geçirilecek olarak değerlendirilmiştir.|.
*        lv_sub_header_text = 'Gözden Geçirilecek'.
*
*        lv_matur  = '01'.
*
*        lv_button_text = 'Malzeme Anaveri Talep Süreci'.
*        lv_button_url  = lv_request.
*
*      WHEN zif_may_constants=>mc_action_reject.
*
*        lv_core_text1  = |{ is_model-request_no } numaralı { lv_header_text } belgesi  { is_model-person_info-ename } tarafından reddedilmiştir.|.
*        lv_core_text2  = |Red Nedeni: { is_model-note } |.
*        lv_sub_header_text = 'Reddedildi'.
*        lv_matur  = '03'.
*
*        lv_button_text = 'Malzeme Anaveri Talep Süreci'.
*        lv_button_url  = lv_request.
*    ENDCASE.
*
*    lv_subject = lv_header_text.
**    lv_sub_header_text = lv_header_text.
*
*    LOOP AT lt_receivers_user INTO DATA(ls_user).
*      CLEAR lt_receivers.
*      ls_receiver-rtype = 'TO'.
*      ls_receiver-email = zcl_abap_utils=>get_user_email( ls_user-user )  .
*      APPEND ls_receiver TO lt_receivers.
*
*      DATA(lv_name) = zcl_abap_utils=>get_user_name( ls_user-user ) .
*
*      lv_body       =  |Sayın { lv_name } <br><br> { lv_core_text1 } <br> { lv_core_text2 }  <br> { lv_core_text3 }|.
*
*
*      CALL FUNCTION 'Z_GNL_SEND_MAIL'
*        EXPORTING
*          iv_matur           = lv_matur
*          iv_send_adr_name   = 'Sap Bilgilendirme Sistemi'
*          iv_send_adr_mail   = 'sapbildirim@gubretasmaden.com'
*          iv_subject         = lv_subject            " Mail konusu
*          iv_body            = lv_body               " Mail içeriği
*          iv_header_text     = lv_header_text        " Başlık tanımı
*          iv_button_text     = lv_button_text
*          iv_button_url      = lv_button_url
*          iv_sub_header_text = lv_sub_header_text    " Alt başlık tanımı
*          it_receivers       = lt_receivers          " Mail alıcıları
*        IMPORTING
*          ev_subrc           = lv_subrc
*          et_return          = lt_return.
*    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
