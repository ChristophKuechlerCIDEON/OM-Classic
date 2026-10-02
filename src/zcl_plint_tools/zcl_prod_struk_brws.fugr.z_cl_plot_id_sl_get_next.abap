FUNCTION z_cl_plot_id_sl_get_next.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_NUMRANGE_OBJECT) LIKE  INRI-OBJECT
*"     VALUE(I_NUMRANGE_INTERVAL) LIKE  INRI-NRRANGENR DEFAULT '01'
*"  EXPORTING
*"     VALUE(E_NUMBER)
*"----------------------------------------------------------------------

  DATA: quant LIKE inri-quantity,      " dummy                  ~
        code  LIKE inri-returncode,    " returncode             ~
        subrc LIKE sy-subrc VALUE IS INITIAL.

  CLEAR e_number.

  CLEAR: code, quant.

  CALL FUNCTION 'NUMBER_GET_NEXT'
       EXPORTING
            nr_range_nr             = i_numrange_interval
            object                  = i_numrange_object
*           QUANTITY                = '1'
*           SUBOBJECT               = ' '
*           TOYEAR                  = '0000'
*           IGNORE_BUFFER           = ' '
       IMPORTING
            number                  = e_number
            quantity                = quant
            returncode              = code
       EXCEPTIONS
            interval_not_found      = 1
            number_range_not_intern = 2
            object_not_found        = 3
            quantity_is_0           = 4
            quantity_is_not_1       = 5
            interval_overflow       = 6
            OTHERS                  = 7.

  subrc = sy-subrc.

  IF subrc <> 0   OR
     code  <> ' ' OR
     quant <> 1   OR
     e_number IS INITIAL.
*    break_point.
  ENDIF.

  CASE subrc.
    WHEN 0.
      EXIT.
    WHEN 1.
      MESSAGE a114 WITH i_numrange_interval i_numrange_object.
*     Fehler im Nummernkreis: Intervall & von & nicht gefunden
    WHEN 2.
      MESSAGE a115 WITH i_numrange_object.
*     Fehler im Nummernkreis: Nummernkreis nicht intern/extern
    WHEN 3.
      MESSAGE a116 WITH i_numrange_object.
*     Nummernkreisfehler: N.kreis & nicht vorhanden
    WHEN 4.
      MESSAGE a117 WITH i_numrange_object.
*     Nummerkreisfehler: Keine Nummer aus & bekommen
    WHEN 5.
      MESSAGE a145 WITH i_numrange_interval i_numrange_object.
*     keine Nummer aus Interv. &1 im Nr.kreis &2 bekommen
    WHEN 6.
      MESSAGE a143 WITH i_numrange_interval i_numrange_object.
*     Intervall &1 aus Nummernkreis &2 ist übergelaufen
    WHEN OTHERS.
      MESSAGE a144 WITH i_numrange_interval i_numrange_object.
*     interner Fehler im Intervall &1 des Nummernkreises &2
  ENDCASE.

  CASE code.
    WHEN ' '.
*     everything is ok, so do nothing
    WHEN '1'.
      MESSAGE w146 WITH i_numrange_interval i_numrange_object.
*     vergeb. Nr. aus Interv. &1 im Nr.kreis &2 liegt im krit. Bereich
    WHEN '2'.
      MESSAGE w147 WITH i_numrange_interval i_numrange_object.
*     letzte Nr. aus dem Interv. &1 des Nr.kreises &2 wurde vergeben
    WHEN '3'.
      MESSAGE a143 WITH i_numrange_interval i_numrange_object.
*     Intervall &1 aus Nummernkreis &2 ist übergelaufen
  ENDCASE.

  IF quant <> 1 OR
     e_number IS INITIAL.
    MESSAGE a145 WITH i_numrange_interval i_numrange_object.
*   keine Nummer aus Interv. &1 im Nr.kreis &2 bekommen
  ENDIF.

ENDFUNCTION.
