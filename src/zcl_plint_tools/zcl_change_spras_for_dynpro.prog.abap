REPORT zcl_change_spras_for_dynpro .

*ITAB
*WA
DATA: wa TYPE d020s.

PARAMETERS: p_do TYPE c AS CHECKBOX.
PARAMETERS: p_spras TYPE sylangu DEFAULT 'D'.
PARAMETERS: p_prog TYPE progname.

START-OF-SELECTION.

  IF p_do = 'X'.
    SELECT * FROM d020s INTO wa
      where prog = p_prog.
      wa-spra = p_spras.
      MODIFY d020s FROM wa.
    ENDSELECT.
  ELSE.
  ENDIF.
