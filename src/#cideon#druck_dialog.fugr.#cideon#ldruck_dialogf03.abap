*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LDRUCK_DIALOGF03 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_user_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_user_values.
* get same user values from configuration tables
**
  data: pwert type pwert.
  data: pname type pname.
  data: tmp_str(255).

  clear user_data.
  user_data-uname = sy-uname.


  call function '/CIDEON/READ_USERDATA'
       exporting
            i_default_data = default_data
       importing
            o_user_data    = user_data.


  g_repid = sy-repid.

  user_data-modus = 'NORMAL'.
  authority-check object 'ZCL_PLOT_2'
           id 'ZCL_TA' field sy-tcode
           id 'ACTVT' field 'L0'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
  .
  if sy-subrc ne 0.
  else.
    user_data-modus =  'SUPER'.
  endif.



  g_repid = sy-repid.

  user_data-modus = 'NORMAL'.
  authority-check object 'ZCL_PLOT_2'
           id 'ZCL_TA' field sy-tcode
           id 'ACTVT' field 'L0'
*           id 'ZDPH_KLIEN' dummy
*           id 'ZDPH_LAGER' dummy
  .
  if sy-subrc ne 0.
  else.
    user_data-modus =  'SUPER'.
  endif.


  init = 'X'.


endform.                    " get_user_values
