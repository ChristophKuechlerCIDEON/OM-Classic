REPORT z_delete_all_in_c_temp_direc .

DATA : table_of_files LIKE sdokpath OCCURS 0 WITH HEADER LINE,
       table_of_direcs LIKE sdokpath OCCURS 0 WITH HEADER LINE,

       num_of_files TYPE i,
       num_of_direcs TYPE i.


*CALL FUNCTION 'Z_DELETE_ALL_IN_TEMP_DIRECTORY'
*     EXPORTING
*          path            = 'C:\TEMP\CV04N\'
*          file_type       = '*.*'
*     IMPORTING
*          num_of_files    = num_of_files
*          num_of_direcs   = num_of_direcs
*     TABLES
*          table_of_files  = table_of_files
*          table_of_direcs = table_of_direcs.
