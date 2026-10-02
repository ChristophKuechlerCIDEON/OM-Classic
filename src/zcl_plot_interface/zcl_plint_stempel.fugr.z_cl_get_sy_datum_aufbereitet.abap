FUNCTION z_cl_get_sy_datum_aufbereitet.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_WA_PLOTJOBS) TYPE  ZCL_S_PLOTLIST
*"  EXPORTING
*"     VALUE(O_STEMPEL_WERT) TYPE  ZCL_STEMPEL_WERT
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  DATA: datum type char10.

  CALL FUNCTION 'DATUMSAUFBEREITUNG'
    EXPORTING
*     FLAGM                 = ' '
*     FLAGW                 = ' '
      idate                 = sy-datum
*     IMONT                 = ' '
*     IWEEK                 = ' '
    IMPORTING
*     MDAT4                 =
*     MDAT6                 =
*     TDAT4                 =
*      tdat6                 = datum
      TDAT8                 = datum
*     WDAT4                 =
*     WDAT6                 =
    EXCEPTIONS
      datfm_ungueltig       = 1
      datum_ungueltig       = 2
      OTHERS                = 3
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.



  o_stempel_wert = datum.


ENDFUNCTION.
