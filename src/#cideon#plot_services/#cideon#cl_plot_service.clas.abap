class /CIDEON/CL_PLOT_SERVICE definition
  public
  inheriting from CL_GOS_SERVICE
  abstract
  create public .

*"* public components of class /CIDEON/CL_PLOT_SERVICE
*"* do not include other source files here!!!
public section.

  class-methods CLASS_CONSTRUCTOR .
  methods CONSTRUCTOR .
  type-pools SEOX .
*"* protected components of class /CIDEON/CL_PLOT_SERVICE
*"* do not include other source files here!!!
protected section.

  data BUSINESS_OBJECT type ref to /CIDEON/IF_PLOT_BO .
  type-pools SEOX .
  data NOT_IMPLEMENTED type SEOX_BOOLEAN .

  methods CHECK_STATUS
    redefinition .
*"* private components of class /CIDEON/CL_PLOT_SERVICE
*"* do not include other source files here!!!
private section.

  class-data MO_SAPRELEASE type ref to /CIDEON/CL_SAPRELEASE .
  type-pools SEOX .
ENDCLASS.



CLASS /CIDEON/CL_PLOT_SERVICE IMPLEMENTATION.


METHOD check_status .
************************************************************************
* Beschreibung: Es wird die Verfügbarkeit des Services abhängig vom
*               Objekttyp geregelt.
*               Der Service ist für folgende Objekttypen verfügbar:
*               - BUS2105    Bestellanforderung
*
* Autor:        Heiko Hänsel
* Angelegt am:  01.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  21.04.2004   HAENSEL  Dynamische Prüfung eingebaut, ob der Service
*                        für den Business Object Typ zur Verfügung
*                        steht.
*  12.08.2004   HAENSEL  Dynamisierung wegen inkompat. Schnittstelle
*                        der Methode zu 4.70
*  29.03.2005   HAENSEL  Die Dynamisierung vom 12.08.2004 zurückgebaut,
*                        da 4.7 nun separat entwickelt wird.
************************************************************************

  DATA: class_name        TYPE string.

*  ASSIGN ('IS_LPORB-INSTID') TO <lc_instid>.
*  assign ('IS_LPORB-TYPEID') TO <lc_typeid>.
*    IF sy-subrc = 0.
*      IF IS_LPORB-INSTID IS INITIAL.
*        ep_status = mp_status_inactive.
*      ELSE.
*        ep_status = mp_status_active.
*      ENDIF.
*      ls_object-objkey = <lc_instid>.
*      ls_object-objtype = <lc_typeid>.
*    else.
*      ep_status = mp_status_inactive.
*    ENDIF.
*  ELSE.
*    ls_object = is_object.
  IF is_lporb-typeid IS INITIAL.
    ep_status = mp_status_inactive.
  ELSE.
    DATA  ls_logond TYPE uslogond.

    CALL FUNCTION 'SUSR_USER_LOGONDATA_GET'
      EXPORTING
        user_name      = sy-uname
      IMPORTING
        user_logondata = ls_logond
      EXCEPTIONS
        OTHERS         = 1.
    IF sy-subrc <> 0 OR ls_logond-ustyp <> 'A'.
*     No dialog user
      ep_status = mp_status_inactive.
    ELSE.
      ep_status = mp_status_active.
    ENDIF.
  ENDIF.

  CHECK NOT ep_status = mp_status_inactive.

* Wenn das Business Objekt Attribut intial ist und nicht NOT_IMPLEMENTED
* gesetzt ist, dann versuche eine Instanz des betreffenden Business
* Objektes zu erzeugen.
  IF not_implemented = abap_false.
    IF business_object IS INITIAL.
      CONCATENATE '/CIDEON/CL_PLOT_BO_' is_lporb-typeid
        INTO class_name.
      CATCH SYSTEM-EXCEPTIONS create_object_class_not_found = 1.
        CREATE OBJECT business_object TYPE (class_name).
        CALL METHOD business_object->set_key( is_lporb-instid ).
      ENDCATCH.
      IF sy-subrc = 1.
*       Der Service ist nicht verfügbar.
        not_implemented = abap_true.
        ep_status = mp_status_invisible.
      ENDIF.
    ENDIF.
  ELSE.
    ep_status = mp_status_invisible.
  ENDIF.

ENDMETHOD.


METHOD class_constructor.

  " SAP Release Informationen besorgen
  CREATE OBJECT mo_saprelease.
ENDMETHOD.


METHOD CONSTRUCTOR .
************************************************************************
* Beschreibung: Constructor für den Objektservice.
*
* Autor:        Heiko Hänsel
* Angelegt am:  01.04.2004
*-----------------------------------------------------------------------
* Änderungen:
*  TT.MM.JJJJ   <Änderer>  <Änderungsbeschreibung>
************************************************************************
  CALL METHOD super->constructor.

ENDMETHOD.
ENDCLASS.
