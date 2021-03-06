------------------------------------------------------------------------------
--  程式名稱: psc02m.4gl
--  作    者: merlin
--  日    期: 
--  處理概要: 還本櫃臺作業
--  重要函式:
------------------------------------------------------------------------------
-- 票據查詢前必須先宣告 g_check_count＝0 才會找資料
-- 089/09/14:修改審查表列印格式與內容，取消補印功能
------------------------------------------------------------------------------
-- 修改者:JC
--  090/04/25:修改受益人名字的找法,有id 找clnt,否則顯示 benf 的 names
------------------------------------------------------------------------------
-- 修改者:merlin
-- 090/07/20:開放保單狀態66，67，73可櫃臺作業及已領取報表增加應領金額
------------------------------------------------------------------------------
GLOBALS "../def/common.4gl"
GLOBALS "../def/lf.4gl"
GLOBALS "../def/pscgcpn.4gl"
GLOBALS "../def/g_check_array.4gl"
GLOBALS "../def/report.4gl"

DATABASE life

    DEFINE p_space           CHAR(20)
          ,p_bell            CHAR
          ,b                 CHAR(1)
          ,p_rcode           INTEGER      
   DEFINE p_name                CHAR(14)

    DEFINE p_policy_no        LIKE pscb.policy_no
          ,p_applicant_id     LIKE clnt.client_id       -- 業務員ID   --
          ,p_applicant_name   LIKE clnt.names           -- 業務員姓名 --
          ,p_coverage_no      LIKE colf.coverage_no     -- 險種版本   --
          ,p_benf_cnt         INTEGER                   -- 受益人數   -- 
          ,p_cp_sw            CHAR(1)                   -- 還本指示   -- 
          ,p_check_date       CHAR(9)

 
    -- 畫面一上半部的資料 --
    DEFINE p_data_s1 RECORD -- screen s1 -- 
           policy_no         LIKE pscb.policy_no       -- 保單號碼   --
          ,cp_anniv_date     LIKE pscp.cp_anniv_date   -- 週年日     --
          ,expired_sw        CHAR                      -- 滿期/生存  --
          ,cp_remark_sw      LIKE pscb.cp_remark_sw    -- 註記指示   --  
          ,cp_pay_name       LIKE pscb.cp_pay_name     -- 應領人姓名 --
          ,cp_pay_id         LIKE pscb.cp_pay_id       -- 應領ID     --
          ,dept_code         LIKE pscb.dept_code       -- 領取分公司 --
                 END RECORD

    -- 畫面一第二部份資料 --
    DEFINE p_data_s3 RECORD
           po_issue_date     LIKE polf.po_issue_date   -- 生效日     --
          ,paid_to_date      LIKE polf.paid_to_date    -- 繳費終日   --
          ,po_sts_code       LIKE polf.po_sts_code     -- 保單狀態   --
          ,app_name          CHAR(12)                  -- 要保人     --
          ,insured_name      CHAR(12)                  -- 被保人     --
          ,method            LIKE polf.method          -- 收費方式   --
          ,dept_name         LIKE dept.dept_name       -- 營業單位   --
          ,agent_name        LIKE clnt.names           -- 業務員     --
          ,chk_date          CHAR(9)                   -- 未兌支票   --
                 END RECORD

    -- 畫面一第三部分資料 --
    DEFINE p_data_s2 ARRAY[99] OF RECORD               -- 受益人情形 --
           names               LIKE benf.names         -- 受益人姓名 --
          ,benf_ratio          LIKE benf.benf_ratio    -- 受益比例   --
          ,remit_account       LIKE benf.remit_account -- 匯款帳號   --
          ,benf_order          LIKE benf.benf_order    -- 匯款銀行   --
                 END RECORD
 

    DEFINE p_pscb              RECORD LIKE pscb.*  
    DEFINE p_pscp              RECORD LIKE pscp.*

    -- 審查單內容 --    
    DEFINE benf_arr             ARRAY[6]  OF RECORD
           names                LIKE pscd.names
          ,benf_ratio           LIKE pscd.benf_ratio
          ,cp_real_payamt       LIKE pscd.cp_real_payamt
          ,disb_no              LIKE pscd.disb_no       
         END RECORD

    DEFINE p_cpform_1           ARRAY[32] OF CHAR(100)
    DEFINE p_cpform_2           ARRAY[32] OF CHAR(100)          
    DEFINE p_cpform_init        CHAR(100)       
    DEFINE p_pass_or_deny       INTEGER

-- 主程式 --
MAIN

    OPTIONS
        ERROR   LINE LAST 
      , PROMPT  LINE LAST - 2 
      , MESSAGE LINE LAST - 1
      , COMMENT LINE LAST - 1

    DEFER INTERRUPT
    SET LOCK MODE TO WAIT

    LET g_program_id ="psc02m"
    LET p_space      =" "
    LET p_bell       =ASCII 7

    -- 顯示第一畫面 --
    OPEN FORM psc02m01 FROM "psc02m01"
    DISPLAY FORM psc02m01 ATTRIBUTE (GREEN)

    CALL ShowLogo()
    -- JOB  CONTROL beg --
    CALL GetDocLname( '2') RETURNING p_name
    CALL JobControl()

    MENU "請選擇"
       BEFORE MENU
            IF  NOT CheckAuthority("1", FALSE)  THEN
                HIDE OPTION "1)領取"
            END IF
            IF  NOT CheckAuthority("2", FALSE)  THEN
                HIDE OPTION "2)還本查詢"
            END IF
            IF  NOT CheckAuthority("3", FALSE)  THEN
                HIDE OPTION "3)理賠查詢"
            END IF
            IF  NOT CheckAuthority("4", FALSE)  THEN
                HIDE OPTION "4)票據查詢"
            END IF
            IF  NOT CheckAuthority("5", FALSE)  THEN
                HIDE OPTION "5)註記查詢"
            END IF
{
            IF  NOT CheckAuthority("6", FALSE)  THEN
                HIDE OPTION "6)補印審查表"
            END IF
}
            IF  NOT CheckAuthority("7", FALSE)  THEN
                HIDE OPTION "7)列印櫃臺已領取報表"
            END IF
        COMMAND "1)領取"
                 CALL psc02m_pay()

        COMMAND "2)還本查詢"
                 RUN "psc01i.4ge"

        COMMAND "3)理賠查詢"
                 CALL psc02m_init()
                 CALL qry_input() RETURNING p_pass_or_deny
                   IF p_pass_or_deny=0 THEN
                      CALL qryClaim(p_data_s1.policy_no,2,2)
                   END IF 

        COMMAND "4)票據查詢"
                 CALL psc02m_init()
                 CALL qry_input() RETURNING p_pass_or_deny
                   IF p_pass_or_deny=0 THEN
                      LET g_check_count=0 
                      CALL qryCheck()   RETURNING p_check_date
                   END IF       

        COMMAND "5)註記查詢"
                 CALL psc02m_init()
                 CALL psc02m_input() RETURNING p_pass_or_deny
                   IF p_pass_or_deny=0 THEN
                      CALL pscninq(p_data_s1.policy_no,p_data_s1.cp_anniv_date)
                      RETURNING p_pass_or_deny
                   END IF
{
        COMMAND "6)補印審查表" 
                 CALL psc02m_print("6") 
}
        COMMAND "7)列印櫃臺已領取報表"
                 CALL psc02m_print("7")

        COMMAND "0)結束"
                 EXIT MENU
        END MENU 
 
    CLOSE FORM psc02m01

    -- JOB  CONTROL beg --
    CALL JobControl()

END MAIN -- 主程式結束 --

------------------------------------------------------------------------------
--  函式名稱: psc02m_pay
--  作    者: merlin
--  日    期: 
--  處理概要: 還本櫃臺作業_領取作業
--  重要函式:
------------------------------------------------------------------------------          
FUNCTION psc02m_pay()
    DEFINE f_rcode      INTEGER    
    DEFINE f_pscb_cnt   INTEGER 
    DEFINE f_cp_sw      LIKE pscb.cp_sw
        
     CALL psc02m_init()
     CALL psc02m_input() RETURNING f_rcode

     --判斷保單是否已還本--     
     IF f_rcode=0 THEN  
        SELECT count(*) 
        INTO f_pscb_cnt
        FROM   pscb
        WHERE  policy_no=p_data_s1.policy_no
        AND    cp_anniv_date=p_data_s1.cp_anniv_date
        AND    cp_sw in ("3","7")
        AND    cp_notice_sw="2"

       IF f_pscb_cnt is null OR
          f_pscb_cnt =0      THEN
          ERROR "請由還本查詢功能查詢相關資料！" 
          ATTRIBUTE(RED,UNDERLINE)
       ELSE
          CALL psc02m_display()
          CALL psc02m_check() RETURNING f_rcode 
       END IF
       CALL Fatca_message()
     END IF     
END FUNCTION    ---  psc02m_pay ---

------------------------------------------------------------------------------
--  函式名稱: psc02m_print()
--  作    者: merlin
--  日    期: 
--  處理概要: 還本櫃臺作業_列印作業
--  重要函式:
------------------------------------------------------------------------------
FUNCTION psc02m_print(f_print_type)
    DEFINE f_rcode              INTEGER
    DEFINE f_dept_code          LIKE pscb.dept_code
          ,f_start_date         CHAR(9)
          ,f_end_date           CHAR(9)
          ,f_pscb_cnt           INTEGER
          ,f_print_type         CHAR(1)

     CASE 
         WHEN f_print_type="6"          
             CALL psc02m_init()
             CALL psc02m_input() RETURNING f_rcode      
             IF f_rcode=0 THEN
                LET f_pscb_cnt=0
                SELECT count(*) 
                INTO f_pscb_cnt
                FROM   pscb
                WHERE  policy_no=p_data_s1.policy_no
                AND    cp_anniv_date=p_data_s1.cp_anniv_date       
                AND    cp_sw in ("2","5","6")
                AND    cp_disb_type="1"

                IF f_pscb_cnt is null OR
                   f_pscb_cnt =0      THEN
                   ERROR "保單已還本，請由還本查詢功能查詢相關資料！" 
                   ATTRIBUTE(RED,UNDERLINE)
                ELSE
                   CALL psc02m_display()
                   CALL psc02m_init_array() RETURNING f_rcode
                   IF f_rcode=1 THEN    
                       CALL psc02m_report1(p_data_s1.policy_no,
                                           p_data_s1.cp_anniv_date,'')             
                            RETURNING f_rcode   
                   END IF
                   IF f_rcode=0 THEN
                      ERROR "列印作業有誤！！"
                   END IF
                END IF
             END IF
        WHEN f_print_type="7"
             CALL psc02m_input1()
                  RETURNING f_rcode,f_dept_code,f_start_date
                  IF f_rcode=0  THEN
                     CALL psc02m_report2(f_dept_code,f_start_date)      
                          RETURNING f_rcode
                       IF f_rcode=0  THEN
                           ERROR "列印作業有誤！！"
                       END IF
                 END IF
        END CASE
END FUNCTION      --- psc02m_print ---
------------------------------------------------------------------------------
--  函式名稱: psc02m_init
--  作    者: merlin
--  日    期: 
--  處理概要: 還本櫃臺作業_畫面初值
--  重要函式:
------------------------------------------------------------------------------

FUNCTION psc02m_init()
    DEFINE f_i           SMALLINT -- array index ---

    LET   p_policy_no     =" "
    LET   p_applicant_id  =" "
    LET   p_applicant_name=" "
    LET   p_coverage_no   =1

    -- 畫面一資料 --
    LET   p_data_s1.policy_no              =" "       -- 保單號碼   --
    LET   p_data_s1.cp_anniv_date          =" "       -- 還本週年日 --
    LET   p_data_s1.expired_sw             =" "       -- 滿期/生存  --
    LET   p_data_s1.cp_remark_sw           =" "       -- 註記指示   --
    LET   p_data_s1.cp_pay_name            =" "       -- 應領人姓名 --
    LET   p_data_s1.cp_pay_id              =" "       -- 應領人ID   --
    LET   p_data_s1.dept_code              =" "       -- 領取分公司 --                          

    -- 畫面二資料 --
    LET   p_data_s3.po_issue_date          =" "       -- 生效日     --
    LET   p_data_s3.paid_to_date           =" "       -- 繳費終日   --
    LET   p_data_s3.po_sts_code            =" "       -- 保單狀態   --
    LET   p_data_s3.app_name               =" "       -- 要保人     --
    LET   p_data_s3.insured_name           =" "       -- 被保人     --
    LET   p_data_s3.method                 =" "       -- 收費方式   --
    LET   p_data_s3.dept_name              =" "       -- 營業單位   --
    LET   p_data_s3.agent_name             =" "       -- 業務員     --
    LET   p_data_s3.chk_date               =" "       -- 未兌支票   --

    -- 畫面三 detail 資料 --
    FOR f_i=1 TO 4
       LET   p_data_s2[f_i].names          =" "       -- 姓名/名稱  --
       LET   p_data_s2[f_i].benf_ratio     = 0        -- 受益比例   --
       LET   p_data_s2[f_i].remit_account  =" "       -- 匯款帳號   --
       LET   p_data_s2[f_i].benf_order     =" "       -- 受益順位   --
    END FOR
    CLEAR FORM
END FUNCTION   -- psc02m_init --
------------------------------------------------------------------------------
--  函式名稱: psc02m_input
--  作    者: merlin
--  日    期: 
--  處理概要: 還本櫃臺作業_畫面輸入（領取，註記查詢，報表列印）
--  重要函式:
------------------------------------------------------------------------------
FUNCTION psc02m_input()
    DEFINE f_right_or_fault     INTEGER   -- 日期檢查 t or f --
          ,f_formated_date      CHAR(9)   -- 日期格式化 999/99/99 --
          ,f_pscb_cnt           INTEGER   -- 執行 perpare 指令有保單可執行 --
          ,f_rcode              INTEGER

    LET f_rcode       =FALSE            
    LET INT_FLAG      =FALSE
    LET f_pscb_cnt    =0

    MESSAGE " END(F7):取消作業"

    INPUT p_data_s1.policy_no,p_data_s1.cp_anniv_date
    FROM  policy_no,cp_anniv_date
    ATTRIBUTE(BLUE ,REVERSE ,UNDERLINE)
  
    AFTER FIELD policy_no
        IF p_data_s1.policy_no=" "            OR
           p_data_s1.policy_no="            " THEN
           ERROR "保單號碼必須輸入!!"    ATTRIBUTE (RED)
           NEXT FIELD policy_no
        END IF
       -- 資料檢查 --
       -- g_polf.的資料 --
       SELECT *
       INTO   g_polf.*
       FROM   polf
       WHERE  policy_no=p_data_s1.policy_no

       IF STATUS=NOTFOUND THEN
          ERROR "無此張保單!!" ATTRIBUTE (RED)
          NEXT FIELD policy_no
       END IF

    AFTER FIELD cp_anniv_date
        CALL CheckDate(p_data_s1.cp_anniv_date)
             RETURNING f_right_or_fault,f_formated_date

        IF f_right_or_fault = false THEN
           ERROR "週年日輸入錯誤!!" ATTRIBUTE (RED)
           NEXT FIELD cp_anniv_date
        END IF

        IF p_data_s1.cp_anniv_date="         " OR
           p_data_s1.cp_anniv_date=" "         THEN
           ERROR "週年日必須輸入!!"  ATTRIBUTE (RED)
           NEXT FIELD cp_anniv_date
        END IF

    ON KEY (F7)
       LET INT_FLAG=TRUE
       EXIT INPUT
    AFTER INPUT

       IF INT_FLAG=TRUE THEN
          EXIT INPUT
       END IF

    END INPUT
       MESSAGE " "      

    -- 中斷作業 --
    IF INT_FLAG=TRUE THEN
       LET f_rcode=TRUE 
       RETURN f_rcode
    END IF
    RETURN f_rcode
   
END FUNCTION    --- psc02m_input ---
------------------------------------------------------------------------------
--  函式名稱: qry_input
--  作    者: merlin
--  日    期: 
--  處理概要: 還本櫃臺作業_畫面輸入（理賠，票據查詢）
--  重要函式:
------------------------------------------------------------------------------
FUNCTION qry_input()
    DEFINE f_right_or_fault     INTEGER   -- 日期檢查 t or f --
          ,f_formated_date      CHAR(9)   -- 日期格式化 999/99/99 --
          ,f_pscb_cnt           INTEGER   -- 執行 perpare 指令有保單可執行 --
          ,f_rcode              INTEGER

    LET f_rcode       =FALSE            
    LET INT_FLAG      =FALSE
    LET f_pscb_cnt    =0

    MESSAGE " END(F7):取消作業"

    INPUT p_data_s1.policy_no
    FROM  policy_no
    ATTRIBUTE(BLUE ,REVERSE ,UNDERLINE)

    AFTER FIELD policy_no
        IF p_data_s1.policy_no=" "            OR
           p_data_s1.policy_no="            " THEN
           ERROR "保單號碼必須輸入!!"    ATTRIBUTE (RED)
           NEXT FIELD policy_no
        END IF

    ON KEY (F7)
       LET INT_FLAG=TRUE
       EXIT INPUT
    AFTER INPUT

       IF INT_FLAG=TRUE THEN
          EXIT INPUT
       END IF

       -- 資料檢查 --
       -- g_polf.的資料 --
       SELECT *
       INTO   g_polf.*
       FROM   polf
       WHERE  policy_no=p_data_s1.policy_no

       IF STATUS=NOTFOUND THEN
          ERROR "無此張保單!!"   ATTRIBUTE (RED)
          NEXT FIELD policy_no
       END IF

    END INPUT
       MESSAGE " "      

    -- 中斷作業 --
    IF INT_FLAG=TRUE THEN
       LET f_rcode=TRUE 
       RETURN f_rcode
    END IF
     RETURN f_rcode
   
END FUNCTION    --- qry_input ---

------------------------------------------------------------------------------
--  函式名稱: psc02m_display
--  作    者: merlin
--  日    期: 
--  處理概要: 還本櫃臺作業_畫面顯示
--  重要函式:
------------------------------------------------------------------------------
FUNCTION psc02m_display()
    
    DEFINE f_i                  INTEGER                 -- array 計數器 
          ,f_benf_cnt           INTEGER                 -- 受益人計數器 
          ,f_arr_cur            INTEGER                 -- 受益人輸入的計數 
          ,f_scr_cur            INTEGER                 -- 受益人畫面的計數 
          ,f_disb_err           INTEGER                 -- 受益人銀行帳號有錯 

    DEFINE f_cp_anniv_date      LIKE pscb.cp_anniv_date      -- 週年日   
          ,f_cp_sw              LIKE pscb.cp_sw              -- 還本指示 
          ,f_expired_sw         CHAR
          ,f_cp_remark_sw       LIKE pscb.cp_remark_sw       -- 註記指示 
          ,f_cp_pay_name        LIKE pscb.cp_pay_name        -- 應領人姓名 
          ,f_cp_pay_id          LIKE pscb.cp_pay_id          -- 應領人ID 
          ,f_pay_dept_code      LIKE pscb.dept_code          -- 領取分公司 

    DEFINE f_cp_notice_formtype LIKE pscr.cp_notice_formtype -- 通知書格式
          ,f_chk_sw             LIKE pscr.cp_chk_sw          -- 支票未兌現指示
          ,f_chk_date           LIKE pscr.cp_chk_date        -- 未兌現支票MAX日

    DEFINE f_arr                INTEGER
          ,f_dtl_real_amt       INTEGER
          ,f_dtl_cp_ann         LIKE pscb.cp_anniv_date
          ,f_client_ident       LIKE colf.client_ident       -- 關係人識別碼
          ,f_applicant_id       LIKE clnt.client_id          -- 要保人證號
          ,f_insured_id         LIKE clnt.client_id          -- 被保險人證號
          ,f_app_name           LIKE clnt.names              -- 要保人姓名
          ,f_insured_name       LIKE clnt.names              -- 被保險人姓名
          ,f_agent_code         LIKE agnt.agent_code         -- 業務員代碼
          ,f_dept_code          LIKE dept.dept_code          -- 部門代碼
          ,f_relation           CHAR(1)
          ,f_benf_client_id     CHAR(10)

    MESSAGE "END(F7):取消作業"

    LET f_client_ident=" "
    LET f_applicant_id=" "
    LET f_app_name    =" "
    LET f_insured_id  =" "
    LET f_insured_name=" "
    LET f_chk_date    =" "
    LET f_chk_sw      =" "
    LET f_expired_sw  =" " 
    LET f_agent_code  =" "
    LET f_dept_code   =""               
    LET f_relation    =""

    LET p_policy_no=p_data_s1.policy_no
        
        SELECT cp_sw,cp_pay_name,cp_pay_id,dept_code,cp_remark_sw
        INTO   f_cp_sw,f_cp_pay_name,f_cp_pay_id,f_pay_dept_code,f_cp_remark_sw
        FROM   pscb
        WHERE  policy_no     = p_policy_no
        AND    cp_anniv_date = p_data_s1.cp_anniv_date

     -- 判斷滿期/生存受益人
        IF p_data_s1.cp_anniv_date >= g_polf.expired_date THEN
           LET f_expired_sw = "Y"
           LET f_relation   = "M"
        ELSE
           LET f_expired_sw = "N"
           LET f_relation   = "L"
        END IF

     -- 畫面一的第二部資料 --
        LET  p_data_s3.po_sts_code    = g_polf.po_sts_code
        LET  p_data_s3.method         = g_polf.method
        LET  p_data_s3.po_issue_date  = g_polf.po_issue_date
        LET  p_data_s3.paid_to_date   = g_polf.paid_to_date

     -- 業務員,與營業單位 --
        SELECT agent_code
        INTO   f_agent_code
        FROM   poag
        WHERE  policy_no=p_data_s1.policy_no
        AND    relation ="S"

        SELECT dept_code
        INTO   f_dept_code
        FROM   agnt
        WHERE  agent_code=f_agent_code  

     -- 要保人ID,姓名 --
        CALL getNames(p_data_s1.policy_no,'O1')
             RETURNING p_applicant_id,p_applicant_name

     -- 未兌現支票日期 --       
        SELECT cp_chk_date,coverage_no
        INTO   f_chk_date,p_coverage_no
        FROM   pscp
        WHERE  policy_no=p_policy_no
        AND    cp_anniv_date=p_data_s1.cp_anniv_date
        
     -- 被保人ID,姓名 --
        SELECT client_ident
        INTO   f_client_ident
        FROM   colf
        WHERE  policy_no=p_policy_no
        AND    coverage_no=p_coverage_no

     -- 被保險人姓名 --
        SELECT client_id
        INTO   f_insured_id
        FROM   pocl
        WHERE  policy_no=p_policy_no
        AND    client_ident=f_client_ident

        SELECT names
        INTO   f_insured_name
        FROM   clnt
        WHERE  client_id=f_insured_id

     -- 業務員姓名，營業單位 --
        SELECT names
        INTO   p_data_s3.agent_name
        FROM   clnt
        WHERE  client_id=f_agent_code

        SELECT dept_name
        INTO   p_data_s3.dept_name
        FROM   dept
        WHERE  dept_code=f_dept_code

        LET p_data_s3.app_name     = p_applicant_name[1,12]
        LET p_data_s3.insured_name = f_insured_name[1,12]  
        LET p_data_s3.chk_date     = f_chk_date
        
    -- 畫面一的第二部資料 --
    -- 要判斷滿期或生存 滿期 relation="M" ,生存 relation="L" 
        SELECT count(*)
        INTO   f_benf_cnt
        FROM   benf
        WHERE  policy_no= p_data_s1.policy_no
        AND    relation = f_relation

        IF f_benf_cnt !=0 THEN
           LET f_i=1
           LET p_benf_cnt = 1
           DECLARE benf_cur CURSOR FOR
           SELECT names
                 ,benf_ratio
                 ,remit_account
                 ,benf_order
                 ,client_id
           FROM  benf
           WHERE policy_no  = p_data_s1.policy_no
           AND   relation   = f_relation

           FOREACH benf_cur INTO p_data_s2[p_benf_cnt].*,f_benf_client_id
               IF LENGTH(f_benf_client_id CLIPPED) !=0 THEN
                  SELECT names INTO p_data_s2[p_benf_cnt].names
                  FROM   clnt
                  WHERE  client_id=f_benf_client_id                 
               END IF
           LET p_benf_cnt = p_benf_cnt + 1
           END FOREACH

           FREE benf_cur
           LET p_benf_cnt=p_benf_cnt-1
        END IF

    -- 顯示取得的資料(畫面一第三部份) --
       DISPLAY BY NAME p_data_s3.*  ATTRIBUTE (YELLOW)

    -- 顯示取得的資料(畫面一第二部份) --
       IF f_benf_cnt !=0 THEN
          FOR f_i=1 TO 4
            IF f_i > p_benf_cnt THEN
               EXIT FOR
            END IF
            DISPLAY p_data_s2[f_i].* TO psc02_s1[f_i].*   ATTRIBUTE (YELLOW)
          END FOR
       ELSE
          FOR f_i=1 TO 4
              DISPLAY p_data_s2[f_i].* TO psc02_s1[f_i].* ATTRIBUTE (YELLOW)
          END FOR 
      END IF

    -- 顯示取得的資料(畫面一第一部份) --
    
      LET p_data_s1.expired_sw   = f_expired_sw
      LET p_data_s1.cp_remark_sw = f_cp_remark_sw
      LET p_data_s1.cp_pay_name  = f_cp_pay_name
      LET p_data_s1.cp_pay_id    = f_cp_pay_id
      LET p_data_s1.dept_code    = f_pay_dept_code
      LET p_cp_sw                = f_cp_sw

      DISPLAY BY NAME p_data_s1.*  ATTRIBUTE (YELLOW)

    RETURN 
END FUNCTION   -- psc02m_display --
------------------------------------------------------------------------------
--  函式名稱: psc02m_check()
--  作    者: merlin
--  日    期: 
--  處理概要: 還本櫃臺作業_領取條件判斷
--  重要函式:
------------------------------------------------------------------------------
FUNCTION psc02m_check()

    DEFINE  f_ans_sw            CHAR
    DEFINE  f_ans_sw1           CHAR    
    DEFINE  f_tran_date         CHAR(9)
    DEFINE  f_rcode             INTEGER
    DEFINE  f_count             INTEGER 
    DEFINE  f_journal_amt       LIKE glrc.journal_amount        
    DEFINE  f_cp_pay_amt        LIKE pscp.cp_pay_amt
    DEFINE  f_cp_pay_form_type  LIKE pscp.cp_pay_form_type
    DEFINE  f_dept_belong       LIKE dept.dept_code
           ,f_dept_belong_name  LIKE dept.dept_name
           ,f_t_f               INTEGER
    DEFINE  f_cp_disb_type      LIKE pscb.cp_disb_type

    DEFINE f_user_code          LIKE edp_base:usrdat.user_code
          ,f_user_id            LIKE edp_base:usrdat.id_code
          ,f_user_name          LIKE edp_base:usrdat.user_name
          ,f_dept_code          LIKE edp_base:usrdat.dept_code
          ,f_receive_no         LIKE apdt.po_chg_rece_no

      LET f_rcode               =0
      LET f_count               =0      
      LET f_dept_code           =""
      LET f_dept_belong         =""
      LET f_tran_date           =""
      LET f_journal_amt         =0
      LET f_cp_pay_amt          =0
      LET f_cp_disb_type        =""
      LET f_receive_no          =""     

WHILE f_rcode=0                 
        -- 判斷保單狀態合理性 --
        IF p_data_s3.po_sts_code != "42"  AND
           p_data_s3.po_sts_code != "43"  AND 
           p_data_s3.po_sts_code != "44"  AND
           p_data_s3.po_sts_code != "46"  AND
           p_data_s3.po_sts_code != "47"  AND   
           p_data_s3.po_sts_code != "48"  AND
           p_data_s3.po_sts_code != "50"  AND
           p_data_s3.po_sts_code != "62"  AND
	   p_data_s3.po_sts_code != "66"  AND
           p_data_s3.po_sts_code != "67"  AND
           p_data_s3.po_sts_code != "73"  THEN
           ERROR "保單狀態不符!!"
           LET g_coupon_errmsg="保單狀態不符!!" CLIPPED,p_data_s3.po_sts_code
           ERROR "erorr:",g_coupon_errmsg ATTRIBUTE(RED,UNDERLINE) 
           LET f_rcode=1
           EXIT WHILE
        END IF

        -- 判斷PTD 是否大於還本週年 --
        IF p_data_s3.po_sts_code != "43"  AND
           p_data_s3.po_sts_code != "44"  AND
           p_data_s3.po_sts_code != "46"  AND 
           p_data_s3.po_sts_code != "62"  THEN
           IF p_data_s3.paid_to_date < p_data_s1.cp_anniv_date THEN
              LET g_coupon_errmsg="繳費終日＜還本週年日!!" CLIPPED
                               ,p_data_s3.paid_to_date,p_data_s1.cp_anniv_date
              ERROR "erorr:",g_coupon_errmsg ATTRIBUTE(RED,UNDERLINE) 
              LET f_rcode=1
              EXIT WHILE
           END IF
        END IF

        SELECT * 
        INTO   p_pscb.*
        FROM   pscb
        WHERE  policy_no=p_data_s1.policy_no
        AND    cp_anniv_date=p_data_s1.cp_anniv_date

        CALL initgpsc(p_pscb.policy_no
                     ,p_pscb.cp_anniv_date
                     ,p_pscb.cp_disb_type
                     ,p_pscb.mail_addr_ind
                      )
        RETURNING f_rcode

        SELECT * 
        INTO   g_pscp.*
        FROM   pscp
        WHERE  policy_no=p_pscb.policy_no
        AND    cp_anniv_date=p_pscb.cp_anniv_date

        -- 判斷領取方式 --
        IF p_pscb.cp_disb_type != "1" THEN
           LET g_coupon_errmsg=" 還本領取方式不是櫃臺領取!!" CLIPPED
                               ,p_pscb.cp_disb_type     
           ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
           LET f_rcode=1
           EXIT WHILE
        END IF

        -- 領取日期是否大於週年日 --
        LET f_tran_date=GetDate(today)  
        IF f_tran_date < p_data_s1.cp_anniv_date THEN
           LET g_coupon_errmsg="領取日期小於還本週年日!!" CLIPPED
                               ,f_tran_date,p_data_s1.cp_anniv_date     
           ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
           LET f_rcode=1
           EXIT WHILE
        END IF

        -- 領取分公司判斷 --
        CALL GetUserData (g_user)  RETURNING f_user_code
                                            ,f_user_id
                                            ,f_user_name
                                            ,f_dept_code

        LET f_dept_belong      = ""
        LET f_dept_belong_name = ""
        CALL GetDBranchOffice(f_dept_code)   RETURNING f_t_f
                                                      ,f_dept_belong
                                                      ,f_dept_belong_name
        
        IF f_t_f =FALSE THEN
           LET g_coupon_errmsg="使用者對應分公司找不到!!" CLIPPED
                               ,f_dept_code
           ERROR "error:",g_coupon_errmsg ATTRIBUTE(RED,UNDERLINE)
           LET f_rcode=1
           EXIT WHILE
        END IF

        IF LENGTH(f_dept_belong CLIPPED) =0 THEN
           LET g_coupon_errmsg="使用者所屬分公司找不到!!" CLIPPED
                               ,f_dept_code
           ERROR "error:",g_coupon_errmsg ATTRIBUTE(RED,UNDERLINE)
           LET f_rcode=1
           EXIT WHILE
        END IF
  
        IF f_dept_belong != p_data_s1.dept_code THEN
           LET g_coupon_errmsg="領取分公司與作業分公司不符!!" CLIPPED
                               ,f_dept_belong,p_data_s1.dept_code
           ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
           LET f_rcode=1
           EXIT WHILE
        END IF

        -- 是否有未兌現支票 --
        CALL psc34s00(p_data_s1.policy_no,p_data_s1.cp_anniv_date,f_tran_date)  
             RETURNING f_rcode  
             IF f_rcode !=0 THEN
                LET g_coupon_errmsg="call psc03s00 error" 
                ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
                LET f_rcode=1
                EXIT WHILE
             END IF     

             IF g_coupon.g_chk_sw="N" THEN
                LET g_coupon_errmsg="有未兌現支票" 
                ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
                LET f_rcode=1
                EXIT WHILE
             END IF

        -- 領取金額與沖銷金額相符否 --
        LET   f_cp_pay_amt=g_pscp.cp_pay_amt*(-1)
        
        SELECT sum(journal_amount) 
        INTO   f_journal_amt            
        FROM   glrc
        WHERE  acct_no="28250019"
        AND    recn_code=p_data_s1.policy_no

        IF  f_journal_amt != f_cp_pay_amt       THEN
            LET g_coupon_errmsg="沖銷金額與領取金額不符，請查詢帳務作業!!"
                                ,f_journal_amt,f_cp_pay_amt
            ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
            LET f_rcode=1
            EXIT WHILE
        END IF

        -- 是否有理賠資料 --         
        CALL qryClaim(p_data_s1.policy_no,2,2)  

        -- 是否完成受理作業 --
        CALL getAcceptNo("9","")
             RETURNING  f_receive_no    

        IF  LENGTH(f_receive_no) =0     THEN
            LET g_coupon_errmsg="尚未完成受理作業!!"                            
            ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
            LET f_rcode=1
            EXIT WHILE
        ELSE
            ERROR f_receive_no  ATTRIBUTE(RED,UNDERLINE) 
        END IF  

       -- 是否有異常情形 --     
       SELECT count(*)
       INTO   f_count
       FROM   psce
       WHERE  policy_no     = p_data_s1.policy_no
       AND    cp_anniv_date = p_data_s1.cp_anniv_date

       IF f_count !=0  THEN
          ERROR "曾有異常情形請查明再作業!!" 
       END IF

      PROMPT '是否符合領取條件[y/n]' ATTRIBUTE(RED,UNDERLINE)
      FOR CHAR f_ans_sw1
      IF UPSHIFT(f_ans_sw1) = 'Y' THEN
         PROMPT '請注意!!生存金領取審查表須依給付金額進行政授權簽核[y/n]' ATTRIBUTE(RED,UNDERLINE)
         FOR CHAR f_ans_sw

         IF UPSHIFT(f_ans_sw) = 'Y' THEN                   
            CALL psc02m_payout(p_pscb.*
                           ,f_tran_date
                           ,g_pscp.cp_pay_amt
                           ,g_pscp.cp_pay_form_type
                           ,f_dept_code
                           ) 
            RETURNING f_rcode,g_coupon_errmsg
  
            IF f_rcode=0   THEN
               CALL psc02m_init_array()  RETURNING f_rcode
               CALL psc02m_report1(p_data_s1.policy_no
                               ,p_data_s1.cp_anniv_date
                               ,f_receive_no)
               RETURNING f_rcode           
               IF f_rcode=1 THEN
                  ERROR '成功!!' ATTRIBUTE(RED,UNDERLINE)
               ELSE
                  ERROR '列印審查表失敗，請由列印作業補印'ATTRIBUTE(RED,UNDERLINE)
               END IF
            ELSE
               ERROR "erorr:",g_coupon_errmsg
            END IF  
         END IF
         IF UPSHIFT(f_ans_sw) = 'N' THEN
            ERROR '離開領取作業!!' ATTRIBUTE(RED,UNDERLINE)
            LET f_rcode=0
            EXIT WHILE
         END IF

      END IF
      IF UPSHIFT(f_ans_sw1) = 'N' THEN
         ERROR '離開領取作業!!' ATTRIBUTE(RED,UNDERLINE)
         LET f_rcode=0
         EXIT WHILE
      END IF
END WHILE
RETURN f_rcode
END FUNCTION  --- psc02m_check ---
------------------------------------------------------------------------------
--  函式名稱: psc02m_report1()
--  作    者: merlin
--  日    期: 
--  處理概要: 還本櫃臺作業_列印審查單
--  重要函式:
------------------------------------------------------------------------------
FUNCTION psc02m_report1(f_policy_no,f_cp_anniv_date,f_receive_no)
    DEFINE f_policy_no           LIKE pscp.policy_no
          ,f_cp_anniv_date       LIKE pscp.cp_anniv_date        
          ,f_rcode               INTEGER
          ,f_i                   INTEGER          
          ,f_benf_cnt            INTEGER
          ,f_rpt_name_1          CHAR(30)
          ,cmd                   CHAR(900)
          ,copies                INTEGER
          ,f_ans_sw              CHAR(1)
          ,f_rpt_cnt             INTEGER
          ,i                     INTEGER
          ,f_receive_no          LIKE apdt.po_chg_rece_no
    DEFINE r            RECORD
         process_date             CHAR(9)                       -- 作業日
        ,applicant_name           LIKE clnt.names               -- 要保人姓名
        ,insured_name             LIKE clnt.names               -- 被保險人姓名
        ,po_sts_code              LIKE polf.po_sts_code         -- 保單狀態
        ,modx                     CHAR(6)                       -- 繳法
        ,plan_desc                LIKE pldf.plan_desc           -- 還本險種
        ,policy_no                LIKE pscp.policy_no           -- 保單號碼
        ,face_amt                 INTEGER                       -- 保險金額
        ,dept_name                LIKE dept.dept_name           -- 營業處代碼
        ,agent_name               LIKE clnt.names               -- 業務員代碼
        ,po_issue_date            LIKE pscp.po_issue_date       -- 生效日
        ,paid_to_date             LIKE pscp.paid_to_date        -- 繳費終日
        ,cp_pay_form_type         LIKE pscp.cp_pay_form_type    -- 給付格式
        ,cp_anniv_date            LIKE pscp.cp_anniv_date       -- 週年日
        ,div_option               LIKE pscp.div_option          -- 紅利選擇權
        ,cp_amt                   INTEGER                       -- 給付金額
        ,div_amt                  INTEGER                       -- 保單紅利
        ,prem_susp                INTEGER                       -- 溢繳
        ,minus_prem_susp          INTEGER                       -- 欠繳
        ,apl_int                  INTEGER                       -- 自動墊繳利息
        ,apl_amt                  INTEGER                       -- 自動墊繳本金
        ,loan_int                 INTEGER                       -- 借款利息
        ,loan_amt                 INTEGER                       -- 借款本金
        ,cp_pay_amt               INTEGER                       -- 應給付淨額
        ,rtn_rece_no              CHAR(10)                      -- 還款收據號碼 
        ,cp_pay_name              CHAR(12)                      -- 領取人姓名
        ,cp_pay_id                LIKE pscb.cp_pay_id           -- 領取人ID
        ,pay_dept_code            LIKE pscb.dept_code           -- 領取分公司
        ,benf_cnt                 INTEGER
        ,plan_abbr_code           LIKE pldf.plan_abbr_code        --新增FEL健康給付 096/02
        ,receive_no               LIKE apdt.po_chg_rece_no
        ,tel                      LIKE addr.tel_1
                   END RECORD  
    LET f_rpt_cnt=0
    PROMPT '是否列印會計聯[y/n]' ATTRIBUTE(RED,UNDERLINE)
    FOR CHAR f_ans_sw
    IF  UPSHIFT(f_ans_sw) = 'Y' THEN                        
        LET f_rpt_cnt=3
    ELSE
        LET f_rpt_cnt=2
    END IF      

    LET f_rpt_name_1    =ReportName("psc02m01")
    
     START REPORT psc02m_notice     TO f_rpt_name_1    
       INITIALIZE r.* TO NULL

        -- 讀取pscp主檔資料 --     
        SELECT * 
        INTO   p_pscp.*
        FROM   pscp
        WHERE  policy_no     = f_policy_no
        AND    cp_anniv_date = f_cp_anniv_date
        
        -- 業務員姓名 --
        SELECT names
        INTO   r.agent_name
        FROM   clnt
        WHERE  client_id=p_pscp.agent_code

        -- 營業單位 --
        SELECT dept_name
        INTO   r.dept_name
        FROM   dept
        WHERE  dept_code=p_pscp.dept_code

        -- 繳法 --
        CASE 
            WHEN g_polf.modx="0"  
                 LET r.modx       =" 年 繳"
            WHEN g_polf.modx="1"  
                 LET r.modx       =" 月 繳"             
            WHEN g_polf.modx="3"  
                 LET r.modx       =" 季 繳"             
            WHEN g_polf.modx="6"  
                 LET r.modx       ="半年繳"             
            WHEN g_polf.modx="12"
                 LET r.modx       =" 年 繳"             
             OTHERWISE          
                 LET r.modx       ="    繳"                      
        END CASE        

        LET r.policy_no         = f_policy_no                   -- 保單號碼
        LET r.cp_anniv_date     = f_cp_anniv_date               -- 還本週年日 
        LET r.process_date      = GetDate(TODAY)                -- 處理日期
        LET r.applicant_name    = p_data_s3.app_name            -- 要保人姓名
        LET r.insured_name      = p_data_s3.insured_name        -- 被保險人姓名
        LET r.po_sts_code       = p_data_s3.po_sts_code         -- 保單狀態
        LET r.policy_no         = p_pscp.policy_no              -- 保單號碼
        LET r.face_amt          = p_pscp.face_amt               -- 保險金額
        LET r.po_issue_date     = p_pscp.po_issue_date          -- 生效日
        LET r.paid_to_date      = p_pscp.paid_to_date           -- 繳費終日
        LET r.cp_pay_form_type  = p_pscp.cp_pay_form_type       -- 給付格式
        LET r.cp_anniv_date     = p_pscp.cp_anniv_date          -- 週年日
        LET r.div_option        = p_pscp.div_option             -- 紅利選擇權
        LET r.cp_amt            = p_pscp.cp_amt                 -- 給付金額
        LET r.div_amt           = p_pscp.accumulated_div        -- 保單紅利
                                + p_pscp.div_int_balance         
                                + p_pscp.div_int        
        LET r.prem_susp         = p_pscp.prem_susp              -- 溢繳
        LET r.minus_prem_susp   = p_pscp.rtn_minus_premsusp    -- 欠繳
        LET r.apl_int           = p_pscp.rtn_apl_int            -- 自動墊繳利息
        LET r.apl_amt           = p_pscp.rtn_apl_amt            -- 自動墊繳本金
        LET r.loan_int          = p_pscp.rtn_loan_int           -- 借款利息
        LET r.loan_amt          = p_pscp.rtn_loan_amt           -- 借款本金
        LET r.cp_pay_amt        = p_pscp.cp_pay_amt             -- 應給付淨額
        LET r.rtn_rece_no       = p_pscp.rtn_rece_no            -- 還款收據號碼
        LET r.cp_pay_name       = p_data_s1.cp_pay_name[1,12]   -- 領取人姓名
        LET r.cp_pay_id         = p_data_s1.cp_pay_id           -- 領取人ID
        LET r.pay_dept_code     = p_data_s1.dept_code           -- 領取分公司
        LET r.benf_cnt          = 0
        LET r.receive_no        = f_receive_no
        
    SELECT psc_desc
      INTO r.tel
      FROM psc4
     WHERE policy_no = f_policy_no
       AND cp_anniv_date = f_cp_anniv_date
       AND psc_type = '2'
    -- 讀取險種說明 --
    SELECT plan_desc,plan_abbr_code            
    INTO   r.plan_desc,r.plan_abbr_code
    FROM   pldf
    WHERE  plan_code  = p_pscp.plan_code
    AND    rate_scale = p_pscp.rate_scale

    -- 受益人資料初值 --        
    FOR f_i=1 TO 6
        LET   benf_arr[f_i].names               = ""      -- 受益人name --
        LET   benf_arr[f_i].benf_ratio          = ""      -- 受益比例   --
        LET   benf_arr[f_i].cp_real_payamt      = ""      -- 實領金額   --
        LET   benf_arr[f_i].disb_no             = ""      -- 付款號碼   --
    END FOR

    LET f_i=0
    LET f_benf_cnt=0

    SELECT count(*)
    INTO   f_benf_cnt
    FROM   pscd
    WHERE  policy_no=r.policy_no
    AND    cp_anniv_date=r.cp_anniv_date

    LET r.benf_cnt=f_benf_cnt

    -- 讀取受益人資料 --        
    IF f_benf_cnt !=0 THEN
       LET f_i=1        
       DECLARE r_benf CURSOR FOR
       SELECT  names
              ,benf_ratio
              ,cp_real_payamt
              ,disb_no
       FROM   pscd
       WHERE  policy_no     = r.policy_no
       AND    cp_anniv_date = r.cp_anniv_date

       LET f_benf_cnt = 1
       
       FOREACH r_benf INTO benf_arr[f_benf_cnt].*
           LET f_benf_cnt = f_benf_cnt + 1
       END FOREACH
       LET f_benf_cnt=f_benf_cnt-1
    END IF      
    FOR i= 1 TO f_rpt_cnt
        OUTPUT TO REPORT psc02m_notice(r.*,i)
    END FOR
    FINISH REPORT psc02m_notice

    LET copies=SelectPrinter(f_rpt_name_1)
    IF ( copies ) THEN
       LET cmd="locprn -n",copies USING " <<< ", f_rpt_name_1
       RUN cmd
    END IF      
    LET f_rcode=1
    RETURN f_rcode              
END FUNCTION  -- psc02m_report --
------------------------------------------------------------------------------
--  函式名稱: psc02m_notice()
--  作    者: merlin
--  日    期: 
--  處理概要: 還本櫃臺作業_審查單內容
--  重要函式:
------------------------------------------------------------------------------
REPORT psc02m_notice(r,f_rpt_cnt)
    DEFINE r            RECORD
         process_date             CHAR(9) 
        ,applicant_name           LIKE clnt.names               -- 要保人姓名
        ,insured_name             LIKE clnt.names               -- 被保險人姓名
        ,po_sts_code              LIKE polf.po_sts_code         -- 保單狀態
        ,modx                     CHAR(6)                       -- 繳法
        ,plan_desc                LIKE pldf.plan_desc           -- 還本險種
        ,policy_no                LIKE pscp.policy_no           -- 保單號碼
        ,face_amt                 INTEGER                       -- 保險金額
        ,dept_name                LIKE dept.dept_name           -- 營業處代碼
        ,agent_name               LIKE clnt.names               -- 業務員代碼
        ,po_issue_date            LIKE pscp.po_issue_date       -- 生效日
        ,paid_to_date             LIKE pscp.paid_to_date        -- 繳費終日
        ,cp_pay_form_type         LIKE pscp.cp_pay_form_type    -- 給付格式
        ,cp_anniv_date            LIKE pscp.cp_anniv_date       -- 週年日
        ,div_option               LIKE pscp.div_option          -- 紅利選擇權
        ,cp_amt                   INTEGER                       -- 給付金額
        ,div_amt                  INTEGER                       -- 保單紅利
        ,prem_susp                INTEGER                       -- 溢繳
        ,minus_prem_susp          INTEGER                       -- 欠繳
        ,apl_int                  INTEGER                       -- 自動墊繳利息
        ,apl_amt                  INTEGER                       -- 自動墊繳本金
        ,loan_int                 INTEGER                       -- 借款利息
        ,loan_amt                 INTEGER                       -- 借款本金
        ,cp_pay_amt               INTEGER                       -- 應給付淨額
        ,rtn_rece_no              CHAR(10)                      -- 還款收據號碼
        ,cp_pay_name              CHAR(12)                      -- 領取人姓名
        ,cp_pay_id                LIKE pscb.cp_pay_id           -- 領取人ID
        ,pay_dept_code            LIKE pscb.dept_code           -- 領取分公司
        ,benf_cnt                 INTEGER      
        ,plan_abbr_code           LIKE pldf.plan_abbr_code      --新增FEL給付 096/02 
        ,receive_no               LIKE apdt.po_chg_rece_no
        ,tel                      LIKE addr.tel_1
                    END RECORD  
    DEFINE r_i                INTEGER  
          ,r_cpform_var       CHAR(100)
          ,f_i                INTEGER   
          ,f_rpt_cnt          INTEGER
          ,f_dept_code        LIKE dept.dept_code
          ,f_dept_name        LIKE dept.dept_name
          ,f_user_name        LIKE edp_base:usrdat.user_name
          ,f_dept_belong      LIKE dept.dept_name               
   OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    FORMAT
       PAGE HEADER
            PRINT ASCII 126, "IX10W1G2;"
            SKIP  4 LINES

       ON EVERY ROW

       SELECT dept_name
       INTO   f_dept_belong
       FROM   dept
       WHERE  dept_code=r.pay_dept_code
        
       LET f_dept_code=get_user_dept_code(g_user)       
       SELECT dept_name
       INTO   f_dept_name
       FROM   dept
       WHERE  dept_code=f_dept_code

       SELECT user_name
       INTO   f_user_name
       FROM   edp_base:usrdat
       WHERE  edp_base:usrdat.user_code = g_user

        -- 生存領取表 -- 
        IF r.cp_pay_form_type="5"   OR
           r.cp_pay_form_type="5.1" THEN
           LET r_cpform_var        = p_cpform_1[4]
           LET r_cpform_var[18,29] = r.policy_no
           LET r_cpform_var[60,68] = r.process_date
           LET p_cpform_1[4]       = r_cpform_var
           LET r_cpform_var        = p_cpform_1[5] 
           LET r_cpform_var[18,29] = r.applicant_name[1,12]
           LET r_cpform_var[60,79] = r.dept_name
           LET p_cpform_1[5]       = r_cpform_var
           LET r_cpform_var        = p_cpform_1[6]
           LET r_cpform_var[18,29] = r.insured_name[1,12]
           LET r_cpform_var[60,69] = r.agent_name
           LET p_cpform_1[6]       = r_cpform_var
           LET r_cpform_var        = p_cpform_1[7]
           LET r_cpform_var[60,67] = r.receive_no
           LET p_cpform_1[7]       = r_cpform_var
           LET r_cpform_var        = p_cpform_1[9]
           LET r_cpform_var[18,45] = r.plan_desc[1,28]
           LET r_cpform_var[62,72] = r.face_amt         USING "###,###,##&"
           LET p_cpform_1[9]       = r_cpform_var
           LET r_cpform_var        = p_cpform_1[10]
           LET r_cpform_var[18,26] = r.po_issue_date
      --   LET r_cpform_var[62,70] = r.paid_to_date
           LET p_cpform_1[10]       = r_cpform_var
           LET r_cpform_var        = p_cpform_1[11]
           LET r_cpform_var[18,26] = r.cp_anniv_date
           LET r_cpform_var[42,43] = r.po_sts_code
           LET r_cpform_var[58]    = r.div_option
           LET r_cpform_var[71,76] = r.modx
           LET p_cpform_1[11]      = r_cpform_var
           LET r_cpform_var        = p_cpform_1[14]
           IF  r.plan_abbr_code = 'FEL' THEN
               LET r_cpform_var[14,21] = '健康檢查' 
           ELSE 
               LET r_cpform_var[18,21] = '生存'
           END IF
           LET r_cpform_var[53,63] = r.cp_amt           USING "###,###,##&"
           LET p_cpform_1[14]      = r_cpform_var                       
           LET r_cpform_var        = p_cpform_1[17]
           LET r_cpform_var[53,63] = r.minus_prem_susp  USING "###,###,##&"
           LET p_cpform_1[17]      = r_cpform_var                       
           LET r_cpform_var        = p_cpform_1[18]
           LET r_cpform_var[53,63] = r.apl_int          USING "###,###,##&"
           LET p_cpform_1[18]      = r_cpform_var                       
           LET r_cpform_var        = p_cpform_1[19]
           LET r_cpform_var[53,63] = r.apl_amt          USING "###,###,##&"
           LET p_cpform_1[19]      = r_cpform_var                       
           LET r_cpform_var        = p_cpform_1[20]
           LET r_cpform_var[53,63] = r.loan_int         USING "###,###,##&"
           LET p_cpform_1[20]      = r_cpform_var                       
           LET r_cpform_var        = p_cpform_1[21]
           LET r_cpform_var[53,63] = r.loan_amt         USING "###,###,##&"
           LET p_cpform_1[21]      = r_cpform_var                       
           LET r_cpform_var        = p_cpform_1[23]
           LET r_cpform_var[53,63] = r.cp_pay_amt       USING "###,###,##&"
           LET p_cpform_1[23]      = r_cpform_var                       
           LET r_cpform_var        = p_cpform_1[25]
           LET r_cpform_var[19,28] = r.rtn_rece_no      
           LET p_cpform_1[25]      = r_cpform_var
           LET r_cpform_var        = p_cpform_1[27]
           LET r_cpform_var[17,28] = r.cp_pay_name CLIPPED
           LET r_cpform_var[42,53] = r.cp_pay_id   CLIPPED
           LET r_cpform_var[66,77] = f_dept_belong CLIPPED
           LET p_cpform_1[27]      = r_cpform_var       
           LET r_cpform_var        = p_cpform_1[28]
           LET r_cpform_var[17,28] = r.tel CLIPPED
           LET p_cpform_1[28]      = r_cpform_var     

           FOR r_i=1 TO 32
               IF r_i=2 THEN            
                  PRINT ASCII 126,"IX10W2G2;"
               END IF            
               IF r_i=3 THEN
                  PRINT ASCII 126,"IX10W1G2;"
                  SKIP 4 LINES  
               END IF
               PRINT COLUMN 1,p_cpform_1[r_i] CLIPPED           
               IF  r_i=30 THEN
                   FOR f_i=1 TO r.benf_cnt
                       PRINT COLUMN  1 ,"│"
                            ,COLUMN  6 ,f_i                         
                                        USING "#"
                            ,COLUMN 12 ,benf_arr[f_i].names CLIPPED
                            ,COLUMN 28 ,benf_arr[f_i].benf_ratio
                                        USING "###.##"
                            ,COLUMN 40 ,benf_arr[f_i].cp_real_payamt 
                                        USING "###,###,###"     
                            ,COLUMN 62 ,benf_arr[f_i].disb_no
                            ,COLUMN 79 ,"│"
                   END FOR
               END IF           
           END FOR
        END IF  

        -- 滿期領取表 --
        IF r.cp_pay_form_type="6"    OR
           r.cp_pay_form_type="6.1"  OR
           r.cp_pay_form_type="6.2"  THEN
 
           LET r_cpform_var        = p_cpform_2[4]
           LET r_cpform_var[18,29] = r.policy_no
           LET r_cpform_var[60,68] = r.process_date
           LET p_cpform_2[4]       = r_cpform_var
           LET r_cpform_var        = p_cpform_2[5] 
           LET r_cpform_var[18,29] = r.applicant_name[1,12]
           LET r_cpform_var[60,79] = r.dept_name
           LET p_cpform_2[5]       = r_cpform_var
           LET r_cpform_var        = p_cpform_2[6]
           LET r_cpform_var[18,29] = r.insured_name[1,12]
           LET r_cpform_var[60,69] = r.agent_name
           LET p_cpform_2[6]       = r_cpform_var
           LET r_cpform_var        = p_cpform_2[7]
           LET r_cpform_var[60,67] = r.receive_no
           LET p_cpform_2[7]       = r_cpform_var
           LET r_cpform_var        = p_cpform_2[9]
           LET r_cpform_var[18,45] = r.plan_desc[1,28]
           LET r_cpform_var[62,72] = r.face_amt         USING "###,###,##&"
           LET p_cpform_2[9]       = r_cpform_var
           LET r_cpform_var        = p_cpform_2[10]
           LET r_cpform_var[18,26] = r.po_issue_date
      --   LET r_cpform_var[62,70] = r.paid_to_date
           LET p_cpform_2[10]       = r_cpform_var
           LET r_cpform_var        = p_cpform_2[11]
           LET r_cpform_var[18,26] = r.cp_anniv_date
           LET r_cpform_var[42,43] = r.po_sts_code
           LET r_cpform_var[58]    = r.div_option
           LET r_cpform_var[71,76] = r.modx
           LET p_cpform_2[11]      = r_cpform_var
           LET r_cpform_var        = p_cpform_2[14]
           LET r_cpform_var[53,63] = r.cp_amt           USING "###,###,##&"
           LET p_cpform_2[14]      = r_cpform_var                       
           LET r_cpform_var        = p_cpform_2[15]
           LET r_cpform_var[53,63] = r.div_amt          USING "###,###,##&"
           LET p_cpform_2[15]      = r_cpform_var                       
           LET r_cpform_var        = p_cpform_2[16]
           LET r_cpform_var[53,63] = r.prem_susp        USING "###,###,##&"
           LET p_cpform_2[16]      = r_cpform_var                       
           LET r_cpform_var        = p_cpform_2[17]
           LET r_cpform_var[53,63] = r.minus_prem_susp  USING "###,###,##&"
           LET p_cpform_2[17]      = r_cpform_var                       
           LET r_cpform_var        = p_cpform_2[18]
           LET r_cpform_var[53,63] = r.apl_int          USING "###,###,##&"
           LET p_cpform_2[18]      = r_cpform_var                       
           LET r_cpform_var        = p_cpform_2[19]
           LET r_cpform_var[53,63] = r.apl_amt          USING "###,###,##&"
           LET p_cpform_2[19]      = r_cpform_var                       
           LET r_cpform_var        = p_cpform_2[20]
           LET r_cpform_var[53,63] = r.loan_int         USING "###,###,##&"
           LET p_cpform_2[20]      = r_cpform_var                       
           LET r_cpform_var        = p_cpform_2[21]
           LET r_cpform_var[53,63] = r.loan_amt         USING "###,###,##&"
           LET p_cpform_2[21]      = r_cpform_var                       
           LET r_cpform_var        = p_cpform_2[23]
           LET r_cpform_var[53,63] = r.cp_pay_amt       USING "###,###,##&"
           LET p_cpform_2[23]      = r_cpform_var                       
           LET r_cpform_var        = p_cpform_2[25]
           LET r_cpform_var[19,28] = r.rtn_rece_no      
           LET p_cpform_2[25]      = r_cpform_var
           LET r_cpform_var        = p_cpform_2[27]
           LET r_cpform_var[17,28] = r.cp_pay_name CLIPPED
           LET r_cpform_var[42,53] = r.cp_pay_id   CLIPPED
           LET r_cpform_var[66,77] = f_dept_belong CLIPPED
           LET p_cpform_2[27]      = r_cpform_var                      
           LET r_cpform_var        = p_cpform_2[28]
           LET r_cpform_var[17,28] = r.tel CLIPPED
           LET p_cpform_2[28]      = r_cpform_var
 
           
           FOR r_i=1 TO 32
               IF r_i=2 THEN            
                  PRINT ASCII 126,"IX10W2G2;"
               END IF            
               IF r_i=3 THEN
                  PRINT ASCII 126,"IX10W1G2;"
                  SKIP 4 LINES  
               END IF
               PRINT COLUMN 1,p_cpform_2[r_i] CLIPPED
               IF  r_i=30 THEN
                   FOR f_i=1 TO r.benf_cnt
                       PRINT COLUMN  1 ,"│"
                            ,COLUMN  6 ,f_i                         
                                        USING "#"
                            ,COLUMN 12 ,benf_arr[f_i].names CLIPPED
                            ,COLUMN 28 ,benf_arr[f_i].benf_ratio
                                        USING "###.##"
                            ,COLUMN 40 ,benf_arr[f_i].cp_real_payamt 
                                        USING "###,###,###"     
                            ,COLUMN 62 ,benf_arr[f_i].disb_no
                            ,COLUMN 79 ,"│"
                   END FOR
               END IF           
           END FOR
        END IF  

       
       LET  r_cpform_var[51,78] = "主管簽核：__________________"

       CASE 
       WHEN f_rpt_cnt=1 
            PRINT COLUMN  6, "領取人簽章："
                        PRINT COLUMN  1, "  "               
            PRINT COLUMN 40, r_cpform_var[51,78]                
            SKIP 3 LINES
            PRINT COLUMN 32, "第一聯 �  公司歸檔聯"
       WHEN f_rpt_cnt=2 
            PRINT COLUMN 40, r_cpform_var CLIPPED
            PRINT COLUMN  1, "  "               
            PRINT COLUMN  1, "  "
            SKIP 3 LINES
            PRINT COLUMN 32, "第二聯�   保戶聯"
       WHEN f_rpt_cnt=3
            PRINT COLUMN 40, r_cpform_var CLIPPED
            PRINT COLUMN  1, "  "               
            PRINT COLUMN 40, r_cpform_var[51,78]                
            SKIP 3 LINES
            PRINT COLUMN 32, "第三聯�   會計歸檔聯"
       END CASE

       PRINT COLUMN 5, ap003_barcode( "PS2090" ) CLIPPED, 2 SPACES, "PS2090"
       SKIP 1 LINES
       PRINT COLUMN 5, ap003_barcode(r.receive_no) CLIPPED,2 SPACES,r.receive_no
       SKIP 1 LINES
       PRINT COLUMN 5, ap003_barcode(r.policy_no) CLIPPED,2 SPACES,r.policy_no

       SKIP TO TOP OF PAGE      

END REPORT  -- psc02m_notice --
------------------------------------------------------------------------------
--  函式名稱: psc02m_init_array()
--  作    者: merlin
--  日    期: 
--  處理概要: 還本櫃臺作業_審查單格式
--  重要函式:
------------------------------------------------------------------------------   
FUNCTION psc02m_init_array()
        DEFINE f_rcode  INTEGER

LET p_cpform_1[1] = " "
LET p_cpform_1[2] = "               生存金領取審查表"
LET p_cpform_1[3] = "                                                           [機密文件]"
LET p_cpform_1[4] = "      保單號碼：                              日    期 ：                       "  
LET p_cpform_1[5] = "      要 保 人：                              營業單位 ：                       "  
LET p_cpform_1[6] = "      被保險人：                              業 務 員 ：                       "  
LET p_cpform_1[7] = "                                              受理號碼 ：                       "   
LET p_cpform_1[8] = "┌──────────────────────────────────────┐"
LET p_cpform_1[9] = "│  還本險種  ：                              保險金額  ：   xxx,xxx,xxx元    │"
LET p_cpform_1[10]= "│  契約生效日：                                                              │"
LET p_cpform_1[11]= "│  還本週年日： xxxxxxxxx    保單狀態： xx   紅利選擇： x     繳法： xxxxxx  │"
LET p_cpform_1[12]= "├──────────────────────────────────────┤"
LET p_cpform_1[13]= "│                                                                            │"
LET p_cpform_1[14]= "│                   保險金                         xxx,xxx,xxx元             │"
LET p_cpform_1[15]= "│                                                                            │"
LET p_cpform_1[16]= "│                                                                            │"
LET p_cpform_1[17]= "│                     扣除：前期欠繳               xxx,xxx,xxx元             │"
LET p_cpform_1[18]= "│                           自動墊繳保費利息       xxx,xxx,xxx元             │"
LET p_cpform_1[19]= "│                           自動墊繳保費本金       xxx,xxx,xxx元             │"
LET p_cpform_1[20]= "│                           保單借款利息           xxx,xxx,xxx元             │"
LET p_cpform_1[21]= "│                           保單借款本金           xxx,xxx,xxx元             │"
LET p_cpform_1[22]= "│                                                                            │"
LET p_cpform_1[23]= "│               應給付淨額                         xxx,xxx,xxx元             │"
LET p_cpform_1[24]= "│                                                                            │"
LET p_cpform_1[25]= "│  還款收據號碼：xxxxxxxxxx                                                  │"
LET p_cpform_1[26]= "│                                                                            │"
LET p_cpform_1[27]= "│  領取人姓名：xxxxxxxxxxxx   領取人ID：xxxxxxxxxx  領取分公司：xxxxxx       │"
LET p_cpform_1[28]= "│  領取人電話：xxxxxxxxxxxx                                                  │"
LET p_cpform_1[29]= "│                                                                            │"
LET p_cpform_1[30]= "│  序號   受益人姓名      比率％         給付金額           付款號碼         │"
LET p_cpform_1[31]= "│                                                                            │"
LET p_cpform_1[32]= "└──────────────────────────────────────┘"

LET p_cpform_2[1] = " "
LET p_cpform_2[2] = "               滿期金領取審查表"
LET p_cpform_2[3] = ""
LET p_cpform_2[4] = "      保單號碼：                              日    期 ：                       "  
LET p_cpform_2[5] = "      要 保 人：                              營業單位 ：                       "
LET p_cpform_2[6] = "      被保險人：                              業 務 員 ：                       "
LET p_cpform_2[7] = "                                              受理號碼 ：                       " 
LET p_cpform_2[8] = "┌──────────────────────────────────────┐"
LET p_cpform_2[9] = "│  還本險種  ：                              保險金額  ：   xxx,xxx,xxx元    │"
LET p_cpform_2[10]= "│  契約生效日：                                                              │"
LET p_cpform_2[11]= "│  還本週年日： xxxxxxxxx    保單狀態： xx   紅利選擇： x     繳法： xxxxxx  │"
LET p_cpform_2[12]= "├──────────────────────────────────────┤"
LET p_cpform_2[13]= "│                                                                            │"
LET p_cpform_2[14]= "│               滿期保險金                         xxx,xxx,xxx元             │"
LET p_cpform_2[15]= "│                       加：保單紅利               xxx,xxx,xxx元             │"
LET p_cpform_2[16]= "│                           溢繳                   xxx,xxx,xxx元             │"
LET p_cpform_2[17]= "│                     扣除：前期欠繳               xxx,xxx,xxx元             │"
LET p_cpform_2[18]= "│                           自動墊繳保費利息       xxx,xxx,xxx元             │"
LET p_cpform_2[19]= "│                           自動墊繳保費本金       xxx,xxx,xxx元             │"
LET p_cpform_2[20]= "│                           保單借款利息           xxx,xxx,xxx元             │"
LET p_cpform_2[21]= "│                           保單借款本金           xxx,xxx,xxx元             │"
LET p_cpform_2[22]= "│                                                                            │"
LET p_cpform_2[23]= "│               應給付淨額                         xxx,xxx,xxx元             │"
LET p_cpform_2[24]= "│                                                                            │"
LET p_cpform_2[25]= "│  還款收據號碼：xxxxxxxxxx                                                  │"
LET p_cpform_2[26]= "│                                                                            │"
LET p_cpform_2[27]= "│  領取人姓名：xxxxxxxxxxxx   領取人ID：xxxxxxxxxx  領取分公司：xxxxxx       │"
LET p_cpform_2[28]= "│  領取人電話：xxxxxxxxxxxx                                                  │"
LET p_cpform_2[29]= "│                                                                            │"
LET p_cpform_2[30]= "│  序號   受益人姓名      比率％         給付金額           付款號碼         │"
LET p_cpform_2[31]= "│                                                                            │"
LET p_cpform_2[32]= "└──────────────────────────────────────┘"

LET f_rcode=1
RETURN f_rcode
END FUNCTION  -- psc02m_init_array --
------------------------------------------------------------------------------
--  函式名稱: psc02m_inoput1()
--  作    者: merlin
--  日    期: 
--  處理概要: 還本櫃臺作業_報表條件輸入
--  重要函式:
------------------------------------------------------------------------------  
FUNCTION psc02m_input1()
    DEFINE f_right_or_fault     INTEGER   -- 日期檢查 t or f --
          ,f_formated_date      CHAR(9)   -- 日期格式化 999/99/99 --
          ,f_pscb_cnt           INTEGER   -- 執行 perpare 指令有保單可執行 --
          ,f_rcode              INTEGER
        
    DEFINE f_dept_code          LIKE pscb.dept_code
          ,f_start_date         CHAR(9)

    LET f_rcode         = 0             
    LET INT_FLAG        = FALSE
    LET f_pscb_cnt      = 0
    LET f_dept_code     = " "
    LET f_start_date    = " "
        
    MESSAGE " END(F7):取消作業"

    OPEN WINDOW psc02m02   AT 10,11 WITH FORM "psc02m02"        
    ATTRIBUTE(BLUE, REVERSE, UNDERLINE, FORM LINE FIRST)

    INPUT f_dept_code,f_start_date
    FROM  dept_code,start_date   ATTRIBUTE(BLUE ,REVERSE ,UNDERLINE)

    AFTER FIELD dept_code
       IF f_dept_code=" "             OR
          f_dept_code="            "  THEN
          ERROR "領取地點必須輸入!!"  ATTRIBUTE (RED)
          NEXT FIELD dept_code
       END IF

    AFTER FIELD start_date
       CALL CheckDate(f_start_date)
            RETURNING f_right_or_fault,f_formated_date
       IF f_right_or_fault = false THEN
          ERROR "日期輸入錯誤!!"   ATTRIBUTE (RED)
          NEXT FIELD start_date
       END IF

       IF f_start_date="         " OR
          f_start_date=" "         THEN
          ERROR "日期必須輸入!!"   ATTRIBUTE (RED)
          NEXT FIELD f_start_date
       END IF

    ON KEY (F7)
       LET INT_FLAG=TRUE
       EXIT INPUT
    AFTER INPUT

    IF INT_FLAG=TRUE THEN
       EXIT INPUT
    END IF
     
    END INPUT

  CLOSE WINDOW psc02m02

    MESSAGE " "
    -- 中斷作業 --
    IF INT_FLAG=TRUE THEN
       LET f_rcode=1
       RETURN f_rcode,f_dept_code,f_start_date
    END IF

    RETURN f_rcode ,f_dept_code,f_start_date

END FUNCTION    --- psc02m_input1 ---
------------------------------------------------------------------------------
--  函式名稱: psc02m_report2()
--  作    者: merlin
--  日    期: 
--  處理概要: 還本櫃臺作業_已領取報表
--  重要函式:
------------------------------------------------------------------------------
FUNCTION psc02m_report2(f_dept_code,f_start_date)
    DEFINE f_start_date          CHAR(9)
          ,f_dept_code           LIKE pscb.dept_code
          ,f_rcode               INTEGER
          ,f_i                   INTEGER          
          ,f_rpt_name_2          CHAR(30)
          ,f_pscb_cnt            INTEGER
          ,f_agent_name          LIKE clnt.names
          ,f_dept_name           LIKE dept.dept_name 
          ,f_expired_sw          CHAR(4)
          ,cmd                   CHAR(900)
          ,copies                INTEGER

    DEFINE r1           RECORD 
         policy_no                LIKE pscb.policy_no           -- 保單號碼
        ,cp_anniv_date            LIKE pscb.cp_anniv_date       -- 保單週年日
        ,cp_sw                    LIKE pscb.cp_sw               -- 還本指示
        ,process_user             LIKE pscb.process_user        -- 承辦人
        ,change_date              LIKE pscb.change_date         -- 作帳日
        ,cp_pay_name              LIKE pscb.cp_pay_name         -- 領取人姓名
        ,dept_code                LIKE pscb.dept_code           -- 領取分公司
        ,cp_disb_type             LIKE pscb.cp_disb_type        -- 還本給付方式
        ,agent_code               LIKE pscp.agent_code          -- 業務員代碼
        ,cp_amt  	          INTEGER                       -- 應給付金額
        ,cp_pay_amt               INTEGER                       -- 應給付淨額
        ,cp_pay_form_type         LIKE pscp.cp_pay_form_type    -- 還本給付書格式
                    END RECORD  

        LET r1.policy_no                = " "           -- 保單號碼
        LET r1.cp_anniv_date            = " "           -- 還本週年日
        LET r1.cp_sw                    = " "           -- 還本指示
        LET r1.process_user             = " "           -- 承辦人
        LET r1.change_date              = " "           -- 作帳日
        LET r1.agent_code               = " "           -- 業務員代碼
        LET r1.cp_pay_amt               = 0             -- 應給付淨額
        LET r1.cp_pay_name              = " "           -- 領取人姓名
        LET r1.dept_code                = " "           -- 領取分公司
        LET r1.cp_pay_form_type         = ""            -- 還本給付書格式
        
        LET f_rpt_name_2    = ReportName("psc02m02")
        LET f_pscb_cnt      = 0
        LET f_agent_name    = ""
        LET f_dept_name     = ""
        LET f_expired_sw    = ""

        SELECT count(*) 
        INTO   f_pscb_cnt
        FROM   pscb
        WHERE  change_date = f_start_date 
        AND    cp_sw in (2,5,6)
        AND    dept_code=f_dept_code 
        AND    cp_disb_type="1"

        IF f_pscb_cnt =0 THEN
           ERROR "無已領取資料"         
        ELSE
           -- 讀取領取地點名稱 --
           SELECT  dept_name
           INTO    f_dept_name
           FROM    dept
           WHERE   dept_code=f_dept_code
                
           -- 讀取以領取資料 --
           DECLARE r1_cur CURSOR FOR
           SELECT cb.policy_no,cb.cp_anniv_date,cb.cp_sw,
                  cb.process_user,cb.change_date,cb.cp_pay_name,
                  cb.dept_code,cb.cp_disb_type,
                  cp.agent_code,cp.cp_amt,cp.cp_pay_amt,cp.cp_pay_form_type
           FROM   pscb cb,pscp cp 
           WHERE  cb.policy_no    = cp.policy_no
           AND    cb.cp_anniv_date= cp.cp_anniv_date
           AND    cb.change_date  = f_start_date 
           AND    cb.dept_code    = f_dept_code 
           AND    cb.cp_disb_type = "1"
           AND    cb.cp_sw in ("2","5","6")
           ORDER BY cb.cp_anniv_date

           START REPORT psc02m_notice1 TO f_rpt_name_2                  
        
           FOREACH r1_cur INTO r1.*
           -- 業務員姓名 --
           SELECT names
           INTO   f_agent_name
           FROM   clnt
           WHERE  client_id=r1.agent_code

           -- 判斷滿期  
           CASE
                WHEN r1.cp_pay_form_type = "5"
                     LET f_expired_sw    = "生存"
                WHEN r1.cp_pay_form_type = "5.1"
                     LET f_expired_sw    = "生存"
                WHEN r1.cp_pay_form_type = "6"
                     LET f_expired_sw    = "滿期"
                WHEN r1.cp_pay_form_type = "6.1"
                     LET f_expired_sw    = "滿期"
                WHEN r1.cp_pay_form_type = "6.2"
                     LET f_expired_sw    = "滿期"
           END CASE
        
           OUTPUT TO REPORT psc02m_notice1(r1.*
                                         ,f_start_date
                                         ,f_dept_code
                                         ,f_agent_name
                                         ,f_dept_name
                                         ,f_expired_sw)
        
           END FOREACH
           FREE r1_cur

           FINISH REPORT psc02m_notice1

           LET copies=SelectPrinter(f_rpt_name_2)
           IF  copies THEN
               LET cmd="locprn -n",copies USING " <<< ", f_rpt_name_2
               RUN cmd
           END IF
        END IF
            
        LET f_rcode=1
    RETURN f_rcode              
END FUNCTION  -- psc02m_report2 --

------------------------------------------------------------------------------
--  函式名稱: psc02m_notice1()
--  作    者: merlin
--  日    期: 
--  處理概要: 還本櫃臺作業_已領取控制報表內容
--  重要函式:
------------------------------------------------------------------------------
REPORT psc02m_notice1(r1,f_start_date,f_dept_code
                     ,f_agent_name,f_dept_name,f_expired_sw)
    DEFINE r1           RECORD
         policy_no                LIKE pscb.policy_no           -- 保單號碼
        ,cp_anniv_date            LIKE pscb.cp_anniv_date
        ,cp_sw                    LIKE pscb.cp_sw               -- 還本指示
        ,process_user             LIKE pscb.process_user        -- 承辦人
        ,change_date              LIKE pscb.change_date         -- 作帳日
        ,cp_pay_name              LIKE pscb.cp_pay_name         -- 領取人姓名
        ,dept_code                LIKE pscb.dept_code           -- 領取分公司
        ,cp_disb_type             LIKE pscb.cp_disb_type
        ,agent_code               LIKE pscp.agent_code          -- 業務員代碼
        ,cp_amt                   INTEGER                       -- 應給付金額
        ,cp_pay_amt               INTEGER                       -- 應給付淨額
        ,cp_pay_form_type         LIKE pscp.cp_pay_form_type
                    END RECORD  

    DEFINE f_start_date           CHAR(9)
          ,f_dept_code            LIKE pscb.dept_code
          ,f_agent_name           LIKE clnt.names
          ,f_dept_name            LIKE dept.dept_name
          ,f_expired_sw           CHAR(4)       

    DEFINE r_i                    INTEGER  
          ,r_cpform_var           CHAR(100)
          ,f_i                    INTEGER       
          ,r_page_cnt             INTEGER
          ,r_total_cnt            INTEGER
          ,r_sum_1                INTEGER
          ,r_sum_2                INTEGER

   OUTPUT
       TOP    OF PAGE "^L"
       PAGE   LENGTH  66
       LEFT   MARGIN   0
       TOP    MARGIN   0
       BOTTOM MARGIN   0

    FORMAT
       PAGE HEADER          
         IF PAGENO=1 THEN
            LET r_page_cnt  = 0
            LET r_total_cnt = 0
            LET r_sum_1     = 0 
	    LET r_sum_2	    = 0
         END IF

             PRINT ASCII 126, "IX10W1;"
             SKIP 2 LINES
             PRINT COLUMN  17,"還 本 櫃 臺 作 業 __ 還 本 金 已 領 取 報 表"
             PRINT COLUMN  64,p_name CLIPPED
             SKIP 1 LINES                       
             PRINT COLUMN   1, "印表日期： ", GetDate(TODAY),
                   COLUMN  64, "報表代碼： ","PSC02M"
             PRINT COLUMN   1, "作業日期： ",f_start_date,
                   COLUMN  22, "領取地點： ",f_dept_name CLIPPED ,f_dept_code,
                   COLUMN  64, "第 "   , PAGENO USING "####"," 頁"
             PRINT SetLine( "-",80 ) CLIPPED
             PRINT COLUMN   2, "保單號碼",   
                   COLUMN  15, "還本週年日",		
                   COLUMN  28, "應領金額",
                   COLUMN  39, "實領金額",
                   COLUMN  48, "領取人",
                   COLUMN  57, "業務員",
                   COLUMN  66, "承辦人",
                   COLUMN  75, "型態"
             PRINT SetLine( "-",80 ) CLIPPED            

       ON EVERY ROW
             PRINT COLUMN   2, r1.policy_no,
                   COLUMN  16, r1.cp_anniv_date,
                   COLUMN  26, r1.cp_amt      USING"##,###,##&" ,
                   COLUMN  37, r1.cp_pay_amt  USING"##,###,##&" ,
                   COLUMN  48, r1.cp_pay_name[1,8],
                   COLUMN  57, f_agent_name[1,8],
                   COLUMN  66, r1.process_user[1,8],
                   COLUMN  75, f_expired_sw
              
        LET r_page_cnt =r_page_cnt+1
        LET r_total_cnt=r_total_cnt+1
        LET r_sum_1    =r1.cp_amt+r_sum_1
        LET r_sum_2    =r1.cp_pay_amt+r_sum_2

               IF r_page_cnt > 50 THEN
                  SKIP TO TOP OF PAGE
                  LET r_page_cnt=0
               END IF

   ON LAST ROW
      PRINT COLUMN  1," "
      PRINT COLUMN  1,"件數：",r_total_cnt USING "###,##&","件",
            COLUMN 18,"應領金額合計：",r_sum_1 USING "###,###,##&" ," 元",
            COLUMN 50,"實領金額合計：",r_sum_2 USING "###,###,##&" ," 元"    
END REPORT
{
 保單號碼     還本週年日   應領金額   實領金額 領取人   業務員   承辦人   型態
 123456789012  123456789 12,345,678 12,345,678 12345678 12345678 12345678 1234
}

FUNCTION Fatca_message()
   DEFINE f_benf       RECORD LIKE benf.*
   DEFINE f_app_id     LIKE clnt.client_id
   DEFINE f_app_names  LIKE clnt.names
   DEFINE f_relation   LIKE benf.relation
   DEFINE f_ans        CHAR(1) 

   CALL getNames(p_policy_no,'O1') RETURNING f_app_id, f_app_names
   IF p_data_s1.expired_sw = "Y" THEN 
      LET f_relation = "M"
   ELSE 
      LET f_relation = "L"
   END IF 
   DECLARE benf_cur1 CURSOR WITH HOLD FOR 
      SELECT    * 
      FROM      benf 
      WHERE     policy_no = p_policy_no 
      AND       relation  = f_relation 
   FOREACH benf_cur1 INTO f_benf.*
      IF f_benf.client_id = f_app_id THEN 
         CONTINUE FOREACH 
      END IF 
      IF needFatcaSw( f_benf.client_id ) THEN 
         WHILE TRUE
            PROMPT "請確認保戶是否填具FATCA聲明書!!Y/N" FOR CHAR f_ans
            IF UPSHIFT( f_ans ) = "Y" OR 
               UPSHIFT( f_ans ) = "N" THEN
               EXIT WHILE 
            END IF 
         END WHILE 
         EXIT FOREACH
      END IF 
   END FOREACH -- benf_cur END 
    
END FUNCTION -- Fatca_message END 

FUNCTION needFatcaSw( f_id )
   DEFINE f_id        CHAR(10)
   DEFINE f_clnt      RECORD LIKE clnt.*

   IF f_id = " "    OR
      f_id IS NULL  THEN
      RETURN 1
   END IF
   INITIALIZE f_clnt TO NULL
   SELECT  *
   INTO    f_clnt.*
   FROM    clnt
   WHERE   client_id = f_id
   IF STATUS = NOTFOUND THEN
      RETURN 1
   END IF
   IF f_clnt.fatca_ind = " " OR f_clnt.fatca_ind = "1" THEN
      RETURN 1
   END IF
   RETURN 0

END FUNCTION --needFatcaSw END
