*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZAZR_FI_027_T_01................................*
DATA:  BEGIN OF STATUS_ZAZR_FI_027_T_01              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZAZR_FI_027_T_01              .
CONTROLS: TCTRL_ZAZR_FI_027_T_01
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZAZR_FI_027_T_01              .
TABLES: ZAZR_FI_027_T_01               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
