FUNCTION Z_CL_READ_SKEL_CLF.
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
  data: itab_skel_lines type table of ZCL_SKEL_clf.
*WA
  data: wa_SKELETON like ZCL_SKEL_clf.
  data: wa_data_tab type t_data_tab.
*NORMAL
  data: numc(3)  type n.



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
      raising error.
  ENDIF.

  refresh o_itab_data.
  clear wa_data_tab.
  select * from zcl_skel_clf into wa_skeleton
    where nutzer = user_name
    .
    wa_data_tab-line = wa_skeleton-line.
    append wa_data_tab to o_itab_data.
  endselect.
  if sy-subrc ne 0.
    raise error.
  else.
  endif.



ENDFUNCTION.
