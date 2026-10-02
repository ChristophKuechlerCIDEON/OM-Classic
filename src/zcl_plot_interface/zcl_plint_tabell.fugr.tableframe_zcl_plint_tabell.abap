*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZCL_PLINT_TABELL
*   generation date: 22.10.2002 at 16:35:49 by user KUECHLER
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZCL_PLINT_TABELL   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
