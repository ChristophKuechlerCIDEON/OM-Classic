class /CIDEON/CLA_PLOT_FAUF definition
  public
  inheriting from CL_GOS_SERVICE
  abstract
  create public .

*"* public components of class /CIDEON/CLA_PLOT_FAUF
*"* do not include other source files here!!!
public section.

  class-methods CLASS_CONSTRUCTOR .
  type-pools ABAP .
*"* protected components of class /CIDEON/CLA_MAT_VIEW_BO
*"* do not include other source files here!!!
protected section.

  class-data MO_SAPRELEASE type ref to /CIDEON/CL_SAPRELEASE .

  methods CHECK_STATUS
    redefinition .
*"* private components of class /CIDEON/CLA_MAT_VIEW_BO
*"* do not include other source files here!!!
private section.
ENDCLASS.



CLASS /CIDEON/CLA_PLOT_FAUF IMPLEMENTATION.


METHOD check_status .
*&----------------------------------------------------------------------
*& Beschreibung: Blendet den generischen Objektdienst abhängig vom
*&               Objekttyp 'Material' ein bzw. aus
*&
*& Autor:        HAENSEL
*& Angelegt am:  24.01.2005
*&----------------------------------------------------------------------
*& Änderungen:
*&  27.01.2005 HAENSEL  Dienst unsichtbar statt inaktiv gemacht.
* 04.10.2008 - CKR - Christoph Küchler
*              Anpassung für Fertigungsauftrag
*
*&----------------------------------------------------------------------
*& Schnittstelle:
*&  [IN]  <Parameter>  <Beschreibung>
*&  [OUT] <Parameter>  <Beschreibung>
*&----------------------------------------------------------------------

  DATA: ls_object    TYPE borident.

  FIELD-SYMBOLS: <lc_instid>  TYPE char70,
                 <lc_typeid>  TYPE char32.

* Implementierung des Codes von CHECK_STATUS aus der Basisklasse
* abhängig vom SAP Release, da die Schnittstelle inkompatibel
* geändert wurde.
  IF mo_saprelease->is_higher( /cideon/cl_saprelease=>mi_46c ) =
    abap_true.
*   Implementierung für Releases > 4.6
    ASSIGN ('IS_LPORB-INSTID') TO <lc_instid>.
    ASSIGN ('IS_LPORB-TYPEID') TO <lc_typeid>.
    IF sy-subrc = 0.
      IF <lc_instid> IS INITIAL.
        ep_status = mp_status_invisible.
      ELSE.
        ep_status = mp_status_active.
      ENDIF.
      ls_object-objkey = <lc_instid>.
      ls_object-objtype = <lc_typeid>.
    ELSE.
      ep_status = mp_status_invisible.
    ENDIF.
  ELSE.
*   Implementierung für Releases <= 4.6C
    ls_object = is_object.
    IF ls_object-objkey IS INITIAL.
      ep_status = mp_status_invisible.
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
*       No dialog user
        ep_status = mp_status_invisible.
      ELSE.
        ep_status = mp_status_active.
      ENDIF.
    ENDIF.

  ENDIF.

  "break kuechler.

  IF NOT ls_object-objtype = 'BUS2005'.
    ep_status = mp_status_invisible.
  ELSE.
    ep_status = mp_status_active.
  ENDIF.



ENDMETHOD.


method CLASS_CONSTRUCTOR .
* SAP Release Informationen besorgen
  CREATE OBJECT mo_saprelease.
endmethod.
ENDCLASS.
