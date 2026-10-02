FUNCTION z_cl_read_skeleton_lines.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"       IMPORTING
*"             VALUE(I_UNAME) TYPE  XUBNAME
*"       TABLES
*"              O_ITAB_DATA STRUCTURE  ZCL_S_LINE_256
*"       EXCEPTIONS
*"              ERROR
*"----------------------------------------------------------------------
* CIDEON Software
*
*-----------------------------------------------------------------------
* Author :  Christoph Küchler
*           chris@christoph-kuechler.de
*-----------------------------------------------------------------------
* Journal
* 25.07.2002 Erstellung
*-----------------------------------------------------------------------
  TYPES:
   BEGIN OF t_data_tab,
     line(255),
   END OF t_data_tab.


  DATA: tmp_filename TYPE rlgrap-filename.
*ITAB
  DATA: data_tab TYPE TABLE OF t_data_tab.
  DATA: itab_skel_lines TYPE TABLE OF zcl_skel_lines.
*WA
  DATA: wa_skel_lines LIKE zcl_skel_lines.
  DATA: wa_data_tab TYPE t_data_tab.
*NORMAL
  DATA: numc(3)  TYPE n.



  user_name = i_uname.

  CALL FUNCTION 'Z_CL_CHECK_FOR_UNAME'
       EXPORTING
            i_uname = user_name
       IMPORTING
            o_uname = user_name
       EXCEPTIONS
            error   = 1
            OTHERS  = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      RAISING error.
  ENDIF.

  REFRESH o_itab_data.
  CLEAR wa_data_tab.
  SELECT * FROM zcl_skel_lines INTO wa_skel_lines
    WHERE nutzer = user_name
    .
    wa_data_tab-line = wa_skel_lines-line.
    APPEND wa_data_tab TO o_itab_data.
  ENDSELECT.
  IF sy-subrc NE 0.
    RAISE error.
  ELSE.
  ENDIF.



ENDFUNCTION.
