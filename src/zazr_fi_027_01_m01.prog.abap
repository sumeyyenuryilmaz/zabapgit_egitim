*&---------------------------------------------------------------------*
*& Include          ZAZR_FI_027_01_M01
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM get_data.
  IF sy-batch IS INITIAL.
    CALL SCREEN 0100.
  ELSE.
    IF gt_data[] IS NOT INITIAL.
      PERFORM send_mail TABLES gt_data
        USING 'Satıcı Oluşturma ve Değişiklik Bildirimi'.
    ENDIF.
    PERFORM send_mail_2
    USING 'Satıcı Oluşturma ve Değişiklik Bildirimi'.
    PERFORM send_mail_3
     USING 'Satıcı Oluşturma ve Değişiklik Bildirimi'.

    MESSAGE 'Mail gönderilmiştir!' TYPE 'I'.
  ENDIF.
