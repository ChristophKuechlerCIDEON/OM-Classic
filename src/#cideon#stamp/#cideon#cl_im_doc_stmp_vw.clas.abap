class /CIDEON/CL_IM_DOC_STMP_VW definition
  public
  final
  create public .

*"* public components of class /CIDEON/CL_IM_DOC_STMP_VW
*"* do not include other source files here!!!
public section.

  interfaces IF_EX_DOCUMENT_FILES01 .
*"* protected components of class /CIDEON/CL_IM_DOC_STMP_VW
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_IM_DOC_STMP_VW
*"* do not include other source files here!!!
private section.
ENDCLASS.



CLASS /CIDEON/CL_IM_DOC_STMP_VW IMPLEMENTATION.


method IF_EX_DOCUMENT_FILES01~AFTER_ASSIGN_FILE.
* ...
endmethod.


method IF_EX_DOCUMENT_FILES01~AFTER_COPY_FILE_DIALOG.
* ...
endmethod.


method IF_EX_DOCUMENT_FILES01~AFTER_START_APPL.
* ...
endmethod.


method IF_EX_DOCUMENT_FILES01~BEFORE_ASSIGN_FILE.
* ...
endmethod.


method IF_EX_DOCUMENT_FILES01~BEFORE_COPY_FILE_DIALOG.
* ...
endmethod.


method IF_EX_DOCUMENT_FILES01~BEFORE_LIST_TEMPLATES.
* ...
endmethod.


METHOD if_ex_document_files01~before_start_appl.
* ...

* 'Stempeln vor Viewen' sollte nur bei APPL_TYPE = '1' benutzt werden
* also beim Viewen. Bein Drucken sollten die unveränderten Dateien
* benutzt werden.


  IF appl_type = 1.
    CALL FUNCTION '/CIDEON/STAMP_BEFORE_VIEW'
         EXPORTING
              i_appl_type   = appl_type
              i_draw        = draw
              i_target_file = target_file
              i_docfile     = docfile
              i_draz        = draz
         EXCEPTIONS
              error         = 1
              do_not_stamp  = 2
              OTHERS        = 3.
    IF sy-subrc <> 0.
      IF sy-subrc = 2.
      ELSE.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ELSE.
  ENDIF.


ENDMETHOD.


method IF_EX_DOCUMENT_FILES01~GENERATE_COPY_FILE_NAME.
* ...
endmethod.


method IF_EX_DOCUMENT_FILES01~GENERATE_ORIGINAL_FILE_NAME.
* ...
endmethod.
ENDCLASS.
