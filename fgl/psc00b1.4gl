
GLOBALS "../def/common.4gl"

DATABASE life
MAIN


    DEFINE f_tran_date CHAR(9)
    DEFINE f_rcode ,p_disb_cnt    INTEGER
          ,f_beg_time  CHAR(20)
          ,f_end_time  CHAR(20)
          ,f_month_proc_sw char(1)
    DEFINE f_inp_date  CHAR(9)
          ,f_proc_date CHAR(9)

    SET LOCK MODE TO WAIT

    LET  f_beg_time=TIME
    LET  f_rcode=0
    LET  f_month_proc_sw="N"
    LET  f_proc_date=GetDate(TODAY)

    -- JOB control beg ---
    CALL JobControl()

    -- 保單還本日處理作業 --
    -- 輸入一個日期 --
    LET f_tran_date=ARG_VAL(1)
    LET f_month_proc_sw="N"
    LET g_program_id = "psc00b1"
    
    display "處理日期:",f_proc_date
    display "開始時間:",f_beg_time

    display "輸入的日期:",f_tran_date

    LET p_disb_cnt = 0
    SELECT count(*) INTO p_disb_cnt
      FROM pscb
     WHERE disb_special_ind not in ( '0','1')

     IF p_disb_cnt > 0 THEN
        DISPLAY " begin disb_special_ind error : ", p_disb_cnt
     END IF

    CALL psc00s00(f_tran_date,f_month_proc_sw)
         RETURNING f_rcode
    IF f_rcode !=0 THEN
       DISPLAY " call psc00s00 error !!"
    ELSE
       DISPLAY " call psc00s00 ok !!"
    END IF 
    LET f_end_time=TIME
    display "end_time:",f_end_time

    LET p_disb_cnt = 0
    SELECT count(*) INTO p_disb_cnt
      FROM pscb
     WHERE disb_special_ind not in ( '0','1')

     IF p_disb_cnt > 0 THEN
        DISPLAY " begin disb_special_ind error : ", p_disb_cnt
     END IF
    -- JOB control end ---

    CALL JobControl()

END MAIN
