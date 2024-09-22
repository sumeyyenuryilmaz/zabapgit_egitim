*&---------------------------------------------------------------------*
*& Include          ZAZR_FI_027_01_TOP
*&---------------------------------------------------------------------*
TABLES: cdhdr, cdpos,t012k.
TYPE-POOLS: icon, sscr.

DATA : gv_char TYPE char5.
DATA gv_error.

DATA gv_uzeit TYPE sy-uzeit.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001 .

SELECT-OPTIONS:  s_bukrs   FOR t012k-bukrs,
                 s_udate   FOR cdhdr-udate DEFAULT sy-datum OBLIGATORY,
                 s_object  FOR cdhdr-objectid.
PARAMETERS : p_date TYPE char2 .
SELECTION-SCREEN END OF BLOCK b1.



"Alv
DATA:      ok_code                TYPE sy-ucomm.
*-Data Alv
DATA: go_container         TYPE scrfname VALUE 'GRID',
      grid                 TYPE REF TO cl_gui_alv_grid,
      go_custom_container  TYPE REF TO cl_gui_custom_container,
      gs_layo100           TYPE lvc_s_layo,
      gt_fieldcat          TYPE lvc_t_fcat,
      gs_fieldcat          TYPE lvc_s_fcat,
      gt_sort              TYPE lvc_t_sort,
      gs_sort              TYPE lvc_s_sort,
      gt_exclude           TYPE ui_functions,
      gs_exclude           TYPE ui_func,
      gs_variant           TYPE disvariant,
      gt_dropdown          TYPE lvc_t_drop,
      gt_toolbar_excluding TYPE ui_functions,
      gs_row_no            TYPE lvc_s_roid,
      gt_row_no            TYPE lvc_t_roid,
      gv_hata(1).

DATA: gt_bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
DATA: gt_messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.

TYPES : BEGIN OF ty_order,

          object_id    TYPE crmt_object_id_db,
          process_type TYPE crmt_process_type_db,
          posting_date TYPE crmt_posting_date,

        END OF ty_order,
        t_body_msg TYPE solisti1.
DATA: w_body_msg TYPE t_body_msg.

DATA : w_cnt TYPE i.
DATA: i_body_msj TYPE STANDARD TABLE OF t_body_msg.
DATA: lt_order   TYPE TABLE OF ty_order,
      ls_order   TYPE ty_order,
      lv_subject TYPE so_obj_des.

DATA : gt_data TYPE TABLE OF zazr_fi_027_s_01,
       gs_data TYPE zazr_fi_027_s_01.

DATA : gt_data2 TYPE TABLE OF zazr_fi_027_s_01,
       gs_data2 TYPE zazr_fi_027_s_01.

DATA : gt_data3 TYPE TABLE OF zazr_fi_027_s_01,
       gs_data3 TYPE zazr_fi_027_s_01.

DATA : gt_data4 TYPE TABLE OF zazr_fi_027_s_01,
       gs_data4 TYPE zazr_fi_027_s_01.
