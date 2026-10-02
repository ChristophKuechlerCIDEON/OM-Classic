FUNCTION zcl_proc_skel_group_clf10.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"      VALUE(WA_DRAW) LIKE DRAW STRUCTURE DRAW OPTIONAL
*"  TABLES
*"      IT_GROUP      STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"      IT_GROUP_CLF  STRUCTURE  ZCL_S_LINE_256 OPTIONAL
*"  EXCEPTIONS
*"      ERROR
*"----------------------------------------------------------------------

  DATA : wa_group TYPE zcl_s_line_256.


  LOOP AT it_group INTO wa_group.

    IF wa_group-line CS '%ONLY_TEXT%'.
      REPLACE '%ONLY_TEXT%' WITH '' INTO wa_group-line.
      APPEND wa_group TO it_group_clf.

    ELSEIF wa_group-line CS '%NAME1%'.
*      REPLACE '%NAME1%' WITH 'Ausgabe' INTO wa_group-line.
      REPLACE '%NAME1%' WITH text-002 INTO wa_group-line.
      APPEND wa_group TO it_group_clf.

    ELSEIF  wa_group-line CS '%AO$_GROUPNAME%'.
*      REPLACE '%AO$_GROUPNAME%' WITH 'Datei' INTO wa_group-line.
      REPLACE '%AO$_GROUPNAME%' WITH text-001 INTO wa_group-line.
      APPEND wa_group TO it_group_clf.

    ELSEIF wa_group-line CS '<%AOFILE_CLF10%>'.
      APPEND wa_group TO it_group_clf.

    ELSEIF wa_group-line CS '</AOG>'.
      APPEND wa_group TO it_group_clf.

    ELSEIF wa_group-line CS '<AOG <AO$_GROUPNAME>>'.
      APPEND wa_group TO it_group_clf.

*   ELSEIF  wa_group-line CS '<AOG name/<AO$_GROUPNAME>/<AO$_PROJECT>>'.
*      APPEND wa_group TO it_group_clf.

*    ELSEIF  wa_group-line CS '%AO$_PROJECT%'.
*      REPLACE '%AO$_PROJECT%' WITH 'Project' INTO wa_group-line.
*      APPEND wa_group TO it_group_clf.

    ELSEIF wa_group-line CS '<AOG <MYVALUE>>'.
      APPEND wa_group TO it_group_clf.

    ELSEIF wa_group-line CS '%MYVALUE%'.
*      REPLACE '%MYVALUE%' WITH 'Datei' INTO wa_group-line.
      REPLACE '%MYVALUE%' WITH text-001 INTO wa_group-line.
      APPEND wa_group TO it_group_clf.

*    ELSEIF wa_group-line CS '%ONLY_TEXT%'.
*      REPLACE '%ONLY_TEXT%' WITH '' INTO wa_group-line.
*      APPEND wa_group TO it_group_clf.

    ELSE.
    ENDIF.

  ENDLOOP.

ENDFUNCTION.


*    IF wa_group-line CS '<AOG <AO$_GROUPNAME>>'.
*      APPEND wa_group TO it_group_clf.

*   ELSEIF  wa_group-line CS '<AOG name/<AO$_GROUPNAME>/<AO$_PROJECT>>'.
*      APPEND wa_group TO it_group_clf.

*    ELSEIF  wa_group-line CS '%AO$_PROJECT%'.
*      REPLACE '%AO$_PROJECT%' WITH 'Project' INTO wa_group-line.
*      APPEND wa_group TO it_group_clf.

*    ELSEIF wa_group-line CS '<AOG <MYVALUE>>'.
*      APPEND wa_group TO it_group_clf.

*    ELSEIF wa_group-line CS '%MYVALUE%'.
*      REPLACE '%MYVALUE%' WITH 'Datei' INTO wa_group-line.
*      APPEND wa_group TO it_group_clf.

*    ELSEIF wa_group-line CS '%ONLY_TEXT%'.
*      REPLACE '%ONLY_TEXT%' WITH 'Only_Text' INTO wa_group-line.
*      APPEND wa_group TO it_group_clf.

*    IF wa_group-line CS '<AOG <AO$_GROUPNAME>>'.
*      APPEND wa_group TO it_group_clf.
