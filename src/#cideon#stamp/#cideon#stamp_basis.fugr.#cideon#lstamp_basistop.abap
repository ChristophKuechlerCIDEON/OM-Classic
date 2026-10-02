FUNCTION-POOL /cideon/stamp_basis.          "MESSAGE-ID ..



TABLES : rfcdes, rfctest.
INCLUDE <icon>.

DATA: dest LIKE rfcdes-rfcdest VALUE 'NONE'.
DATA: repeat TYPE i VALUE 1.
DATA: blocks TYPE i VALUE 4.
DATA: dump(1) VALUE ''   .
DATA: keep_luw(1) VALUE ''.
DATA: authchk TYPE c VALUE space.

DATA : tx TYPE f, ta TYPE i, te TYPE i.
DATA : BEGIN OF rfctab OCCURS 0.
        INCLUDE STRUCTURE rfctest.
DATA : END OF rfctab.
DATA : rfcerror TYPE i.
DATA : lines TYPE i.
DATA : v1 TYPE i VALUE 21.
DATA : tytext(30).
DATA : pitext LIKE sy-ucomm,
       piperc TYPE i.
TYPES: cpic_text(70) TYPE c.
DATA: call TYPE cpic_text,
      component TYPE cpic_text,
      counter TYPE cpic_text,
      detail TYPE cpic_text,
      errno TYPE cpic_text,
      errno_txt TYPE cpic_text,
      error TYPE cpic_text,
      line TYPE cpic_text,
      location TYPE cpic_text,
      module TYPE cpic_text,
      rc TYPE cpic_text,
      release TYPE cpic_text,
      subrc LIKE sy-subrc,
      time TYPE cpic_text,
      version TYPE cpic_text.
DATA: l_subrc LIKE sy-subrc,
      len TYPE i,
      cpic_detail_available(1) TYPE c VALUE space.
