FUNCTION ZCL_DMS_ADD_TO_QUEUE.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             REFERENCE(CALLED_FROM) TYPE  DMS_PROC01-PROC_TYPE
*"         OPTIONAL
*"             REFERENCE(TESTMODE) TYPE  C OPTIONAL
*"       TABLES
*"              TDRAW STRUCTURE  DRAW OPTIONAL
*"              PROTOCOL OPTIONAL
*"       EXCEPTIONS
*"              ERROR
*"----------------------------------------------------------------------
* CIDEON SAP Plotting Interface
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 25.11.2002 Erstellung
*-----------------------------------------------------------------------

*ITAB
  DATA: itab_objects TYPE TABLE OF pdm_exp_objects.
*WA
  DATA: wa_objects TYPE pdm_exp_objects.
  DATA: wa_draw TYPE draw.
*NORMAL
  DATA: save_tcode LIKE sy-tcode.

  CLEAR wa_objects.
  REFRESH itab_objects.
  CLEAR save_tcode.

*  CASE sy-tcode.
*    WHEN 'CV03N'.
*      save_tcode = 'CC04'.
*      SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD'X'.
*    WHEN OTHERS.
*      save_tcode = sy-tcode.
*      SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD'X'.
*  ENDCASE.

  SET PARAMETER ID 'Z_PL_READ_AKT_QUEUE' FIELD'X'.


  LOOP AT tdraw INTO wa_draw.
    CLEAR wa_objects.
    MOVE-CORRESPONDING wa_draw TO wa_objects.
    wa_objects-object_type = 'DOCUMENT'.
    APPEND wa_objects TO itab_objects.
  ENDLOOP.


  CALL FUNCTION 'Z_CL_PSBRW_WRITE_PSB_TMP'
       TABLES
            i_itab_objects = itab_objects
       EXCEPTIONS
            error          = 1
            OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  COMMIT WORK AND WAIT.

*  CALL TRANSACTION 'ZCL_PLOT_INTERFACE'.



ENDFUNCTION.
