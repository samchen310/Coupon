-------------------------------------------------------------------------------
-- 程式名稱:psc03r.4gl
-- 作    者:jessica Chang
-- 日    期:087/02/03
-- 處理概要:滿期 給付明細列印(明細表,控制報表)
-- table   :pscb,pscp
-- inp para:列印日
-- return 的參數:
-- 重要函式:
-------------------------------------------------------------------------------
-- 修改目的:新增領取方式
-- 修改者  :jessica Chang
-- 需求單號:
-- 修改日期:088/12/14
-- 功能碼特殊說明 郵寄支票: R1-滿期        R2-生存
--                抵繳保費: R3-滿期        R4-生存
--                未回領取: R5-滿期        R6-生存
--                電    匯: R7-滿期_一般   R8-滿期_延遲
--                電    匯: R9-生存_一般   RA-生存_延遲
--                櫃台領取: RB-滿期        RC-生存
--                還本回流: RJ-滿期        RK-生存
-------------------------------------------------------------------------------
--  修改者:JC
--  090/04/25:修改受益人名字的找法,有id 找clnt,否則顯示 benf 的 names
-------------------------------------------------------------------------------
--  修  改:JC 090/07/20 SR:PS90655S 配合還本修正
--           "給付明細",改為 "對帳單明細",取消領款人簽章等字句
-------------------------------------------------------------------------------
--  修  改:SR120800390 EB加密專案-報表調整、新增要保人姓名ID欄位 cmwang 101/09
-------------------------------------------------------------------------------
--  修  改:105/04/01 新增月給付險種
--  1.只揭露每月給付金額，不揭露該年度的還款資訊
--  2.改從pscu抓給付資料
--  3.根據週月日判斷延遲
--  4.月給付只會揭露在報表cp_pay_dtl_col() cp_pay_unnormal()
--    100萬以上/回流/外幣報表尚未加上月給付
-------------------------------------------------------------------------------
--GLOBALS "/devp/def/common.4gl"   --測試用
--GLOBALS "/devp/def/lf.4gl"       --測試用
--GLOBALS "/devp/def/report.4gl"   --測試用


GLOBALS "../def/common.4gl"   --上線後開啟
GLOBALS "../def/lf.4gl"       --上線後開啟
GLOBALS "../def/report.4gl"   --上線後開啟
--SR120800390 cmwang 101/09 電子通知e_bill格式內容
GLOBALS "../def/omsg.4gl"
------------------------------------
DATABASE life

   DEFINE p_rpt_code_1     CHAR(8) -- 給付明細表代碼     --
   DEFINE p_rpt_code_2     CHAR(8) -- 生存控制報表代碼   --
   DEFINE p_rpt_code_3     CHAR(8) -- 滿期大宗掛號       --
   DEFINE p_rpt_code_4     CHAR(8) -- 滿期控制報表代碼_延遲電匯 --
   DEFINE p_rpt_code_5     CHAR(8) -- 滿期控制報表代碼_延遲電匯 A4 --
   DEFINE p_rpt_code_7     CHAR(8)
   DEFINE p_rpt_code_8     CHAR(8)
   DEFINE p_rpt_code_9     CHAR(8)
   DEFINE p_rpt_code_10    CHAR(8) -- 還本給付一般件、e-billing、暫停郵寄明細表
   DEFINE p_rpt_code_11    CHAR(8)
   DEFINE p_rpt_code_12    CHAR(8)
   DEFINE p_rpt_code_13    CHAR(8)

   
   DEFINE p_rpt_beg_date   CHAR(9) -- 列印報表起日   --
   DEFINE p_rpt_end_date   CHAR(9) -- 列印報表止日   --
   DEFINE p_rpt_name_1     CHAR(40) -- 給付明細表抬頭 --
         ,p_rpt_name_2     CHAR(40) -- 生存控制表抬頭 --
         ,p_rpt_name_3     CHAR(40) -- 滿期大宗掛號   --
         ,p_rpt_name_4     CHAR(40) -- 滿期控制表抬頭_延遲電匯 --
         ,p_rpt_name_5     CHAR(40) -- 滿期控制表抬頭_延遲電匯 A4 --
         ,p_rpt_name_7     CHAR(40) -- 回流延遲控制報表 --
         ,p_rpt_name_8     CHAR(40)
         ,p_rpt_name_9     CHAR(40)
         ,p_rpt_name_10    CHAR(40) -- 還本給付一般件、e-billing、暫停郵寄明細表       
         ,p_rpt_name_11    CHAR(40)
         ,p_rpt_name_12    CHAR(40)
         ,p_rpt_name_13    CHAR(40)


   DEFINE p_name                CHAR(14)
   DEFINE p_pscb           RECORD LIKE pscb.*
   DEFINE p_pscp           RECORD LIKE pscp.*
   DEFINE p_cp_pay_detail  RECORD
          process_date            LIKE pscb.change_date
         ,policy_no               LIKE polf.policy_no
         ,cp_anniv_date           LIKE pscb.cp_anniv_date
         ,cp_sw                   LIKE pscb.cp_sw
         ,cp_pay_form_type        LIKE pscp.cp_pay_form_type
         ,plan_code               LIKE pscp.plan_code
         ,rate_scale              LIKE pscp.rate_scale
         ,coverage_no             LIKE pscp.coverage_no
         ,face_amt                LIKE pscp.face_amt
         ,paid_to_date            LIKE pscp.paid_to_date
         ,po_issue_date           LIKE pscp.po_issue_date
         ,minus_prem_susp         LIKE pscp.minus_prem_susp
         ,loan_amt                LIKE pscp.loan_amt
         ,loan_int_balance        LIKE pscp.loan_int_balance
         ,loan_int                LIKE pscp.loan_int
         ,apl_amt                 LIKE pscp.apl_amt
         ,apl_int_balance         LIKE pscp.apl_int_balance
         ,apl_int                 LIKE pscp.apl_int
         ,rtn_minus_premsusp      LIKE pscp.rtn_minus_premsusp
         ,rtn_loan_amt            LIKE pscp.rtn_loan_amt
         ,rtn_loan_int            LIKE pscp.rtn_loan_int
         ,rtn_apl_amt             LIKE pscp.rtn_apl_amt
         ,rtn_apl_int             LIKE pscp.rtn_apl_int
         ,prem_susp               LIKE pscp.prem_susp
         ,accumulated_div         LIKE pscp.accumulated_div
         ,div_int_balance         LIKE pscp.div_int_balance
         ,div_int                 LIKE pscp.div_int
         ,cp_amt                  LIKE pscp.cp_amt
         ,cp_chk_date             LIKE pscp.cp_chk_date
         ,rtn_rece_no             LIKE pscp.rtn_rece_no
         ,cp_pay_amt              LIKE pscp.cp_pay_amt
         ,cp_disb_type            LIKE pscb.cp_disb_type
         ,mail_addr_ind           LIKE polf.mail_addr_ind
         ,dept_code               LIKE dept.dept_code
         ,agent_code              LIKE agnt.agent_code
         ,dept_belong             LIKE dept.dept_belong
         ,address                 LIKE addr.address
         ,zip_code                LIKE addr.zip_code
         ,currency                LIKE pscp.currency
                           END RECORD

    DEFINE p_pscd_r ARRAY [99] OF RECORD
          policy_no               LIKE pscd.policy_no
         ,cp_anniv_date           LIKE pscd.cp_anniv_date
         ,cp_pay_cnt              LIKE pscd.cp_pay_cnt
         ,cp_pay_seq              LIKE pscd.cp_pay_seq
         ,currency                LIKE pscd.currency
         ,cp_pay_amt              LIKE pscd.cp_pay_amt
         ,names                   LIKE pscd.names
         ,benf_ratio              LIKE pscd.benf_ratio 
         ,cp_real_payamt          LIKE pscd.cp_real_payamt
         ,remit_bank              LIKE pscd.remit_bank
         ,remit_branch            LIKE pscd.remit_branch
         ,remit_account           LIKE pscd.remit_account
         ,disb_no                 LIKE pscd.disb_no
         ,client_id               LIKE pscd.client_id
                          END  RECORD
    DEFINE p_pscx_r ARRAY [99] OF RECORD LIKE pscx.*

    DEFINE p_payform_5            CHAR(100) -- 給付明細表頭─生存   --
          ,p_payform_52           CHAR(100)
          ,p_payform_6            CHAR(100) -- 給付明細表頭─滿期   --
          ,p_payform_7            CHAR(100) -- 大宗掛號空的資料 --
          ,p_payform_8            CHAR(100) -- 大宗掛號空的資料 --
          ,p_payform_init         CHAR(100)
          ,p_payform_end_5        CHAR(100) -- 承辦分公司─生存     --
          ,p_payform_end_6        CHAR(100) -- 承辦分公司─滿期     --

    DEFINE p_payform_0 ARRAY [11] OF  CHAR(100) -- 給付明細的格式表頭   --
    DEFINE p_payform_1 ARRAY [11] OF  CHAR(100) -- 給付明細─生存金     --
    DEFINE p_payform_2 ARRAY [13] OF  CHAR(100) -- 給付明細─滿期金     --
    DEFINE p_payform_3 ARRAY [20] OF  CHAR(100) -- 大宗掛號             --
    DEFINE p_payform_d ARRAY [3]  OF  CHAR(100) -- 給付明細─受益人明細 --
    DEFINE p_payform_e ARRAY [9]  OF  CHAR(100) -- 給付明細─結尾       --

    DEFINE p_pmms                  RECORD LIKE pmms.*    ----大宗掛號需求 by yirong 95/01
    DEFINE p_batch_no_pm           LIKE pmms.batch_no_pm ----大宗掛號需求 by yirong 95/01
    DEFINE p_cmd                   CHAR(100)             ----大宗掛號需求 by yirong 95/01
    DEFINE  run_cmd1 CHAR(80)
    DEFINE  run_cmd2 CHAR(80)
MAIN

    DEFINE f_rcode INTEGER

    -- Job Control beg --
    CALL JobControl()

    LET f_rcode       =0
    LET p_rpt_beg_date=ARG_VAL(1)
    LET p_rpt_end_date=ARG_VAL(2)
    LET g_program_id = "psc03r"

    CALL get_pm_batch_no() RETURNING p_batch_no_pm       ----大宗掛號需求 by yirong 95/01
    IF p_batch_no_pm = 0 THEN
       DISPLAY "簽收單號產生失敗 !!"
    END IF

    -- 給付明細表 --
    CALL GetDocLname( '2') RETURNING p_name
    CALL psc03r01_init_array()  RETURNING f_rcode
    CALL psc03r01() RETURNING f_rcode
    IF f_rcode !=0 THEN
       DISPLAY "call psc03r01 error !!"
    END IF
    -- Job Control end --
    CALL JobControl()

END MAIN
-------------------------------------------------------------------------------
-- 程式名稱:psc03r01
-- 作    者:jessica Chang
-- 日    期:087/02/03
-- 處理概要:滿期給付明細與控制報表
-- table   :pscb,pscp
-- inp para:列印日
-- return 的參數:
-- 重要函式:
-------------------------------------------------------------------------------
FUNCTION psc03r01 ()

    DEFINE f_rcode            INTEGER
          ,f_2141_have_data   CHAR(1)    -- 郵寄支票 --
          ,f_2143_have_data   CHAR(1)    -- 正常電匯 --
          ,f_2825_have_data   CHAR(1)    -- 抵繳保費 --
          ,f_0027_have_data   CHAR(1)    -- 還本回流 --
          ,f_agnt_have_data   CHAR(1)    -- 未回領取 --
          ,f_2143_unnormal    CHAR(1)    -- 電匯延遲 --
          ,f_0027_unnormal    CHAR(1)    -- 還本延遲 --
          ,f_2143_have_data_50   CHAR(1) -- 正常電匯<100萬  --    
          ,f_2143_unnormal_50    CHAR(1) -- 電匯延遲>=100萬 --
          ,f_cp5_have_data       CHAR(1) -- 主動電匯正常<100萬  --
          ,f_cp5_have_data_50    CHAR(1) -- 主動電匯正常>=100萬 --
          ,f_cp5_unnormal        CHAR(1) -- 主動電匯延遲<100萬  --
          ,f_cp5_unnormal_50     CHAR(1) -- 主動電匯延遲>=100萬 -- 
          ,f_have_data        CHAR(1)
          ,f_pmia_sw          LIKE pmia.pmia_sw   -- 判斷是否郵寄
          ,f_have_data_usd   CHAR(1)
          ,f_data_col_usd    CHAR(1)

          
    DEFINE f_rpt_name_1       CHAR(30)   -- 滿期給付明細報表   --
    DEFINE f_rpt_name_2       CHAR(30)   -- 滿期給付控制報表   --
    DEFINE f_rpt_name_3       CHAR(30)   -- 滿期給付大宗掛號   --
    DEFINE f_rpt_name_4       CHAR(30)   -- 滿期給付延遲電匯   --
    DEFINE f_rpt_name_5       CHAR(30)   -- 滿期給付延遲電匯 A4 --
    DEFINE f_rpt_name_6       CHAR(30)   -- 大宗掛號需求 by yirong 95/01
    DEFINE f_rpt_name_7       CHAR(30)   -- 回流延遲控制報表 --
    DEFINE f_rpt_name_8       CHAR(30)   -- 還本給付控制報表 >=100萬 --
    DEFINE f_rpt_name_9       CHAR(30)   -- 還本給付延遲電匯 >=100萬 --
    DEFINE f_rpt_name_10      CHAR(30)   -- 還本給付一般件、e-billing、暫停郵寄明細表
    DEFINE f_rpt_name_11      CHAR(30)   -- 生存給付統計報表
    DEFINE f_rpt_name_12      CHAR(30)   -- 還本給付明細報表外幣   --
    DEFINE f_rpt_name_13      CHAR(30)   -- 還本給付控制報表外幣   --

    DEFINE f_i                INTEGER    -- 給付明細的資料 --
    DEFINE f_pscd_cnt         INTEGER    -- 給付明細的筆數 --
    DEFINE f_cp_pay_detail_sw CHAR(1)    -- 是否有給付明細 --

    DEFINE f_po_issue_date     LIKE polf.po_issue_date   -- 保單生效日  --
          ,f_expired_date      LIKE polf.expired_date    -- 滿期日 --
          ,f_expired_sw        CHAR(1)                   -- 滿期 sw --
          ,f_po_sts_code       LIKE polf.po_sts_code
          ,f_modx              LIKE polf.modx
          ,f_method            LIKE polf.method
          ,f_polf_mail_addr_ind LIKE polf.mail_addr_ind  -- SR:PS88217S --

    DEFINE f_agent_code        LIKE poag.agent_code      -- 業務員-ID   --
          ,f_agent_name        LIKE clnt.names           -- 業務員-name --

    DEFINE f_dept_code         LIKE agnt.dept_code       -- 營業處代號  --
          ,f_dept_name         LIKE dept.dept_name       -- 營業處名稱  --
          ,f_dept_mail         LIKE dept.dept_mail       -- 單位通訊代碼 --
          ,f_dept_belong_name  LIKE dept.dept_name       -- 分公司  --

    DEFINE f_applicant_id      LIKE pocl.client_id       -- 要保人-ID   --
          ,f_applicant_name    LIKE clnt.names           -- 要保人-name --
          ,f_client_ident      LIKE pocl.client_ident    -- 關係人識別碼 --
          ,f_insured_id        LIKE pocl.client_id       -- 被保人-ID   --
          ,f_insured_name      LIKE clnt.names           -- 被保人-name --

    DEFINE f_benf_id           ARRAY[10] OF LIKE pocl.client_id       -- 受益人-ID   --
          ,f_benf_name         ARRAY[10] OF LIKE clnt.names           -- 受益人-name --
    DEFINE f_benf_name_all     CHAR(50)

    DEFINE f_zip_code          LIKE addr.zip_code        -- 郵遞區號    --
          ,f_address           LIKE addr.address         -- 地址        --
          ,f_tel_1             LIKE addr.tel_1           -- 電話號碼-1  --

    DEFINE f_plan_desc          LIKE pldf.plan_desc    -- 險種描述    --
          ,f_cp_chk_sw          LIKE pscr.cp_chk_sw    -- 支票兌現否  --
          ,f_cp_notice_print_sw LIKE pscr.cp_notice_print_sw -- 通知印否 --
          ,f_cp_form_desc       CHAR(6)

    DEFINE f_t_f                INTEGER
          ,f_dept_adm_no        LIKE dept.dept_code
          ,f_dept_adm_name      LIKE dept.dept_name

    DEFINE f_note_recv_name     LIKE clnt.names   -- 明細收件者 --
          ,f_pay_desc           CHAR(10)
          ,f_var_date           INTEGER
          ,f_R3_min_date        CHAR(9)
          ,f_function_code      VARCHAR(10)   -- 當筆資料必須進入特殊電匯 --
                                              -- 因應滿期主動電匯需求，更改為VARCHAR(10)
          

    DEFINE f_benf_cmd           CHAR(254) 
    DEFINE f_pscd_cmd           CHAR(254)
    DEFINE f_pscx_cmd           CHAR(254)
    DEFINE f_item_no            INTEGER     ----大宗掛號需求 by yirong 95/01
    DEFINE f_j                  INTEGER
    DEFINE f_ebill_email        LIKE addr.address
    DEFINE f_ebill_zip_ind      CHAR(1)
    DEFINE f_ebill_ind          CHAR(1)
    DEFINE f_mobile_o1          LIKE addr.tel_1
    DEFINE f_sub_stat           CHAR(2)
    DEFINE f_fn_code_desc       CHAR(14)
    DEFINE f_pay_modx           LIKE arpm.pay_modx   -- 12:年給付   1:月給付
          ,f_pscu               RECORD LIKE pscu.* 
          ,f_source             CHAR(4)              -- 資料來源
          ,f_payout_date_from   CHAR(9)

    LET f_rcode=0
    LET f_2141_have_data ="N"
    LET f_2143_have_data ="N"
    LET f_2143_have_data_50 ="N"
    LET f_2825_have_data ="N"
    LET f_0027_have_data ="N"
    LET f_agnt_have_data ="N"
    LET f_have_data      ="N"
    LET f_2143_unnormal  ="N"
    LET f_2143_unnormal_50  ="N"
    LET f_0027_unnormal  ="N"
    LET f_var_date       =4
    LET f_cp5_have_data    ="N"
    LET f_cp5_have_data_50 ="N"
    LET f_cp5_unnormal     ="N"
    LET f_cp5_unnormal_50  ="N"    
    LET f_have_data_usd        ="N"
    LET f_data_col_usd     ="N"
    LET f_pay_modx         = 0
    LET f_source           =" "
    LET f_payout_date_from =" "
    INITIALIZE f_pscu.* TO NULL
    
    -- 滿期金給付明細報表 --
    LET p_rpt_code_1    ="psc03r01"
 -- LET f_rpt_name_1    =ReportName(p_rpt_code_1)
    CALL GetReportTitle( p_rpt_code_1, TRUE )
    LET p_rpt_name_1    =g_report_name
--    LET f_rpt_name_1    = PSManagerName('psc03r01')
      LET f_rpt_name_1    ="psc03r01.",p_rpt_end_date[8,9]
--    LET f_rpt_name_1    ="psc03r01.lst"

    -- 滿期金給付控制表 --
    LET p_rpt_code_2    ="psc03r02"
 -- LET f_rpt_name_2    =ReportName(p_rpt_code_2)
    CALL GetReportTitle( p_rpt_code_2, TRUE )
    LET p_rpt_name_2    =g_report_name
    LET f_rpt_name_2    ="psc03r02.lst"
{
    -- 滿期金給付大宗掛號函 --
    LET p_rpt_code_3    ="psc03r03"
 -- LET f_rpt_name_3    =ReportName(p_rpt_code_3)
    CALL GetReportTitle( p_rpt_code_3, TRUE )
    LET p_rpt_name_3    =g_report_name
    LET f_rpt_name_3    ="psc03r03.lst"
}
    LET f_rpt_name_6    = "psc03r06.lst"      ---大宗掛號需求 by yirong 95/01

    -- 生存金給付明細表_電匯特殊作業 --
    LET p_rpt_code_4    ="psc03r04"
 -- LET f_rpt_name_4    =ReportName(p_rpt_code_2)
    CALL GetReportTitle( p_rpt_code_4, TRUE )
    LET p_rpt_name_4    =g_report_name
    LET f_rpt_name_4    ="psc03r04.lst"

    -- 生存金給付明細表_電匯特殊作業 A4 --
    LET p_rpt_code_5    ="psc03r05"
 -- LET f_rpt_name_5    =ReportName(p_rpt_code_2)
    CALL GetReportTitle( p_rpt_code_5, TRUE )
    LET p_rpt_name_5    =g_report_name
--    LET f_rpt_name_5    = PSManagerName('psc03r05')
    LET f_rpt_name_5    = "psc03r05.",p_rpt_end_date[8,9]
--    LET f_rpt_name_5    ="psc03r05.lst"

    -- 回流延遲控制報表 ---
    LET p_rpt_code_7    ="psc03r07"
    CALL GetReportTitle( p_rpt_code_4, TRUE )
    LET p_rpt_name_7    =g_report_name
    LET f_rpt_name_7    ="psc03r07.",p_rpt_end_date[8,9]

       -- 生存金給付控制表 >= 100萬--
    LET p_rpt_code_8    ="psc03r08"
    CALL GetReportTitle( p_rpt_code_2, TRUE )
    LET p_rpt_name_8    =g_report_name
    LET f_rpt_name_8    ="psc03r08.lst"

    -- 生存金給付明細表_電匯特殊作業 >= 100萬--
    LET p_rpt_code_9    ="psc03r09"
    CALL GetReportTitle( p_rpt_code_4, TRUE )
    LET p_rpt_name_9    =g_report_name
    LET f_rpt_name_9    ="psc03r09.lst"

    -- 還本給付 一般件、e-billing、暫停郵寄明細表                                
    LET p_rpt_code_10    ="psc03r10"
    CALL GetReportTitle( p_rpt_code_10, TRUE )                                   
    LET p_rpt_name_10    =g_report_name                                          
    LET f_rpt_name_10    = "psc03r10.",p_rpt_end_date[8,9]
  
    -- 給付統計報表
    LET p_rpt_code_11    ="psc03r11"
    CALL GetReportTitle( p_rpt_code_11, TRUE )
    LET p_rpt_name_11    =g_report_name
    LET f_rpt_name_11    = "psc03r11.",p_rpt_end_date[8,9]

    --
    LET p_rpt_code_12    ="psc03r12"
    CALL GetReportTitle( p_rpt_code_12, TRUE )
    LET p_rpt_name_12    =g_report_name
    LET f_rpt_name_12    = "psc03r12.",p_rpt_end_date[8,9]

    --
    LET p_rpt_code_13    ="psc03r13"
    CALL GetReportTitle( p_rpt_code_13, TRUE )
    LET p_rpt_name_13    =g_report_name
    LET f_rpt_name_13    = "psc03r13.",p_rpt_end_date[8,9]

                                                                       


    LET f_item_no = 0                          ----大宗掛號需求 by yirong 95/01
    -- 105/04/01 月給付險種資料來源為pscu,並利用f_source區分資料來源
    --           因為月給付第一期也會有pscb進入報表，要控制不揭露該筆pscp
    DECLARE f_s1 CURSOR FOR
            SELECT a.change_date
                  ,a.policy_no
                  ,a.cp_anniv_date
                  ,a.cp_sw
                  ,b.cp_pay_form_type
                  ,b.plan_code
                  ,b.rate_scale
                  ,b.coverage_no
                  ,b.face_amt
                  ,b.paid_to_date
                  ,b.po_issue_date
                  ,b.minus_prem_susp
                  ,b.loan_amt
                  ,b.loan_int_balance
                  ,b.loan_int
                  ,b.apl_amt
                  ,b.apl_int_balance
                  ,b.apl_int
                  ,b.rtn_minus_premsusp
                  ,b.rtn_loan_amt
                  ,b.rtn_loan_int
                  ,b.rtn_apl_amt
                  ,b.rtn_apl_int
                  ,b.prem_susp
                  ,b.accumulated_div
                  ,b.div_int_balance
                  ,b.div_int
                  ,b.cp_amt
                  ,b.cp_chk_date
                  ,b.rtn_rece_no
                  ,b.cp_pay_amt
                  ,a.cp_disb_type
                  ,a.mail_addr_ind
                  ,b.dept_code
                  ,b.agent_code
                  ,c.dept_belong
                  ,a.address
                  ,a.zip_code
                  ,b.currency
                  ,"pscp"
                  ," "
            FROM  pscb a,pscp b ,dept c
            WHERE change_date  BETWEEN p_rpt_beg_date AND p_rpt_end_date
            AND   a.policy_no    =b.policy_no
            AND   a.cp_anniv_date=b.cp_anniv_date
            AND   a.cp_disb_type in ("0","2","3","4","5","6")
            AND   a.cp_sw in ("2","6")
            AND   b.cp_pay_form_type in ("6","6.1","6.2")
            AND   b.dept_code=c.dept_code
    UNION
            SELECT a.change_date
                  ,a.policy_no
                  ,a.cp_anniv_date
                  ,a.cp_sw
                  ,b.cp_pay_form_type
                  ,b.plan_code
                  ,b.rate_scale
                  ,b.coverage_no
                  ,b.face_amt
                  ,b.paid_to_date
                  ,b.po_issue_date
                  ,0                          -- minus_prem_susp                   
                  ,0                          -- loan_amt                          
                  ,0                          -- loan_int_balance                  
                  ,0                          -- loan_int                          
                  ,0                          -- apl_amt                           
                  ,0                          -- apl_int_balance                   
                  ,0                          -- apl_int                           
                  ,0                          -- rtn_minus_premsusp                
                  ,0                          -- rtn_loan_amt                      
                  ,0                          -- rtn_loan_int                      
                  ,0                          -- rtn_apl_amt                       
                  ,0                          -- rtn_apl_int                       
                  ,0                          -- prem_susp                         
                  ,0                          -- accumulated_div                   
                  ,0                          -- div_int_balance                   
                  ,0                          -- div_int                           
                  ,d.cp_pay_amt               -- 該月預計給付金額                  
                  ,b.cp_chk_date 
                  ," "                        -- rtn_rece_no 
                  ,d.cp_pay_amt               -- 該月實際給付金額                  
                  ,a.cp_disb_type
                  ,a.mail_addr_ind
                  ,b.dept_code
                  ,b.agent_code
                  ,c.dept_belong
                  ,a.address
                  ,a.zip_code
                  ,b.currency
                  ,"pscu"
                  ,d.payout_date_from         -- 月給付日期
            FROM  pscu d,pscb a,pscp b ,dept c
            WHERE d.change_date  BETWEEN p_rpt_beg_date AND p_rpt_end_date
            AND   d.process_sw   ='1'     -- 已給付 
            AND   d.cp_pay_seq   =1       -- 以第一位受領人資料當成代表
            AND   d.policy_no    =a.policy_no
            AND   d.cp_anniv_date=a.cp_anniv_date
            AND   a.policy_no    =b.policy_no
            AND   a.cp_anniv_date=b.cp_anniv_date
            AND   a.cp_disb_type in ("0","2","3","4","5","6")
            AND   a.cp_sw in ("2","6")
            AND   b.cp_pay_form_type in ("6","6.1","6.2")
            AND   b.dept_code=c.dept_code   
    
    ORDER BY a.cp_disb_type,a.policy_no,a.cp_anniv_date

    START REPORT cp_pay_dtl      TO f_rpt_name_1
    START REPORT cp_pay_dtl_un   TO f_rpt_name_5
    START REPORT cp_pay_dtl_col  TO f_rpt_name_2
    START REPORT cp_pay_unnormal TO f_rpt_name_4
--    START REPORT cp_pay_post     TO f_rpt_name_3
    START REPORT cp_pay_dtl_col_un  TO f_rpt_name_7
    START REPORT cp_pay_dtl_col_50  TO f_rpt_name_8
    START REPORT cp_pay_unnormal_50 TO f_rpt_name_9
    START REPORT cp_pay_dtl_all TO f_rpt_name_10        
    START REPORT cp_pay_dtl_stat TO f_rpt_name_11
    START REPORT cp_pay_dtl_col_usd TO f_rpt_name_12
    START REPORT cp_pay_dtl_usd TO f_rpt_name_13


    FOREACH f_s1 INTO p_cp_pay_detail.* ,f_source, f_payout_date_from
	    
       LET f_have_data="Y"
       LET f_po_issue_date   ="         "

       LET f_agent_code      =" "
       LET f_agent_name      =" "

       LET f_dept_code       =" "
       LET f_dept_name       =" "
       LET f_dept_mail       =" "
       LET f_dept_belong_name=" "

       LET f_applicant_id   =" "
       LET f_applicant_name =" "
       LET f_insured_id     =" "
       LET f_insured_name   =" "

       LET f_zip_code       =" "
       LET f_address        =" "
       LET f_tel_1          =" "

       LET f_plan_desc          =" "
       LET f_cp_chk_sw          =" "
       LET f_cp_notice_print_sw =" "
       LET f_cp_form_desc       ="滿期金"

       -- 105/04/01 月給付險種只揭露每月給付金額，不揭露該年度的還款資訊
       LET f_pay_modx = psc99s01_pay_modx(p_cp_pay_detail.policy_no)
       IF f_source = "pscp" AND f_pay_modx = 1 THEN
          CONTINUE FOREACH
       END IF

       -- 105/04/01 月給付險種根據週月日判斷延遲 
       IF f_pay_modx = 1 THEN
       	  LET f_R3_min_date=SubtractDay(f_payout_date_from,f_var_date)
       ELSE
          LET f_R3_min_date=SubtractDay(p_cp_pay_detail.cp_anniv_date,f_var_date)
       END IF
       
       -- 保單生效日 --
       SELECT  po_issue_date,expired_date,po_sts_code,modx,method
              ,mail_addr_ind
       INTO    f_po_issue_date,f_expired_date,f_po_sts_code
              ,f_modx,f_method
              ,f_polf_mail_addr_ind
       FROM    polf
       WHERE   policy_no=p_cp_pay_detail.policy_no

       ---------------------------------------------------------------
       -- SR:PS88217S pscb 中郵寄為 空白必須參考 polf.mail_addr_ind --
       ---------------------------------------------------------------
       IF p_cp_pay_detail.mail_addr_ind=" " THEN
          LET p_cp_pay_detail.mail_addr_ind=f_polf_mail_addr_ind
       END IF 

       -- 業務員 --
       SELECT  names
       INTO    f_agent_name
       FROM    clnt
       WHERE   client_id=p_cp_pay_detail.agent_code

       -- 要保人ID,姓名 --
       CALL getNames(p_cp_pay_detail.policy_no,'O1') 
            RETURNING f_applicant_id,f_applicant_name

       -- 被保人 --
       SELECT  client_ident
       INTO    f_client_ident
       FROM    colf
       WHERE   policy_no   =p_cp_pay_detail.policy_no
       AND     coverage_no =p_cp_pay_detail.coverage_no

       CALL getNames(p_cp_pay_detail.policy_no,f_client_ident) 
            RETURNING f_insured_id,f_insured_name
       
       -- 營業處 --
       SELECT dept_name  ,dept_mail
       INTO   f_dept_name,f_dept_mail
       FROM   dept
       WHERE  dept_code=p_cp_pay_detail.dept_code

       -- 分公司 --
       SELECT dept_name
       INTO   f_dept_belong_name
       FROM   dept
       WHERE  dept_code=p_cp_pay_detail.dept_belong

       LET f_dept_adm_no=p_cp_pay_detail.dept_belong
       LET f_dept_adm_name=f_dept_belong_name

       -- 險種名稱 --
       SELECT plan_desc
       INTO   f_plan_desc
       FROM   pldf
       WHERE  plan_code =p_cp_pay_detail.plan_code
       AND    rate_scale=p_cp_pay_detail.rate_scale

       -- 要保人電話    --
       SELECT tel_1
       INTO   f_tel_1
       FROM   addr
       WHERE  client_id=f_applicant_id
       AND    addr_ind =p_cp_pay_detail.mail_addr_ind

       -- 郵遞區號,地址 --
       LET f_address       =p_cp_pay_detail.address
       LET f_zip_code      =p_cp_pay_detail.zip_code

       -- 要保人email資訊--

       LET f_ebill_email = ''
       LET f_ebill_zip_ind = ''
       LET f_mobile_o1 = ''
       LET f_ebill_ind = '1'

       SELECT　zip_code[2,2],address,tel_1
       INTO    f_ebill_zip_ind,f_ebill_email,f_mobile_o1
       FROM    addr
       WHERE   client_id=f_applicant_id
       AND     addr_ind = 'E'

       IF  STATUS=NOTFOUND THEN
           LET f_ebill_ind = '1'
       END IF
--display p_cp_pay_detail.policy_no,f_ebill_email[1,50],f_ebill_ind
       IF  f_ebill_email IS NULL OR f_ebill_email = '' THEN
           LET f_ebill_ind = '1'
       ELSE
           IF  f_ebill_zip_ind = '1' THEN
               LET f_ebill_ind = '1'
           ELSE
               LET f_ebill_ind = '0'
           END IF
       END IF


       IF f_expired_date <= p_cp_pay_detail.cp_anniv_date THEN
          LET f_expired_sw="Y"
       ELSE
          LET f_expired_sw="N"
       END IF

       -- 功能碼的判斷  --
       IF f_expired_sw="Y" THEN
          -- 滿期金 --
          LET f_cp_form_desc="滿期金"
          CASE
              WHEN p_cp_pay_detail.cp_disb_type="0"   -- 郵寄支票 --
                  LET f_2141_have_data="Y"
                  LET f_function_code="R1"
                  LET f_pay_desc="應給付淨額"
              WHEN p_cp_pay_detail.cp_disb_type="1"   -- 櫃台領取 --
                  LET f_function_code="RB"
                  LET f_pay_desc="應給付淨額"
              WHEN p_cp_pay_detail.cp_disb_type="2"   -- 抵繳保費 --
                  LET f_2825_have_data="Y"
                  LET f_function_code="R3"
                  LET f_pay_desc="  抵繳保費"
              WHEN p_cp_pay_detail.cp_disb_type="3"   -- 電    匯 --
                  LET f_pay_desc="  電匯金額"
                  IF f_R3_min_date < p_cp_pay_detail.process_date THEN
                     LET f_function_code="R8"
                  ELSE
                     LET f_function_code="R7"
                  END IF
              WHEN p_cp_pay_detail.cp_disb_type="4"   -- 未回領取 --
                  LET f_agnt_have_data="Y"
                  LET f_function_code="R5"
                  LET f_pay_desc="應給付淨額"
              WHEN p_cp_pay_detail.cp_disb_type="5"   -- 主動電匯 --
                  LET f_pay_desc="  主動電匯"
                  IF f_R3_min_date < p_cp_pay_detail.process_date THEN
                     LET f_function_code="R8-主動"          
                  ELSE
                     LET f_function_code="R7-主動"
                  END IF
              WHEN p_cp_pay_detail.cp_disb_type="6"   -- 還本回流 --
--                  LET f_0027_have_data="Y"
                  LET f_pay_desc="  還本回流"
                  LET f_function_code="RJ"
                  IF p_cp_pay_detail.process_date >
                     p_cp_pay_detail.cp_anniv_date THEN
                     LET f_0027_unnormal="Y"
                  ELSE
                     LET f_0027_have_data="Y"
                  END IF

          END CASE
       ELSE
          -- 生存金 --
          LET f_cp_form_desc="      "
          CASE
              WHEN p_cp_pay_detail.cp_disb_type="0"   -- 郵寄支票 --
                  LET f_2141_have_data="Y"
                  LET f_function_code="R2"
                  LET f_pay_desc="應給付淨額"
              WHEN p_cp_pay_detail.cp_disb_type="1"   -- 櫃台領取 --
                  LET f_function_code="RC"
                  LET f_pay_desc="應給付淨額"
              WHEN p_cp_pay_detail.cp_disb_type="2"   -- 抵繳保費 --
                  LET f_2825_have_data="Y"
                  LET f_pay_desc="  抵繳金額"
                  LET f_function_code="R4"
              WHEN p_cp_pay_detail.cp_disb_type="3"   -- 電    匯 --
                  LET f_pay_desc="  電匯金額"
                  IF f_R3_min_date < p_cp_pay_detail.process_date THEN
                     LET f_2143_unnormal="Y"
                     LET f_function_code="RA"
                  ELSE
                     LET f_2143_have_data="Y"
                     LET f_function_code="R9"
                  END IF
              WHEN p_cp_pay_detail.cp_disb_type="4"   -- 未回領取 --
                  LET f_agnt_have_data="Y"
                  LET f_pay_desc="應給付淨額"
                  LET f_function_code="R6"
              WHEN p_cp_pay_detail.cp_disb_type="6"   -- 還本回流 --
                  LET f_0027_have_data="Y"
                  LET f_pay_desc="  還本回流"
                  LET f_function_code="RK"
                  IF p_cp_pay_detail.process_date >
                     p_cp_pay_detail.cp_anniv_date THEN
                     LET f_0027_unnormal="Y"
                  END IF

          END CASE
       END IF -- 功能碼的判斷 --
       {
       -- 保單要保人地址 --
       SELECT address,zip_code
       INTO   f_address,f_zip_code
       FROM   addr
       WHERE  client_id=f_applicant_id
       AND    addr_ind =p_cp_pay_detail.mail_addr_ind

       IF f_address IS NULL OR
          f_address =  " "  THEN
          LET f_address="找不到地址"
       END IF

       IF f_zip_code IS NULL OR
          f_zip_code = " "   THEN
          LET f_zip_code="non"
       END IF
       }
       
       -- 受益人 --
       FOR f_i = 1 TO 10
           LET f_benf_id[f_i]    = NULL
           LET f_benf_name[f_i]  = NULL
       END FOR
       LET f_benf_name_all       = NULL

       LET f_i = 1       
       
       -- 105/04/01 月給付改從pscu抓資料
       IF f_pay_modx = 1 THEN
       	  DECLARE pscu_cur_1 CURSOR FOR
             SELECT client_id, names
             FROM   pscu
             WHERE  policy_no        = p_cp_pay_detail.policy_no
             AND    cp_anniv_date    = p_cp_pay_detail.cp_anniv_date
             AND    payout_date_from = f_payout_date_from
             ORDER BY cp_pay_seq
          FOREACH pscu_cur_1 INTO f_benf_id[f_i],f_benf_name[f_i]
       	     IF f_i=1 THEN
                LET f_benf_name_all=f_benf_name[f_i]
             ELSE
                LET f_benf_name_all=f_benf_name_all CLIPPED," ",f_benf_name[f_i]
             END IF
             LET f_i = f_i + 1
          END FOREACH
       ELSE       
       
          DECLARE benf_cur CURSOR FOR
             SELECT client_id, names
             FROM   benf
             WHERE  policy_no   = p_cp_pay_detail.policy_no
             AND    coverage_no = 0
             AND    relation    = "M"
          FOREACH benf_cur INTO f_benf_id[f_i]
                               ,f_benf_name[f_i]
             IF length(f_benf_id[f_i] CLIPPED) !=0 THEN
                SELECT names INTO f_benf_name[f_i]
                FROM   clnt
                WHERE  client_id=f_benf_id[f_i]
             END IF
          
             IF f_i=1 THEN
                LET f_benf_name_all=f_benf_name[f_i]
             ELSE
                LET f_benf_name_all=f_benf_name_all CLIPPED," ",f_benf_name[f_i]
             END IF
          
             LET f_i = f_i + 1
          END FOREACH
       END IF
       
       IF f_benf_name[1] IS NULL THEN
          IF f_benf_id[1] IS NULL THEN
             LET f_benf_name[1]=f_applicant_name
             LET f_benf_name_all=f_applicant_name
          ELSE
             SELECT names
             INTO   f_benf_name[1]
             FROM   clnt
             WHERE  client_id=f_benf_id[1]

             LET f_benf_name_all=f_benf_name[1]
          END IF
       END IF

       IF p_cp_pay_detail.cp_disb_type="0" THEN
          LET f_note_recv_name=f_benf_name[1]
       ELSE
          LET f_note_recv_name=f_applicant_name
       END IF

       LET f_pscd_cmd="SELECT  * FROM pscd "
                     ,"WHERE policy_no= ?  "
                     ,"AND   cp_anniv_date= ?"
                     ,"ORDER BY cp_pay_seq"

       PREPARE pscd_pre FROM f_pscd_cmd
       DECLARE pscd_cur CURSOR FOR pscd_pre
 
       LET f_pscx_cmd="SELECT  * FROM pscx "
                     ,"WHERE policy_no= ?  "
                     ,"AND   cp_anniv_date= ?"
                     ,"ORDER BY cp_pay_seq"

       PREPARE pscx_pre FROM f_pscx_cmd
       DECLARE pscx_cur CURSOR FOR pscx_pre


       FOR f_i=1 TO 99
           LET p_pscd_r[f_i].policy_no     =" "
           LET p_pscd_r[f_i].cp_anniv_date ="   /  /  "
           LET p_pscd_r[f_i].cp_pay_cnt    =0
           LET p_pscd_r[f_i].cp_pay_seq    =0
           LET p_pscd_r[f_i].currency      =" " 
           LET p_pscd_r[f_i].cp_pay_amt    =0
           LET p_pscd_r[f_i].names         =" "
           LEt p_pscd_r[f_i].benf_ratio    =0
           LET p_pscd_r[f_i].cp_real_payamt=0
           LET p_pscd_r[f_i].remit_bank    =" "
           LET p_pscd_r[f_i].remit_account =" "
           LET p_pscd_r[f_i].disb_no       =" "
      
           LET p_pscx_r[f_i].policy_no     =" "
           LET p_pscx_r[f_i].cp_anniv_date ="   /  /  "
           LET p_pscx_r[f_i].cp_pay_cnt    =0
           LET p_pscx_r[f_i].cp_pay_seq    =0
           LET p_pscx_r[f_i].cp_pay_amt    =0
           LET p_pscx_r[f_i].names         =" "
           LEt p_pscx_r[f_i].benf_ratio    =0
           LET p_pscx_r[f_i].cp_real_payamt=0
           LET p_pscx_r[f_i].bank_code     =" "
           LET p_pscx_r[f_i].bank_account_e  =" "
           LET p_pscx_r[f_i].payee_e       =" "
           LET p_pscx_r[f_i].disb_no       =" "

       END FOR

       LET f_i=0
       LET f_pscd_cnt=0

       -- 105/04/01 月給付改從pscu抓資料
       IF f_pay_modx = 1 THEN
 DECLARE pscu_cur_2 CURSOR FOR
             SELECT *
             FROM   pscu
             WHERE  policy_no        = p_cp_pay_detail.policy_no
             AND    cp_anniv_date    = p_cp_pay_detail.cp_anniv_date
             AND    payout_date_from = f_payout_date_from
             ORDER BY cp_pay_seq     
          FOREACH pscu_cur_2 INTO f_pscu.*
          	
          	 LET f_i=f_i+1
          	 
          	 IF f_pscu.currency = 'TWD' THEN
                LET p_pscd_r[f_i].policy_no           = f_pscu.policy_no        
                LET p_pscd_r[f_i].cp_anniv_date       = f_pscu.cp_anniv_date    
                LET p_pscd_r[f_i].cp_pay_cnt          = f_pscu.cp_pay_cnt       
                LET p_pscd_r[f_i].cp_pay_seq          = f_pscu.cp_pay_seq       
                LET p_pscd_r[f_i].currency            = f_pscu.currency         
                LET p_pscd_r[f_i].cp_pay_amt          = f_pscu.cp_pay_amt       
                LET p_pscd_r[f_i].names               = f_pscu.names            
                LET p_pscd_r[f_i].benf_ratio          = f_pscu.benf_ratio       
                LET p_pscd_r[f_i].cp_real_payamt      = f_pscu.cp_real_payamt   
                LET p_pscd_r[f_i].remit_bank          = f_pscu.remit_bank       
                LET p_pscd_r[f_i].remit_branch        = f_pscu.remit_branch     
                LET p_pscd_r[f_i].remit_account       = f_pscu.remit_account    
                LET p_pscd_r[f_i].disb_no             = f_pscu.disb_no          
                LET p_pscd_r[f_i].client_id           = f_pscu.client_id        
             ELSE                       
                LET p_pscx_r[f_i].policy_no           = f_pscu.policy_no       
                LET p_pscx_r[f_i].cp_anniv_date       = f_pscu.cp_anniv_date   
                LET p_pscx_r[f_i].cp_pay_cnt          = f_pscu.cp_pay_cnt      
                LET p_pscx_r[f_i].cp_pay_seq          = f_pscu.cp_pay_seq      
                LET p_pscx_r[f_i].currency            = f_pscu.currency        
                LET p_pscx_r[f_i].cp_pay_amt          = f_pscu.cp_pay_amt      
                LET p_pscx_r[f_i].client_id           = f_pscu.client_id       
                LET p_pscx_r[f_i].names               = f_pscu.names           
                LET p_pscx_r[f_i].benf_ratio          = f_pscu.benf_ratio      
                LET p_pscx_r[f_i].cp_real_payamt      = f_pscu.cp_real_payamt  
                LET p_pscx_r[f_i].bank_code           = f_pscu.bank_code       
                LET p_pscx_r[f_i].swift_code          = f_pscu.swift_code      
                LET p_pscx_r[f_i].bank_name_e         = f_pscu.bank_name_e     
                LET p_pscx_r[f_i].bank_account_e      = f_pscu.bank_account_e  
                LET p_pscx_r[f_i].payee_e             = f_pscu.payee_e         
                LET p_pscx_r[f_i].bank_address_e      = f_pscu.bank_address_e  
                LET p_pscx_r[f_i].disb_no             = f_pscu.disb_no         
             END IF
          	 
             INITIALIZE f_pscu.* TO NULL
          END FOREACH
          
          IF f_i=0 THEN -- 無受益人 
             LET f_cp_pay_detail_sw="0"
          ELSE
             LET f_cp_pay_detail_sw="1"
          END IF
          LET f_pscd_cnt=f_i
       ELSE
           OPEN pscd_cur USING p_cp_pay_detail.policy_no
                              ,p_cp_pay_detail.cp_anniv_date
           WHILE 1=1
               LET f_i=f_i+1
               FETCH pscd_cur INTO p_pscd_r[f_i].*
               IF STATUS=NOTFOUND THEN
                  EXIT WHILE
               END IF
           END WHILE
           CLOSE pscd_cur 
           
           LET f_j=0
           
           OPEN pscx_cur USING p_cp_pay_detail.policy_no
                              ,p_cp_pay_detail.cp_anniv_date
           
           WHILE 1=1
               LET f_j=f_j+1
               FETCH pscx_cur INTO p_pscx_r[f_j].*
               IF STATUS=NOTFOUND THEN
                  EXIT WHILE
               END IF
           END WHILE
           CLOSE pscx_cur
           
           IF p_cp_pay_detail.currency = 'TWD' THEN
              IF f_i=1 THEN
                 LET f_cp_pay_detail_sw="0"
              ELSE
                 LET f_cp_pay_detail_sw="1"
                 LET f_pscd_cnt=f_i-1
              END IF
           ELSE
              IF f_j=1 THEN
                 LET f_cp_pay_detail_sw="0"
              ELSE
                 LET f_cp_pay_detail_sw="1"
                 LET f_pscd_cnt=f_j-1
              END IF
           END IF
       END IF
       
       IF ill_addr(p_cp_pay_detail.policy_no, f_applicant_id, f_polf_mail_addr_ind, 2, g_program_id, p_rpt_beg_date, p_rpt_end_date ) THEN
          LET f_pmia_sw = "Y"
        --  display 'policy_no_y=', p_cp_pay_detail.policy_no, ' applicant_id=', f_applicant_id, ' addr_ind=', f_polf_mail_addr_ind, ' pmia=', f_pmia_sw
       ELSE
          LET f_pmia_sw = " "
        --  display 'policy_no_n=', p_cp_pay_detail.policy_no, ' applicant_id=', f_applicant_id, ' addr_ind=', f_polf_mail_addr_ind, ' pmia=', f_pmia_sw
       END IF
       --SR120800390 cmwang 101/09 將e_bill 格式內容放在g_ebill_format變數中
       CALL oms_ebill_format(f_dept_code,f_mobile_o1,f_ebill_email[1,50]
                            ,f_ebill_ind,f_applicant_name,f_applicant_id
                            ,p_cp_pay_detail.policy_no)
       --------------
       OUTPUT TO REPORT cp_pay_dtl_all (                                                                   
                              p_cp_pay_detail.policy_no                                                 
                             ,f_benf_name_all                                                           
                             ,p_cp_pay_detail.cp_anniv_date                                             
                             ,p_cp_pay_detail.plan_code                                                 
                             ,p_cp_pay_detail.face_amt                                                  
                             ,p_cp_pay_detail.cp_amt                                                    
                             ,p_cp_pay_detail.cp_pay_amt                                                
                             ,f_ebill_ind                     -- ebill指示                              
                             ,f_pmia_sw                       -- 無效地址指示                           
                             )                                                                          

      IF f_function_code = 'R1' OR
         f_function_code = 'R3' OR
         f_function_code = 'R5' THEN
         LET f_fn_code_desc = f_function_code
         LET f_sub_stat = 'S1'
      ELSE
         IF f_function_code = 'R7' THEN
            IF p_cp_pay_detail.cp_pay_amt < 1000000 THEN
               LET f_fn_code_desc = 'R7<100萬'
            ELSE
               LET f_fn_code_desc = 'R7>=100萬'
            END IF
            LET f_sub_stat = 'S2'
         ELSE
            IF f_function_code = 'R7-主動' THEN
               IF p_cp_pay_detail.cp_pay_amt < 1000000 THEN
                  LET f_fn_code_desc = 'R7-主動<100萬'
               ELSE
                  LET f_fn_code_desc = 'R7-主動>=100萬'
               END IF
               LET f_sub_stat = 'S3'
            ELSE
               IF f_function_code = 'R8' THEN
                  IF p_cp_pay_detail.cp_pay_amt < 1000000 THEN
                     LET f_fn_code_desc = 'R8<100萬'
                  ELSE
                     LET f_fn_code_desc = 'R8>=100萬'
                  END IF
                  LET f_sub_stat = 'S4'
               ELSE
                  IF f_function_code = 'R8-主動' THEN
                     IF p_cp_pay_detail.cp_pay_amt < 1000000 THEN
                        LET f_fn_code_desc = 'R8-主動<100萬'
                     ELSE
                        LET f_fn_code_desc = 'R8-主動>=100萬'
                     END IF
                     LET f_sub_stat = 'S5'
                  ELSE
                     IF f_function_code='RK' THEN
                        LET f_fn_code_desc = 'RK-回流'
                        LET f_sub_stat = 'S6'
                     ELSE
                        LET f_fn_code_desc = 'OTH'
                        LET f_sub_stat = 'S7'
                     END IF
                  END IF
               END IF
            END IF
         END IF
      END IF
      OUTPUT TO REPORT cp_pay_dtl_stat (
                                p_cp_pay_detail.currency,
                                f_fn_code_desc,
                                f_sub_stat,
                                p_cp_pay_detail.cp_amt
                                )
          IF p_cp_pay_detail.currency != 'TWD' THEN
        IF f_ebill_ind = "1" AND f_pmia_sw = "Y" THEN
        ELSE
           OUTPUT TO REPORT cp_pay_dtl_usd    (p_cp_pay_detail.cp_pay_form_type
                                             ,p_cp_pay_detail.policy_no
                                             ,p_cp_pay_detail.cp_anniv_date
                                             ,f_zip_code
                                             ,f_address
                                             ,f_applicant_name
                                             ,f_insured_name
                                             ,f_tel_1
                                             ,f_dept_name
                                             ,f_plan_desc
                                             ,f_cp_pay_detail_sw
                                             ,f_benf_name_all
                                             ,p_cp_pay_detail.cp_disb_type
                                             ,f_pay_desc
                                             ,f_note_recv_name
                                             ,f_dept_adm_name
                                             ,f_pscd_cnt
                                             ,p_cp_pay_detail.dept_code
                                             ,f_mobile_o1
                                             ,f_ebill_ind
                                             ,f_ebill_email
                                             )
        END IF
        LET f_data_col_usd = "Y"
        OUTPUT TO REPORT cp_pay_dtl_col_usd (f_have_data
                                             ,p_cp_pay_detail.cp_pay_form_type
                                             ,p_cp_pay_detail.policy_no
                                             ,p_cp_pay_detail.cp_anniv_date
                                             ,f_applicant_name
                                             ,f_dept_name
                                             ,f_cp_pay_detail_sw
                                             ,p_cp_pay_detail.cp_disb_type
                                             ,f_note_recv_name
                                             ,f_agent_name
                                             ,f_pscd_cnt
                                             ,f_po_sts_code
                                             ,f_modx
                                             ,f_method
                                             ,f_function_code
                                             ,p_cp_pay_detail.*
                                             )


     ELSE
                                                                                              

       IF f_function_code NOT MATCHES "R[JK815]*" 
       THEN
       display 'policy_no=', p_cp_pay_detail.policy_no, ' applicant_id=', f_applicant_id, ' addr_ind=', f_polf_mail_addr_ind, ' pmia=', f_pmia_sw
          IF f_ebill_ind = "1" AND f_pmia_sw = "Y" THEN
         --    display 'address_R[JK8]不郵寄1=', f_address, ' pmia_y=', f_pmia_sw
          ELSE
             OUTPUT TO REPORT cp_pay_dtl   (p_cp_pay_detail.cp_pay_form_type
                                        ,p_cp_pay_detail.policy_no
                                        ,p_cp_pay_detail.cp_anniv_date
                                        ,f_zip_code
                                        ,f_address
                                        ,f_applicant_name
                                        ,f_insured_name
                                        ,f_tel_1
                                        ,f_dept_name
                                        ,f_plan_desc
                                        ,f_cp_pay_detail_sw
                                        ,f_benf_name_all
                                        ,p_cp_pay_detail.cp_disb_type
                                        ,f_pay_desc
                                        ,f_note_recv_name
                                        ,f_dept_adm_name
                                        ,f_pscd_cnt
                                        ,p_cp_pay_detail.dept_belong
                                        ,p_cp_pay_detail.dept_code
                                        ,f_mobile_o1
                                        ,f_ebill_ind
                                        ,f_ebill_email
                                        )
         --   display 'addressR[JK8]要郵寄1=', f_address, ' pmia_n=', f_pmia_sw
          END IF

       END IF

       IF f_function_code MATCHES "R8*" THEN
       display 'policy_no=', p_cp_pay_detail.policy_no, ' applicant_id=', f_applicant_id, ' addr_ind=', f_polf_mail_addr_ind, ' pmia=', f_pmia_sw
          -- 延遲電匯-滿期金的給付明細表 --
          IF f_ebill_ind = "1" AND f_pmia_sw = "Y" THEN
            -- display 'address_R8不郵寄5=', f_address, ' pmia_y=', f_pmia_sw
          ELSE
             OUTPUT TO REPORT cp_pay_dtl_un (p_cp_pay_detail.cp_pay_form_type
                                            ,p_cp_pay_detail.policy_no
                                            ,p_cp_pay_detail.cp_anniv_date
                                            ,f_zip_code
                                            ,f_address
                                            ,f_applicant_name
                                            ,f_insured_name
                                            ,f_tel_1
                                            ,f_dept_name
                                            ,f_plan_desc
                                            ,f_cp_pay_detail_sw
                                            ,f_benf_name_all
                                            ,p_cp_pay_detail.cp_disb_type
                                            ,f_pay_desc
                                            ,f_note_recv_name
                                            ,f_dept_adm_name
                                            ,f_pscd_cnt
                                            ,p_cp_pay_detail.dept_belong
                                            ,p_cp_pay_detail.dept_code
                                            ,f_mobile_o1
                                            ,f_ebill_ind
                                            ,f_ebill_email
                                            )

           --    display 'address_R8要郵寄5=', f_address, ' pmia_y=', f_pmia_sw
          END IF

          -- 延遲電匯-滿期金的給付控制表 --
             IF p_cp_pay_detail.cp_pay_amt < 1000000 THEN

                IF p_cp_pay_detail.cp_disb_type = '3' THEN
                   LET  f_2143_unnormal = "Y"
                END IF

                IF p_cp_pay_detail.cp_disb_type = '5' THEN
                   LET  f_cp5_unnormal = "Y"
                END IF

                OUTPUT TO REPORT cp_pay_unnormal (f_have_data
                                        ,p_cp_pay_detail.cp_pay_form_type
                                        ,p_cp_pay_detail.policy_no
                                        ,p_cp_pay_detail.cp_anniv_date
                                        ,f_applicant_name
                                        ,f_dept_name
                                        ,f_cp_pay_detail_sw
                                        ,p_cp_pay_detail.cp_disb_type
                                        ,f_note_recv_name
                                        ,f_agent_name
                                        ,f_pscd_cnt
                                        ,f_po_sts_code
                                        ,f_modx
                                        ,f_method
                                        ,p_cp_pay_detail.dept_belong
                                        ,f_dept_adm_name
                                        ,f_function_code
                                        ,f_payout_date_from
                                        )
             ELSE
                IF p_cp_pay_detail.cp_disb_type = '3' THEN
                   LET  f_2143_unnormal_50 = "Y"
                END IF

                IF p_cp_pay_detail.cp_disb_type = '5' THEN
                   LET  f_cp5_unnormal_50 = "Y"
                END IF

                OUTPUT TO REPORT cp_pay_unnormal_50 (f_have_data
                                        ,p_cp_pay_detail.cp_pay_form_type
                                        ,p_cp_pay_detail.policy_no
                                        ,p_cp_pay_detail.cp_anniv_date
                                        ,f_applicant_name
                                        ,f_dept_name
                                        ,f_cp_pay_detail_sw
                                        ,p_cp_pay_detail.cp_disb_type
                                        ,f_note_recv_name
                                        ,f_agent_name
                                        ,f_pscd_cnt
                                        ,f_po_sts_code
                                        ,f_modx
                                        ,f_method
                                        ,p_cp_pay_detail.dept_belong
                                        ,f_dept_adm_name
                                        ,f_function_code
                                        )
                END IF

       ELSE

             IF f_function_code MATCHES 'R[JK]' AND
                p_cp_pay_detail.cp_anniv_date < p_cp_pay_detail.process_date THEN



                OUTPUT TO REPORT cp_pay_dtl_col_un
                                       (f_have_data
                                       ,p_cp_pay_detail.cp_pay_form_type
                                       ,p_cp_pay_detail.policy_no
                                       ,p_cp_pay_detail.cp_anniv_date
                                       ,f_applicant_name
                                       ,f_dept_name
                                       ,f_cp_pay_detail_sw
                                       ,p_cp_pay_detail.cp_disb_type
                                       ,f_note_recv_name
                                       ,f_agent_name
                                       ,f_pscd_cnt
                                       ,f_po_sts_code
                                       ,f_modx
                                       ,f_method
                                       ,p_cp_pay_detail.dept_belong
                                       ,f_dept_adm_name
                                       ,f_function_code
                                       )


             ELSE
             -- 一般電匯-滿期金的給付控制表 --
                IF
                  (
                   p_cp_pay_detail.cp_pay_amt < 1000000
                   AND
                   p_cp_pay_detail.cp_disb_type MATCHES "[35]"
                  )
                  OR
                  p_cp_pay_detail.cp_disb_type NOT MATCHES "[35]"
                THEN

                    IF p_cp_pay_detail.cp_disb_type = '3' THEN
                       LET f_2143_have_data = "Y"
                    END IF
    
                    IF p_cp_pay_detail.cp_disb_type = '5' THEN
                       LET  f_cp5_have_data = "Y"
                    END IF
                    OUTPUT TO REPORT cp_pay_dtl_col (f_have_data
                                       ,p_cp_pay_detail.cp_pay_form_type
                                       ,p_cp_pay_detail.policy_no
                                       ,p_cp_pay_detail.cp_anniv_date
                                       ,f_applicant_name
                                       ,f_dept_name
                                       ,f_cp_pay_detail_sw
                                       ,p_cp_pay_detail.cp_disb_type
                                       ,f_note_recv_name
                                       ,f_agent_name
                                       ,f_pscd_cnt
                                       ,f_po_sts_code
                                       ,f_modx
                                       ,f_method
                                       ,p_cp_pay_detail.dept_belong
                                       ,f_dept_adm_name
                                       ,f_function_code
                                       ,f_payout_date_from
                                       )


              
                END IF

                IF p_cp_pay_detail.cp_pay_amt >= 1000000
                   AND
                   p_cp_pay_detail.cp_disb_type MATCHES "[35]"
                THEN

                    IF p_cp_pay_detail.cp_disb_type = '3' THEN
                       LET f_2143_have_data_50 = "Y"
                    END IF
    
                    IF p_cp_pay_detail.cp_disb_type = '5' THEN
                       LET  f_cp5_have_data_50 = "Y"
                    END IF

                    OUTPUT TO REPORT cp_pay_dtl_col_50 (f_have_data
                                       ,p_cp_pay_detail.cp_pay_form_type
                                       ,p_cp_pay_detail.policy_no
                                       ,p_cp_pay_detail.cp_anniv_date
                                       ,f_applicant_name
                                       ,f_dept_name
                                       ,f_cp_pay_detail_sw
                                       ,p_cp_pay_detail.cp_disb_type
                                       ,f_note_recv_name
                                       ,f_agent_name
                                       ,f_pscd_cnt
                                       ,f_po_sts_code
                                       ,f_modx
                                       ,f_method
                                       ,p_cp_pay_detail.dept_belong
                                       ,f_dept_adm_name
                                       ,f_function_code
                                       )
                END IF
           END IF
       END IF

      -- 大宗掛號函 --
      IF p_cp_pay_detail.cp_disb_type ="0"  OR
         p_cp_pay_detail.cp_disb_type ="4"  THEN

         IF f_cp_pay_detail_sw="1" THEN
            IF  p_batch_no_pm > 0 THEN
                 LET f_j = 1
                 FOR f_j = 1 TO f_pscd_cnt
                     IF  p_pscd_r[f_j].cp_real_payamt !=0 AND p_cp_pay_detail.cp_disb_type != '4' THEN
                         LET p_pmms.recipient_type = "3"
                         LET p_pmms.addr_type_pm = "4"
                         LET f_item_no = f_item_no + 1
                         LET p_pmms.batch_no_pm = p_batch_no_pm
                         LET p_pmms.docu_item_no = f_item_no
                         LET p_pmms.mail_reg_no = " "
                         LET p_pmms.policy_no = p_cp_pay_detail.policy_no
                         LET p_pmms.recipient = f_benf_name[f_j]
                         LET p_pmms.zip_code = f_zip_code
                         LET p_pmms.address  = f_address
                         LET p_pmms.mail_type = "1"
                         LET p_pmms.docu_type_pm = "016"
                         LET p_pmms.dept_code = '90000'
                         LET p_pmms.access_user = "oper"
                         LET p_pmms.input_date = p_rpt_end_date
                         LET p_pmms.mail_user = " "
                         LET p_pmms.mail_date = " "
                         LET p_pmms.pmms_sts_code = "1"
                         LET p_pmms.process_date = GetDate(TODAY)
                         LET p_pmms.process_time = TIME

                         INSERT INTO pmms VALUES(p_pmms.*)
                         IF  SQLCA.SQLCODE != 0 THEN
                             DISPLAY "pmms insert 失敗 !!"
                         END IF
                         INITIALIZE p_pmms.* TO NULL
                     END IF
                 END FOR
             END IF

{
            OUTPUT TO REPORT cp_pay_post (p_cp_pay_detail.cp_pay_form_type
                                         ,p_cp_pay_detail.policy_no
                                         ,p_cp_pay_detail.cp_anniv_date
                                         ,f_zip_code
                                         ,f_address
                                         ,f_applicant_name
                                         ,p_cp_pay_detail.cp_disb_type
                                         ,f_benf_name[1]
                                         ,f_benf_name[2]
                                         ,f_benf_name[3]
                                         ,f_benf_name[4]
                                         ,f_pscd_cnt
                                         )
}
         END IF
      END IF

       IF p_batch_no_pm > 0 THEN                            ----大宗掛號需求 by yirong 95/01
          LET p_cmd = "/prod/run/pm011r.4ge ",p_batch_no_pm," ",f_rpt_name_6  --上線後開啟
--          LET p_cmd = "/devp/run/pm011r.4ge ",p_batch_no_pm," ",f_rpt_name_6  --測試用
--          RUN p_cmd
       END IF
    END IF
    END FOREACH

    FREE f_s1

    -- 郵寄支票,無資料 --
    IF f_2141_have_data="N" THEN
       LET f_function_code="R1"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no       =""
       LET p_cp_pay_detail.cp_anniv_date   =""
       LET f_applicant_name                =""
       LET f_dept_name                     =""
       LET f_cp_pay_detail_sw              ="0"
       LET p_cp_pay_detail.cp_disb_type    ="0"
       LET f_note_recv_name                =""
       LET f_agent_name                    =""
       LET f_pscd_cnt                      =0
       LET f_po_sts_code                   =""
       LET f_modx                          =0
       LET f_method                        =""
       LET p_cp_pay_detail.dept_belong     =""
       LET f_dept_adm_name                 =""
        
       OUTPUT TO REPORT cp_pay_dtl_col (f_have_data
                                       ,p_cp_pay_detail.cp_pay_form_type
                                       ,p_cp_pay_detail.policy_no
                                       ,p_cp_pay_detail.cp_anniv_date
                                       ,f_applicant_name
                                       ,f_dept_name
                                       ,f_cp_pay_detail_sw
                                       ,p_cp_pay_detail.cp_disb_type
                                       ,f_note_recv_name
                                       ,f_agent_name
                                       ,f_pscd_cnt
                                       ,f_po_sts_code
                                       ,f_modx
                                       ,f_method
                                       ,p_cp_pay_detail.dept_belong
                                       ,f_dept_adm_name
                                       ,f_function_code
                                       ,f_payout_date_from
                                       )
 
    END IF
    -- 未回覆領取,無資料 --
    IF f_agnt_have_data="N" THEN
       LET f_function_code="R5"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="4"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0 
 
       OUTPUT TO REPORT cp_pay_dtl_col (f_have_data
                                       ,p_cp_pay_detail.cp_pay_form_type
                                       ,p_cp_pay_detail.policy_no
                                       ,p_cp_pay_detail.cp_anniv_date
                                       ,f_applicant_name
                                       ,f_dept_name
                                       ,f_cp_pay_detail_sw
                                       ,p_cp_pay_detail.cp_disb_type
                                       ,f_note_recv_name
                                       ,f_agent_name
                                       ,f_pscd_cnt
                                       ,f_po_sts_code
                                       ,f_modx
                                       ,f_method
                                       ,p_cp_pay_detail.dept_belong
                                       ,f_dept_adm_name
                                       ,f_function_code
                                       ,f_payout_date_from
                                       )

       
    END IF

    -- 抵繳保費,無資料 --
    IF f_2825_have_data="N" THEN
       LET f_function_code="R3"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="2"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0 
 
       OUTPUT TO REPORT cp_pay_dtl_col (f_have_data
                                       ,p_cp_pay_detail.cp_pay_form_type
                                       ,p_cp_pay_detail.policy_no
                                       ,p_cp_pay_detail.cp_anniv_date
                                       ,f_applicant_name
                                       ,f_dept_name
                                       ,f_cp_pay_detail_sw
                                       ,p_cp_pay_detail.cp_disb_type
                                       ,f_note_recv_name
                                       ,f_agent_name
                                       ,f_pscd_cnt
                                       ,f_po_sts_code
                                       ,f_modx
                                       ,f_method
                                       ,p_cp_pay_detail.dept_belong
                                       ,f_dept_adm_name
                                       ,f_function_code
                                       ,f_payout_date_from
                                       )

       
    END IF

    -- 一般電匯,無資料 --
    IF f_2143_have_data="N" THEN
       LET f_function_code="R7"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="3"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0 
 
       OUTPUT TO REPORT cp_pay_dtl_col (f_have_data
                                       ,p_cp_pay_detail.cp_pay_form_type
                                       ,p_cp_pay_detail.policy_no
                                       ,p_cp_pay_detail.cp_anniv_date
                                       ,f_applicant_name
                                       ,f_dept_name
                                       ,f_cp_pay_detail_sw
                                       ,p_cp_pay_detail.cp_disb_type
                                       ,f_note_recv_name
                                       ,f_agent_name
                                       ,f_pscd_cnt
                                       ,f_po_sts_code
                                       ,f_modx
                                       ,f_method
                                       ,p_cp_pay_detail.dept_belong
                                       ,f_dept_adm_name
                                       ,f_function_code
                                       ,f_payout_date_from
                                       )

       
    END IF
    IF f_2143_have_data_50="N" THEN
       LET f_function_code="R7"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="3"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0

       OUTPUT TO REPORT cp_pay_dtl_col_50 (f_have_data
                                       ,p_cp_pay_detail.cp_pay_form_type
                                       ,p_cp_pay_detail.policy_no
                                       ,p_cp_pay_detail.cp_anniv_date
                                       ,f_applicant_name
                                       ,f_dept_name
                                       ,f_cp_pay_detail_sw
                                       ,p_cp_pay_detail.cp_disb_type
                                       ,f_note_recv_name
                                       ,f_agent_name
                                       ,f_pscd_cnt
                                       ,f_po_sts_code
                                       ,f_modx
                                       ,f_method
                                       ,p_cp_pay_detail.dept_belong
                                       ,f_dept_adm_name
                                       ,f_function_code
                                       )


    END IF

    -- 一般主動電匯,無資料 --
    IF f_cp5_have_data="N" THEN
       LET f_function_code="R7-主動"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="5"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0 
 
       OUTPUT TO REPORT cp_pay_dtl_col (f_have_data
                                       ,p_cp_pay_detail.cp_pay_form_type
                                       ,p_cp_pay_detail.policy_no
                                       ,p_cp_pay_detail.cp_anniv_date
                                       ,f_applicant_name
                                       ,f_dept_name
                                       ,f_cp_pay_detail_sw
                                       ,p_cp_pay_detail.cp_disb_type
                                       ,f_note_recv_name
                                       ,f_agent_name
                                       ,f_pscd_cnt
                                       ,f_po_sts_code
                                       ,f_modx
                                       ,f_method
                                       ,p_cp_pay_detail.dept_belong
                                       ,f_dept_adm_name
                                       ,f_function_code
                                       ,f_payout_date_from
                                       )

       
    END IF
    IF f_cp5_have_data_50="N" THEN
       LET f_function_code="R7-主動"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="5"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0

       OUTPUT TO REPORT cp_pay_dtl_col_50 (f_have_data
                                       ,p_cp_pay_detail.cp_pay_form_type
                                       ,p_cp_pay_detail.policy_no
                                       ,p_cp_pay_detail.cp_anniv_date
                                       ,f_applicant_name
                                       ,f_dept_name
                                       ,f_cp_pay_detail_sw
                                       ,p_cp_pay_detail.cp_disb_type
                                       ,f_note_recv_name
                                       ,f_agent_name
                                       ,f_pscd_cnt
                                       ,f_po_sts_code
                                       ,f_modx
                                       ,f_method
                                       ,p_cp_pay_detail.dept_belong
                                       ,f_dept_adm_name
                                       ,f_function_code
                                       )


    END IF


    
    -- 無還本回流 --
    IF f_0027_have_data="N" THEN
       LET f_function_code="RJ"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="6"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0

       OUTPUT TO REPORT cp_pay_dtl_col (f_have_data
                                       ,p_cp_pay_detail.cp_pay_form_type
                                       ,p_cp_pay_detail.policy_no
                                       ,p_cp_pay_detail.cp_anniv_date
                                       ,f_applicant_name
                                       ,f_dept_name
                                       ,f_cp_pay_detail_sw
                                       ,p_cp_pay_detail.cp_disb_type
                                       ,f_note_recv_name
                                       ,f_agent_name
                                       ,f_pscd_cnt
                                       ,f_po_sts_code
                                       ,f_modx
                                       ,f_method
                                       ,p_cp_pay_detail.dept_belong
                                       ,f_dept_adm_name
                                       ,f_function_code
                                       ,f_payout_date_from
                                       )


    END IF


    -- 延遲電匯,無資料 --
    
    IF f_2143_unnormal ="N" THEN
       LET f_function_code="R8"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="3"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0 
 
       OUTPUT TO REPORT cp_pay_unnormal (f_have_data
                                        ,p_cp_pay_detail.cp_pay_form_type
                                        ,p_cp_pay_detail.policy_no
                                        ,p_cp_pay_detail.cp_anniv_date
                                        ,f_applicant_name
                                        ,f_dept_name
                                        ,f_cp_pay_detail_sw
                                        ,p_cp_pay_detail.cp_disb_type
                                        ,f_note_recv_name
                                        ,f_agent_name
                                        ,f_pscd_cnt
                                        ,f_po_sts_code
                                        ,f_modx
                                        ,f_method
                                        ,p_cp_pay_detail.dept_belong
                                        ,f_dept_adm_name
                                        ,f_function_code
                                        ,f_payout_date_from
                                        )
       
    END IF

    IF f_2143_unnormal_50 ="N" THEN
       LET f_function_code="R8"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="3"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0

       OUTPUT TO REPORT cp_pay_unnormal_50 (f_have_data
                                        ,p_cp_pay_detail.cp_pay_form_type
                                        ,p_cp_pay_detail.policy_no
                                        ,p_cp_pay_detail.cp_anniv_date
                                        ,f_applicant_name
                                        ,f_dept_name
                                        ,f_cp_pay_detail_sw
                                        ,p_cp_pay_detail.cp_disb_type
                                        ,f_note_recv_name
                                        ,f_agent_name
                                        ,f_pscd_cnt
                                        ,f_po_sts_code
                                        ,f_modx
                                        ,f_method
                                        ,p_cp_pay_detail.dept_belong
                                        ,f_dept_adm_name
                                        ,f_function_code
                                        )


    END IF

    -- 延遲主動電匯,無資料 --
    
    IF f_cp5_unnormal ="N" THEN
       LET f_function_code="R8-主動"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="5"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0 
 
       OUTPUT TO REPORT cp_pay_unnormal (f_have_data
                                        ,p_cp_pay_detail.cp_pay_form_type
                                        ,p_cp_pay_detail.policy_no
                                        ,p_cp_pay_detail.cp_anniv_date
                                        ,f_applicant_name
                                        ,f_dept_name
                                        ,f_cp_pay_detail_sw
                                        ,p_cp_pay_detail.cp_disb_type
                                        ,f_note_recv_name
                                        ,f_agent_name
                                        ,f_pscd_cnt
                                        ,f_po_sts_code
                                        ,f_modx
                                        ,f_method
                                        ,p_cp_pay_detail.dept_belong
                                        ,f_dept_adm_name
                                        ,f_function_code
                                        ,f_payout_date_from
                                        )
       
    END IF

    IF f_cp5_unnormal_50 ="N" THEN
       LET f_function_code="R8-主動"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="5"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0

       OUTPUT TO REPORT cp_pay_unnormal_50 (f_have_data
                                        ,p_cp_pay_detail.cp_pay_form_type
                                        ,p_cp_pay_detail.policy_no
                                        ,p_cp_pay_detail.cp_anniv_date
                                        ,f_applicant_name
                                        ,f_dept_name
                                        ,f_cp_pay_detail_sw
                                        ,p_cp_pay_detail.cp_disb_type
                                        ,f_note_recv_name
                                        ,f_agent_name
                                        ,f_pscd_cnt
                                        ,f_po_sts_code
                                        ,f_modx
                                        ,f_method
                                        ,p_cp_pay_detail.dept_belong
                                        ,f_dept_adm_name
                                        ,f_function_code
                                        )


    END IF

    -- ,無資料 --
    IF f_0027_unnormal ="N" THEN
       LET f_function_code="RJ"
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type="6"
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0

       OUTPUT TO REPORT cp_pay_dtl_col_un (f_have_data
                                        ,p_cp_pay_detail.cp_pay_form_type
                                        ,p_cp_pay_detail.policy_no
                                        ,p_cp_pay_detail.cp_anniv_date
                                        ,f_applicant_name
                                        ,f_dept_name
                                        ,f_cp_pay_detail_sw
                                        ,p_cp_pay_detail.cp_disb_type
                                        ,f_note_recv_name
                                        ,f_agent_name
                                        ,f_pscd_cnt
                                        ,f_po_sts_code
                                        ,f_modx
                                        ,f_method
                                        ,p_cp_pay_detail.dept_belong
                                        ,f_dept_adm_name
                                        ,f_function_code
                                        )
    END IF
        -- 無回流,延遲 --
    IF f_data_col_usd ="N" THEN
       LET f_function_code=""
       LET f_have_data="N"
       LET p_cp_pay_detail.cp_pay_form_type="0"
       LET p_cp_pay_detail.policy_no=""
       LET p_cp_pay_detail.cp_anniv_date=""
       LET f_applicant_name=""
       LET f_dept_name=""
       LET f_cp_pay_detail_sw="0"
       LET p_cp_pay_detail.cp_disb_type=""
       LET f_note_recv_name=""
       LET f_agent_name=""
       LET f_pscd_cnt=0
       LET f_po_sts_code=""
       LET f_modx=0

       OUTPUT TO REPORT cp_pay_dtl_col_usd (f_have_data
                                        ,p_cp_pay_detail.cp_pay_form_type
                                        ,p_cp_pay_detail.policy_no
                                        ,p_cp_pay_detail.cp_anniv_date
                                        ,f_applicant_name
                                        ,f_dept_name
                                        ,f_cp_pay_detail_sw
                                        ,p_cp_pay_detail.cp_disb_type
                                        ,f_note_recv_name
                                        ,f_agent_name
                                        ,f_pscd_cnt
                                        ,f_po_sts_code
                                        ,f_modx
                                        ,f_method
                                        ,f_function_code
                                        ,p_cp_pay_detail.*
                                        )



    END IF

    FINISH REPORT cp_pay_dtl
    FINISH REPORT cp_pay_dtl_un
    FINISH REPORT cp_pay_dtl_col
    FINISH REPORT cp_pay_unnormal
--    FINISH REPORT cp_pay_post
    FINISH REPORT cp_pay_dtl_col_un
    FINISH REPORT cp_pay_dtl_col_50
    FINISH REPORT cp_pay_unnormal_50
    FINISH REPORT cp_pay_dtl_all        
    FINISH REPORT cp_pay_dtl_stat
    FINISH REPORT cp_pay_dtl_usd
    FINISH REPORT cp_pay_dtl_col_usd

  

    LET     run_cmd1 = "psmanager ", f_rpt_name_1
        RUn     run_cmd1
    LET     run_cmd1 = "psmanager ", f_rpt_name_5
        RUn     run_cmd1
    LET     run_cmd1 = "psmanager ", f_rpt_name_13
        RUn     run_cmd1



    RETURN f_rcode
END FUNCTION
-------------------------------------------------------------------------------
-- 報表名稱:cp_pay_dtl
-- 作    者:jessica Chang
-- 日    期:087/02/03
-- 處理概要:滿期給付明細列印
-- table   :pscr
-- inp para:列印日
-- return 的參數:
-- 重要函式:
-------------------------------------------------------------------------------
REPORT cp_pay_dtl    (r_cp_pay_form_type
                     ,r_policy_no
                     ,r_cp_anniv_date
                     ,r_zip_code
                     ,r_address
                     ,r_applicant_name
                     ,r_insured_name
                     ,r_tel_1
                     ,r_dept_name
                     ,r_plan_desc
                     ,r_cp_pay_detail_sw
                     ,r_benf_name_all
                     ,r_cp_disb_type
                     ,r_pay_desc
                     ,r_recv_note_name
                     ,r_dept_adm_name
                     ,r_pscd_cnt
                     ,r_dept_belong
                     ,r_dept_code        -- 部門代碼
                     ,r_mobile_o1        -- 要保人手機
                     ,r_ebill_ind        -- ebill指示
                     ,r_ebill_email      -- 要保人email
                     )

    DEFINE  r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_zip_code            LIKE addr.zip_code
           ,r_address             LIKE addr.address
           ,r_applicant_name      LIKE clnt.names
           ,r_insured_name        LIKE clnt.names
           ,r_tel_1               LIKE addr.tel_1
           ,r_dept_name           LIKE dept.dept_name
           ,r_plan_desc           LIKE pldf.plan_desc
           ,r_cp_pay_detail_sw    CHAR(1)
           ,r_benf_name_all       CHAR(50)
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_pay_desc            CHAR(10)
           ,r_recv_note_name      LIKE clnt.names
           ,r_dept_adm_name       LIKE clnt.names
           ,r_pscd_cnt            INTEGER -- 受益人明細筆數 --
           ,r_dept_belong         LIKE dept.dept_belong
           ,r_dept_code           LIKE dept.dept_code
           ,r_mobile_o1           LIKE addr.tel_1
           ,r_ebill_ind           CHAR(1)
           ,r_ebill_email         LIKE addr.address


    DEFINE r_addr_1              CHAR(36)
          ,r_addr_2              CHAR(36)

    DEFINE r_rpt_yy              INTEGER
          ,r_rpt_mm              INTEGER
          ,r_rpt_dd              INTEGER
          ,r_anniv_yy            INTEGER
          ,r_anniv_mm            INTEGER
          ,r_anniv_dd            INTEGER
          ,r_div_total           INTEGER
          ,r_11780300_amt        INTEGER
          ,r_28250019_amt        INTEGER
          ,r_cp_pay_amt          INTEGER
          ,r_cp_real_payamt      INTEGER

    DEFINE r_payform_var         CHAR(100)
          ,r_i                   INTEGER
          ,r_pscd_row            INTEGER
          ,r_diff_row            INTEGER

    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER EXTERNAL BY r_dept_belong
            ,r_cp_disb_type
            ,r_policy_no
            ,r_cp_anniv_date

    FORMAT
        --SR120800390 cmwang 101/09 
        PAGE HEADER
--                PRINT r_dept_code, r_mobile_o1, r_ebill_email[1,50], r_ebill_ind, r_policy_no,"|" 
--              PRINT ASCII 27,"E",ASCII 27,"A",ASCII 27,"z1",
--                    ASCII 27,"90033",ASCII 27,"80060"
              PRINT g_ebill_format
        ----------------------------------------------------------- 
              PRINT ASCII 126,"IT26G2;"
              SKIP  9 LINES

              CALL cut_string (r_address,LENGTH(r_address),36)
                   RETURNING r_addr_1,r_addr_2

              PRINT COLUMN  11,r_zip_code  CLIPPED
              PRINT COLUMN   1," "
              PRINT COLUMN  11,r_addr_1 CLIPPED
              PRINT COLUMN   1," "
              PRINT COLUMN  11,r_addr_2 CLIPPED
              PRINT COLUMN   1," "
              PRINT COLUMN  11,r_recv_note_name[1,30]         ,"  君親啟"

              SKIP  4 LINES

        BEFORE GROUP OF r_dept_belong
               SKIP TO TOP OF PAGE

        BEFORE GROUP OF r_cp_disb_type 
               SKIP TO TOP OF PAGE

        BEFORE GROUP OF r_policy_no         
               SKIP TO TOP OF PAGE

        BEFORE GROUP OF r_cp_anniv_date
               SKIP TO TOP OF PAGE

        ON EVERY ROW
           LET r_pscd_row = 0
           LET r_diff_row = 0
           -- 其它支出 印 0 --
           IF p_cp_pay_detail.cp_pay_amt < 0 THEN
              LET r_cp_pay_amt=0
           ELSE
              LET r_cp_pay_amt=p_cp_pay_detail.cp_pay_amt
           END IF

           CALL SeparateYMD(p_cp_pay_detail.process_date)
                 RETURNING r_rpt_yy,r_rpt_mm,r_rpt_dd
           CALL SeparateYMD(r_cp_anniv_date)
                RETURNING r_anniv_yy,r_anniv_mm,r_anniv_dd

           LET p_payform_0[2]=p_payform_6

           --  滿期 給付明細基本資料列印 p_payform_0 --

           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_0[4]
           LET r_payform_var[15,26]=p_cp_pay_detail.policy_no
           LET r_payform_var[45,64]=r_insured_name[1,20]
           LET r_payform_var[82,84]=p_cp_pay_detail.cp_pay_form_type
           LET p_payform_0[4]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_0[5]
           LET r_payform_var[15,64]=r_benf_name_all
           LET r_payform_var[72,74]=r_rpt_yy    USING "###"
           LET r_payform_var[77,78]=r_rpt_mm    USING "##"
           LET r_payform_var[81,82]=r_rpt_dd    USING "##"
           LET p_payform_0[5]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_0[6]
           LET r_payform_var[15,27]=p_cp_pay_detail.face_amt
                                    USING "#,###,###,###"
           LET r_payform_var[45,84]=r_plan_desc[1,38]
           LET p_payform_0[6]=r_payform_var

           FOR r_i=1 TO 11
               IF r_i=1 THEN
               --   PRINT ASCII 27,"612"
                  PRINT ASCII 126,"IX1W2Z2FK;"
               ELSE
                  IF r_i=3 THEN
                --     PRINT ASCII 27,"611",ASCII 27,"90036"
                --          ,ASCII 27,"80067"
                  PRINT ASCII 126,"IX9G2;"
                  ELSE
                     PRINT COLUMN  1,p_payform_0[r_i] CLIPPED
                  END IF
               END IF
           END FOR

           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[1]
           LET r_payform_var[31,33]=r_anniv_yy  USING "###"
           LET r_payform_var[38,39]=r_anniv_mm  USING "##"
           LET r_payform_var[44,45]=r_anniv_dd  USING "##"
           LET p_payform_2[1]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[4]
           LET r_payform_var[49,60]=p_cp_pay_detail.cp_amt
                                    USING "----,---,--&"
           LET p_payform_2[4]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[5]
           LET r_div_total =0
           LET r_div_total =p_cp_pay_detail.accumulated_div
                           +p_cp_pay_detail.div_int_balance
                           +p_cp_pay_detail.div_int
           LET r_payform_var[49,60]=r_div_total
                                    USING "----,---,--&"
           LET p_payform_2[5]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[6]
           LET r_payform_var[49,60]=p_cp_pay_detail.prem_susp
                                    USING "----,---,--&"
           LET p_payform_2[6]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[7]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_minus_premsusp
                                    USING "----,---,--&"
           LET p_payform_2[7]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[8]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_apl_int
                                    USING "----,---,--&"
           LET p_payform_2[8]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[9]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_apl_amt
                                    USING "----,---,--&"
           LET p_payform_2[9]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[10]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_loan_int
                                    USING "----,---,--&"
           LET p_payform_2[10]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[11]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_loan_amt
                                    USING "----,---,--&"
           LET p_payform_2[11]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[12]
           LET r_payform_var[20,29]=r_pay_desc
           LET r_payform_var[49,60]=r_cp_pay_amt  
                                    USING "----,---,--&"
           LET p_payform_2[12]=r_payform_var

           FOR r_i =1 TO 13
               PRINT COLUMN  1,p_payform_2[r_i] CLIPPED
           END FOR

           -- 列印受益人給付明細 --
           IF r_cp_pay_detail_sw ="0" THEN
              FOR r_i =1 to 7
                  PRINT COLUMN 1," "
              END FOR
           ELSE
              FOR r_i =1 TO 3
                  PRINT COLUMN  1,p_payform_d[r_i] CLIPPED
              END FOR
              FOR r_i =1 TO r_pscd_cnt
                  IF p_pscd_r[r_i].cp_real_payamt !=0 THEN
                     -- 其它支出 印 0 --
                     IF p_pscd_r[r_i].cp_real_payamt < 0 THEN
                        LET r_cp_real_payamt = 0
                     ELSE
                        LET r_cp_real_payamt = p_pscd_r[r_i].cp_real_payamt
                     END IF

                     PRINT COLUMN  6,p_pscd_r[r_i].cp_pay_seq
                                     USING "####",
                           COLUMN 11,p_pscd_r[r_i].names[1,20]   ,
                           COLUMN 32,p_pscd_r[r_i].benf_ratio
                                     USING "###",
                           COLUMN 38,r_cp_real_payamt
                                     USING "----,---,--&",
                           COLUMN 50,"元",
                           COLUMN 53,p_pscd_r[r_i].disb_no;

                     IF r_cp_disb_type = "3"
                     OR r_cp_disb_type = "5" THEN
                        PRINT COLUMN 61,p_pscd_r[r_i].remit_bank,
                                        p_pscd_r[r_i].remit_branch,"-",
                                        p_pscd_r[r_i].remit_account[1,7], 'xxx',
                                        p_pscd_r[r_i].remit_account[11,16]
                     ELSE
                        PRINT COLUMN 61,p_pscd_r[r_i].remit_bank,
                                        p_pscd_r[r_i].remit_branch,"-",
                                        p_pscd_r[r_i].remit_account
                     END IF

                     LET r_pscd_row=r_pscd_row+1
                  END IF
              END FOR
              IF r_pscd_row < 7 THEN
                 LET r_diff_row=7-r_pscd_row
                 FOR r_i=1 TO r_diff_row
                     PRINT COLUMN 1," "
                 END FOR
              END IF
           END IF

           -- 列印明細表結尾 --
           LET r_payform_var=p_payform_init
           LET r_payform_var=p_payform_e[3]
           LET r_payform_var[17,26]=p_cp_pay_detail.rtn_rece_no
           LET p_payform_e[3]=r_payform_var
           LET r_payform_var=p_payform_init
           LET r_payform_var=p_payform_e[4]
           LET r_payform_var[17,36]=r_dept_name[1,20]
           LET p_payform_e[4]=r_payform_var

#          LET p_payform_e[5]=p_payform_init
           LET r_payform_var=p_payform_e[5]
           LET r_payform_var[17,36]=r_dept_adm_name[1,20]
           LET p_payform_e[5]=r_payform_var

           FOR r_i =1 TO 9
--               IF r_i=10 THEN
--                  PRINT ASCII 27,"E"
--               ELSE
                  PRINT COLUMN  1,p_payform_e[r_i] CLIPPED
--               END IF
           END FOR
        
         ON LAST ROW
           PRINT ASCII 12

END REPORT -- cp_pay_dtl 生存/滿期給付報表  --
-------------------------------------------------------------------------------
-- 報表名稱:cp_pay_dtl_un
-- 作    者:jessica Chang
-- 日    期:087/02/03
-- 處理概要:滿期給付明細列印--延遲電匯
-- table   :pscr
-- inp para:列印日
-- return 的參數:
-- 重要函式:
-------------------------------------------------------------------------------
REPORT cp_pay_dtl_un (r_cp_pay_form_type
                     ,r_policy_no
                     ,r_cp_anniv_date
                     ,r_zip_code
                     ,r_address
                     ,r_applicant_name
                     ,r_insured_name
                     ,r_tel_1
                     ,r_dept_name
                     ,r_plan_desc
                     ,r_cp_pay_detail_sw
                     ,r_benf_name_all
                     ,r_cp_disb_type
                     ,r_pay_desc
                     ,r_recv_note_name
                     ,r_dept_adm_name
                     ,r_pscd_cnt
                     ,r_dept_belong
                     ,r_dept_code        -- 部門代碼
                     ,r_mobile_o1        -- 要保人手機
                     ,r_ebill_ind        -- ebill指示
                     ,r_ebill_email      -- 要保人email

                     )

    DEFINE  r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_zip_code            LIKE addr.zip_code
           ,r_address             LIKE addr.address
           ,r_applicant_name      LIKE clnt.names
           ,r_insured_name        LIKE clnt.names
           ,r_tel_1               LIKE addr.tel_1
           ,r_dept_name           LIKE dept.dept_name
           ,r_plan_desc           LIKE pldf.plan_desc
           ,r_cp_pay_detail_sw    CHAR(1)
           ,r_benf_name_all       CHAR(50)
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_pay_desc            CHAR(10)
           ,r_recv_note_name      LIKE clnt.names
           ,r_dept_adm_name       LIKE clnt.names
           ,r_pscd_cnt            INTEGER -- 受益人明細筆數 --
           ,r_dept_belong         LIKE dept.dept_belong
           ,r_dept_code           LIKE dept.dept_code
           ,r_mobile_o1           LIKE addr.tel_1
           ,r_ebill_ind           CHAR(1)
           ,r_ebill_email         LIKE addr.address


    DEFINE r_addr_1              CHAR(36)
          ,r_addr_2              CHAR(36)

    DEFINE r_rpt_yy              INTEGER
          ,r_rpt_mm              INTEGER
          ,r_rpt_dd              INTEGER
          ,r_anniv_yy            INTEGER
          ,r_anniv_mm            INTEGER
          ,r_anniv_dd            INTEGER
          ,r_div_total           INTEGER
          ,r_11780300_amt        INTEGER
          ,r_28250019_amt        INTEGER
          ,r_cp_pay_amt          INTEGER
          ,r_cp_real_payamt      INTEGER

    DEFINE r_payform_var         CHAR(100)
          ,r_i                   INTEGER
          ,r_pscd_row            INTEGER
          ,r_diff_row            INTEGER

    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER EXTERNAL BY r_dept_belong
            ,r_cp_disb_type
            ,r_policy_no
            ,r_cp_anniv_date

    FORMAT

        PAGE HEADER
                --SR120800390 cmwang 101/09 
--              PRINT ASCII 27,"E",ASCII 27,"A",ASCII 27,"z1",
--                    ASCII 27,"90033",ASCII 27,"80060"
--                PRINT r_dept_code, r_mobile_o1, r_ebill_email[1,50], r_ebill_ind, r_policy_no,"|"
              PRINT g_ebill_format
        ----------------------------------------------------------- 
                PRINT ASCII 126,"IT26G2;"
              SKIP  9 LINES

              CALL cut_string (r_address,LENGTH(r_address),36)
                   RETURNING r_addr_1,r_addr_2

              PRINT COLUMN  11,r_zip_code  CLIPPED
              PRINT COLUMN   1," "
              PRINT COLUMN  11,r_addr_1 CLIPPED
              PRINT COLUMN   1," "
              PRINT COLUMN  11,r_addr_2 CLIPPED
              PRINT COLUMN   1," "
              PRINT COLUMN  11,r_recv_note_name[1,30]         ,"  君親啟"

              SKIP  4 LINES

        BEFORE GROUP OF r_dept_belong
               SKIP TO TOP OF PAGE

        BEFORE GROUP OF r_cp_disb_type 
               SKIP TO TOP OF PAGE

        BEFORE GROUP OF r_policy_no         
               SKIP TO TOP OF PAGE

        BEFORE GROUP OF r_cp_anniv_date
               SKIP TO TOP OF PAGE

        ON EVERY ROW
           LET r_pscd_row = 0
           LET r_diff_row = 0
           -- 其它支出 印 0 --
           IF p_cp_pay_detail.cp_pay_amt < 0 THEN
              LET r_cp_pay_amt=0
           ELSE
              LET r_cp_pay_amt=p_cp_pay_detail.cp_pay_amt
           END IF

           CALL SeparateYMD(p_cp_pay_detail.process_date)
                 RETURNING r_rpt_yy,r_rpt_mm,r_rpt_dd
           CALL SeparateYMD(r_cp_anniv_date)
                RETURNING r_anniv_yy,r_anniv_mm,r_anniv_dd

           LET p_payform_0[2]=p_payform_6

           --  滿期 給付明細基本資料列印 p_payform_0 --

           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_0[4]
           LET r_payform_var[15,26]=p_cp_pay_detail.policy_no
           LET r_payform_var[45,64]=r_insured_name[1,20]
           LET r_payform_var[82,84]=p_cp_pay_detail.cp_pay_form_type
           LET p_payform_0[4]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_0[5]
           LET r_payform_var[15,64]=r_benf_name_all
           LET r_payform_var[72,74]=r_rpt_yy    USING "###"
           LET r_payform_var[77,78]=r_rpt_mm    USING "##"
           LET r_payform_var[81,82]=r_rpt_dd    USING "##"
           LET p_payform_0[5]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_0[6]
           LET r_payform_var[15,27]=p_cp_pay_detail.face_amt
                                    USING "#,###,###,###"
           LET r_payform_var[45,84]=r_plan_desc[1,38]
           LET p_payform_0[6]=r_payform_var

           FOR r_i=1 TO 11
               IF r_i=1 THEN
               --   PRINT ASCII 27,"612"
                   PRINT ASCII 126,"IX1W2Z2FK;"
               ELSE
                  IF r_i=3 THEN
               --      PRINT ASCII 27,"611",ASCII 27,"90036"
               --           ,ASCII 27,"80067"
                   PRINT ASCII 126,"IX9G2;"
                  ELSE
                     PRINT COLUMN  1,p_payform_0[r_i] CLIPPED
                  END IF
               END IF
           END FOR

           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[1]
           LET r_payform_var[31,33]=r_anniv_yy  USING "###"
           LET r_payform_var[38,39]=r_anniv_mm  USING "##"
           LET r_payform_var[44,45]=r_anniv_dd  USING "##"
           LET p_payform_2[1]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[4]
           LET r_payform_var[49,60]=p_cp_pay_detail.cp_amt
                                    USING "----,---,--&"
           LET p_payform_2[4]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[5]
           LET r_div_total =0
           LET r_div_total =p_cp_pay_detail.accumulated_div
                           +p_cp_pay_detail.div_int_balance
                           +p_cp_pay_detail.div_int
           LET r_payform_var[49,60]=r_div_total
                                    USING "----,---,--&"
           LET p_payform_2[5]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[6]
           LET r_payform_var[49,60]=p_cp_pay_detail.prem_susp
                                    USING "----,---,--&"
           LET p_payform_2[6]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[7]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_minus_premsusp
                                    USING "----,---,--&"
           LET p_payform_2[7]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[8]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_apl_int
                                    USING "----,---,--&"
           LET p_payform_2[8]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[9]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_apl_amt
                                    USING "----,---,--&"
           LET p_payform_2[9]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[10]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_loan_int
                                    USING "----,---,--&"
           LET p_payform_2[10]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[11]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_loan_amt
                                    USING "----,---,--&"
           LET p_payform_2[11]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_2[12]
           LET r_payform_var[20,29]=r_pay_desc           
           LET r_payform_var[49,60]=r_cp_pay_amt  
                                    USING "----,---,--&"
           LET p_payform_2[12]=r_payform_var

           FOR r_i =1 TO 13
               PRINT COLUMN  1,p_payform_2[r_i] CLIPPED
           END FOR

           -- 列印受益人給付明細 --
           IF r_cp_pay_detail_sw ="0" THEN
              FOR r_i =1 to 7
                  PRINT COLUMN 1," "
              END FOR
           ELSE
              FOR r_i =1 TO 3
                  PRINT COLUMN  1,p_payform_d[r_i] CLIPPED
              END FOR
              FOR r_i =1 TO r_pscd_cnt
                  IF p_pscd_r[r_i].cp_real_payamt !=0 THEN
                     -- 其它支出 印 0 --
                     IF p_pscd_r[r_i].cp_real_payamt < 0 THEN
                        LET r_cp_real_payamt = 0
                     ELSE
                        LET r_cp_real_payamt = p_pscd_r[r_i].cp_real_payamt
                     END IF

                     PRINT COLUMN  6,p_pscd_r[r_i].cp_pay_seq
                                     USING "####",
                           COLUMN 11,p_pscd_r[r_i].names[1,20]   ,
                           COLUMN 32,p_pscd_r[r_i].benf_ratio
                                     USING "###",
                           COLUMN 38,r_cp_real_payamt
                                     USING "----,---,--&",
                           COLUMN 50,"元",
                           COLUMN 53,p_pscd_r[r_i].disb_no;

                     IF r_cp_disb_type = "3"
                     OR r_cp_disb_type = "5" THEN
                        PRINT COLUMN 61,p_pscd_r[r_i].remit_bank,
                                        p_pscd_r[r_i].remit_branch,"-",
                                        p_pscd_r[r_i].remit_account[1,7], 'xxx',
                                        p_pscd_r[r_i].remit_account[11,16]
                     ELSE
                        PRINT COLUMN 61,p_pscd_r[r_i].remit_bank,
                                        p_pscd_r[r_i].remit_branch,"-",
                                        p_pscd_r[r_i].remit_account
                     END IF

                     LET r_pscd_row=r_pscd_row+1
                  END IF
              END FOR
              IF r_pscd_row < 7 THEN
                 LET r_diff_row=7-r_pscd_row
                 FOR r_i=1 TO r_diff_row
                     PRINT COLUMN 1," "
                 END FOR
              END IF
           END IF

           -- 列印明細表結尾 --
           LET r_payform_var=p_payform_init
           LET r_payform_var=p_payform_e[3]
           LET r_payform_var[17,26]=p_cp_pay_detail.rtn_rece_no
           LET p_payform_e[3]=r_payform_var
           LET r_payform_var=p_payform_init
           LET r_payform_var=p_payform_e[4]
           LET r_payform_var[17,36]=r_dept_name[1,20]
           LET p_payform_e[4]=r_payform_var

#          LET p_payform_e[5]=p_payform_init
           LET r_payform_var=p_payform_e[5]
           LET r_payform_var[17,36]=r_dept_adm_name[1,20]
           LET p_payform_e[5]=r_payform_var

           FOR r_i =1 TO 9
         --      IF r_i=10 THEN
         --         PRINT ASCII 27,"E"
         --      ELSE
                  PRINT COLUMN  1,p_payform_e[r_i] CLIPPED
         --      END IF
           END FOR
        
         ON LAST ROW
           PRINT ASCII 12

END REPORT -- cp_pay_dtl_un 生存/滿期給付報表  --
-------------------------------------------------------------------------------
-- 報表名稱:cp_pay_dtl_col
-- 作    者:jessica Chang
-- 日    期:087/02/03
-- 處理概要:滿期給付明細控制表列印
-- table   :pscr
-- inp para:列印日
-- return 的參數:
-- 重要函式:
-------------------------------------------------------------------------------
REPORT cp_pay_dtl_col (r_have_data
                      ,r_cp_pay_form_type
                      ,r_policy_no
                      ,r_cp_anniv_date
                      ,r_applicant_name
                      ,r_dept_name
                      ,r_cp_pay_detail_sw
                      ,r_cp_disb_type
                      ,r_recv_note_name
                      ,r_agent_name
                      ,r_pscd_cnt
                      ,r_po_sts_code
                      ,r_modx
                      ,r_method
                      ,r_dept_belong
                      ,r_dept_adm_name
                      ,r_function_code
                      ,r_payout_date_from  
                      )

    DEFINE  r_have_data           CHAR(1) 
           ,r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_applicant_name      LIKE clnt.names
           ,r_dept_name           LIKE dept.dept_name
           ,r_plan_desc           LIKE pldf.plan_desc
           ,r_cp_pay_detail_sw    CHAR(1)
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_recv_note_name      LIKE clnt.names
           ,r_agent_name          LIKE clnt.names
           ,r_pscd_cnt            INTEGER
           ,r_po_sts_code         LIKE polf.po_sts_code
           ,r_modx                LIKE polf.modx
           ,r_method              LIKE polf.method
           ,r_dept_belong         LIKE dept.dept_belong
           ,r_dept_adm_name       LIKE dept.dept_name
--           ,r_function_code       CHAR(2)
           ,r_function_code       VARCHAR(10)
           ,r_payout_date_from    CHAR(9)


    DEFINE r_acct_no             CHAR(8)  -- 給付科目 --
          ,r_disb_desc           CHAR(8)  -- 給付方式說明 --

    DEFINE r_rpt_yy              INTEGER
          ,r_rpt_mm              INTEGER
          ,r_rpt_dd              INTEGER
          ,r_anniv_yy            INTEGER
          ,r_anniv_mm            INTEGER
          ,r_anniv_dd            INTEGER

    DEFINE r_loan_amt            INTEGER
          ,r_apl_amt             INTEGER
          ,r_div_amt             INTEGER

    DEFINE r_total_cnt           INTEGER -- 合計:件數 --
          ,r_total_payamt        INTEGER -- 應付值    --
          ,r_total_supprem       INTEGER -- 溢繳      --
          ,r_total_divamt        INTEGER -- 紅利      --
          ,r_disb_cnt            INTEGER -- 付款合計  --
          ,r_total_loanamt       INTEGER -- 貸款      --
          ,r_total_aplamt        INTEGER -- 墊繳      --
          ,r_total_minus_supprem INTEGER -- 欠繳      --
          ,r_total_realamt       INTEGER -- 實付      --
          ,r_11780300_cnt        INTEGER
          ,r_11780300_amt        INTEGER
          ,r_28250019_cnt        INTEGER
          ,r_28250019_amt        INTEGER


    DEFINE r_payform_var         CHAR(100)
          ,r_i                   INTEGER
          ,r_row_count           INTEGER
          ,r_row_cnt             INTEGER
          ,r_page_count          INTEGER

    DEFINE for_100w              VARCHAR(10)

    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER EXTERNAL BY r_cp_disb_type
            ,r_policy_no
            ,r_cp_anniv_date

    FORMAT

        PAGE HEADER
            IF PAGENO=1 THEN
               LET r_page_count =0

               LET r_loan_amt            =0
               LET r_apl_amt             =0
               LET r_div_amt             =0

               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0

               LET r_28250019_cnt        =0
               LET r_28250019_amt        =0
               LET r_11780300_cnt        =0
               LET r_11780300_amt        =0
               LET for_100w              ='' 
                
            END IF

            LET r_row_count           =0

            CASE
                WHEN r_cp_disb_type="0"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="郵寄支票"
                     LET for_100w=''
                WHEN r_cp_disb_type="2"
                     LET r_acct_no="28250001"
                     LET r_disb_desc="抵繳保費"
                     LET for_100w=''
                WHEN r_cp_disb_type="3"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="電    匯"
                     LET for_100w="＜100萬"
                WHEN r_cp_disb_type="4"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="未回領取"
                     LET for_100w=''
                WHEN r_cp_disb_type="5"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="主動電匯"
                     LET for_100w="＜100萬"
                WHEN r_cp_disb_type="6"
                     LET r_acct_no="28250027"
                     LET r_disb_desc="還本回流"
                     LET for_100w=''

            END CASE
            IF r_cp_disb_type="6" THEN
               LET r_acct_no="28250027"
            ELSE
               LET r_acct_no="28250019"
            END IF  
      --    LET g_report_corp="三 商 美 邦 人 壽 保 險 股 份 有 限 公 司"
      --    LET g_report_name="滿期給付明細控制報表"
            LET g_report_name=p_rpt_name_2

            PRINT          ASCII  27, "E",     ASCII  27, "z0"
                          ,ASCII  27, "90028", ASCII 27, "80054"
                          ,ASCII  27, "7005"
            PRINT COLUMN CenterPosition( g_report_corp,132 ),
                         g_report_corp CLIPPED,
                    COLUMN  119 ,p_name CLIPPED
{
            PRINT COLUMN  CenterPosition( g_report_corp,132 ),
                          g_report_corp CLIPPED
}
            PRINT COLUMN  CenterPosition( g_report_name,132 ),
                          g_report_name CLIPPED,for_100w
            PRINT COLUMN   1, "印表日期:", GetDate(TODAY),
                  COLUMN 111, "代    號:GC61"
            PRINT COLUMN   1, "作業日期:", p_rpt_beg_date,
                  COLUMN  45, "給付方式:",r_disb_desc,"-",r_acct_no
                                         ,"付款功能碼:",r_function_code,
                  COLUMN 111, "頁    次:", PAGENO USING "####"

            PRINT SetLine( "-",132 ) CLIPPED

            PRINT COLUMN   1, "保單號碼"    ,
                  COLUMN  14, "要保人"      ,
                  COLUMN  35, "PO-生效日"   ,
                  COLUMN  45, "週年日"      ,
                  COLUMN  53, "PO-ST"       ,
                  COLUMN  59, "繳法"        ,
                  COLUMN  64, "收費方式"    ,
                  COLUMN  73, "兌現"        ,
                  COLUMN  79, "支票日期"    ,
                  COLUMN  89, "繳費終日"    ,
                  COLUMN  99, "還款收據"    ,
                  COLUMN 110, "業務員"

            PRINT COLUMN   1, "月給付"      ,  -- 105/04/01
                  COLUMN  14, "險種"        ,
                  COLUMN  34, "保額"        ,
                  COLUMN  42, "應付金額"    ,
                  COLUMN  55, "(+)溢繳"     ,
                  COLUMN  67, "(+)紅利"     ,
                  COLUMN  75, "(-)貸款本利" ,
                  COLUMN  87, "(-)墊繳本利" ,
                  COLUMN 103, "(-)欠繳"     ,
                  COLUMN 112, "(=)實付金額" ,
                  COLUMN 125, "通訊單位"

            PRINT COLUMN  14, "受益人"      ,
                  COLUMN  36, "順序"        ,
                  COLUMN  43, "受益比率%"   ,
                  COLUMN  57, "分配金額"    ,
                  COLUMN  68, "銀行"        ,
                  COLUMN  76, "帳號"        ,
                  COLUMN 110, "付款號碼"

            PRINT SetLine( "-",132 ) CLIPPED

        BEFORE GROUP OF r_cp_disb_type
               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET r_page_count          =0
               LET r_28250019_cnt        =0
               LET r_28250019_amt        =0
               LET r_11780300_cnt        =0
               LET r_11780300_amt        =0
               LET r_row_count           =0
               SKIP TO TOP OF PAGE

        ON EVERY ROW
           IF r_have_data="Y" THEN
              LET r_loan_amt=p_cp_pay_detail.rtn_loan_amt
                            +p_cp_pay_detail.rtn_loan_int
              LET r_apl_amt =p_cp_pay_detail.rtn_apl_amt
                            +p_cp_pay_detail.rtn_apl_int
              LET r_div_amt =p_cp_pay_detail.accumulated_div
                            +p_cp_pay_detail.div_int_balance
                            +p_cp_pay_detail.div_int

              LET r_total_cnt           =r_total_cnt+1
              LET r_total_payamt        =r_total_payamt
                                        +p_cp_pay_detail.cp_amt
              LET r_total_supprem       =r_total_supprem
                                        +p_cp_pay_detail.prem_susp
              LET r_total_divamt        =r_total_divamt
                                        +r_div_amt
              LET r_total_loanamt       =r_total_loanamt
                                        +r_loan_amt
              LET r_total_aplamt        =r_total_aplamt
                                        +r_apl_amt
              LET r_total_minus_supprem =r_total_minus_supprem
                                        +p_cp_pay_detail.rtn_minus_premsusp

--            LET r_total_realamt       =r_total_realamt
--                                      +p_cp_pay_detail.cp_pay_amt


              PRINT COLUMN   1,r_policy_no             ,  -- 保單號碼   --
                    COLUMN  14,r_applicant_name[1,20]  ,  -- 要保人     --
                    COLUMN  35,p_cp_pay_detail.po_issue_date
                                                       ,  -- po_issue_d --
                    COLUMN  45,r_cp_anniv_date         ,  -- cp_anniv_d --
                    COLUMN  55,r_po_sts_code           ,  -- po_sts     --
                    COLUMN  60,r_modx  USING "###"     ,  -- modx       --
                    COLUMN  68,r_method                ,  -- method     --
                    COLUMN  75," "                     ,  -- chk_sw     --
                    COLUMN  79,p_cp_pay_detail.cp_chk_date
                                                       ,  -- chk_date   --
                    COLUMN  89,p_cp_pay_detail.paid_to_date
                                                       ,  -- paid_to_d  --
                    COLUMN  99,p_cp_pay_detail.rtn_rece_no
                                                       ,  -- rtn_rece_no--
                    COLUMN 110,r_agent_name[1,20]         -- agent_name --

              LET r_page_count=r_page_count+1
              LET r_row_count=r_row_count+1
              
              PRINT COLUMN   1,r_payout_date_from       , -- 月給付   -- 105/04/01
                    COLUMN  14,p_cp_pay_detail.plan_code,'-',
                               p_cp_pay_detail.rate_scale
                                                        ,  -- 險種       --
                    COLUMN  25,p_cp_pay_detail.face_amt USING "#,###,###,###"
                                                        ,  -- 保額       --
                    COLUMN  39,p_cp_pay_detail.cp_amt   USING "###,###,###"
                                                        ,  -- 應付金額   --
                    COLUMN  51,p_cp_pay_detail.prem_susp USING "###,###,###"
                                                        ,  -- (+)溢繳    --
                    COLUMN  63,r_div_amt                USING "###,###,###"
                                                        ,  -- (+)紅利    --
                    COLUMN  75,r_loan_amt               USING "###,###,###"
                                                        ,  -- (-)貸款本息--
                    COLUMN  87,r_apl_amt                USING "###,###,###"
                                                        ,  -- (-)墊繳本息--
                    COLUMN  99,p_cp_pay_detail.rtn_minus_premsusp
                                                        USING "###,###,###"
                                                        ,  -- (-)欠繳    --
                    COLUMN 111,p_cp_pay_detail.cp_pay_amt USING "----,---,--&"
                                                        ,  -- (=)實付金額--
                    COLUMN 125,p_cp_pay_detail.dept_code  -- 通訊單位 --

              LET r_page_count=r_page_count+1

              IF p_cp_pay_detail.cp_pay_amt < 0 THEN
                 LET r_11780300_cnt=r_11780300_cnt+1
                 LET r_11780300_amt=r_11780300_amt+p_cp_pay_detail.cp_pay_amt
              END IF
              IF r_cp_pay_detail_sw ="1" THEN -- 無受益人資料 --
                 FOR r_i=1 TO r_pscd_cnt
                     IF p_pscd_r[r_i].cp_real_payamt !=0 THEN
                        LET r_page_count   =r_page_count+1
                        LET r_disb_cnt     =r_disb_cnt+1
                        IF p_pscd_r[r_i].cp_real_payamt < 0 THEN
                           LET r_11780300_cnt=r_11780300_cnt+1
                           LET r_11780300_amt=r_11780300_amt
                                             -p_pscd_r[r_i].cp_real_payamt
                        ELSE
                           LET r_28250019_cnt=r_28250019_cnt+1
                           LET r_28250019_amt=r_28250019_amt
                                             +p_pscd_r[r_i].cp_real_payamt
                        END IF

                        PRINT COLUMN   14,p_pscd_r[r_i].names[1,20]    , -- 受益人 --
                              COLUMN   36,p_pscd_r[r_i].cp_pay_seq
                                          USING "####"                 , -- 順序   --
                              COLUMN   46,p_pscd_r[r_i].benf_ratio
                                          USING "###"                  , -- 分配率 --
                              COLUMN   53,p_pscd_r[r_i].cp_real_payamt
                                          USING "----,---,--&"         , -- 分配金額 --
                              COLUMN   68,p_pscd_r[r_i].remit_bank
                                         ,p_pscd_r[r_i].remit_branch   , -- 銀行     --
                              COLUMN   76,p_pscd_r[r_i].remit_account  , -- 帳號     --
                              COLUMN  110,p_pscd_r[r_i].disb_no          -- 付款號碼 --
                     END IF
                 END FOR
              END IF
              PRINT COLUMN   1," "
              IF r_page_count >= 30 
              OR r_row_count  == 10
              THEN
                 LET r_page_count=0
                 LET r_row_cnt=r_row_count   --紀錄該頁印出幾筆資料
                 LET r_row_count =0
                 SKIP 1 LINE
                 PRINT SetLine("-",62 ) CLIPPED,"續下頁",SetLine("-",62)
                 PRINT COLUMN 92,"本頁資料筆數：",r_row_cnt USING "<<<<","筆"
                 SKIP TO TOP OF PAGE
              END IF
           END IF

        AFTER GROUP OF r_cp_disb_type
           PRINT COLUMN  24,"應付值:"   ,r_total_payamt USING "#,###,###,##&"," 元",
                 COLUMN  50,"(+)溢繳:"  ,r_total_supprem USING "#,###,###,##&"," 元",
                 COLUMN  77,"(+)紅利:"  ,r_total_divamt USING "#,###,###,##&"," 元"

           PRINT COLUMN  21,"(-)貸  款:",r_total_loanamt USING "#,###,###,##&"," 元",
                 COLUMN  50,"(-)墊繳:"  ,r_total_aplamt  USING "#,###,###,##&"," 元",
                 COLUMN  77,"(-)欠繳:"  ,r_total_minus_supprem USING "#,###,###,##&"," 元"

           PRINT COLUMN  22,r_acct_no,":",r_28250019_cnt USING "###,##&",
                            "件",
                 COLUMN  49,"合計金額:",r_28250019_amt USING "#,###,###,##&"," 元"
           PRINT COLUMN  22,"11780300:",r_11780300_cnt USING "###,##&","件",
                 COLUMN  49,"合計金額:",r_11780300_amt USING "#,###,###,##&"," 元"
           SKIP  2 LINE

           PRINT COLUMN   3,"(副)總經理:_____________________",
                 COLUMN  37,  "部門主管:_____________________",
                 COLUMN  68,  "單位主管:_____________________",
                 COLUMN  99,    "請款人:_____________________"

        LET r_row_count=0

        ON LAST ROW
           PRINT ASCII 12

END REPORT -- cp_pay_dtl_col 滿期金給付控制報表 --

-------------------------------------------------------------------------------
-- 報表名稱:cp_pay_unnormal
-- 作    者:jessica Chang
-- 日    期:088/12/14
-- 處理概要:滿期/還本給付明細控制表列印
--          因支票未兌現使得給付延後的資料,電匯資料特殊作業
-- table   :pscr
-- inp para:列印日
-- return 的參數:
-- 重要函式:
-------------------------------------------------------------------------------
REPORT cp_pay_unnormal (r_have_data
                       ,r_cp_pay_form_type
                       ,r_policy_no
                       ,r_cp_anniv_date
                       ,r_applicant_name
                       ,r_dept_name
                       ,r_cp_pay_detail_sw
                       ,r_cp_disb_type
                       ,r_recv_note_name
                       ,r_agent_name
                       ,r_pscd_cnt
                       ,r_po_sts_code
                       ,r_modx
                       ,r_method
                       ,r_dept_belong
                       ,r_dept_adm_name
                       ,r_function_code
                       ,r_payout_date_from
                       )

    DEFINE  r_have_data           CHAR(1) 
           ,r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_applicant_name      LIKE clnt.names
           ,r_dept_name           LIKE dept.dept_name
           ,r_plan_desc           LIKE pldf.plan_desc
           ,r_cp_pay_detail_sw    CHAR(1)
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_recv_note_name      LIKE clnt.names
           ,r_agent_name          LIKE clnt.names
           ,r_pscd_cnt            INTEGER
           ,r_po_sts_code         LIKE polf.po_sts_code
           ,r_modx                LIKE polf.modx
           ,r_method              LIKE polf.method
           ,r_dept_belong         LIKE dept.dept_belong
           ,r_dept_adm_name       LIKE dept.dept_name
--           ,r_function_code       CHAR(2)
           ,r_function_code       VARCHAR(10)
           ,r_payout_date_from    CHAR(9)

    DEFINE r_acct_no             CHAR(8)  -- 給付科目 --
          ,r_disb_desc           CHAR(8)  -- 給付方式說明 --

    DEFINE r_rpt_yy              INTEGER
          ,r_rpt_mm              INTEGER
          ,r_rpt_dd              INTEGER
          ,r_anniv_yy            INTEGER
          ,r_anniv_mm            INTEGER
          ,r_anniv_dd            INTEGER

    DEFINE r_loan_amt            INTEGER
          ,r_apl_amt             INTEGER
          ,r_div_amt             INTEGER

    DEFINE r_total_cnt           INTEGER -- 合計:件數 --
          ,r_total_payamt        INTEGER -- 應付值    --
          ,r_total_supprem       INTEGER -- 溢繳      --
          ,r_total_divamt        INTEGER -- 紅利      --
          ,r_disb_cnt            INTEGER -- 付款合計  --
          ,r_total_loanamt       INTEGER -- 貸款      --
          ,r_total_aplamt        INTEGER -- 墊繳      --
          ,r_total_minus_supprem INTEGER -- 欠繳      --
          ,r_total_realamt       INTEGER -- 實付      --
          ,r_11780300_cnt        INTEGER
          ,r_11780300_amt        INTEGER
          ,r_28250019_cnt        INTEGER
          ,r_28250019_amt        INTEGER


    DEFINE r_payform_var         CHAR(100)
          ,r_i                   INTEGER
          ,r_row_count           INTEGER
          ,r_row_cnt             INTEGER
          ,r_page_count          INTEGER

    DEFINE for_100w              VARCHAR(10)
    
    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER EXTERNAL BY r_cp_disb_type
            ,r_policy_no
            ,r_cp_anniv_date

    FORMAT

        PAGE HEADER
            IF PAGENO=1 THEN
               LET r_page_count =0

               LET r_loan_amt            =0
               LET r_apl_amt             =0
               LET r_div_amt             =0

               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0

               LET r_28250019_cnt        =0
               LET r_28250019_amt        =0
               LET r_11780300_cnt        =0
               LET r_11780300_amt        =0
               LET for_100w              =''
            
            END IF

            LET r_row_count           =0

            CASE
                WHEN r_cp_disb_type="0"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="郵寄支票"
                     LET for_100w=''
                WHEN r_cp_disb_type="2"
                     LET r_acct_no="28250001"
                     LET r_disb_desc="抵繳保費"
                     LET for_100w=''
                WHEN r_cp_disb_type="3"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="電    匯"
                     LET for_100w="＜100萬"
                WHEN r_cp_disb_type="4"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="未回領取"
                     LET for_100w=''
                WHEN r_cp_disb_type="5"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="主動電匯"
                     LET for_100w="＜100萬"
                     
            END CASE

            LET r_acct_no="28250019"
      --    LET g_report_corp="三 商 美 邦 人 壽 保 險 股 份 有 限 公 司"
      --    LET g_report_name="滿期給付明細控制報表"
            LET g_report_name=p_rpt_name_4

            PRINT          ASCII  27, "E",     ASCII  27, "z0"
                          ,ASCII  27, "90028", ASCII 27, "80054"
                          ,ASCII  27, "7005"
            PRINT COLUMN CenterPosition( g_report_corp,132 ),
                         g_report_corp CLIPPED,
                    COLUMN  119 ,p_name CLIPPED
{
            PRINT COLUMN  CenterPosition( g_report_corp,132 ),
                          g_report_corp CLIPPED
}
            PRINT COLUMN  CenterPosition( g_report_name,132 ),
                          g_report_name CLIPPED,for_100w
            PRINT COLUMN   1, "印表日期:", GetDate(TODAY),
                  COLUMN 111, "代    號:GC63"
            PRINT COLUMN   1, "作業日期:", p_rpt_beg_date,
                  COLUMN  45, "給付方式:",r_disb_desc,"-",r_acct_no
                                         ,"付款功能碼:",r_function_code,
                  COLUMN 111, "頁    次:", PAGENO USING "####"

            PRINT SetLine( "-",132 ) CLIPPED

            PRINT COLUMN   1, "保單號碼"    ,
                  COLUMN  14, "要保人"      ,
                  COLUMN  35, "PO-生效日"   ,
                  COLUMN  45, "週年日"      ,
                  COLUMN  53, "PO-ST"       ,
                  COLUMN  59, "繳法"        ,
                  COLUMN  64, "收費方式"    ,
                  COLUMN  73, "兌現"        ,
                  COLUMN  79, "支票日期"    ,
                  COLUMN  89, "繳費終日"    ,
                  COLUMN  99, "還款收據"    ,
                  COLUMN 110, "業務員"

            PRINT COLUMN   1, "月給付"      ,  -- 105/04/01
                  COLUMN  14, "險種"        ,
                  COLUMN  34, "保額"        ,
                  COLUMN  42, "應付金額"    ,
                  COLUMN  55, "(+)溢繳"     ,
                  COLUMN  67, "(+)紅利"     ,
                  COLUMN  75, "(-)貸款本利" ,
                  COLUMN  87, "(-)墊繳本利" ,
                  COLUMN 103, "(-)欠繳"     ,
                  COLUMN 112, "(=)實付金額" ,
                  COLUMN 125, "通訊單位"

            PRINT COLUMN  14, "受益人"      ,
                  COLUMN  36, "順序"        ,
                  COLUMN  43, "受益比率%"   ,
                  COLUMN  57, "分配金額"    ,
                  COLUMN  68, "銀行"        ,
                  COLUMN  76, "帳號"        ,
                  COLUMN 110, "付款號碼"

            PRINT SetLine( "-",132 ) CLIPPED

        BEFORE GROUP OF r_cp_disb_type
               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET r_page_count          =0
               LET r_28250019_cnt        =0
               LET r_28250019_amt        =0
               LET r_11780300_cnt        =0
               LET r_11780300_amt        =0
               LET r_row_count           =0
               SKIP TO TOP OF PAGE

        ON EVERY ROW
           IF r_have_data="Y" THEN
              LET r_loan_amt=p_cp_pay_detail.rtn_loan_amt
                            +p_cp_pay_detail.rtn_loan_int
              LET r_apl_amt =p_cp_pay_detail.rtn_apl_amt
                            +p_cp_pay_detail.rtn_apl_int
              LET r_div_amt =p_cp_pay_detail.accumulated_div
                            +p_cp_pay_detail.div_int_balance
                            +p_cp_pay_detail.div_int

              LET r_total_cnt           =r_total_cnt+1
              LET r_total_payamt        =r_total_payamt
                                        +p_cp_pay_detail.cp_amt
              LET r_total_supprem       =r_total_supprem
                                        +p_cp_pay_detail.prem_susp
              LET r_total_divamt        =r_total_divamt
                                        +r_div_amt
              LET r_total_loanamt       =r_total_loanamt
                                        +r_loan_amt
              LET r_total_aplamt        =r_total_aplamt
                                        +r_apl_amt
              LET r_total_minus_supprem =r_total_minus_supprem
                                        +p_cp_pay_detail.rtn_minus_premsusp

--            LET r_total_realamt       =r_total_realamt
--                                      +p_cp_pay_detail.cp_pay_amt


              PRINT COLUMN   1,r_policy_no             ,  -- 保單號碼   --
                    COLUMN  14,r_applicant_name[1,20]  ,  -- 要保人     --
                    COLUMN  35,p_cp_pay_detail.po_issue_date
                                                       ,  -- po_issue_d --
                    COLUMN  45,r_cp_anniv_date         ,  -- cp_anniv_d --
                    COLUMN  55,r_po_sts_code           ,  -- po_sts     --
                    COLUMN  60,r_modx  USING "###"     ,  -- modx       --
                    COLUMN  68,r_method                ,  -- method     --
                    COLUMN  75," "                     ,  -- chk_sw     --
                    COLUMN  79,p_cp_pay_detail.cp_chk_date
                                                       ,  -- chk_date   --
                    COLUMN  89,p_cp_pay_detail.paid_to_date
                                                       ,  -- paid_to_d  --
                    COLUMN  99,p_cp_pay_detail.rtn_rece_no
                                                       ,  -- rtn_rece_no--
                    COLUMN 110,r_agent_name[1,20]         -- agent_name --

              LET r_page_count=r_page_count+1
              PRINT COLUMN   1,r_payout_date_from       , -- 月給付   -- 105/04/01
                    COLUMN  14,p_cp_pay_detail.plan_code,'-',
                               p_cp_pay_detail.rate_scale
                                                        ,  -- 險種       --
                    COLUMN  25,p_cp_pay_detail.face_amt USING "#,###,###,###"
                                                        ,  -- 保額       --
                    COLUMN  39,p_cp_pay_detail.cp_amt   USING "###,###,###"
                                                        ,  -- 應付金額   --
                    COLUMN  51,p_cp_pay_detail.prem_susp USING "###,###,###"
                                                        ,  -- (+)溢繳    --
                    COLUMN  63,r_div_amt                USING "###,###,###"
                                                        ,  -- (+)紅利    --
                    COLUMN  75,r_loan_amt               USING "###,###,###"
                                                        ,  -- (-)貸款本息--
                    COLUMN  87,r_apl_amt                USING "###,###,###"
                                                        ,  -- (-)墊繳本息--
                    COLUMN  99,p_cp_pay_detail.rtn_minus_premsusp
                                                        USING "###,###,###"
                                                        ,  -- (-)欠繳    --
                    COLUMN 111,p_cp_pay_detail.cp_pay_amt USING "----,---,--&"
                                                        ,  -- (=)實付金額--
                    COLUMN 125,p_cp_pay_detail.dept_code  -- 通訊單位 --

              LET r_page_count=r_page_count+1
              LET r_row_count=r_row_count+1
              IF p_cp_pay_detail.cp_pay_amt <0 THEN
                 LET r_11780300_cnt=r_11780300_cnt+1
                 LET r_11780300_amt=r_11780300_amt+p_cp_pay_detail.cp_pay_amt
              END IF

              IF r_cp_pay_detail_sw ="1" THEN -- 無受益人資料 --
                 FOR r_i=1 TO r_pscd_cnt
                     IF p_pscd_r[r_i].cp_real_payamt !=0 THEN
                        LET r_page_count   =r_page_count+1
                        LET r_disb_cnt     =r_disb_cnt+1
                        IF p_pscd_r[r_i].cp_real_payamt < 0 THEN
                           LET r_11780300_cnt=r_11780300_cnt+1
                           LET r_11780300_amt=r_11780300_amt
                                             -p_pscd_r[r_i].cp_real_payamt
                        ELSE
                           LET r_28250019_cnt=r_28250019_cnt+1
                           LET r_28250019_amt=r_28250019_amt
                                             +p_pscd_r[r_i].cp_real_payamt
                        END IF

                        PRINT COLUMN   14,p_pscd_r[r_i].names[1,20]    , -- 受益人 --
                              COLUMN   36,p_pscd_r[r_i].cp_pay_seq
                                          USING "####"                 , -- 順序   --
                              COLUMN   46,p_pscd_r[r_i].benf_ratio
                                          USING "###"                  , -- 分配率 --
                              COLUMN   53,p_pscd_r[r_i].cp_real_payamt
                                          USING "----,---,--&"         , -- 分配金額 --
                              COLUMN   68,p_pscd_r[r_i].remit_bank
                                         ,p_pscd_r[r_i].remit_branch   , -- 銀行     --
                              COLUMN   76,p_pscd_r[r_i].remit_account  , -- 帳號     --
                              COLUMN  110,p_pscd_r[r_i].disb_no          -- 付款號碼 --
                     END IF
                 END FOR
              END IF
              PRINT COLUMN   1," "
              IF r_page_count >= 30 
              OR r_row_count  == 10
              THEN
                 LET r_page_count=0
                 LET r_row_cnt=r_row_count   --紀錄該頁印出幾筆資料
                 LET r_row_count =0
                 SKIP 1 LINE
                 PRINT SetLine("-",62 ) CLIPPED,"續下頁",SetLine("-",62)
                 PRINT COLUMN 92,"本頁資料筆數：",r_row_cnt USING "<<<<","筆"
                 SKIP TO TOP OF PAGE
              END IF
           END IF

        AFTER GROUP OF r_cp_disb_type
           PRINT COLUMN  24,"應付值:"   ,r_total_payamt USING "#,###,###,##&"," 元",
                 COLUMN  50,"(+)溢繳:"  ,r_total_supprem USING "#,###,###,##&"," 元",
                 COLUMN  77,"(+)紅利:"  ,r_total_divamt USING "#,###,###,##&"," 元"

           PRINT COLUMN  21,"(-)貸  款:",r_total_loanamt USING "#,###,###,##&"," 元",
                 COLUMN  50,"(-)墊繳:"  ,r_total_aplamt  USING "#,###,###,##&"," 元",
                 COLUMN  77,"(-)欠繳:"  ,r_total_minus_supprem USING "#,###,###,##&"," 元"

           PRINT COLUMN  22,r_acct_no,":",r_28250019_cnt USING "###,##&",
                            "件",
                 COLUMN  49,"合計金額:",r_28250019_amt USING "#,###,###,##&"," 元"
           PRINT COLUMN  22,"11780300:",r_11780300_cnt USING "###,##&","件",
                 COLUMN  49,"合計金額:",r_11780300_amt USING "#,###,###,##&"," 元"
           SKIP  2 LINE

           PRINT COLUMN   3,"(副)總經理:_____________________",
                 COLUMN  37,  "部門主管:_____________________",
                 COLUMN  68,  "單位主管:_____________________",
                 COLUMN  99,    "請款人:_____________________"

        LET r_row_count=0

        ON LAST ROW
           PRINT ASCII 12
END REPORT -- cp_pay_unnormal 生存明細控制報表 --

-------------------------------------------------------------------------------
-- 報表名稱:cp_pay_post
-- 作    者:jessica Chang
-- 日    期:087/02/03
-- 處理概要:滿期/還本給付明細大宗掛號函列印
-- table   :pscr
-- inp para:列印日
-- return 的參數:
-- 重要函式:
-------------------------------------------------------------------------------
REPORT cp_pay_post     (r_cp_pay_form_type -- 給付格式 --
                       ,r_policy_no        -- 保單號碼 --
                       ,r_cp_anniv_date    -- 還本週年日 --
                       ,r_zip_code         -- 郵遞區號 --
                       ,r_address          -- 郵寄地址 --
                       ,r_applicant_name   -- 要保人   --
                       ,r_cp_disb_type     -- 給付方式   --
                       ,r_benf_name_1      -- 受益人姓名1 --
                       ,r_benf_name_2      -- 受益人姓名2 --
                       ,r_benf_name_3      -- 受益人姓名3 --
                       ,r_benf_name_4      -- 受益人姓名4 --
                       ,r_pscd_cnt         -- 受益人筆數 --
                       )

    DEFINE  r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_zip_code            LIKE addr.zip_code
           ,r_address             LIKE addr.address
           ,r_applicant_name      LIKE clnt.names
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_benf_name_1         LIKE clnt.names
           ,r_benf_name_2         LIKE clnt.names
           ,r_benf_name_3         LIKE clnt.names
           ,r_benf_name_4         LIKE clnt.names
           ,r_pscd_cnt            INTEGER

    DEFINE  r_addr_1              CHAR(36)
           ,r_addr_2              CHAR(36)

    DEFINE  r_print_sw            CHAR(1)
           ,r_page_count          INTEGER
           ,r_disb_desc           CHAR(8)
           ,r_i                   INTEGER
           ,r_j                   INTEGER
           ,r_last_count          INTEGER
           ,r_payform_var         CHAR(100)
           ,r_print_head_sw       CHAR(1)
           ,r_print_first         CHAR(1)
           ,r_pageno              INTEGER
           ,r_recv_note_name      LIKE clnt.names

    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER EXTERNAL BY r_cp_disb_type
            ,r_policy_no
            ,r_cp_anniv_date

    FORMAT

       PAGE HEADER
            IF PAGENO=1 THEN
               LET r_pageno=0
               LET r_page_count=0
            END IF

            CASE
               WHEN r_cp_disb_type="0" -- 郵寄支票 --
                    LET r_disb_desc="郵寄支票"
               WHEN r_cp_disb_type="4" -- 業務代領 --
                    LET r_disb_desc="未回領取"
               WHEN r_cp_disb_type="3" -- 電    匯 --
                    LET r_disb_desc="電    匯"
            END CASE

            PRINT ASCII 27,"E",ASCII 27,"A",ASCII 27,"z1",
                  ASCII 27,"90033",ASCII 27,"80060"

            SKIP 4 LINES

            PRINT ASCII 27,"611"

            LET r_pageno=r_pageno+1

            LET r_payform_var=p_payform_init
            LET r_payform_var=p_payform_3[2]
            LET r_payform_var[ 8,20]=r_disb_desc,"-滿期"
            LET r_payform_var[80,83]=r_pageno USING "###&"
            LET p_payform_3[2]=r_payform_var
            LET r_payform_var=p_payform_init
            LET r_payform_var=p_payform_3[7]
            LET r_payform_var[70,72]=p_rpt_beg_date[1,3]
            LET r_payform_var[75,76]=p_rpt_beg_date[5,6]
            LET r_payform_var[79,80]=p_rpt_beg_date[8,9]
            LET p_payform_3[7]=r_payform_var

            PRINT COLUMN 1,p_payform_3[1]  CLIPPED
            PRINT COLUMN 1,p_payform_3[2]  CLIPPED
            PRINT COLUMN 1,p_payform_3[3]  CLIPPED
            PRINT COLUMN 1,p_payform_3[4]  CLIPPED
            PRINT COLUMN 1,p_payform_3[5]  CLIPPED
            PRINT COLUMN 1,p_payform_3[6]  CLIPPED
            PRINT COLUMN 1,p_payform_3[7]  CLIPPED
            PRINT COLUMN 1,p_payform_3[8]  CLIPPED
            PRINT COLUMN 1,p_payform_3[9]  CLIPPED
            PRINT COLUMN 1,p_payform_3[10] CLIPPED
            PRINT COLUMN 1,p_payform_3[11] CLIPPED
            PRINT COLUMN 1,p_payform_3[12] CLIPPED
            PRINT COLUMN 1,p_payform_3[13] CLIPPED

       BEFORE GROUP OF r_cp_disb_type 
              LET r_page_count=0
              SKIP TO TOP OF PAGE
 
       ON EVERY ROW

          FOR r_i=1 TO r_pscd_cnt
              IF p_pscd_r[r_i].cp_real_payamt !=0 THEN

                 CASE r_i
                 WHEN 1
                      LET r_recv_note_name = r_benf_name_1
                 WHEN 2
                      LET r_recv_note_name = r_benf_name_2
                 WHEN 3 
                      LET r_recv_note_name = r_benf_name_3
                 WHEN 4
                      LET r_recv_note_name = r_benf_name_4
                 END CASE

                 -- 每 20 筆必須跳頁 --

                  IF r_page_count >= 20 THEN
                     LET r_payform_var=p_payform_init
                     LET r_payform_var=p_payform_3[18]
                     LET r_payform_var[69,71]=r_page_count USING "###"
                     LET p_payform_3[18]=r_payform_var
                     FOR r_j=16 TO 20
                         PRINT COLUMN 1,p_payform_3[r_j] CLIPPED
                     END FOR
                     LET r_page_count=0
                     SKIP TO TOP OF PAGE
                  END IF

                  LET r_page_count=r_page_count+1

                  CALL cut_string (r_address,LENGTH(r_address),36)
                  RETURNING r_addr_1,r_addr_2

                  LET r_payform_var=p_payform_init
                  LET r_payform_var=p_payform_3[14]
                  LET r_payform_var[18,37]=r_recv_note_name
                  LET r_payform_var[40,75]=r_addr_1 
                  LET p_payform_3[14]=r_payform_var

                  LET r_payform_var=p_payform_init
                  LET r_payform_var=p_payform_3[15]
                  LET r_payform_var[18,29]=r_policy_no
                  LET r_payform_var[40,75]=r_addr_2        
                  LET p_payform_3[15]=r_payform_var

                  PRINT COLUMN 1,p_payform_3[14] CLIPPED
                  PRINT COLUMN 1,p_payform_3[15] CLIPPED

              END IF -- p_pscd_r[r_i].cp_real_payamt !=0 --

          END FOR  -- 此張保單受益人筆數結束 --


      AFTER GROUP OF r_cp_disb_type

          -- 空的筆數 --

          LET r_last_count=20-r_page_count

          FOR r_i=1 TO r_last_count
              PRINT COLUMN 1,p_payform_7 CLIPPED
              PRINT COLUMN 1,p_payform_7 CLIPPED
          END FOR

          -- 每頁結束 --
          LET r_payform_var=p_payform_init
          LET r_payform_var=p_payform_3[18]
          LET r_payform_var[69,71]=r_page_count USING "###"
          LET p_payform_3[18]=r_payform_var

          FOR r_i=16 TO 20
              PRINT COLUMN 1,p_payform_3[r_i] CLIPPED
          END FOR

          PRINT COLUMN 39,"－－END－－"
          LET r_pageno=0
{
    ON LAST ROW
          PRINT COLUMN 39,"－－END－－"
}
END REPORT -- cp_pay_post 大宗掛號 --

-------------------------------------------------------------------------------
-- 程式名稱:psc03r01_init_array
-- 作    者:jessica Chang
-- 日    期:087/02/03
-- 處理概要:滿期/還本給付明細列印
--         :給付明細格式
-- return 的參數:
-- 重要函式:
-------------------------------------------------------------------------------
FUNCTION psc03r01_init_array()
    DEFINE f_rcode INTEGER

LET p_payform_5    ="            生  存  保  險  金  對  帳  單  明  細"
LET p_payform_6    ="            滿  期  保  險  金  對  帳  單  明  細"
LET p_payform_7    ="     │        │                    │                                            │"
LET p_payform_init ="                                                  "
                   ,"                                                  "
LET p_payform_0[1] ="ASC II","612"
LET p_payform_0[2] =p_payform_init
LET p_payform_0[3] ="ASC II","611 ","ASC II","90036 ","ASC II","80067"
LET p_payform_0[4] ="     保單號碼:xxxxxxxxxxxx         被保險人:xxxxxxxxxxxxxxxxxxxx          CPFORM:xxx"
LET p_payform_0[5] ="     受 益 人:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 日期: xxx年xx月xx日"
LET p_payform_0[6] ="     保險金額:x,xxx,xxx,xxx 元     保險種類:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
LET p_payform_0[7] =p_payform_init
LET p_payform_0[8] ="     親愛的保戶，您好！                                                             "
LET p_payform_0[9] =p_payform_init
LET p_payform_0[10]="     　  感謝您投保三商美邦人壽保險，希望我們誠摯的服務能獲得您最大的滿意。         "
LET p_payform_0[11]=p_payform_init

LET p_payform_1[1] ="      　 由於您所投保之保單於 xxx 年 xx 月 xx 日已屆滿保單週年日，本公司依據保單條款"
LET p_payform_1[2] ="     約定，給付生存保險金如下：                                                     "
LET p_payform_1[3] =p_payform_init
LET p_payform_1[4] ="                    生存保險金                   xxx,xxx,xxx 元                     "
LET p_payform_1[5] ="                          扣除:前期欠繳          xxx,xxx,xxx 元                     "
LET p_payform_1[6] ="                              :自動墊繳保費利息  xxx,xxx,xxx 元                     "
LET p_payform_1[7] ="                              :自動墊繳保費本金  xxx,xxx,xxx 元                     "
LET p_payform_1[8] ="                              :保單借款利息      xxx,xxx,xxx 元                     "
LET p_payform_1[9] ="                              :保單借款本金      xxx,xxx,xxx 元                     "
LET p_payform_1[10]="                      xxxxxxxx                   xxx,xxx,xxx 元                     "
LET p_payform_1[11]=p_payform_init
LET p_payform_2[1] ="    　　 由於您所投保之保單於 xxx 年 xx 月 xx 日保險期間屆滿，本公司依據保單條款約  "
LET p_payform_2[2] ="     定，給付滿期保險金如下：                                                       "
LET p_payform_2[3] =p_payform_init
LET p_payform_2[4] ="                   滿期保險金                    xxx,xxx,xxx 元                     "
LET p_payform_2[5] ="                           加:保單紅利           xxx,xxx,xxx 元                     "
LET p_payform_2[6] ="                              溢繳               xxx,xxx,xxx 元                     "
LET p_payform_2[7] ="                         扣除:前期欠繳           xxx,xxx,xxx 元                     "
LET p_payform_2[8] ="                             :自動墊繳保費利息   xxx,xxx,xxx 元                     "
LET p_payform_2[9] ="                             :自動墊繳保費本金   xxx,xxx,xxx 元                     "
LET p_payform_2[10]="                             :保單借款利息       xxx,xxx,xxx 元                     "
LET p_payform_2[11]="                             :保單借款本金       xxx,xxx,xxx 元                     "
LET p_payform_2[12]="                   應給付淨額                    xxx,xxx,xxx 元                     "
LET p_payform_2[13]=p_payform_init

LET p_payform_d[1] ="     給付明細:                                                                      "
LET p_payform_d[2] ="     序號 受益人              比率％     給付金額   付款號碼 匯款銀行與帳號         "
LET p_payform_d[3] ="     ---- -------------------- ----- -------------- -------- -----------------------"
{
LET p_payform_d[4] ="     xxxx xxxxxxxxxxxxxxxxxxxx xxx   xxxx,xxx,xxx元 xxxxxxx xxxxxxx-xxxxxxxxxxxxxxxx"
}
LET p_payform_e[1] ="      敬頌     時 祺                                                                "
LET p_payform_e[2] ="                                                三商美邦人壽保險股份有限公司  謹啟  "
LET p_payform_e[3] ="      還款收據：xxxxxxxxx                                                           "
LET p_payform_e[4] ="      通訊單位：xxxxxxxxxxxxxxxxxxxx                                                "
LET p_payform_e[5] ="      分 公 司：xxxxxxxxxxxxxxxxxxxx                                                "
LET p_payform_e[6] =p_payform_init
LET p_payform_e[7] =p_payform_init
LET p_payform_e[8] =p_payform_init
LET p_payform_e[9] =p_payform_init

-- 大宗掛號 --
LET p_payform_3[1] ="     ┌──────────────────────────────────────┐"
LET p_payform_3[2] ="     │xxxxxxxx-xxxx           中  華  民  國  郵  政                     頁碼:xxxx│"
LET p_payform_3[3] ="     │                                                                            │"
LET p_payform_3[4] ="     │滿期/還本 通知書專用                                                        │"
LET p_payform_3[5] ="     │                     大 宗 普 通 掛 號 函 件 收 執 聯                       │"
LET p_payform_3[6] ="     │                                                                            │"
LET p_payform_3[7] ="     │中華民國          年     月     日                   作業日期:xxx年xx月xx日 │"
LET p_payform_3[8] ="     │                                                                            │"
LET p_payform_3[9] ="     │寄件人名稱:  三商美邦人壽保險公司   詳細地址: 台北市信義路五段150巷2號6樓   │"
LET p_payform_3[10]="     └──────────────────────────────────────┘"
LET p_payform_3[11]="     ┌────┬──────────┬──────────────────────┐"
LET p_payform_3[12]="     │掛號號碼│ 收 件 人 姓 名     │    寄          達            地            │"
LET p_payform_3[13]="     �澺��������蕅��������������������蕅���������������������������������������������"
LET p_payform_3[14]="     │        │xxxxxxxxxxxxxxxxxxxx│xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx        │"
LET p_payform_3[15]="     │        │xxxxxxxxxxxx        │xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx        │"
LET p_payform_3[16]="     ├────┴──────────┴──────────────────────┤"
LET p_payform_3[17]="     │                                                                            │"
LET p_payform_3[18]="     │                                         上開普通掛號函/共   xxx  件照收無誤│"
LET p_payform_3[19]="     │                                                                            │"
LET p_payform_3[20]="     └──────────────────────────────────────┘"

LET f_rcode=0
RETURN f_rcode
END FUNCTION -- psc02r_init_array --
{
0        1         2         3         4         5         6         7         8         9         a         b         c         d
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
Ez090028800547005
                                     三  商  人  壽  保  險  股  份  有  限  公  司
                                  <<<           生存保險金給付明細控制報表         >>>
印表日期 :  87/07/27                                                                                          代    號: GC60
作業日期 :  87/09/05                        給付方式: 郵寄支票-214101000                                      頁    次: xxxx
------------------------------------------------------------------------------------------------------------------------------------
保單號碼     要保人               PO-生效日 週年日  PO_ST 繳法 收費方式 兌現  支票日期  繳費終日  還款收據   業務員
             險種                保額    應付金額     (+)溢繳     (+)紅利 (-)貸款本利 (-)墊繳本利     (-)欠繳  (=)實付金額  通訊單位
             受益人                順序   受益比例      分配金額   銀行    帳號              付款號碼
------------------------------------------------------------------------------------------------------------------------------------
xxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxx xxx/xx/xx xxx/xx/xx xx    x      x      x   xxx/xx/xx xxx/xx/xx xxxxxxxxxx xxxxxxxxxxxxxxxxxxxxx
             xxxxxxxx-x x,xxx,xxx,xxx xxx,xxx,xxx xxx,xxx,xxx xxx,xxx,xxx xxx,xxx,xxx xxx,xxx,xxx xxx,xxx,xxx  xxx,xxx,xxx  xxxxxx
             xxxxxxxxxxxxxxxxxxxx  xxxxxx    xxx     xxx,xxx,xxx   xxxxxxx xxxxxxxxxxxxxxxx  xxxxxxxx

xxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxx xxx/xx/xx  xxx/xx/xx   xx     x       x       x    xxx/xx/xx  xxx/xx/xx          xxxxxxxxxx
             xxxxxxxx-x   x,xxx,xxx,xxx  xxx,xxx,xxx  xxx,xxx,xxx  xxx,xxx,xxx   xxx,xxx,xxx   xxx,xxx,xxx  xxx,xxx,xxx xxx,xxx,xxx
             xxxxxxxxxxxxxxxxxxxx  xxxxxx    xxx     xxx,xxx,xxx   xxx   xxxxxxxxxxxxxxxx  xxxxxxxx
             xxxxxxxxxxxxxxxxxxxx  xxxxxx    xxx     xxx,xxx,xxx   xxx   xxxxxxxxxxxxxxxx  xxxxxxxx
             xxxxxxxxxxxxxxxxxxxx  xxxxxx    xxx     xxx,xxx,xxx   xxx   xxxxxxxxxxxxxxxx  xxxxxxxx
             xxxxxxxxxxxxxxxxxxxx  xxxxxx    xxx     xxx,xxx,xxx   xxx   xxxxxxxxxxxxxxxx  xxxxxxxx


    合計:zzz,zzz 件    應付值: x,xxx,xxx,xxx 元  (+)溢繳: x,xxx,xxx,xxx 元  (+)紅利: x,xxx,xxx,xxx 元
xxxxxxxx:xxx,xxx 件 (-)貸  款: x,xxx,xxx,xxx 元  (-)墊繳: x,xxx,xxx,xxx 元  (-)欠繳: x,xxx,xxx,xxx 元  (=)實付: x,xxx,xxx,xxx 元

       (副)總經理:______________________ 部門主管:___________________單位主管:____________________請款人:____________________

Ez090028800547005
                                     三  商  人  壽  保  險  股  份  有  限  公  司
                                 <<<   生 存 保 險 金 給 付 控 制 報 表 - 21410100  >>>
印表日期 :  87/09/08                                                                                          代 號:GC60
作業日期 :  87/09/07                        輸入日期:[ 87/09/07]                                              第    1 頁
------------------------------------------------------------------------------------------------------------------------------------
保單號碼     要保人                 保單生效日    受 益 人                 保單週年日   PO_ST       兌現        支票日期
             給付險種     保      額       應付值       貸款本利      墊繳本利           欠繳       實付金額     還款收據
             給付方式  受款人               受款人ID   銀行    帳號           通訊單位     業務員            PTD  收費方式  繳法
------------------------------------------------------------------------------------------------------------------------------------
111900010515 呂敏智                   85/09/20    呂敏智                     87/09/20     42          Y          00/00/00
             20FED20         500,000       50,000                                                     50,000     000000000
             郵寄支票                                                                                    00/00/00              
 

             合計:     59件       應付值:    2,896,007 元    貸款:            0 元
         21410100:     59件         墊繳:            0 元    欠繳:           31 元        實付:    2,895,976 元
 
 
 

(副)總經理:ˍˍˍˍˍˍˍˍˍˍˍ 部門主管:ˍˍˍˍˍˍˍˍˍˍ 單位主管:ˍˍˍˍˍˍˍˍˍˍˍ 請款人:ˍˍˍˍˍˍˍˍˍˍˍˍ
Ez090028800547005
                                     三  商  人  壽  保  險  股  份  有  限  公  司
                                 <<< 滿 期 保 險 金 給 付 控 制 報 表 - 票據已兌現  >>>
印表日期 :  87/09/08                        輸入日期:[ 87/09/07]                                                         代 號:GC70
作業日期 : 000/00/00                        單    位:[                    ]                                              第    1 頁
------------------------------------------------------------------------------------------------------------------------------------
保單號碼      要保人                保單生效日   受 益 人               保單週年日           兌現     支票日期
          給付險種    保      額      應付值      溢繳      預繳      紅利    貸款本利    墊繳本利      欠繳    實付金額   還款收據
------------------------------------------------------------------------------------------------------------------------------------
  無資料
------------------------------------------------------------------------------------------------------------------------------------

E A z1 90033 80060





                                                                                         ▔▔▔▔
                                                                                         ▔▔▔▔
                                                                                         ▔▔▔▔


          70942

          臺南市安南區安和路二段３１８巷３１號        

                                                      

          張淑惠               君親啟
                           




612
                            生  存  保  險  金  給  付  明  細
611 90036 80067
     保單號碼:174710006282         被保險人:張淑惠                       CPFORM:5.1 
     受 益 人:張淑惠               保險種類:二十年繳費盈福養老保險                  
     保險金額:    500,000 元       聯絡電話:06-2566650         日期:  87年 9月 7日

    　親愛的保戶，您好！

      　  感謝您投保三商人壽保險，希望我們誠摯的服務能獲得您最大的滿意。

     　　 由於您所投保之保單於  87 年  9 月  4 日已屆滿保單週年日，本公司依據保單條
      款約定，給付生存保險金如下：

                        生存保險金給付                50,000 元

                          扣除:前期欠繳                    0 元
                              :自動墊繳保費利息            0 元
                              :自動墊繳保費本金            0 元
                              :保單借款利息                0 元
                              :保單借款本金                0 元

                      支票金額                        50,000 元


      敬頌     時 祺

                                                    三商人壽保險股份有限公司  謹啟

      還款收據No: 000000000
      通訊單位  ：中華17471處         



      領款人簽章:                          日  期:
                 __________________               ___________________
      支票號碼  :                          承辦人:
                 __________________               ___________________
E
 
}
-------------------------------------------------------------------------------
-- 報表名稱:cp_pay_dtl_col_un
-- 作    者:yirong
-- 日    期:098/04/25
-- 處理概要:同意回流延遲控制表列印
-- table   :pscr
-- inp para:列印日
-- return 的參數:
-- 重要函式:
-------------------------------------------------------------------------------
REPORT cp_pay_dtl_col_un (r_have_data
                      ,r_cp_pay_form_type
                      ,r_policy_no
                      ,r_cp_anniv_date
                      ,r_applicant_name
                      ,r_dept_name
                      ,r_cp_pay_detail_sw
                      ,r_cp_disb_type
                      ,r_recv_note_name
                      ,r_agent_name
                      ,r_pscd_cnt
                      ,r_po_sts_code
                      ,r_modx
                      ,r_method
                      ,r_dept_belong
                      ,r_dept_adm_name
                      ,r_function_code
                      )

    DEFINE  r_have_data           CHAR(1)
           ,r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_applicant_name      LIKE clnt.names
           ,r_dept_name           LIKE dept.dept_name
           ,r_plan_desc           LIKE pldf.plan_desc
           ,r_cp_pay_detail_sw    CHAR(1)
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_recv_note_name      LIKE clnt.names
           ,r_agent_name          LIKE clnt.names
           ,r_pscd_cnt            INTEGER
           ,r_po_sts_code         LIKE polf.po_sts_code
           ,r_modx                LIKE polf.modx
           ,r_method              LIKE polf.method
           ,r_dept_belong         LIKE dept.dept_belong
           ,r_dept_adm_name       LIKE dept.dept_name
--           ,r_function_code       CHAR(2)
           ,r_function_code       VARCHAR(10)

    DEFINE r_acct_no             CHAR(8)  -- 給付科目 --
          ,r_disb_desc           CHAR(8)  -- 給付方式說明 --

    DEFINE r_rpt_yy              INTEGER
          ,r_rpt_mm              INTEGER
          ,r_rpt_dd              INTEGER
          ,r_anniv_yy            INTEGER
          ,r_anniv_mm            INTEGER
          ,r_anniv_dd            INTEGER

    DEFINE r_loan_amt            INTEGER
          ,r_apl_amt             INTEGER
          ,r_div_amt             INTEGER

    DEFINE r_total_cnt           INTEGER -- 合計:件數 --
          ,r_total_payamt        INTEGER -- 應付值    --
          ,r_total_supprem       INTEGER -- 溢繳      --
          ,r_total_divamt        INTEGER -- 紅利      --
          ,r_disb_cnt            INTEGER -- 付款合計  --
          ,r_total_loanamt       INTEGER -- 貸款      --
          ,r_total_aplamt        INTEGER -- 墊繳      --
          ,r_total_minus_supprem INTEGER -- 欠繳      --
          ,r_total_realamt       INTEGER -- 實付      --
          ,r_11780300_cnt        INTEGER
          ,r_11780300_amt        INTEGER
          ,r_28250019_cnt        INTEGER
          ,r_28250019_amt        INTEGER


    DEFINE r_payform_var         CHAR(100)
          ,r_i                   INTEGER
          ,r_page_count          INTEGER

    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER EXTERNAL BY r_cp_disb_type
            ,r_policy_no
            ,r_cp_anniv_date

    FORMAT

        PAGE HEADER
            IF PAGENO=1 THEN
               LET r_page_count =0

               LET r_loan_amt            =0
               LET r_apl_amt             =0
               LET r_div_amt             =0

               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0

               LET r_28250019_cnt        =0
               LET r_28250019_amt        =0
               LET r_11780300_cnt        =0
               LET r_11780300_amt        =0

            END IF

            CASE
                WHEN r_cp_disb_type="0"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="郵寄支票"
                WHEN r_cp_disb_type="4"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="未回領取"
                WHEN r_cp_disb_type="2"
                     LET r_acct_no="28250001"
                     LET r_disb_desc="抵繳保費"
                WHEN r_cp_disb_type="3"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="電    匯"
                WHEN r_cp_disb_type="6"
                     LET r_acct_no="28250027"
                     LET r_disb_desc="還本回流"

            END CASE
            IF r_cp_disb_type="6" THEN
               LET r_acct_no="28250027"
            ELSE
               LET r_acct_no="28250019"
            END IF
      --    LET g_report_corp="三 商 美 邦 人 壽 保 險 股 份 有 限 公 司"
      --    LET g_report_name="滿期給付明細控制報表"
            LET g_report_name=p_rpt_name_2

            PRINT          ASCII  27, "E",     ASCII  27, "z0"
                          ,ASCII  27, "90028", ASCII 27, "80054"
                          ,ASCII  27, "7005"
            PRINT COLUMN CenterPosition( g_report_corp,132 ),
                         g_report_corp CLIPPED,
                    COLUMN  119 ,p_name CLIPPED
{
            PRINT COLUMN  CenterPosition( g_report_corp,132 ),
                          g_report_corp CLIPPED

            PRINT COLUMN  CenterPosition( g_report_name,132 ),
                          g_report_name CLIPPED
}
            PRINT COLUMN  CenterPosition( '回流同意/延遲符合資格控制報表',132 ),
                          '回流同意/延遲符合資格控制報表' CLIPPED

            PRINT COLUMN   1, "印表日期:", GetDate(TODAY),
                  COLUMN 111, "代    號:GC102"
            PRINT COLUMN   1, "作業日期:", p_rpt_beg_date,
                  COLUMN  45, "給付方式:",r_disb_desc,"-",r_acct_no
                                         ,"付款功能碼:",r_function_code,
                  COLUMN 111, "頁    次:", PAGENO USING "####"

            PRINT SetLine( "-",132 ) CLIPPED

            PRINT COLUMN   1, "保單號碼"    ,
                  COLUMN  14, "要保人"      ,
                  COLUMN  35, "PO-生效日"   ,
                  COLUMN  45, "週年日"      ,
                  COLUMN  53, "PO-ST"       ,
                  COLUMN  59, "繳法"        ,
                  COLUMN  64, "收費方式"    ,
                  COLUMN  73, "兌現"        ,
                  COLUMN  79, "支票日期"    ,
                  COLUMN  89, "繳費終日"    ,
                  COLUMN  99, "還款收據"    ,
                  COLUMN 110, "業務員"

            PRINT COLUMN  14, "險種"        ,
                  COLUMN  34, "保額"        ,
                  COLUMN  42, "應付金額"    ,
                  COLUMN  55, "(+)溢繳"     ,
                  COLUMN  67, "(+)紅利"     ,
                  COLUMN  75, "(-)貸款本利" ,
                  COLUMN  87, "(-)墊繳本利" ,
                  COLUMN 103, "(-)欠繳"     ,
                  COLUMN 112, "(=)實付金額" ,
                  COLUMN 125, "通訊單位"

            PRINT COLUMN  14, "受益人"      ,
                  COLUMN  36, "順序"        ,
                  COLUMN  43, "受益比率%"   ,
                  COLUMN  57, "分配金額"    ,
                  COLUMN  68, "銀行"        ,
                  COLUMN  76, "帳號"        ,
                  COLUMN 110, "付款號碼"

            PRINT SetLine( "-",132 ) CLIPPED

        BEFORE GROUP OF r_cp_disb_type
               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET r_page_count          =0
               LET r_28250019_cnt        =0
               LET r_28250019_amt        =0
               LET r_11780300_cnt        =0
               LET r_11780300_amt        =0
               SKIP TO TOP OF PAGE

        ON EVERY ROW
           IF r_have_data="Y" THEN
              LET r_loan_amt=p_cp_pay_detail.rtn_loan_amt
                            +p_cp_pay_detail.rtn_loan_int
              LET r_apl_amt =p_cp_pay_detail.rtn_apl_amt
                            +p_cp_pay_detail.rtn_apl_int
              LET r_div_amt =p_cp_pay_detail.accumulated_div
                            +p_cp_pay_detail.div_int_balance
                            +p_cp_pay_detail.div_int

              LET r_total_cnt           =r_total_cnt+1
              LET r_total_payamt        =r_total_payamt
                                        +p_cp_pay_detail.cp_amt
              LET r_total_supprem       =r_total_supprem
                                        +p_cp_pay_detail.prem_susp
              LET r_total_divamt        =r_total_divamt
                                        +r_div_amt
              LET r_total_loanamt       =r_total_loanamt
                                        +r_loan_amt
              LET r_total_aplamt        =r_total_aplamt
                                        +r_apl_amt
              LET r_total_minus_supprem =r_total_minus_supprem
                                        +p_cp_pay_detail.rtn_minus_premsusp

--            LET r_total_realamt       =r_total_realamt
--                                      +p_cp_pay_detail.cp_pay_amt


              PRINT COLUMN   1,r_policy_no             ,  -- 保單號碼   --
                    COLUMN  14,r_applicant_name[1,20]  ,  -- 要保人     --
                    COLUMN  35,p_cp_pay_detail.po_issue_date
                                                       ,  -- po_issue_d --
                    COLUMN  45,r_cp_anniv_date         ,  -- cp_anniv_d --
                    COLUMN  55,r_po_sts_code           ,  -- po_sts     --
                    COLUMN  60,r_modx  USING "###"     ,  -- modx       --
                    COLUMN  68,r_method                ,  -- method     --
                    COLUMN  75," "                     ,  -- chk_sw     --
                    COLUMN  79,p_cp_pay_detail.cp_chk_date
                                                       ,  -- chk_date   --
                    COLUMN  89,p_cp_pay_detail.paid_to_date
                                                       ,  -- paid_to_d  --
                    COLUMN  99,p_cp_pay_detail.rtn_rece_no
                                                       ,  -- rtn_rece_no--
                    COLUMN 110,r_agent_name[1,20]         -- agent_name --

              LET r_page_count=r_page_count+1
              PRINT COLUMN  14,p_cp_pay_detail.plan_code,'-',
                               p_cp_pay_detail.rate_scale
                                                        ,  -- 險種       --
                    COLUMN  25,p_cp_pay_detail.face_amt USING "#,###,###,###"
                                                        ,  -- 保額       --
                    COLUMN  39,p_cp_pay_detail.cp_amt   USING "###,###,###"
                                                        ,  -- 應付金額   --
                    COLUMN  51,p_cp_pay_detail.prem_susp USING "###,###,###"
                                                        ,  -- (+)溢繳    --
                    COLUMN  63,r_div_amt                USING "###,###,###"
                                                        ,  -- (+)紅利    --
                    COLUMN  75,r_loan_amt               USING "###,###,###"
                                                        ,  -- (-)貸款本息--
                    COLUMN  87,r_apl_amt                USING "###,###,###"
                                                        ,  -- (-)墊繳本息--
                    COLUMN  99,p_cp_pay_detail.rtn_minus_premsusp
                                                        USING "###,###,###"
                                                        ,  -- (-)欠繳    --
                    COLUMN 111,p_cp_pay_detail.cp_pay_amt USING "----,---,--&"
                                                        ,  -- (=)實付金額--
                    COLUMN 125,p_cp_pay_detail.dept_code  -- 通訊單位 --

              LET r_page_count=r_page_count+1

              IF p_cp_pay_detail.cp_pay_amt < 0 THEN
                 LET r_11780300_cnt=r_11780300_cnt+1
                 LET r_11780300_amt=r_11780300_amt+p_cp_pay_detail.cp_pay_amt
              END IF
              IF r_cp_pay_detail_sw ="1" THEN -- 無受益人資料 --
                 FOR r_i=1 TO r_pscd_cnt
                     IF p_pscd_r[r_i].cp_real_payamt !=0 THEN
                        LET r_page_count   =r_page_count+1
                        LET r_disb_cnt     =r_disb_cnt+1
                        IF p_pscd_r[r_i].cp_real_payamt < 0 THEN
                           LET r_11780300_cnt=r_11780300_cnt+1
                           LET r_11780300_amt=r_11780300_amt
                                             -p_pscd_r[r_i].cp_real_payamt
                        ELSE
                           LET r_28250019_cnt=r_28250019_cnt+1
                           LET r_28250019_amt=r_28250019_amt
                                             +p_pscd_r[r_i].cp_real_payamt
                        END IF

                        PRINT COLUMN   14,p_pscd_r[r_i].names[1,20]    , -- 受益
                              COLUMN   36,p_pscd_r[r_i].cp_pay_seq
                                          USING "####"                 , -- 順序
                              COLUMN   46,p_pscd_r[r_i].benf_ratio
                                          USING "###"                  , -- 分配
                              COLUMN   53,p_pscd_r[r_i].cp_real_payamt
                                          USING "----,---,--&"         , -- 分配
                              COLUMN   68,p_pscd_r[r_i].remit_bank
                                         ,p_pscd_r[r_i].remit_branch   , -- 銀行
                              COLUMN   76,p_pscd_r[r_i].remit_account  , -- 帳號
                              COLUMN   94,p_pscd_r[r_i].disb_no          -- 付款
                     END IF
                 END FOR
              END IF
              PRINT COLUMN   1," "
              IF r_page_count = 30 THEN
                 LET r_page_count=0
                 SKIP TO TOP OF PAGE
              END IF
           END IF

        AFTER GROUP OF r_cp_disb_type
           PRINT COLUMN  24,"應付值:"   ,r_total_payamt USING "#,###,###,##&"," 元",
                 COLUMN  50,"(+)溢繳:"  ,r_total_supprem USING "#,###,###,##&"," 元",
                 COLUMN  77,"(+)紅利:"  ,r_total_divamt USING "#,###,###,##&"," 元"

           PRINT COLUMN  21,"(-)貸  款:",r_total_loanamt USING "#,###,###,##&"," 元",
                 COLUMN  50,"(-)墊繳:"  ,r_total_aplamt  USING "#,###,###,##&"," 元",
                 COLUMN  77,"(-)欠繳:"  ,r_total_minus_supprem USING "#,###,###,##&"," 元"

           PRINT COLUMN  22,r_acct_no,":",r_28250019_cnt USING "###,##&",
                            "件",
                 COLUMN  49,"合計金額:",r_28250019_amt USING "#,###,###,##&"," 元"
           PRINT COLUMN  22,"11780300:",r_11780300_cnt USING "###,##&","件",
                 COLUMN  49,"合計金額:",r_11780300_amt USING "#,###,###,##&"," 元"
           SKIP  2 LINE

           PRINT COLUMN   3,"(副)總經理:_____________________",
                 COLUMN  37,  "部門主管:_____________________",
                 COLUMN  68,  "單位主管:_____________________",
                 COLUMN  99,    "請款人:_____________________"

        ON LAST ROW
           PRINT ASCII 12

END REPORT -- cp_pay_dtl_col 滿期金給付控制報表 --
-------------------------------------------------------------------------------
-- 報表名稱:cp_pay_dtl_col_50
-- 作    者:yirong
-- 日    期:098/12/24
-- 處理概要:滿期給付明細控制表列印
-- table   :pscr
-- inp para:列印日
-- return 的參數:
-- 重要函式:
-------------------------------------------------------------------------------
REPORT cp_pay_dtl_col_50 (r_have_data
                      ,r_cp_pay_form_type
                      ,r_policy_no
                      ,r_cp_anniv_date
                      ,r_applicant_name
                      ,r_dept_name
                      ,r_cp_pay_detail_sw
                      ,r_cp_disb_type
                      ,r_recv_note_name
                      ,r_agent_name
                      ,r_pscd_cnt
                      ,r_po_sts_code
                      ,r_modx
                      ,r_method
                      ,r_dept_belong
                      ,r_dept_adm_name
                      ,r_function_code
                      )

    DEFINE  r_have_data           CHAR(1)
           ,r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_applicant_name      LIKE clnt.names
           ,r_dept_name           LIKE dept.dept_name
           ,r_plan_desc           LIKE pldf.plan_desc
           ,r_cp_pay_detail_sw    CHAR(1)
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_recv_note_name      LIKE clnt.names
           ,r_agent_name          LIKE clnt.names
           ,r_pscd_cnt            INTEGER
           ,r_po_sts_code         LIKE polf.po_sts_code
           ,r_modx                LIKE polf.modx
           ,r_method              LIKE polf.method
           ,r_dept_belong         LIKE dept.dept_belong
           ,r_dept_adm_name       LIKE dept.dept_name
--           ,r_function_code       CHAR(2)
           ,r_function_code       VARCHAR(10)
           
    DEFINE r_acct_no             CHAR(8)  -- 給付科目 --
          ,r_disb_desc           CHAR(8)  -- 給付方式說明 --

    DEFINE r_rpt_yy              INTEGER
          ,r_rpt_mm              INTEGER
          ,r_rpt_dd              INTEGER
          ,r_anniv_yy            INTEGER
          ,r_anniv_mm            INTEGER
          ,r_anniv_dd            INTEGER

    DEFINE r_loan_amt            INTEGER
          ,r_apl_amt             INTEGER
          ,r_div_amt             INTEGER

    DEFINE r_total_cnt           INTEGER -- 合計:件數 --
          ,r_total_payamt        INTEGER -- 應付值    --
          ,r_total_supprem       INTEGER -- 溢繳      --
          ,r_total_divamt        INTEGER -- 紅利      --
          ,r_disb_cnt            INTEGER -- 付款合計  --
          ,r_total_loanamt       INTEGER -- 貸款      --
          ,r_total_aplamt        INTEGER -- 墊繳      --
          ,r_total_minus_supprem INTEGER -- 欠繳      --
          ,r_total_realamt       INTEGER -- 實付      --
          ,r_11780300_cnt        INTEGER
          ,r_11780300_amt        INTEGER
          ,r_28250019_cnt        INTEGER
          ,r_28250019_amt        INTEGER


    DEFINE r_payform_var         CHAR(100)
          ,r_i                   INTEGER
          ,r_row_count           INTEGER
          ,r_row_cnt             INTEGER
          ,r_page_count          INTEGER

    DEFINE for_100w              VARCHAR(10)

    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER EXTERNAL BY r_cp_disb_type
            ,r_policy_no
            ,r_cp_anniv_date

    FORMAT

        PAGE HEADER
            IF PAGENO=1 THEN
               LET r_page_count =0

               LET r_loan_amt            =0
               LET r_apl_amt             =0
               LET r_div_amt             =0

               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0

               LET r_28250019_cnt        =0
               LET r_28250019_amt        =0
               LET r_11780300_cnt        =0
               LET r_11780300_amt        =0
               LET for_100w              =''
            END IF

            LET r_row_count           =0

            CASE
                WHEN r_cp_disb_type="0"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="郵寄支票"
                     LET for_100w=''
                WHEN r_cp_disb_type="2"
                     LET r_acct_no="28250001"
                     LET r_disb_desc="抵繳保費"
                     LET for_100w=''
                WHEN r_cp_disb_type="3"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="電    匯"
                     LET for_100w="≧100萬"
                WHEN r_cp_disb_type="4"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="未回領取"
                     LET for_100w=''
                WHEN r_cp_disb_type="5"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="主動電匯"
                     LET for_100w="≧100萬"
                WHEN r_cp_disb_type="6"
                     LET r_acct_no="28250027"
                     LET r_disb_desc="還本回流"
                     LET for_100w=''
            END CASE

            IF r_cp_disb_type="6" THEN
               LET r_acct_no="28250027"
            ELSE
               LET r_acct_no="28250019"
            END IF
      --    LET g_report_corp="三 商 美 邦 人 壽 保 險 股 份 有 限 公 司"
      --    LET g_report_name="滿期給付明細控制報表"
            LET g_report_name=p_rpt_name_2

            PRINT          ASCII  27, "E",     ASCII  27, "z0"
                          ,ASCII  27, "90028", ASCII 27, "80054"
                          ,ASCII  27, "7005"
            PRINT COLUMN CenterPosition( g_report_corp,132 ),
                         g_report_corp CLIPPED,
                    COLUMN  119 ,p_name CLIPPED
{
            PRINT COLUMN  CenterPosition( g_report_corp,132 ),
                          g_report_corp CLIPPED
}
            PRINT COLUMN  CenterPosition( g_report_name,132 ),
                          g_report_name CLIPPED,for_100w
            PRINT COLUMN   1, "印表日期:", GetDate(TODAY),
                  COLUMN 111, "代    號:GC61"
            PRINT COLUMN   1, "作業日期:", p_rpt_beg_date,
                  COLUMN  45, "給付方式:",r_disb_desc,"-",r_acct_no
                                         ,"付款功能碼:",r_function_code,
                  COLUMN 111, "頁    次:", PAGENO USING "####"

            PRINT SetLine( "-",132 ) CLIPPED

            PRINT COLUMN   1, "保單號碼"    ,
                  COLUMN  14, "要保人"      ,
                  COLUMN  35, "PO-生效日"   ,
                  COLUMN  45, "週年日"      ,
                  COLUMN  53, "PO-ST"       ,
                  COLUMN  59, "繳法"        ,
                  COLUMN  64, "收費方式"    ,
                  COLUMN  73, "兌現"        ,
                  COLUMN  79, "支票日期"    ,
                  COLUMN  89, "繳費終日"    ,
                  COLUMN  99, "還款收據"    ,
                  COLUMN 110, "業務員"

            PRINT COLUMN  14, "險種"        ,
                  COLUMN  34, "保額"        ,
                  COLUMN  42, "應付金額"    ,
                  COLUMN  55, "(+)溢繳"     ,
                  COLUMN  67, "(+)紅利"     ,
                  COLUMN  75, "(-)貸款本利" ,
                  COLUMN  87, "(-)墊繳本利" ,
                  COLUMN 103, "(-)欠繳"     ,
                  COLUMN 112, "(=)實付金額" ,
                  COLUMN 125, "通訊單位"

            PRINT COLUMN  14, "受益人"      ,
                  COLUMN  36, "順序"        ,
                  COLUMN  43, "受益比率%"   ,
                  COLUMN  57, "分配金額"    ,
                  COLUMN  68, "銀行"        ,
                  COLUMN  76, "帳號"        ,
                  COLUMN 110, "付款號碼"

            PRINT SetLine( "-",132 ) CLIPPED

        BEFORE GROUP OF r_cp_disb_type
               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET r_page_count          =0
               LET r_28250019_cnt        =0
               LET r_28250019_amt        =0
               LET r_11780300_cnt        =0
               LET r_11780300_amt        =0
               LET r_row_count           =0
               SKIP TO TOP OF PAGE

        ON EVERY ROW
           IF r_have_data="Y" THEN
              LET r_loan_amt=p_cp_pay_detail.rtn_loan_amt
                            +p_cp_pay_detail.rtn_loan_int
              LET r_apl_amt =p_cp_pay_detail.rtn_apl_amt
                            +p_cp_pay_detail.rtn_apl_int
              LET r_div_amt =p_cp_pay_detail.accumulated_div
                            +p_cp_pay_detail.div_int_balance
                            +p_cp_pay_detail.div_int

              LET r_total_cnt           =r_total_cnt+1
              LET r_total_payamt        =r_total_payamt
                                        +p_cp_pay_detail.cp_amt
              LET r_total_supprem       =r_total_supprem
                                        +p_cp_pay_detail.prem_susp
              LET r_total_divamt        =r_total_divamt
                                        +r_div_amt
              LET r_total_loanamt       =r_total_loanamt
                                        +r_loan_amt
              LET r_total_aplamt        =r_total_aplamt
                                        +r_apl_amt
              LET r_total_minus_supprem =r_total_minus_supprem
                                        +p_cp_pay_detail.rtn_minus_premsusp

--            LET r_total_realamt       =r_total_realamt
--                                      +p_cp_pay_detail.cp_pay_amt


              PRINT COLUMN   1,r_policy_no             ,  -- 保單號碼   --
                    COLUMN  14,r_applicant_name[1,20]  ,  -- 要保人     --
                    COLUMN  35,p_cp_pay_detail.po_issue_date
                                                       ,  -- po_issue_d --
                    COLUMN  45,r_cp_anniv_date         ,  -- cp_anniv_d --
                    COLUMN  55,r_po_sts_code           ,  -- po_sts     --
                    COLUMN  60,r_modx  USING "###"     ,  -- modx       --
                    COLUMN  68,r_method                ,  -- method     --
                    COLUMN  75," "                     ,  -- chk_sw     --
                    COLUMN  79,p_cp_pay_detail.cp_chk_date
                                                       ,  -- chk_date   --
                    COLUMN  89,p_cp_pay_detail.paid_to_date
                                                       ,  -- paid_to_d  --
                    COLUMN  99,p_cp_pay_detail.rtn_rece_no
                                                       ,  -- rtn_rece_no--
                    COLUMN 110,r_agent_name[1,20]         -- agent_name --

              LET r_page_count=r_page_count+1
              LET r_row_count = r_row_count+1
              PRINT COLUMN  14,p_cp_pay_detail.plan_code,'-',
                               p_cp_pay_detail.rate_scale
                                                        ,  -- 險種       --
                    COLUMN  25,p_cp_pay_detail.face_amt USING "#,###,###,###"
                                                        ,  -- 保額       --
                    COLUMN  39,p_cp_pay_detail.cp_amt   USING "###,###,###"
                                                        ,  -- 應付金額   --
                    COLUMN  51,p_cp_pay_detail.prem_susp USING "###,###,###"
                                                        ,  -- (+)溢繳    --
                    COLUMN  63,r_div_amt                USING "###,###,###"
                                                        ,  -- (+)紅利    --
                    COLUMN  75,r_loan_amt               USING "###,###,###"
                                                        ,  -- (-)貸款本息--
                    COLUMN  87,r_apl_amt                USING "###,###,###"
                                                        ,  -- (-)墊繳本息--
                    COLUMN  99,p_cp_pay_detail.rtn_minus_premsusp
                                                        USING "###,###,###"
                                                        ,  -- (-)欠繳    --
                    COLUMN 111,p_cp_pay_detail.cp_pay_amt USING "----,---,--&"
                                                        ,  -- (=)實付金額--
                    COLUMN 125,p_cp_pay_detail.dept_code  -- 通訊單位 --

              LET r_page_count=r_page_count+1
              IF p_cp_pay_detail.cp_pay_amt < 0 THEN
                 LET r_11780300_cnt=r_11780300_cnt+1
                 LET r_11780300_amt=r_11780300_amt+p_cp_pay_detail.cp_pay_amt
              END IF
              IF r_cp_pay_detail_sw ="1" THEN -- 無受益人資料 --
                 FOR r_i=1 TO r_pscd_cnt
                     IF p_pscd_r[r_i].cp_real_payamt !=0 THEN
                        LET r_page_count   =r_page_count+1
                        LET r_disb_cnt     =r_disb_cnt+1
                        IF p_pscd_r[r_i].cp_real_payamt < 0 THEN
                           LET r_11780300_cnt=r_11780300_cnt+1
                           LET r_11780300_amt=r_11780300_amt
                                             -p_pscd_r[r_i].cp_real_payamt
                        ELSE
                           LET r_28250019_cnt=r_28250019_cnt+1
                           LET r_28250019_amt=r_28250019_amt
                                             +p_pscd_r[r_i].cp_real_payamt
                        END IF

                        PRINT COLUMN   14,p_pscd_r[r_i].names[1,20]    , -- 受益
                              COLUMN   36,p_pscd_r[r_i].cp_pay_seq
                                          USING "####"                 , -- 順序
                              COLUMN   46,p_pscd_r[r_i].benf_ratio
                                          USING "###"                  , -- 分配
                              COLUMN   53,p_pscd_r[r_i].cp_real_payamt
                                          USING "----,---,--&"         , -- 分配
                              COLUMN   68,p_pscd_r[r_i].remit_bank
                                         ,p_pscd_r[r_i].remit_branch   , -- 銀行
                              COLUMN   76,p_pscd_r[r_i].remit_account  , -- 帳號
                              COLUMN  110,p_pscd_r[r_i].disb_no          -- 付款
                     END IF
                 END FOR
              END IF
              PRINT COLUMN   1," "
              IF r_page_count >= 30 
              OR r_row_count  == 10
              THEN
                 LET r_page_count=0
                 LET r_row_cnt=r_row_count   --紀錄該頁印出幾筆資料
                 LET r_row_count =0
                 SKIP 1 LINE
                 PRINT SetLine("-",62 ) CLIPPED,"續下頁",SetLine("-",62)
                 PRINT COLUMN 92,"本頁資料筆數：",r_row_cnt USING "<<<<","筆"
                 SKIP TO TOP OF PAGE
              END IF
           END IF

        AFTER GROUP OF r_cp_disb_type
           PRINT COLUMN  24,"應付值:"   ,r_total_payamt USING "#,###,###,##&"," 元",
                 COLUMN  50,"(+)溢繳:"  ,r_total_supprem USING "#,###,###,##&"," 元",
                 COLUMN  77,"(+)紅利:"  ,r_total_divamt USING "#,###,###,##&"," 元"

           PRINT COLUMN  21,"(-)貸  款:",r_total_loanamt USING "#,###,###,##&"," 元",
                 COLUMN  50,"(-)墊繳:"  ,r_total_aplamt  USING "#,###,###,##&"," 元",
                 COLUMN  77,"(-)欠繳:"  ,r_total_minus_supprem USING "#,###,###,##&"," 元"

           PRINT COLUMN  22,r_acct_no,":",r_28250019_cnt USING "###,##&",
                            "件",
                 COLUMN  49,"合計金額:",r_28250019_amt USING "#,###,###,##&"," 元"
           PRINT COLUMN  22,"11780300:",r_11780300_cnt USING "###,##&","件",
                 COLUMN  49,"合計金額:",r_11780300_amt USING "#,###,###,##&"," 元"
           SKIP  2 LINE

           PRINT COLUMN   3,"(副)總經理:_____________________",
                 COLUMN  37,  "部門主管:_____________________",
                 COLUMN  68,  "單位主管:_____________________",
                 COLUMN  99,    "請款人:_____________________"

        LET r_row_count=0

        ON LAST ROW
           PRINT ASCII 12

END REPORT -- cp_pay_dtl_col 滿期金給付控制報表 --

-------------------------------------------------------------------------------
-- 報表名稱:cp_pay_unnormal_50
-- 作    者:yirong
-- 日    期:098/12/24
-- 處理概要:滿期/還本給付明細控制表列印
--          因支票未兌現使得給付延後的資料,電匯資料特殊作業
-- table   :pscr
-- inp para:列印日
-- return 的參數:
-- 重要函式:
-------------------------------------------------------------------------------
REPORT cp_pay_unnormal_50 (r_have_data
                       ,r_cp_pay_form_type
                       ,r_policy_no
                       ,r_cp_anniv_date
                       ,r_applicant_name
                       ,r_dept_name
                       ,r_cp_pay_detail_sw
                       ,r_cp_disb_type
                       ,r_recv_note_name
                       ,r_agent_name
                       ,r_pscd_cnt
                       ,r_po_sts_code
                       ,r_modx
                       ,r_method
                       ,r_dept_belong
                       ,r_dept_adm_name
                       ,r_function_code
                       )

    DEFINE  r_have_data           CHAR(1)
           ,r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_applicant_name      LIKE clnt.names
           ,r_dept_name           LIKE dept.dept_name
           ,r_plan_desc           LIKE pldf.plan_desc
           ,r_cp_pay_detail_sw    CHAR(1)
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_recv_note_name      LIKE clnt.names
           ,r_agent_name          LIKE clnt.names
           ,r_pscd_cnt            INTEGER
           ,r_po_sts_code         LIKE polf.po_sts_code
           ,r_modx                LIKE polf.modx
           ,r_method              LIKE polf.method
           ,r_dept_belong         LIKE dept.dept_belong
           ,r_dept_adm_name       LIKE dept.dept_name
--           ,r_function_code       CHAR(2)
           ,r_function_code       VARCHAR(10)


    DEFINE r_acct_no             CHAR(8)  -- 給付科目 --
          ,r_disb_desc           CHAR(8)  -- 給付方式說明 --

    DEFINE r_rpt_yy              INTEGER
          ,r_rpt_mm              INTEGER
          ,r_rpt_dd              INTEGER
          ,r_anniv_yy            INTEGER
          ,r_anniv_mm            INTEGER
          ,r_anniv_dd            INTEGER

    DEFINE r_loan_amt            INTEGER
          ,r_apl_amt             INTEGER
          ,r_div_amt             INTEGER

    DEFINE r_total_cnt           INTEGER -- 合計:件數 --
          ,r_total_payamt        INTEGER -- 應付值    --
          ,r_total_supprem       INTEGER -- 溢繳      --
          ,r_total_divamt        INTEGER -- 紅利      --
          ,r_disb_cnt            INTEGER -- 付款合計  --
          ,r_total_loanamt       INTEGER -- 貸款      --
          ,r_total_aplamt        INTEGER -- 墊繳      --
          ,r_total_minus_supprem INTEGER -- 欠繳      --
          ,r_total_realamt       INTEGER -- 實付      --
          ,r_11780300_cnt        INTEGER
          ,r_11780300_amt        INTEGER
          ,r_28250019_cnt        INTEGER
          ,r_28250019_amt        INTEGER


    DEFINE r_payform_var         CHAR(100)
          ,r_i                   INTEGER
          ,r_row_count           INTEGER
          ,r_row_cnt             INTEGER
          ,r_page_count          INTEGER
          
    DEFINE for_100w              VARCHAR(10)

    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER EXTERNAL BY r_cp_disb_type
            ,r_policy_no
            ,r_cp_anniv_date

    FORMAT

        PAGE HEADER
            IF PAGENO=1 THEN
               LET r_page_count =0

               LET r_loan_amt            =0
               LET r_apl_amt             =0
               LET r_div_amt             =0

               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0

               LET r_28250019_cnt        =0
               LET r_28250019_amt        =0
               LET r_11780300_cnt        =0
               LET r_11780300_amt        =0
               LET for_100w              ='' 
                
            END IF

            LET r_row_count           =0

            CASE
                WHEN r_cp_disb_type="0"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="郵寄支票"
                     LET for_100w=''
                WHEN r_cp_disb_type="2"
                     LET r_acct_no="28250001"
                     LET r_disb_desc="抵繳保費"
                     LET for_100w=''
                WHEN r_cp_disb_type="3"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="電    匯"
                     LET for_100w="≧100萬"
                WHEN r_cp_disb_type="4"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="未回領取"
                     LET for_100w=''
                WHEN r_cp_disb_type="5"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="主動電匯"
                     LET for_100w="≧100萬"
                WHEN r_cp_disb_type="6"
                     LET r_acct_no="28250027"
                     LET r_disb_desc="還本回流"
                     LET for_100w=''
            END CASE

            LET r_acct_no="28250019"
      --    LET g_report_corp="三 商 美 邦 人 壽 保 險 股 份 有 限 公 司"
      --    LET g_report_name="滿期給付明細控制報表"
            LET g_report_name=p_rpt_name_4

            PRINT          ASCII  27, "E",     ASCII  27, "z0"
                          ,ASCII  27, "90028", ASCII 27, "80054"
                          ,ASCII  27, "7005"
            PRINT COLUMN CenterPosition( g_report_corp,132 ),
                         g_report_corp CLIPPED,
                    COLUMN  119 ,p_name CLIPPED
{
            PRINT COLUMN  CenterPosition( g_report_corp,132 ),
                          g_report_corp CLIPPED
}
            PRINT COLUMN  CenterPosition( g_report_name,132 ),
                          g_report_name CLIPPED,for_100w
            PRINT COLUMN   1, "印表日期:", GetDate(TODAY),
                  COLUMN 111, "代    號:GC63"
            PRINT COLUMN   1, "作業日期:", p_rpt_beg_date,
                  COLUMN  45, "給付方式:",r_disb_desc,"-",r_acct_no
                                         ,"付款功能碼:",r_function_code,
                  COLUMN 111, "頁    次:", PAGENO USING "####"

            PRINT SetLine( "-",132 ) CLIPPED

            PRINT COLUMN   1, "保單號碼"    ,
                  COLUMN  14, "要保人"      ,
                  COLUMN  35, "PO-生效日"   ,
                  COLUMN  45, "週年日"      ,
                  COLUMN  53, "PO-ST"       ,
                  COLUMN  59, "繳法"        ,
                  COLUMN  64, "收費方式"    ,
                  COLUMN  73, "兌現"        ,
                  COLUMN  79, "支票日期"    ,
                  COLUMN  89, "繳費終日"    ,
                  COLUMN  99, "還款收據"    ,
                  COLUMN 110, "業務員"

            PRINT COLUMN  14, "險種"        ,
                  COLUMN  34, "保額"        ,
                  COLUMN  42, "應付金額"    ,
                  COLUMN  55, "(+)溢繳"     ,
                  COLUMN  67, "(+)紅利"     ,
                  COLUMN  75, "(-)貸款本利" ,
                  COLUMN  87, "(-)墊繳本利" ,
                  COLUMN 103, "(-)欠繳"     ,
                  COLUMN 112, "(=)實付金額" ,
                  COLUMN 125, "通訊單位"

            PRINT COLUMN  14, "受益人"      ,
                  COLUMN  36, "順序"        ,
                  COLUMN  43, "受益比率%"   ,
                  COLUMN  57, "分配金額"    ,
                  COLUMN  68, "銀行"        ,
                  COLUMN  76, "帳號"        ,
                  COLUMN 110, "付款號碼"

            PRINT SetLine( "-",132 ) CLIPPED

        BEFORE GROUP OF r_cp_disb_type
               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET r_page_count          =0
               LET r_28250019_cnt        =0
               LET r_28250019_amt        =0
               LET r_11780300_cnt        =0
               LET r_11780300_amt        =0
               LET r_row_count           =0
               SKIP TO TOP OF PAGE

        ON EVERY ROW
           IF r_have_data="Y" THEN
              LET r_loan_amt=p_cp_pay_detail.rtn_loan_amt
                            +p_cp_pay_detail.rtn_loan_int
              LET r_apl_amt =p_cp_pay_detail.rtn_apl_amt
                            +p_cp_pay_detail.rtn_apl_int
              LET r_div_amt =p_cp_pay_detail.accumulated_div
                            +p_cp_pay_detail.div_int_balance
                            +p_cp_pay_detail.div_int

              LET r_total_cnt           =r_total_cnt+1
              LET r_total_payamt        =r_total_payamt
                                        +p_cp_pay_detail.cp_amt
              LET r_total_supprem       =r_total_supprem
                                        +p_cp_pay_detail.prem_susp
              LET r_total_divamt        =r_total_divamt
                                        +r_div_amt
              LET r_total_loanamt       =r_total_loanamt
                                        +r_loan_amt
              LET r_total_aplamt        =r_total_aplamt
                                        +r_apl_amt
              LET r_total_minus_supprem =r_total_minus_supprem
                                        +p_cp_pay_detail.rtn_minus_premsusp

--            LET r_total_realamt       =r_total_realamt
--                                      +p_cp_pay_detail.cp_pay_amt


              PRINT COLUMN   1,r_policy_no             ,  -- 保單號碼   --
                    COLUMN  14,r_applicant_name[1,20]  ,  -- 要保人     --
                    COLUMN  35,p_cp_pay_detail.po_issue_date
                                                       ,  -- po_issue_d --
                    COLUMN  45,r_cp_anniv_date         ,  -- cp_anniv_d --
                    COLUMN  55,r_po_sts_code           ,  -- po_sts     --
                    COLUMN  60,r_modx  USING "###"     ,  -- modx       --
                    COLUMN  68,r_method                ,  -- method     --
                    COLUMN  75," "                     ,  -- chk_sw     --
                    COLUMN  79,p_cp_pay_detail.cp_chk_date
                                                       ,  -- chk_date   --
                    COLUMN  89,p_cp_pay_detail.paid_to_date
                                                       ,  -- paid_to_d  --
                    COLUMN  99,p_cp_pay_detail.rtn_rece_no
                                                       ,  -- rtn_rece_no--
                    COLUMN 110,r_agent_name[1,20]         -- agent_name --

              LET r_page_count=r_page_count+1
              LET r_row_count =r_row_count+1
              
              PRINT COLUMN  14,p_cp_pay_detail.plan_code,'-',
                               p_cp_pay_detail.rate_scale
                                                        ,  -- 險種       --
                    COLUMN  25,p_cp_pay_detail.face_amt USING "#,###,###,###"
                                                        ,  -- 保額       --
                    COLUMN  39,p_cp_pay_detail.cp_amt   USING "###,###,###"
                                                        ,  -- 應付金額   --
                    COLUMN  51,p_cp_pay_detail.prem_susp USING "###,###,###"
                                                        ,  -- (+)溢繳    --
                    COLUMN  63,r_div_amt                USING "###,###,###"
                                                        ,  -- (+)紅利    --
                    COLUMN  75,r_loan_amt               USING "###,###,###"
                                                        ,  -- (-)貸款本息--
                    COLUMN  87,r_apl_amt                USING "###,###,###"
                                                        ,  -- (-)墊繳本息--
                    COLUMN  99,p_cp_pay_detail.rtn_minus_premsusp
                                                        USING "###,###,###"
                                                        ,  -- (-)欠繳    --
                    COLUMN 111,p_cp_pay_detail.cp_pay_amt USING "----,---,--&"
                                                        ,  -- (=)實付金額--
                    COLUMN 125,p_cp_pay_detail.dept_code  -- 通訊單位 --

              LET r_page_count=r_page_count+1
              IF p_cp_pay_detail.cp_pay_amt <0 THEN
                 LET r_11780300_cnt=r_11780300_cnt+1
                 LET r_11780300_amt=r_11780300_amt+p_cp_pay_detail.cp_pay_amt
              END IF

              IF r_cp_pay_detail_sw ="1" THEN -- 無受益人資料 --
                 FOR r_i=1 TO r_pscd_cnt
                     IF p_pscd_r[r_i].cp_real_payamt !=0 THEN
                        LET r_page_count   =r_page_count+1
                        LET r_disb_cnt     =r_disb_cnt+1
                        IF p_pscd_r[r_i].cp_real_payamt < 0 THEN
                           LET r_11780300_cnt=r_11780300_cnt+1
                           LET r_11780300_amt=r_11780300_amt
                                             -p_pscd_r[r_i].cp_real_payamt
                        ELSE
                           LET r_28250019_cnt=r_28250019_cnt+1
                           LET r_28250019_amt=r_28250019_amt
                                             +p_pscd_r[r_i].cp_real_payamt
                        END IF

                        PRINT COLUMN   14,p_pscd_r[r_i].names[1,20]    , -- 受益
                              COLUMN   36,p_pscd_r[r_i].cp_pay_seq
                                          USING "####"                 , -- 順序
                              COLUMN   46,p_pscd_r[r_i].benf_ratio
                                          USING "###"                  , -- 分配
                              COLUMN   53,p_pscd_r[r_i].cp_real_payamt
                                          USING "----,---,--&"         , -- 分配
                              COLUMN   68,p_pscd_r[r_i].remit_bank
                                         ,p_pscd_r[r_i].remit_branch   , -- 銀行
                              COLUMN   76,p_pscd_r[r_i].remit_account  , -- 帳號
                              COLUMN  110,p_pscd_r[r_i].disb_no          -- 付款
                     END IF
                 END FOR
              END IF
              PRINT COLUMN   1," "
              IF r_page_count >= 30 
              OR r_row_count  == 10
              THEN
                 LET r_page_count=0
                 LET r_row_cnt=r_row_count   --紀錄該頁印出幾筆資料
                 LET r_row_count =0
                 SKIP 1 LINE
                 PRINT SetLine("-",62 ) CLIPPED,"續下頁",SetLine("-",62)
                 PRINT COLUMN 92,"本頁資料筆數：",r_row_cnt USING "<<<<","筆"
                 SKIP TO TOP OF PAGE
              END IF
           END IF

        AFTER GROUP OF r_cp_disb_type
           PRINT COLUMN  24,"應付值:"   ,r_total_payamt USING "#,###,###,##&"," 元",
                 COLUMN  50,"(+)溢繳:"  ,r_total_supprem USING "#,###,###,##&"," 元",
                 COLUMN  77,"(+)紅利:"  ,r_total_divamt USING "#,###,###,##&"," 元"

           PRINT COLUMN  21,"(-)貸  款:",r_total_loanamt USING "#,###,###,##&"," 元",
                 COLUMN  50,"(-)墊繳:"  ,r_total_aplamt  USING "#,###,###,##&"," 元",
                 COLUMN  77,"(-)欠繳:"  ,r_total_minus_supprem USING "#,###,###,##&"," 元"

           PRINT COLUMN  22,r_acct_no,":",r_28250019_cnt USING "###,##&",
                            "件",
                 COLUMN  49,"合計金額:",r_28250019_amt USING "#,###,###,##&"," 元"
           PRINT COLUMN  22,"11780300:",r_11780300_cnt USING "###,##&","件",
                 COLUMN  49,"合計金額:",r_11780300_amt USING "#,###,###,##&"," 元"
           SKIP  2 LINE

           PRINT COLUMN   3,"(副)總經理:_____________________",
                 COLUMN  37,  "部門主管:_____________________",
                 COLUMN  68,  "單位主管:_____________________",
                 COLUMN  99,    "請款人:_____________________"

        LET r_row_count=0

        ON LAST ROW
           PRINT ASCII 12
END REPORT -- cp_pay_unnormal 生存明細控制報表 --


-- 還本給付一般件、e-billing、暫停郵寄明細表                                                     
-------------------------------------------------------------------------------                  
-- 報表名稱:cp_pay_dtl_all                                                                       
-- 作    者:yihua                                                                                
-- 日    期:100/01/10                                                                            
-- 處理概要:滿期/還本給付明細控制表列印                                                          
--          還本給付一般件、e-billing、暫停郵寄明細表                                            
-------------------------------------------------------------------------------                  
REPORT cp_pay_dtl_all (                                                                          
          r_policy_no                    -- 保單號碼                                             
         ,r_benf_name_all                -- 受益人                                               
         ,r_cp_anniv_date                -- 週年日                                               
         ,r_plan_code                    -- 險種                                                 
         ,r_face_amt                     -- 保額                                                 
         ,r_cp_amt                       -- 還本金額                                             
         ,r_cp_pay_amt                   -- 給付金額                                             
         ,r_ebill_ind                    -- ebill指示                                            
         ,r_pmia_sw                      -- 無效地址指示                                         
         )                                                                                       
                                                                                                 
DEFINE  r_policy_no              LIKE polf.policy_no                                             
       ,r_benf_name_all          CHAR(10)                                                        
       ,r_cp_anniv_date          LIKE pscp.cp_anniv_date                                         
       ,r_plan_code              LIKE pscp.plan_code                                             
       ,r_face_amt               LIKE pscp.face_amt                                              
       ,r_cp_amt                 LIKE pscp.cp_amt                                                
       ,r_cp_pay_amt             LIKE pscp.cp_pay_amt                                            
       ,r_ebill_ind              CHAR(1)                                                         
       ,r_pmia_sw                LIKE pmia.pmia_sw                                               
                                                                                                 
                                                                                                 
DEFINE  r_stop_mail               CHAR(1)                       -- 暫停郵寄                      
       ,r_normal                  CHAR(1)                       -- 一般件                        
       ,r_e_mail                  CHAR(1)                       -- e-billing                     
       ,r_total                   INTEGER                       -- 合計件數                      
     --  ,r_sub_total               INTEGER                       -- 合計金額                    
       ,corp_name                 CHAR(54)                                                       
       ,rpt_name                  CHAR(54)                                                       
                                                                                                 
OUTPUT                                                                                           
      PAGE   LENGTH  40                                                                          
      LEFT   MARGIN   0                                                                          
      TOP    MARGIN   0                                                                          
      BOTTOM MARGIN   0                                                                          
                                                                                                 
ORDER BY r_policy_no, r_benf_name_all, r_benf_name_all                                           
                                                                                                 
FORMAT                                                                                           
                                                                                                 
                                                                                                 
PAGE HEADER                                                                                      
   PRINT                                                                                         
   LET  corp_name = "三  商  美  邦  人  壽  保  險  股  份  有  限  公  司"                     
   PRINT COLUMN CenterPosition( corp_name, 120 ), corp_name CLIPPED                              
   LET  rpt_name = "滿 期 保 險 金 對 帳 明 細 報 表"
   PRINT COLUMN CenterPosition( rpt_name, 120 ), rpt_name CLIPPED                                
                                                                                                 
   SKIP 1 LINE                                                                                   
           PRINT COLUMN   1, "印表日期:", GetDate(TODAY),                                        
                 COLUMN 119, "代    號:GC50-1"                                                   
           PRINT COLUMN   1, "作業日期:", p_rpt_beg_date,                                        
                 COLUMN 119, "頁    次:", PAGENO USING "####"                                    
           PRINT SetLine( "-",140 ) CLIPPED                                                      
                                                                                                 
           PRINT COLUMN   3 , "保單號碼",                                                        
                 COLUMN  16 , "受益人"  ,                                                        
                 COLUMN  27 , "週 年 日",                                                        
                 COLUMN  38 , "險    種",                                                        
                 COLUMN  56 , "保    額",                                                        
                 COLUMN  81 , "還本金額",                                                        
                 COLUMN  94 , "給付金額",                                                        
                 COLUMN 106 , "一般件",
                 COLUMN 116 , "e-billing",
                 COLUMN 128 , "暫停郵寄"
           PRINT SetLine( "-",140 ) CLIPPED                                                      
                                                                                                 
       ON EVERY ROW

       IF r_ebill_ind = '1' AND r_pmia_sw = ' ' THEN                                             
         LET r_normal = 'Y'                                                                      
       ELSE                                                                                      
         LET r_normal = ' '                                                                      
       END IF                                                                                    
                                                                                                 
       IF r_ebill_ind = '0' THEN                                                                 
         LET r_e_mail = 'Y'                                                                      
       ELSE                                                                                      
         LET r_e_mail = ' '                                                                      
       END IF                                                                                    
                                                                                                 
       IF r_ebill_ind = '1' AND r_pmia_sw = 'Y' THEN                                             
         LET r_stop_mail = 'Y'                                                                   
       ELSE                                                                                      
         LET r_stop_mail = ' '                                                                   
       END IF                                                                                    
                                                                                                 
       display 'ebill指示3=', r_ebill_ind , ' 無效地址指示=', r_pmia_sw                          
       display '一般件3=', r_normal, ' mail=',r_e_mail, ' 暫停郵寄=', r_stop_mail                
           PRINT COLUMN   1 , r_policy_no,                                                       
                 COLUMN  16 , r_benf_name_all,                                                   
                 COLUMN  25 , r_cp_anniv_date,                                                   
                 COLUMN  38 , r_plan_code,                                                       
                 COLUMN  50 , r_face_amt                                                         
                              USING "#,###,###,###.#&",                                             
                 COLUMN  74 , r_cp_amt                                                           
                              USING "#,###,###,###.#&",                                             
                 COLUMN  87 , r_cp_pay_amt                                                       
                              USING "#,###,###,###.#&",                                             
                 COLUMN 108 , r_normal,
                 COLUMN 119 , r_e_mail,
                 COLUMN 132 , r_stop_mail
                                                                                                 
       LET r_total = r_total + 1                            -- 合計件數                          
     --  LET r_sub_total = r_sub_total + r_cp_amt             -- 合計金額                        
                                                                                                 
       ON LAST ROW                                                                               
           PRINT SetLine( "-",140 ) CLIPPED                                                      
           PRINT COLUMN  3 , "合     計:",                                                       
                 COLUMN  9 , r_total  USING "###,##&","件"                                       
                -- COLUMN 50 , "金     額:",                                                     
                -- COLUMN 60 , r_sub_total  USING "###,###,###,##&"                              
                                                                                                 
                                                                                                 
          PRINT ASCII 12                                                                         
END REPORT                                                                                       
-------------------------------------------------------------------------------
-- 報表名稱:cp_pay_dtl_stat
-- 作    者:yirong
-- 日    期:100/03
-- 處理概要:生存明細統計
-------------------------------------------------------------------------------
REPORT cp_pay_dtl_stat (r_currency,r_fn_code_desc,r_sub_stat,r_cp_pay_amt)
    DEFINE r_currency CHAR(3)
    DEFINE r_fn_code_desc  CHAR(14)
    DEFINE r_sub_stat CHAR(2)
    DEFINE r_cp_pay_amt LIKE pscp.cp_pay_amt
    DEFINE r_rpt_name                  CHAR(54)
    DEFINE r_fn_cnt   INT
    DEFINE r_fn_payamt FLOAT
    DEFINE r_sub_cnt   INT
    DEFINE r_sub_payamt FLOAT
    DEFINE r_cur_cnt INT
    DEFINE r_cur_payamt FLOAT


 OUTPUT
      TOP OF PAGE "^L"
      PAGE   LENGTH  40
      LEFT   MARGIN   0
      TOP    MARGIN   0
      BOTTOM MARGIN   0

ORDER BY r_currency,r_sub_stat,r_fn_code_desc

FORMAT


PAGE HEADER
   PRINT
   CALL GetReportTitle("", TRUE)
   PRINT COLUMN CenterPosition(g_report_corp CLIPPED,120), g_report_corp CLIPPED;
   PRINT COLUMN 114, "[ 機密資訊 ]"

   PRINT ""
   LET r_rpt_name = "滿 期 對 帳 統 計 報 表"
   PRINT COLUMN CenterPosition(r_rpt_name,120), r_rpt_name CLIPPED,
   COLUMN 124, "psc03r11"
   PRINT ""
           PRINT COLUMN   1, "印表日期:", GetDate(TODAY),--,"幣別:",r_currency
                 COLUMN 119, "代    號:GC65-2"
           PRINT COLUMN   1, "作業日期:", p_rpt_beg_date,
                 COLUMN 119, "頁    次:", PAGENO USING "####"
           PRINT SetLine( "-",140 ) CLIPPED

           PRINT COLUMN   3 , "幣別",
                 COLUMN  10 , "滿期"  ,
                 COLUMN  30 , "筆數",
                 COLUMN  46 , "金額"

           PRINT SetLine( "-",140 ) CLIPPED
   BEFORE GROUP OF r_fn_code_desc
               LET r_fn_cnt           =0
               LET r_fn_payamt        =0
   BEFORE GROUP OF r_sub_stat
               LET r_sub_cnt      =0
               LET r_sub_payamt        =0
   BEFORE GROUP OF r_currency
               LET r_cur_cnt            =0
               LET r_cur_payamt       =0
--               SKIP TO TOP OF PAGE
   ON EVERY ROW
      LET r_fn_cnt = r_fn_cnt + 1
      LET r_fn_payamt = r_fn_payamt + r_cp_pay_amt
   AFTER GROUP OF r_fn_code_desc
      PRINT COLUMN   3,r_currency,
            COLUMN  10,r_fn_code_desc,
            COLUMN  20,r_fn_cnt USING "###,##&"," 件",
            COLUMN  30,r_fn_payamt USING "#,###,###,##&.&&"," 元"
      LET r_sub_cnt = r_sub_cnt + r_fn_cnt
      LET r_sub_payamt = r_sub_payamt + r_fn_payamt


   AFTER GROUP OF r_sub_stat
      PRINT COLUMN   3,r_currency,
            COLUMN  10,"小計:   ",
            COLUMN  24,r_sub_cnt USING "###,##&"," 件",
            COLUMN  34,r_sub_payamt USING "#,###,###,##&.&&"," 元"
      PRINT " "
      LET r_cur_cnt = r_cur_cnt + r_sub_cnt
      LET r_cur_payamt = r_cur_payamt + r_sub_payamt

   AFTER GROUP OF r_currency
      PRINT COLUMN   3,r_currency,
            COLUMN  10,"Total:    ",
            COLUMN  24,r_cur_cnt USING "###,##&"," 件",
            COLUMN  34,r_cur_payamt USING "#,###,###,##&.&&"," 元"


      ON LAST ROW
           PRINT ASCII 12

END REPORT
-------------------------------------------------------------------------------
-- 報表名稱:cp_pay_dtl_col_usd
-- 作    者:jessica Chang
-- 日    期:087/02/03
-- 處理概要:滿期/還本給付明細控制表列印
-- table   :pscr
-- inp para:列印日
-- return 的參數:
-- 重要函式:
-------------------------------------------------------------------------------
REPORT cp_pay_dtl_col_usd (r_have_data
                      ,r_cp_pay_form_type
                      ,r_policy_no
                      ,r_cp_anniv_date
                      ,r_applicant_name
                      ,r_dept_name
                      ,r_cp_pay_detail_sw
                      ,r_cp_disb_type
                      ,r_recv_note_name
                      ,r_agent_name
                      ,r_pscd_cnt
                      ,r_po_sts_code
                      ,r_modx
                      ,r_method
                      ,r_function_code
,r_cp_pay_detail_process_date
,r_cp_pay_detail_policy_no
,r_cp_pay_detail_cp_anniv_date
,r_cp_pay_detail_cp_sw
,r_cp_pay_detail_cp_pay_form_type
,r_cp_pay_detail_plan_code
,r_cp_pay_detail_rate_scale
,r_cp_pay_detail_coverage_no
,r_cp_pay_detail_face_amt
,r_cp_pay_detail_paid_to_date
,r_cp_pay_detail_po_issue_date
,r_cp_pay_detail_minus_prem_susp
,r_cp_pay_detail_loan_amt
,r_cp_pay_detail_loan_int_balance
,r_cp_pay_detail_loan_int
,r_cp_pay_detail_apl_amt
,r_cp_pay_detail_apl_int_balance
,r_cp_pay_detail_apl_int
,r_cp_pay_detail_rtn_minus_premsusp
,r_cp_pay_detail_rtn_loan_amt
,r_cp_pay_detail_rtn_loan_int
,r_cp_pay_detail_rtn_apl_amt
,r_cp_pay_detail_rtn_apl_int
,r_cp_pay_detail_prem_susp
,r_cp_pay_detail_accumulated_div
,r_cp_pay_detail_div_int_balance
,r_cp_pay_detail_div_int
,r_cp_pay_detail_cp_amt
,r_cp_pay_detail_cp_chk_date
,r_cp_pay_detail_rtn_rece_no
,r_cp_pay_detail_cp_pay_amt
,r_cp_pay_detail_cp_disb_type
,r_cp_pay_detail_mail_addr_ind
,r_cp_pay_detail_dept_code
,r_cp_pay_detail_agent_code
,r_cp_pay_detail_dept_belong
,r_cp_pay_detail_address
,r_cp_pay_detail_zip_code
,r_cp_pay_detail_currency

                      )

    DEFINE  r_have_data           CHAR(1)
           ,r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_applicant_name      LIKE clnt.names
           ,r_dept_name           LIKE dept.dept_name
           ,r_cp_pay_detail_sw    CHAR(1)
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_recv_note_name      LIKE clnt.names
           ,r_agent_name          LIKE clnt.names
           ,r_pscd_cnt            INTEGER
           ,r_po_sts_code         LIKE polf.po_sts_code
           ,r_modx                LIKE polf.modx
           ,r_method              LIKE polf.method
           ,r_function_code       CHAR(2)


    DEFINE r_acct_no             CHAR(8)  -- 給付科目 --
          ,r_disb_desc           CHAR(8)  -- 給付方式說明 --

    DEFINE r_rpt_yy              INTEGER
          ,r_rpt_mm              INTEGER
          ,r_rpt_dd              INTEGER
          ,r_anniv_yy            INTEGER
          ,r_anniv_mm            INTEGER
          ,r_anniv_dd            INTEGER

    DEFINE r_loan_amt            FLOAT--INTEGER
          ,r_apl_amt             FLOAT--INTEGER
          ,r_div_amt             FLOAT--INTEGER

    DEFINE r_total_cnt           INTEGER -- 合計:件數 --
          ,r_total_payamt        FLOAT--INTEGER -- 應付值    --
          ,r_total_supprem       FLOAT--INTEGER -- 溢繳      --
          ,r_total_divamt        FLOAT--INTEGER -- 紅利      --
          ,r_disb_cnt            FLOAT--INTEGER -- 付款合計  --
          ,r_total_loanamt       FLOAT--INTEGER -- 貸款      --
          ,r_total_aplamt        FLOAT--INTEGER -- 墊繳      --
          ,r_total_minus_supprem FLOAT--INTEGER -- 欠繳      --
          ,r_total_realamt       FLOAT--INTEGER -- 實付      --
          ,r_total_cpamt         FLOAT--INTEGER -- 應付金額  --
          ,r_page_count          INTEGER -- 每頁筆數  --


    DEFINE r_payform_var         CHAR(100)
          ,r_i                   INTEGER
          ,r_row_count           INTEGER
          ,r_row_cnt             INTEGER
          ,r_j                   INTEGER

    DEFINE for_100w              VARCHAR(10)
DEFINE r_cp_pay_detail_process_date            LIKE pscb.change_date
    DEFINE r_cp_pay_detail_policy_no           LIKE polf.policy_no
    DEFINE r_cp_pay_detail_cp_anniv_date           LIKE pscb.cp_anniv_date
    DEFINE r_cp_pay_detail_cp_sw                   LIKE pscb.cp_sw
    DEFINE r_cp_pay_detail_cp_pay_form_type        LIKE pscp.cp_pay_form_type
    DEFINE r_cp_pay_detail_plan_code               LIKE pscp.plan_code
    DEFINE r_cp_pay_detail_rate_scale       LIKE pscp.rate_scale
    DEFINE r_cp_pay_detail_coverage_no             LIKE pscp.coverage_no
    DEFINE r_cp_pay_detail_face_amt                LIKE pscp.face_amt
    DEFINE r_cp_pay_detail_paid_to_date            LIKE pscp.paid_to_date
    DEFINE r_cp_pay_detail_po_issue_date           LIKE pscp.po_issue_date
    DEFINE r_cp_pay_detail_minus_prem_susp         LIKE pscp.minus_prem_susp
  DEFINE r_cp_pay_detail_loan_amt              LIKE pscp.loan_amt
  DEFINE r_cp_pay_detail_loan_int_balance        LIKE pscp.loan_int_balance
  DEFINE r_cp_pay_detail_loan_int              LIKE pscp.loan_int
    DEFINE r_cp_pay_detail_apl_amt                 LIKE pscp.apl_amt
    DEFINE r_cp_pay_detail_apl_int_balance         LIKE pscp.apl_int_balance
    DEFINE r_cp_pay_detail_apl_int                 LIKE pscp.apl_int
    DEFINE r_cp_pay_detail_rtn_minus_premsusp      LIKE pscp.rtn_minus_premsusp
    DEFINE r_cp_pay_detail_rtn_loan_amt            LIKE pscp.rtn_loan_amt
    DEFINE r_cp_pay_detail_rtn_loan_int            LIKE pscp.rtn_loan_int
    DEFINE r_cp_pay_detail_rtn_apl_amt             LIKE pscp.rtn_apl_amt
    DEFINE r_cp_pay_detail_rtn_apl_int             LIKE pscp.rtn_apl_int
    DEFINE r_cp_pay_detail_prem_susp               LIKE pscp.prem_susp
    DEFINE r_cp_pay_detail_accumulated_div         LIKE pscp.accumulated_div
    DEFINE r_cp_pay_detail_div_int_balance         LIKE pscp.div_int_balance
    DEFINE r_cp_pay_detail_div_int                 LIKE pscp.div_int
    DEFINE r_cp_pay_detail_cp_amt                  LIKE pscp.cp_amt
    DEFINE r_cp_pay_detail_cp_chk_date             LIKE pscp.cp_chk_date
    DEFINE r_cp_pay_detail_rtn_rece_no             LIKE pscp.rtn_rece_no
    DEFINE r_cp_pay_detail_cp_pay_amt              LIKE pscp.cp_pay_amt
    DEFINE r_cp_pay_detail_cp_disb_type            LIKE pscb.cp_disb_type
    DEFINE r_cp_pay_detail_mail_addr_ind           LIKE polf.mail_addr_ind
    DEFINE r_cp_pay_detail_dept_code               LIKE dept.dept_code
    DEFINE r_cp_pay_detail_agent_code              LIKE agnt.agent_code
     DEFINE r_cp_pay_detail_dept_belong               LIKE dept.dept_belong
    DEFINE r_cp_pay_detail_address                 LIKE addr.address
    DEFINE r_cp_pay_detail_zip_code                LIKE addr.zip_code
    DEFINE r_cp_pay_detail_currency                LIKE pscp.currency
    DEFINE r_pscx_r ARRAY [99] OF RECORD LIKE pscx.*
         DEFINE r_pscx_cmd           CHAR(254)


    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER BY r_function_code
--            ,r_cp_disb_type
            ,r_policy_no
            ,r_cp_anniv_date

    FORMAT

        PAGE HEADER
            IF PAGENO=1 THEN
               LET r_total_cpamt=0
               LET r_page_count =0

               LET r_loan_amt            =0
               LET r_apl_amt             =0
               LET r_div_amt             =0

               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET for_100w              =''


            END IF

            LET r_row_count           =0

            CASE
                WHEN r_cp_disb_type="0"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="郵寄支票"
                     LET for_100w=''
                WHEN r_cp_disb_type="2"
                     LET r_acct_no="28250001"
                     LET r_disb_desc="抵繳保費"
                     LET for_100w=''
                WHEN r_cp_disb_type="3"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="電    匯"
--                     LET for_100w="＜100萬"
                WHEN r_cp_disb_type="4"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="未回領取"
                     LET for_100w=''
                WHEN r_cp_disb_type="5"
                     LET r_acct_no="21430000"
                     LET r_disb_desc="主動電匯"
--                   LET for_100w="＜100萬"
                WHEN r_cp_disb_type="6"
                     LET r_acct_no="28250027"
                     LET r_disb_desc="還本回流"
                     LET for_100w=''

            END CASE

            PRINT COLUMN CenterPosition( g_report_corp,132 ),
                         g_report_corp CLIPPED,
                    COLUMN  119 ,p_name CLIPPED
            PRINT COLUMN  CenterPosition( g_report_name,132 ),
                          g_report_name CLIPPED,"外幣"
            PRINT COLUMN   1, "印表日期:", GetDate(TODAY),
                  COLUMN  62, "幣別:美元",
                  COLUMN 111, "代    號:GC60-1"
            PRINT COLUMN   1, "作業日期:", p_rpt_beg_date,
                  COLUMN  45, "給付方式:",r_disb_desc,"-",r_acct_no
                                         ,"付款功能碼:",r_function_code,
                  COLUMN 111, "頁    次:", PAGENO USING "####"

            PRINT SetLine( "-",132 ) CLIPPED

            PRINT COLUMN   1, "保單號碼"    ,
                  COLUMN  14, "要保人"      ,
                  COLUMN  35, "PO-生效日"   ,
                  COLUMN  45, "週年日"      ,
                  COLUMN  53, "PO-ST"       ,
                  COLUMN  59, "繳法"        ,
                  COLUMN  64, "收費方式"    ,
                  COLUMN  73, "兌現"        ,
                  COLUMN  79, "支票日期"    ,
                  COLUMN  89, "繳費終日"    ,
                  COLUMN  99, "還款收據"    ,
                  COLUMN 110, "業務員"

            PRINT COLUMN  14, "險種"        ,
                  COLUMN  34, "保額"        ,
                  COLUMN  42, "應付金額"    ,
                  COLUMN  55, "(+)溢繳"     ,
                  COLUMN  67, "(+)紅利"     ,
                  COLUMN  75, "(-)貸款本利" ,
                  COLUMN  87, "(-)墊繳本利" ,
                  COLUMN 103, "(-)欠繳"     ,
                  COLUMN 112, "(=)實付金額" ,
                  COLUMN 125, "通訊單位"

            PRINT COLUMN  14, "受益人"      ,
                  COLUMN  36, "順序"        ,
                  COLUMN  43, "受益比率%"   ,
                  COLUMN  57, "分配金額"    ,
                  COLUMN  68, "銀行"        ,
                  COLUMN  78, "帳號"        ,
                  COLUMN 112, "付款號碼"

            PRINT SetLine( "-",132 ) CLIPPED
         BEFORE GROUP OF r_function_code
               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET r_page_count          =0
               LET r_row_count           =0
               SKIP TO TOP OF PAGE

{
        BEFORE GROUP OF r_cp_disb_type
               LET r_total_cnt           =0
               LET r_total_payamt        =0
               LET r_total_supprem       =0
               LET r_total_divamt        =0
               LET r_disb_cnt            =0
               LET r_total_loanamt       =0
               LET r_total_aplamt        =0
               LET r_total_minus_supprem =0
               LET r_total_realamt       =0
               LET r_page_count          =0
               LET r_row_count           =0
               SKIP TO TOP OF PAGE
}

        ON EVERY ROW

           IF r_have_data="Y" THEN

               LET r_loan_amt=r_cp_pay_detail_rtn_loan_amt
                             +r_cp_pay_detail_rtn_loan_int
               LET r_apl_amt =r_cp_pay_detail_rtn_apl_amt
                             +r_cp_pay_detail_rtn_apl_int
               LET r_div_amt =r_cp_pay_detail_accumulated_div
                             +r_cp_pay_detail_div_int_balance
                             +r_cp_pay_detail_div_int

               LET r_total_cnt           =r_total_cnt+1
               LET r_total_payamt        =r_total_payamt
                                         +r_cp_pay_detail_cp_amt
               LET r_total_supprem       =r_total_supprem
                                         +r_cp_pay_detail_prem_susp
               LET r_total_divamt        =r_total_divamt
                                         +r_div_amt
               LET r_total_loanamt       =r_total_loanamt
                                         +r_loan_amt
               LET r_total_aplamt        =r_total_aplamt
                                         +r_apl_amt
               LET r_total_minus_supprem =r_total_minus_supprem
                                         +r_cp_pay_detail_rtn_minus_premsusp
               LET r_total_realamt       =r_total_realamt
                                         +r_cp_pay_detail_cp_pay_amt


               PRINT COLUMN   1,r_policy_no             ,  -- 保單號碼   --
                     COLUMN  14,r_applicant_name[1,20]  ,  -- 要保人     --
                     COLUMN  35,r_cp_pay_detail_po_issue_date
                                                        ,  -- po_issue_d --
                     COLUMN  45,r_cp_anniv_date         ,  -- cp_anniv_d --
                     COLUMN  55,r_po_sts_code           ,  -- po_sts     --
                     COLUMN  60,r_modx   USING "###"    ,  -- modx       --
                     COLUMN  68,r_method                ,  -- method     --
                     COLUMN  75," "                     ,  -- chk_sw     --
                     COLUMN  79,r_cp_pay_detail_cp_chk_date
                                                        ,  -- chk_date   --
                     COLUMN  89,r_cp_pay_detail_paid_to_date
                                                        ,  -- paid_to_d  --
                     COLUMN  99,r_cp_pay_detail_rtn_rece_no
                                                        ,  -- rtn_rece_no--
                     COLUMN 110,r_agent_name[1,20]         -- agent_name --

               LET r_page_count=r_page_count+1
               LET r_row_count=r_row_count +1

               PRINT COLUMN  14,r_cp_pay_detail_plan_code,'-',
                                r_cp_pay_detail_rate_scale
                                                         ,  -- 險種       --
                     COLUMN  25,r_cp_pay_detail_face_amt USING "#,###,##&.&&"
                                                         ,  -- 保額       --
                     COLUMN  39,r_cp_pay_detail_cp_amt   USING "#,###,##&.&&"
                                                         ,  -- 應付金額   --
                     COLUMN  51,r_cp_pay_detail_prem_susp USING "###,##&.&&"
                                                         ,  -- (+)溢繳    --
                     COLUMN  63,r_div_amt                USING "###,##&.&&"
                                                         ,  -- (+)紅利    --
                     COLUMN  75,r_loan_amt               USING "###,##&.&&"
                                                         ,  -- (-)貸款本息--
                     COLUMN  87,r_apl_amt                USING "###,##&.&&"
                                                         ,  -- (-)墊繳本息--
                     COLUMN  99,r_cp_pay_detail_rtn_minus_premsusp
                                                         USING "###,##&.&&"
                                                         ,  -- (-)欠繳    --
                     COLUMN 112,r_cp_pay_detail_cp_pay_amt USING "#,###,##&.&&"
                                                         ,  -- (=)實付金額--
                     COLUMN 125,r_cp_pay_detail_dept_code  -- 通訊單位 --

               LET r_page_count=r_page_count+1

               IF r_cp_pay_detail_sw ="1" THEN -- 無受益人資料 --
                  FOR r_i=1 TO 99
                      LET r_pscx_r[r_i].policy_no     =" "
                      LET r_pscx_r[r_i].cp_anniv_date ="   /  /  "
                      LET r_pscx_r[r_i].cp_pay_cnt    =0
                      LET r_pscx_r[r_i].cp_pay_seq    =0
                      LET r_pscx_r[r_i].cp_pay_amt    =0
                      LET r_pscx_r[r_i].names         =" "
                      LEt r_pscx_r[r_i].benf_ratio    =0
                      LET r_pscx_r[r_i].cp_real_payamt=0
                      LET r_pscx_r[r_i].bank_code     =" "
                      LET r_pscx_r[r_i].bank_account_e  =" "
                      LET r_pscx_r[r_i].payee_e       =" "
                      LET r_pscx_r[r_i].disb_no       =" "

                  END FOR

                  LET r_j = 1
                  DECLARE pscx_cur1 CURSOR FOR
                      SELECT  *
                        FROM pscx
                       WHERE policy_no=r_cp_pay_detail_policy_no
                         AND cp_anniv_date= r_cp_pay_detail_cp_anniv_date
                       ORDER BY cp_pay_seq


                  FOREACH pscx_cur1 INTO r_pscx_r[r_j].*

                      LET r_j=r_j+1
                  END FOREACH

                  FOR r_i=1 TO r_pscd_cnt
                      IF r_pscx_r[r_i].cp_real_payamt !=0 THEN
                         LET r_page_count   =r_page_count+1
                         LET r_disb_cnt     =r_disb_cnt+1

                         PRINT COLUMN   14,r_pscx_r[r_i].names[1,20]    , -- 受益

                               COLUMN   36,r_pscx_r[r_i].cp_pay_seq
                                           USING "####"                 , -- 順序
                               COLUMN   46,r_pscx_r[r_i].benf_ratio
                                           USING "###"                  , -- 分配
                               COLUMN   54,r_pscx_r[r_i].cp_real_payamt
                                           USING "#,###,##&.&&"          , -- 分
                               COLUMN   68,r_pscx_r[r_i].bank_code   ,
                               COLUMN   78,r_pscx_r[r_i].bank_account_e  , -- 帳
                               COLUMN  112,r_pscx_r[r_i].disb_no          -- 付款
                      END IF
                  END FOR
               END IF
               PRINT COLUMN   1," "

               IF r_page_count >= 30
               OR r_row_count ==10
               THEN
                  LET r_page_count = 0
                  LET r_row_cnt=r_row_count   --紀錄該頁印出幾筆資料
                  LET r_row_count  = 0
                  SKIP 1 LINE
                  PRINT SetLine("-",62 ) CLIPPED,"續下頁",SetLine("-",62)
              PRINT COLUMN 92,"本頁資料筆數：",r_row_cnt USING "<<<<","筆"
              SKIP TO TOP OF PAGE
           END IF
       END IF

    AFTER GROUP OF r_function_code--r_cp_disb_type

       IF r_acct_no ="28250001" THEN
          LET r_disb_cnt=r_total_cnt
       END IF

       PRINT COLUMN   1,"合    計: " ,r_total_cnt USING "###,##&"," 件",
             COLUMN  24,"應付值:"   ,r_total_payamt USING "##,###,##&.&&"," 元",
             COLUMN  50,"(+)溢繳:"  ,r_total_supprem USING "##,###,##&.&&"," 元",
             COLUMN  77,"(+)紅利:"  ,r_total_divamt USING "##,###,##&.&&"," 元"

       PRINT COLUMN   1,r_acct_no,": ",r_disb_cnt USING "###,##&"," 件",
             COLUMN  21,"(-)貸  款:",r_total_loanamt USING "##,###,##&.&&"," 元",
             COLUMN  50,"(-)墊繳:"  ,r_total_aplamt  USING "##,###,##&.&&"," 元",
             COLUMN  77,"(-)欠繳:"  ,r_total_minus_supprem USING "##,###,##&.&&",
             COLUMN 104,"(=)實付:"  ,r_total_realamt USING "##,###,##&.&&"," 元"
       SKIP  4 LINE

       PRINT COLUMN   3,"(副)總經理:_____________________",
             COLUMN  37,  "部門主管:_____________________",
             COLUMN  68,  "單位主管:_____________________",
             COLUMN  99,    "請款人:_____________________"

    LET r_row_count=0

    ON LAST ROW
       PRINT ASCII 12

END REPORT -- cp_pay_dtl_col_usd 生存明細控制報表 --
-------------------------------------------------------------------------------
-- 報表名稱:cp_pay_dtl_usd
-- 作    者:jessica Chang
-- 日    期:087/02/03
-- 處理概要:滿期/還本給付明細列印
-- table   :pscr
-- inp para:列印日
-- return 的參數:
-- 重要函式:
-------------------------------------------------------------------------------
REPORT cp_pay_dtl_usd  (r_cp_pay_form_type -- 給付格式 --
                     ,r_policy_no        -- 保單號碼 --
                     ,r_cp_anniv_date    -- 還本週年日 --
                     ,r_zip_code         -- 郵遞區號 --
                     ,r_address          -- 郵寄地址 --
                     ,r_applicant_name   -- 要保人   --
                     ,r_insured_name     -- 被保險人 --
                     ,r_tel_1            -- 要保人聯絡電話 --
                     ,r_dept_name        -- 營業處   --
                     ,r_plan_desc        -- 險種說明 --
                     ,r_cp_pay_detail_sw -- 列印受益人明細 --
                     ,r_benf_name_all    -- 受益人姓名 --
                     ,r_cp_disb_type     -- 給付方式   --
                     ,r_pay_desc         -- 給付說明   --
                     ,r_recv_note_name   -- 收件人姓名 --
                     ,r_dept_adm_name    -- 分公司名稱 --
                     ,r_pscd_cnt         -- 受益人明細筆數 --
                     ,r_dept_code        -- 部門代碼
                     ,r_mobile_o1        -- 要保人手機
                     ,r_ebill_ind        -- ebill指示
                     ,r_ebill_email      -- 要保人email
                     )

    DEFINE  r_cp_pay_form_type    LIKE pscp.cp_pay_form_type
           ,r_policy_no           LIKE polf.policy_no
           ,r_cp_anniv_date       LIKE pscp.cp_anniv_date
           ,r_zip_code            LIKE addr.zip_code
           ,r_address             LIKE addr.address
           ,r_applicant_name      LIKE clnt.names
           ,r_insured_name        LIKE clnt.names
           ,r_tel_1               LIKE addr.tel_1
           ,r_dept_name           LIKE dept.dept_name
           ,r_plan_desc           LIKE pldf.plan_desc
           ,r_cp_pay_detail_sw    CHAR(1)
           ,r_benf_name_all       CHAR(50)
           ,r_cp_disb_type        LIKE pscb.cp_disb_type
           ,r_pay_desc            CHAR(10)
           ,r_recv_note_name      LIKE clnt.names
           ,r_dept_adm_name       LIKE clnt.names
           ,r_pscd_cnt            INTEGER -- 受益人明細筆數 --
           ,r_dept_code           LIKE dept.dept_code
           ,r_mobile_o1           LIKE addr.tel_1
           ,r_ebill_ind           CHAR(1)
           ,r_ebill_email         LIKE addr.address
           ,r_pmia_sw            LIKE pmia.pmia_sw

    DEFINE r_addr_1              CHAR(36)
          ,r_addr_2              CHAR(36)

    DEFINE r_rpt_yy              INTEGER
          ,r_rpt_mm              INTEGER
          ,r_rpt_dd              INTEGER
          ,r_anniv_yy            INTEGER
          ,r_anniv_mm            INTEGER
          ,r_anniv_dd            INTEGER
          ,r_div_total           INTEGER

    DEFINE r_payform_var         CHAR(100)
          ,r_i                   INTEGER
          ,r_pscd_row            INTEGER
          ,r_diff_row            INTEGER

    OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    ORDER EXTERNAL BY r_cp_disb_type
            ,r_policy_no
            ,r_cp_anniv_date

    FORMAT

        PAGE HEADER
       --SR120800390 cmwang 101/09 
--              PRINT r_dept_code, r_mobile_o1, r_ebill_email[1,50], r_ebill_ind, r_policy_no,"|"
              PRINT g_ebill_format
        -----------------------------------------------------------   
--              PRINT ASCII 27,"E",ASCII 27,"A",ASCII 27,"z1",
--                    ASCII 27,"90033",ASCII 27,"80060"
              PRINT ASCII 126,"IT26G2;"
              SKIP 10 LINES

              CALL cut_string (r_address,LENGTH(r_address),36)
                   RETURNING r_addr_1,r_addr_2

              PRINT COLUMN  11,r_zip_code  CLIPPED
              PRINT COLUMN   1," "
              PRINT COLUMN  11,r_addr_1 CLIPPED
              PRINT COLUMN   1," "
              PRINT COLUMN  11,r_addr_2 CLIPPED
              PRINT COLUMN   1," "
              PRINT COLUMN  11,r_recv_note_name[1,30]         ,"  君親啟"

              SKIP  5 LINES

        BEFORE GROUP OF r_cp_disb_type
               SKIP TO TOP OF PAGE

        BEFORE GROUP OF r_policy_no
               SKIP TO TOP OF PAGE

        BEFORE GROUP OF r_cp_anniv_date
               SKIP TO TOP OF PAGE

        ON EVERY ROW
           LET r_pscd_row = 0
           LET r_diff_row = 0
           CALL SeparateYMD(p_cp_pay_detail.process_date)
                 RETURNING r_rpt_yy,r_rpt_mm,r_rpt_dd
           CALL SeparateYMD(r_cp_anniv_date)
                RETURNING r_anniv_yy,r_anniv_mm,r_anniv_dd

           --  生存 給付明細基本資料列印 p_payform_0 --

           LET p_payform_0[2]=p_payform_52
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_0[4]
           LET r_payform_var[15,26]=p_cp_pay_detail.policy_no
           LET r_payform_var[45,64]=r_insured_name[1,20]
           LET r_payform_var[82,84]=p_cp_pay_detail.cp_pay_form_type
           LET p_payform_0[4]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_0[5]
           LET r_payform_var[15,64]=r_benf_name_all
           LET r_payform_var[72,74]=r_rpt_yy    USING "###"
           LET r_payform_var[77,78]=r_rpt_mm    USING "##"
           LET r_payform_var[81,82]=r_rpt_dd    USING "##"
           LET p_payform_0[5]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_0[6]
           LET r_payform_var[15,27]=p_cp_pay_detail.face_amt
                                    USING "#,###,###,###"
           LET r_payform_var[45,84]=r_plan_desc[1,38]
           LET p_payform_0[6]=r_payform_var

           FOR r_i=1 TO 11
               IF r_i=1 THEN
              --    PRINT ASCII 27,"612"
                    PRINT ASCII 126,"IX1W2Z2FK;"
               ELSE
                  IF r_i=3 THEN
                --     PRINT ASCII 27,"611",ASCII 27,"90036"
                --         ,ASCII 27,"80067"
                     PRINT ASCII 126,"IX9G2;"
                  ELSE
                     PRINT COLUMN  1,p_payform_0[r_i] CLIPPED
                  END IF
               END IF
           END FOR

           -- 列印給付內容 --
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[1]
           LET r_payform_var[31,33]=r_anniv_yy  USING "###"
           LET r_payform_var[38,39]=r_anniv_mm  USING "##"
           LET r_payform_var[44,45]=r_anniv_dd  USING "##"
           LET p_payform_1[1]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[2]
           LET r_payform_var[12,35] = "給付保險金如下：    "
           LET p_payform_1[2]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[4]
           LET r_payform_var[17,24] = "        "
           LET r_payform_var[49,60]=p_cp_pay_detail.cp_amt
                                    USING "#,###,##&.&&"
           LET p_payform_1[4]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[5]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_minus_premsusp
                                    USING "#,###,##&.&&"
           LET p_payform_1[5]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[6]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_apl_int
                                    USING "#,###,##&.&&"
           LET p_payform_1[6]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[7]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_apl_amt
                                    USING "#,###,##&.&&"
           LET p_payform_1[7]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[8]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_loan_int
                                    USING "#,###,##&.&&"
           LET p_payform_1[8]=r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[9]
           LET r_payform_var[49,60]=p_cp_pay_detail.rtn_loan_amt
                                    USING "#,###,##&.&&"
           LET p_payform_1[9] =r_payform_var
           LET r_payform_var =p_payform_init
           LET r_payform_var =p_payform_1[10]
           LET r_payform_var[21,30]=r_pay_desc
           LET r_payform_var[40,48]="美  元："
           LET r_payform_var[49,60]=p_cp_pay_detail.cp_pay_amt
                                    USING "#,###,##&.&&"
           LET p_payform_1[10]=r_payform_var
           LET r_payform_var =p_payform_init

           FOR r_i =1 TO 11
               PRINT COLUMN  1,p_payform_1[r_i] CLIPPED
           END FOR

           -- 列印受益人給付明細 --
           IF r_cp_pay_detail_sw ="0" THEN
              FOR r_i =1 to 7
                  PRINT COLUMN 1," "
              END FOR
           ELSE
              FOR r_i =1 TO 3
                  PRINT COLUMN  1,p_payform_d[r_i] CLIPPED
              END FOR
              FOR r_i =1 TO r_pscd_cnt
                  IF p_pscd_r[r_i].cp_real_payamt !=0 THEN
                     PRINT COLUMN  6,p_pscx_r[r_i].cp_pay_seq
                                     USING "####",
                           COLUMN 11,p_pscx_r[r_i].names[1,20]   ,
                           COLUMN 33,p_pscx_r[r_i].benf_ratio
                                     USING "##&",
                           COLUMN 38,p_pscx_r[r_i].cp_real_payamt
                                     USING "-,---,--&.&&",
                           COLUMN 50,"元",
                           COLUMN 53,p_pscd_r[r_i].disb_no;

                     IF r_cp_disb_type = "3"
                     OR r_cp_disb_type = "5" THEN
                        PRINT COLUMN 61,p_pscx_r[r_i].bank_code,'-',
                                        p_pscx_r[r_i].bank_account_e[1,7], 'xxx',
                                        p_pscx_r[r_i].bank_account_e[11,16]
                     ELSE
                        PRINT COLUMN 61,p_pscx_r[r_i].bank_code,'-',
                                        p_pscx_r[r_i].bank_account_e
                     END IF

                     LET r_pscd_row=r_pscd_row+1
                  END IF
              END FOR
              IF r_pscd_row < 7 THEN
                 LET r_diff_row=7-r_pscd_row
                 FOR r_i=1 TO r_diff_row
                     PRINT COLUMN 1," "
                 END FOR
              END IF
           END IF

           -- 列印明細表結尾 --
           LET r_payform_var=p_payform_init
           LET r_payform_var=p_payform_e[3]
           LET r_payform_var[17,26]=p_cp_pay_detail.rtn_rece_no
           LET p_payform_e[3]=r_payform_var
           LET r_payform_var=p_payform_init
           LET r_payform_var=p_payform_e[4]
           LET r_payform_var[17,36]=r_dept_name[1,20]
           LET p_payform_e[4]=r_payform_var
           LET p_payform_e[5]=p_payform_init

           FOR r_i =1 TO 9
  --             IF r_i=9  THEN
  --                PRINT ASCII 27,"E"
  --             ELSE
                  PRINT COLUMN  1,p_payform_e[r_i] CLIPPED
  --             END IF
           END FOR

         ON LAST ROW
           PRINT ASCII 12

END REPORT -- cp_pay_dtl_usd 生存/滿期給付報表  --
