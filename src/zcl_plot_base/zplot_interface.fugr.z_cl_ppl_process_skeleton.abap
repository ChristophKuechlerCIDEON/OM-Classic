FUNCTION z_cl_ppl_process_skeleton.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  TABLES
*"      I_ITAB_JOBLIST_FILE STRUCTURE  ZCL_S_PLOTLIST OPTIONAL
*"      I_ITAB_PPL_SKELETON STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"      O_ITAB_PPL_PROC_SKEL STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  DATA : wa_ppl_skeleton TYPE zcl_s_line_256.

  LOOP AT i_itab_joblist_file .

    LOOP AT i_itab_ppl_skeleton INTO wa_ppl_skeleton.

      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
           EXPORTING
                percentage = 30
                text       = text-083.

      MOVE wa_ppl_skeleton-line TO o_itab_ppl_proc_skel-line.

      IF o_itab_ppl_proc_skel-line CS 'AOPPL-LIST_1.0'.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS 'AOJOB-BEGIN'.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS 'AOFILES-BEGIN'.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS 'AOJOB-END'.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS '%SY-UNAME%'.
        REPLACE '%SY-UNAME%' WITH sy-uname
                                        INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS '%SENDER%'.
        REPLACE '%SENDER%' WITH sy-uname INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS '%OUTPUTDEVICE%'.
        REPLACE '%OUTPUTDEVICE%' WITH i_itab_joblist_file-ausgabegeraet
                                         INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS '%VERTEILER%'.
        REPLACE '%VERTEILER%' WITH i_itab_joblist_file-verteiler
                                         INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS '%SY-DATUM%'.
        WRITE sy-datum TO ao_datum DD/MM/YYYY.
        REPLACE '%SY-DATUM%' WITH ao_datum
                                         INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS '%KOSTENSTELLE%'.
        REPLACE '%KOSTENSTELLE%' WITH i_itab_joblist_file-kostl
                                         INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS '%ACCOUNT%'.
        REPLACE '%ACCOUNT%' WITH sy-uname
                                         INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS '%JOBCOUNT%'.
        REPLACE '%JOBCOUNT%' WITH '1' INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.


      ELSEIF o_itab_ppl_proc_skel-line CS '%DISTRIBUTOR%'.
        REPLACE '%DISTRIBUTOR%' WITH i_itab_joblist_file-ausgabegeraet
                                      INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.


      ELSEIF o_itab_ppl_proc_skel-line CS '%TARGET%'.
        REPLACE '%TARGET%' WITH '1'
                               INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS '%SEPARATOR%'.
        REPLACE '%SEPARATOR%' WITH '-'
                                INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS '%PRIORITY%'.
        REPLACE '%PRIORITY%' WITH i_itab_joblist_file-prio
                                 INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS '%NAME1%'.
        REPLACE '%NAME1%' WITH i_itab_joblist_file-name1
                                  INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS '%FIRMA%'.
        REPLACE '%FIRMA%' WITH  i_itab_joblist_file-firma
                                   INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS '%STREET%'.
        REPLACE '%STREET%' WITH i_itab_joblist_file-stras
                                    INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS '%CITY%'.
        REPLACE '%CITY%' WITH i_itab_joblist_file-ort1
                                     INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS '%PLZ%'.
        REPLACE '%PLZ%' WITH i_itab_joblist_file-pstlz
                                      INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS '%PHONE%'.
        REPLACE '%PHONE%' WITH i_itab_joblist_file-telf1
                                       INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS '%FAX%'.
        REPLACE '%FAX%' WITH i_itab_joblist_file-telfx
                                        INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS '%MAILID%'.
        REPLACE '%MAILID%' WITH i_itab_joblist_file-smtp_addr
                                         INTO o_itab_ppl_proc_skel-line.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS '%LINES.CLF%'.
        APPEND o_itab_ppl_proc_skel.

      ELSEIF o_itab_ppl_proc_skel-line CS 'AOFILES-END'.
        APPEND o_itab_ppl_proc_skel.

      ENDIF.

    ENDLOOP.

  ENDLOOP.

ENDFUNCTION.
