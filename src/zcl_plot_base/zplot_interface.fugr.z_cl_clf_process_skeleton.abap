FUNCTION z_cl_clf_process_skeleton.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_OUT_PROC) TYPE  C OPTIONAL
*"  TABLES
*"      I_REP_SKELETON STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"      O_REPROLISTE STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"      I_JOBLIST_FILE STRUCTURE  ZCL_S_PLOTLIST OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  DATA : wa_repli_skeleton TYPE zcl_s_line_256,
         wa_joblist_file TYPE zcl_s_plotlist.

  DATA : ao_project(60)  VALUE '-',
         ao_print        VALUE '0',
         lv_tabix        TYPE sy-tabix.

  LOOP AT i_joblist_file INTO wa_joblist_file.
    LOOP AT i_rep_skeleton  INTO wa_repli_skeleton .

      MOVE wa_repli_skeleton-line TO o_reproliste-line.

      IF o_reproliste-line CS '%SY-UNAME%'.
        REPLACE '%SY-UNAME%' WITH sy-uname INTO o_reproliste-line.
        APPEND o_reproliste.

      ELSEIF o_reproliste-line CS '%VERTEILER%'.
        REPLACE '%VERTEILER%' WITH wa_joblist_file-verteiler
                                              INTO o_reproliste-line.
        APPEND o_reproliste.

      ELSEIF o_reproliste-line CS '%SY-DATUM%'.
        WRITE sy-datum TO ao_datum DD/MM/YYYY.
        REPLACE '%SY-DATUM%' WITH ao_datum INTO o_reproliste-line.
        APPEND o_reproliste.

      ELSEIF o_reproliste-line CS '%KOSTENSTELLE%'.
        REPLACE '%KOSTENSTELLE%' WITH wa_joblist_file-kostl
                                            INTO o_reproliste-line.
        APPEND o_reproliste.

      ELSEIF o_reproliste-line CS '%PROJECT%'.
        IF ao_project = '-'.
          REPLACE '%PROJECT%' WITH text-078 INTO o_reproliste-line.
        ELSE.
          REPLACE '%PROJECT%' WITH ao_project INTO o_reproliste-line.
        ENDIF.
        APPEND o_reproliste.

      ELSEIF o_reproliste-line CS '%PRINTMODE%'.
        IF i_out_proc = 'X'.
          ao_print = '1'.
        ELSE.
          ao_print = '0'.
        ENDIF.
        REPLACE '%PRINTMODE%' WITH ao_print INTO o_reproliste-line.
        APPEND o_reproliste.

      ELSEIF o_reproliste-line CS '%NAME1%'.
        REPLACE '%NAME1%' WITH wa_joblist_file-name1
                                              INTO o_reproliste-line.
        APPEND o_reproliste.

      ELSEIF o_reproliste-line CS '%FIRMA%'.
        REPLACE '%FIRMA%' WITH wa_joblist_file-name1
                                              INTO o_reproliste-line.
        APPEND o_reproliste.

      ELSEIF o_reproliste-line CS '%KUNDENNAME%'.
        REPLACE '%KUNDENNAME%' WITH wa_joblist_file-name1
                                              INTO o_reproliste-line.
        APPEND o_reproliste.


      ELSEIF o_reproliste-line CS '%STREET%'.
        REPLACE '%STREET%' WITH wa_joblist_file-stras
                                              INTO o_reproliste-line.
        APPEND o_reproliste.

      ELSEIF o_reproliste-line CS '%CITY%'.
        REPLACE '%CITY%' WITH wa_joblist_file-ort1
                                              INTO o_reproliste-line.
        APPEND o_reproliste.

      ELSEIF o_reproliste-line CS '%PLZ%'.
        REPLACE '%PLZ%' WITH wa_joblist_file-pstlz
                                              INTO o_reproliste-line.
        APPEND o_reproliste.

      ELSEIF o_reproliste-line CS '%PHONE%'.
        REPLACE '%PHONE%' WITH wa_joblist_file-telf1
                                              INTO o_reproliste-line.
        APPEND o_reproliste.

      ELSEIF o_reproliste-line CS '%FAX%'.
        REPLACE '%FAX%' WITH wa_joblist_file-telfx
                                              INTO o_reproliste-line.
        APPEND o_reproliste.

      ELSEIF o_reproliste-line CS '%MAILID%'.
        REPLACE '%MAILID%' WITH wa_joblist_file-smtp_addr
                                              INTO o_reproliste-line.
        APPEND o_reproliste.


      ELSEIF o_reproliste-line CS '%LINES.CLF%'.
        lv_tabix = sy-tabix + 1.
        APPEND o_reproliste.

      ELSE.
        APPEND o_reproliste.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFUNCTION.
