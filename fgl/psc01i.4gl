-----------------------------------------------------------------------------
--  程式名稱: psc01i.4gl
--  作    者: jessica Chang
--  日    期: 87/04/08
--  處理概要: 還本查詢
--  重要函式:
------------------------------------------------------------------------------
--  新增註記查詢與回覆查詢 89/2/24
------------------------------------------------------------------------------
--  修    改: JC 090/07/20 SR:PS90655S 還本修改,註記與抵繳保他張保單
--            define p_pc961_data record 程式放在 pc961p0.4gl 中
--            prss_code:EDIT=編輯,SAVE=存檔,DELE=刪除,PASS=過帳,QURY=查詢
------------------------------------------------------------------------------
--  修    者: JUCHUN 100/03/31 配合外幣還本進行修正
--            1.INTTGER -> FLOAT
--            2.新增外幣帳戶查詢
-----------------------------------------------------------------------------
--  修    者: cmwang 101/09/27
--            1.外幣保單新增F10還款試算畫面
--            2.還款試算畫面新增「週年日pv」欄位
--            3.新增「本保單近期有保單借款或自動墊繳，請留意」提示訊息
--            4.新增位回領取件註記之欄位
---------------------------------------------------------------------------
--  修    改: cmwang 103/10/24 SR140800458
--            1.新增F1 F12功能，取消display 領取人欄位改為開F11視窗顯示
---------------------------------------------------------------------------
--  修    改: cmwang 104/05/04 SR150300263還本查詢畫面新增保額明細查詢功能
---------------------------------------------------------------------------
--  修    改: JUCHUN 105/04/01 新增 F2:月給付險種
---------------------------------------------------------------------------
--  修    改: JUCHUN 105/07/20 避免月給付險種變更後，險種判斷錯誤
--            若已存在pscp,就用pscp紀錄的險種判斷;否則,用保單目前險種來判斷  
---------------------------------------------------------------------------
--  修    改: YiRong test github  
---------------------------------------------------------------------------

GLOBALS "../def/common.4gl"
GLOBALS "../def/lf.4gl"
GLOBALS "../def/pscgcpn.4gl"
-- 101/09/27 cmwang 未計算co_pv引用
GLOBALS "../def/vlinface.4gl"
-- 101/09/27 END

DATABASE life

    DEFINE p_space           CHAR(20)
          ,p_bell            CHAR
          ,b                 CHAR(1)

    DEFINE p_policy_no       LIKE polf.policy_no
          ,p_tx_date         CHAR(9)
          ,p_pass_or_deny    INTEGER
          ,p_pc961_sw        SMALLINT
          ,p_pc961_msg       CHAR(78)
    -- 修改 091/05/02 by kobe --
          ,p_po		     LIKE polf.policy_no

    -- 畫面一上半部的資料 --
    DEFINE p_data_s1 RECORD -- screen s1 --
           policy_no         LIKE polf.policy_no                -- 保單號碼 --
          ,currency          LIKE polf.currency                 -- 保單幣別 -- 100/03/31 ADD
          ,po_sts_code       LIKE polf.po_sts_code              -- 保單狀態 --
--          ,method            LIKE polf.method                   -- 保費繳法 --
          ,po_issue_date     LIKE polf.po_issue_date            -- 生效日 --
          ,paid_to_date      LIKE polf.paid_to_date             -- 繳費終日 --
--          ,cp_anniv_date     LIKE pscp.cp_anniv_date            -- 週年日 --
          ,tran_date         LIKE pscb.change_date              -- 交易日 --
          ,modx                  CHAR (2)                       -- 週期 -- 105/04/01 
	  ,dept_name	     LIKE dept.dept_name		-- 營業處 --
	  ,agent_name	     LIKE clnt.names			-- 業務員 --
    END RECORD

    -- 畫面二 detail 資料 --
    DEFINE p_data_s2 ARRAY[99] OF RECORD -- 還本的情形 --
           cp_anniv_date       LIKE pscp.cp_anniv_date          -- 週年日 --
          ,plan_code           CHAR(10)                         -- plan_code+rate_scale --
          ,st_code             CHAR(2)                          -- 狀況:未承認,承  認 -- 100/03/31 MODIFY原CHAR(6)
          ,nonresp_sw          LIKE psck.nonresp_sw             -- 執行過「整批未回覆領取」 -- 101/09/28 cmwang
          ,chk_sw              CHAR(1)                          -- N:支票未兌現 --
          ,cp_amt              LIKE pscp.cp_amt                 -- 應付金額 --
          ,add_amt             FLOAT                            -- 加項 --
          ,sub_amt             FLOAT                            -- 減項 --
          ,real_amt            FLOAT                            -- 實付值 --
          ,pay_type            CHAR(2)                          -- 種類:生存,滿期 --
    END RECORD

    -- 畫面三 受益人明細 detail 資料 --
    DEFINE p_data_s3 ARRAY[99] OF RECORD -- 還本的情形 --
           cp_pay_seq          LIKE pscd.cp_pay_seq             -- 週年日 --
          ,benf_name           LIKE clnt.names                  -- 受益人 --
          ,benf_ratio          LIKE pscd.benf_ratio             -- 狀況:未承認,承  認 --
          ,cp_real_payamt      LIKE pscd.cp_real_payamt         -- 實付金額 --
          ,disb_no             LIKE pscd.disb_no                -- 付款號碼 --
          ,remit_account       CHAR(24)                         -- 付款帳號
          ,bank_name           CHAR(40)                         --銀行名稱--
    END RECORD

    -- 畫面四 回覆詳細資料 --
    DEFINE p_data_s4 ARRAY[99] OF RECORD
           act_return_date      LIKE pscn.act_return_date       -- 回覆日 --
          ,notice_code          CHAR(8)                         -- 回覆情形 --
          ,notice_sub_code      CHAR(10)                        -- 處理情形 --
          ,process_user_name    CHAR(10)                        -- 處理者   --
          ,dept_name		CHAR(12)			-- 承辦單位 --
          ,cp_notice_serial     LIKE pscn.cp_notice_serial      -- 缺碼序號 --
    END  RECORD

    DEFINE p_pc961_data       RECORD
           policy_no          LIKE pscb.policy_no
          ,cp_anniv_date      LIKE pscb.cp_anniv_date
          ,prss_code          CHAR(4)
          ,tran_date          CHAR(9)
          ,cp_pay_amt         LIKE pcpm.cp_pay_amt
          ,col_policy_no_1    LIKE pscb.policy_no
          ,col_policy_no_2    LIKE pscb.policy_no
          ,col_policy_no_3    LIKE pscb.policy_no
          ,col_policy_no_4    LIKE pscb.policy_no
          ,col_policy_no_5    LIKE pscb.policy_no
          ,col_policy_no_6    LIKE pscb.policy_no
          ,col_policy_no_7    LIKE pscb.policy_no
          ,col_policy_no_8    LIKE pscb.policy_no
          ,col_policy_no_9    LIKE pscb.policy_no
          ,col_policy_no_10   LIKE pscb.policy_no
                          END RECORD

    --100/03/31 ADD
    DEFINE p_data_s3_ext ARRAY[99] OF RECORD
          client_id  LIKE benf.client_id
    END  RECORD
    --100/03/31 END
-- 主程式 --
MAIN

    DEFINE f_rcode INTEGER
    OPTIONS
        ERROR   LINE LAST,
        PROMPT  LINE LAST - 1,
        MESSAGE LINE LAST - 1,
        COMMENT LINE LAST

    DEFER INTERRUPT
    SET LOCK MODE TO WAIT

    LET g_program_id ="psc01i"
    LET p_space      =" "
    LET p_bell       =ASCII 7
    LET p_tx_date    =XDATE()

    LET p_po	     =ARG_VAL(2)

    -- Job Control beg --
    CALL JobControl()

    -- 顯示第一畫面 --
    OPEN FORM psc01i01 FROM "psc01i01"
    DISPLAY FORM psc01i01 ATTRIBUTE (GREEN)

    CALL ShowLogo()

    MENU "請選擇"
        BEFORE MENU
           IF  NOT CheckAuthority("1", FALSE)  THEN
               HIDE OPTION "1)查詢"
           END IF

        COMMAND "1)查詢"
            CALL psc01i00_init()
            CALL psc01i10_query()

        COMMAND "0)結束"
            EXIT MENU
        END MENU

    CLOSE FORM psc01i01

    -- Job Control beg --
    CALL JobControl()

END MAIN -- 主程式結束 --

------------------------------------------------------------------------------
--  函式名稱: psc01i00_init
--  作    者: jessica Chang
--  日    期: 87/04/08
--  處理概要: 還本查詢作業,畫面初值
--  重要函式:
------------------------------------------------------------------------------
FUNCTION psc01i00_init()
    DEFINE f_i SMALLINT -- array index ---

        LET  p_data_s1.policy_no           =" "
        LET  p_data_s1.currency            =" "   --100/03/31 ADD
        LET  p_data_s1.po_sts_code         =" "
--        LET  p_data_s1.method              =" "
        LET  p_data_s1.po_issue_date       ="000/00/00"
        LET  p_data_s1.paid_to_date        ="000/00/00"
--        LET  p_data_s1.cp_anniv_date       =" "
        LET  p_data_s1.tran_date           ="000/00/00"
        LET  p_data_s1.modx  = " "
	LET  p_data_s1.dept_name	   =" "
	LET  p_data_s1.agent_name	   =" "

    FOR f_i=1 to 99
        LET  p_data_s2[f_i].cp_anniv_date  ="         "
        LET  p_data_s2[f_i].plan_code      =" "
        LET  p_data_s2[f_i].st_code        =" "
        LET  p_data_s2[f_i].nonresp_sw     =" "
        LET  p_data_s2[f_i].chk_sw         =" "
        LET  p_data_s2[f_i].cp_amt         =0
        LET  p_data_s2[f_i].add_amt        =0
        LET  p_data_s2[f_i].sub_amt        =0
        LET  p_data_s2[f_i].real_amt       =0
        LET  p_data_s2[f_i].pay_type       =0
    END FOR

 CLEAR FORM

END FUNCTION   -- psc01i00_init --

------------------------------------------------------------------------------
--  函式名稱: psc01i10_query
--  作    者: jessica Chang
--  日    期: 87/04/08
--  處理概要: 還本查詢作業,查詢畫面
--  重要函式:
------------------------------------------------------------------------------
FUNCTION psc01i10_query()

    DEFINE f_rcode              INTEGER
    DEFINE f_po                 CHAR(255) -- 取得 po 資訊的 prepare --
    DEFINE f_i                  INTEGER   -- array 計數器 --
    DEFINE f_pscb_cnt           INTEGER   -- 執行 perpare 指令有保單可執行 --
          ,f_polf_cnt           INTEGER   -- polf 是否存在 input 保單 --
          ,f_right_or_fault     INTEGER   -- 日期檢查 t or f --
          ,f_formated_date      CHAR(9)   -- 日期格式化 999/99/99 --

    DEFINE f_cp_anniv_date      LIKE    pscb.cp_anniv_date
          ,f_cp_sw              LIKE    pscb.cp_sw
          ,f_cp_disb_type       LIKE    pscb.cp_disb_type
          ,f_disb_special_ind   LIKE    pscb.disb_special_ind
          ,f_mail_addr_ind      LIKE    pscb.mail_addr_ind
          ,f_cp_notice_sw       LIKE    pscb.cp_notice_sw
          ,f_dtl_cp_ann         LIKE    pscb.cp_anniv_date
          ,f_cp_notice_formtype LIKE    pscr.cp_notice_formtype

    DEFINE f_arr                INTEGER
          ,f_dtl_real_amt       FLOAT

    -- 091/03/27 新增 --
    DEFINE f_expired_date	CHAR(9)
    -- 101/09/28 cmwang 新增
    DEFINE fmd CHAR(500)
    DEFINE f_j INT
    DEFINE f_loan_date LIKE lnnl.loan_date_init
    DEFINE f_loan_ind INT
    DEFINE test_cp_anniv_date CHAR(9)
    DEFINE test_today CHAR(9)
    DEFINE f_anniv_larger_ind INT
    DEFINE f_psck_cnt INT
    -- 101/09/28 END

    MESSAGE "END:離開"

    LET INT_FLAG=FALSE

    INPUT p_data_s1.policy_no
    FROM  policy_no
  ATTRIBUTE(BLUE ,REVERSE ,UNDERLINE)

    BEFORE FIELD policy_no
          IF p_po = ""
	  OR p_po = " "
          OR p_po IS NULL THEN
	  ELSE
             LET p_data_s1.policy_no = p_po
          END IF

    AFTER FIELD policy_no

          IF p_data_s1.policy_no=" " OR
             p_data_s1.policy_no="            " THEN
             ERROR "保單號碼必須輸入!!" ATTRIBUTE (RED)
             NEXT FIELD policy_no
          END IF

          ON KEY (F7)
          LET INT_FLAG=TRUE
          EXIT INPUT

    AFTER INPUT

    IF INT_FLAG=TRUE THEN
       LET INT_FLAG=TRUE
       EXIT INPUT
    END IF

    LET p_policy_no=p_data_s1.policy_no
    LET f_pscb_cnt=0

   -- g_polf 的資料 --
    SELECT *
    INTO   g_polf.*
    FROM   polf
    WHERE  policy_no=p_policy_no

    IF STATUS=NOTFOUND THEN
#    IF SQLCA.SQLERRD[3]=0 THEN
       ERROR "無此張保單" ATTRIBUTE (RED)
       NEXT FIELD policy_no
    END IF

    LET p_data_s1.currency = g_polf.currency    --100/03/31 ADD

    -- g_pscb 的資料 --
    SELECT count(*) INTO f_pscb_cnt
    FROM   pscb
    WHERE  policy_no=p_policy_no

    IF f_pscb_cnt =0      THEN
       ERROR "此張保單無還本資料" ATTRIBUTE (RED)
       NEXT FIELD policy_no
    END IF

    END INPUT

    -- 中斷作業 --
    IF INT_FLAG=TRUE THEN
       MESSAGE " "
       RETURN
    END IF

    LET p_policy_no=p_data_s1.policy_no
    LET f_polf_cnt=0

    SELECT MAX(change_date)
    INTO   p_data_s1.tran_date
    FROM   pscb
    WHERE  policy_no=p_data_s1.policy_no
    AND    cp_sw in ("2","5","6")

    IF p_data_s1.tran_date IS NULL OR
       p_data_s1.tran_date =" "    THEN
       LET p_data_s1.tran_date="000/00/00"
    END IF

    -- 營業處, 業務員 --
    -- 注意 "b" 為定義變數, 所以Table 不能為"b", 為什麼設"b" ?? 不知道.....
    SELECT c.names, e.dept_name
    INTO   p_data_s1.agent_name, p_data_s1.dept_name
    FROM   poag a, clnt c, agnt d, dept e
    WHERE  a.agent_code = c.client_id
    AND    a.agent_code = d.agent_code
    AND    d.dept_code  = e.dept_code
    AND    a.policy_no  = g_polf.policy_no
    AND    a.relation   = "S"

    -- 畫面一的上半部資料 --
    LET  p_data_s1.policy_no      =g_polf.policy_no
    LET  p_data_s1.po_sts_code    =g_polf.po_sts_code
--    LET  p_data_s1.method         =g_polf.method
    LET  p_data_s1.po_issue_date  =g_polf.po_issue_date
    LET  p_data_s1.paid_to_date   =g_polf.paid_to_date
--    LET  p_data_s1.cp_anniv_date  ="000/00/00"

    -- 105/04/01 ADD
    IF psc99s01_pay_modx(g_polf.policy_no) = '1' THEN
    	  LET p_data_s1.modx = "月"
    ELSE
        LET p_data_s1.modx = "年"
    END IF
    	  
    -- 顯示取得的資料(畫面一上半部) --
    DISPLAY BY NAME p_data_s1.*
      ATTRIBUTE (YELLOW)

----------------------------------
-- 092/12/15 週年日條件取消輸入 --
----------------------------------
{
    INPUT p_data_s1.cp_anniv_date
    FROM  cp_anniv_date
    ATTRIBUTE(BLUE ,REVERSE ,UNDERLINE)
    AFTER FIELD cp_anniv_date
       IF p_data_s1.cp_anniv_date=" "     OR
          p_data_s1.cp_anniv_date is NULL THEN
          LET p_data_s1.cp_anniv_date="000/00/00"
#          DISPLAY p_data_s1.cp_anniv_date TO cp_anniv_date ATTRIBUTE (YELLOW)
       END IF

       IF p_data_s1.cp_anniv_date !="000/00/00" THEN
          CALL CheckDate(p_data_s1.cp_anniv_date)
               RETURNING f_right_or_fault , f_formated_date
          IF f_right_or_fault = false THEN
             ERROR "週年日輸入錯誤!!" ATTRIBUTE (RED)
             NEXT FIELD cp_anniv_date
          ELSE
             LET  p_data_s1.cp_anniv_date=f_formated_date
#             DISPLAY p_data_s1.cp_anniv_date TO cp_anniv_date ATTRIBUTE (YELLOW)
          END IF
       END IF

       ON KEY (F7)
          LET INT_FLAG=TRUE
          EXIT INPUT

    AFTER INPUT
    DISPLAY p_data_s1.cp_anniv_date TO cp_anniv_date ATTRIBUTE (YELLOW)

    IF INT_FLAG=TRUE THEN
       LET INT_FLAG=TRUE
       EXIT INPUT
    END IF
}

    DECLARE f_s1 CURSOR FOR
            SELECT cp_anniv_date
                  ,cp_sw
                  ,cp_disb_type
                  ,disb_special_ind
                  ,mail_addr_ind
                  ,cp_notice_sw
            FROM  pscb
            WHERE policy_no=p_data_s1.policy_no
--            AND   cp_anniv_date <= p_data_s1.cp_anniv_date
            ORDER BY cp_anniv_date DESC

    LET f_i=0
    FOREACH f_s1 INTO f_cp_anniv_date
                     ,f_cp_sw
                     ,f_cp_disb_type
                     ,f_disb_special_ind
                     ,f_mail_addr_ind
                     ,f_cp_notice_sw

    LET f_i=f_i+1
    LET p_data_s2[f_i].cp_anniv_date=f_cp_anniv_date
    -- 101/09/28 cmwang 判斷是否出現提示訊息「本保單近期有保單結款或
    --           自動墊繳」
    -- 判斷規則:1.最近還本日p_data_s2[1].cp_anniv_date -45 <= today
    --          2.最近還本日~查詢日期間有新增保單借款或自動墊繳者
    -- 101/10/30 cmwang 再次確認需求為
    -- 判斷規則:1.查詢日限制 p_data_s2[1].cp_anniv_date -45 <= today <= p_data_s2[1].cp_anniv_date + 20
    --          2.初借日限制 最近還本週年日 p_data_s2[1].cp_anniv_date -45 <= 初借日 <= p_data_s2[1].cp_anniv_date + 20
    IF f_i = 1 THEN
{
       IF AddDay(p_data_s2[1].cp_anniv_date,-45) <= getDate(TODAY) THEN
       	 LET test_cp_anniv_date = AddDay(p_data_s2[1].cp_anniv_date,-45)
       	 LET test_today = getDate(TODAY)
--       	 DISPLAY "test_cp_anniv_date",test_cp_anniv_date
--       	 DISPLAY "test_today",test_today
       	 IF p_data_s2[1].cp_anniv_date > getDate(TODAY) THEN
       	 	 LET f_anniv_larger_ind = 1
       	 ELSE
       	 	 LET f_anniv_larger_ind = 0
       	 END IF
--       	 DISPLAY "f_anniv_larger_ind",f_anniv_larger_ind
       	 LET fmd = " select distinct loan_date_init "
       	          ," from lnnl"
       	          ," where loan_amt > 0 "
       	          ," and policy_no = '",p_data_s1.policy_no ," ' "
       	 PREPARE qry FROM fmd
       	 LET f_loan_ind = 0
       	 DECLARE loan_date_qry CURSOR  FOR qry
       	 FOREACH loan_date_qry INTO f_loan_date
--       	 	 DISPLAY "f_loan_date:",f_loan_date
       	 	 IF f_anniv_larger_ind THEN
       	 	 	 IF f_loan_date < p_data_s2[1].cp_anniv_date AND
       	 	 	 	  f_loan_date > getDate(TODAY) THEN
       	 	 	 	 LET  f_loan_ind = 1
       	 	 	 	 EXIT FOREACH
       	 	 	 END IF
       	 	 ELSE
       	 	   IF f_loan_date < getDate(TODAY)
       	 	   	  AND f_loan_date > p_data_s2[1].cp_anniv_date THEN
       	 	 	   LET f_loan_ind = 1
       	 	 	   EXIT FOREACH
       	 	 	 END IF
       	 	 END IF
       	 END FOREACH
       	 IF f_loan_ind = 1 THEN
       	 	 ERROR "本保單近期有保單借款或自動墊繳，請留意!" ATTRIBUTE(RED,UNDERLINE)
       	 END IF
       END IF
       }
      IF AddDay(p_data_s2[1].cp_anniv_date,-45) <= getDate(TODAY)
      	 AND AddDay(p_data_s2[1].cp_anniv_date,30) >= getDate(TODAY) THEN
--      	DISPLAY "查詢日介於還本周年日(-45,+30)之間"
--      	LET test_today = getDate(TODAY)
--      	DISPLAY "test_today"
--      	LET test_cp_anniv_date = AddDay(p_data_s2[1].cp_anniv_date,-45)
--      	DISPLAY "test_cp_anniv_date_from",test_cp_anniv_date
--      	LET test_cp_anniv_date = AddDay(p_data_s2[1].cp_anniv_date,+20)
--      	DISPLAY "test_cp_anniv_date_end",test_cp_anniv_date
      	LET fmd = " select distinct loan_date_init "
       	          ," from lnnl"
       	          ," where loan_amt > 0 "
       	          ," and policy_no = '",p_data_s1.policy_no ," ' "
        PREPARE qry FROM fmd
       	LET f_loan_ind = 0
       	DECLARE loan_date_qry CURSOR  FOR qry
      	FOREACH loan_date_qry INTO f_loan_date
--       	 	 DISPLAY "f_loan_date:",f_loan_date
       	 	 IF AddDay(p_data_s2[1].cp_anniv_date,-45) <= f_loan_date
       	 	 	  AND AddDay(p_data_s2[1].cp_anniv_date,30) >= f_loan_date THEN
--       	 	 	 DISPLAY "初借日介於還本周年日(-45,+30)之間"
 --      	 	 	 LET test_today = f_loan_date
--       	 	 	 DISPLAY f_loan_date
       	 	 	 ERROR "本保單近期有保單借款或自動墊繳，請留意!" ATTRIBUTE(RED,UNDERLINE)
       	 	 	 EXIT FOREACH
       	 	 END IF
       	 END FOREACH
      END IF
    END IF
    -- 101/09/28 cmwang 新增未領回取件註記之欄位
    LET f_psck_cnt = 0
    SELECT COUNT(*)
      INTO f_psck_cnt
      FROM psck
      WHERE nonresp_sw = "Y"
        AND policy_no = p_data_s1.policy_no
        AND cp_anniv_date = p_data_s2[f_i].cp_anniv_date
    IF f_psck_cnt THEN
    	LET p_data_s2[f_i].nonresp_sw = "*"
    END IF
    -- 101/09/28 END
    -- 已進入領取階段的保單 --
       IF f_cp_sw="2" OR
          f_cp_sw="3" OR
          f_cp_sw="5" OR
          f_cp_sw="6" OR
          f_cp_sw="7" THEN
          INITIALIZE g_pscp.* TO NULL

          SELECT *
          INTO   g_pscp.*
          FROM   pscp
          WHERE  policy_no    =p_data_s1.policy_no
          AND    cp_anniv_date=f_cp_anniv_date


          LET p_data_s2[f_i].cp_amt   =g_pscp.cp_amt
          LET p_data_s2[f_i].add_amt  =g_pscp.prem_susp
                                      +g_pscp.accumulated_div
                                      +g_pscp.div_int_balance
                                      +g_pscp.div_int
          LET p_data_s2[f_i].sub_amt  =g_pscp.rtn_minus_premsusp
                                      +g_pscp.rtn_loan_amt
                                      +g_pscp.rtn_loan_int
                                      +g_pscp.rtn_apl_amt
                                      +g_pscp.rtn_apl_int
          LET p_data_s2[f_i].real_amt =p_data_s2[f_i].cp_amt
                                      +p_data_s2[f_i].add_amt
                                      -p_data_s2[f_i].sub_amt
          LET p_data_s2[f_i].plan_code=g_pscp.plan_code,'-'
                                      ,g_pscp.rate_scale

          -- 判斷生存/滿期 --
          CASE
              WHEN g_pscp.cp_pay_form_type="5"
                   LET p_data_s2[f_i].pay_type  ="生"
                   LET p_data_s2[f_i].chk_sw    =" "
              WHEN g_pscp.cp_pay_form_type="5.1"
                   LET p_data_s2[f_i].pay_type  ="生"
                   IF f_cp_sw="3" THEN
                      LET p_data_s2[f_i].chk_sw ="N"
                   ELSE
                      LET p_data_s2[f_i].chk_sw =" "
                   END IF
              WHEN g_pscp.cp_pay_form_type="6"
                   LET p_data_s2[f_i].pay_type  ="滿"
                   LET p_data_s2[f_i].chk_sw    =" "
              WHEN g_pscp.cp_pay_form_type="6.1"
                   LET p_data_s2[f_i].pay_type  ="滿"
                   IF f_cp_sw="3" THEN
                      LET p_data_s2[f_i].chk_sw ="N"
                   ELSE
                      LET p_data_s2[f_i].chk_sw =" "
                   END IF
              WHEN g_pscp.cp_pay_form_type="6.2"
                   LET p_data_s2[f_i].pay_type  ="滿"
                   IF f_cp_sw="3" THEN
                      LET p_data_s2[f_i].chk_sw ="N"
                   ELSE
                      LET p_data_s2[f_i].chk_sw =" "
                   END IF
              OTHERWISE
                   LET p_data_s2[f_i].pay_type  =" "
                   LET p_data_s2[f_i].chk_sw    =" "
          END CASE

          -- 判斷狀況 --
          IF f_cp_sw="3"  THEN
             LET p_data_s2[f_i].st_code = "C2"             -- 100/03/31 MODIFY 原"未兌現"
          ELSE
             IF f_cp_sw = "2" OR
                f_cp_sw = "5" OR
                f_cp_sw = "6" THEN
                IF psc99s02_pay_finish(p_data_s1.policy_no,p_data_s2[f_i].cp_anniv_date) = 'N' THEN -- 105/04/01 給付中
                    LET p_data_s2[f_i].st_code ="B4"  
                ELSE   
                    LET p_data_s2[f_i].st_code ="A1"           -- 100/03/31 MODIFY 原"已領取"
                END IF
             ELSE
                IF f_cp_sw = "7" THEN
                    IF  f_cp_notice_sw = "1" OR
                        f_cp_notice_sw = "4" THEN
                        LET p_data_s2[f_i].st_code="B1"   -- 100/03/31 MODIFY 原"照會中"
                    END IF
                    IF  f_cp_notice_sw = "2" OR
                        f_cp_notice_sw = "3" THEN
                        LET p_data_s2[f_i].st_code="B2"   -- 100/03/31 MODIFY 原"等待中"
                    END IF
                    IF  f_cp_notice_sw = "0" THEN
                        LET p_data_s2[f_i].st_code="C1"   -- 100/03/31 MODIFY 原"未回覆"
                    END IF
                END IF
            END IF
         END IF
         CONTINUE FOREACH
       END IF

       -- 尚未進入領取階段的保單 --
       IF f_cp_sw="0" OR
          f_cp_sw="1" OR
          f_cp_sw="4" OR
	        f_cp_sw="8" THEN
          LET p_data_s2[f_i].chk_sw     =" "
          LET p_data_s2[f_i].cp_amt     =0
          LET p_data_s2[f_i].add_amt    =0
          LET p_data_s2[f_i].sub_amt    =0
          LET p_data_s2[f_i].real_amt   =0

          SELECT expired_date INTO f_expired_date
          FROM   polf
          WHERE  policy_no    =p_data_s1.policy_no

          SELECT cp_notice_formtype INTO f_cp_notice_formtype
          FROM   pscr
          WHERE  policy_no    =p_data_s1.policy_no
          AND    cp_anniv_date=f_cp_anniv_date

          -- 判斷生存/滿期 --
          CASE
             WHEN f_cp_notice_formtype  ="1"
                  LET p_data_s2[f_i].pay_type   ="生"
             WHEN f_cp_notice_formtype  ="1.1"
                  LET p_data_s2[f_i].pay_type   ="生"
             WHEN f_cp_notice_formtype  ="2"
                  LET p_data_s2[f_i].pay_type   ="滿"
             WHEN f_cp_notice_formtype  ="2.1"
                  LET p_data_s2[f_i].pay_type   ="滿"
             WHEN f_cp_notice_formtype  ="3"
                  LET p_data_s2[f_i].pay_type   ="生"
             WHEN f_cp_notice_formtype  ="3.1"
                  LET p_data_s2[f_i].pay_type   ="生"
             WHEN f_cp_notice_formtype  ="4"
                  LET p_data_s2[f_i].pay_type   ="滿"
             WHEN f_cp_notice_formtype  ="4.1"
                  LET p_data_s2[f_i].pay_type   ="滿"
             WHEN f_cp_notice_formtype  ="5"
                  IF f_cp_anniv_date >= f_expired_date THEN
                     LET p_data_s2[f_i].pay_type="滿"
                  ELSE
                     LET p_data_s2[f_i].pay_type="生"
                  END IF
             OTHERWISE
                  LET p_data_s2[f_i].pay_type   ="  "
          END CASE

         -- 判斷狀況 --
         IF  f_cp_sw="1"
	           OR  f_cp_sw="4"
	           OR  f_cp_sw="8" THEN
             IF  f_cp_notice_sw="1" OR
                 f_cp_notice_sw="4" THEN
                 LET p_data_s2[f_i].st_code="B1"  -- 100/03/31 MODIFY原"照會中"
             END IF

             IF  f_cp_notice_sw="0" THEN
                 LET p_data_s2[f_i].st_code="B3" -- 100/03/31 MODIFY原"通知中"
             END IF

             IF  f_cp_notice_sw="2" THEN
                 LET p_data_s2[f_i].st_code="A2" -- 100/03/31 MODIFY原"已回覆"
             END IF

             IF  f_cp_notice_sw="3" THEN
                 LET p_data_s2[f_i].st_code="C3" -- 100/03/31 MODIFY原"未回領"
             END IF
         ELSE
             LET p_data_s2[f_i].st_code    ="C4" -- 100/03/31 MODIFY原"未通知"
         END IF
         CONTINUE FOREACH
       END IF

       -- 已經作廢的保單 --
       IF f_cp_sw="A" OR
          f_cp_sw="B" OR
          f_cp_sw="C" THEN
          LET p_data_s2[f_i].st_code    ="D1"        -- 100/03/31 MODIFY原"作  廢"
          LET p_data_s2[f_i].chk_sw     =" "
          LET p_data_s2[f_i].cp_amt     =0
          LET p_data_s2[f_i].add_amt    =0
          LET p_data_s2[f_i].sub_amt    =0
          LET p_data_s2[f_i].real_amt   =0
          LET p_data_s2[f_i].pay_type   =""
      END IF
   END FOREACH

--   IF f_i=0 THEN
--      ERROR "找不到資料!!" ATTRIBUTE (RED)
--      NEXT FIELD cp_anniv_date
--   END IF

   IF f_i > 99 THEN
      ERROR "資料過多請洽資訊部!!" ATTRIBUTE (RED)
      MESSAGE " "
      RETURN
--      NEXT FIELD cp_anniv_date
   END IF

--   END INPUT

   -- 中斷作業 --
   IF INT_FLAG=TRUE THEN
      MESSAGE " "
      RETURN
   END IF

   MESSAGE " END(F7):取消作業 F1:保額明細 F5:受益人給付明細"

   OPEN WINDOW w_s2 AT 9,3 WITH FORM "psc01i02"
        ATTRIBUTE(GREEN, FORM LINE FIRST)

   CALL set_count(f_i)

   DISPLAY f_i to total_record

   DISPLAY ARRAY p_data_s2 TO psc01_s2.*
     ATTRIBUTE (YELLOW)
     ON KEY (F7)
           LET INT_FLAG=true
           EXIT DISPLAY
     ON KEY (F1)
        LET f_arr=ARR_CURR()
        CALL psc01i_cp_amt_query( p_policy_no                    ,
                                  p_data_s2[f_arr].cp_anniv_date ,
                                  p_data_s2[f_arr].cp_amt        )
     ON KEY (F5)          --還本查詢作業,受益人給付明細
        LET f_arr=ARR_CURR()
        LET f_dtl_real_amt =p_data_s2[f_arr].real_amt
        LET f_dtl_cp_ann   =p_data_s2[f_arr].cp_anniv_date
        CALL psc01i20_detail_query (p_policy_no
                                   ,f_dtl_cp_ann
                                   )
             RETURNING f_rcode
        {
        IF f_dtl_real_amt=0 THEN
           ERROR   "此週年日無受益人明細!!"
           ATTRIBUTE (RED)
        ELSE
           CALL psc01i20_detail_query (p_policy_no
                                      ,f_dtl_cp_ann
                                       )
                RETURNING f_rcode
           IF f_rcode !=0 THEN
              ERROR   "此週年日無受益人明細!!"
              ATTRIBUTE (RED)
           END IF
        END IF
        }
    END DISPLAY

    IF INT_FLAG=true THEN
       MESSAGE " "
       CLOSE WINDOW w_s2
       RETURN
    END IF

    CLOSE WINDOW w_s2
    RETURN
END FUNCTION   -- psc01i10_query --

------------------------------------------------------------------------------
--  函式名稱: psc01i02_detail_query
--  作    者: jessica Chang
--  日    期: 87/04/08
--  處理概要: 還本查詢作業,受益人給付明細
--  重要函式:
------------------------------------------------------------------------------
FUNCTION psc01i20_detail_query (f_policy_no
                               ,f_cp_ann
                               )
    DEFINE  f_rcode             INTEGER
           ,f_data_sw           INTEGER
           ,f_psck_cnt          INTEGER
           ,f_psck_sw           CHAR(1)
    DEFINE  f_policy_no         LIKE polf.policy_no
           ,f_cp_ann            LIKE pscp.cp_anniv_date
    DEFINE  f_dept_len          INTEGER  -- 營業處長度,舊的資料 --

    DEFINE  f_i                 INTEGER -- array 計數器 --
           ,r_i			INTEGER -- array 計數器 --
           ,f_benf_name         LIKE clnt.names -- 受益人 name --

    -- 給付方式、電匯指示、郵寄指示 --
    DEFINE  f_cp_sw             LIKE pscb.cp_sw
           ,f_cp_disb_type      LIKE pscb.cp_disb_type
           ,f_disb_special_ind  LIKE pscb.disb_special_ind
           ,f_mail_addr_ind     LIKE pscb.mail_addr_ind

    -- 營業處 與 業務員 --
    DEFINE f_dept_code          LIKE pscp.dept_code
          ,f_agent_code         LIKE pscp.agent_code
          ,f_dept_mail          LIKE dept.dept_mail

    -- 要保人 id 與 names --
    DEFINE  f_applicant_id      LIKE clnt.client_id
           ,f_applicant_name    LIKE clnt.names

    -- 超借, 還款, 回覆指示 --
    DEFINE  f_overloan_sw	LIKE pscb.overloan_sw
	   ,f_cp_rtn_sw		LIKE pscb.cp_rtn_sw
	   ,f_notice_resp_sw	LIKE pscb.notice_resp_sw

    -- 畫面的顯示欄位 --
    DEFINE  f_disb_desc         CHAR(8)
           ,f_special_desc      CHAR(4)
           ,f_zip_code          LIKE  addr.zip_code
           ,f_address           LIKE  addr.address
           ,f_address_1         LIKE  addr.address
           ,f_cp_chk_date       LIKE  pscp.cp_chk_date
           ,f_cp_pay_name       LIKE pscb.cp_pay_name
           ,f_cp_pay_id         LIKE pscb.cp_pay_id
           ,f_pay_dept_code     LIKE pscb.dept_code
           ,f_pay_dept_name	LIKE dept.dept_name
           ,f_pay_dept_name_1	LIKE dept.dept_name
           ,f_relation          LIKE benf.relation
           ,f_pay_change_name	CHAR(70)
           ,f_pay_change_name_1 CHAR(70)
           ,f_benf_name_all     CHAR(38)
           ,f_id_copy_sw	CHAR(1)
	   ,f_overloan_desc	CHAR(1)
	   ,f_cp_rtn_desc	CHAR(1)
	   ,f_notice_resp_desc	CHAR(1)
	   ,f_remit_date	CHAR(9)
           ,f_guarantee_sw      LIKE pscb.guarantee_sw --101/11/20新增
    DEFINE  f_benf_name_1       LIKE clnt.names
           ,f_client_id_1	LIKE clnt.client_id

    DEFINE  f_total_record SMALLINT
    DEFINE  f_pscd_count   SMALLINT
    DEFINE  f_pscd              RECORD LIKE pscd.*
    DEFINE  f_benf              RECORD LIKE benf.*
    DEFINE  f_pscs		RECORD LIKE pscs.*

    -- 100/03/31 ADD
    DEFINE  f_cp_real_payamt   LIKE  pscd.cp_real_payamt
    DEFINE  f_disb_no          LIKE  pscd.disb_no
    DEFINE  f_bank_account_e   LIKE  benp.bank_account_e
    DEFINE  f_bank_code        LIKE  benp.bank_code
    DEFINE  f_arr_cur          INTEGER
    DEFINE  f_pscx             RECORD LIKE pscx.*
    DEFINE  f_pscy             RECORD LIKE pscy.*
    DEFINE  f_psbh_cnt         INT
    -- 100/03/31 END

    LET f_rcode                 =0
    LET f_dept_len              =0
    LET f_total_record          =0
    LET f_pscd_count            =0
    LET f_zip_code              =""
    LET f_cp_chk_date           ="000/00/00"
    LET f_cp_pay_name           =""
    LET f_cp_pay_id             =""
    LET f_pay_dept_code         =""
    LET f_pay_dept_name		=""
    LET f_pay_dept_name_1	=""
    LET f_address               =""
    LET f_relation              =""
    LET f_pay_change_name	=""
    LET f_pay_change_name_1	=""
    LET f_benf_name_all		=""
    LET f_id_copy_sw		=""
    LET f_overloan_desc		=""
    LET f_cp_rtn_desc		=""
    LET f_notice_resp_desc	=""
    LET f_remit_date		=""
    LET f_guarantee_sw          =""
    SELECT cp_sw,cp_disb_type,disb_special_ind,mail_addr_ind
          ,cp_pay_name,cp_pay_id,dept_code
          ,address,zip_code
	  ,overloan_sw,cp_rtn_sw,notice_resp_sw
    INTO   f_cp_sw,f_cp_disb_type,f_disb_special_ind,f_mail_addr_ind
          ,f_cp_pay_name,f_cp_pay_id,f_pay_dept_code
          ,f_address,f_zip_code
	  ,f_overloan_sw,f_cp_rtn_sw,f_notice_resp_sw
    FROM   pscb
    WHERE  policy_no    =f_policy_no
    AND    cp_anniv_date=f_cp_ann

    SELECT dept_name
    INTO   f_pay_dept_name
    FROM   dept
    WHERE  dept_code=f_pay_dept_code

    LET f_dept_code=""
    LET f_agent_code=""
    LET f_psbh_cnt = 0

    SELECT count(*)
      INTO f_psbh_cnt
      FROM psbh
     WHERE policy_no = f_policy_no
       AND cp_anniv_date = f_cp_ann
       AND cp_rtn_sts in ('0','1')


    SELECT dept_code,agent_code,cp_chk_date
    INTO   f_dept_code,f_agent_code,f_cp_chk_date
    FROM   pscp
    WHERE  policy_no    =f_policy_no
    AND    cp_anniv_date=f_cp_ann

    IF f_dept_code is null THEN
       SELECT  agent_code INTO f_agent_code
       FROM    poag
       WHERE   policy_no=f_policy_no
       AND     relation="S"

       SELECT  dept_code INTO f_dept_code
       FROM    agnt
       WHERE   agent_code=f_agent_code

   END IF

   CASE
       WHEN f_cp_disb_type="0"
            LET f_disb_desc="郵寄支票"
       WHEN f_cp_disb_type="1"
            LET f_disb_desc="櫃臺領取"
       WHEN f_cp_disb_type="2"
            LET f_disb_desc="抵繳保費"
       WHEN f_cp_disb_type="3"
            LET f_disb_desc="電    匯"
       WHEN f_cp_disb_type="4"
            LET f_disb_desc="未回覆件"
       WHEN f_cp_disb_type="5"
	    LET f_disb_desc="主動電匯"
       WHEN f_cp_disb_type="6"
            LET f_disb_desc="回    流"

       OTHERWISE
            LET f_disb_desc="其    它"
    END CASE

    CASE
       WHEN f_disb_special_ind="0"
            LET f_special_desc="正常"
       WHEN f_disb_special_ind="1"
            LET f_special_desc="指定"
       OTHERWISE
            LET f_special_desc="其它"
    END CASE
{
    -- 指定電匯的資料 --
    IF f_disb_special_ind="1" THEN

       SELECT remit_bank,remit_branch,remit_account
       INTO   f_pscs_remit_bank,f_pscs_remit_branch,f_remit_account
       FROM   pscs
       WHERE  policy_no=f_policy_no
       AND    cp_anniv_date=f_cp_ann

       LET  f_bank_code=f_pscs_remit_bank,f_pscs_remit_branch

       SELECT bank_name INTO f_bank_name
       FROM   bank
       WHERE  bank_code=f_bank_code

       LET f_bank_name=f_bank_name CLIPPED

    END IF
}
    LET f_dept_len=LENGTH(f_dept_code CLIPPED)

    IF f_dept_len =4 THEN
       LET f_dept_code=f_dept_code CLIPPED ,"0"
    END IF

    IF f_agent_code is null OR
       f_agent_code =" "    THEN

       SELECT  agent_code INTO f_agent_code
       FROM    poag
       WHERE   policy_no=f_policy_no
       AND     relation="S"

    END IF

    SELECT dept_mail
    INTO   f_dept_mail
    FROM   dept
    WHERE  dept_code=f_dept_code

    -- 要保人ID,姓名 --
    CALL getNames(g_polf.policy_no,'O1')
         RETURNING f_applicant_id,f_applicant_name

    -- 郵寄資料 --
    IF f_cp_sw !="2"    AND
       f_cp_sw !="5"    AND
       f_cp_sw !="6"    THEN
       ---------------------------------------------------------------
       -- SR:PS88217S pscb 中郵寄為 空白必須參考 polf.mail_addr_ind --
       ---------------------------------------------------------------

       IF LENGTH(f_mail_addr_ind CLIPPED)=0 THEN
          LET f_address="請參考收費地址！！"
          LET f_zip_code=""
       ELSE
         IF f_mail_addr_ind = "Q" THEN
           SELECT address,zip_code
           INTO   f_address,f_zip_code
           FROM   psc3
           WHERE  policy_no = g_polf.policy_no
           AND    cp_anniv_date = f_cp_ann
           AND    client_id = f_applicant_id
           AND    addr_ind = "Q"
         ELSE
           SELECT address,zip_code
           INTO   f_address,f_zip_code
           FROM   addr
           WHERE  client_id=f_applicant_id
           AND    addr_ind =f_mail_addr_ind
         END IF
       END IF
    END IF

    IF g_polf.expired_date > f_cp_ann THEN
       LET f_relation="L"
    ELSE
       LET f_relation="M"
    END IF
    -- 受益人  --
    DECLARE benf_name_ptr CURSOR FOR
      SELECT client_id, names
      FROM   benf
      WHERE  policy_no  =f_policy_no
      AND    relation	=f_relation
--      ORDER BY benf_order

    LET f_client_id_1=""
    LET f_benf_name_1=""
    LET r_i	     =1
    FOREACH benf_name_ptr INTO f_client_id_1,f_benf_name_1

      IF f_client_id_1  !=" " THEN
         SELECT names INTO f_benf_name_1
         FROM   clnt
         WHERE  client_id=f_client_id_1
      END IF
      IF f_benf_name_1 IS NULL THEN
         LET f_benf_name_1=""
      END IF
      IF r_i=1 THEN
         LET f_benf_name_all=f_benf_name_1
      ELSE
         LET f_benf_name_all=f_benf_name_all CLIPPED," ",f_benf_name_1
      END IF
      LET f_client_id_1=""
      LET f_benf_name_1=""
      LET r_i=r_i+1
    END FOREACH

    -- 給付變更 --
    SELECT cp_remark_desc_5
    INTO   f_pay_change_name
    FROM   psck
    WHERE  policy_no=f_policy_no
    AND    cp_anniv_date=f_cp_ann
    AND    cp_remark_desc_5[69]='1'

    IF STATUS = NOTFOUND THEN
    ELSE
       LET f_pay_change_name_1=f_pay_change_name[1,10]
    END IF

    FOR f_i=1 TO 99
        LET p_data_s3[f_i].cp_pay_seq    =0
        LET p_data_s3[f_i].benf_name     =" "
        LET p_data_s3[f_i].benf_ratio    =0
        LET p_data_s3[f_i].cp_real_payamt=0
        LET p_data_s3[f_i].disb_no       =" "
        LET p_data_s3[f_i].remit_account =" "
        LET p_data_s3[f_i].bank_name     =" "
        LET p_data_s3_ext[f_i].client_id =" "  --100/03/31 ADD
    END FOR

    LET f_i=0


    -- 100/03/31 MODIFY
    -- 有指定則顯示指定受益人 --
    IF f_disb_special_ind = "1" THEN
    	 IF p_data_s1.currency = 'TWD' THEN
          SELECT *
          INTO   f_pscs.*
          FROM   pscs
          WHERE  policy_no	    =f_policy_no
          AND    cp_anniv_date =f_cp_ann

          LET f_i=f_i+1

          -- 受領人
          LET f_benf_name=f_pscs.payee
          LET p_data_s3[f_i].benf_name	=f_benf_name[1,10]

          -- 受領人ID
          LET p_data_s3_ext[f_i].client_id =f_pscs.client_id

          -- 順序/比率
          LET p_data_s3[f_i].cp_pay_seq	=1
          LET p_data_s3[f_i].benf_ratio =100

          -- 電匯帳號
          LET p_data_s3[f_i].remit_account =f_pscs.remit_bank
				   	,f_pscs.remit_branch,'-'
				   	,f_pscs.remit_account

			    -- 銀行名稱
          SELECT bank_name
          INTO   p_data_s3[f_i].bank_name
          FROM   bank
          WHERE  bank_code[1,3] = f_pscs.remit_bank
          AND    bank_code[4,7] = f_pscs.remit_branch

          -- 實付金額 /付款號碼
          SELECT cp_real_payamt,disb_no
          INTO   f_cp_real_payamt,f_disb_no
          FROM   pscd
          WHERE  policy_no	  =f_policy_no
          AND    cp_anniv_date    =f_cp_ann

          IF STATUS = NOTFOUND THEN
          	  LET f_cp_real_payamt = 0
             LET f_disb_no        = ''
          END IF

          LET p_data_s3[f_i].cp_real_payamt  =f_cp_real_payamt
          LET p_data_s3[f_i].disb_no	        =f_disb_no



       ELSE
       	  SELECT *
          INTO   f_pscy.*
          FROM   pscy
          WHERE  policy_no	    =f_policy_no
          AND    cp_anniv_date =f_cp_ann

          LET f_i=f_i+1

          -- 受領人
          LET f_benf_name=f_pscy.payee
          LET p_data_s3[f_i].benf_name	=f_benf_name[1,10]

          -- 受領人ID
          LET p_data_s3_ext[f_i].client_id =f_pscy.client_id

          -- 順序/比率
          LET p_data_s3[f_i].cp_pay_seq	=1
          LET p_data_s3[f_i].benf_ratio =100

          -- 電匯帳號
          LET p_data_s3[f_i].remit_account =f_pscy.bank_code,'-',f_pscy.bank_account_e

          -- 銀行名稱
          SELECT bank_name
          INTO   p_data_s3[f_i].bank_name
          FROM   bank
          WHERE  bank_code = f_pscy.bank_code

          -- 實付金額 /付款號碼
          SELECT cp_real_payamt,disb_no
          INTO   f_cp_real_payamt,f_disb_no
          FROM   pscx
          WHERE  policy_no	  =f_policy_no
          AND    cp_anniv_date    =f_cp_ann

          IF STATUS = NOTFOUND THEN
          	 LET f_cp_real_payamt = 0
             LET f_disb_no        = ''
          END IF

          LET p_data_s3[f_i].cp_real_payamt   =f_cp_real_payamt
          LET p_data_s3[f_i].disb_no	        =f_disb_no

       END IF
    -- 若無指定則依作帳前,後來顯示 --
    ELSE
    	 IF p_data_s1.currency = 'TWD' THEN
    	    SELECT count(*)
          INTO   f_pscd_count
          FROM   pscd
          WHERE  policy_no=f_policy_no
          AND    cp_anniv_date =f_cp_ann
       ELSE
      	  SELECT count(*)
          INTO   f_pscd_count
          FROM   pscx
          WHERE  policy_no=f_policy_no
          AND    cp_anniv_date =f_cp_ann
       END IF

       IF f_pscd_count >0 THEN
          IF p_data_s1.currency = 'TWD' THEN
             DECLARE f_s3 CURSOR FOR
                 SELECT *
                 FROM  pscd
                 WHERE policy_no=f_policy_no
                 AND   cp_anniv_date =f_cp_ann
                 ORDER BY cp_pay_seq

             FOREACH f_s3 INTO f_pscd.*

                LET f_i=f_i+1

                -- 受領人
                LET f_benf_name=f_pscd.names
                LET p_data_s3[f_i].benf_name =f_benf_name[1,10]

                -- 受領人ID
                LET p_data_s3_ext[f_i].client_id =''

                -- 順序/比率
                LET p_data_s3[f_i].cp_pay_seq=f_pscd.cp_pay_seq
                LET p_data_s3[f_i].benf_ratio=f_pscd.benf_ratio

                -- 實付金額 /付款號碼
                LET p_data_s3[f_i].cp_real_payamt=f_pscd.cp_real_payamt
                LET p_data_s3[f_i].disb_no       =f_pscd.disb_no

                -- 電匯帳號
                LET p_data_s3[f_i].remit_account =f_pscd.remit_bank
                                                 ,f_pscd.remit_branch,'-'
                                                 ,f_pscd.remit_account
                -- 銀行名稱
                SELECT bank_name
                INTO   p_data_s3[f_i].bank_name
                FROM   bank
                WHERE  bank_code[1,3] = f_pscd.remit_bank
                AND    bank_code[4,7] = f_pscd.remit_branch

             END FOREACH
          ELSE
          	 DECLARE f_s5 CURSOR FOR
                 SELECT *
                 FROM  pscx
                 WHERE policy_no=f_policy_no
                 AND   cp_anniv_date =f_cp_ann
                 ORDER BY cp_pay_seq

             FOREACH f_s5 INTO f_pscx.*

                LET f_i=f_i+1

                -- 受領人
                LET f_benf_name=f_pscx.names
                LET p_data_s3[f_i].benf_name =f_benf_name[1,10]

                -- 受領人ID
                LET p_data_s3_ext[f_i].client_id =f_pscx.client_id

                -- 順序/比率
                LET p_data_s3[f_i].cp_pay_seq=f_pscx.cp_pay_seq
                LET p_data_s3[f_i].benf_ratio=f_pscx.benf_ratio

                -- 實付金額 /付款號碼
                LET p_data_s3[f_i].cp_real_payamt=f_pscx.cp_real_payamt
                LET p_data_s3[f_i].disb_no       =f_pscx.disb_no

                -- 電匯帳號
                LET p_data_s3[f_i].remit_account =f_pscx.bank_code,'-',f_pscx.bank_account_e

                -- 銀行名稱
                SELECT bank_name
                INTO   p_data_s3[f_i].bank_name
                FROM   bank
                WHERE  bank_code = f_pscx.bank_code

             END FOREACH
          END IF
       ELSE
            DECLARE benf_cur CURSOR FOR
                 SELECT *
                 FROM  benf
                 WHERE policy_no=f_policy_no
                 AND   relation =f_relation
                 ORDER BY benf_order

            FOREACH benf_cur INTO f_benf.*

            LET f_i=f_i+1

            -- 受領人
            IF  f_benf.client_id  !=" " THEN
                SELECT names INTO f_benf_name
                FROM   clnt
                WHERE  client_id=f_benf.client_id
            ELSE
                LET f_benf_name=f_benf.names
            END IF

            IF f_benf_name is null THEN
               LET f_benf_name=""
            END IF

            LET p_data_s3[f_i].benf_name =f_benf_name[1,10]

            -- 受領人ID
            LET p_data_s3_ext[f_i].client_id =f_benf.client_id

            -- 順序/比率
            LET p_data_s3[f_i].cp_pay_seq=f_benf.benf_order
            LET p_data_s3[f_i].benf_ratio=f_benf.benf_ratio

            -- 實付金額 /付款號碼
            LET p_data_s3[f_i].cp_real_payamt=0
            LET p_data_s3[f_i].disb_no       =""

            IF p_data_s1.currency = 'TWD' THEN
               -- 電匯帳號
               LET p_data_s3[f_i].remit_account =f_benf.remit_bank
                                                ,f_benf.remit_branch,'-'
                                                ,f_benf.remit_account
               -- 銀行名稱
               SELECT bank_name
               INTO   p_data_s3[f_i].bank_name
               FROM   bank
               WHERE  bank_code[1,3] = f_benf.remit_bank
               AND    bank_code[4,7] = f_benf.remit_branch
            ELSE
             	 -- 電匯帳號
             	 LET f_bank_account_e =''

             	 SELECT bank_account_e, bank_code
             	   INTO f_bank_account_e, f_bank_code
                 FROM benp
                WHERE policy_no = f_policy_no
                  AND relation  = f_relation
                  AND client_id = f_benf.client_id

               LET p_data_s3[f_i].remit_account = f_bank_code,'-',f_bank_account_e

               -- 銀行名稱
               SELECT bank_name
               INTO   p_data_s3[f_i].bank_name
               FROM   bank
               WHERE  bank_code = f_bank_code

            END IF
          END FOREACH
       END IF
    END IF
    -- 100/03/31 END


    IF f_i=0 THEN
       LET f_i=1
       LET f_total_record=0
    ELSE
       LET f_total_record=f_i
    END IF

    OPEN WINDOW w_s3 AT 9,1 WITH FORM "psc01i03"
         ATTRIBUTE(GREEN, FORM LINE FIRST )

    -- 100/03/31 MODIFY
    -- 101/09/28 cmwang 外幣帳戶新增還款試算F10(畫面較非外幣新增週年日pv)
    IF p_data_s1.currency = 'TWD' THEN
       MESSAGE "F1:櫃檯領取F2:月給付F5:回覆查詢F6:註記查詢F9:抵繳保單F10:還款試算F12:還本未回"     ATTRIBUTE (WHITE)
    ELSE
    	 MESSAGE "END:離開,F5:回覆查詢,F6:註記查詢,F8:外幣帳戶,F10:還款試算"                  ATTRIBUTE (WHITE)
    END IF
    -- 101/09/28 END
    -- 100/03/31 END

    IF f_psbh_cnt > 0 THEN
       ERROR "此保單已參加回流專案!!" ATTRIBUTE (RED)
    END IF
    IF LENGTH(f_address CLIPPED)=0 THEN
       LET f_address="參考收費地址!!"
    END IF

    -- 註記作業 --
    LET f_psck_cnt=0
    SELECT count(*) INTO f_psck_cnt
    FROM   psck
    WHERE  policy_no	=f_policy_no
    AND    cp_anniv_date=f_cp_ann

    IF f_psck_cnt=0       OR
       f_psck_cnt is NULL THEN
       LET f_psck_sw="N"
    ELSE
       LET f_psck_sw="Y"
    END IF

    -- 身份證影本是否檢附 --
    SELECT id_copy_sw
    INTO   f_id_copy_sw
    FROM   pscr
    WHERE  policy_no	=f_policy_no
    AND    cp_anniv_date=f_cp_ann

    LET f_pay_dept_name_1=f_pay_dept_name[1,14]
    LET f_address_1      =f_address[1,64]

    -- 郵寄支票件才顯示地址 --
    IF f_cp_disb_type !="0" THEN
       LET f_address_1=""
       LET f_zip_code =""
    END IF

    -- 超借, 還款指示 --
    IF f_overloan_sw = "1" THEN
       LET f_overloan_desc = "Y"
    ELSE
       IF f_overloan_sw = "0" THEN
	  LET f_overloan_desc = "N"
       END IF
    END IF

    -------------------------------------
    -- 092/03/17 針對上線的錯誤        --
    -- 令 092/04/30 前的超借指示看不到 --
    -------------------------------------
    IF f_cp_ann <= "092/04/30" THEN
       LET f_overloan_desc = ""
    END IF

    IF f_cp_rtn_sw = "1" THEN
       LET f_cp_rtn_desc = "Y"
    ELSE
       IF f_cp_rtn_sw = "0" THEN
          LET f_cp_rtn_desc = "N"
       END IF
    END IF

    IF f_notice_resp_sw = "1" THEN
       LET f_notice_resp_desc = "Y"
    ELSE
       IF f_notice_resp_sw = "0" THEN
	  LET f_notice_resp_desc = "N"
       END IF
    END IF

    --------------
    -- 電匯日期 --
    --------------
    IF f_cp_disb_type = "3"
    OR f_cp_disb_type = "5" THEN
    	 -- 100/03/31 MODIFY
    	 IF p_data_s1.currency = 'TWD' THEN
          SELECT c.remit_date
          INTO   f_remit_date
          FROM   pscd a, dbdd c
          WHERE  a.policy_no     = f_policy_no
          AND    a.cp_anniv_date = f_cp_ann
          AND    a.cp_pay_seq    = 1
          AND    a.disb_no       = c.disb_no
          AND    a.policy_no     = c.reference_code
       ELSE
       	  SELECT c.remit_date
          INTO   f_remit_date
          FROM   pscx a, dbdd c
          WHERE  a.policy_no     = f_policy_no
          AND    a.cp_anniv_date = f_cp_ann
          AND    a.cp_pay_seq    = 1
          AND    a.disb_no       = c.disb_no
          AND    a.policy_no     = c.reference_code
       END IF
       -- 100/03/31 END

       IF LENGTH(f_remit_date CLIPPED) = 0 THEN
	        LET f_remit_date = ""
       END IF

    ELSE
       LET f_remit_date = ""
    END IF
    --101/11/20 新增保證給付指示--
    SELECT   guarantee_sw
      INTO   f_guarantee_sw
      FROM   pscb
      WHERE  policy_no    =f_policy_no
        AND  cp_anniv_date=f_cp_ann
    -- END 101/11/20
    DISPLAY f_disb_desc
           ,f_special_desc
           ,f_zip_code
           ,f_address_1
           ,f_cp_chk_date 
{ --SR140800458
           ,f_cp_pay_name
           ,f_cp_pay_id
           ,f_pay_dept_name_1
}
           ,f_psck_sw
           ,f_pay_change_name_1
	   ,f_benf_name_all
           ,f_id_copy_sw
	   ,f_overloan_desc
	   ,f_cp_rtn_desc
	   ,f_notice_resp_desc
	   ,f_remit_date
           ,f_guarantee_sw
        TO  disb_desc
           ,special_desc
           ,zip_code
           ,address
           ,cp_chk_date
{ --SR140800458 
           ,cp_pay_name
           ,cp_pay_id
           ,pay_dept_name
}
           ,psck_sw
           ,pay_change_name
           ,benf_name_all
           ,id_copy
	   ,overloan_desc
	   ,cp_rtn_desc
	   ,notice_resp_desc
	   ,remit_date
           ,guarantee_sw
    ATTRIBUTE (YELLOW)

    CALL set_count(f_i)

    DISPLAY f_cp_ann       TO cp_anniv_date ATTRIBUTE (YELLOW)
    DISPLAY f_total_record TO total_record

    DISPLAY ARRAY p_data_s3 TO psc01_s3.*
      ATTRIBUTE (YELLOW)



      ON KEY (F5)   --回覆查詢
         CALL psc01i30_edit_query (f_policy_no ,f_cp_ann)
         IF f_psbh_cnt > 0 THEN
            ERROR "此保單已參加回流專案!!" ATTRIBUTE (RED)
         END IF

      ON KEY (F6)   --註記查詢
         CALL pscninq(f_policy_no,f_cp_ann)
              RETURNING f_data_sw
         IF f_psbh_cnt > 0 THEN
            ERROR "此保單已參加回流專案!!" ATTRIBUTE (RED)
         END IF

      ON KEY (F7)
         EXIT DISPLAY

      -- 100/03/31 ADD 外幣帳戶查詢,外幣才有此功能
      ON KEY (F8)
      	 IF p_data_s1.currency <> 'TWD' THEN
      	    LET f_arr_cur = ARR_CURR()
            CALL psc01i07_edit_query (f_policy_no ,f_cp_ann, p_data_s3_ext[f_arr_cur].client_id,f_relation,f_disb_special_ind)
         END IF
      -- 100/03/31 END
         IF f_psbh_cnt > 0 THEN
            ERROR "此保單已參加回流專案!!" ATTRIBUTE (RED)
         END IF

      ON KEY (F9) -- 抵繳保費,其它張保單查詢 --
      	 -- 100/03/31 MODIFY 台幣才有此功能
      	 IF p_data_s1.currency = 'TWD' THEN
            -- 執行抵繳保費輸入他張保單程式,功能由容芳提供,程式放在 p9610.4gl --
            INITIALIZE p_pc961_data.* TO NULL
            LET p_pc961_data.policy_no    =f_policy_no
            LET p_pc961_data.cp_anniv_date=f_cp_ann
            LET p_pc961_data.prss_code    ="QURY"
            LET p_pc961_data.tran_date    =p_tx_date
            LET p_pc961_data.cp_pay_amt   =0
            LET p_pc961_sw=TRUE
            LET p_pc961_msg=""
            CALL pc961_process(p_pc961_data.*,'')
                 RETURNING p_pc961_sw,p_pc961_msg,p_pc961_data.*
            IF p_pc961_sw=FALSE THEN
               ERROR p_pc961_msg
               SLEEP 3
            END IF
         END IF
         -- 100/03/31 END
         IF f_psbh_cnt > 0 THEN
            ERROR "此保單已參加回流專案!!" ATTRIBUTE (RED)
         END IF

      ON KEY (F10)
         -- 100/03/31 MODIFY 台幣才有此功能
         -- 101/09/28 新增外幣功能
      	 IF p_data_s1.currency = 'TWD' THEN
	          CALL calc_process(f_policy_no, f_cp_ann,"TWD")
	       ELSE
	       	  CALL calc_process(f_policy_no, f_cp_ann,"Other")
         END IF
         -- 101/09/28 END
         -- 100/03/31 END
         IF f_psbh_cnt > 0 THEN
            ERROR "此保單已參加回流專案!!" ATTRIBUTE (RED)
         END IF
     ON KEY ( F1 )
         CALL psc01i_F1( f_cp_pay_name      ,
                          f_cp_pay_id       ,
                          f_pay_dept_name_1 )
     ON KEY ( F2 ) -- 105/04/01 月給付
         CALL psc01i_F2( f_policy_no ,f_cp_ann, f_cp_disb_type, f_disb_desc, f_zip_code ,f_address_1 ) 
                         
     ON KEY ( F12 )
         MESSAGE " "
         CALL psc01i_F12( f_policy_no ,f_cp_ann )
         MESSAGE "F1:櫃檯領取F2:月給付F5:回覆查詢F6:註記查詢F9:抵繳保單F10:還款試算F12:還本未回"     ATTRIBUTE (WHITE)

    END DISPLAY

    CLOSE WINDOW w_s3
    RETURN f_rcode
END FUNCTION   -- psc01i20_detail_query --


------------------------------------------------------------------------------
--  函式名稱: psc01i30_edit_query
--  作    者: merlin
--  日    期: 89/02/24
--  處理概要: 回覆查詢作業
--  重要函式:
------------------------------------------------------------------------------
FUNCTION psc01i30_edit_query(f_policy_no,f_cp_ann)

   DEFINE f_policy_no           LIKE pscb.policy_no
         ,f_cp_ann              LIKE pscb.cp_anniv_date
         ,f_cp_anniv_date       LIKE pscn.cp_anniv_date
         ,f_act_return_date     LIKE pscn.act_return_date
         ,f_cp_notice_code      LIKE pscn.cp_notice_code
         ,f_cp_notice_sub_code  LIKE pscn.cp_notice_sub_code
         ,f_cp_notice_serial    LIKE pscg.cp_notice_serial
         ,f_process_time        LIKE pscn.process_time
         ,f_process_user        LIKE pscn.process_user

   DEFINE f_user_code           LIKE edp_base:usrdat.user_code
         ,f_user_id             LIKE edp_base:usrdat.id_code
         ,f_user_name           LIKE edp_base:usrdat.user_name
         ,f_dept_code           LIKE edp_base:usrdat.dept_code

   DEFINE f_t_f			INTEGER
         ,f_dept_adm_code	LIKE dept.dept_code
         ,f_dept_adm_name	LIKE dept.dept_name

   DEFINE f_i                   SMALLINT
   DEFINE f_total_record        SMALLINT
   DEFINE f_arr                 INTEGER
         ,f_dtl_cp_notice_serial LIKE pscn.cp_notice_serial

    FOR f_i=1 TO 99
        LET p_data_s4[f_i].act_return_date      =""
        LET p_data_s4[f_i].notice_code          =""
        LET p_data_s4[f_i].notice_sub_code      =""
        LET p_data_s4[f_i].cp_notice_serial     =""
        LET p_data_s4[f_i].dept_name		=""
        LET p_data_s4[f_i].process_user_name    =""
    END FOR

   LET f_total_record=0
   SELECT count(*)
   INTO   f_total_record
   FROM   pscn
   WHERE  policy_no=f_policy_no
   AND    cp_anniv_date=f_cp_ann

   IF  f_total_record=0 THEN
       ERROR   '無符合條件資料!!' ATTRIBUTE(RED,UNDERLINE)
   ELSE
       LET f_i=0
       DECLARE f_s4 CURSOR FOR
               SELECT cp_anniv_date
                     ,act_return_date
                     ,cp_notice_code
                     ,cp_notice_sub_code
                     ,process_time
                     ,process_user
                     ,cp_notice_serial
                FROM  pscn
                WHERE policy_no     = f_policy_no
                AND   cp_anniv_date = f_cp_ann
                ORDER BY act_return_date DESC,process_time DESC

           FOREACH f_s4 INTO f_cp_anniv_date
                           , f_act_return_date
                           , f_cp_notice_code
                           , f_cp_notice_sub_code
                           , f_process_time
                           , f_process_user
                           , f_cp_notice_serial

               CALL GetUserData(f_process_user)
                    RETURNING f_user_code
			     ,f_user_id
			     ,f_user_name
			     ,f_dept_code

               LET f_i=f_i+1
               LET p_data_s4[f_i].act_return_date       =f_act_return_date
               LET p_data_s4[f_i].cp_notice_serial      =f_cp_notice_serial
               LET p_data_s4[f_i].process_user_name     =f_user_name

               -- 承辦公司 --
               CALL getDBranchoffice(f_dept_code)
                    RETURNING f_t_f
			     ,f_dept_adm_code
			     ,f_dept_adm_name

               IF f_t_f=FALSE THEN
                  LET f_dept_adm_code=""
		  LET f_dept_adm_name=""
               END IF
               IF f_dept_adm_code="99000" THEN
                  LET f_dept_adm_code="97000"
		  LET f_dept_adm_name="高雄分公司"
               END IF
               LET p_data_s4[f_i].dept_name=f_dept_adm_name

                -- 回覆情形 --
                CASE
                    WHEN f_cp_notice_code="0"
                         IF  f_process_user  = 'ECO_POS' THEN
                             LET p_data_s4[f_i].notice_code="網路回覆"
                         ELSE
                             LET p_data_s4[f_i].notice_code="文件齊全"
                         END IF
                    WHEN f_cp_notice_code="1"
                         LET p_data_s4[f_i].notice_code="文件不齊"
                    WHEN f_cp_notice_code="2"
                         LET p_data_s4[f_i].notice_code="直接給付"
                    WHEN f_cp_notice_code="3"
                         LET p_data_s4[f_i].notice_code="照會回覆"
                    OTHERWISE
                         LET p_data_s4[f_i].notice_code=" 其  他 "
                END CASE

                -- 回覆處理情形 --
                CASE
                    WHEN f_cp_notice_sub_code="0"
                         LET p_data_s4[f_i].notice_sub_code="融通進給付"
                    WHEN f_cp_notice_sub_code="1"
                         LET p_data_s4[f_i].notice_sub_code="照會業務員"
		    WHEN f_cp_notice_sub_code="2"
			 LET p_data_s4[f_i].notice_sub_code="照會保戶"
               END CASE

            END FOREACH

      -- 顯示回覆資料 --
      OPEN WINDOW w_s4 AT 9,1 WITH FORM "psc01i04"
           ATTRIBUTE(GREEN, FORM LINE FIRST )

          MESSAGE "ESC(F7):離開  F5:文件缺碼詳細資料" ATTRIBUTE (WHITE)

          DISPLAY f_cp_ann TO cp_anniv_date
          DISPLAY f_i  TO total_record

          CALL set_count(f_i)
          DISPLAY ARRAY p_data_s4 TO psc01_s4.*
          ATTRIBUTE (YELLOW)
          ON KEY (F7)
          EXIT DISPLAY

          ON KEY (F5)
          LET f_arr=ARR_CURR()
          LET f_dtl_cp_notice_serial    =p_data_s4[f_arr].cp_notice_serial
          IF f_dtl_cp_notice_serial =0  THEN
              ERROR "無文件缺碼!!"      ATTRIBUTE (RED,UNDERLINE)
          ELSE
             CALL psc01i30_dif_query(p_data_s1.policy_no,
                                     f_cp_ann,
                                     f_dtl_cp_notice_serial)
          END IF
          END DISPLAY
      CLOSE WINDOW w_s4
    END IF
END FUNCTION   -- psc01i30_edit_query --
------------------------------------------------------------------------------
--  函式名稱: psc01i30_dif_query
--  作    者: merlin
--  日    期: 89/02/24
--  處理概要: 回覆查詢作業:文件缺碼詳細資料
--  重要函式:
------------------------------------------------------------------------------
FUNCTION psc01i30_dif_query(f_policy_no,
                            f_cp_anniv_date,
                            f_cp_notice_serial)

    DEFINE f_policy_no          LIKE pscg.policy_no
          ,f_cp_anniv_date      LIKE pscg.cp_anniv_date
          ,f_cp_notice_serial   LIKE pscg.cp_notice_serial
          ,f_answer             CHAR

    DEFINE f_pscg       RECORD  LIKE pscg.*

    INITIALIZE f_pscg.* TO NULL

     SELECT *
     INTO   f_pscg.*
     FROM   pscg
     WHERE  policy_no=f_policy_no
     AND    cp_anniv_date=f_cp_anniv_date
     AND    cp_notice_serial=f_cp_notice_serial

     IF STATUS=NOTFOUND THEN
          ERROR "無文件缺碼詳細資料!!"   ATTRIBUTE (RED,UNDERLINE)
     ELSE
      OPEN WINDOW w_s5 AT 2,15 WITH FORM "psc01i05"
       ATTRIBUTE(BLUE,REVERSE,UNDERLINE)
        DISPLAY BY NAME f_pscg.* ATTRIBUTE(CYAN)
PROMPT '按任一鍵結束查詢'  ATTRIBUTE(RED,UNDERLINE) FOR CHAR f_answer
      CLOSE WINDOW w_s5
     END IF

END FUNCTION --psc01i30_dif_query--

------------------------------------------------------------------------------
--  函式名稱: calc_process
--  作    者: Kobe
--  日    期: 092/12/15
--  處理概要: 還款試算畫面
--  重要函式:
------------------------------------------------------------------------------
--  修    改:101/09/28 cmwang 新增Currency_ind "TWD","Other"
----------------------------------------------------------------------
FUNCTION calc_process(f_policy_no, f_cp_ann,f_currency_ind)

   DEFINE f_policy_no			LIKE polf.policy_no	-- 保單號碼 --
   DEFINE f_cp_ann			CHAR(9)			-- 還本週年日 --
-- 101/09/27 cmwang 新增變數
   DEFINE f_currency_ind  CHAR(5)
   DEFINE f_sys           CHAR(8) --計算方式
-- 101/09/27 END
   -- 輸入變數 --
   DEFINE f_rtn_date			CHAR(9)			-- 還款日期 --

   -- 顯示變數 --
   DEFINE f_plan_code			LIKE colf.plan_code	-- 主約險種 --
   DEFINE f_face_amt			LIKE colf.face_amt	-- 主約保額 --
   --101/09/27 cmwang 新增f_co_pv
   DEFINE f_co_pv         LIKE vlcoi.co_pv
   DEFINE f_i            INT
   -- 101/09/27 END
   DEFINE f_minus_amt			FLOAT			-- 欠繳金額 --
   DEFINE f_tot_apl			FLOAT			-- APL 本息 --
   DEFINE f_tot_loan			FLOAT			-- LOAN本息 --
   DEFINE f_tot_amt			FLOAT			-- 合    計 --

   DEFINE f_polf			RECORD LIKE polf.*

   DEFINE f_loan_amt			FLOAT
   DEFINE f_apl_amt			FLOAT
   DEFINE f_int                         FLOAT                 -- 利息
   DEFINE f_int_balance			FLOAT
   DEFINE f_rc                          FLOAT

   DEFINE f_chkdate_sw			INTEGER
   DEFINE f_format_date			CHAR(9)
   DEFINE f_last_loan_date		CHAR(9)
   DEFINE f_char			CHAR(1)

-- 101/09/27 cmwang 依照f_currency_ind開不同視窗
   CASE UPSHIFT(f_currency_ind)
   	WHEN "TWD"
      OPEN WINDOW w_psc01i06 AT 9,20 WITH FORM "psc01i06"
           ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                     , PROMPT LINE LAST )
    WHEN "OTHER"
    	OPEN WINDOW w_psc01i08 AT 9,20 WITH FORM "psc01i08"
           ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                     , PROMPT LINE LAST )
    OTHERWISE
      DISPLAY "input error!"
    END CASE
-- 101/09/27 END

   LET f_rtn_date	= ""

   LET f_plan_code	= ""
   LET f_face_amt	= ""
   LET f_minus_amt	= 0
   LET f_tot_apl	= 0
   LET f_tot_loan	= 0
   LET f_tot_amt	= 0

   LET f_loan_amt	= 0
   LET f_apl_amt	= 0
   LET f_int		= 0
   LET f_int_balance	= 0
 -- 101/09/27 cmwang 新增變數賦值
   LET f_sys = "借款"
 -- 101/09/27 END
   LET INT_FLAG		= FALSE

   SELECT plan_code, (face_amt/10000)
   INTO   f_plan_code, f_face_amt
   FROM   colf
   WHERE  policy_no   = f_policy_no
   AND    coverage_no = 1

   DISPLAY f_policy_no, f_plan_code, f_face_amt TO policy_no, plan_code, face_amt
	   ATTRIBUTE(BLUE, REVERSE, UNDERLINE)

   INPUT f_rtn_date WITHOUT DEFAULTS FROM rtn_date

	 AFTER FIELD rtn_date
	       IF LENGTH(f_rtn_date CLIPPED) = 0 THEN
		  ERROR "請輸入日期!!" ATTRIBUTE(RED, UNDERLINE)
		  NEXT FIELD rtn_date
	       END IF

	       CALL CheckDate(f_rtn_date) RETURNING f_chkdate_sw, f_format_date
	       IF f_chkdate_sw = FALSE THEN
		  ERROR "輸入日期錯誤!!" ATTRIBUTE(RED, UNDERLINE)
		  NEXT FIELD rtn_date
	       END IF

	       IF f_rtn_date < f_cp_ann THEN
		  ERROR "日期不得小於週年日!!" ATTRIBUTE(RED, UNDERLINE)
		  NEXT FIELD rtn_date
	       END IF

	       SELECT max(last_loan_date)
	       INTO   f_last_loan_date
	       FROM   lnlg
	       WHERE  policy_no = f_policy_no

	       IF f_rtn_date < f_last_loan_date THEN
		  ERROR "還款日期不可小於前次交易日!!" ATTRIBUTE(RED, UNDERLINE)
		  NEXT FIELD rtn_date
	       END IF

	       SELECT *
	       INTO   f_polf.*
	       FROM   polf
	       WHERE  policy_no = f_policy_no

	       IF f_rtn_date <= f_polf.loan_date THEN
		  ERROR "輸入日期必須大於借款日!!" ATTRIBUTE(RED, UNDERLINE)
		  NEXT FIELD rtn_date
	       END IF
	       --------------
	       -- 欠繳金額 --
	       --------------
	       IF f_polf.prem_susp < 0 THEN
		  LET f_minus_amt = f_polf.prem_susp * -1
	       ELSE
		  LET f_minus_amt = 0
	       END IF

	       -----------------------
	       -- LOAN本息, APL本息 --
	       -----------------------
	       IF f_polf.loan_amt <= 0 THEN
		  LET f_int = 0
		  LET f_int_balance = 0
	       ELSE
		  CALL psdint_new("1", f_policy_no, f_rtn_date, "L")
		       RETURNING f_loan_amt, f_int_balance, f_int, f_rc
		  IF f_rc != 0 THEN
		     ERROR "計算過程錯誤, 請洽資訊部!!" ATTRIBUTE(RED, UNDERLINE)
		     EXIT INPUT
		  END IF
	       END IF
	       LET f_tot_loan = f_loan_amt + f_int_balance + f_int

	       IF f_polf.apl_amt <= 0 THEN
                  LET f_int = 0
		  LET f_int_balance = 0
               ELSE
                  CALL psdint_new("1", f_policy_no, f_rtn_date, "A")
                       RETURNING f_apl_amt, f_int_balance, f_int, f_rc
                  IF f_rc != 0 THEN
                     ERROR "計算過程錯誤, 請洽資訊部!!" ATTRIBUTE(RED, UNDERLINE)
                   EXIT INPUT
                  END IF
	       END IF
	       LET f_tot_apl = f_apl_amt + f_int_balance + f_int

	       LET f_tot_amt = f_tot_loan + f_tot_apl + f_minus_amt

	       DISPLAY f_minus_amt, f_tot_apl, f_tot_loan, f_tot_amt
	       TO      minus_amt  , apl_amt  , loan_amt  , tot_amt
		       ATTRIBUTE(BLUE, REVERSE, UNDERLINE)
		-- 101/09/27 cmwang 新增外幣保單display週年日pv
		     CALL selpo() RETURNING g_polf.coverage_cnt
		     LET g_vlpoi.process_date = f_rtn_date
		     CALL Po_Pv( f_sys )
		     CALL Po_Cv( f_sys )
		     LET f_co_pv = g_vlpoi.pv
		    { FOR f_i = 1 TO g_polf.coverage_cnt
		     	 IF g_colf[f_i].coverage_no = 1 THEN
		     	 	 LET f_co_pv = g_vlcoi[f_i].co_pv
		     	 	 EXIT FOR
		     	 END IF
		     END FOR }
        -- IF UPSHIFT(f_currency_ind)="OTHER" THEN
               DISPLAY f_co_pv TO pv ATTRIBUTE(BLUE, REVERSE, UNDERLINE)
        -- END IF
     -- 101/09/27 END
	 AFTER INPUT
	       IF INT_FLAG THEN
		  EXIT INPUT
	       END IF
   END INPUT

   IF INT_FLAG THEN
      ERROR "試算作業放棄 !!" ATTRIBUTE(RED, UNDERLINE)
      LET INT_FLAG = FALSE
      CASE UPSHIFT(f_currency_ind)
        WHEN "TWD"
          CLOSE WINDOW w_psc01i06
        WHEN "OTHER"
          CLOSE WINDOW w_psc01i08
        OTHERWISE
          DISPLAY "input error!"
      END CASE
      RETURN
   END IF

   PROMPT " 按任何鍵跳出此視窗!!" ATTRIBUTE (RED, UNDERLINE)
   FOR CHAR f_char

   IF UPSHIFT(f_currency_ind) = "TWD" THEN
     CLOSE WINDOW w_psc01i06
   ELSE
   	 CLOSE WINDOW w_psc01i08
   END IF
   RETURN

END FUNCTION

--100/03/31 ADD
------------------------------------------------------------------------------
--  函式名稱: psc01i07_edit_query
------------------------------------------------------------------------------
FUNCTION psc01i07_edit_query(f_policy_no ,f_cp_ann,f_client_id,f_relation,f_disb_special_ind)
    DEFINE f_policy_no          LIKE pscb.policy_no
    DEFINE f_cp_ann             LIKE pscb.cp_anniv_date
    DEFINE f_client_id          LIKE benf.client_id
    DEFINE f_relation           LIKE benf.relation
    DEFINE f_disb_special_ind   LIKE pscb.disb_special_ind
    DEFINE f_names              LIKE clnt.names
    DEFINE f_pscy RECORD
                   payee            LIKE pscy.payee
                  ,client_id        LIKE pscy.client_id
                  ,swift_code       LIKE pscy.swift_code
                  ,bank_name        CHAR(30)
                  ,bank_code        LIKE pscy.bank_code
                  ,bank_name_e      LIKE pscy.bank_name_e
                  ,bank_account_e   LIKE pscy.bank_account_e
                  ,payee_e          LIKE pscy.payee_e
                  ,bank_address_e   LIKE pscy.bank_address_e
                  END RECORD

    INITIALIZE f_pscy.* TO NULL


    IF f_disb_special_ind ='1' THEN     -- 指定電匯
        SELECT payee,
               client_id,
               swift_code,
               '',
               bank_code,
               bank_name_e,
               bank_account_e,
               payee_e,
               bank_address_e
        INTO   f_pscy.*
        FROM   pscy
        WHERE  policy_no     = f_policy_no
        AND    cp_anniv_date = f_cp_ann
    ELSE                                 -- 一般電匯
        SELECT names,
               client_id,
               swift_code,
               '',
               bank_code,
               bank_name_e,
               bank_account_e,
               payee_e,
               bank_address_e
        INTO   f_pscy.*
        FROM   benp
        WHERE  policy_no     = f_policy_no
        AND    client_id     = f_client_id
        AND    relation      = f_relation
    END IF

    IF STATUS = NOTFOUND THEN
       ERROR "無外幣帳戶資料!"
    ELSE

      -- 若無中文姓名,則用ID串中文姓名
      IF (LENGTH(f_pscy.payee CLIPPED) =0 ) THEN

         LET f_names = NULL
         IF (LENGTH(f_pscy.client_id) >0)  THEN
            SELECT names INTO f_names
            FROM   clnt
            WHERE  client_id = f_pscy.client_id
         END IF
         IF (f_names != " ") OR (f_names IS NOT NULL) THEN
            LET f_pscy.payee = f_names
         END IF
      END IF

      -- 銀行的中文名稱
      SELECT bank_name[1,30]
        INTO f_pscy.bank_name
        FROM bank
       WHERE bank_code = f_pscy.bank_code

      OPEN WINDOW psc01i07 AT 9,01 WITH FORM "psc01i07"
      ATTRIBUTE (GREEN,FORM LINE FIRST,PROMPT LINE LAST,MESSAGE LINE LAST)

      LET INT_FLAG=FALSE

      WHILE (TRUE)
        DISPLAY BY NAME f_pscy.*
        IF INT_FLAG=TRUE THEN
          EXIT WHILE
        END IF
      END WHILE

      CLOSE WINDOW  psc01i07
    END IF

END FUNCTION

--100/03/31 END

FUNCTION psc01i_F1( f_cp_pay_name     ,
                     f_cp_pay_id       ,
                     f_pay_dept_name   )
   DEFINE f_cp_pay_name       LIKE pscb.cp_pay_name
   DEFINE f_cp_pay_id         LIKE pscb.cp_pay_id
   DEFINE f_pay_dept_name     LIKE dept.dept_name
   OPEN WINDOW w_psc01i09 AT 9,20 WITH FORM "psc01i09" ATTRIBUTE( BLUE, REVERSE, UNDERLINE )
   DISPLAY f_cp_pay_name TO cp_pay_name
   DISPLAY f_cp_pay_id TO cp_pay_id
   DISPLAY f_pay_dept_name TO pay_dept_name
   MESSAGE "請按任意鍵結束..." ATTRIBUTE(WHITE,UNDERLINE)
   CALL touch()
   CLOSE WINDOW w_psc01i09
END FUNCTION --psc01i_F1_1 END 

FUNCTION psc01i_F12( f_policy_no ,f_cp_anniv_date )
   DEFINE f_policy_no           LIKE pscah.policy_no
   DEFINE f_cp_anniv_date       LIKE pscah.cp_anniv_date 
   DEFINE f_rec          RECORD 
          policy_no             LIKE pscah.policy_no        ,
          po_chg_rece_no        LIKE pscah.po_chg_rece_no   ,
          names                 LIKE clnt.names             ,
          currency              LIKE polf.currency          ,
          po_issue_date         LIKE polf.po_issue_date     ,
          paid_to_date          LIKE polf.paid_to_date      ,
          po_sts_code           LIKE polf.po_sts_code       ,
          agent_name            LIKE pscah.agent_name       ,
          cp_anniv_date         LIKE pscah.cp_anniv_date    ,
          ca_disb_type          LIKE pscah.ca_disb_type     ,
          mail_addr             LIKE pscah.mail_addr        ,
          crt_user              CHAR(8) 
   END RECORD 
   DEFINE f_pscah               RECORD LIKE pscah.*
   DEFINE f_pscad               RECORD LIKE pscad.*
   DEFINE f_pscd                RECORD LIKE pscd.*
   DEFINE f_polf                RECORD LIKE polf.*
          
   DEFINE f_arr           ARRAY[200] OF RECORD 
          check_no              LIKE glkk.check_no          ,
          ori_id                LIKE clnt.client_id         ,
          ori_name              LIKE clnt.names             ,
          new_id                LIKE clnt.client_id         ,
          new_name              LIKE clnt.names             ,
          remit_bank            LIKE pscad.remit_bank       ,
          remit_branch          LIKE pscad.remit_branch     ,
          remit_account         LIKE pscad.remit_account    ,
          payee_code            LIKE pscad.payee_code       ,
          bank_name             LIKE bank.bank_name
   END RECORD 
   DEFINE f_arr_cnt             INTEGER
   DEFINE f_ix                  INTEGER
   DEFINE f_relation            CHAR(1)
   DEFINE f_pscae_po            ARRAY[10] OF LIKE pscae.policy_no
   DEFINE f_pscae_po_cnt        INTEGER
  
   OPEN WINDOW s_psc01i10 AT 1,1 WITH FORM "psc01i10" ATTRIBUTE( GREEN )

   INITIALIZE f_rec    TO NULL
   INITIALIZE f_pscah  TO NULL 
   INITIALIZE f_pscad  TO NULL
   INITIALIZE f_polf   TO NULL
   FOR f_ix = 1 TO 200
       INITIALIZE f_arr[f_ix] TO NULL
   END FOR
   
   SELECT      *
   INTO        f_pscah.*
   FROM        pscah a 
   WHERE       a.policy_no     = f_policy_no 
   AND         a.cp_anniv_date = f_cp_anniv_date 
   LET f_rec.policy_no        = f_pscah.policy_no 
   LET f_rec.po_chg_rece_no   = f_pscah.po_chg_rece_no
   SELECT      c.names 
   INTO        f_rec.names 
   FROM        pocl a , clnt c
   WHERE       a.policy_no      = f_pscah.policy_no 
   AND         a.client_ident   = "O1"
   AND         a.client_id      = c.client_id
   SELECT      currency         ,
               po_issue_date    ,
               paid_to_date     ,
               po_sts_code      ,
               *
   INTO        f_rec.currency        ,
               f_rec.po_issue_date   ,
               f_rec.paid_to_date    ,
               f_rec.po_sts_code     ,
               f_polf.*
   FROM        polf
   WHERE       policy_no = f_pscah.policy_no 
   LET f_rec.agent_name         = f_pscah.agent_name 
   LET f_rec.cp_anniv_date      = f_pscah.cp_anniv_date 
   LET f_rec.ca_disb_type       = f_pscah.ca_disb_type 
   LET f_rec.mail_addr          = f_pscah.mail_addr 
   SELECT  user_name 
   INTO    f_rec.crt_user
   FROM    edp_base:usrdat
   WHERE   user_code = f_pscah.crt_user
   LET f_arr_cnt = 0
   DECLARE cad_cur CURSOR WITH HOLD FOR 
      SELECT   * 
      FROM     pscad a ,pscd d
      WHERE    a.policy_no       = f_pscah.policy_no 
      AND      a.cp_anniv_date   = f_pscah.cp_anniv_date 
      AND      a.policy_no       = d.policy_no 
      AND      a.cp_anniv_date   = d.cp_anniv_date
      AND      a.disb_no         = d.disb_no
   FOREACH cad_cur INTO f_pscad.* ,f_pscd.*
      LET f_arr_cnt = f_arr_cnt + 1 
      LET f_arr[f_arr_cnt].check_no      = f_pscad.check_no 
      LET f_arr[f_arr_cnt].ori_id        = f_pscd.client_id 
      LET f_arr[f_arr_cnt].ori_name      = f_pscd.names
      LET f_arr[f_arr_cnt].new_id        = f_pscad.payee_id
      LET f_arr[f_arr_cnt].new_name      = f_pscad.payee
      LET f_arr[f_arr_cnt].remit_bank    = f_pscad.remit_bank
      LET f_arr[f_arr_cnt].remit_branch  = f_pscad.remit_branch
      LET f_arr[f_arr_cnt].remit_account = f_pscad.remit_account
      LET f_arr[f_arr_cnt].payee_code    = f_pscad.payee_code
      LET f_arr[f_arr_cnt].bank_name     = " "
      SELECT    bank_name
      INTO      f_arr[f_arr_cnt].bank_name
      FROM      bank
      WHERE     bank_code[1,3] = f_pscad.remit_bank
      AND       bank_code[4,7] = f_pscad.remit_branch
   END FOREACH 
   DISPLAY BY NAME f_rec.* ATTRIBUTE( YELLOW ,UNDERLINE )      
   CALL SET_COUNT( f_arr_cnt )
   DISPLAY ARRAY f_arr TO psc01i10_s1.* ATTRIBUTE( YELLOW ,UNDERLINE )
      ON KEY( F5 )
         OPEN WINDOW w_po_s1 AT 5,1 WITH FORM "psc01i11"
              ATTRIBUTE(GREEN, FORM LINE FIRST)
         LET f_pscae_po_cnt = 1
         DECLARE pscae_po_cur CURSOR WITH HOLD FOR 
            SELECT  policy_no 
            FROM    pscae
            WHERE   join_policy_no = f_pscah.policy_no
            AND     cp_anniv_date  = f_pscah.cp_anniv_date
         FOREACH pscae_po_cur INTO f_pscae_po[f_pscae_po_cnt]
            LET f_pscae_po_cnt = f_pscae_po_cnt + 1
         END FOREACH 
         LET f_pscae_po_cnt = f_pscae_po_cnt - 1
         CALL SET_COUNT( f_pscae_po_cnt )
         DISPLAY ARRAY f_pscae_po TO psc01i11_s1.*
         CLOSE WINDOW w_po_s1
   END DISPLAY 
   CLOSE WINDOW s_psc01i10
END FUNCTION -- psc01i_F12 END 

FUNCTION psc01i_cp_amt_query( f_policy_no ,f_cp_anniv_date ,f_cp_amt)

    DEFINE f_policy_no        LIKE polf.policy_no 
    DEFINE f_cp_anniv_date    LIKE pscb.cp_anniv_date 
    DEFINE f_pscamt           RECORD LIKE pscamt.*
    DEFINE f_cp_amt           FLOAT 

    OPTIONS MESSAGE LINE LAST

    INITIALIZE f_pscamt TO NULL 
    SELECT  * 
    INTO    f_pscamt.*
    FROM    pscamt
    WHERE   policy_no = f_policy_no 
    AND     cp_anniv_date = f_cp_anniv_date 

    OPEN WINDOW w_s12 AT 11,1 WITH FORM "psc01i12" ATTRIBUTE(GREEN, FORM LINE FIRST )

    DISPLAY f_pscamt.face_amt TO s_psc01i12.face_amt ATTRIBUTE(YELLOW)
    DISPLAY f_pscamt.accumulated_pua TO s_psc01i12.accumulated_pua ATTRIBUTE(YELLOW)
    DISPLAY f_pscamt.cp_amt_fa TO s_psc01i12.cp_amt_fa ATTRIBUTE (YELLOW)
    DISPLAY f_pscamt.cp_amt_pua TO s_psc01i12.cp_amt_pua ATTRIBUTE (YELLOW)
    DISPLAY f_cp_amt TO s_psc01i12.cp_amt ATTRIBUTE (YELLOW)

    CALL err_touch(" 結束流覽")
    
    CLOSE WINDOW  w_s12
    OPTIONS MESSAGE LINE LAST - 1
END FUNCTION --psc01i_cp_amt_query END 

FUNCTION psc01i_F2( f_policy_no ,f_cp_anniv_date, f_cp_disb_type, f_disb_desc, f_zip_code, f_address_1 )   
    DEFINE f_policy_no           LIKE pscu.policy_no
          ,f_cp_anniv_date       LIKE pscu.cp_anniv_date 
          ,f_cp_disb_type        LIKE pscb.cp_disb_type
          ,f_disb_desc           CHAR(8)
          ,f_zip_code            LIKE  addr.zip_code
          ,f_address_1           LIKE  addr.address
          
    DEFINE f_info          RECORD 
           currency              LIKE polf.currency
          ,owner_name            LIKE clnt.names              
          ,insure_name           LIKE clnt.names              
          ,po_sts_code           LIKE polf.po_sts_code
          ,po_issue_date         LIKE polf.po_issue_date
          ,policy_no             LIKE pscu.policy_no
          ,cp_anniv_date         LIKE pscu.cp_anniv_date 
          END RECORD   

    DEFINE f_arr          ARRAY[200] OF RECORD 
           payout_date_from      LIKE pscu.payout_date_from          
          ,cp_pay_amt            LIKE pscu.cp_pay_amt
          ,process_date          LIKE pscu.process_date
          ,disb_desc             CHAR(8)
          ,pay_type_desc         CHAR(8)
          ,remit_date            CHAR(9)
          END RECORD 
 
    DEFINE f_pscu                RECORD LIKE pscu.*
    DEFINE f_polf                RECORD LIKE polf.*
   	DEFINE i                     INTEGER            
          ,f_cnt                 INTEGER
    
    LET f_cnt = 0
    INITIALIZE f_info   TO NULL      
    INITIALIZE f_pscu   TO NULL
    INITIALIZE f_polf   TO NULL
    FOR i = 1 TO 200
        INITIALIZE f_arr[i] TO NULL
    END FOR

    -- 條件檢核 -- 105/07/20 MODIFY
    IF psc99s01_pay_modx_by_anniv (f_policy_no,f_cp_anniv_date) != '1' THEN
    	  ERROR '非月給付險種!!' ATTRIBUTE(RED,UNDERLINE)
        RETURN 
    END IF
    
    SELECT COUNT(*)
    INTO   f_cnt
    FROM   pscu
    WHERE  policy_no      = f_policy_no    
    AND    cp_anniv_date  = f_cp_anniv_date
    IF f_cnt = 0 THEN
       ERROR '尚未進入給付中!!' ATTRIBUTE(RED,UNDERLINE)
       RETURN 
    END IF
    
    -- 保單資訊
    LET f_info.policy_no       = f_policy_no    
    LET f_info.cp_anniv_date   = f_cp_anniv_date
    SELECT      *
    INTO        f_polf.*  
    FROM        polf
    WHERE       policy_no = f_policy_no
    IF STATUS = NOTFOUND THEN 
    ELSE
       LET f_info.currency        = f_polf.currency      
       LET f_info.po_sts_code     = f_polf.po_sts_code   
       LET f_info.po_issue_date   = f_polf.po_issue_date 
    END IF
     
    -- 要被保人
    SELECT      c.names 
    INTO        f_info.owner_name
    FROM        pocl a , clnt c
    WHERE       a.policy_no      = f_policy_no 
    AND         a.client_ident   = "O1"
    AND         a.client_id      = c.client_id
    	
    SELECT      c.names 
    INTO        f_info.insure_name
    FROM        pocl a , clnt c
    WHERE       a.policy_no      = f_policy_no 
    AND         a.client_ident   = "I1"
    AND         a.client_id      = c.client_id
    
    -- 週月日明細
    LET f_cnt = 0
    DECLARE pscu_cur_1 CURSOR WITH HOLD FOR 
       SELECT *
       FROM   pscu
       WHERE  policy_no      = f_policy_no    
       AND    cp_anniv_date  = f_cp_anniv_date
       AND    cp_pay_seq     = 1                   -- 用第一位受益人的資料就好
       ORDER BY payout_date_from DESC 
    FOREACH pscu_cur_1 INTO f_pscu.*
       LET f_cnt = f_cnt + 1 
       LET f_arr[f_cnt].payout_date_from  = f_pscu.payout_date_from 
       LET f_arr[f_cnt].cp_pay_amt        = f_pscu.cp_pay_amt 
       
       
       CASE f_pscu.process_sw 
       	   WHEN '0'  
       	       LET f_arr[f_cnt].disb_desc      = "未給付"
       	   WHEN '1'  
       	       LET f_arr[f_cnt].disb_desc      = "已給付"
       	   OTHERWISE
       	       LET f_arr[f_cnt].disb_desc      = " "
       END CASE
       
       LET f_arr[f_cnt].pay_type_desc  = "    -     "
       LET f_arr[f_cnt].process_date   = "    -     "
       LET f_arr[f_cnt].remit_date     = "    -     "
       
       -- 已給付時才會有以下資訊
       IF f_pscu.process_sw = '1' THEN
       	   LET f_arr[f_cnt].pay_type_desc  = f_disb_desc
       	   LET f_arr[f_cnt].process_date   = f_pscu.process_date
           -- 電匯日期 --
           IF f_cp_disb_type = '3' OR f_cp_disb_type = '5' THEN
               SELECT c.remit_date
               INTO   f_arr[f_cnt].remit_date
               FROM   pscu a, dbdd c
               WHERE  a.policy_no         = f_policy_no
               AND    a.cp_anniv_date     = f_cp_anniv_date
               AND    a.payout_date_from  = f_pscu.payout_date_from 
               AND    a.cp_pay_seq        = 1
               AND    a.disb_no           = c.disb_no
               AND    a.policy_no         = c.reference_code
       	   END IF
       END IF
    END FOREACH      
    
    OPEN WINDOW s_psc01i13 AT 1,1 WITH FORM "psc01i13" ATTRIBUTE( GREEN )
    MESSAGE "END:離開,F1:給付明細"  ATTRIBUTE (WHITE)
    DISPLAY BY NAME f_info.* ATTRIBUTE( YELLOW ,UNDERLINE )
    DISPLAY f_cnt TO total_record ATTRIBUTE( YELLOW ,UNDERLINE )
    CALL SET_COUNT( f_cnt )
    DISPLAY ARRAY f_arr TO psc01_s13.* ATTRIBUTE( YELLOW ,UNDERLINE )

    ON KEY( F1 ) -- 給付明細
    	   LET i = ARR_CURR()
         CALL psc01i_F2_detail( f_policy_no ,f_cp_anniv_date,f_arr[i].payout_date_from, f_zip_code, f_address_1 )
    END DISPLAY 
    CLOSE WINDOW s_psc01i13	      
END FUNCTION



FUNCTION psc01i_F2_detail( f_policy_no ,f_cp_anniv_date,f_payout_date_from, f_zip_code, f_address_1 )   
    DEFINE f_policy_no           LIKE pscu.policy_no
          ,f_cp_anniv_date       LIKE pscu.cp_anniv_date 
          ,f_payout_date_from    LIKE pscu.payout_date_from
          ,f_zip_code            LIKE addr.zip_code
          ,f_address_1           LIKE addr.address

    DEFINE f_detail ARRAY[99] OF RECORD 
           cp_pay_seq          LIKE pscd.cp_pay_seq                                       
          ,benf_name           LIKE clnt.names                                            
          ,benf_ratio          LIKE pscd.benf_ratio                                       
          ,cp_real_payamt      LIKE pscd.cp_real_payamt                                   
          ,disb_no             LIKE pscd.disb_no                                          
          ,remit_account       CHAR(24)                                                   
          ,bank_name           CHAR(40)                                                   
    END RECORD
    
    DEFINE f_pscu                RECORD LIKE pscu.*
   	DEFINE i                     INTEGER            
          ,f_bank_code           LIKE pscu.bank_code
          ,f_remit_account       CHAR(70)
          
    INITIALIZE f_pscu TO NULL
    FOR i = 1 TO 99
        LET f_detail[i].cp_pay_seq     = 0
        LET f_detail[i].benf_name      = " "
        LET f_detail[i].benf_ratio     = 0
        LET f_detail[i].cp_real_payamt = 0
        LET f_detail[i].disb_no        = " "
        LET f_detail[i].remit_account  = " "
        LET f_detail[i].bank_name      = " "
    END FOR
    LET i = 0
    DECLARE pscu_cur_2 CURSOR WITH HOLD FOR 
        SELECT *
        FROM   pscu
        WHERE  policy_no        = f_policy_no    
        AND    cp_anniv_date    = f_cp_anniv_date
        AND    payout_date_from = f_payout_date_from                     
        ORDER BY cp_pay_seq
    FOREACH pscu_cur_2 INTO f_pscu.*
        LET i = i + 1
        LET f_bank_code = ' '
        LET f_remit_account = ' '
        LET f_detail[i].benf_name	     = f_pscu.names[1,10]
        LET f_detail[i].cp_pay_seq     = f_pscu.cp_pay_seq
        LET f_detail[i].benf_ratio     = f_pscu.benf_ratio
        LET f_detail[i].cp_real_payamt = f_pscu.cp_real_payamt
        LET f_detail[i].disb_no        = f_pscu.disb_no
        
        IF f_pscu.currency = 'TWD' THEN
        	  LET f_bank_code[1,3] = f_pscu.remit_bank
        	  LET f_bank_code[4,7] = f_pscu.remit_branch
        	  LET f_remit_account  = f_pscu.remit_account
        ELSE
        	  LET f_bank_code      = f_pscu.bank_code
        	  LET f_remit_account  = f_pscu.bank_account_e
        END IF
        
        -- 電匯帳號
        LET f_detail[i].remit_account  = f_bank_code,'-',f_remit_account
        
        -- 銀行名稱
        SELECT bank_name
        INTO   f_detail[i].bank_name
        FROM   bank
        WHERE  bank_code = f_bank_code
    END FOREACH 
    
    OPEN WINDOW w_s14 AT 13,1 WITH FORM "psc01i14"  ATTRIBUTE(GREEN, FORM LINE FIRST)
    DISPLAY f_payout_date_from,f_zip_code ,f_address_1 ,i
    TO      payout_date_from  ,zip_code   ,address     ,total_record ATTRIBUTE (YELLOW)
    CALL SET_COUNT( i )
    DISPLAY ARRAY f_detail TO psc01_s14.*  ATTRIBUTE( YELLOW ,UNDERLINE )
    CLOSE WINDOW w_s14    
END FUNCTION          