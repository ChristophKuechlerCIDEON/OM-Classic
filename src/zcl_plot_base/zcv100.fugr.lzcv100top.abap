FUNCTION-POOL zcv100 MESSAGE-ID 26.                       "MESSAGE-ID ..
TYPE-POOLS slis.
DATA  tab_check.
INCLUDE <icon>.
DATA  g_flag_exit VALUE ''..
DATA  tmp_copies(4).
DATA: itab_index_rows_searchlist_z  TYPE lvc_t_row.
DATA : obj_frontend TYPE REF TO cl_gui_frontend_services.

*___________________________________
* For the purpose of Dyn-Pro '0902'.
*___________________________________
DATA  ok_code TYPE sy-ucomm.

*ITAB
DATA: itab_tdwp TYPE TABLE OF tdwp.
DATA: wa_tdwp TYPE  tdwp.

*CL Coustom Controls
DATA: grid_suchen_z TYPE REF TO cl_gui_alv_grid.
DATA: container_grid_suchen_z TYPE REF TO cl_gui_custom_container.

DATA: grid_plotlist_z TYPE REF TO cl_gui_alv_grid.
DATA: container_grid_plotlist_z TYPE REF TO cl_gui_custom_container.


*LAYOUT
DATA: g_layo_grid_suchen_z TYPE lvc_s_layo.

*FieldKatalog
DATA: g_fc_grid_suchen_z TYPE  lvc_t_fcat.

*___________________________________

INCLUDE cv_constants.

TABLES: tdwp.

DATA : ttdwp LIKE tdwp OCCURS 0 WITH HEADER LINE.
*DATA: it_tdwp LIKE tdwp OCCURS 0 WITH HEADER LINE.

DATA : BEGIN OF it_tdwp OCCURS 0,
         dappl LIKE tdwp-dappl,
         cvtext LIKE tdwp-cvtext,
         dateifrmt LIKE tdwp-dateifrmt,
         flag,       "flag for mark column
       END OF it_tdwp.

*DATA : wa_tdwp TYPE tdwp.

CONSTANTS: c_list_web(1)   TYPE c VALUE '1',
           c_list_table(1) TYPE c VALUE '2',
           c_list_memid(1) TYPE c VALUE '3'.

TABLES: drad, drap, drat, draw, mcdok, qinf, tclo, tdwa, tdwo, tdwot,
        tdws, tdwsexitt, tdwst.
TABLES: tdwd, *tdwd, tdwn.


*CONTROLS:  mainstrip TYPE TABSTRIP,
*           objectstrip TYPE TABSTRIP,
*           tab_x TYPE TABLEVIEW USING SCREEN 1201.

DATA: marked_line(1) TYPE c,
      actcnt TYPE i.                   "act count in selection

FIELD-SYMBOLS: <tab>.

DATA: init_ok,
      init_char_ok,
      screen_nr LIKE sy-dynnr,         "subscreen in 0400
      oscreen_nr LIKE sy-dynnr.        "subscreen in 0404
*      ok_code(10) TYPE c.

* fulltext-retrieval
DATA: gf_cs_repid      TYPE sy-repid,
      gf_cs_dynp       TYPE sy-dynnr,
      gf_cs_active     TYPE sy-datar.

* Invocation from CAD library
DATA: cad_called LIKE sy-batch,
      cad_fcode LIKE sy-lisel.

* note 391227
DATA: gf_api_flag TYPE xfeld.

DATA: gf_cv04_list_type(1) TYPE c,
      gf_web_list_type(1)  TYPE c.

* textsearch in subscreen
TABLES rsfin.

DATA: searchtab_orig TYPE STANDARD TABLE OF fist WITH HEADER LINE,
      stepl LIKE sy-stepl,             "index to searchtab_orig
      sw_class LIKE fist-swclass,
      oper LIKE fist-searchw.

* Object links
DATA  BEGIN OF inttdwo OCCURS 0.       "defined links per DOKAR
        INCLUDE STRUCTURE tdwo.
DATA: ktxt LIKE tdwot-ktxt,
      END OF inttdwo.

DATA srcdrad TYPE STANDARD TABLE OF seldrad WITH HEADER LINE.
DATA intdrad TYPE STANDARD TABLE OF seldrad WITH HEADER LINE.

* Strings for Object tabstrip
DATA: objtab01(60) TYPE c, objtab02(60) TYPE c, objtab03(60) TYPE c,
      objtab04(60) TYPE c, objtab05(60) TYPE c, objtab06(60) TYPE c,
      objtab07(60) TYPE c, objtab08(60) TYPE c, objtab09(60) TYPE c,
      objtab10(60) TYPE c, objtab11(60) TYPE c, objtab12(60) TYPE c,
      objtab13(60) TYPE c, objtab14(60) TYPE c, objtab15(60) TYPE c,
      objtab16(60) TYPE c, objtab17(60) TYPE c, objtab18(60) TYPE c,
      objtab19(60) TYPE c, objtab20(60) TYPE c, objtab21(60) TYPE c,
      objtab22(60) TYPE c, objtab23(60) TYPE c, objtab24(60) TYPE c,
      objtab25(60) TYPE c, objtab26(60) TYPE c, objtab27(60) TYPE c,
      objtab28(60) TYPE c, objtab29(60) TYPE c, objtab30(60) TYPE c,
      objtab31(60) TYPE c, objtab32(60) TYPE c, objtab33(60) TYPE c,
      objtab34(60) TYPE c, objtab35(60) TYPE c, objtab36(60) TYPE c,
      objtab37(60) TYPE c, objtab38(60) TYPE c, objtab39(60) TYPE c,
      objtab40(60) TYPE c, objtab41(60) TYPE c, objtab42(60) TYPE c,
      objtab43(60) TYPE c, objtab44(60) TYPE c, objtab45(60) TYPE c,
      objtab46(60) TYPE c, objtab47(60) TYPE c, objtab48(60) TYPE c,
      objtab49(60) TYPE c, objtab50(60) TYPE c.
DATA: dummy(60).

FIELD-SYMBOLS: <keyf1>, <keyf2>, <keyf3>, <keyf4>, <keyf5>,
               <keyf6>, <keyf7>, <keyf8>, <keyf9>, <keyf10>.

FIELD-SYMBOLS: <field1>, <field2>, <field3>, <field4>, <field5>,
               <field6>, <field7>, <field8>, <field9>, <field10>.

DATA: flen1  TYPE i, flen2  TYPE i, flen3  TYPE i, flen4  TYPE i,
      flen5  TYPE i, flen6  TYPE i, flen7  TYPE i, flen8  TYPE i,
      flen9  TYPE i, flen10 TYPE i.

DATA: offset TYPE i,
      last_actobj(10) TYPE c,          "like ok_code.
      save_dokar LIKE draw-dokar,
      kpro_use TYPE c,
      process_flag TYPE c.             "additional processes

* Selections
TABLES: dms_selections, dms_selectionst.

DATA: BEGIN OF dms_selections_key,
      bname LIKE dms_selections-bname,
      vari LIKE dms_selections-vari,
      END OF dms_selections_key.

DATA: user_specific TYPE c,
      var TYPE c,                      " U = user S = standard
      vartext(40) TYPE c,
      chbox TYPE c.

DATA: box(1) TYPE c, lines TYPE i, num(1) TYPE c.

SELECTION-SCREEN BEGIN OF SCREEN 402 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-005.
SELECT-OPTIONS:
  stdoknr FOR draw-doknr NO INTERVALS.

* define push-button "Search" for WEB-EWT's
SELECTION-SCREEN:
  PUSHBUTTON pos_high(12) pb_sel USER-COMMAND sel MODIF ID 002.

SELECT-OPTIONS:
  stdokar FOR draw-dokar NO INTERVALS.

* define push-button "Reset" for WEB-EWT's
SELECTION-SCREEN:
  PUSHBUTTON pos_high(12) pb_res USER-COMMAND vres MODIF ID 002.

SELECT-OPTIONS:
  stdoktl FOR draw-doktl NO INTERVALS,
  stdokvr FOR draw-dokvr NO INTERVALS.
PARAMETERS restrict TYPE i.
SELECTION-SCREEN END OF BLOCK bl1.
SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-006.
PARAMETERS slng LIKE rsfin-langu.
SELECT-OPTIONS:
  stdktxt FOR drat-dktxt_uc NO INTERVALS,
  stdwnam FOR draw-dwnam NO INTERVALS,
  stlabor FOR draw-labor NO INTERVALS,
    staennr FOR draw-aennr NO INTERVALS MATCHCODE OBJECT aen1,
  stbegru FOR draw-begru NO INTERVALS,
  stloedk FOR draw-loedk NO INTERVALS,
  stcadkz FOR draw-cadkz NO INTERVALS DEFAULT '*'.
PARAMETERS dttrg LIKE draw-dttrg MODIF ID 001.
PARAMETERS dappl LIKE draw-dappl MODIF ID 001.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(16) text-008 FOR FIELD status.
SELECTION-SCREEN POSITION 18.
PARAMETERS status LIKE tdwst-stabk.
SELECTION-SCREEN COMMENT 22(12) text-012 FOR FIELD stseit.
SELECTION-SCREEN POSITION 36.
PARAMETERS stseit LIKE mcdok-stseit.
SELECTION-SCREEN COMMENT 48(12) text-013 FOR FIELD stseit.
SELECTION-SCREEN POSITION 62.
PARAMETERS stbis LIKE mcdok-stbis.
SELECTION-SCREEN PUSHBUTTON 74(4) sthelp USER-COMMAND shlp.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK bl2.
SELECTION-SCREEN END OF SCREEN 402.

* Classification
DATA: lf_clprg LIKE sy-repid,
      lf_cldyn LIKE sy-dynnr,
      init_cls.

DATA wcltext TYPE STANDARD TABLE OF cltext WITH HEADER LINE.

DATA BEGIN OF hits OCCURS 10.
        INCLUDE STRUCTURE clobj.
DATA END OF hits.
DATA ccomw TYPE STANDARD TABLE OF comw WITH HEADER LINE.
DATA causp TYPE STANDARD TABLE OF ausp WITH HEADER LINE.

*
DATA: lf_looplines TYPE i,
      marked_linenr TYPE i.

TYPE-POOLS: slis.

DATA:
      filename LIKE draw-filep,
      idx_tab_x TYPE i.

DATA: BEGIN OF temp_file_tab OCCURS 10,
        tempfile LIKE draw-filep,
      END OF temp_file_tab.

DATA:  BEGIN OF doklist OCCURS 100,
      dokar LIKE draw-dokar,
      doknr LIKE draw-doknr,
      dokvr LIKE draw-dokvr,
      doktl LIKE draw-doktl,
  END OF doklist.

DATA: founddraw TYPE STANDARD TABLE OF founddraw WITH HEADER LINE,
      cpdraw TYPE STANDARD TABLE OF founddraw WITH HEADER LINE,
      workdraw TYPE STANDARD TABLE OF founddraw WITH HEADER LINE.

DATA fdraw TYPE STANDARD TABLE OF draw WITH HEADER LINE.

DATA: cpvar,                           " L = list / C = clipboard
      cptext(40).

DATA: fieldcat TYPE slis_t_fieldcat_alv,
      fieldcatalog TYPE slis_fieldcat_alv,
      eventtab TYPE slis_t_event,
      eventtab_zeile TYPE slis_alv_event,
      pf_tab TYPE slis_t_extab,
      layout TYPE slis_layout_alv.

DATA: linez LIKE sy-tabix,
  name(20),
  lf_idx TYPE i.

DATA: tab1(30) TYPE c, tab2(30) TYPE c, tab3(30) TYPE c,
      tab4(30) TYPE c, tab5(30) TYPE c.

DATA: matcomp-aufnr LIKE aufk-aufnr,   " für Anschluß Materialkomp.
      matcomp-vornr LIKE afvc-vornr,
      matcomp-posnr2 LIKE resb-posnr.
DATA: matcomp-i_rsnum  LIKE resb-rsnum,   " für Anschluß Materialkomp.
      matcomp-i_rspos  LIKE resb-rspos,
      matcomp-i_rsart  LIKE resb-rsart,
      matcomp-rsnum_vsnmr LIKE vskopf-vsnmr.

DATA: smqmel-qmnum LIKE qmel-qmnum,
      qmqmel-qmnum LIKE qmel-qmnum.
DATA: gf_variant_use TYPE c.
DATA: gf_class_search TYPE c.

*DATA:     SY-UCOMM LIKE SY-UCOMM.

* TYPE FOR THE DATA OF TABLECONTROL 'Z602'
TYPES: BEGIN OF t_z602,
         dappl LIKE tdwp-dappl,
         cvtext LIKE tdwp-cvtext,
         dateifrmt LIKE tdwp-dateifrmt,
         flag,       "flag for mark column
       END OF t_z602.

* INTERNAL TABLE FOR TABLECONTROL 'Z602'
DATA:     g_z602_itab   TYPE t_z602 OCCURS 0,
          g_z602_wa     TYPE t_z602, "work area
          g_z602_copied.           "copy flag

* DECLARATION OF TABLECONTROL 'Z602' ITSELF
CONTROLS: z602 TYPE TABLEVIEW USING SCREEN 0602.

* DECLARATION OF TABLECONTROL 'Z902' ITSELF
CONTROLS: z902 TYPE TABLEVIEW USING SCREEN 0902.

* TYPE FOR THE DATA OF TABLECONTROL 'Z100'
TYPES: BEGIN OF t_z100,
         dappl LIKE tdwp-dappl,
         cvtext LIKE tdwp-cvtext,
         dateifrmt LIKE tdwp-dateifrmt,
         flag,       "flag for mark column
       END OF t_z100.

* INTERNAL TABLE FOR TABLECONTROL 'Z100'
DATA:     g_z100_itab   TYPE t_z100 OCCURS 0,
          g_z100_wa     TYPE t_z100, "work area
          g_z100_copied.           "copy flag

* DECLARATION OF TABLECONTROL 'Z100' ITSELF
CONTROLS: z100 TYPE TABLEVIEW USING SCREEN 0100.

* LINES OF TABLECONTROL 'Z100'
DATA:     g_z100_lines  LIKE sy-loopc.


* Data for the Function Module z_cl_delete_files_in_tmp.
DATA : table_of_files1  LIKE sdokpath OCCURS 0 WITH HEADER LINE,
       table_of_direcs1 LIKE sdokpath OCCURS 0 WITH HEADER LINE.

DATA : delete_source(50) TYPE c.
DATA: tmp_str type string.
