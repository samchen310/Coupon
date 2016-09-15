
GLOBALS "../def/common.4gl"

DATABASE life
MAIN

    DEFINE f_tran_date CHAR(9)
    DEFINE f_rcode     INTEGER
          ,f_beg_time  CHAR(20)
          ,f_end_time  CHAR(20)
          ,f_month_proc_sw char(1)
    DEFINE f_inp_date  CHAR(9)
          ,f_proc_date CHAR(9)
    LET  f_beg_time=TIME
    LET  f_rcode=0
    LET  f_proc_date=GetDate(TODAY)

    -- JOB control beg ---
    CALL JobControl()

    -- �O���٥���B�z�@�~ --
    -- ��J�@�Ӥ�� --
    LET f_tran_date=ARG_VAL(1)
    LET f_month_proc_sw="Y"
    LET g_program_id = "psc00b0"
    
    display "�B�z���:",f_proc_date
    display "�}�l�ɶ�:",f_beg_time

    display "��J�����:",f_tran_date

    CALL psc00s00(f_tran_date,f_month_proc_sw)
         RETURNING f_rcode
    IF f_rcode !=0 THEN
       DISPLAY " call psc00s00 error !!"
    ELSE
       DISPLAY " call psc00s00 ok !!"
    END IF 
    LET f_end_time=TIME
    display "�����ɶ�:",f_end_time

    -- JOB control end ---
    CALL JobControl()

END MAIN
