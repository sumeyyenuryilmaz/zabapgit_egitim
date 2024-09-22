*&---------------------------------------------------------------------*
*& Include          ZAZR_FI_027_01_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  user_command_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  DATA lv_okcode TYPE sy-ucomm.

  lv_okcode = ok_code.
  CLEAR ok_code.
  CASE lv_okcode.
    WHEN 'BACK' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'MAIL'.
      PERFORM send_mail TABLES gt_data
        USING 'Satıcı Oluşturma ve Değişiklik Bildirimi'..
      PERFORM send_mail_2
        USING 'Satıcı Oluşturma ve Değişiklik Bildirimi'.
      PERFORM send_mail_3
        USING 'Satıcı Oluşturma ve Değişiklik Bildirimi'.
  ENDCASE.
  CLEAR lv_okcode.
ENDMODULE.
