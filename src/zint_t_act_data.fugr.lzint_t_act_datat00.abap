*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZINT_T_ACT_DATA.................................*
DATA:  BEGIN OF STATUS_ZINT_T_ACT_DATA               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZINT_T_ACT_DATA               .
CONTROLS: TCTRL_ZINT_T_ACT_DATA
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZINT_T_ACT_DATA               .
TABLES: ZINT_T_ACT_DATA                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
