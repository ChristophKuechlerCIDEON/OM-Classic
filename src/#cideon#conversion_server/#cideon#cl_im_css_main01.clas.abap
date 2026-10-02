class /CIDEON/CL_IM_CSS_MAIN01 definition
  public
  final
  create public .

*"* public components of class /CIDEON/CL_IM_CSS_MAIN01
*"* do not include other source files here!!!
public section.

  interfaces IF_EX_CONVERTER_MAIN01 .
*"* protected components of class /CIDEON/CL_IM_CSS_MAIN01
*"* do not include other source files here!!!
protected section.
*"* private components of class /CIDEON/CL_IM_CSS_MAIN01
*"* do not include other source files here!!!
private section.
ENDCLASS.



CLASS /CIDEON/CL_IM_CSS_MAIN01 IMPLEMENTATION.


METHOD if_ex_converter_main01~checkin_after_checkin.
* ...

* Recherchieren, ob zusätzliche Aktionen nach dem erfolgreichen
* Einchecken / Konvertieren gestartet werden sollen
* z.B. eine weitere aufbauende Konvertierung, etc.


* Einstellungen lesen


* Aktionen ausführen
  CALL FUNCTION '/CIDEON/CSS_GET_NEXT_CONV'
       EXPORTING
            is_document_key         = is_document_key
            i_kpro_use              = i_kpro_use
            is_conv_requested       = is_conv_requested
            is_convert_spec         = is_convert_spec
            is_converter            = is_converter
            is_conv_path_and_matrix = is_conv_path_and_matrix
            is_conv_req_data        = is_conv_req_data
            it_doc_files            = it_doc_files
            is_doc_file             = is_doc_file
       EXCEPTIONS
            kein_nachfolger         = 1
            OTHERS                  = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


* Einträge ins Applikation LOG

ENDMETHOD.


METHOD if_ex_converter_main01~checkin_before_checkin.
* ...
ENDMETHOD.


METHOD if_ex_converter_main01~checkin_change_ws_application.
* ...
ENDMETHOD.
ENDCLASS.
