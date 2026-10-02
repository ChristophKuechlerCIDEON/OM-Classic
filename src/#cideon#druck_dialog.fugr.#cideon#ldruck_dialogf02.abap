*----------------------------------------------------------------------*
***INCLUDE /CIDEON/LDRUCK_DIALOGF02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_default_values
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form get_default_values.
  data: pwert type pwert.
  data: pname type pname.
  data: tmp_str(255).

* Stempelsprache für sprachabhängige Stempel
  set parameter id 'ZCL_STAMP_LANGUAGE' field sy-langu.

  call function '/CIDEON/READ_DEFAULTDATA'
       exporting
            i_batch        = ''
       importing
            o_default_data = default_data.

endform.                    " get_default_values
*&---------------------------------------------------------------------*
*&      Form  reindex_table_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form reindex_table_2.
  loop at itab_tmp_plotjobs_2 into wa_plotjobs.
    wa_plotjobs-cont = sy-tabix.
    modify itab_tmp_plotjobs_2 from wa_plotjobs index sy-tabix.
  endloop.
endform.                    " reindex_table_2
