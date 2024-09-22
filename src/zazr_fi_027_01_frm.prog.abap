*&---------------------------------------------------------------------*
*& Include          ZAZR_FI_027_01_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .
  DATA : lt_cdhdr TYPE TABLE OF cdhdr,
         ls_cdhdr TYPE cdhdr.
  DATA : lt_cdpos TYPE TABLE OF cdpos,
         ls_cdpos TYPE cdpos.
  DATA : lt_dd03t TYPE TABLE OF dd03t.
  DATA : ls_dd03t TYPE  dd03t.
  DATA lv_adrnr TYPE lfa1-adrnr.
  DATA lv_bankl TYPE tiban-bankl.
  DATA lv_bankn TYPE tiban-bankn.
  DATA lv_tabkey TYPE tiban-tabkey.
  DATA lt_dd03m TYPE TABLE OF ddftx.
  DATA ls_dd03m TYPE ddftx.
  DATA : lt_dd07v TYPE TABLE OF dd07v,
         ls_dd07v TYPE dd07v.
  DATA : ls_lfa1 TYPE lfa1.

  DATA : lv_kunnr TYPE kna1-kunnr.
  DATA lv_uzeit TYPE sy-uzeit.
  CONCATENATE '00' p_date '00' INTO lv_uzeit.

  IF p_date IS NOT INITIAL.
    gv_uzeit = sy-uzeit - lv_uzeit.

    SELECT * FROM cdhdr
      INTO TABLE lt_cdhdr
      WHERE udate    IN s_udate
        AND objectid IN s_object
        AND utime    BETWEEN gv_uzeit AND sy-uzeit
       AND ( tcode  EQ 'FK01' OR  tcode  EQ 'FK02' OR  tcode  EQ 'XK03'
           OR tcode  EQ 'XK01' OR tcode   EQ 'XK02'
         OR tcode  EQ 'MK01' OR tcode   EQ 'MK02' OR tcode  EQ 'MK03'
         OR tcode EQ 'BP'). "added by snyilmaz 170924

  ELSE.
    SELECT * FROM cdhdr
   INTO TABLE lt_cdhdr
   WHERE udate    IN s_udate
     AND objectid IN s_object
      "   AND utime    BETWEEN gv_uzeit AND sy-uzeit
     AND ( tcode  EQ 'FK01' OR  tcode  EQ 'FK02' OR  tcode  EQ 'XK03'
        OR tcode  EQ 'XK01' OR tcode   EQ 'XK02'
        OR tcode  EQ 'MK01' OR tcode   EQ 'MK02' OR tcode  EQ 'MK03'
        OR tcode EQ 'BP'). "added by snyilmaz 170924

  ENDIF.

  IF lt_cdhdr[] IS NOT INITIAL.

    SELECT * FROM cdpos
      INTO TABLE lt_cdpos
      FOR ALL ENTRIES IN lt_cdhdr
      WHERE objectid EQ lt_cdhdr-objectid
        AND changenr EQ lt_cdhdr-changenr.

  ENDIF.

  IF lt_cdpos[] IS NOT INITIAL.
    SELECT fieldname scrtext_s FROM ddftx
      INTO CORRESPONDING FIELDS OF TABLE lt_dd03m
    FOR ALL ENTRIES IN lt_cdpos
    WHERE fieldname EQ lt_cdpos-fname
      AND ddlanguage EQ sy-langu
      AND ( tabname EQ 'ADRC' OR tabname EQ 'LFA1' OR
            tabname EQ 'LFB1' OR tabname EQ 'TIBAN' OR
            tabname EQ 'LFM1' OR tabname EQ 'KNA1' OR
            tabname EQ 'LFBK'
            OR tabname EQ 'BUT000' ) "added by snyilmaz 170924
      AND scrtext_s  NE ' '.

  ENDIF.

  SELECT * FROM dd07v
    INTO TABLE lt_dd07v
    WHERE domname EQ 'CDCHNGIND'
      AND ddlanguage EQ sy-langu.

  LOOP AT lt_cdpos INTO ls_cdpos.
    READ TABLE lt_cdhdr INTO ls_cdhdr
                            WITH KEY objectid  = ls_cdpos-objectid
                                     changenr  = ls_cdpos-changenr.
    IF sy-subrc EQ 0.
      gs_data-username = ls_cdhdr-username.
      gs_data-udate = ls_cdhdr-udate.
      gs_data-utime = ls_cdhdr-utime.
    ENDIF.
    MOVE-CORRESPONDING ls_cdpos TO gs_data.
    IF ls_cdpos-tabkey+13(4) IS NOT INITIAL AND
       ls_cdpos-tabname EQ 'LFB1'.
      gs_data-bukrs = ls_cdpos-tabkey+13(4).
    ENDIF.
    IF ls_cdpos-tabkey+13(4) IS NOT INITIAL AND
     ls_cdpos-tabname EQ 'LFM1'.
      gs_data-vkorg = ls_cdpos-tabkey+13(4).
    ENDIF.
    READ TABLE lt_dd07v INTO ls_dd07v WITH KEY domvalue_l
                                              = ls_cdpos-chngind.
    IF sy-subrc EQ 0.
      gs_data-cdchngind = ls_dd07v-ddtext.
    ENDIF.


    READ TABLE lt_dd03m INTO ls_dd03m
         WITH KEY fieldname = ls_cdpos-fname.
    IF sy-subrc EQ 0.
      gs_data-fname = ls_dd03m-scrtext_s.
    ENDIF.
    IF gs_data-fname EQ 'KEY'.
      gs_data-fname = 'Oluşturuldu'.
    ENDIF.
    IF gs_data-tabname(1) EQ 'L'.
      gs_data-lifnr = gs_data-objectid.
    ENDIF.
    IF gs_data-tabname(3) EQ 'ADR'.
      lv_adrnr = gs_data-objectid+4(10).
      SELECT SINGLE lifnr  FROM lfa1
        INTO gs_data-lifnr
        WHERE adrnr EQ lv_adrnr.
    ENDIF.

    IF gs_data-tabname EQ 'TIBAN'.

      lv_bankl = gs_data-objectid+6(10).
      lv_bankn = gs_data-objectid+20(35).
      CONDENSE lv_bankn.
      SELECT SINGLE tabkey  FROM tiban
        INTO lv_tabkey
        WHERE bankl EQ lv_bankl
          AND bankn EQ lv_bankn.

      gs_data-lifnr = lv_tabkey.
    ENDIF.

    IF gs_data-tabname EQ 'KNA1'.
      lv_kunnr = gs_data-objectid.
      CONDENSE lv_kunnr.
      SELECT SINGLE lifnr  FROM kna1
        INTO gs_data-lifnr
        WHERE kunnr EQ lv_kunnr.

    ENDIF.
    IF gs_data-lifnr IS NOT INITIAL.
      SELECT SINGLE *
        FROM lfa1
        INTO ls_lfa1
        WHERE lifnr = gs_data-lifnr.


     CONCATENATE ls_lfa1-name1 ls_lfa1-name2 ls_lfa1-name3 ls_lfa1-name4
     INTO gs_data-name1
     SEPARATED BY space.
*     gs_gata-name1 = ls_lfa1-name1.

    ENDIF.
    IF gs_data-username IS NOT INITIAL .
      SELECT SINGLE name_text  FROM zazr_fi_027_v_01
        INTO gs_data-name_text
        WHERE kullanici EQ gs_data-username.
    ENDIF.

    IF ls_cdpos-tabname EQ 'LFBK'  AND gs_data-lifnr IS NOT INITIAL.

      SELECT SINGLE b~iban
        INTO gs_data-value_new
        FROM lfbk AS a
        INNER JOIN tiban AS b ON b~banks = a~banks
                             AND b~bankl = a~bankl
                             AND b~bankn = a~bankn
         WHERE a~lifnr EQ gs_data-lifnr.

    ENDIF.

    APPEND gs_data TO gt_data.
    CLEAR gs_data.
  ENDLOOP.
  SORT gt_data BY bukrs lifnr chngind value_new value_old.
  DELETE ADJACENT DUPLICATES FROM gt_data COMPARING
  bukrs lifnr  chngind value_new value_old..
  SORT gt_data BY utime DESCENDING.
  gt_data2 = gt_data.
  gt_data3 = gt_data.
  gt_data4 = gt_data.

  DELETE gt_data  WHERE  tabname EQ 'LFB1'.
  DELETE gt_data  WHERE  tabname EQ 'LFM1'.
  DELETE gt_data2 WHERE  tabname NE 'LFB1'.
  DELETE gt_data4 WHERE  tabname NE 'LFM1'.

  IF s_bukrs[] IS NOT INITIAL.
    DELETE gt_data2 WHERE bukrs NOT IN s_bukrs.
    DELETE gt_data3 WHERE bukrs NOT IN s_bukrs.
  ENDIF.

  SORT gt_data3 BY utime DESCENDING.

ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  SHOW_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_data .
  CLEAR: gt_fieldcat, gt_fieldcat[].


  IF go_custom_container IS INITIAL.
    CREATE OBJECT go_custom_container
      EXPORTING
        container_name = go_container.

    CREATE OBJECT grid
      EXPORTING
        i_parent = go_custom_container.

    PERFORM get_fieldcatalog.
    PERFORM toolbar_exclude TABLES gt_toolbar_excluding.


*-Layout
    CLEAR gs_layo100.
    gs_layo100-zebra      = 'X'.
    gs_layo100-cwidth_opt = 'X'.
    gs_layo100-edit_mode  = 'X'.
    gs_variant-report     = sy-repid .
    gs_layo100-sel_mode = 'A'.


    CALL METHOD grid->set_table_for_first_display
      EXPORTING
        is_layout            = gs_layo100
        it_toolbar_excluding = gt_toolbar_excluding
        is_variant           = gs_variant
        i_save               = 'A'
      CHANGING
        it_outtab            = gt_data3[]
        it_fieldcatalog      = gt_fieldcat[].

*    CREATE OBJECT event_receiver.
*    SET HANDLER event_receiver->on_hotspot_click    FOR grid.

  ELSE .
    CALL METHOD grid->refresh_table_display.
  ENDIF .


ENDFORM.                    " SHOW_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_fieldcatalog .

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZAZR_FI_027_S_01'
      i_client_never_display = 'X'
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = gt_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  LOOP AT gt_fieldcat INTO gs_fieldcat.
    CASE gs_fieldcat-fieldname.
      WHEN 'OBJECTID' OR 'CHANGENR' OR 'TABNAME' OR 'USERNAME'
           OR 'CHNGIND'.
        gs_fieldcat-no_out = 'X'.
      WHEN 'CDCHNGIND'.
        gs_fieldcat-reptext = 'Değişiklik Türü'.
    ENDCASE.
    MODIFY gt_fieldcat FROM gs_fieldcat TRANSPORTING reptext no_out
  hotspot.
    CLEAR gs_fieldcat.
  ENDLOOP.


ENDFORM.                    " GET_FIELDCATALOG
*&---------------------------------------------------------------------*
*&      Form  TOOLBAR_EXCLUDE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_TOOLBAR_EXCLUDING  text
*----------------------------------------------------------------------*
FORM toolbar_exclude   TABLES pt_toolbar.
  DATA ls_exclude TYPE ui_func.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO pt_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO pt_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO pt_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO pt_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO pt_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut .
  APPEND ls_exclude TO pt_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO pt_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO pt_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row .
  APPEND ls_exclude TO pt_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo .
  APPEND ls_exclude TO pt_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_help.
  APPEND ls_exclude TO pt_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_exclude TO pt_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_detail .
  APPEND ls_exclude TO pt_toolbar.
  ls_exclude = cl_gui_alv_grid=>mc_fc_check .
  APPEND ls_exclude TO pt_toolbar.
ENDFORM.                    " TOOLBAR_EXCLUDE
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_mail TABLES gt_data USING text..


  CONSTANTS:
  gc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab,
  gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf.

  DATA send_request   TYPE REF TO cl_bcs.
  DATA document       TYPE REF TO cl_document_bcs.
  DATA recipient      TYPE REF TO if_recipient_bcs.
  DATA bcs_exception  TYPE REF TO cx_bcs.

  DATA main_text      TYPE bcsy_text.
  DATA binary_content TYPE solix_tab.
  DATA size           TYPE so_obj_len.
  DATA sent_to_all    TYPE os_boolean.

  DATA lv_string TYPE string.
  DATA ls_t100 TYPE t100.

  DATA : lt_mail TYPE TABLE OF zazr_fi_027_t_01,
         ls_mail TYPE zazr_fi_027_t_01.
*
  DATA:lv_dat(10) TYPE c.


  PERFORM build_body_of_mail USING:
*  'Sayın İlgili,','Değişiklik kayıtları ektedir.', 'iyi çalışmalar!'.
  'Hörmətli həmkar,','Dəyişiklik qeydləri əlavə olunur.', 'Məlumatınız üçün!'.

  DATA:
    l_obj(11),
    l_type(5),
    l_date(15).
  DATA: time(8) TYPE c.
  DATA : lv_eski TYPE string.
  DATA : lv_yeni TYPE string.

  SELECT * FROM zazr_fi_027_t_01
    INTO TABLE lt_mail
    WHERE statu EQ '1'.

  LOOP AT lt_mail INTO ls_mail.

    CLEAR : lv_string.


    CONCATENATE 'Satici' gc_tab
                'Satici Adi' gc_tab
                'Alan adı' gc_tab
                'Degisiklik gös.' gc_tab
                'Kullanici' gc_tab
                'Tarih ' gc_tab
                'Saat' gc_tab
                'Yeni Deger' gc_tab
                'Eski Deger'   gc_crlf
                  INTO lv_string.

    LOOP AT gt_data INTO gs_data.
      CLEAR lv_dat.
      CLEAR : lv_eski,lv_yeni.
      CONCATENATE gs_data-udate+6(2) '.'
                  gs_data-udate+4(2) '.'
                  gs_data-udate+0(4)
                  INTO lv_dat.

      CLEAR time.
      CONCATENATE gs_data-utime+0(2) ':'
                  gs_data-utime+2(2) ':'
                  gs_data-utime+4(2)
                   INTO time.

      lv_eski = gs_data-value_old.
      lv_yeni = gs_data-value_new.

      CONCATENATE '="' gs_data-value_old '"' INTO lv_eski.
      CONCATENATE '="' gs_data-value_new '"' INTO lv_yeni.

      CONCATENATE lv_string
                  gs_data-lifnr gc_tab
                  gs_data-name1 gc_tab
                  gs_data-fname gc_tab
                  gs_data-cdchngind gc_tab
                  gs_data-name_text gc_tab
                  lv_dat gc_tab
                  time gc_tab
                  lv_yeni gc_tab
                  lv_eski gc_crlf
      INTO lv_string.


    ENDLOOP.
    REFRESH binary_content.
    TRY.
        cl_bcs_convert=>string_to_solix(
          EXPORTING
            iv_string   = lv_string
            iv_codepage = '4103'  "suitable for MS Excel, leave empty
            iv_add_bom  = 'X'     "for other doc types
          IMPORTING
            et_solix  = binary_content
            ev_size   = size ).
      CATCH cx_bcs.
        MESSAGE e445(so).
    ENDTRY.
    TRY.
        REFRESH main_text.
*     -------- create persistent send request ------------------------
        send_request = cl_bcs=>create_persistent( ).

*     -------- create and set document with attachment ---------------
*     create document object from internal table with text
*        APPEND 'Sayın İlgili,' TO main_text.                "#EC NOTEXT
        APPEND 'Hörmətli həmkar,' TO main_text.                "#EC NOTEXT
*        APPEND 'Değişiklik kayıtları ektedir.' TO main_text.
        APPEND 'Dəyişiklik qeydləri əlavə olunur.' TO main_text.
                                                            "#EC NOTEXT
*        APPEND 'iyi çalışmalar.' TO main_text.
        APPEND 'Məlumatınız üçün.' TO main_text.
                                                            "#EC notext
        document = cl_document_bcs=>create_document(
          i_type    = 'RAW'
          i_text    = main_text
*         i_subject = 'Satıcı Oluşturma ve Değişiklik Bildirimi' ).
         i_subject = 'Satıcı Yaradılması və Dəyişiklik Bildirişi' ).
                                                            "#EC NOTEXT

*     add the spread sheet as attachment to document object
        document->add_attachment(
         i_attachment_type    = 'xls'                       "#EC NOTEXT
          i_attachment_subject =
*          'Satıcı Oluşturma ve Değişiklik Bildirimi'        "#EC NOTEXT
          'Satıcı Yaradılması və Dəyişiklik Bildirişi'        "#EC NOTEXT
          i_attachment_size    = size
          i_att_content_hex    = binary_content ).

*     add document object to send request
        send_request->set_document( document ).

*     --------- add recipient (e-mail address) -----------------------
*     create recipient object
        recipient =
          cl_cam_address_bcs=>create_internet_address( ls_mail-mail ).

*     add recipient object to send request
        send_request->add_recipient( recipient ).

*     ---------- send document ---------------------------------------
        sent_to_all = send_request->send( i_with_error_screen = 'X' ).

        COMMIT WORK.

        IF sent_to_all IS INITIAL.
          MESSAGE i500(sbcoms) WITH ls_mail-mail.
        ELSE.
          MESSAGE s022(so).
        ENDIF.

*   ------------ exception handling ----------------------------------
*   replace this rudimentary exception handling with your own one !!!
      CATCH cx_bcs INTO bcs_exception.
        MESSAGE i865(so) WITH bcs_exception->error_type.
    ENDTRY.
  ENDLOOP.
ENDFORM.                    "send_mail

*&---------------------------------------------------------------------*
*&      Form  build_body_of_mail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->L_MESSAGE  text
*----------------------------------------------------------------------*
FORM build_body_of_mail USING l_message.
  w_body_msg = l_message.
  APPEND w_body_msg TO i_body_msj.
  CLEAR w_body_msg.

ENDFORM.                    "build_body_of_mail
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_DATA2  text
*      -->P_0023   text
*----------------------------------------------------------------------*
FORM send_mail_2 USING text..


  CONSTANTS:
  gc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab,
  gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf.

  DATA send_request   TYPE REF TO cl_bcs.
  DATA document       TYPE REF TO cl_document_bcs.
  DATA recipient      TYPE REF TO if_recipient_bcs.
  DATA bcs_exception  TYPE REF TO cx_bcs.

  DATA main_text      TYPE bcsy_text.
  DATA binary_content TYPE solix_tab.
  DATA size           TYPE so_obj_len.
  DATA sent_to_all    TYPE os_boolean.

  DATA lv_string TYPE string.
  DATA ls_t100 TYPE t100.

  DATA : lt_mail TYPE TABLE OF zazr_fi_027_t_01,
         ls_mail TYPE zazr_fi_027_t_01.
*
  DATA:lv_dat(10) TYPE c.
  DATA : lv_eski TYPE string.
  DATA : lv_yeni TYPE string.

  PERFORM build_body_of_mail USING:
*  'Sayın İlgili,','Değişiklik kayıtları ektedir.', 'iyi çalışmalar!'.
  'Hörmətli həmkar,','Dəyişiklik qeydləri əlavə olunur.', 'Məlumatınız üçün!'.

  DATA:
    l_obj(11),
    l_type(5),
    l_date(15).
  DATA: time(8) TYPE c.

  SELECT * FROM zazr_fi_027_t_01
    INTO TABLE lt_mail
    WHERE statu EQ '2'
      AND bukrs IN s_bukrs.

  DATA lv_mail TYPE char1.

  LOOP AT lt_mail INTO ls_mail.

    CLEAR : lv_string,lv_mail.


    CONCATENATE 'Satici' gc_tab
                'Satici Adi' gc_tab
                'Alan adı' gc_tab
                'Degisiklik gös.' gc_tab
                'Kullanici' gc_tab
                'Tarih ' gc_tab
                'Saat' gc_tab
                'Yeni Deger' gc_tab
                'Eski Deger'   gc_crlf
                  INTO lv_string.


    LOOP AT gt_data2 INTO gs_data WHERE bukrs = ls_mail-bukrs.
      CLEAR lv_dat.
      CLEAR : lv_eski,lv_yeni.
      CONCATENATE gs_data-udate+6(2) '.'
                  gs_data-udate+4(2) '.'
                  gs_data-udate+0(4)
                  INTO lv_dat.

      CLEAR time.
      CONCATENATE gs_data-utime+0(2) ':'
                  gs_data-utime+2(2) ':'
                  gs_data-utime+4(2)
                   INTO time.

      lv_eski = gs_data-value_old.
      lv_yeni = gs_data-value_new.

      CONCATENATE '="' gs_data-value_old '"' INTO lv_eski.
      CONCATENATE '="' gs_data-value_new '"' INTO lv_yeni.

      CONCATENATE lv_string
                  gs_data-lifnr gc_tab
                  gs_data-name1 gc_tab
                  gs_data-fname gc_tab
                  gs_data-cdchngind gc_tab
                  gs_data-name_text gc_tab
                  lv_dat gc_tab
                  time gc_tab
                  lv_yeni gc_tab
                  lv_eski gc_crlf
      INTO lv_string.

      lv_mail = 'X'.
    ENDLOOP.
    REFRESH binary_content.
    IF lv_mail IS NOT INITIAL.
      TRY.
          cl_bcs_convert=>string_to_solix(
            EXPORTING
              iv_string   = lv_string
              iv_codepage = '4103'  "suitable for MS Excel, leave empty
              iv_add_bom  = 'X'     "for other doc types
            IMPORTING
              et_solix  = binary_content
              ev_size   = size ).
        CATCH cx_bcs.
          MESSAGE e445(so).
      ENDTRY.
      TRY.
          REFRESH main_text.
*     -------- create persistent send request ------------------------
          send_request = cl_bcs=>create_persistent( ).

*     -------- create and set document with attachment ---------------
*     create document object from internal table with text
          APPEND 'Hörmətli həmkar,' TO main_text.              "#EC NOTEXT
          APPEND 'Dəyişiklik qeydləri əlavə olunur.' TO main_text.
                                                            "#EC NOTEXT
          APPEND 'Məlumatınız üçün.' TO main_text.
                                                            "#EC notext
          document = cl_document_bcs=>create_document(
            i_type    = 'RAW'
            i_text    = main_text
           i_subject = 'Satıcı Yaradılması və Dəyişiklik Bildirişi' ).
                                                            "#EC NOTEXT

*     add the spread sheet as attachment to document object
          document->add_attachment(
          i_attachment_type    = 'xls'                      "#EC NOTEXT
            i_attachment_subject =
           'Satıcı Yaradılması və Dəyişiklik Bildirişi'       "#EC NOTEXT
            i_attachment_size    = size
            i_att_content_hex    = binary_content ).

*     add document object to send request
          send_request->set_document( document ).

*     --------- add recipient (e-mail address) -----------------------
*     create recipient object
          recipient =
            cl_cam_address_bcs=>create_internet_address( ls_mail-mail ).

*     add recipient object to send request
          send_request->add_recipient( recipient ).

*     ---------- send document ---------------------------------------
          sent_to_all = send_request->send( i_with_error_screen = 'X' ).

          COMMIT WORK.

          IF sent_to_all IS INITIAL.
            MESSAGE i500(sbcoms) WITH ls_mail-mail.
          ELSE.
            MESSAGE s022(so).
          ENDIF.

*   ------------ exception handling ----------------------------------
*   replace this rudimentary exception handling with your own one !!!
        CATCH cx_bcs INTO bcs_exception.
          MESSAGE i865(so) WITH bcs_exception->error_type.
      ENDTRY.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " SEND_MAIL_2
*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL_3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0025   text
*----------------------------------------------------------------------*
FORM send_mail_3  USING text..

  CONSTANTS:
   gc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab,
   gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf.

  DATA send_request   TYPE REF TO cl_bcs.
  DATA document       TYPE REF TO cl_document_bcs.
  DATA recipient      TYPE REF TO if_recipient_bcs.
  DATA bcs_exception  TYPE REF TO cx_bcs.

  DATA main_text      TYPE bcsy_text.
  DATA binary_content TYPE solix_tab.
  DATA size           TYPE so_obj_len.
  DATA sent_to_all    TYPE os_boolean.

  DATA lv_string TYPE string.
  DATA ls_t100 TYPE t100.

  DATA : lt_mail TYPE TABLE OF zazr_fi_027_t_01,
         ls_mail TYPE zazr_fi_027_t_01.
*
  DATA:lv_dat(10) TYPE c.
  DATA : lv_eski TYPE string.
  DATA : lv_yeni TYPE string.

  PERFORM build_body_of_mail USING:
  'Hörmətli həmkar,','Dəyişiklik qeydləri əlavə olunur.', 'Məlumatınız üçün!'.

  DATA lv_mail TYPE char1.
  DATA:
    l_obj(11),
    l_type(5),
    l_date(15).
  DATA: time(8) TYPE c.

  SELECT * FROM zazr_fi_027_t_01
    INTO TABLE lt_mail
    WHERE statu EQ '3'.

  LOOP AT lt_mail INTO ls_mail.

    CLEAR : lv_string,lv_mail.


    CONCATENATE 'Satici' gc_tab
                'Satici Adi' gc_tab
                'Alan adı' gc_tab
                'Degisiklik gös.' gc_tab
                'Kullanici' gc_tab
                'Tarih ' gc_tab
                'Saat' gc_tab
                'Yeni Deger' gc_tab
                'Eski Deger'   gc_crlf
                  INTO lv_string.

    LOOP AT gt_data4 INTO gs_data WHERE vkorg = ls_mail-vkorg.
      CLEAR lv_dat.
      CLEAR : lv_eski, lv_yeni.
      CONCATENATE gs_data-udate+6(2) '.'
                  gs_data-udate+4(2) '.'
                  gs_data-udate+0(4)
                  INTO lv_dat.

      CLEAR time.
      CONCATENATE gs_data-utime+0(2) ':'
                  gs_data-utime+2(2) ':'
                  gs_data-utime+4(2)
                   INTO time.

      lv_eski = gs_data-value_old.
      lv_yeni = gs_data-value_new.

      CONCATENATE '="' gs_data-value_old '"' INTO lv_eski.
      CONCATENATE '="' gs_data-value_new '"' INTO lv_yeni.

      CONCATENATE lv_string
                  gs_data-lifnr gc_tab
                  gs_data-name1 gc_tab
                  gs_data-fname gc_tab
                  gs_data-cdchngind gc_tab
                  gs_data-name_text gc_tab
                  lv_dat gc_tab
                  time gc_tab
                  lv_yeni gc_tab
                  lv_eski gc_crlf
      INTO lv_string.

      lv_mail = 'X'.
    ENDLOOP.
    IF lv_mail IS NOT INITIAL.
      REFRESH binary_content.
      TRY.
          cl_bcs_convert=>string_to_solix(
            EXPORTING
              iv_string   = lv_string
              iv_codepage = '4103'  "suitable for MS Excel, leave empty
              iv_add_bom  = 'X'     "for other doc types
            IMPORTING
              et_solix  = binary_content
              ev_size   = size ).
        CATCH cx_bcs.
          MESSAGE e445(so).
      ENDTRY.
      TRY.
          REFRESH main_text.
*     -------- create persistent send request ------------------------
          send_request = cl_bcs=>create_persistent( ).

*     -------- create and set document with attachment ---------------
*     create document object from internal table with text
          APPEND 'Hörmətli həmkar,' TO main_text.              "#EC NOTEXT
          APPEND 'Dəyişiklik qeydləri əlavə olunur.' TO main_text.
                                                            "#EC NOTEXT
          APPEND 'Məlumatınız üçün.' TO main_text.
                                                            "#EC notext
          document = cl_document_bcs=>create_document(
            i_type    = 'RAW'
            i_text    = main_text
           i_subject = 'Satıcı Yaradılması və Dəyişiklik Bildirişi' ).
                                                            "#EC NOTEXT

*     add the spread sheet as attachment to document object
          document->add_attachment(
          i_attachment_type    = 'xls'                      "#EC NOTEXT
            i_attachment_subject =
           'Satıcı Yaradılması və Dəyişiklik Bildirişi'       "#EC NOTEXT
            i_attachment_size    = size
            i_att_content_hex    = binary_content ).

*     add document object to send request
          send_request->set_document( document ).

*     --------- add recipient (e-mail address) -----------------------
*     create recipient object
          recipient =
            cl_cam_address_bcs=>create_internet_address( ls_mail-mail ).

*     add recipient object to send request
          send_request->add_recipient( recipient ).

*     ---------- send document ---------------------------------------
          sent_to_all = send_request->send( i_with_error_screen = 'X' ).

          COMMIT WORK.

          IF sent_to_all IS INITIAL.
            MESSAGE i500(sbcoms) WITH ls_mail-mail.
          ELSE.
            MESSAGE s022(so).
          ENDIF.

*   ------------ exception handling ----------------------------------
*   replace this rudimentary exception handling with your own one !!!
        CATCH cx_bcs INTO bcs_exception.
          MESSAGE i865(so) WITH bcs_exception->error_type.
      ENDTRY.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " SEND_MAIL_3
