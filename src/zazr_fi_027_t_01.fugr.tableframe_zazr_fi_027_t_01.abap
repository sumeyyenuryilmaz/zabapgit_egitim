*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZAZR_FI_027_T_01
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZAZR_FI_027_T_01   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
