FUNCTION-POOL zplot_interface.              "MESSAGE-ID ..

** Data for Z_CL_SEARCH_LIST
DATA: t_bapi_doc_files2    TYPE bapi_doc_files2 OCCURS 0
                                                   WITH HEADER LINE,
      t1_bapi_doc_files2 TYPE bapi_doc_files2 OCCURS 0
                                                   WITH HEADER LINE,
      t2_bapi_doc_files2 TYPE bapi_doc_files2 OCCURS 0
                                                   WITH HEADER LINE,
      t3_bapi_doc_files2   TYPE bapi_doc_files2 OCCURS 0
                                                   WITH HEADER LINE.

DATA: BEGIN OF gv_stru,
          langu      TYPE sy-langu,
          y_filename LIKE rlgrap-filename,
      END OF gv_stru.


* Data for the Function Module Z_CL_PLOT_LIST.
DATA : obj_frontend TYPE REF TO cl_gui_frontend_services.
DATA : t_zcl_s_plotlist TYPE zcl_s_plotlist OCCURS 0 WITH HEADER LINE,
       joblist_file     TYPE zcl_s_plotlist OCCURS 0 WITH HEADER LINE,
       job_fehllist     TYPE zcl_s_plotlist OCCURS 0 WITH HEADER LINE,
       table_of_files1  TYPE sdokpath       OCCURS 0 WITH HEADER LINE,
       table_of_direcs1 TYPE sdokpath       OCCURS 0 WITH HEADER LINE.

DATA : delete_source(50)   TYPE c.
DATA : fehl_doc_detail(40) TYPE c.
DATA : ppl_special_check   TYPE c,
       ppl_deck_check      TYPE c,
       ppl_inhalts_check   TYPE c,
       ppl_ende_check      TYPE c,
       rtf_special_check   TYPE c,
       rtf_deck_check      TYPE c,
       rtf_inhalts_check   TYPE c,
       rtf_ende_check      TYPE c,
       rtf_fehl_check      TYPE c.

DATA : tmp_dirname       LIKE rlgrap-filename,
       stripped_name     LIKE rlgrap-filename,
       file_path         LIKE rlgrap-filename,
       split_full_path   LIKE rlgrap-filename,
       moved_directory   LIKE rlgrap-filename,
       h1                LIKE rlgrap-filename,
       h2                LIKE rlgrap-filename,
       p1                LIKE rlgrap-filename,
       p2                LIKE rlgrap-filename,
       deck_down         LIKE rlgrap-filename,
       ende_down         LIKE rlgrap-filename,
       inhalts_down      LIKE rlgrap-filename,
       fehl_down         LIKE rlgrap-filename,
       filename          LIKE draw-filep.

DATA : ao_datum(10),
       tabix            TYPE sy-tabix,
       dir_exist        TYPE c,
       rc               TYPE i,
       count_files      TYPE i,
       tmp_copies       TYPE c,
       num_copy         TYPE c,
       dir_create       TYPE string,
       k                TYPE sy-tabix VALUE 1,
       temp_path        LIKE bapi_doc_aux-filename,
       x_filename       LIKE rlgrap-filename,
       d_drive_path(255) TYPE c,
       no_lines         TYPE i,
       next_level       TYPE i,
       percentage       TYPE i.

DATA : it_file_info TYPE TABLE OF file_info,
       wa_file_info TYPE file_info.

DATA :  it_repli_skeleton TYPE STANDARD TABLE OF zcl_s_line_256,
        wa_repli_skeleton TYPE zcl_s_line_256.

DATA : it_repli_lines TYPE STANDARD TABLE OF zcl_s_line_256,
       wa_repli_lines TYPE zcl_s_line_256.


* An internal table to modify or insert..from or to any internal tables.
DATA : BEGIN OF reproliste OCCURS 50,
            line(1000),
        END OF reproliste.

* An internal table to modify or insert..from or to any internal tables.
DATA : BEGIN OF x_lines OCCURS 20,
        line(1000),
       END OF x_lines.

DATA : destination TYPE string,
       source TYPE string.

****** Data for the FM Z_CL_DECKBLATT**********
DATA : file_exist TYPE c.

DATA : it_lines TYPE STANDARD TABLE OF zcl_s_line_256 ,
       wa_lines TYPE zcl_s_line_256.

DATA : it_liste TYPE zcl_s_line_256 OCCURS 0 WITH HEADER LINE,
       wa_liste TYPE zcl_s_line_256 .
*******Data for FM Z_CL_READ_PAPER_FORMATS********
DATA: itab_paper_format TYPE TABLE OF zcl_paper_format,
      wa_paper_format TYPE zcl_paper_format.

DATA: numc(3)   TYPE n,
      user_name TYPE xubname.
*******************************
DATA : gv_filelength       TYPE i,
       gv_ao_datum(30)     TYPE c,
       gv_filename         TYPE string,
       gv_stripped_name1   LIKE rlgrap-filename,
       gv_stripped_name2   LIKE rlgrap-filename,
       gv_stripped_name    LIKE rlgrap-filename,
       gv_file_path        LIKE rlgrap-filename,
       gv_rtf_dowload_path LIKE rlgrap-filename,
       gv_itab_data_tab    TYPE STANDARD TABLE OF zcl_s_line_256.
*******************************
