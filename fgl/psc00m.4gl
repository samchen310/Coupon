------------------------------------------------------------------------------
--  程式名稱: psc00m.4gl
--  作    者: jessica Chang
--  日    期: 089/01/06
--  處理概要: 還本通知回覆作業
--  重要函式:
------------------------------------------------------------------------------
--  新版的還本回覆作業:有照會與給付
------------------------------------------------------------------------------
--  089/11/21新增板橋(92000)、彰化行政中心(9A000)
------------------------------------------------------------------------------
--  修改者:JC
--  090/04/25:修改受益人名字的找法,有id 找clnt,否則顯示 benf 的 names
------------------------------------------------------------------------------
--  修改者:merlin
--  090/05/22:屏東行政中心(98000)獨立作業，不歸屬於高雄分公司(97000)
------------------------------------------------------------------------------
--  修  改:JC 090/07/20 SR:PS90655S 配合修改,畫面多一個保單狀態
--         給付方式為 "抵繳保費" ,要執行容芳程式,記錄其它張保單
--         注意:若從 "抵繳" 改為 其它方式,資料必須做處理
--              po_sts < 50 才可以抵繳,執行 pc961_process 傳入 p_pc961_data
--         define p_pc961_data record 程式放在 pc961p0.4gl 中
--                prss_code:EDIT=編輯,SAVE=存檔,DELE=刪除,PASS=過帳,QURY=查詢
------------------------------------------------------------------------------
--  修改者:kobe
--  091/04/11:未回領取也會新增至pscn
------------------------------------------------------------------------------
--  修改者:kobe
--  091/11/16:未回領取會記錄log於psck檔
------------------------------------------------------------------------------
--  修改者:kobe
--  092/01/22:(1)新增畫面 psc00m00 還款欄位
--            (2)回覆程序中, 文件不齊件選完後可直接列印
------------------------------------------------------------------------------
--  修改者:kurt
--  095/05/26:新增給付回覆項目
------------------------------------------------------------------------------
--  修改者:yirong
--  095/12/29:新增抵繳保費回覆條件,需求PS95I99S
------------------------------------------------------------------------------
--  修改者:yirong
--  098/03/24:新增回覆方式６為回流專案
------------------------------------------------------------------------------
--  修改者:JUCHUN
--  100/03/31:配合外幣還本進行修正
------------------------------------------------------------------------------
--  修改者:JUCHUN
--  101/02/20:修正bug:回覆時切換外幣/台幣保單，需先重新開啟FORM
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--  修改者:yirong
--  101/09/06:新增櫃台領取可以即時過帳呼叫psc30s01
------------------------------------------------------------------------------
--  修改者:cmwang SR130800093
--  102/08/06:未回領取於psck新增一筆資料，新增nonresp_sw_add()
------------------------------------------------------------------------------
--  修改者:yirong
--  102/10/04:取消6滿期回流選項
------------------------------------------------------------------------------
--  修改者:cmwang
--  103/12/23:新增p_upd_psck，將upd_psck動作放入psc01m_save_data
-----------------------------------------------------------------------------
--  修改者:cmwang 
--  104/01/19:於執行整批未回領取時留下log至pscba，晚上psc96b.4gl執行產出比對報表
----------------------------------------------------------------------------
--  修改者: pyliu(還有psca02m沒改到喔！→done)昱傑說關鍵字用結案找！
--  105/01/28 SR151200331:受益人無資料時卡住
----------------------------------------------------------------------------
--  修改者: JUCHUN
--  105/04/01 月給付險種只能回覆 0:郵寄支票,3:電 匯,4:未回領取
----------------------------------------------------------------------------
--  修改者: JUCHUN
--  105/07/06 新增9B000中正分公司
----------------------------------------------------------------------------
--  修  改:JUCHUN
--  105/07/20 避免月給付險種變更後，險種判斷錯誤
--            若已存在pscp,就用pscp紀錄的險種判斷 
--            否則,用保單目前險種來判斷 
-------------------------------------------------------------------------------

GLOBALS "../def/common.4gl"
GLOBALS "../def/lf.4gl"
GLOBALS "../def/pscgcpn.4gl"
GLOBALS "../def/report.4gl"
GLOBALS "../def/ia.4gl"
GLOBALS "../def/ptinface.4gl"
GLOBALS "../def/disburst.4gl"
GLOBALS "../def/pscgchk.4gl"

DATABASE life

    DEFINE p_space           CHAR(20)
          ,p_bell            CHAR
          ,p_tx_date         CHAR(9)   -- 作帳日期 --
          ,p_tran_date       CHAR(9)   -- 交易日期 --
          ,p_pass_or_deny    INTEGER   -- 權限檢核 --

    DEFINE p_pscb           RECORD LIKE pscb.*
    DEFINE p_policy_no           LIKE polf.policy_no
          ,p_cp_anniv_date       LIKE pscb.cp_anniv_date
          ,p_po_sts_code         LIKE polf.po_sts_code
          ,p_benf_relation       CHAR(1)
          ,p_act_return_date     CHAR(9)
          ,p_cp_notice_code      CHAR(1)
          ,p_cp_notice_dif_code  CHAR(1)
          ,p_dif_code_desc       CHAR(30)
          ,p_cp_notice_sub_code  CHAR(1)
          ,p_notice_desc         CHAR(1024) -- 缺文件的內容 --
          ,p_notice_desc_len     INTEGER    -- 缺文件內容的長度 --
          ,p_notice_desc_1       CHAR(30)
          ,p_notice_desc_2       CHAR(30)
          ,p_notice_desc_3       CHAR(30)
          ,p_notice_desc_4       CHAR(30)
          ,p_notice_desc_5       CHAR(30)
          ,p_notice_desc_6       CHAR(30)
          ,p_notice_desc_7       CHAR(30)

    DEFINE p_pscg ARRAY[7]  OF RECORD
           input_desc            CHAR(30)
                           END RECORD

    DEFINE p_pscg_notice_desc_1  CHAR(30)
          ,p_pscg_notice_desc_2  CHAR(30)
          ,p_pscg_notice_desc_3  CHAR(30)
          ,p_pscg_notice_desc_4  CHAR(30)
          ,p_pscg_notice_desc_5  CHAR(30)
          ,p_pscg_notice_desc_6  CHAR(30)
          ,p_pscg_notice_desc_7  CHAR(30)

    DEFINE p_dif ARRAY [99]  OF RECORD
           cp_notice_dif_code LIKE pscf.cp_notice_dif_code
          ,dif_code_desc      LIKE pscf.cp_dif_code_desc
                            END RECORD

    DEFINE p_applicant_id     LIKE clnt.client_id
          ,p_applicant_name   LIKE clnt.names
          ,p_tel_1            LIKE addr.tel_1
          ,p_tel_2            LIKE addr.tel_2
          ,p_coverage_no      LIKE colf.coverage_no
          ,p_benf_cnt         INTEGER
          ,p_pce_param        CHAR(1)
          ,p_old_cp_disb_type CHAR(1)
          ,p_cp_sw            CHAR(1)

    DEFINE p_pc961_sw        SMALLINT
          ,p_pc961_msg       CHAR(78)

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
    -- 還本抵繳保費與收費配合 --
    DEFINE p_pcps    RECORD LIKE pcps.* 
    DEFINE ans       CHAR(1)

    -- 畫面一上半部的資料 --
    DEFINE p_data_s1 RECORD -- screen s1 -- 
           policy_no         LIKE polf.policy_no
          ,po_sts_code       LIKE polf.po_sts_code
          ,cp_anniv_date     LIKE pscp.cp_anniv_date
          ,po_chg_rece_no    LIKE apdt.po_chg_rece_no
          ,cp_disb_type      LIKE pscb.cp_disb_type
          ,mail_addr_ind     LIKE pscb.mail_addr_ind
          ,disb_special_ind  LIKE pscb.disb_special_ind
	  ,cp_rtn_sw	     LIKE pscb.cp_rtn_sw
          ,cp_pay_name       CHAR(12)
          ,cp_pay_id         CHAR(10)
	  ,dept_name	     CHAR(18)
--          ,dept_code         CHAR(6)
                 END RECORD
    -- 取消第一部份欄位仍所需的變數 --
    DEFINE p_dept_code	     LIKE dept.dept_code

    -- 畫面一第三部份資料 --
    DEFINE p_data_s3 RECORD
           psck_sw           CHAR(1)                 -- 還本註記 --
	  ,overloan_desc     CHAR(1)		     -- OVERLOAN 指示 --
	  ,notice_resp_desc  CHAR(1)		     -- 回覆指示 --
          ,app_name          CHAR(12)                -- 要保人   --
	  ,app_id	     CHAR(10)		     -- 要保人id --
          ,insured_name      CHAR(12)                -- 被保人   --
          ,insured_id	     CHAR(10)		     -- 被保人id --
                 END RECORD

    -- 取消第三部份欄位仍所需的變數 --
    DEFINE p_agent_code	     LIKE agnt.agent_code    -- 業務員   --
          ,p_dept_code_1     LIKE dept.dept_code     -- 營業單位 --

    -- 畫面二 detail 資料 --
    DEFINE p_data_s2 ARRAY[99] OF RECORD           -- 受益人情形 --
           client_id           LIKE benf.client_id
          ,benf_ratio          LIKE benf.benf_ratio
          ,remit_bank          LIKE benf.remit_bank     -- 受益人   --
          ,remit_branch        LIKE benf.remit_branch   -- 匯款分行 --
          ,remit_account       LIKE benf.remit_account  -- 分配率   --
          ,benf_order          LIKE benf.benf_order     -- 匯款銀行 --
          ,names               LIKE benf.names          -- 受益人姓名 --
                 END RECORD

    DEFINE p_data_s2_b ARRAY[99] OF RECORD
           bank_name           LIKE bank.bank_name           --銀行名稱--
           END RECORD

    DEFINE p_data_s21 ARRAY[99] OF RECORD           -- 受益人情形-1 --
           mail_addr_ind       LIKE ptpc.mail_addr_ind
          ,pay_method          LIKE ptpc.pay_method
                 END RECORD
 
    DEFINE p_pscs              RECORD LIKE pscs.*       -- 電匯特殊指示 --
    DEFINE p_benf    ARRAY[99] OF RECORD           -- 受益人情形 --
           client_id           LIKE benf.client_id
          ,benf_ratio          LIKE benf.benf_ratio     -- 分配比率 --
          ,remit_bank          LIKE benf.remit_bank     -- 匯款銀行 --
          ,remit_branch        LIKE benf.remit_branch   -- 匯款分行 --
          ,remit_account       LIKE benp.bank_account_e -- 匯款帳號 --  100/03/31 MODIFY 原benf.remit_account 
          ,benf_order          LIKE benf.benf_order     -- 順序     --
          ,names               LIKE benf.names          -- 受益人   --
          ,bank_name           LIKE bank.bank_name           --銀行名稱--
                 END RECORD
   
   
    
    DEFINE p_addr ARRAY[10]    OF RECORD
           addr_ind            LIKE addr.addr_ind
          ,zip_code            LIKE addr.zip_code
          ,tel_1               LIKE addr.tel_1
          ,tel_2               LIKE addr.tel_2
          ,fax                 LIKE addr.fax
          ,address             LIKE addr.address
                 END RECORD
    DEFINE p_po_chg  ARRAY[20] OF RECORD
           po_chg_rece_no   LIKE apdt.po_chg_rece_no
          ,po_chg_rece_date LIKE apdt.po_chg_rece_date 
          ,po_chg_sts_code  LIKE apdt.po_chg_sts_code   --09
                 END RECORD

    --------------------------------------------------------------------------
    -- p_sel_sw=1:回覆,2:筆數未回,3:整批未回覆,4:給付修改,5:照會單列印
    --------------------------------------------------------------------------
    DEFINE p_sel_sw          CHAR(1)
    DEFINE p_pt_sw             CHAR(1) ----pt指示
    DEFINE f_rtn               CHAR(1)
    DEFINE p_po_chg_rece_no   LIKE apdt.po_chg_rece_no
    DEFINE p_apdt_exist CHAR(1)
    DEFINE p_po_chg_cnt                   SMALLINT
    DEFINE p_relation   CHAR(1)
    DEFINE p_benf_cnt1   INT
    DEFINE p_online_prc CHAR(1)  --101/09線上過帳指示yirong
    DEFINE p_tel_3      LIKE addr.tel_1
    DEFINE p_psbh_cnt   INT
    
    --100/03/31 ADD                                   
    DEFINE p_benp_ext  ARRAY[99] OF RECORD 
            payee               LIKE dbdd.payee              -- 受款人(英)    
           ,remit_swift_code    LIKE dbdd.remit_swift_code   -- 匯款銀行swift code
           ,remit_bank_name     LIKE dbdd.remit_bank_name    -- 匯款銀行英文名稱
           ,remit_bank_address  LIKE dbdd.remit_bank_address -- 匯款銀行地址  
           END RECORD 
    
    DEFINE p_data_s2_c ARRAY[99] OF RECORD
            payee               LIKE dbdd.payee              -- 受款人(英)    
           ,remit_swift_code    LIKE dbdd.remit_swift_code   -- 匯款銀行swift code 
           ,remit_bank_name     LIKE dbdd.remit_bank_name    -- 匯款銀行英文名稱 
           ,remit_bank_address  LIKE dbdd.remit_bank_address -- 匯款銀行地址  
           END RECORD       
    -- 100/03/31 END 
    DEFINE p_cmd     CHAR(100)
    DEFINE p_cp_pay_amt  LIKE pscr.cp_pay_amt
    DEFINE p_cp_amt      LIKE pscr.cp_amt   
    DEFINE p_upd_psck    CHAR(1)

-- 主程式 --
MAIN

    OPTIONS
        INSERT  KEY  F35
      , DELETE  KEY  F36
      , ERROR   LINE LAST 
      , PROMPT  LINE LAST - 2 
      , MESSAGE LINE LAST - 1 
      , COMMENT LINE LAST

    DEFER INTERRUPT
    SET LOCK MODE TO WAIT

    LET g_program_id ="psc00m"
    LET p_space      =" "
    LET p_bell       =ASCII 7
    LET p_tx_date    =GetDate(TODAY)
    LET p_tran_date  =GetDate(TODAY)
    LET p_pt_sw      ='0'

    -- 顯示第一畫面 --
    OPEN FORM psc00m00 FROM "psc00m00"
    DISPLAY FORM psc00m00 ATTRIBUTE (GREEN)

    CALL ShowLogo()
    -- JOB  CONTROL beg --
    CALL JobControl()

    MENU "請選擇"

        BEFORE MENU  
            IF  NOT CheckAuthority( "1", FALSE )  THEN
                HIDE OPTION "1)回覆"
            END IF
            {
            IF  NOT CheckAuthority( "2", FALSE )  THEN
                HIDE OPTION "2)未回覆領取"
            END IF
            }
            IF  NOT CheckAuthority( "3", FALSE )  THEN
                HIDE OPTION "3)整批未回覆領取"
            END IF
            IF  NOT CheckAuthority( "4", FALSE )  THEN
                HIDE OPTION "4)修改給付內容"
            END IF
            IF  NOT CheckAuthority( "5", FALSE )  THEN
                HIDE OPTION "5)照會單列印"
            END IF
            IF  NOT CheckAuthority( "6", FALSE )  THEN
                HIDE OPTION "6)未回領取回覆作業"
            END IF
            IF  NOT CheckAuthority( "7", FALSE )  THEN
                HIDE OPTION "7)照會補件"
            END IF
            IF  NOT CheckAuthority( "8", FALSE )  THEN
                HIDE OPTION "8)退件"
            END IF
            IF  NOT CheckAuthority( "9", FALSE )  THEN
                HIDE OPTION "9)退件一"
            END IF   
            IF  NOT CheckAuthority( "10", FALSE )  THEN
                HIDE OPTION "10)退件二”
            END IF 
            IF  NOT CheckAuthority( "11", FALSE )  THEN
                HIDE OPTION "11)照會一"
            END IF



        COMMAND "1)回覆"
            LET  p_sel_sw="1"
            CALL psc00m_init()
            CALL psc00m_sel_1()

        {
        COMMAND "2)未回覆領取"
            LET  p_sel_sw="2"
            CALL psc00m_init()
            CALL psc00m_sel_2()
        }

        COMMAND "3)整批未回覆領取"
            LET  p_sel_sw="3"
            CALL psc00m_sel_3()

        COMMAND "4)修改給付內容"
            LET  p_sel_sw="4"
            CALL psc00m_sel_4()

        COMMAND "5)照會單列印"
            LET  p_sel_sw="5"
	    CALL psc00m_init()
            CALL psc00m_sel_5()
        COMMAND "6)未回領取回覆作業"
            LET p_cmd = "psca02m.4ge "  
            RUN p_cmd

        COMMAND "7)照會補件"
            LET p_cmd = "ap003m.4ge "
            RUN p_cmd

        COMMAND "8)退件"
            LET p_cmd = "ap002p.4ge "
            RUN p_cmd


        COMMAND "0)結束"
            EXIT MENU
        END MENU 

    CLOSE FORM psc00m00

    OPTIONS
       INSERT KEY F1
     , DELETE KEY F2

    -- JOB  CONTROL beg --
    CALL JobControl()

END MAIN -- 主程式結束 --
------------------------------------------------------------------------------
--   psc00m_init
--  作    者: jessica Chang
--  日    期: 089/01/06
--  處理概要: 程式變數 initialize
--  重要函式:
------------------------------------------------------------------------------
FUNCTION psc00m_init()
    DEFINE f_rcode INTEGER
    DEFINE f_i     INTEGER
    LET f_rcode=0

    LET p_policy_no          =""
    LET p_cp_anniv_date      =""
    LET p_po_sts_code        =""
    LET p_benf_relation      =""
    LET p_act_return_date    =""
    LET p_cp_notice_code     =""
    LET p_cp_notice_dif_code =""
    LET p_dif_code_desc      =""
    LET p_cp_notice_sub_code =""
    LET p_apdt_exist         =""
    LET p_po_chg_rece_no     =""
    LET p_upd_psck           =""
    INITIALIZE p_pc961_data.* TO NULL

    FOR f_i=1 TO 20
        LET p_po_chg[f_i].po_chg_rece_no = ''
        LET p_po_chg[f_i].po_chg_rece_date  = '' 
        LET p_po_chg[f_i].po_chg_sts_code = ''
    END FOR

     
    RETURN

END FUNCTION -- psc00m_init --
------------------------------------------------------------------------------
--  函式名稱: psc00m_sel_1
--  作    者: jessica Chang
--  日    期: 089/01/06
--  處理概要: 選擇處理還本保單回覆
--  重要函式:
------------------------------------------------------------------------------
FUNCTION  psc00m_sel_1()
    DEFINE f_rcode           INTEGER

    DEFINE f_polf_exist      INTEGER  -- 保單檢核 --
          ,f_pscb_exist      INTEGER  -- 還本檔檢核 --
          ,f_pscn_exist      INTEGER  -- 是否再次進行回覆 --
          ,f_chkdate_sw      INTEGER  -- 日期檢核 --
          ,f_format_date     CHAR(9)  -- 格式化的日期 --
  -----------------------修改開始-------------------------------------------------------
 --       ,f_cnt             INTEGER
-----------------------修改結束-------------------------------------------------------
    DEFINE f_ins_pscn        CHAR(1)  --  N:不做 pscn 維護
          ,f_ins_pscg        CHAR(1)  --  N:不做 pscg 維護
          ,f_call_psc00m00   CHAR(1)  --  N:進入領取
          ,f_upd_pscb        CHAR(1)
          ,f_repeat_sw	     CHAR(1)
          ,f_upd_psck        CHAR(1)  --  Y:nonresp_sw = "Y" N:nonresp_sw = " "

    DEFINE f_pscn	     RECORD LIKE pscn.*
	  ,f_cmd             CHAR(1024)

    DEFINE f_notice_print    CHAR(1)  --  Y:列印照會單, N:不列印照會單
    DEFINE f_psck_cnt        SMALLINT
    DEFINE f_sw              CHAR(1)
    DEFINE f_prompt_ans      CHAR(1)  
-----------------------修改開始-------------------------------------------------------
--    DEFINE f_po_chg_sts_code LIKE aplg.po_chg_sts_code
--    DEFINE f_po_chg_rece_date LIKE apdt.po_chg_rece_date 
 --   DEFINE f_po_chg_rece_no   LIKE apdt.po_chg_rece_no   
--    LET f_po_chg_sts_code = ""
-----------------------修改結束-------------------------------------------------------    
    LET f_rcode=0
    LET f_chkdate_sw=true
    LET f_format_date=""
    LET f_psck_cnt = 0

    MESSAGE " 請輸入條件。Esc: 接受，End: 放棄。" ATTRIBUTE (YELLOW)

    OPEN WINDOW w_psc00m01 AT 10,11 WITH FORM "psc00m01"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                   , PROMPT LINE LAST )

    IF INT_FLAG=TRUE THEN
        CLOSE WINDOW w_psc00m01
        LET INT_FLAG=FALSE
        RETURN
    END IF
    
     IF INT_FLAG=TRUE THEN
        CLOSE WINDOW w_psc00m01
        LET INT_FLAG=FALSE
        RETURN
    END IF

    LET f_rcode     		=0
    LET f_polf_exist		=0
    LET f_pscb_exist		=0
    LET f_pscn_exist		=0
    LET f_chkdate_sw		=TRUE
    LET f_format_date		=""
    LET f_ins_pscg   	        ="N"
    LET f_ins_pscn	        ="N"
    LET f_upd_pscb	        ="N"
    LET f_upd_psck              ="N"
    LET f_call_psc00m00	 	="N"
    LET f_repeat_sw     	=""
    LET f_notice_print		="N"
    LET p_pt_sw                 = '0'
    LET f_prompt_ans            =" "
---------------------------修改開始-----------------------------------------------
--    LET f_cnt                   = 0
    LET f_sw                = '0'
---------------------------修改結束----------------------------------------------

    INITIALIZE f_pscn.*         TO NULL
    LET p_psbh_cnt = 0 

    DISPLAY p_policy_no,p_cp_anniv_date,p_po_chg_rece_no TO psc00m01.*

    INPUT p_policy_no,p_cp_anniv_date,p_po_chg_rece_no without defaults FROM
          psc00m01.* 
          --policy_no,cp_anniv_date
          ATTRIBUTE (BLUE ,REVERSE ,UNDERLINE)

          AFTER FIELD policy_no
                SELECT count(*) INTO f_polf_exist
                FROM   polf
                WHERE  policy_no=p_policy_no

                IF f_polf_exist=0  THEN
                   CALL get_ia(p_policy_no) RETURNING f_rtn ----0-正常; 1-有誤
                   IF f_rtn = 1 THEN
                   ERROR "保單不存在!!"
                   NEXT FIELD policy_no
                   ELSE
                       LET p_pt_sw = '1'
                   END IF
                END IF
     	  AFTER FIELD cp_anniv_date
                CALL CheckDate(p_cp_anniv_date) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "日期輸入錯誤!!"
                   NEXT FIELD cp_anniv_date
                END IF
                LET p_cp_anniv_date=f_format_date
                DISPLAY p_cp_anniv_date TO cp_anniv_date

          AFTER INPUT
                IF INT_FLAG=TRUE  THEN
                   EXIT INPUT
                END IF

                SELECT count(*) INTO f_polf_exist
                FROM   polf
                WHERE  policy_no=p_policy_no

                IF f_polf_exist=0  THEN
                   CALL get_ia(p_policy_no) RETURNING f_rtn ----0-正常; 1-有誤
                   IF f_rtn = 1 THEN
                   ERROR "保單不存在!!"
                   NEXT FIELD policy_no
                   ELSE
                       LET p_pt_sw = '1'
                   END IF
                END IF

                CALL CheckDate(p_cp_anniv_date) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "日期輸入錯誤!!"
                   NEXT FIELD cp_anniv_date
                END IF

                LET p_cp_anniv_date=f_format_date
                DISPLAY p_cp_anniv_date TO cp_anniv_date

             IF p_pt_sw = '1' THEN ----給付保單
                SELECT count(*) INTO f_pscb_exist
                FROM   ptpd
                WHERE  policy_no      = p_policy_no
                AND    payout_due     = p_cp_anniv_date
--                AND    live_certi_ind = 'Y'
                AND    opt_notice_sw  in ( '1','2')----回覆狀態 1.等待回覆 2.已經回覆
                AND    process_sw     = '0'        ----初始值   1.已經給付
                IF f_pscb_exist = 0 THEN
                   ERROR "給付檔中無此筆資料 !!"
                   NEXT  FIELD policy_no
                END IF
                IF  g_poia.po_sts_code !='53' THEN 
                    ERROR '年金保單狀態不符，不需回覆'
                   NEXT  FIELD policy_no
                END IF

                IF  p_cp_anniv_date > AddDay(p_tx_date,45) OR g_poia.po_sts_code !='53' THEN 
                   ERROR '此保單位於非回覆期間，不可回覆'
                   NEXT  FIELD policy_no
                END IF

             ELSE
                SELECT count(*)
                INTO   f_pscb_exist
                FROM   pscb
                WHERE  policy_no    =p_policy_no
                AND    cp_anniv_date=p_cp_anniv_date
                AND    cp_sw in ("1","3","4","7","8")

                IF f_pscb_exist =0 THEN
                   ERROR "還本檔中無此筆資料 !!"
                   NEXT  FIELD policy_no
                END IF
             END IF
             IF f_sw = "0" THEN
                LET f_sw ="1"
                ERROR "請按F6選擇受理號碼!!" ATTRIBUTE(RED ,REVERSE)
                NEXT  FIELD cp_anniv_date
             END IF

             IF p_po_chg_rece_no = "" OR p_po_chg_rece_no = " " OR
                p_po_chg_rece_no IS NULL THEN
                ERROR "該保單號碼查無狀態(2,4,A)下之受理號碼，請查核!" ATTRIBUTE(RED ,REVERSE)
                NEXT  FIELD cp_anniv_date 
             END IF

             SELECT count(*)
             INTO   f_pscn_exist
             FROM   pscn
             WHERE  policy_no	=p_policy_no
             AND    cp_anniv_date	=p_cp_anniv_date
         
             SELECT count(*)
             INTO   p_psbh_cnt
             FROM   psbh
             WHERE  policy_no     = p_policy_no
             AND    cp_anniv_date = p_cp_anniv_date
             AND    cp_rtn_sts in ('0','1')
-------------------------修改線開始(受理號碼)-------------------------------------------------
	     ON KEY (F6) 
		IF INFIELD(cp_anniv_date) THEN 
		   CALL rece_no_show()
	           DISPLAY p_po_chg_rece_no TO po_chg_rece_no ATTRIBUTE( BLUE, REVERSE, UNDERLINE )
 	        END IF
                
                
-------------------------修改線結束(受理號碼)------------------------------------------------- 
    END INPUT

    IF INT_FLAG THEN
       ERROR "回覆作業放棄 !!"
       LET INT_FLAG = FALSE
------------------------------------------------------------------------------------------
			 CLOSE WINDOW w_psc00m01
---------------------------------------------------------------------------------------------
       RETURN
    END IF

  IF  p_pt_sw = '1' THEN
    IF  g_poia.po_sts_code = '53' THEN
        LET f_polf_exist = 0
    ELSE
        LET f_polf_exist = 1
    END IF
  ELSE
    SELECT COUNT(*)
    INTO   f_polf_exist
    FROM   polf
    WHERE  policy_no = p_policy_no
    AND    po_sts_code NOT IN ("42", "43", "44", "46", "47", "48", "50")
  END IF
    LET f_repeat_sw = " "
    IF f_polf_exist > 0 THEN
--       PROMPT "請注意，此保單非為有效狀態，確認請按(Y/y)" FOR CHAR f_repeat_sw
       PROMPT "保單非有效狀態確認請按(Y/y)" FOR CHAR f_repeat_sw
       IF UPSHIFT(f_repeat_sw) !="Y"
       OR f_repeat_sw IS NULL        THEN
	  CLOSE WINDOW w_psc00m01
	  RETURN
       END IF
    END IF
    SELECT count(*)
      INTO f_psck_cnt
      FROM psck
     WHERE policy_no = p_policy_no
       AND nonresp_sw = 'Y'
    IF f_psck_cnt > 0 THEN
       ERROR "尚有未回領取註記未消除，請確認 !!"
    END IF

    LET f_repeat_sw = " "
    IF f_pscn_exist > 0 THEN

       LET f_cmd ="SELECT FIRST 1 * FROM pscn "
                 ," WHERE policy_no= ? "
                 ," AND   cp_anniv_date= ? "
                 ," ORDER BY process_date DESC ,process_time DESC "

       PREPARE pscn_pre FROM f_cmd
       DECLARE pscn_ptr CURSOR FOR pscn_pre
       FOREACH pscn_ptr USING p_policy_no, p_cp_anniv_date
			INTO  f_pscn.*
       END FOREACH

       IF  f_pscn.cp_notice_code = "1" 
       AND f_pscn.cp_notice_sub_code MATCHES "[12]" THEN
       ELSE
           IF p_psbh_cnt = 0 THEN
              PROMPT "  確定再次進行回覆請按(Y/y)" FOR CHAR f_repeat_sw
              IF UPSHIFT(f_repeat_sw) !="Y" OR
                 f_repeat_sw IS NULL        THEN
                 CLOSE WINDOW w_psc00m01
                 RETURN
              END IF
           ELSE
              PROMPT "＊本保單為回流件,再次回覆(Y/y)" FOR CHAR f_repeat_sw
              IF UPSHIFT(f_repeat_sw) !="Y" OR
                 f_repeat_sw IS NULL        THEN
                 CLOSE WINDOW w_psc00m01
                 RETURN
              END IF
           END IF         
       END IF
    END IF

    CLOSE WINDOW w_psc00m01

    CALL psc00m02_screen() RETURNING f_rcode
    ----------------------------------------------
    -- f_rcode
    -- =1 :INT_FLAG=TRUE 離開                   --
    -- !=1:psc00m02 存檔                        --
    ----------------------------------------------

    -- 輸入資料不存,離開 --
    IF f_rcode !=0 THEN
       ERROR "回覆不存檔 !!"
       RETURN
    END IF

    -- 文件齊全,進入領取 --
    IF p_cp_notice_code="0" THEN
       LET f_ins_pscg="N"
       LET f_ins_pscn="Y"
       LET f_call_psc00m00="Y"
       LET f_upd_pscb="N"
       LET f_upd_psck="N"
       LET f_notice_print="N"
    END IF

    -- 未回覆件,進入領取 --
    IF p_cp_notice_code="2" THEN
       LET f_ins_pscg="N"
       LET f_ins_pscn="Y"
       LET f_call_psc00m00="Y"
       LET f_upd_pscb="N"
--       IF f_psck_cnt > 0 THEN
       LET f_upd_psck="Y"
--       END IF 
       LET f_notice_print="N"
    END IF

    -- 照會回覆,進入領取 --
    IF p_cp_notice_code="3" THEN
       LET f_ins_pscg="N"
       LET f_ins_pscn="Y"
       LET f_call_psc00m00="Y"
       LET f_upd_pscb="N"
       LET f_upd_psck="N"
       LET f_notice_print="N"
    END IF

    IF p_cp_notice_code="1" THEN
       LET f_ins_pscg="Y"
       LET f_upd_psck="N"
       -- 融通件 --
       IF p_cp_notice_sub_code ="0" THEN
          LET f_ins_pscn="Y"
          LET f_call_psc00m00="Y"
          LET f_upd_pscb="N"
	  LET f_notice_print="N"
       ELSE
	  IF p_cp_notice_sub_code ="1" THEN
	     LET f_ins_pscn="Y"
             LET f_call_psc00m00="N"
             LET f_upd_pscb="Y"
	     LET f_notice_print="Y"
	  ELSE
	     LET f_ins_pscn="Y"
	     LET f_call_psc00m00="N"
	     LET f_upd_pscb="Y"
	     LET f_notice_print="Y"
	  END IF
       END IF
    END IF
    LET p_upd_psck = f_upd_psck
    IF f_call_psc00m00="Y" THEN
       CALL psc00m00_input() RETURNING f_rcode
       -- 領取回覆的資料不存,離開 --
       IF f_rcode =1 THEN
          ERROR "回覆資料,領取資料放棄作業 !!"
          LET f_rcode=0
          RETURN
       END IF
    END  IF

    IF f_ins_pscn="Y" THEN
       CALL psc00m_insert_pscn(f_upd_pscb,f_ins_pscg)
            RETURNING f_rcode
       IF f_rcode !=0 THEN
          ERROR "回覆資料新增有誤,請聯絡資訊部 !!"
          RETURN
       END IF
    END IF

    IF f_notice_print="Y" THEN

       -- 選擇照會業務員或保戶才需列印 --
       IF p_cp_notice_sub_code = "1"
       OR p_cp_notice_sub_code = "2" THEN
	  CALL notice_print() RETURNING f_rcode

	  IF f_rcode != 0 THEN
	     ERROR "列印照會單錯誤,請聯絡資訊部 !!"
	     RETURN
	  END IF
       END IF
    END IF

    RETURN

END FUNCTION -- psc00m_sel_1 --
-------------------------------------------------------------------
FUNCTION psc00m02_screen()
    DEFINE f_rcode          INTEGER
          ,f_ans_sw         CHAR(1)

    LET  p_act_return_date=p_tran_date
    LET  p_cp_notice_code =""
    LET  f_rcode=0

    OPEN WINDOW w_psc00m02 AT 10,41 WITH FORM "psc00m02"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                   , PROMPT LINE LAST )

    WHILE 1=1

        LET f_rcode         =0
        LET INT_FLAG        =FALSE
        LET p_cp_notice_code=""

        DISPLAY p_policy_no,p_cp_anniv_date,p_tran_date
        TO      policy_no  ,cp_anniv_date  ,act_return_date

        INPUT p_cp_notice_code WITHOUT DEFAULTS
              FROM  cp_notice_code
              ATTRIBUTE (BLUE ,REVERSE ,UNDERLINE)

              AFTER FIELD cp_notice_code
                    IF LENGTH(p_cp_notice_code CLIPPED)=0 THEN
                       ERROR "回覆處理碼必須輸入 !!"
                       NEXT FIELD cp_notice_code
                    END IF
                    IF p_cp_notice_code NOT MATCHES "[0-3]" THEN
                       ERROR "回覆處理碼輸入錯誤 !!"
                       NEXT FIELD cp_notice_code
                    END IF
                    -- 文件不齊全,進入照會或融通處理 --
                    IF p_cp_notice_code="1" THEN
                       CALL psc00m03_screen()
                    END IF

              AFTER INPUT

                    IF INT_FLAG=TRUE THEN
                       EXIT INPUT
                    END IF
                    IF LENGTH(p_cp_notice_code CLIPPED)=0 THEN
                       ERROR "回覆處理碼必須輸入 !!"
                       NEXT FIELD cp_notice_code
                    END IF
                    IF p_cp_notice_code NOT MATCHES "[0-3]" THEN
                       ERROR "回覆處理碼輸入錯誤 !!"
                       NEXT FIELD cp_notice_code
                    END IF

                    IF p_cp_notice_code MATCHES "[2]" AND p_pt_sw= '1' THEN
                       ERROR "回覆處理碼輸入錯誤，給付回覆不可使用 !!"
                       NEXT FIELD cp_notice_code
                    END IF

                    IF p_cp_notice_code="1" THEN
                      IF LENGTH(p_cp_notice_sub_code CLIPPED)=0 THEN
                         ERROR "回覆處理,文件不齊,無處理方式 !!"
                         NEXT FIELD cp_notice_code
                      END IF

                      IF p_notice_desc_len=0 THEN
                         ERROR "回覆處理,文件不齊,無缺碼 !!"
                         NEXT FIELD cp_notice_code
                      END IF
                    END IF

                    LET f_ans_sw=""
                    PROMPT "  確認存檔請按 Y" FOR CHAR f_ans_sw
                    IF UPSHIFT(f_ans_sw) !="Y" OR
                       f_ans_sw IS NULL        THEN
                       NEXT FIELD cp_notice_code
                    END IF

        END INPUT

        IF INT_FLAG=TRUE THEN
           LET INT_FLAG=FALSE
           LET f_rcode=1
        ENd IF

        EXIT WHILE
    END WHILE

    CLOSE WINDOW w_psc00m02
    LET INT_FLAG=FALSE
    RETURN f_rcode

END FUNCTION -- psc00m02_screen --

FUNCTION psc00m03_screen()
    DEFINE f_rcode  CHAR(1)
          ,f_ans_sw CHAR(1)
    DEFINE f_psc00m03_rcode CHAR(1)

    OPEN WINDOW w_psc00m03 AT  10,11 WITH FORM "psc00m03"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                   , PROMPT LINE LAST )
--    MESSAGE "ESC:存檔 F1:照會補件 F2:退件"

    WHILE 1=1

        LET f_rcode             ="0"
        LET INT_FLAG            =FALSE
        LET f_psc00m03_rcode    ="0"
        LET p_cp_notice_sub_code=""

        DISPLAY p_policy_no,p_cp_anniv_date,p_act_return_date
               ,p_cp_notice_code
               ,p_cp_notice_sub_code
        TO      policy_no,cp_anniv_date,act_return_date
               ,cp_notice_code
               ,cp_notice_sub_code

        INPUT p_cp_notice_sub_code
              WITHOUT DEFAULTS FROM cp_notice_sub_code
              ATTRIBUTE (BLUE ,REVERSE ,UNDERLINE)

              AFTER FIELD cp_notice_sub_code
                    IF LENGTH(p_cp_notice_sub_code CLIPPED)=0 THEN
                       ERROR "處理方式必須輸入   !!"
                       NEXT FIELD cp_notice_sub_code
                    END IF
                    IF p_cp_notice_sub_code NOT MATCHES "[0-2]" THEN
                       ERROR "處理方式輸入錯誤   !!"
                       NEXT FIELD cp_notice_sub_code
                    END IF
                    -- 文件缺碼處理 pscg insert --
                    -- f_rcode=0 確定存檔       --
                    -- f_rcoed=1 存檔錯誤       --
                    -- f_rcode=2 放棄存檔       --
                    CALL psc00m08_screen() RETURNING
                         f_rcode
               --   CALL psc00m_dsp_dif_code() RETURNING
               --        f_rcode,p_cp_notice_dif_code
               --       ,p_dif_code_desc

                    IF  f_rcode=1 THEN
                        ERROR " 代碼檔欠缺資料 !!"
                        ATTRIBUTE (RED)
                        LET f_rcode=0
                        NEXT FIELD cp_notice_sub_code
                    END IF

                    IF  f_rcode=2  THEN
                        ERROR " 放棄缺碼作業 !!" ATTRIBUTE (RED)
                        LET f_rcode=0
                        NEXT FIELD cp_notice_sub_code
                    END IF

              AFTER INPUT
                    IF INT_FLAG=TRUE THEN
                       EXIT INPUT
                    END IF

                    IF LENGTH(p_cp_notice_sub_code CLIPPED)=0 THEN
                       ERROR "處理方式必須輸入   !!"
                       NEXT FIELD cp_notice_sub_code
                    END IF
                    IF p_cp_notice_sub_code NOT MATCHES "[0-2]" THEN
                       ERROR "處理方式輸入錯誤   !!"
                       NEXT FIELD cp_notice_sub_code
                    END IF

                    IF p_notice_desc_len =0 THEN
                       ERROR "文件缺無作業,請重新輸入!!" ATTRIBUTE (RED)
                       LET f_rcode=0
                       NEXT FIELD cp_notice_sub_code
                    END IF

                    LET f_ans_sw=""
--                    MESSAGE "" 
                    PROMPT "  確認存檔請按 Y" FOR CHAR f_ans_sw
                    IF UPSHIFT(f_ans_sw) !="Y" OR
                       f_ans_sw IS NULL        THEN
--                       MESSAGE "F1:照會補件 F2:退件" 
                       NEXT FIELD cp_notice_sub_code
                    END IF

        END INPUT

        IF INT_FLAG=TRUE THEN
           LET p_cp_notice_sub_code=""
           EXIT WHILE
        END IF

        EXIT WHILE
    END WHILE

    CLOSE WINDOW w_psc00m03
    LET INT_FLAG=FALSE
    RETURN

END FUNCTION -- psc00m03_screen --

-- 文件缺的內容 --
FUNCTION psc00m08_screen()
    DEFINE f_rcode    CHAR(1)
          ,f_i        INTEGER
          ,f_x        INTEGER
          ,f_y        INTEGER
          ,f_arr_cur  INTEGER
          ,f_scr_cur  INTEGER
    DEFINE f_ans_sw   CHAR(1)
          ,f_dif_code_desc CHAR(30)
    DEFINE f_cmd 	CHAR(100)
    OPEN WINDOW w_psc00m08 AT  6,6 WITH FORM "psc00m08"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                   , PROMPT LINE LAST )
    MESSAGE "  F6:選擇缺碼說明"

    FOR f_i=1 TO 7
        LET p_pscg[f_i].input_desc=""
    END FOR

    LET f_rcode=0
    LET f_ans_sw=""
    LET p_notice_desc_len=0
    LET p_notice_desc=""

    CALL SET_COUNT(7)
    INPUT ARRAY p_pscg WITHOUT DEFAULTS
    FROM  psc00m08.*
    BEFORE ROW
           LET f_arr_cur = ARR_CURR()
           LET f_scr_cur = SCR_LINE()

    ON KEY (F6)
       CALL psc00m_dsp_dif_code() RETURNING
            f_rcode,f_dif_code_desc
       LET p_pscg[f_arr_cur].input_desc=f_dif_code_desc
       DISPLAY p_pscg[f_arr_cur].input_desc TO
               psc00m08[f_scr_cur].desc
       LET p_notice_desc =p_notice_desc CLIPPED
                         ,p_pscg[f_arr_cur].input_desc
 

    AFTER INPUT
       IF INT_FLAG=TRUE THEN
          EXIT INPUT
       END IF

       LET p_notice_desc_len=LENGTH(p_notice_desc CLIPPED)

       LET f_ans_sw=""
       PROMPT "  確認存檔請按 Y" FOR CHAR f_ans_sw
       IF UPSHIFT(f_ans_sw) !="Y" OR
          f_ans_sw IS NULL        THEN
          NEXT FIELD desc
       END IF
    END INPUT
    IF INT_FLAG=TRUE THEN
       LET f_rcode=1
       LET p_notice_desc_len=0
       LET p_notice_desc=""
       CLOSE WINDOW w_psc00m08
       RETURN f_rcode
    END IF
    LET p_notice_desc_1=p_pscg[1].input_desc
    LET p_notice_desc_2=p_pscg[2].input_desc
    LET p_notice_desc_3=p_pscg[3].input_desc
    LET p_notice_desc_4=p_pscg[4].input_desc
    LET p_notice_desc_5=p_pscg[5].input_desc
    LET p_notice_desc_6=p_pscg[6].input_desc
    LET p_notice_desc_7=p_pscg[7].input_desc
    LET p_notice_desc_len = length(p_notice_desc_1)
    CLOSE WINDOW w_psc00m08

    RETURN f_rcode
END FUNCTION -- psc00m08_screen --

FUNCTION psc00m_dsp_dif_code()
    DEFINE f_rcode    CHAR(1)
    DEFINE f_pscf  RECORD LIKE pscf.*
    DEFINE f_pscf_cnt INTEGER
          ,f_i        INTEGER
          ,f_x        INTEGER
          ,f_y        INTEGER
    DEFINE f_cp_notice_dif_code LIKE pscf.cp_notice_dif_code
          ,f_dif_code_desc      LIKE pscf.cp_dif_code_desc


    LET f_i=0
    LET f_cp_notice_dif_code=""
    LET f_dif_code_desc     =""

    FOR f_i=1 TO 99
        LET p_dif[f_i].cp_notice_dif_code=""
        LET p_dif[f_i].dif_code_desc     =""
    END FOR

    LET f_i=0
    DECLARE pscf_crs CURSOR FOR
            SELECT *
            FROM   pscf
    FOREACH pscf_crs  INTO f_pscf.*
        LET f_i=f_i+1
        LET p_dif[f_i].cp_notice_dif_code=f_pscf.cp_notice_dif_code
        LET p_dif[f_i].dif_code_desc     =f_pscf.cp_dif_code_desc
    END FOREACH

    IF f_i=0 THEN
       LET f_rcode=1
       LET f_cp_notice_dif_code=""
       LET f_dif_code_desc  =""
       RETURN f_rcode,f_dif_code_desc
    END IF

    LET f_x=8
    LET f_y=31

    OPEN WINDOW w_psc00m04 AT f_x, f_y WITH FORM "psc00m04"
         ATTRIBUTE( BLUE, REVERSE, UNDERLINE )

    CALL SET_COUNT(f_i)
    LET f_cp_notice_dif_code=""
    LET f_dif_code_desc=""
    LET INT_FLAG=FALSE

    DISPLAY ARRAY p_dif TO psc00m04.* ATTRIBUTE (BLUE ,REVERSE)


    IF (INT_FLAG = FALSE) THEN
        LET f_i    = ARR_CURR()
        LET f_cp_notice_dif_code=p_dif[f_i].cp_notice_dif_code
        LET f_dif_code_desc     =p_dif[f_i].dif_code_desc
    ELSE
        LET f_rcode=2
        LET INT_FLAG = FALSE
    END IF

    CLOSE WINDOW w_psc00m04

    RETURN f_rcode,f_dif_code_desc
END FUNCTION -- psc00m_dsp_diff_code --

FUNCTION psc00m_insert_pscn(f_upd_pscb,f_ins_pscg)
    DEFINE f_upd_pscb CHAR(1)     -- 是否更新 pscb --
          ,f_ins_pscg CHAR(1)     -- 是否 insert pscg --
    DEFINE f_rcode INTEGER
          ,f_process_date CHAR(9)
          ,f_process_time CHAR(8)
          ,f_notice_serial INTEGER
          ,f_pscn_notice_serial INTEGER
          ,f_dummy_flag         CHAR(2)

    LET f_notice_serial=0
    LET f_rcode=0
    LET f_process_date=GetDate(TODAY)
    LET f_process_time=TIME

    WHENEVER ERROR CONTINUE


    BEGIN WORK

    LET f_pscn_notice_serial=null

    SELECT max(cp_notice_serial)
    INTO   f_pscn_notice_serial
    FROM   pscn
    WHERE  policy_no=p_policy_no
    AND    cp_anniv_date=p_cp_anniv_date

    IF f_pscn_notice_serial IS NULL THEN
       LET f_pscn_notice_serial=0
    END IF

    LET  f_notice_serial=f_pscn_notice_serial+1

    IF f_ins_pscg="N" THEN
       LET f_dummy_flag="OK" 
    ELSE
       {
       SELECT max(cp_notice_serial)
       INTO   f_pscg_notice_serial
       FROM   pscg
       WHERE  policy_no=p_policy_no
       AND    cp_anniv_date=p_cp_anniv_date

       IF f_pscg_notice_serial IS NULL THEN
          LET f_pscg_notice_serial=0
       END IF

       LET  f_notice_serial=f_pscg_notice_serial+1
       }

       INSERT INTO pscg
       VALUES (p_policy_no
              ,p_cp_anniv_date
              ,f_notice_serial
              ,p_notice_desc_1
              ,p_notice_desc_2
              ,p_notice_desc_3
              ,p_notice_desc_4
              ,p_notice_desc_5
              ,p_notice_desc_6
              ,p_notice_desc_7
              ,f_process_date
              ,f_process_time
              ,g_user
              )
       IF SQLCA.SQLCODE != 0 THEN
          ROLLBACK WORK
          LET f_rcode=1
          RETURN f_rcode
       END IF
    END IF


    INSERT INTO pscn
    VALUES (p_policy_no
           ,p_cp_anniv_date
           ,p_act_return_date
           ,p_cp_notice_code
           ,p_cp_notice_sub_code
           ,f_notice_serial
           ,f_process_date
           ,f_process_time
           ,g_user
           )

    IF SQLCA.SQLCODE != 0 THEN
       ROLLBACK WORK
       LET f_rcode=1
       RETURN f_rcode
    ELSE
       IF f_upd_pscb="Y" THEN
         IF p_pt_sw = '1' THEN     ----給付保單
            ----不需更新 cp_notice_sw
         ELSE
          UPDATE pscb
          SET    cp_notice_sw="1"
                ,change_date =f_process_date
                ,process_date=f_process_date
                ,process_user=g_user
          WHERE  policy_no=p_policy_no
          AND    cp_anniv_date=p_cp_anniv_date
          IF SQLCA.SQLCODE != 0 THEN
             ROLLBACK WORK
             LET f_rcode=1
             RETURN f_rcode
          END  IF
         END IF

          -- 照會單檔 --
          INSERT INTO psci
          VALUES (p_policy_no
                 ,p_cp_anniv_date
                 ,"1"
                 ,g_user
                 ,f_process_date
                 )
          IF SQLCA.SQLCODE !=0 THEN
             ROLLBACK WORK
             LET f_rcode=1
             RETURN f_rcode
          END IF

       END IF
    END IF

    COMMIT WORK
    RETURN f_rcode
END FUNCTION -- psc00m_insert_pscn --


FUNCTION psc00m00_input()
    DEFINE f_rcode          INTEGER
    DEFINE f_psc00m00_rcode CHAR(1)

    LET f_rcode=0

    CALL psc01m_init()

    IF  p_pt_sw = '1' THEN
    CALL psc01m_query_pt() RETURNING f_rcode
    ELSE
    CALL psc01m_query() RETURNING f_rcode
    END IF

    RETURN f_rcode
END FUNCTION --psc00m00_input --

------------------------------------------------------------------------------
--  函式名稱: psc01m_init
--  作    者: jessica Chang
--  日    期: 87/08/04
--  處理概要: 還本通知回覆,畫面初值
--  重要函式:
------------------------------------------------------------------------------

FUNCTION psc01m_init()
    DEFINE f_i SMALLINT -- array index ---

    INITIALIZE p_pc961_data.* TO NULL

    LET   p_applicant_id  =" "
    LET   p_applicant_name=" "
    LET   p_tel_1         =" "
    LET   p_tel_2         =" "
    LET   p_old_cp_disb_type=" "
    LET   p_coverage_no  =1

    -- 畫面一資料 --
    LET   p_data_s1.policy_no              =" "       -- 保單號碼 --
    LET   p_data_s1.po_sts_code            =" "       -- 保單狀態 --
    LET   p_data_s1.cp_anniv_date          =" "       -- 還本週年日 --
    LET   p_data_s1.cp_disb_type           =" "       -- 付款方式 --
    LET   p_data_s1.mail_addr_ind          =" "       -- 郵寄指示 --
    LET   p_data_s1.disb_special_ind       =" "       -- 電匯指示 --
    LET   p_data_s1.cp_rtn_sw		   =" "	      -- 還款指示 --
    LET   p_data_s1.cp_pay_name            =" "       -- 應領姓名 --
    LET   p_data_s1.cp_pay_id              =" "       -- 應領id   --
    LET   p_data_s1.dept_name		   =" "       -- 領取地點 --
    LET   p_data_s1.po_chg_rece_no         =" "       -- 受理號碼  97.07 yirong
--    LET   p_data_s1.dept_code              =" "       -- 領取地點 --
    -- 補畫面一取消的欄位 --
    LET   p_dept_code			   =" "	      -- 領取地點 --


    -- 畫面三資料 --
    LET   p_data_s3.psck_sw                =" "       -- 還本註記 --
    LET   p_data_s3.overloan_desc	   =" "	      -- OVERLOAN 指示 --
    LET   p_data_s3.notice_resp_desc	   =" "	      -- 回覆指示 --
    LET   p_data_s3.app_name               =" "       -- 要保人   --
    LET   p_data_s3.app_id		   =" "	      -- 要保人id --
    LET   p_data_s3.insured_name           =" "       -- 被保人   --
    LET   p_data_s3.insured_id		   =" "	      -- 被保人id --

    -- 補畫面三取消的欄位 --
    LET   p_agent_code			   =" "       -- 業務員   --
    LET   p_dept_code_1			   =" "       -- 營業單位 --

    -- 畫面二 detail 資料 --
    FOR f_i=1 TO 99
       LET   p_data_s2[f_i].client_id      =" "      -- 受益人ID  --
       LET   p_data_s2[f_i].benf_ratio     = 0       -- 受益比例  --
       LET   p_data_s2[f_i].remit_bank     =" "      -- 匯款銀行  --
       LET   p_data_s2[f_i].remit_branch   =" "      -- 匯款銀行  --
       LET   p_data_s2[f_i].remit_account  =" "      -- 匯款帳帳  --
       LET   p_data_s2[f_i].benf_order     =" "      -- 受益順位  --
       LET   p_data_s2[f_i].names          =" "      -- 姓名/名稱 --
    END FOR
    FOR f_i=1 TO 99
       LET   p_data_s2_b[f_i].bank_name     =" "
    END FOR
    
    -- 100/03/31 ADD
    FOR f_i=1 TO 99
       LET   p_data_s2_c[f_i].payee               =" "                      
       LET   p_data_s2_c[f_i].remit_swift_code    =" " 
       LET   p_data_s2_c[f_i].remit_bank_name     =" "
       LET   p_data_s2_c[f_i].remit_bank_address  =" "  
    END FOR
    -- 100/03/31 END
    
    CLEAR FORM
    RETURN
END FUNCTION   -- psc01m_init --

------------------------------------------------------------------------------
--  函式名稱: psc01m_query
--  作    者: jessica Chang
--  日    期: 87/08/04
--  處理概要: 還本查詢作業,查詢畫面
--  重要函式:
------------------------------------------------------------------------------

FUNCTION psc01m_query()
    
    DEFINE f_rcode              INTEGER
          ,f_dummy_flag         CHAR(2)
          ,f_ans_sw             CHAR(1)   -- prompt 的回覆 --
          ,f_ans_sw1            CHAR(1)   -- yirong 101/09
          ,f_expired_sw         CHAR(1)
          ,f_psck_sw            CHAR(1)
          ,f_psck_cnt           INTEGER
          ,f_pscninq_sw         INTEGER

    DEFINE f_po                 CHAR(255) -- 取得 po 資訊的 prepare --
    DEFINE f_addr_cmd           CHAR(255) -- 執行地址的修改新增作業 --
    DEFINE f_bank_cmd		CHAR(255) -- 執行銀行資料維護作業 --
    DEFINE f_i                  INTEGER   -- array 計數器 --
          ,f_j                  INTEGER   -- array 計數器 -
          ,f_benf_cnt           INTEGER   -- 受益人計數器 --
          ,f_arr_cur            INTEGER   -- 受益人輸入的計數 --
          ,f_scr_cur            INTEGER   -- 受益人畫面的計數 --
          ,f_disb_err           INTEGER   -- 受益人銀行帳號有錯 --
          ,f_chk_remit_err      INTEGER 
          ,f_chk_remit_msg      CHAR(255)

    DEFINE f_pscb_cnt           INTEGER   -- 執行 perpare 指令有保單可執行 --
          ,f_polf_cnt           INTEGER   -- polf 是否存在 input 保單 --
          ,f_right_or_fault     INTEGER   -- 日期檢查 t or f --
          ,f_formated_date      CHAR(9)   -- 日期格式化 999/99/99 --
          ,f_benf_relation      CHAR(1)   -- 滿期/生存 受益人 --
          ,f_serivce_agt_name   CHAR(40)  -- 服務業務員_name --
          ,f_agt_deptbelong     CHAR(6)   -- agent 所屬分公司 --

    DEFINE f_cp_anniv_date      LIKE    pscb.cp_anniv_date
          ,f_cp_sw              LIKE    pscb.cp_sw
          ,f_cp_disb_type       LIKE    pscb.cp_disb_type
          ,f_mail_addr_ind      LIKE    pscb.mail_addr_ind
          ,f_disb_special_ind   LIKE    pscb.disb_special_ind
          ,f_pay_ind            CHAR(1)
          ,f_cp_pay_name        CHAR(12)
          ,f_cp_pay_id          LIKE    pscb.cp_pay_id
          ,f_cp_dept_code       LIKE    pscb.dept_code

    DEFINE f_cp_notice_formtype LIKE pscr.cp_notice_formtype
          ,f_chk_sw             LIKE pscr.cp_chk_sw
          ,f_chk_date           LIKE pscr.cp_chk_date

    DEFINE f_arr                INTEGER
          ,f_dtl_cp_ann         LIKE    pscb.cp_anniv_date

    DEFINE f_client_ident       LIKE    colf.client_ident
          ,f_applicant_id       LIKE    clnt.client_id
          ,f_insured_id         LIKE    clnt.client_id
          ,f_addr_id            LIKE    clnt.client_id
          ,f_addr_ind           LIKE    addr.addr_ind
          ,f_zip_code           LIKE    addr.zip_code
          ,f_address            LIKE    addr.address
          ,f_app_name           LIKE    clnt.names
          ,f_insured_name       LIKE    clnt.names
--          ,f_disb_ind           CHAR(1)
          ,f_ask_error          CHAR(100)
          , f_po_chg_sts_code   CHAR(1)
    DEFINE f_rece               SMALLINT
    -- 100/03/31 ADD
    DEFINE f_hotkey_msg         CHAR(100)     
    DEFINE f_cmd_1              CHAR(1000)  
    DEFINE f_client_id          LIKE benf.client_id 
    DEFINE f_swift_code         LIKE benp.swift_code     
    DEFINE f_bank_account_e     LIKE benp.bank_account_e 
    DEFINE f_psc4_cnt           SMALLINT
    -- 100/03/31 END      
    MESSAGE " END:取消"

    LET INT_FLAG      =FALSE
    LET f_client_ident=" "
    LET f_applicant_id=" "
    LET f_app_name    =" "
    LET f_insured_id  =" "
    LET f_insured_name=" "
    LET f_addr_id     =" "
    LET f_addr_ind    ="0"
    LET f_zip_code    =" "
    LET f_address     =" "
    LET f_chk_date    =" "
    LET f_chk_sw      =" "
    LET f_psck_sw     =" "

    LET f_psck_cnt    =0
    LET f_pscb_cnt    =0
    LET f_polf_cnt    =0
    LET f_benf_cnt    =0
    LET f_psc4_cnt = 0
    LET p_data_s1.policy_no=p_policy_no
    LET p_data_s1.cp_anniv_date=p_cp_anniv_date
    -- 資料檢查 --

    -- g_polf.的資料 --
    SELECT *
    INTO   g_polf.*
    FROM   polf
    WHERE  policy_no=p_data_s1.policy_no
    IF SQLCA.SQLERRD[3]=0 THEN
       ERROR "無此張保單!!"
             ATTRIBUTE (RED)
       LET f_rcode=1
       RETURN f_rcode
    END IF

    -- 100/03/31 ADD 外幣要切換成另外一個FORM,熱鍵指示也不同
    IF g_polf.currency = 'TWD' THEN
    	 LET f_hotkey_msg = "END:放棄,F2:受理查詢,F5:郵寄指示,F6:正常電匯,F8:指定電匯,F9:註記,F7:銀行資料維護"
       OPEN FORM psc00m00 FROM "psc00m00"              -- 101/02/20 ADD 回覆時切換外幣/台幣保單，需先重新開啟FORM 
       DISPLAY FORM psc00m00 ATTRIBUTE (GREEN)
       CALL ShowLogo()
    ELSE
    	 LET f_hotkey_msg = "END:放棄,F2:受理查詢,F6:正常電匯,F8:指定電匯,F9:註記,F7:銀行Swift code維護"  
    	 OPEN FORM psc00m11 FROM "psc00m11"
       DISPLAY FORM psc00m11 ATTRIBUTE (GREEN)
       CALL ShowLogo()
    END IF
    -- 100/03/31 ADD
    
    -- 滿期 or 生存 --
    IF g_polf.expired_date <= p_data_s1.cp_anniv_date THEN
       LET f_expired_sw="Y"
    ELSE
       LET f_expired_sw="N"
    END IF

    SELECT count(*) INTO f_pscb_cnt
    FROM   pscb
    WHERE  policy_no=p_data_s1.policy_no
    AND    cp_anniv_date=p_data_s1.cp_anniv_date
    AND    cp_sw  in ("1","3","4","7","8")

    IF f_pscb_cnt is null OR
       f_pscb_cnt =0      THEN
       ERROR "此張保單無還本資料!!"
             ATTRIBUTE (RED)
       LET f_rcode=1
       RETURN f_rcode
    END IF

    -- 還本註記 --
    SELECT count(*) INTO f_psck_cnt
    FROM   psck
    WHERE  policy_no=p_data_s1.policy_no
    AND    cp_anniv_date=p_data_s1.cp_anniv_date
    IF f_psck_cnt=0 THEN
       LET f_psck_sw="N"
    ELSE
       LET f_psck_sw="Y"
    END IF


    LET f_pscb_cnt=0
    LET f_polf_cnt=0
    LET f_benf_cnt=0
    LET p_benf_cnt=0

    SELECT * INTO p_pscb.*
    FROM   pscb
    WHERE  policy_no    =p_policy_no
    AND    cp_anniv_date=p_data_s1.cp_anniv_date

    LET f_cp_sw             =p_pscb.cp_sw
    LET f_cp_disb_type      =p_pscb.cp_disb_type
    LET f_mail_addr_ind     =p_pscb.mail_addr_ind
    LET f_disb_special_ind  =p_pscb.disb_special_ind
    LET f_cp_pay_name       =p_pscb.cp_pay_name
    LET f_cp_pay_id         =p_pscb.cp_pay_id
    LET f_cp_dept_code      =p_pscb.dept_code

    -- 畫面一的第三部資料 --
        LET  p_data_s3.psck_sw        =f_psck_sw

	IF p_pscb.overloan_sw = "1" THEN
	   LET p_data_s3.overloan_desc = "Y"
	ELSE
	   IF p_pscb.overloan_sw = "0" THEN
	      LET p_data_s3.overloan_desc = "N"
	   END IF
	END IF

	IF p_pscb.notice_resp_sw = "1" THEN
	   LET p_data_s3.notice_resp_desc = "Y"
	ELSE
	   IF p_pscb.notice_resp_sw = "0" THEN
	      LET p_data_s3.notice_resp_desc = "N"
	   END IF
	END IF

        -- 業務員,與營業單位 --
        SELECT agent_code
        INTO   p_agent_code
        FROM   poag
        WHERE  policy_no=p_data_s1.policy_no
        AND    relation ="S"

        SELECT dept_code
        INTO   p_dept_code_1
        FROM   agnt
        WHERE  agent_code=p_agent_code

        SELECT names INTO f_serivce_agt_name
        FROM   clnt
        WHERE  client_id=p_agent_code

        SELECT dept_belong INTO f_agt_deptbelong
        FROM   dept
        WHERE  dept_code=p_dept_code_1
{
        IF f_agt_deptbelong ="99000" OR 
           f_agt_deptbelong ="98000" THEN
           LET f_agt_deptbelong="97000"
        END IF
}
        IF f_agt_deptbelong ="99000"  THEN
           LET f_agt_deptbelong="97000"
        END IF

        -- 要保人ID,姓名 --
        CALL getNames(p_data_s1.policy_no,'O1')
             RETURNING p_applicant_id,p_applicant_name

        SELECT cp_chk_sw,cp_chk_date,coverage_no,cp_amt
        INTO   f_chk_sw,f_chk_date,p_coverage_no,p_cp_amt
        FROM   pscr
        WHERE  policy_no=p_data_s1.policy_no
        AND    cp_anniv_date=p_data_s1.cp_anniv_date

        -- 被保人ID,姓名 --
        SELECT client_ident
        INTO   f_client_ident
        FROM   colf
        WHERE  policy_no=p_data_s1.policy_no
        AND    coverage_no=p_coverage_no

        SELECT client_id
        INTO   f_insured_id
        FROM   pocl
        WHERE  policy_no=p_data_s1.policy_no
        AND    client_ident=f_client_ident

        SELECT names
        INTO   f_insured_name
        FROM   clnt
        WHERE  client_id=f_insured_id

        LET p_data_s3.app_name    =p_applicant_name[1,12] CLIPPED
        LET p_data_s3.app_id	  =p_applicant_id
        LET p_data_s3.insured_name=f_insured_name[1,12]   CLIPPED
        LET p_data_s3.insured_id  =f_insured_id

    -- 畫面一的第二部資料,受益人資料 --
       IF g_polf.expired_date >  p_data_s1.cp_anniv_date THEN
          LET p_benf_relation="L"    --生存受益人
       ELSE
          LET p_benf_relation="M"    --滿期受益人
       END IF
 
       SELECT count(*)
       INTO   f_benf_cnt
       FROM   benf
       WHERE  policy_no=p_data_s1.policy_no
       AND    relation =p_benf_relation

       IF f_benf_cnt !=0 THEN
          -- 100/03/31 MODIFY 根據幣別抓不同受益人匯款資料
{
          DECLARE benf_cur CURSOR FOR
                     SELECT benf.client_id
                           ,benf.benf_ratio
                           ,benf.remit_bank
                           ,benf.remit_branch
                           ,benf.remit_account
                           ,benf.benf_order
                           ,benf.names
                           ,bank.bank_name
                     FROM  benf , outer bank
                     WHERE benf.policy_no  =p_data_s1.policy_no
                     AND   benf.relation   =p_benf_relation
                     AND   bank.bank_code[1,3] = benf.remit_bank
                     AND   bank.bank_code[4,7] = benf.remit_branch
}                    
          LET f_cmd_1= ''
          IF g_polf.currency = 'TWD' THEN 
          	 LET f_cmd_1 = " SELECT benf.client_id                           ",          
                           "       ,benf.benf_ratio                          ",    
                           "       ,benf.remit_bank                          ",    
                           "       ,benf.remit_branch                        ",    
                           "       ,benf.remit_account                       ",    
                           "       ,benf.benf_order                          ",    
                           "       ,benf.names                               ",    
                           "       ,bank.bank_name                           ",
                           "       ,''                                       ",   -- payee_e 外幣使用
                           "       ,''                                       ",   -- swift_code 外幣使用
                           "       ,''                                       ",   -- bank_name_e 外幣使用 
                           "       ,''                                       ",   -- bank_address_e外幣使用 
                           " FROM  benf , outer bank                         ",    
                           " WHERE benf.policy_no  ='",p_data_s1.policy_no,"'",    
                           " AND   benf.relation   ='",p_benf_relation,"'    ",    
                           " AND   bank.bank_code[1,3] = benf.remit_bank     ",    
                           " AND   bank.bank_code[4,7] = benf.remit_branch   "   
          ELSE 
          	  LET f_cmd_1 = " SELECT benf.client_id                          ",                                 
          	               "       ,benf.benf_ratio                          ",                                 
                           "       ,benp.bank_code[1,3]                      ",
                           "       ,benp.bank_code[4,7]                      ",   
                           "       ,benp.bank_account_e                      ",                                 
                           "       ,benf.benf_order                          ",                                 
                           "       ,benf.names                               ",                                 
                           "       ,''                                       ", -- bank_name 中文名稱
                           "       ,benp.payee_e                             ",
                           "       ,benp.swift_code                          ",
                           "       ,benp.bank_name_e                         ",
                           "       ,benp.bank_address_e                      ",                                
                           " FROM  benf , outer benp                         ",                                 
                           " WHERE benf.policy_no  ='",p_data_s1.policy_no,"'",                                 
                           " AND   benf.relation   ='",p_benf_relation,"'    ",                                 
                           " AND   benf.policy_no  = benp.policy_no          ",                                 
                           " AND   benf.relation   = benp.relation           ",
                           " AND   benf.client_id  = benp.client_id          "                                     
          END IF      
          -- 100/03/31 END
         
          PREPARE cur_f_cmd_1 FROM f_cmd_1
          DECLARE benf_cur CURSOR FOR cur_f_cmd_1   
          LET p_benf_cnt = 1
          FOREACH benf_cur INTO p_data_s2[p_benf_cnt].*,p_data_s2_b[p_benf_cnt].bank_name
          	                   ,p_data_s2_c[p_benf_cnt].*                              -- 100/03/31 ADD
             --  受益人資料若是有 id 則找 clnt 的名字 --
             IF LENGTH(p_data_s2[p_benf_cnt].client_id CLIPPED) !=0 THEN
                SELECT names INTO p_data_s2[p_benf_cnt].names
                FROM   clnt
                WHERE  client_id=p_data_s2[p_benf_cnt].client_id
             END IF
             
             -- 100/03/31 ADD 外幣獨立抓銀行中文名稱
             IF g_polf.currency <> 'TWD' THEN 
                SELECT bank_name
                  INTO p_data_s2_b[p_benf_cnt].bank_name
                  FROM bank
                 WHERE bank_code[1,3] = p_data_s2[p_benf_cnt].remit_bank
                   AND bank_code[4,7] = p_data_s2[p_benf_cnt].remit_branch
             END IF
             -- 100/03/31 END
             
             LET p_benf_cnt = p_benf_cnt + 1
          END FOREACH
          FREE benf_cur
          LET p_benf_cnt=p_benf_cnt-1
       END IF
       
       
    -- 顯示取得的資料(畫面一第三部份) --
    DISPLAY BY NAME p_data_s3.*
       ATTRIBUTE (YELLOW)

    -- 顯示取得的資料(畫面一第二部份) --
    IF f_benf_cnt !=0 THEN
       FOR f_i=1 TO 2
           IF f_i > p_benf_cnt THEN
              EXIT FOR
           END IF
           DISPLAY p_data_s2[f_i].* TO psc01_s1[f_i].*   ATTRIBUTE (YELLOW)
       END FOR
    ELSE
       FOR f_i=1 TO 2
           DISPLAY p_data_s2[f_i].* TO psc01_s1[f_i].*   ATTRIBUTE (YELLOW)
       END FOR 
    END IF
    

    -- 100/03/31 END
    
    -- 顯示取得的資料(畫面一第一部份) --
    LET p_old_cp_disb_type        =f_cp_disb_type
    LET p_cp_sw                   =f_cp_sw
    LET p_data_s1.cp_disb_type    =f_cp_disb_type
    LET p_data_s1.mail_addr_ind   =f_mail_addr_ind
    LET p_data_s1.disb_special_ind=f_disb_special_ind
    LET p_data_s1.cp_pay_name     =f_cp_pay_name
    LET p_data_s1.cp_pay_id       =f_cp_pay_id
--    LET p_data_s1.dept_code       =f_cp_dept_code
    LET p_data_s1.po_sts_code     =g_polf.po_sts_code
    LET p_dept_code		  =f_cp_dept_code
    SELECT dept_name
    INTO   p_data_s1.dept_name
    FROM   dept
    WHERE  dept_code=p_dept_code
    LET p_data_s1.dept_name=p_data_s1.dept_name[1,18]
    LET p_data_s1.po_chg_rece_no = p_po_chg[1].po_chg_rece_no
{
    IF p_apdt_exist = '1' THEN
       DISPLAY "受理號碼非為89或受理中狀況非承辦中，請查核!!"
                AT 22,1
                ATTRIBUTE (RED)
    END IF
}

    IF p_sel_sw="2" THEN
       LET p_data_s1.cp_disb_type="4"
    END IF

    LET INT_FLAG=FALSE

    MESSAGE f_hotkey_msg CLIPPED
    
    -- 100/03/31 MODIFY 外幣欄位比較少，所以指令語法要一個個顯示 
    IF g_polf.currency = 'TWD' THEN  
       DISPLAY BY NAME p_data_s1.*    ATTRIBUTE (YELLOW)
    ELSE
    	 DISPLAY p_data_s1.policy_no         TO psc01_s2.policy_no          ATTRIBUTE (YELLOW)
    	 DISPLAY g_polf.currency             TO psc01_s2.currency           ATTRIBUTE (YELLOW)
    	 DISPLAY p_data_s1.po_sts_code       TO psc01_s2.po_sts_code        ATTRIBUTE (YELLOW)
    	 DISPLAY p_data_s1.cp_anniv_date     TO psc01_s2.cp_anniv_date      ATTRIBUTE (YELLOW)
       DISPLAY p_data_s1.po_chg_rece_no    TO psc01_s2.po_chg_rece_no     ATTRIBUTE (YELLOW)
       DISPLAY p_data_s1.cp_disb_type      TO psc01_s2.cp_disb_type       ATTRIBUTE (YELLOW)
    	 DISPLAY p_data_s1.disb_special_ind  TO psc01_s2.disb_special_ind   ATTRIBUTE (YELLOW)
       DISPLAY p_data_s1.cp_rtn_sw	       TO psc01_s2.cp_rtn_sw	        ATTRIBUTE (YELLOW) 
    END IF
    -- 100/03/31 END
    
    INPUT p_data_s1.cp_disb_type
         ,p_data_s1.mail_addr_ind
         ,p_data_s1.disb_special_ind
	 ,p_data_s1.cp_rtn_sw
    WITHOUT DEFAULTS
    FROM cp_disb_type
         ,mail_addr_ind
         ,disb_special_ind
	 ,cp_rtn_sw
	
	
    AFTER FIELD cp_disb_type
        -- SR151200331
		IF p_benf_cnt = 0 OR chk_benf_data() = FALSE THEN
			PROMPT "受益人空白或ID空白,請於受益人檔建檔後再回覆!(Y/N)" FOR CHAR f_ans_sw
			IF UPSHIFT(f_ans_sw) !="Y" OR
				f_ans_sw IS NULL        THEN
				NEXT FIELD cp_disb_type
			END IF
			-- ERROR "受益人空白或ID空白,請於受益人檔建檔後再回覆!"
			-- NEXT FIELD cp_disb_type 昱傑說可以讓USER繼續KEY
		END IF
		
		IF p_data_s1.cp_disb_type MATCHES "[0-5]" 
           AND p_data_s1.cp_disb_type != '5' THEN
           
           -- 105/04/01 月給付險種只能回覆 0:郵寄支票,3:電 匯,4:未回領取 	-- 105/07/20
           IF p_data_s1.cp_disb_type MATCHES "[12]" AND                              
              psc99s01_pay_modx_by_anniv (p_data_s1.policy_no, p_data_s1.cp_anniv_date) = 1 THEN                            
              ERROR "本保單為月給付，不適用此給付方式!" ATTRIBUTE (RED)
              NEXT FIELD cp_disb_type
           ELSE
              LET f_dummy_flag="ok"
           END IF
        ELSE
           IF p_data_s1.cp_disb_type = '6' THEN
              ERROR "不可選擇回流!!"
                 ATTRIBUTE (RED)
           ELSE
              ERROR "給付方式輸入錯誤!!"
                 ATTRIBUTE (RED)
           END IF
           NEXT FIELD cp_disb_type
        END IF

        IF p_data_s1.cp_disb_type="1" THEN
           CALL psc01m_disb_type_1(f_serivce_agt_name
                                  ,f_agt_deptbelong
                                  ) RETURNING f_rcode
           LET f_rcode=0
           IF LENGTH(p_data_s1.cp_pay_name CLIPPED)=0 OR
              LENGTH(p_data_s1.cp_pay_id   CLIPPED)=0 OR
              LENGTH(p_dept_code   CLIPPED)=0 THEN
              ERROR "櫃臺作業,應領人資料必須輸入 !!"
              NEXT FIELD cp_disb_type
           END IF
        ELSE
           LET p_data_s1.cp_pay_name=""
           LET p_data_s1.cp_pay_id  =""
           LET p_dept_code          =""
           LET p_data_s1.dept_name  =""
        END IF

        DISPLAY p_data_s1.cp_pay_name,p_data_s1.cp_pay_id
               ,p_data_s1.dept_name
        TO      cp_pay_name,cp_pay_id,dept_name

        -- 給付方式:抵繳保費 --
        IF p_data_s1.cp_disb_type="2" THEN
{--101/09 取消此檢核 yirong
           IF f_expired_sw ="Y" THEN
              ERROR  "滿期的保單不可選擇抵繳保費 !!"
              NEXT FIELD cp_disb_type
           END IF
}
{--101/09 取消此檢核 yirong           
           IF  p_data_s1.po_sts_code MATCHES "4[346]" THEN                 ----095/12需求PS95I99S by yirong
               DISPLAY  "本保單已不須繳交續期保費，不適用抵繳保費 !!" AT 22,1 ATTRIBUTE (RED)
               NEXT FIELD cp_disb_type
           END IF 
}
--           LET f_disb_ind = ""
           LET f_ask_error = ""
           IF  g_polf.paid_to_date > p_tran_date THEN
   
               LET f_ask_error = "此張保單應繳費日為",g_polf.paid_to_date,"，是否仍可抵繳保費"
   
               IF  error_asker(f_ask_error) THEN 
   
               ELSE 
                   NEXT FIELD cp_disb_type
               END IF
   
           END IF       

           -- 執行抵繳保費輸入他張保單程式,功能由容芳提供,程式放在 p9610.4gl --
           INITIALIZE p_pc961_data.* TO NULL
           LET p_pc961_data.policy_no    =p_data_s1.policy_no
           LET p_pc961_data.cp_anniv_date=p_data_s1.cp_anniv_date
           LET p_pc961_data.prss_code    ="EDIT"
           LET p_pc961_data.tran_date    =p_tran_date
           LET p_pc961_data.cp_pay_amt   =0
           LET p_pc961_sw=TRUE
           LET p_pc961_msg=""
           CALL pc961_process(p_pc961_data.*,p_benf_relation)
                RETURNING p_pc961_sw,p_pc961_msg,p_pc961_data.*
           IF p_pc961_sw=FALSE THEN
              ERROR p_pc961_msg
              NEXT FIELD cp_disb_type
           END IF
           IF p_pc961_msg = '本保單已無需繳費,請輸入它張保單或放棄' THEN
              ERROR p_pc961_msg
              NEXT FIELD cp_disb_type
           END IF


        END IF
{--102/10取消     
        IF p_data_s1.cp_disb_type="6" THEN     --098/03 yirong --
           IF p_tran_date > p_data_s1.cp_anniv_date THEN            
              ERROR "回覆日期大於作業日或還本週年日不適用此選項!!"
                 ATTRIBUTE (RED)
              NEXT FIELD cp_disb_type
           END IF 
                  
--           IF p_data_s1.policy_no MATCHES '181*' THEN
--              ERROR "銀保通路不適用此選項!!"
--                 ATTRIBUTE (RED)
--              NEXT FIELD cp_disb_type
--           END IF
   

           IF f_expired_sw = "Y" THEN
              LET p_relation = 'M'
           ELSE
              LET p_relation = 'L'
           END IF
           LET p_benf_cnt1 = 0
          
           SELECT COUNT(*)
             INTO p_benf_cnt1
             FROM benf
            WHERE policy_no = p_data_s1.policy_no
              AND relation = p_relation  
                     
           IF p_benf_cnt1 > 1 THEN
              ERROR "此保單為多受益人不得選回流!!"
                 ATTRIBUTE (RED)
              NEXT FIELD cp_disb_type
           END IF
        END IF
}

    BEFORE FIELD mail_addr_ind
        DISPLAY "                                                                " AT 22,1
        DISPLAY "若地址指示空白,參考保單的收費地址 !!"
                AT 22,1 
                ATTRIBUTE (RED)

    AFTER FIELD mail_addr_ind
        IF p_data_s1.mail_addr_ind !=" " THEN
           IF p_data_s1.mail_addr_ind MATCHES "[Qq]"  --
              and p_data_s1.cp_disb_type="0" THEN
              CALL ins_psc3()
           ELSE
              SELECT tel_1,tel_2 INTO p_tel_1,p_tel_2
              FROM   addr
              WHERE  client_id = p_applicant_id
              AND    addr_ind  = p_data_s1.mail_addr_ind
              IF STATUS = NOTFOUND THEN
                 ERROR "郵寄指示不存在!!"
                      ATTRIBUTE (RED)
                 NEXT FIELD mail_addr_ind
              END IF
           END IF
        END IF
        DISPLAY "" AT 22,1 

    AFTER FIELD disb_special_ind
        IF length(p_data_s1.disb_special_ind CLIPPED)=0 THEN
           LET p_data_s1.disb_special_ind="0"
           DISPLAY p_data_s1.disb_special_ind TO disb_special_ind
        END IF

        IF p_data_s1.disb_special_ind ="0" OR
           p_data_s1.disb_special_ind ="1" THEN
           LET f_dummy_flag="OK"
        ELSE
           ERROR "電匯指示錯誤!!"
                 ATTRIBUTE (RED)
           NEXT FIELD disb_special_ind
        END IF

    BEFORE FIELD cp_rtn_sw
	IF f_cp_sw="3"
	OR f_cp_sw="7" THEN
	   LET p_data_s1.cp_rtn_sw = p_pscb.cp_rtn_sw
	   DISPLAY BY NAME p_data_s1.cp_rtn_sw
	END IF

    AFTER FIELD cp_rtn_sw
	IF length(p_data_s1.cp_rtn_sw CLIPPED)=0 THEN
	   ERROR "還款指示錯誤!!" ATTRIBUTE(RED)
	   NEXT FIELD cp_rtn_sw
	ELSE
	   IF f_cp_sw="3"
	   OR f_cp_sw="7" THEN
	      IF p_data_s1.cp_rtn_sw != p_pscb.cp_rtn_sw THEN
		 ERROR "保單已作結清帳, 不可修改還款指示!!" ATTRIBUTE(RED)
		 LET p_data_s1.cp_rtn_sw = p_pscb.cp_rtn_sw
		 DISPLAY BY NAME p_data_s1.cp_rtn_sw
		 NEXT FIELD cp_rtn_sw
	      END IF
	   ELSE
	      IF p_data_s1.cp_rtn_sw = "0" THEN
{--101/09取消此檢核yirong
	         IF p_benf_relation = "M" THEN
		    ERROR "滿期保單, 不可選擇不還款!!" ATTRIBUTE(RED)
		    NEXT FIELD cp_rtn_sw
	         END IF
}
	         IF p_pscb.overloan_sw = "1" THEN
		    ERROR "此保單會 OverLoan, 不可選擇不還款!!" ATTRIBUTE(RED)
		    NEXT FIELD cp_rtn_sw
	         END IF
	      ELSE
	         IF p_data_s1.cp_rtn_sw = "1" THEN
		    LET f_dummy_flag = "OK"
	         ELSE
		    ERROR "還款指示錯誤!!" ATTRIBUTE(RED)
		    NEXT FIELD cp_rtn_sw
	         END IF
	      END IF
	   END IF
           IF p_pscb.guarantee_sw = 'Y' OR  p_pscb.guarantee_sw = 'N' THEN
              IF p_data_s1.cp_rtn_sw != '1' THEN
                 ERROR "已進入保證期須強制還款!!" ATTRIBUTE(RED)
                 NEXT FIELD cp_rtn_sw
              END IF
           END IF

              
	END IF
    ON KEY (F2)
       LET f_rece = display_rece_no()
       LET p_data_s1.po_chg_rece_no = p_po_chg[f_rece].po_chg_rece_no
       DISPLAY p_data_s1.po_chg_rece_no TO po_chg_rece_no

    ON KEY (F5) -- 地址指示,容芳提供功能 --
    	 -- 100/03/31 MODIFY 外幣無此功能
    	 IF g_polf.currency = 'TWD' THEN
            LET  p_data_s1.mail_addr_ind = ' '
            CALL disp_addr(p_applicant_id) RETURNING p_data_s1.mail_addr_ind
            DISPLAY p_data_s1.mail_addr_ind TO mail_addr_ind

            IF INT_FLAG = TRUE THEN
               LET INT_FLAG = FALSE
            END IF    
         
         
{
          LET  p_pce_param="1"
          LET  f_addr_cmd="pce01m.4ge "
                         ,p_pce_param
                         ," "
                         ,p_data_s1.policy_no
                         ," "
                         ,p_applicant_id," ","R0"
          
          RUN f_addr_cmd
}
          MESSAGE f_hotkey_msg CLIPPED
       END IF
       -- 100/03/31 END
       
    ON KEY (F6) -- 受益人作業 --
       IF p_benf_cnt !=0 THEN
          CALL psc01m_edit_benf()
               RETURNING f_rcode
         
          MESSAGE f_hotkey_msg CLIPPED
          IF f_rcode !=0 THEN
             LET INT_FLAG=FALSE
             NEXT FIELD cp_disb_type
          ELSE 
             FOR f_i=1 to 2
                 DISPLAY p_data_s2[f_i].* TO psc01_s1[f_i].*                         ATTRIBUTE (YELLOW)
             END FOR
             NEXT FIELD cp_disb_type
          END IF
       ELSE
          ERROR "此保單無受益人資料,不可按 F6"
                ATTRIBUTE (RED)
          NEXT FIELD cp_disb_type         
       END IF

    ON KEY (F8) -- 指定電匯作業 --
       IF p_data_s1.disb_special_ind="1" THEN
       	  --100/03/31 MODIFY
       	  IF g_polf.currency = 'TWD' THEN
             CALL psc01m_edit_pscs()
                  RETURNING f_rcode
          ELSE
          	 CALL psc01m_edit_pscy()
                  RETURNING f_rcode
          END IF
          --100/03/31 END
          
          MESSAGE f_hotkey_msg CLIPPED
          IF f_rcode !=0 THEN
             LET INT_FLAG=FALSE
             NEXT FIELD disb_special_ind
          ELSE
             NEXT FIELD disb_special_ind
          END IF
       END IF

    ON KEY (F9) -- 註記查詢 --
       CALL pscninq(p_data_s1.policy_no,p_data_s1.cp_anniv_date)
            RETURNING f_pscninq_sw
       MESSAGE f_hotkey_msg CLIPPED

    ON KEY (F7) -- 銀行資料維護作業 --
    	 --100/03/31 MODIFY
       IF g_polf.currency = 'TWD' THEN
          LET f_bank_cmd = "pd121m.4ge"	 
       ELSE
          LET f_bank_cmd = "db020m.4ge"	  	
       END IF
       --100/03/31 END
         
       RUN f_bank_cmd
       MESSAGE f_hotkey_msg CLIPPED

    AFTER INPUT

       IF INT_FLAG=TRUE THEN
          EXIT INPUT
       END IF

       -- 回覆作業  --
       IF p_sel_sw="1" THEN
          IF p_cp_notice_code="2"  THEN  -- 未回領取 --
             IF p_data_s1.cp_disb_type !="4" THEN
                ERROR "是未回覆件處理,不可選擇其他付款方式!!"
                      ATTRIBUTE (RED)
                NEXT FIELD cp_disb_type
             END IF
          END IF
          IF p_data_s1.cp_disb_type ="4" THEN
             IF p_cp_notice_code !="2" THEN
                ERROR "非未回覆件處理,不可選擇 4 付款方式!!"
                      ATTRIBUTE (RED)
                NEXT FIELD cp_disb_type
             END IF
          END IF 
       END IF

       -- 單筆未回進入領取作業 --
       IF p_sel_sw="2" THEN
          IF p_data_s1.cp_disb_type !="4" THEN
             ERROR "單筆未回覆作業,領取方式須為 4 !!"
             NEXT FIELD cp_disb_type
          END IF
          LET p_data_s1.cp_disb_type="4"
       END IF

       -- 給付方式:抵繳保費 --
       IF p_data_s1.cp_disb_type="2" THEN
{-----101/11yirong取消此檢核
          IF f_expired_sw ="Y" THEN
             ERROR  "滿期的保單不可選擇抵繳保費 !!"
             NEXT FIELD cp_disb_type
          END IF
}
          -- after input 不在執行一次抵繳編輯 --
          IF p_pc961_sw=FALSE THEN
             ERROR p_pc961_msg
             NEXT FIELD cp_disb_type
          END IF

       END IF

       IF p_data_s1.cp_disb_type="4" THEN
          LET p_data_s1.disb_special_ind="0"
          LET p_data_s1.cp_pay_name	=""
          LET p_data_s1.cp_pay_id	=""
          LET p_dept_code		=""
          LET p_data_s1.dept_name	=""
       END IF

       -- 付款為櫃臺的檢核 --
       IF p_data_s1.cp_disb_type !="1" THEN
          LET p_data_s1.cp_pay_name	=""
          LET p_data_s1.cp_pay_id	=""
          LET p_dept_code		=""
          LET p_data_s1.dept_name	=""
          LET p_tel_3                   =""
       ELSE
          IF length(p_data_s1.cp_pay_name CLIPPED) =0 OR
             length(p_data_s1.cp_pay_id   CLIPPED) =0 OR
             length(p_dept_code   CLIPPED) =0 THEN
             ERROR "付款方式為櫃臺,必須輸入應領資料 !!"
                    ATTRIBUTE (RED)
                    NEXT FIELD cp_disb_type
          END IF

          IF p_dept_code="90000"  OR
             p_dept_code="91000"  OR
             p_dept_code="93000"  OR
             p_dept_code="94000"  OR
             p_dept_code="95000"  OR
             p_dept_code="96000"  OR
             p_dept_code="97000"  OR
             p_dept_code="98000"  OR    
             p_dept_code="92000"  OR
             p_dept_code="9A000"  OR
             p_dept_code="9B000"  THEN
             LET f_dummy_flag="OK"
          ELSE
             ERROR "領取地區錯誤!!"
                    ATTRIBUTE (RED)
                    NEXT FIELD cp_disb_type
          END IF
       END IF

       IF p_data_s1.cp_disb_type !="3" AND
          p_data_s1.disb_special_ind="1" THEN
          ERROR "給付非電匯,電匯指示須為 0 !!"
          NEXT FIELD cp_disb_type
       END IF

       -- 無受益人資料 --
       IF f_benf_cnt=0 THEN
          IF p_data_s1.cp_disb_type="3" THEN
             IF p_data_s1.disb_special_ind !="1" THEN
                ERROR "此保單無受益人資料,電匯必須是指定電匯!!"
                      ATTRIBUTE (RED)
                NEXT FIELD cp_disb_type
             END IF
          END IF
       END IF

       -- 資料檢查   --

       IF p_data_s1.cp_disb_type="3" THEN

          -- 100/03/31 MODIFY
          IF g_polf.currency = 'TWD' THEN
             IF p_data_s1.disb_special_ind="1" THEN
          	 
                SELECT * 
                FROM  pscs
                WHERE policy_no=p_data_s1.policy_no
                AND   cp_anniv_date=p_data_s1.cp_anniv_date

                IF STATUS = NOTFOUND THEN
                   ERROR "電匯指示，指定電匯無資料!!"
                         ATTRIBUTE (RED)
                   NEXT FIELD cp_disb_type
                END IF
             ELSE
                DECLARE benf_cur_1 CURSOR FOR
                        SELECT client_id
                              ,benf_ratio
                              ,remit_bank
                              ,remit_branch
                              ,remit_account
                              ,benf_order
                              ,names
                        FROM  benf
                        WHERE policy_no  =p_data_s1.policy_no
                        AND   relation   =p_benf_relation
                
                LET f_j = 1
                LET f_disb_err = 0
                FOREACH benf_cur_1 INTO p_data_s2[f_j].*
                  --  受益人資料若是有 id 則找 clnt 的名字 --
                  IF LENGTH(p_data_s2[f_j].client_id CLIPPED) !=0 THEN
                     SELECT names INTO p_data_s2[f_j].names
                     FROM   clnt
                     WHERE  client_id=p_data_s2[f_j].client_id
                  END IF
               
                  IF p_data_s2[f_j].remit_bank IS NULL OR
                     p_data_s2[f_j].remit_bank=" "     THEN
                     ERROR "受益人的匯款銀行必須有值!!"
                     LET f_disb_err=1
                     EXIT FOREACH
                  END IF
                  
                  IF p_data_s2[f_j].remit_branch IS NULL  OR
                     p_data_s2[f_j].remit_branch =" "     THEN
                     ERROR "受益人的匯款分行必須有值!!"
                     LET f_disb_err=1
                     EXIT FOREACH
                  END IF
                     
                  IF p_data_s2[f_j].remit_account IS NULL OR
                     p_data_s2[f_j].remit_account=" "     THEN
                     ERROR "受益人的匯款帳號必須有值!!"
                     LET f_disb_err=1
                     EXIT FOREACH
                  END IF
                  
                  -- 090/05/02 JC 修改 --
                  CALL chkRemitAcct(p_data_s2[f_j].remit_bank
                                   ,p_data_s2[f_j].remit_branch
                                   ,p_data_s2[f_j].remit_account
                                  )
                       RETURNING f_chk_remit_err,f_chk_remit_msg
                  IF f_chk_remit_err !="0" THEN
                     ERROR f_chk_remit_msg  ATTRIBUTE(RED)
                     LET f_disb_err=1
                     EXIT FOREACH
                  END IF
                  
                  IF f_j=1 OR
                     f_j=2 THEN
                     DISPLAY p_data_s2[f_j].*
                     TO      psc01_s1[f_j].*
                             ATTRIBUTE (YELLOW)
                  END IF
                  LET f_j = f_j + 1
               
                END FOREACH
                
                FREE benf_cur_1
          
                IF f_disb_err=1 THEN
                   NEXT FIELD cp_disb_type
                END IF
                LET f_j=f_j-1
             END IF -- disb_special_ind="1" --
          ELSE
          	 IF p_data_s1.disb_special_ind="1" THEN
                SELECT * 
                FROM  pscy
                WHERE policy_no=p_data_s1.policy_no
                AND   cp_anniv_date=p_data_s1.cp_anniv_date

                IF STATUS = NOTFOUND THEN
                   ERROR "電匯指示，指定電匯無資料!!"
                         ATTRIBUTE (RED)
                   NEXT FIELD cp_disb_type
                END IF
             ELSE
             	  LET f_client_id =''
             	  DECLARE benf_cur_2 CURSOR FOR
                        SELECT client_id
                        FROM  benf
                        WHERE policy_no  =p_data_s1.policy_no
                        AND   relation   =p_benf_relation

                LET f_disb_err = 0
                FOREACH benf_cur_2 INTO f_client_id
                  
                  LET f_swift_code     = ''
                  LET f_bank_account_e = ''
                             
                  
             	    -- 要檢查外幣帳號要建立(其餘細部檢核由payforeign處理)
                  LET p_cp_pay_amt = 0
                  LET p_cp_pay_amt = p_cp_amt - g_polf.apl_amt - g_polf.apl_int_balance
                                    - g_polf.loan_amt - g_polf.loan_int_balance
                  IF p_cp_pay_amt <= 0 AND p_data_s1.cp_rtn_sw = '1' THEN
                     PROMPT "實付金額為0,是否不建外幣帳號 Y/N" FOR CHAR f_ans_sw
                     IF UPSHIFT(f_ans_sw) ="Y" OR
                        f_ans_sw IS NULL        THEN
                     ELSE
                        ERROR "受益人的匯款銀行SWIFT必須有值!!"
                        LET f_disb_err=1
                        EXIT FOREACH
                     END IF
                  ELSE
                     SELECT swift_code, bank_account_e
                       INTO f_swift_code, f_bank_account_e
                       FROM benp
                      WHERE policy_no  = p_data_s1.policy_no
                        AND relation   = p_benf_relation
                        AND client_id  = f_client_id

                     IF f_swift_code IS NULL OR
                        f_swift_code=" "     THEN
                        ERROR "受益人的匯款銀行SWIFT必須有值!!"
                        LET f_disb_err=1
                        EXIT FOREACH
                     END IF
       
                     IF f_bank_account_e IS NULL OR
                        f_bank_account_e=" "     THEN
                        ERROR "受益人的外幣匯款帳號必須有值!!"
                        LET f_disb_err=1
                        EXIT FOREACH
                     END IF
                  END IF
               END FOREACH
               IF f_disb_err=1 THEN
                   NEXT FIELD cp_disb_type
                END IF
             END IF
          END IF -- g_polf.currency = 'TWD' --
       END IF -- cp_disb_type="3" --
       
       IF p_data_s1.mail_addr_ind !=" "THEN
          IF p_data_s1.mail_addr_ind MATCHES "[Qq]" THEN
          ELSE
  
             SELECT tel_1,tel_2 INTO p_tel_1,p_tel_2
             FROM   addr
             WHERE  client_id = p_applicant_id
             AND    addr_ind  = p_data_s1.mail_addr_ind
             IF STATUS = NOTFOUND THEN
                ERROR "郵寄指示不存在!!"
                     ATTRIBUTE (RED)
                NEXT FIELD mail_addr_ind
             END IF
          END IF
       END IF

       IF length(p_data_s1.cp_rtn_sw CLIPPED)=0 THEN
	  ERROR "還款指示錯誤!!" ATTRIBUTE(RED)
          NEXT FIELD cp_rtn_sw
       ELSE
	  IF f_cp_sw="3"
	  OR f_cp_sw="7" THEN
	     IF p_data_s1.cp_rtn_sw != p_pscb.cp_rtn_sw THEN
                ERROR "保單已作結清帳, 不可修改還款指示!!" ATTRIBUTE(RED)
                LET p_data_s1.cp_rtn_sw = p_pscb.cp_rtn_sw
                DISPLAY BY NAME p_data_s1.cp_rtn_sw
                NEXT FIELD cp_rtn_sw
             END IF
          ELSE
             IF p_data_s1.cp_rtn_sw = "0" THEN
	        IF p_benf_relation = "M" THEN
		   ERROR "滿期保單, 不可選擇不還款!!" ATTRIBUTE(RED)
		   NEXT FIELD cp_rtn_sw
	        END IF
                IF p_pscb.overloan_sw = "1" THEN
                   ERROR "此保單會 OverLoan, 不可選擇不還款!!" ATTRIBUTE(RED)
                   NEXT FIELD cp_rtn_sw
                END IF
             ELSE
                IF p_data_s1.cp_rtn_sw = "1" THEN
                   LET f_dummy_flag = "OK"
                ELSE
                   ERROR "還款指示錯誤!!" ATTRIBUTE(RED)
                   NEXT FIELD cp_rtn_sw
                END IF
             END IF
	  END IF
       END IF
  
       ------保證給付期警訊------
       IF p_pscb.guarantee_sw = 'Y' THEN
          ERROR "本次生存金為保證給付期，請留意！"
       END IF

       ------過保證期再次確認------
       IF psc_after_gee_chk(p_data_s1.policy_no,p_data_s1.cp_anniv_date) THEN
          PROMPT "本次生存金為非保證給付期，請做被保險人之生存認證(Y/N)" FOR CHAR f_ans_sw
          IF UPSHIFT(f_ans_sw) !="Y" OR
             f_ans_sw IS NULL        THEN
             NEXT FIELD cp_disb_type
          END IF
       END IF  


       LET f_ans_sw=""
       LET f_ans_sw1=""
       LET p_online_prc = "0"
       PROMPT "確認存檔請按 Y" FOR CHAR f_ans_sw
       IF UPSHIFT(f_ans_sw) !="Y" OR
          f_ans_sw IS NULL        THEN
          NEXT FIELD cp_disb_type
       ELSE
          IF g_polf.currency = 'USD' THEN
             IF usd_notify(p_data_s1.cp_anniv_date) THEN 
                ERROR "尚有還本週年日未回覆！！"
{
                LET f_ans_sw=""
                PROMPT "尚有還本週年日未回覆" FOR CHAR f_ans_sw
                IF UPSHIFT(f_ans_sw) !="Y" OR
                   f_ans_sw IS NULL        THEN
                   NEXT FIELD cp_disb_type
                END IF
}
             END IF
          END IF
          IF p_data_s1.cp_disb_type="1" THEN
             IF p_tran_date >= p_data_s1.cp_anniv_date THEN
                PROMPT "已屆保單周年日，是否執行過帳(Y/N)" FOR CHAR f_ans_sw1
                IF UPSHIFT(f_ans_sw1) !="Y" OR
                   f_ans_sw1 IS NULL        THEN
                ELSE
display 'into pscw'
                   LET p_online_prc = "1"
                   CALL ins_pscw() RETURNING f_rcode 
                   IF NOT f_rcode THEN
display "insert pscw error !!"
                   END IF
                END IF 
             END IF
             IF LENGTH(p_tel_3 CLIPPED) > 0 THEN
display 'INSERT psc4=',p_tel_3
                SELECT count(*)
                  INTO f_psc4_cnt 
                  FROM psc4
                 WHERE policy_no = p_data_s1.policy_no
                   AND cp_anniv_date = p_data_s1.cp_anniv_date
                   AND psc_type = '2' 
                IF f_psc4_cnt > 0 THEN
                   DELETE FROM psc4
                    WHERE policy_no=p_data_s1.policy_no
                      AND cp_anniv_date = p_data_s1.cp_anniv_date
                      AND psc_type='2'
                END IF

 
                INSERT INTO psc4 VALUES(
                       p_data_s1.policy_no,
                       p_data_s1.cp_anniv_date,
                       '',
                       '2',
                       p_tel_3,
                       g_user,
                       p_dept_code,
                       p_tran_date)
             
             END IF          
          END IF 
       END IF

    END INPUT

    -- 中斷作業 --
    IF INT_FLAG=TRUE THEN
       LET f_rcode=1
       ERROR "領取作業放棄"
             ATTRIBUTE (RED)
       RETURN f_rcode
    END IF

    LET f_mail_addr_ind=p_data_s1.mail_addr_ind

    -- 更新檔案 --
    CALL psc01m_save_data() 
         RETURNING f_rcode
    IF f_rcode !=0 THEN
       ERROR "update pscb error !!"
            ATTRIBUTE (RED)       
       LET f_rcode=1
    END IF

    -- 100/03/31 ADD 外幣要關閉另外一個FORM
    IF g_polf.currency <> 'TWD' THEN
    	 CLOSE FORM psc00m11
    ELSE
    	 CLOSE FORM psc00m00  -- 101/02/20 ADD 回覆時切換外幣/台幣保單，需關閉FORM 
    END IF
    -- 100/03/31 ADD
    
    MESSAGE " "
    RETURN f_rcode
END FUNCTION   -- psc01m_query --

------------------------------------------------------------------------------
--  函式名稱: psc01m_query_pt
--  作    者: kurt
--  日    期: 094/05/26
--  處理概要: SIPA查詢作業,查詢畫面
--  重要函式:
------------------------------------------------------------------------------

FUNCTION psc01m_query_pt()
    
    DEFINE f_rcode              INTEGER
          ,f_dummy_flag         CHAR(2)
          ,f_ans_sw             CHAR(1)   -- prompt 的回覆 --
          ,f_expired_sw         CHAR(1)
          ,f_psck_sw            CHAR(1)
          ,f_psck_cnt           INTEGER
          ,f_pscninq_sw         INTEGER

    DEFINE f_po                 CHAR(255) -- 取得 po 資訊的 prepare --
    DEFINE f_addr_cmd           CHAR(255) -- 執行地址的修改新增作業 --
    DEFINE f_bank_cmd		CHAR(255) -- 執行銀行資料維護作業 --
    DEFINE f_i                  INTEGER   -- array 計數器 --
          ,f_benf_cnt           INTEGER   -- 受益人計數器 --
          ,f_arr_cur            INTEGER   -- 受益人輸入的計數 --
          ,f_scr_cur            INTEGER   -- 受益人畫面的計數 --
          ,f_disb_err           INTEGER   -- 受益人銀行帳號有錯 --
          ,f_chk_remit_err      INTEGER 
          ,f_chk_remit_msg      CHAR(255)

    DEFINE f_pscb_cnt           INTEGER   -- 執行 perpare 指令有保單可執行 --
          ,f_polf_cnt           INTEGER   -- polf 是否存在 input 保單 --
          ,f_right_or_fault     INTEGER   -- 日期檢查 t or f --
          ,f_formated_date      CHAR(9)   -- 日期格式化 999/99/99 --
          ,f_benf_relation      CHAR(1)   -- 滿期/生存 受益人 --
          ,f_serivce_agt_name   CHAR(40)  -- 服務業務員_name --
          ,f_agt_deptbelong     CHAR(6)   -- agent 所屬分公司 --

    DEFINE f_cp_anniv_date      LIKE    pscb.cp_anniv_date
          ,f_cp_sw              LIKE    pscb.cp_sw
          ,f_cp_disb_type       LIKE    pscb.cp_disb_type
          ,f_mail_addr_ind      LIKE    pscb.mail_addr_ind
          ,f_disb_special_ind   LIKE    pscb.disb_special_ind
          ,f_pay_ind            CHAR(1)
          ,f_cp_pay_name        CHAR(12)
          ,f_cp_pay_id          LIKE    pscb.cp_pay_id
          ,f_cp_dept_code       LIKE    pscb.dept_code

    DEFINE f_cp_notice_formtype LIKE pscr.cp_notice_formtype
          ,f_chk_sw             LIKE pscr.cp_chk_sw
          ,f_chk_date           LIKE pscr.cp_chk_date

    DEFINE f_arr                INTEGER
          ,f_dtl_cp_ann         LIKE    pscb.cp_anniv_date

    DEFINE f_client_ident       LIKE    colf.client_ident
          ,f_applicant_id       LIKE    clnt.client_id
          ,f_insured_id         LIKE    clnt.client_id
          ,f_addr_id            LIKE    clnt.client_id
          ,f_addr_ind           LIKE    addr.addr_ind
          ,f_zip_code           LIKE    addr.zip_code
          ,f_address            LIKE    addr.address
          ,f_app_name           LIKE    clnt.names
          ,f_insured_name       LIKE    clnt.names


    MESSAGE " END:取消"

    LET INT_FLAG      =FALSE
    LET f_client_ident=" "
    LET f_applicant_id=" "
    LET f_app_name    =" "
    LET f_insured_id  =" "
    LET f_insured_name=" "
    LET f_addr_id     =" "
    LET f_addr_ind    ="0"
    LET f_zip_code    =" "
    LET f_address     =" "
    LET f_chk_date    =" "
    LET f_chk_sw      =" "
    LET f_psck_sw     =" "

    LET f_psck_cnt    =0
    LET f_pscb_cnt    =0
    LET f_polf_cnt    =0
    LET f_benf_cnt    =0
    LET p_data_s1.policy_no=p_policy_no
    LET p_data_s1.cp_anniv_date=p_cp_anniv_date
    -- 資料檢查 --


    -- 滿期 or 生存 --
    IF g_poia.expired_date <= p_data_s1.cp_anniv_date THEN
       LET f_expired_sw="Y"
    ELSE
       LET f_expired_sw="N"
    END IF

    SELECT count(*) INTO f_pscb_cnt
    FROM   ptpr
    WHERE  policy_no  = p_data_s1.policy_no
    AND    payout_due = p_data_s1.cp_anniv_date
--    AND    cp_sw  in ("1","3","4","7","8")

    IF f_pscb_cnt is null OR
       f_pscb_cnt =0      THEN
       ERROR "此張保單無給付資料!!"
             ATTRIBUTE (RED)
       LET f_rcode=1
       RETURN f_rcode
    END IF

    -- 還本註記 --
    SELECT count(*) INTO f_psck_cnt
    FROM   psck
    WHERE  policy_no=p_data_s1.policy_no
    AND    cp_anniv_date=p_data_s1.cp_anniv_date
    IF f_psck_cnt=0 THEN
       LET f_psck_sw="N"
    ELSE
       LET f_psck_sw="Y"
    END IF


    LET f_pscb_cnt=0
    LET f_polf_cnt=0
    LET f_benf_cnt=0
    LET p_benf_cnt=0

    SELECT * INTO g_ptpr.*
    FROM   ptpr
    WHERE  policy_no    =p_policy_no
    AND    payout_due   =p_data_s1.cp_anniv_date

    LET f_cp_sw             = '1'
--  LET f_cp_disb_type      = '3'----從ptpc取得
--  LET f_mail_addr_ind     = g_ptpc.mail_addr_ind
    LET f_disb_special_ind  = '0'
    LET f_cp_pay_name       = ''
    LET f_cp_pay_id         = ''
    LET f_cp_dept_code      = ''

    -- 畫面一的第三部資料 --
        LET p_data_s3.psck_sw       = f_psck_sw
        LET p_data_s3.overloan_desc = "N"
	IF g_ptpr.live_certi_ind = "Y" THEN
	   LET p_data_s3.notice_resp_desc = "Y"
	ELSE
           LET p_data_s3.notice_resp_desc = "N"
	END IF

        -- 要保人ID,姓名 --
        CALL getNames(p_data_s1.policy_no,'O1')
             RETURNING p_applicant_id,p_applicant_name

        -- 被保人ID,姓名 --
        LET f_chk_sw = 'Y'
        LET f_chk_date = ''
        LET p_coverage_no=1
        LET f_client_ident='I1'

        SELECT client_ident
        INTO   f_client_ident
        FROM   coia
        WHERE  policy_no=p_data_s1.policy_no
        AND    coverage_no=1

        CALL getNames(p_data_s1.policy_no,f_client_ident)
             RETURNING f_insured_id,f_insured_name

        LET p_data_s3.app_name    =p_applicant_name[1,12] CLIPPED
        LET p_data_s3.app_id	  =p_applicant_id
        LET p_data_s3.insured_name=f_insured_name[1,12]   CLIPPED
        LET p_data_s3.insured_id  =f_insured_id

    -- 畫面一的第二部資料,受益人資料 --

       SELECT count(*)
       INTO   f_benf_cnt
       FROM   ptpc
       WHERE  policy_no = p_data_s1.policy_no
       AND    active_sw = '1'

       IF f_benf_cnt !=0 THEN

          LET f_i=1
          DECLARE ptpc_cur CURSOR FOR
                  SELECT client_id
                        ,pay_dividend
                        ,remit_bank
                        ,remit_branch
                        ,remit_account
                        ,''
                        ,names
                        ,mail_addr_ind
                        ,pay_method
                  FROM  ptpc
                  WHERE policy_no  = p_data_s1.policy_no
                  AND   active_sw  = '1'

          LET p_benf_cnt = 1

          FOREACH ptpc_cur INTO p_data_s2[p_benf_cnt].*,p_data_s21[p_benf_cnt].*

             --  受益人資料若是有 id 則找 clnt 的名字 --
             IF LENGTH(p_data_s2[p_benf_cnt].client_id CLIPPED) !=0 THEN
                SELECT names INTO p_data_s2[p_benf_cnt].names
                FROM   clnt
                WHERE  client_id=p_data_s2[p_benf_cnt].client_id
             END IF
             LET f_mail_addr_ind=p_data_s21[p_benf_cnt].mail_addr_ind
             IF  p_data_s21[p_benf_cnt].pay_method = '1' THEN  --匯款
                 LET f_cp_disb_type = '3'
             ELSE
                 LET f_cp_disb_type = '0'
             END IF
             LET p_benf_cnt = p_benf_cnt + 1
          END FOREACH
          FREE benf_cur
          LET p_benf_cnt=p_benf_cnt-1
       END IF

    -- 顯示取得的資料(畫面一第三部份) --
    DISPLAY BY NAME p_data_s3.*
       ATTRIBUTE (YELLOW)

    -- 顯示取得的資料(畫面一第二部份) --
    IF f_benf_cnt !=0 THEN
       FOR f_i=1 TO 2
           IF f_i > p_benf_cnt THEN
              EXIT FOR
           END IF
           DISPLAY p_data_s2[f_i].* TO psc01_s1[f_i].*
                   ATTRIBUTE (YELLOW)
       END FOR
    ELSE
       FOR f_i=1 TO 2
           DISPLAY p_data_s2[f_i].* TO psc01_s1[f_i].*
                   ATTRIBUTE (YELLOW)
       END FOR 
    END IF

    -- 顯示取得的資料(畫面一第一部份) --
    LET p_old_cp_disb_type        =f_cp_disb_type
    LET p_cp_sw                   =f_cp_sw
    LET p_data_s1.cp_disb_type    =f_cp_disb_type
    LET p_data_s1.mail_addr_ind   =f_mail_addr_ind
    LET p_data_s1.disb_special_ind=f_disb_special_ind
    LET p_data_s1.cp_rtn_sw       ='0'
    LET p_data_s1.cp_pay_name     =f_cp_pay_name
    LET p_data_s1.cp_pay_id       =f_cp_pay_id
--    LET p_data_s1.dept_code       =f_cp_dept_code
    LET p_data_s1.po_sts_code     =g_poia.po_sts_code
    LET p_dept_code		  =f_cp_dept_code
    SELECT dept_name
    INTO   p_data_s1.dept_name
    FROM   dept
    WHERE  dept_code=p_dept_code
    LET p_data_s1.dept_name=p_data_s1.dept_name[1,18]


    LET INT_FLAG=FALSE

    MESSAGE "END:放棄,F9:註記,F7:銀行資料維護作業"

    DISPLAY BY NAME p_data_s1.*
       ATTRIBUTE (YELLOW)

    INPUT p_data_s1.cp_disb_type
--         ,p_data_s1.mail_addr_ind
    WITHOUT DEFAULTS
    FROM  cp_disb_type
--         ,mail_addr_ind

    BEFORE FIELD cp_disb_type
        DISPLAY "給付回覆不需要選擇，請直接按 ESC 繼續!!"
                AT 22,1 
                ATTRIBUTE (RED)
	-- SR151200331
    AFTER FIELD cp_disb_type
        DISPLAY "                                                   "  AT 22,1
		IF p_benf_cnt = 0 OR chk_benf_data() = FALSE THEN
			PROMPT "受益人空白或ID空白,請於受益人檔建檔後再回覆!(Y/N)" FOR CHAR f_ans_sw
			IF UPSHIFT(f_ans_sw) !="Y" OR
				f_ans_sw IS NULL        THEN
				NEXT FIELD cp_disb_type
			END IF
			-- ERROR "受益人空白或ID空白,請於受益人檔建檔後再回覆!"
			-- NEXT FIELD cp_disb_type 昱傑說可以讓USER繼續KEY
		END IF

    ON KEY (F9) -- 註記查詢 --
       CALL pscninq(p_data_s1.policy_no,p_data_s1.cp_anniv_date)
            RETURNING f_pscninq_sw
       MESSAGE "END:放棄,F9:註記,F7:銀行資料維護作業"

    ON KEY (F7) -- 銀行資料維護作業 --
       LET f_bank_cmd = "pd121m.4ge"	 
       RUN f_bank_cmd
       MESSAGE "END:放棄,F9:註記,F7:銀行資料維護作業"

    AFTER INPUT

       IF INT_FLAG=TRUE THEN
          EXIT INPUT
       END IF

       LET f_ans_sw=""
       PROMPT "確認存檔請按 Y" FOR CHAR f_ans_sw
       IF UPSHIFT(f_ans_sw) !="Y" OR
          f_ans_sw IS NULL        THEN
          NEXT FIELD cp_disb_type
       END IF

    END INPUT

    -- 中斷作業 --
    IF INT_FLAG=TRUE THEN
       LET f_rcode=1
       ERROR "領取作業放棄"
             ATTRIBUTE (RED)
       RETURN f_rcode
    END IF

    LET f_mail_addr_ind = p_data_s1.mail_addr_ind
--    LET p_data_s1.mail_addr_ind = f_mail_addr_ind

    -- 更新檔案 --
    CALL psc01m_save_data_pt()
         RETURNING f_rcode
    IF f_rcode !=0 THEN
       ERROR "update pscb error !!"
            ATTRIBUTE (RED)       
       LET f_rcode=1
    END IF

    MESSAGE " "
    RETURN f_rcode
END FUNCTION   -- psc01m_query_pt --

------------------------------------------------------------------------------
--  函式名稱: psc01m_save_data_pt
--  作    者: kurt
--  日    期: 094/05/27
--  處理概要: 給付回覆作業,確認
--  重要函式:
------------------------------------------------------------------------------
FUNCTION psc01m_save_data_pt()
    DEFINE f_rcode   INTEGER
    DEFINE f_pscs_sw INTEGER
    DEFINE f_cp_notice_sw CHAR(1)
    DEFINE f_pscs    RECORD LIKE pscs.*
    DEFINE f_due_date CHAR(9)

    LET f_rcode=0
    LET f_pscs_sw=0

    BEGIN WORK
    WHENEVER ERROR CONTINUE

    IF length(p_cp_notice_code CLIPPED)=0 THEN
       LET f_cp_notice_sw=p_pscb.cp_notice_sw
    END IF

    IF p_cp_notice_code="0" OR     ----文件齊全，照會回覆入給付
       p_cp_notice_code="3" THEN
       LET f_cp_notice_sw="2"      ----已回覆, 進入領取給付
    END IF

    IF p_cp_notice_code="1" THEN    ----文件不齊全
       IF p_cp_notice_sub_code="0" THEN
          LET f_cp_notice_sw="2"
       END IF
    END IF

----同步更新ptpm.mail_ptpr_ind 郵寄通知指示，有回覆下次才會寄出認證信
    UPDATE ptpm
    SET    mail_ptpr_ind  = 'Y'
    WHERE  policy_no      = p_data_s1.policy_no
--      AND  payout_seq    != 'N'
    IF SQLCA.SQLCODE !=0 THEN
       ROLLBACK WORK
       LET f_rcode=1
display 'err update ptpm'
       RETURN f_rcode
    END IF
----
    UPDATE ptpd
    SET    opt_notice_sw  = '2'
          ,payout_ind     = 'Y'
          ,process_date   = p_tx_date
          ,process_user   = g_user
    WHERE  policy_no      = p_data_s1.policy_no
      AND  payout_due     = p_data_s1.cp_anniv_date
      AND  payout_ind       != 'N'
    IF SQLCA.SQLCODE !=0 THEN
       ROLLBACK WORK
       LET f_rcode=1
display 'err update ptpd'
       RETURN f_rcode
    END IF
    ----同步更新認證回覆，小於回覆日的認證
    IF  p_tx_date < p_data_s1.cp_anniv_date THEN
        LET f_due_date = p_data_s1.cp_anniv_date
    ELSE
        LET f_due_date = p_tx_date
    END IF
    UPDATE ptpd
    SET    opt_notice_sw  = '2'
          ,payout_ind     = 'Y'
          ,process_date   = p_tx_date
          ,process_user   = g_user
    WHERE  policy_no      = p_data_s1.policy_no
      AND  payout_due     < f_due_date
      AND  payout_ind       != 'N'
      AND  opt_notice_sw  = '1'
    IF SQLCA.SQLCODE !=0 THEN
    ELSE
display '同步更新認證回覆筆數=',SQLCA.SQLERRD[3],'認證日小於',f_due_date
    END IF

    COMMIT WORK

    RETURN f_rcode
    WHENEVER ERROR STOP
END FUNCTION -- psd01m_save_data_pt --
------------------------------------------------------------------------------
--  函式名稱: psc01m_save_data
--  作    者: jessica Chang
--  日    期: 87/08/04
--  處理概要: 還本回覆作業,確認
--  重要函式:
------------------------------------------------------------------------------
FUNCTION psc01m_save_data()
    DEFINE f_rcode   INTEGER
    DEFINE f_pscs_sw INTEGER
          ,f_cp_notice_sw CHAR(1)
    DEFINE f_pscs    RECORD LIKE pscs.*
    DEFINE f_i       INTEGER
    DEFINE f_msg     CHAR(100)
    DEFINE f_nonresp_cnt INTEGER 
    DEFINE f_prompt_ans  CHAR(1)

    LET f_rcode=0
    LET f_pscs_sw=0

    BEGIN WORK
    WHENEVER ERROR CONTINUE

    -- 100/03/31 MODIFY
    IF p_data_s1.disb_special_ind="0" THEN
       IF g_polf.currency = 'TWD' THEN 
           SELECT * INTO f_pscs.*
           FROM   pscs
           WHERE  policy_no    =p_data_s1.policy_no
           AND    cp_anniv_date=p_data_s1.cp_anniv_date
           
           IF STATUS = NOTFOUND THEN
              LET f_pscs_sw="0"
           ELSE
              DELETE FROM pscs
              WHERE  policy_no    =p_data_s1.policy_no
              AND    cp_anniv_date=p_data_s1.cp_anniv_date
              IF SQLCA.SQLCODE !=0 THEN
                 ROLLBACK WORK
                 LET f_rcode=1
                 RETURN f_rcode
              END IF
           END IF
       ELSE
           SELECT * 
           FROM   pscy
           WHERE  policy_no    =p_data_s1.policy_no
           AND    cp_anniv_date=p_data_s1.cp_anniv_date
           
           IF STATUS = NOTFOUND THEN
              LET f_pscs_sw="0"
           ELSE
              DELETE FROM pscy
              WHERE  policy_no    =p_data_s1.policy_no
              AND    cp_anniv_date=p_data_s1.cp_anniv_date
              IF SQLCA.SQLCODE !=0 THEN
                 ROLLBACK WORK
                 LET f_rcode=1
                 RETURN f_rcode
              END IF
           END IF
       END IF
    END IF -- disb_special_ind="0" --
    -- 100/03/31 END
    
    -- 100/03/31 COMMENT OUT 
    -- 之前程式對輸入完資料，已經檢查過cp_disb_type !="3"時，disb_special_ind必須為0
    -- 所以一定會落入上一段(IF disb_special_ind="0")的條件中
    -- 以下這一段形同虛設，故移除之。
{
    IF p_data_s1.cp_disb_type !="3" and 
       p_data_s1.disb_special_ind !="1" THEN

       SELECT * INTO f_pscs.*
       FROM   pscs
       WHERE  policy_no    =p_data_s1.policy_no
       AND    cp_anniv_date=p_data_s1.cp_anniv_date

       IF STATUS = NOTFOUND THEN
          LET f_pscs_sw="0"
       ELSE
          DELETE FROM pscs
          WHERE  policy_no    =p_data_s1.policy_no
          AND    cp_anniv_date=p_data_s1.cp_anniv_date
          IF SQLCA.SQLCODE !=0 THEN
             ROLLBACK WORK
             LET f_rcode=1
             RETURN f_rcode
          END IF
       END IF
    END IF
}
    -- 舊給付為抵繳保費,新給付 != 抵繳 處理 --
    IF p_old_cp_disb_type ="2"      AND
       p_data_s1.cp_disb_type !="2" THEN

       -- 刪除曾經選擇抵繳的資料 --
       -- 執行抵繳保費輸入他張保單程式,功能由容芳提供,程式放在 p9610.4gl --
       LET p_pc961_data.policy_no    =p_data_s1.policy_no
       LET p_pc961_data.cp_anniv_date=p_data_s1.cp_anniv_date
       LET p_pc961_data.prss_code    ="DELE"
       LET p_pc961_data.tran_date    =p_tran_date
       LET p_pc961_data.cp_pay_amt   =0
       LET p_pc961_sw=TRUE
       LET p_pc961_msg=""
       CALL pc961_process(p_pc961_data.*,p_benf_relation)
            RETURNING p_pc961_sw,p_pc961_msg,p_pc961_data.*
       IF p_pc961_sw=FALSE THEN
          ROLLBACK WORK
          LET f_rcode=1
          RETURN f_rcode
       END IF

       {
       UPDATE pcps    
       SET    process_ind="0"
             ,tran_date  =p_tx_date  
             ,process_date=p_tx_date
       WHERE  policy_no=p_data_s1.policy_no
       AND    cp_anniv_date=p_data_s1.cp_anniv_date

       IF SQLCA.SQLCODE !=0 THEN
          ROLLBACK WORK
          LET f_rcode=1
          RETURN f_rcode
       END IF
       }

    END IF
 
    IF p_data_s1.cp_disb_type ="2"   THEN
       -- 抵繳資料存檔 --
       -- 執行抵繳保費輸入他張保單程式,功能由容芳提供,程式放在 p9610.4gl --
       LET p_pc961_data.policy_no    =p_data_s1.policy_no
       LET p_pc961_data.cp_anniv_date=p_data_s1.cp_anniv_date
       LET p_pc961_data.prss_code    ="SAVE"
       LET p_pc961_data.tran_date    =p_tran_date
       LET p_pc961_data.cp_pay_amt   =0
       LET p_pc961_sw=TRUE
       LET p_pc961_msg=""
       CALL pc961_process(p_pc961_data.*,p_benf_relation)
            RETURNING p_pc961_sw,p_pc961_msg,p_pc961_data.*
       IF p_pc961_sw=FALSE THEN
          ROLLBACK WORK
          LET f_rcode=1
          RETURN f_rcode
       END IF

       {

       LET p_pcps.policy_no    =p_data_s1.policy_no
       LET p_pcps.cp_anniv_date=p_data_s1.cp_anniv_date
       LET p_pcps.cp_sw        =p_cp_sw
       LET p_pcps.cp_prem      =0
       LET p_pcps.process_ind  =" "
       LET p_pcps.tran_date    =p_tx_date
       LET p_pcps.process_date =p_tx_date

       INSERT INTO pcps
       VALUES (p_pcps.*)

       IF SQLCA.SQLCODE !=0 THEN
          ROLLBACK WORK
          LET  f_rcode=1
          RETURN f_rcode
       END IF
       }

    END IF

    IF length(p_cp_notice_code CLIPPED)=0 THEN
       LET f_cp_notice_sw=p_pscb.cp_notice_sw
    END IF

    IF p_cp_notice_code="0" OR
       p_cp_notice_code="3" THEN
       LET f_cp_notice_sw="2"
    END IF

    IF p_cp_notice_code="2" THEN
       LET f_cp_notice_sw="3"
    END IF

    IF p_cp_notice_code="1" THEN
       IF p_cp_notice_sub_code="0" THEN
          LET f_cp_notice_sw="2"
       END IF
    END IF

    UPDATE pscb
    SET    cp_disb_type    =p_data_s1.cp_disb_type
          ,mail_addr_ind   =p_data_s1.mail_addr_ind
          ,disb_special_ind=p_data_s1.disb_special_ind
	  ,cp_rtn_sw	   =p_data_s1.cp_rtn_sw
          ,change_date     =p_tx_date       
          ,process_date    =p_tx_date
          ,process_user    =g_user
          ,cp_notice_sw    =f_cp_notice_sw
          ,cp_pay_name     =p_data_s1.cp_pay_name
          ,cp_pay_id       =p_data_s1.cp_pay_id
          ,dept_code       =p_dept_code
    WHERE  policy_no    =p_data_s1.policy_no
    AND    cp_anniv_date=p_data_s1.cp_anniv_date

    IF SQLCA.SQLCODE !=0 THEN
       ROLLBACK WORK
       LET f_rcode=1
       RETURN f_rcode
    END IF
 
   --cmwang SR130800093 ADD
   IF p_data_s1.cp_disb_type = "4" THEN
      CALL nonresp_sw_add()  RETURNING f_rcode 
      IF f_rcode THEN 
         display " nonresp_sw_add() 錯誤"
	 LET f_rcode = 1 
	 RETURN f_rcode 
      END IF 
   END IF 
   
   --cmwang END 

   --yirong 102/10專案狀態為無效,並送出BPM
   IF p_psbh_cnt > 0 THEN

      SELECT *
        INTO g_psbh.*
        FROM psbh
       WHERE policy_no    =p_data_s1.policy_no
         AND cp_anniv_date=p_data_s1.cp_anniv_date
         AND cp_rtn_sts = '0'  
         AND cp_rtn_type = '2'    --僅滿期需要更改狀態
      
      IF STATUS = NOTFOUND THEN
      ELSE 
      
         LET g_nbbk_cnt = 0
         FOR f_i = 1 TO 3
             INITIALIZE      g_nbbk_arr[f_i].*        TO      NULL
         END FOR
         LET f_i = 1
         DECLARE nbbk_cur CURSOR WITH HOLD FOR
            SELECT *
              FROM nbbk
             WHERE divback_type = '3'
               AND close_ind = '0'
               AND join_policy_no = g_psbh.policy_no
               AND cp_anniv_date = g_psbh.cp_anniv_date
             ORDER BY policy_no
         FOREACH  nbbk_cur INTO g_nbbk_arr[f_i].*
             LET f_i = f_i + 1
         END FOREACH
         LET g_nbbk_cnt = f_i - 1
     
         CALL upd_sts_psbh('0')
         FOR f_i = 1 TO g_nbbk_cnt
             CALL upd_sts_nbbk('0',f_i,p_tx_date)

             CALL psl01s3_bpm_comment(g_nbbk_arr[f_i].policy_no,p_tran_date,g_psbh.*,'變更給付方式(無效)')
                  RETURNING f_rcode,f_msg

             IF NOT f_rcode THEN
                ERROR 'error sent Fail to BPM' ATTRIBUTE(RED ,REVERSE)
--              ROLLBACK WORK
             END IF

         END FOR
      END IF
   END IF
   
--display p_data_s1.cp_disb_type,'===',p_online_prc
    IF p_data_s1.cp_disb_type ="1" AND p_online_prc = '1'  THEN
--display  'psc30s01'
       LET g_online_sw = '1'   
       CALL psc30s01(p_tran_date,p_tran_date,p_tran_date
                    ,p_data_s1.policy_no,p_data_s1.cp_anniv_date)
       RETURNING f_rcode
       IF f_rcode  THEN
display "ONLINE過帳錯誤!!"
       ELSE
--display "OK"
       END IF
    END IF
 
    --SR140800458
    IF p_upd_psck="Y" THEN
       IF psca01s_promptSave( "以未回領取方式回覆是否取消【*】?" ) THEN
          UPDATE  psck
          SET     nonresp_sw = " "
          WHERE   policy_no = p_policy_no
          AND     cp_anniv_date = p_cp_anniv_date
          IF SQLCA.SQLCODE != 0 THEN
             ROLLBACK WORK
             CALL err_touch("取消註記失敗")
          END IF
       END IF
    END IF

--    IF p_upd_psck != "Y" THEN
    SELECT  COUNT(*)
    INTO    f_nonresp_cnt 
    FROM    psck
    WHERE   policy_no = p_data_s1.policy_no 
    AND     nonresp_sw = "Y"
    LET f_prompt_ans = "Y"
    IF f_nonresp_cnt = 0 THEN
       CALL ap905_update_sts(p_data_s1.po_chg_rece_no,'5')
    END IF 
    IF f_nonresp_cnt > 0 THEN
       PROMPT "建檔完成，受理流程是否結案?(Y/N)" FOR CHAR f_prompt_ans
       IF UPSHIFT( f_prompt_ans ) = "Y" THEN 
          CALL ap905_update_sts(p_data_s1.po_chg_rece_no,'5')
       END IF
    END IF
       
--    END IF

    COMMIT WORK

    RETURN f_rcode
    WHENEVER ERROR STOP
END FUNCTION -- psd01m_save_data --

------------------------------------------------------------------------------
--  函式名稱: psc01m_edit_benf
--  作    者: jessica Chang
--  日    期: 87/08/04
--  處理概要: 還本回覆作業,受益人確認
--  重要函式:
------------------------------------------------------------------------------
FUNCTION psc01m_edit_benf()
    DEFINE f_rcode    INTEGER
          ,f_i        INTEGER

    LET INT_FLAG=FALSE
    LET f_rcode=0

    IF  p_data_s1.cp_disb_type !="3" THEN
        LET f_rcode=0
        RETURN f_rcode
    END IF

    -- 100/03/31 MODIFY
    IF g_polf.currency = 'TWD' THEN
       MESSAGE " END(F7):取消作業!!"
    ELSE
       MESSAGE " (F6)編輯外幣匯款帳號  (F7):取消作業  (ESC)存檔"       
    END IF
    -- 100/03/31 END
    
    OPEN WINDOW psc01m_benf AT 6,01 WITH FORM "psc01m03"
    ATTRIBUTE (GREEN, FORM LINE FIRST,PROMPT LINE LAST)

    DISPLAY p_policy_no      TO policy_no
            ATTRIBUTE (YELLOW)

    -- 100/03/31 MODIFY
    IF g_polf.currency = 'TWD' THEN
       CALL psc01m_edit_benf_dsp()
            RETURNING f_rcode
    ELSE
       CALL psc01m_edit_benp_dsp()    
            RETURNING f_rcode      
    END IF
    -- 100/03/31 END

    CASE
       WHEN INT_FLAG=TRUE
          LET INT_FLAG=FALSE
          ERROR "放棄輸入!!"
       WHEN f_rcode = 0
          ERROR "受益人作業完成!!"
       WHEN f_rcode = 1
          ERROR "benf 刪除失敗 !!"
       WHEN f_rcode = 2
          ERROR "benf 新增失敗 !!"
    END CASE

    CLOSE WINDOW psc01m_benf

    RETURN f_rcode
END FUNCTION -- psc01m_edit_benf --

------------------------------------------------------------------------------
--  函式名稱: psc01m_edit_benf_dsp
--  作    者: jessica Chang
--  日    期: 87/08/04
--  處理概要: 還本回覆作業,確認
--  重要函式:
------------------------------------------------------------------------------
FUNCTION psc01m_edit_benf_dsp()

    DEFINE f_rcode         INTEGER
          ,f_i             INTEGER
          ,f_coverage_no   INTEGER
          ,f_arr_cur       INTEGER
          ,f_scr_cur       INTEGER
          ,f_remit_bank    CHAR(3)
          ,f_chk_remit_err CHAR(1)
          ,f_chk_remit_msg CHAR(255)
 	
    DEFINE f_bank_code  LIKE    bank.bank_code
    DEFINE f_data_length INT

    LET f_rcode = 0
    LET f_chk_remit_err="0"
    LET f_chk_remit_msg=""

    FOR f_i=1 TO 99
        LET  p_benf[f_i].client_id      =" "
        LET  p_benf[f_i].benf_ratio     =0
        LET  p_benf[f_i].remit_bank     =" "
        LET  p_benf[f_i].remit_branch   =" "
        LET  p_benf[f_i].remit_account  =" "
        LET  p_benf[f_i].benf_order     =" "
        LET  p_benf[f_i].names          =" "
    END FOR

    FOR f_i=1 TO p_benf_cnt
        LET  p_benf[f_i].client_id      =p_data_s2[f_i].client_id
        LET  p_benf[f_i].benf_ratio     =p_data_s2[f_i].benf_ratio
        LET  p_benf[f_i].remit_bank     =p_data_s2[f_i].remit_bank
        LET  p_benf[f_i].remit_branch   =p_data_s2[f_i].remit_branch
        LET  p_benf[f_i].remit_account  =p_data_s2[f_i].remit_account
        LET  p_benf[f_i].benf_order     =p_data_s2[f_i].benf_order
        LET  p_benf[f_i].names          =p_data_s2[f_i].names
        LET  p_benf[f_i].bank_name      =p_data_s2_b[f_i].bank_name
    END FOR

    CALL SET_COUNT(p_benf_cnt)

    INPUT ARRAY p_benf WITHOUT DEFAULTS
    FROM  psbenf.*
    BEFORE ROW
           LET f_arr_cur = ARR_CURR()
           LET f_scr_cur = SCR_LINE()
    AFTER FIELD remit_bank
          IF p_benf[f_arr_cur].client_id !=" " OR
             p_benf[f_arr_cur].names     !=" " THEN

             IF p_benf[f_arr_cur].remit_bank=" " THEN
                ERROR "匯款銀行必須輸入!!"
                      ATTRIBUTE (RED)
                NEXT FIELD remit_bank
             END IF
             SELECT DISTINCT bank_code[1,3]
             INTO   f_remit_bank
             FROM   bank
             WHERE  bank_code[1,3]= p_benf[f_arr_cur].remit_bank

             IF STATUS = NOTFOUND THEN
                ERROR "請輸入正確銀行代碼 !!"
                      ATTRIBUTE (RED)
                NEXT FIELD remit_bank
             END IF
             LET f_data_length = 0 
             SELECT data_length
               INTO f_data_length
               FROM dbac
              WHERE remit_bank = f_remit_bank
             IF STATUS = NOTFOUND THEN
                LET f_data_length = 0
             END IF  

          ELSE
            NEXT FIELD remit_branch
          END IF

    AFTER FIELD remit_branch
          IF p_benf[f_arr_cur].client_id !=" " OR
             p_benf[f_arr_cur].names     !=" " THEN

             IF p_benf[f_arr_cur].remit_branch=" " THEN
                ERROR "匯款分行必須輸入!!"
                      ATTRIBUTE (RED)
                NEXT FIELD remit_branch
             END IF

          ELSE
             NEXT FIELD remit_account
          END IF

          LET f_bank_code=p_benf[f_arr_cur].remit_bank,p_benf[f_arr_cur].remit_branch

          SELECT bank_name INTO p_benf[f_arr_cur].bank_name
          FROM   bank
          WHERE  bank_code=f_bank_code

          LET p_benf[f_arr_cur].bank_name=p_benf[f_scr_cur].bank_name CLIPPED
          DISPLAY p_benf[f_arr_cur].bank_name to psbenf[f_scr_cur].bank_name


    AFTER FIELD remit_account
          IF p_benf[f_arr_cur].client_id !=" " OR
             p_benf[f_arr_cur].names     !=" " THEN

             IF p_benf[f_arr_cur].remit_account=" " THEN
                ERROR "匯款帳號必須輸入!!"
                      ATTRIBUTE (RED)
                NEXT FIELD remit_account
             END IF

             CALL chkRemitAcct (p_benf[f_arr_cur].remit_bank
                               ,p_benf[f_arr_cur].remit_branch
                               ,p_benf[f_arr_cur].remit_account
                               )
                  RETURNING f_chk_remit_err,f_chk_remit_msg
             IF f_chk_remit_err !="0" THEN
                ERROR f_chk_remit_msg
                      ATTRIBUTE (RED)
                NEXT FIELD remit_bank
             END If
             IF f_data_length > 0 THEN
                IF LENGTH(p_benf[f_arr_cur].remit_account) != f_data_length THEN
                   ERROR "匯款帳號長度有誤!!"
                   ATTRIBUTE (RED)
                   NEXT FIELD remit_account
                END IF
             END IF  
          END IF

    ON KEY (F7)
       LET INT_FLAG=TRUE
       EXIT INPUT

    AFTER ROW

       IF (p_benf[f_arr_cur].client_id =" "   AND
           p_benf[f_arr_cur].names     =" " ) AND
          (p_benf[f_arr_cur].remit_bank !=" "     OR
           p_benf[f_arr_cur].remit_branch  !=" "  OR
           p_benf[f_arr_cur].remit_account !=" ") THEN
                ERROR "匯款銀行,匯款分行,匯款帳號不必須輸入!!"
                      ATTRIBUTE (RED)
       END IF
       IF p_benf[f_arr_cur].remit_bank !=" "    OR
          p_benf[f_arr_cur].remit_branch !=" "  OR
          p_benf[f_arr_cur].remit_account !=" " THEN

          CALL chkRemitAcct (p_benf[f_arr_cur].remit_bank
                            ,p_benf[f_arr_cur].remit_branch
                            ,p_benf[f_arr_cur].remit_account
                            )
               RETURNING f_chk_remit_err,f_chk_remit_msg
          IF f_chk_remit_err !="0" THEN
             ERROR f_chk_remit_msg
                   ATTRIBUTE (RED)
             NEXT FIELD remit_bank
          END IF
       END IF

    END INPUT

    IF INT_FLAG=TRUE THEN
       LET f_rcode=0
       RETURN f_rcode
    END IF


 #  LET p_benf_cnt = ARR_COUNT()


    BEGIN WORK
    WHENEVER ERROR CONTINUE

    DELETE FROM benf
    WHERE  policy_no   = p_policy_no
    AND    relation    = p_benf_relation

    IF SQLCA.SQLCODE != 0 THEN
       ROLLBACK WORK
       LET f_rcode=1
       RETURN f_rcode
    END IF

    LET f_coverage_no=0
    FOR f_i = 1 TO p_benf_cnt
        IF p_benf[f_i].client_id <> " " THEN
           INSERT INTO benf VALUES(p_policy_no
                                  ,f_coverage_no
                                  ,p_benf_relation
                                  ,p_benf[f_i].client_id
                                  ,""
                                  ,p_benf[f_i].benf_order
                                  ,p_benf[f_i].benf_ratio
                                  ,p_benf[f_i].remit_bank
                                  ,p_benf[f_i].remit_branch
                                  ,p_benf[f_i].remit_account
                                  ,""
                                  ,""
                                  ,""
                                  ,""
                                  ,""
                                  ,""
                                  ,"" 
                                   )
           IF SQLCA.SQLCODE != 0 THEN
              ROLLBACK WORK
              LET f_rcode=2
              RETURN f_rcode
           END IF
        ELSE
           INSERT INTO benf VALUES(p_policy_no
                                  ,f_coverage_no
                                  ,p_benf_relation
                                  ,p_benf[f_i].client_id
                                  ,p_benf[f_i].names
                                  ,p_benf[f_i].benf_order
                                  ,p_benf[f_i].benf_ratio
                                  ,p_benf[f_i].remit_bank
                                  ,p_benf[f_i].remit_branch
                                  ,p_benf[f_i].remit_account
                                  ,""
                                  ,""
                                  ,""
                                  ,""
                                  ,""
                                  ,""
                                  ,"" 
                                   )
           IF SQLCA.SQLCODE != 0 THEN
              ROLLBACK WORK
              LET f_rcode=2
              RETURN f_rcode
           END IF
        END IF
    END FOR

    COMMIT WORK

    FOR f_i=1 TO p_benf_cnt
        LET  p_data_s2[f_i].client_id      =p_benf[f_i].client_id
        LET  p_data_s2[f_i].benf_ratio     =p_benf[f_i].benf_ratio
        LET  p_data_s2[f_i].remit_bank     =p_benf[f_i].remit_bank
        LET  p_data_s2[f_i].remit_branch   =p_benf[f_i].remit_branch
        LET  p_data_s2[f_i].remit_account  =p_benf[f_i].remit_account
        LET  p_data_s2[f_i].benf_order     =p_benf[f_i].benf_order
        LET  p_data_s2[f_i].names          =p_benf[f_i].names

    END FOR

    RETURN f_rcode
    WHENEVER ERROR STOP
END FUNCTION -- psc01m_edit_benf_dsp --

-- 100/03/31 ADD
------------------------------------------------------------------------------
--  函式名稱: psc01m_edit_benp_dsp
--  處理概要: 還本回覆作業,編輯外幣受益人匯款資料
------------------------------------------------------------------------------
FUNCTION psc01m_edit_benp_dsp()

    DEFINE f_rcode            INTEGER
          ,f_i                INTEGER
          ,f_coverage_no      INTEGER
          ,f_arr_cur          INTEGER
          ,f_cancel           INTEGER   -- 取消作業
          ,f_ans_sw           CHAR(1)   -- prompt 的回覆 --
          ,f_bank_code        LIKE benp.bank_code
          ,f_bank_name        LIKE bank.bank_name
          ,f_chk_account_sw   CHAR(1)   -- 檢查匯款帳號有值
	  ,f_scr_cur          INTEGER 
              
    LET f_rcode          = 0
    LET f_cancel         = 0      
    LET f_ans_sw         = ''
    
    
    FOR f_i=1 TO 99
        LET  p_benf[f_i].client_id                =" "
        LET  p_benf[f_i].benf_ratio               =0
        LET  p_benf[f_i].remit_bank               =" "
        LET  p_benf[f_i].remit_branch             =" "
        LET  p_benf[f_i].remit_account            =" "
        LET  p_benf[f_i].benf_order               =" "
        LET  p_benf[f_i].names                    =" "
        LET  p_benf[f_i].bank_name                =" "
        
        LET  p_benp_ext[f_i].payee                =" "
        LET  p_benp_ext[f_i].remit_swift_code     =" "
        LET  p_benp_ext[f_i].remit_bank_name      =" "
        LET  p_benp_ext[f_i].remit_bank_address   =" "
    END FOR

    FOR f_i=1 TO p_benf_cnt

        LET  p_benf[f_i].client_id                =p_data_s2[f_i].client_id
        LET  p_benf[f_i].benf_ratio               =p_data_s2[f_i].benf_ratio
        LET  p_benf[f_i].remit_bank               =p_data_s2[f_i].remit_bank
        LET  p_benf[f_i].remit_branch             =p_data_s2[f_i].remit_branch
        LET  p_benf[f_i].remit_account            =p_data_s2[f_i].remit_account
        LET  p_benf[f_i].benf_order               =p_data_s2[f_i].benf_order
        LET  p_benf[f_i].names                    =p_data_s2[f_i].names
        LET  p_benf[f_i].bank_name                =p_data_s2_b[f_i].bank_name
        
        LET  p_benp_ext[f_i].payee                =p_data_s2_c[f_i].payee
        LET  p_benp_ext[f_i].remit_swift_code     =p_data_s2_c[f_i].remit_swift_code
        LET  p_benp_ext[f_i].remit_bank_name      =p_data_s2_c[f_i].remit_bank_name
        LET  p_benp_ext[f_i].remit_bank_address   =p_data_s2_c[f_i].remit_bank_address

    END FOR

    CALL SET_COUNT(p_benf_cnt)

    WHILE(TRUE)
      DISPLAY ARRAY p_benf TO  psbenf.*
      
      ON KEY (F6) -- 編輯外幣匯款帳號
      
         LET f_arr_cur = ARR_CURR()
	 LET f_scr_cur = SCR_LINE()

         -- 初始化
         INITIALIZE g_dbdd.* TO NULL  
         LET g_dbdd.disb_fee_ind        = '1'                             -- 手續費為1:付款人負擔
         LET g_dbdd.payee_id            = p_benf[f_arr_cur].client_id     -- 要設定g_dbdd的ID，否則手續費會預設為2
         -- 編輯外幣帳戶 -- 
         CALL payforeign(p_policy_no, p_benf[f_arr_cur].client_id, "1", "1", 6, 6)
         -- 在編輯外幣帳戶的過程中，利用公用函式進行外幣帳戶檢核，將最後輸入正確合法的帳戶資料記錄於g_dbdd.*中
         -- 但是若中途取消，該筆資料會被清空，後續程式不會進行檢核外幣帳戶，會造成帳戶空白卻存入檔案benp中
         -- 所以增加一個條件是:若使用者取消編輯任何一筆受益人外幣匯款帳號，則就要取消所有編輯
         -- 避免可能造成某個受益人外幣匯款帳號為空白的漏洞
         IF INT_FLAG = TRUE THEN
         	  LET f_cancel = 1
            EXIT DISPLAY
         END IF
         
         -- 檢查:不可以修改client_id
         IF g_dbdd.payee_id <> p_benf[f_arr_cur].client_id THEN
            ERROR "不可以修改受益人ID，請重新輸入!"
            
         ELSE
            -- 檢查:不可以修改手續費指示
            IF g_dbdd.disb_fee_ind <> '1' THEN
               ERROR "不可以修改手續費指示，請重新輸入!"
            ELSE
               -- 用swift_code對應到匯款銀行/分行/銀行中文名稱
               SELECT bksw.bank_code, bank.bank_name
                 INTO f_bank_code, f_bank_name
                 FROM bksw , OUTER bank
                WHERE bksw.swift_code   = g_dbdd.remit_swift_code
                  AND bksw.bank_use_ind = "Y"
                  AND bksw.bank_code    = bank.bank_code
                  
               IF STATUS = NOTFOUND THEN
               	  ERROR "swift_code無對應匯款行，請重新輸入!"
               ELSE
               	  -- 將該筆外幣資料顯示到畫面上
               	  LET p_benf[f_arr_cur].remit_bank     = f_bank_code[1,3]
               	  LET p_benf[f_arr_cur].remit_branch   = f_bank_code[4,7]
                  LET p_benf[f_arr_cur].remit_account  = g_dbdd.remit_account
                  LET p_benf[f_arr_cur].names          = g_dbdd.payee_cht
                  LET p_benf[f_arr_cur].bank_name      = f_bank_name   

                  DISPLAY p_benf[f_arr_cur].remit_bank     TO psbenf[f_scr_cur].remit_bank        
                  DISPLAY p_benf[f_arr_cur].remit_branch   TO psbenf[f_scr_cur].remit_branch              
                  DISPLAY p_benf[f_arr_cur].remit_account  TO psbenf[f_scr_cur].remit_account
                  DISPLAY p_benf[f_arr_cur].names          TO psbenf[f_scr_cur].names
                  DISPLAY p_benf[f_arr_cur].bank_name      TO psbenf[f_scr_cur].bank_name   

                  -- 儲存匯款帳號資料
                  LET p_benp_ext[f_arr_cur].payee         　　 = g_dbdd.payee         　　　      
                  LET p_benp_ext[f_arr_cur].remit_swift_code   = g_dbdd.remit_swift_code
                  LET p_benp_ext[f_arr_cur].remit_bank_name    = g_dbdd.remit_bank_name     
                  LET p_benp_ext[f_arr_cur].remit_bank_address = g_dbdd.remit_bank_address
               END IF
            END IF
         END IF
         
      ON KEY (F7) -- 取消作業
         LET INT_FLAG = TRUE
         LET f_cancel = 1
         EXIT DISPLAY
         
      ON KEY (ESC) -- 存檔作業
      	 
      	 -- 檢查匯款帳號資料
      	 LET f_chk_account_sw = 1
         FOR f_i = 1 TO p_benf_cnt
            IF LENGTH(p_benf[f_i].remit_account)= 0 THEN
               ERROR "帳戶空白不可以存檔!" 
               LET f_chk_account_sw = 0
               EXIT FOR
            END IF
         END FOR
         
         -- 匯款帳號資料不為空白才可以存檔
         IF f_chk_account_sw = 1 THEN
            LET INT_FLAG = TRUE
            EXIT DISPLAY
         END IF
      END DISPLAY

      -- 判斷是否要繼續顯示畫面
      IF INT_FLAG = TRUE THEN    -- 離開視窗
         IF f_cancel = 0 THEN    -- 若非取消作業，則要確認是否存檔
            LET f_ans_sw=" "
            PROMPT "確認存檔請按 Y --->" ATTRIBUTE (WHITE) FOR CHAR f_ans_sw
                   ATTRIBUTE (YELLOW)
            IF UPSHIFT(f_ans_sw) ="Y" THEN
               LET INT_FLAG = FALSE
            END IF
    	   END IF 
    	   EXIT WHILE             
      END IF   
    END WHILE

    -- 使用者取消
    IF INT_FLAG = TRUE THEN
       RETURN f_rcode
    ELSE
       -- 更新benp檔案
       BEGIN WORK
       WHENEVER ERROR CONTINUE
       
       DELETE FROM benp
       WHERE  policy_no   = p_policy_no
       AND    relation    = p_benf_relation
       
       IF SQLCA.SQLCODE != 0 THEN
          ROLLBACK WORK
          LET f_rcode=1
          RETURN f_rcode
       END IF
       
       LET f_coverage_no=0
       FOR f_i = 1 TO p_benf_cnt
           
           LET f_bank_code = p_benf[f_i].remit_bank,p_benf[f_i].remit_branch
           
           INSERT INTO benp VALUES(p_policy_no
                                  ,f_coverage_no
                                  ,p_benf_relation
                                  ,p_benf[f_i].client_id
                                  ,p_benf[f_i].names
                                  ,f_bank_code
                                  ,p_benp_ext[f_i].remit_swift_code
                                  ,p_benp_ext[f_i].remit_bank_name
                                  ,p_benf[f_i].remit_account
                                  ,p_benp_ext[f_i].payee 
                                  ,p_benp_ext[f_i].remit_bank_address
                                   )
           IF SQLCA.SQLCODE != 0 THEN
              ROLLBACK WORK
              LET f_rcode=2
              RETURN f_rcode
           END IF
           
       END FOR
       
       COMMIT WORK
       
       FOR f_i=1 TO p_benf_cnt
       
           -- 更新benp資料到畫面
           LET  p_data_s2[f_i].client_id      =p_benf[f_i].client_id
           LET  p_data_s2[f_i].benf_ratio     =p_benf[f_i].benf_ratio
           LET  p_data_s2[f_i].remit_bank     =p_benf[f_i].remit_bank
           LET  p_data_s2[f_i].remit_branch   =p_benf[f_i].remit_branch
           LET  p_data_s2[f_i].remit_account  =p_benf[f_i].remit_account
           LET  p_data_s2[f_i].benf_order     =p_benf[f_i].benf_order
           LET  p_data_s2[f_i].names          =p_benf[f_i].names
           LET  p_data_s2_b[f_i].bank_name    =p_benf[f_i].bank_name
           
           -- 儲存匯款帳號資料
           LET  p_data_s2_c[f_i].payee              = p_benp_ext[f_i].payee              
           LET  p_data_s2_c[f_i].remit_swift_code   = p_benp_ext[f_i].remit_swift_code 
           LET  p_data_s2_c[f_i].remit_bank_name    = p_benp_ext[f_i].remit_bank_name     
           LET  p_data_s2_c[f_i].remit_bank_address = p_benp_ext[f_i].remit_bank_address 
       END FOR
       
       
       RETURN f_rcode
       WHENEVER ERROR STOP
       
    END IF
END FUNCTION -- psc01m_edit_benp_dsp --

------------------------------------------------------------------------------
--  函式名稱: psc01m_edit_pscy
------------------------------------------------------------------------------
FUNCTION psc01m_edit_pscy()
 DEFINE f_rcode  INTEGER

    LET f_rcode=0

    MESSAGE " END:取消作業" ATTRIBUTE (WHITE)

    OPEN WINDOW psc00m_pscy AT 9,01 WITH FORM "psc00m12"
    ATTRIBUTE (GREEN,FORM LINE FIRST,PROMPT LINE LAST,MESSAGE LINE LAST)

    CALL psc01m_edit_pscy_dsp()
         RETURNING f_rcode

    CASE
       WHEN INT_FLAG=TRUE
          LET INT_FLAG=FALSE
          ERROR "放棄輸入!!"
       WHEN f_rcode = 0
          ERROR "電匯指示作業完成!!"
      WHEN f_rcode = 1
          ERROR "pscy 更新失敗 !!"
       WHEN f_rcode = 2
          ERROR "pscy 新增失敗 !!"
    END CASE

    CLOSE WINDOW psc00m_pscy
    RETURN f_rcode
 
END FUNCTION -- psc01m_edit_pscy --

------------------------------------------------------------------------------
--  函式名稱: psc01m_edit_pscy_dsp
------------------------------------------------------------------------------
FUNCTION psc01m_edit_pscy_dsp()

    DEFINE f_rcode      INTEGER
          ,f_ans_sw     CHAR(1)   -- prompt 的回覆 --

    DEFINE f_pscy       RECORD  
                        payee                LIKE pscy.payee           
                       ,client_id            LIKE pscy.client_id       
                       ,swift_code           LIKE pscy.swift_code
                       ,bank_name            CHAR(30)  
                       ,bank_code            LIKE pscy. bank_code     
                       ,bank_name_e          LIKE pscy.bank_name_e     
                       ,bank_account_e       LIKE pscy.bank_account_e  
                       ,payee_e              LIKE pscy.payee_e         
                       ,bank_address_e       LIKE pscy.bank_address_e  
                       ,ed                   CHAR(2)
                         END RECORD


    LET f_rcode     =0
    INITIALIZE f_pscy.* TO NULL
    
    -- 先抓出原來的pscy
    SELECT pscy.payee, 
           pscy.client_id,
           pscy.swift_code,
           pscy.bank_code,
           pscy.bank_name_e,
           pscy.bank_account_e,
           pscy.payee_e,
           pscy.bank_address_e,
           bank.bank_name[1,30]
      INTO f_pscy.payee, 
           f_pscy.client_id, 
           f_pscy.swift_code,
           f_pscy.bank_code, 
           f_pscy.bank_name_e,
           f_pscy.bank_account_e, 
           f_pscy.payee_e, 
           f_pscy.bank_address_e,
           f_pscy.bank_name
    FROM   pscy, OUTER bank
    WHERE  pscy.policy_no     = p_data_s1.policy_no
    AND    pscy.cp_anniv_date = p_data_s1.cp_anniv_date
    AND    pscy.bank_code     = bank.bank_code
    
    LET f_pscy.ed='F8'
    INPUT BY NAME f_pscy.*  WITHOUT DEFAULTS
    	    
    ON KEY (F8)
    	     -- 初始化
           INITIALIZE g_dbdd.* TO NULL  
              
           -- 編輯外幣帳戶 -- 
           CALL payforeign(p_policy_no, '', "1", "1", 6, 6)
      
           -- 若使用者完成外幣帳戶編輯，將該筆外幣資料顯示到畫面上
           IF INT_FLAG = FALSE THEN      
              LET f_pscy.payee            =   g_dbdd.payee_cht  
              LET f_pscy.client_id        =   g_dbdd.payee_id       
              LET f_pscy.swift_code       =   g_dbdd.remit_swift_code
              LET f_pscy.bank_name_e      =   g_dbdd.remit_bank_name   
              LET f_pscy.bank_account_e   =   g_dbdd.remit_account
              LET f_pscy.payee_e          =   g_dbdd.payee
              LET f_pscy.bank_address_e   =   g_dbdd.remit_bank_address
              
              -- 用swift_code對應到bank_code
              SELECT bksw.bank_code, bank.bank_name[1,30]
                INTO f_pscy.bank_code, f_pscy.bank_name 
                FROM bksw , bank
               WHERE bksw.swift_code   = g_dbdd.remit_swift_code
                 AND bksw.bank_use_ind = "Y"
                 AND bksw.bank_code    = bank.bank_code
                 
              IF STATUS = NOTFOUND THEN 
                 LET f_pscy.bank_code= " "
                 LET f_pscy.bank_name= " "
              END IF    
          END IF
           
           
    AFTER INPUT
       IF INT_FLAG = TRUE THEN
          EXIT INPUT
       END IF

       -- 檢查外幣帳號要有值
    	 IF LENGTH(f_pscy.bank_account_e CLIPPED)= 0 THEN
    	 	  ERROR "外幣帳號要有值，請按F8重新輸入!"
    	 	  LET INT_FLAG = TRUE
    	 	  EXIT INPUT
    	 END IF
    	 
    	 -- 確認存檔
       LET f_ans_sw=" "
       PROMPT "確認存檔請按 Y --->" ATTRIBUTE (WHITE) FOR CHAR f_ans_sw
              ATTRIBUTE (YELLOW)
       IF UPSHIFT(f_ans_sw) !="Y" THEN
          LET INT_FLAG = TRUE
    	 	  EXIT INPUT
       END IF

    END INPUT

    -- 使用者取消
    IF INT_FLAG=TRUE THEN
       LET f_rcode=0
       RETURN f_rcode
    END IF

    -- 更新benp檔案    
    BEGIN WORK
    WHENEVER ERROR CONTINUE

    DELETE FROM pscy
    WHERE  policy_no    =p_data_s1.policy_no
    AND    cp_anniv_date=p_data_s1.cp_anniv_date
       
    INSERT INTO pscy VALUES( p_data_s1.policy_no
                            ,p_data_s1.cp_anniv_date       
                            ,f_pscy.payee             
                            ,f_pscy.client_id         
                            ,f_pscy.bank_code
                            ,f_pscy.swift_code        
                            ,f_pscy.bank_name_e       
                            ,f_pscy.bank_account_e    
                            ,f_pscy.payee_e           
                            ,f_pscy.bank_address_e  
                            )  
    
    IF SQLCA.SQLCODE != 0 THEN
       ROLLBACK WORK
       LET f_rcode=2
       RETURN f_rcode
    END IF

    COMMIT WORK

    RETURN f_rcode
    WHENEVER ERROR STOP
END FUNCTION -- psc01m_edit_pscy_dsp() --

-- 100/03/31 END

------------------------------------------------------------------------------
--  函式名稱: psc01m_edit_pscs
--  作    者: jessica Chang
--  日    期: 87/09/09
--  處理概要: 還本電匯特殊指定
--  重要函式:
------------------------------------------------------------------------------
FUNCTION psc01m_edit_pscs()
    DEFINE f_rcode  INTEGER

    LET f_rcode=0

    MESSAGE " END:取消作業" ATTRIBUTE (WHITE)

    OPEN WINDOW psc01m_pscs AT 10,01 WITH FORM "psc01m04"
    ATTRIBUTE (GREEN,FORM LINE FIRST,PROMPT LINE LAST,MESSAGE LINE LAST)

--    DISPLAY p_data_s1.policy_no ,p_data_s1.cp_anniv_date
--         TO policy_no           ,cp_anniv_date
--            ATTRIBUTE (YELLOW)

    CALL psc01m_edit_pscs_dsp()
         RETURNING f_rcode

    CASE
       WHEN INT_FLAG=TRUE
          LET INT_FLAG=FALSE
          ERROR "放棄輸入!!"
       WHEN f_rcode = 0
          ERROR "電匯指示作業完成!!"
      WHEN f_rcode = 1
          ERROR "pscs 更新失敗 !!"
       WHEN f_rcode = 2
          ERROR "pscs 新增失敗 !!"
    END CASE

    CLOSE WINDOW psc01m_pscs

    RETURN f_rcode

END FUNCTION -- psc01m_edit_pscs --

------------------------------------------------------------------------------
--  函式名稱: psc01m_edit_pscs_dsp
--  作    者: jessica Chang
--  日    期: 87/08/04
--  處理概要: 還本回覆作業,電匯特殊指示
--  重要函式:
------------------------------------------------------------------------------

FUNCTION psc01m_edit_pscs_dsp()

    DEFINE f_i          INTEGER
          ,f_rcode      INTEGER
          ,f_pscs_sw    INTEGER
          ,f_ans_sw     CHAR(1)   -- prompt 的回覆 --

    DEFINE f_remit_bank CHAR(3)
    DEFINE f_pscs       RECORD  LIKE pscs.*
    DEFINE f_bank_name  LIKE    bank.bank_name
          ,f_bank_code  LIKE    bank.bank_code

    DEFINE f_chk_remit_err CHAR(1)
          ,f_chk_remit_msg CHAR(255)

    DEFINE f_dummy_flag CHAR(2)


    LET f_rcode     =0
    LET f_pscs_sw   ="0"
    LET f_dummy_flag=""
    LET f_bank_name =""
    LET f_bank_code =""
    LET f_chk_remit_err="0"
    LET f_chk_remit_msg=""

    SELECT * INTO f_pscs.*
    FROM   pscs
    WHERE  policy_no    =p_data_s1.policy_no
    AND    cp_anniv_date=p_data_s1.cp_anniv_date

    IF STATUS = NOTFOUND THEN
       LET f_pscs_sw="0"
       LET f_pscs.policy_no    =p_data_s1.policy_no
       LET f_pscs.cp_anniv_date=p_data_s1.cp_anniv_date
       LET f_pscs.payee        =""
       LET f_pscs.client_id    =""
       LET f_pscs.remit_bank   =""
       LET f_pscs.remit_branch =""
       LET f_pscs.remit_account=""
    ELSE
       LET f_pscs_sw="1"
       LET f_bank_code=f_pscs.remit_bank,f_pscs.remit_branch

       SELECT bank_name INTO f_bank_name
       FROM   bank
       WHERE  bank_code=f_bank_code

       LET f_bank_name=f_bank_name 
       DISPLAY f_bank_name to bank_name

    END IF

    INPUT f_pscs.client_id
         ,f_pscs.payee
         ,f_pscs.remit_bank
         ,f_pscs.remit_branch
         ,f_pscs.remit_account
    WITHOUT DEFAULTS
    FROM  client_id
         ,payee
         ,remit_bank
         ,remit_branch
         ,remit_account
    ATTRIBUTE (YELLOW,UNDERLINE)

    AFTER FIELD client_id
          LET f_pscs.client_id=UPSHIFT(f_pscs.client_id)
          IF length(f_pscs.client_id	CLIPPED )=0 THEN
             ERROR "受款人必須輸入!!"
                   ATTRIBUTE (RED)
             NEXT FIELD client_id
          ELSE
             SELECT names
             INTO   f_pscs.payee
             FROM   clnt
             WHERE  client_id=f_pscs.client_id
             IF STATUS = NOTFOUND THEN
                LET f_pscs.payee=""
             ELSE
                LET f_pscs.payee=f_pscs.payee CLIPPED
             END IF
             DISPLAY f_pscs.client_id TO client_id
             DISPLAY f_pscs.payee TO payee
          END IF

    AFTER FIELD payee
          IF f_pscs.payee =" "     OR
             f_pscs.payee IS NULL  THEN
             ERROR "受款人必須輸入!!"
                   ATTRIBUTE (RED)
             NEXT FIELD payee
          ELSE
              LET f_pscs.payee=f_pscs.payee CLIPPED
          END IF

    AFTER FIELD remit_bank
          IF f_pscs.remit_bank=" "     OR
             f_pscs.remit_bank IS NULL  THEN
             ERROR "電匯銀行必須輸入!!"
                   ATTRIBUTE (RED)
             NEXT FIELD remit_bank
          END IF

          SELECT DISTINCT bank_code[1,3]
          INTO   f_remit_bank
          FROM   bank
          WHERE  bank_code[1,3]= f_pscs.remit_bank

          IF STATUS = NOTFOUND THEN
             ERROR "請輸入正確銀行代碼 !!"
                   ATTRIBUTE (RED)
             NEXT FIELD remit_bank
          END IF
--          NEXT FIELD remit_branch

    AFTER FIELD remit_branch
          IF f_pscs.remit_branch=" "      OR
             f_pscs.remit_branch=""       THEN
             ERROR "電匯分行必須輸入!!"
                   ATTRIBUTE (RED)
             NEXT FIELD remit_branch
          END IF

          LET f_bank_code=f_pscs.remit_bank,f_pscs.remit_branch
          
          SELECT bank_name INTO f_bank_name
          FROM   bank
          WHERE  bank_code=f_bank_code

          LET f_bank_name=f_bank_name CLIPPED
          DISPLAY f_bank_name to bank_name
--          NEXT FIELD remit_account

    AFTER FIELD remit_account
          IF f_pscs.remit_account=" "     OR
             f_pscs.remit_account IS NULL  THEN
             ERROR "電匯帳號必須輸入!!"
                   ATTRIBUTE (RED)
             NEXT FIELD remit_account
          END IF

          CALL chkRemitAcct (f_pscs.remit_bank
                            ,f_pscs.remit_branch
                            ,f_pscs.remit_account
                            )
               RETURNING f_chk_remit_err,f_chk_remit_msg
          IF f_chk_remit_err="0" THEN
             LET f_dummy_flag="ok"
          ELSE
             ERROR f_chk_remit_msg ATTRIBUTE(RED)
             NEXT FIELD remit_bank
          END IF

    AFTER INPUT
       IF INT_FLAG=TRUE THEN
          EXIT INPUT
       END IF

       LET f_ans_sw=" "
       PROMPT "確認存檔請按 Y --->" ATTRIBUTE (WHITE) FOR CHAR f_ans_sw
              ATTRIBUTE (YELLOW)
       IF UPSHIFT(f_ans_sw) !="Y" OR
          f_ans_sw IS NULL        THEN
          NEXT FIELD payee
       END IF

    END INPUT

    IF INT_FLAG=TRUE THEN
       LET f_rcode=0
       RETURN f_rcode
    END IF

    BEGIN WORK
    WHENEVER ERROR CONTINUE

    -- 新增 --
    IF f_pscs_sw="0" THEN

       INSERT INTO pscs VALUES(f_pscs.*)

       IF SQLCA.SQLCODE != 0 THEN
          ROLLBACK WORK
          LET f_rcode=2
          RETURN f_rcode
       END IF
    END IF

    -- 更新 --
    IF f_pscs_sw="1" THEN
       UPDATE pscs
       SET    payee        =f_pscs.payee
             ,client_id    =f_pscs.client_id
             ,remit_bank   =f_pscs.remit_bank
             ,remit_branch =f_pscs.remit_branch
             ,remit_account=f_pscs.remit_account
       WHERE  policy_no    =f_pscs.policy_no
       AND    cp_anniv_date=f_pscs.cp_anniv_date

       IF SQLCA.SQLCODE != 0 THEN
          ROLLBACK WORK
          LET f_rcode=1
          RETURN f_rcode
       END IF
    END IF

    COMMIT WORK

    RETURN f_rcode
    WHENEVER ERROR STOP
END FUNCTION -- psc01m_edit_pscs_dsp() --

------------------------------------------------------------------------------
--  函式名稱: psc00m_sel_2
--  作    者: jessica Chang
--  日    期: 089/01/06
--  處理概要: 選擇處理還本處理單筆未回覆的資料
--  重要函式:
------------------------------------------------------------------------------
FUNCTION  psc00m_sel_2()
    DEFINE f_rcode INTEGER
    DEFINE f_polf_exist      INTEGER  -- 保單檢核 --
          ,f_pscb_exist      INTEGER  -- 還本檔檢核 --
          ,f_chkdate_sw      INTEGER  -- 日期檢核 --
          ,f_format_date     CHAR(9)  -- 格式化的日期 --

    DEFINE f_ins_pscn        CHAR(1)  --  N:不做 pscn 維護
          ,f_call_psc00m00   CHAR(1)  --  N:進入領取
          ,f_psc00m00_rcode  CHAR(1)

    LET f_rcode=0
    LET f_chkdate_sw=true
    LET f_format_date=""

    MESSAGE " 請輸入條件。Esc: 接受，End: 放棄。" ATTRIBUTE (YELLOW)

    OPEN WINDOW w_psc00m01 AT 10,11 WITH FORM "psc00m01"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                   , PROMPT LINE LAST )

    LET f_rcode         =0
    LET f_polf_exist    =0
    LET f_pscb_exist    =0
    LET f_chkdate_sw    =TRUE
    LET f_format_date   =""
    LET f_ins_pscn      ="N"
    LET f_psc00m00_rcode="0"

    DISPLAY p_policy_no,p_cp_anniv_date TO policy_no,cp_anniv_date

    INPUT p_policy_no,p_cp_anniv_date FROM
          policy_no,cp_anniv_date
          ATTRIBUTE (BLUE ,REVERSE ,UNDERLINE)

          AFTER FIELD policy_no
                SELECT count(*) INTO f_polf_exist
                FROM   polf
                WHERE  policy_no=p_policy_no

                IF f_polf_exist=0  THEN
                   ERROR "保單不存在!!"
                   NEXT FIELD policy_no
                END IF

          AFTER FIELD cp_anniv_date
                CALL CheckDate(p_cp_anniv_date) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "日期輸入錯誤!!"
                   NEXT FIELD cp_anniv_date
                END IF
                LET p_cp_anniv_date=f_format_date
                DISPLAY p_cp_anniv_date TO cp_anniv_date

          AFTER INPUT
                IF INT_FLAG=TRUE  THEN
                   EXIT INPUT
                END IF

                SELECT count(*) INTO f_polf_exist
                FROM   polf
                WHERE  policy_no=p_policy_no

                IF f_polf_exist=0  THEN
                   ERROR "保單不存在!!"
                   NEXT FIELD policy_no
                END IF

                CALL CheckDate(p_cp_anniv_date) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "日期輸入錯誤!!"
                   NEXT FIELD cp_anniv_date
                END IF

                LET p_cp_anniv_date=f_format_date
                DISPLAY p_cp_anniv_date TO cp_anniv_date

                SELECT count(*)
                INTO   f_pscb_exist
                FROM   pscb
                WHERE  policy_no    =p_policy_no
                AND    cp_anniv_date=p_cp_anniv_date
                AND    cp_sw in ("1","3","4","7")

                IF f_pscb_exist =0 THEN
                   ERROR "還本檔中無此筆資料 !!"
                   NEXT  FIELD policy_no
                END IF

    END INPUT

    IF INT_FLAG THEN
       ERROR "單筆未回覆作業放棄 !!"
       LET INT_FLAG = FALSE
       CLOSE WINDOW w_psc00m01
       RETURN
    END IF

    CLOSE WINDOW w_psc00m01

    LET p_act_return_date=p_tran_date
    LET p_cp_notice_code="2"
    LET p_data_s1.cp_disb_type="4"

    CALL psc00m00_input() RETURNING f_rcode
    -- 領取回覆的資料不存,離開 --
    IF f_rcode =1 THEN
       ERROR "回覆資料,領取資料放棄作業 !!"
       LET f_rcode=0
       RETURN
    ELSE
       ERROR "單筆未回覆作業完成 !!"
    END IF

    RETURN
END FUNCTION -- psc00m_sel_2 --

------------------------------------------------------------------------------
--  函式名稱: psc00m_sel_3
--  作    者: jessica Chang
--  日    期: 089/01/06
--  處理概要: 未回覆資料整批處理
--  重要函式:
------------------------------------------------------------------------------
FUNCTION  psc00m_sel_3()
    DEFINE f_rcode           INTEGER
	  ,f_upd_psck_sw     INTEGER
          ,f_ans_sw          CHAR(1)
    DEFINE f_total_cnt       INTEGER  -- 合於條件的資料筆數 --
          ,f_input_date      CHAR(9)  -- 輸入的日期 --
          ,f_chkdate_sw      INTEGER  -- 日期檢核 --
          ,f_format_date     CHAR(9)  -- 格式化的日期 --
    DEFINE f_pscb   RECORD LIKE  pscb.*
    DEFINE f_currency CHAR(3)
    DEFINE DateTest CHAR(9)
    DEFINE f_today   CHAR(9)
    DEFINE f_time    CHAR(8)

    LET f_rcode=0
    LET f_upd_psck_sw=0
    LET f_chkdate_sw=true
    LET f_format_date=""
    LET f_total_cnt=0
    LET f_input_date=""
    LET f_ans_sw="N"

    MESSAGE " 請輸入條件。Esc: 接受，End: 放棄。" ATTRIBUTE (YELLOW)

    OPEN WINDOW w_psc00m07 AT 10,11 WITH FORM "psc00m07"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                   , PROMPT LINE LAST )

    LET f_rcode         =0
    LET f_chkdate_sw    =TRUE
    LET f_format_date   =""

    INPUT f_input_date WITHOUT DEFAULTS FROM
          inp_date
          ATTRIBUTE (BLUE ,REVERSE ,UNDERLINE)

          AFTER FIELD inp_date
                CALL CheckDate(f_input_date   ) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "日期輸入錯誤!!"
                   NEXT FIELD inp_date
                END IF
                LET f_input_date=f_format_date
            --    DISPLAY "f_format_date:",f_format_date
                CALL AddYear(GetDate(TODAY),-1) RETURNING DateTest
            --    DISPLAY "DateTest:",DateTest
                IF f_format_date >= AddYear(GetDate(TODAY),-1) THEN 
                	ERROR "輸入日期須小於一年"
                	NEXT FIELD inp_date
                END IF
                
                -- 100/03/31 MODIFY 排除外幣保單，不能進行整批未回覆
                SELECT count(*) INTO f_total_cnt
                FROM   pscb a,polf b
                WHERE  a.cp_notice_sw="4"
                AND    a.cp_sw in ("1","3","7","8")
                AND    a.cp_anniv_date <= f_input_date
                AND    a.policy_no = b.policy_no
                AND    b.currency ='TWD'
                -- 100/03/31 END
                
                DISPLAY f_total_cnt TO total_cnt

                IF f_total_cnt=0 THEN
                   ERROR "無合乎的資料 !!"
                   NEXT  FIELD inp_date
                END IF

          AFTER INPUT
                IF INT_FLAG=TRUE  THEN
                   EXIT INPUT
                END IF

                CALL CheckDate(f_input_date   ) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "日期輸入錯誤!!"
                   NEXT FIELD inp_date
                END IF
                LET f_input_date=f_format_date

                -- 100/03/31 MODIFY 排除外幣保單，不能進行整批未回覆
                SELECT count(*) INTO f_total_cnt
                FROM   pscb a,polf b
                WHERE  a.cp_notice_sw="4"
                AND    a.cp_sw in ("1","3","7","8")
                AND    a.cp_anniv_date <= f_input_date
                AND    a.policy_no = b.policy_no
                AND    b.currency ='TWD'
                -- 100/03/31 END
                
                DISPLAY f_total_cnt TO total_cnt

                IF f_total_cnt=0 THEN
                   ERROR "無合乎的資料 !!"
                   NEXT  FIELD inp_date
                END IF

                LET f_ans_sw=""
                PROMPT "  確認存檔請按 Y" FOR CHAR f_ans_sw
                IF UPSHIFT(f_ans_sw) !="Y" OR
                   f_ans_sw IS NULL        THEN
                   NEXT FIELD inp_date
                END IF

    END INPUT

    IF INT_FLAG THEN
       ERROR "整批未回覆作業放棄 !!"
       LET INT_FLAG = FALSE
       CLOSE WINDOW w_psc00m07
       RETURN
    END IF

    CLOSE WINDOW w_psc00m07

    ERROR  "資料處理中,請耐心等候 ........."
           ATTRIBUTE  (RED)

    WHENEVER ERROR CONTINUE

    DECLARE pscb_crs CURSOR WITH HOLD FOR
    	      -- 100/03/31 MODIFY 排除外幣保單，不能進行整批未回覆
            SELECT a.*
            FROM   pscb a, polf b
            WHERE  a.cp_notice_sw="4"
            AND    a.cp_sw in ("1","3","7","8")
            AND    a.cp_anniv_date <= f_input_date
            AND    a.policy_no = b.policy_no
            AND    b.currency ='TWD'
            -- 100/03/31 END
                
    FOREACH pscb_crs INTO f_pscb.*

        BEGIN WORK
  
	IF upd_psck(f_pscb.policy_no, f_pscb.cp_anniv_date) THEN
	   ROLLBACK WORK
	   EXIT FOREACH
	END IF

        LET f_today = GetDate(TODAY)
        LET f_time = CURRENT HOUR TO SECOND 
        INSERT INTO pscba  VALUES ( f_pscb.policy_no       ,
                                    f_pscb.cp_anniv_date   ,
                                    f_today                ,
                                    f_time                 ,
                                    g_user                 ,
                                    "0"
                                  )
        IF SQLCA.SQLCODE != 0 THEN
           ROLLBACK WORK
           ERROR "insert pscba error on psc00m_sel_3 !!"
           LET f_rcode=1
           EXIT FOREACH 
        END IF 

        UPDATE pscb
        SET    cp_notice_sw="3"
              ,change_date =p_tran_date
              ,process_date=p_tran_date
              ,process_user=g_user
        WHERE  policy_no    =f_pscb.policy_no
        AND    cp_anniv_date=f_pscb.cp_anniv_date

        IF SQLCA.SQLCODE != 0 THEN
           ROLLBACK WORK
           ERROR "update pscb error on psc00m_sel_3 !!"
           LET f_rcode=1
           EXIT FOREACH
        ELSE
           COMMIT WORK
        END  IF
    END FOREACH

    ERROR "整批未回覆領取處理完畢 !!"
    RETURN
END FUNCTION -- psc00m_sel_3 --

------------------------------------------------------------------------------
--  函式名稱: upd_psck
--  作    者: Kobe
--  日    期: 091/11/11
--  處理概要: 於註記檔紀錄整批未回領取
--  重要函式:
------------------------------------------------------------------------------
FUNCTION upd_psck(f_policy_no, f_cp_anniv_date)

    DEFINE f_policy_no		LIKE pscb.policy_no
	  ,f_cp_anniv_date	LIKE pscb.cp_anniv_date

    DEFINE f_psck		RECORD LIKE psck.*

    DEFINE f_upd_psck_sw	INTEGER

    DEFINE f_process_date       CHAR(9)
    	  ,f_process_time       CHAR(8)
          ,f_process_user       CHAR(8)

    DEFINE f_user_code          LIKE edp_base:usrdat.user_code
          ,f_user_id            LIKE edp_base:usrdat.id_code
          ,f_user_name          LIKE edp_base:usrdat.user_name
          ,f_dept_code          LIKE edp_base:usrdat.dept_code


    LET f_process_date = GetDate(TODAY)
    LET f_process_time = TIME
    LET f_process_user = g_user

    CALL GetUserData(g_user)
         RETURNING f_user_code
                  ,f_user_id
                  ,f_user_name
                  ,f_dept_code

    UPDATE pscb
    SET    cp_remark_sw  = "Y"
    WHERE  policy_no     = f_policy_no
    AND    cp_anniv_date = f_cp_anniv_date

    IF SQLCA.SQLCODE != 0 THEN
       ERROR "error :update pscb ",f_policy_no
       RETURN TRUE
    END IF

    SELECT *
    INTO   f_psck.*
    FROM   psck
    WHERE  policy_no     = f_policy_no
    AND    cp_anniv_date = f_cp_anniv_date

    IF  STATUS = NOTFOUND THEN
	LET f_psck.policy_no            =f_policy_no
	LET f_psck.cp_anniv_date        =f_cp_anniv_date
	LET f_psck.cp_remark_desc_1     =f_process_date,
					 "還本金逾期未回覆領取，開票待領中。（", f_user_name CLIPPED, "）"
	LET f_psck.cp_remark_desc_2     =" "
	LET f_psck.cp_remark_desc_3     =" "
	LET f_psck.cp_remark_desc_4     =" "
	LET f_psck.cp_remark_desc_5     =" "
	LET f_psck.process_date         =f_process_date
	LET f_psck.process_time         =f_process_time
	LET f_psck.process_user         =f_process_user

        LET f_psck.nonresp_sw           = "Y" 

	INSERT INTO psck VALUES (f_psck.*)
	IF SQLCA.SQLCODE != 0 THEN
	   ERROR "error :insert psck ",f_policy_no
	   RETURN TRUE
	END IF
	RETURN FALSE
    END IF

    IF  LENGTH(f_psck.cp_remark_desc_2 CLIPPED) = 0 THEN
	LET f_psck.cp_remark_desc_2 = f_process_date,
				      "還本金逾期未回覆領取，開票待領中。（", f_user_name CLIPPED,"）"

	UPDATE psck
	SET    cp_remark_desc_2 = f_psck.cp_remark_desc_2
	      ,process_date	= f_process_date
	      ,process_time	= f_process_time
	      ,process_user	= f_process_user
              ,nonresp_sw       = "Y" 
	WHERE  policy_no	= f_policy_no
	AND    cp_anniv_date	= f_cp_anniv_date

	IF  SQLCA.SQLCODE != 0 THEN
            ERROR "error :update psck ",f_policy_no
            RETURN TRUE
        END IF
        RETURN FALSE
    END IF

    IF  LENGTH(f_psck.cp_remark_desc_3 CLIPPED) = 0 THEN
        LET f_psck.cp_remark_desc_3 = f_process_date,
                                      "還本金逾期未回覆領取，開票待領中。（", f_user_name CLIPPED,"）"

        UPDATE psck
        SET    cp_remark_desc_3 = f_psck.cp_remark_desc_3
              ,process_date     = f_process_date
              ,process_time     = f_process_time
              ,process_user     = f_process_user
              ,nonresp_sw       = "Y"
        WHERE  policy_no        = f_policy_no
        AND    cp_anniv_date    = f_cp_anniv_date

        IF  SQLCA.SQLCODE != 0 THEN
            ERROR "error :update psck ",f_policy_no
            RETURN TRUE
        END IF
        RETURN FALSE
    END IF

    IF  LENGTH(f_psck.cp_remark_desc_4 CLIPPED) = 0 THEN
        LET f_psck.cp_remark_desc_4 = f_process_date,
                                      "還本金逾期未回覆領取，開票待領中。（", f_user_name CLIPPED,"）"

        UPDATE psck
        SET    cp_remark_desc_4 = f_psck.cp_remark_desc_4
              ,process_date     = f_process_date
              ,process_time     = f_process_time
              ,process_user     = f_process_user
              ,nonresp_sw       = "Y"
        WHERE  policy_no        = f_policy_no
        AND    cp_anniv_date    = f_cp_anniv_date

        IF  SQLCA.SQLCODE != 0 THEN
            ERROR "error :update psck ",f_policy_no
            RETURN TRUE
        END IF
        RETURN FALSE
    END IF

    IF  LENGTH(f_psck.cp_remark_desc_5 CLIPPED) = 0 THEN
        LET f_psck.cp_remark_desc_5 = f_process_date,
                                      "還本金逾期未回覆領取，開票待領中。（", f_user_name CLIPPED,"）"

        UPDATE psck
        SET    cp_remark_desc_5 = f_psck.cp_remark_desc_5
              ,process_date     = f_process_date
              ,process_time     = f_process_time
              ,process_user     = f_process_user
              ,nonresp_sw       = "Y"
        WHERE  policy_no        = f_policy_no
        AND    cp_anniv_date    = f_cp_anniv_date

        IF  SQLCA.SQLCODE != 0 THEN
            ERROR "error :update psck ",f_policy_no
            RETURN TRUE
        END IF
        RETURN FALSE
    END IF

    ERROR "error :psck no space ",f_policy_no
    RETURN TRUE

END FUNCTION

------------------------------------------------------------------------------
--  函式名稱: psc00m_sel_4
--  作    者: jessica Chang
--  日    期: 089/01/06
--  處理概要: 選擇處理還本處理,給付作業修改
--  重要函式:
------------------------------------------------------------------------------
FUNCTION  psc00m_sel_4()
    DEFINE f_rcode INTEGER
    DEFINE f_polf_exist      INTEGER  -- 保單檢核 --
          ,f_pscb_exist      INTEGER  -- 還本檔檢核 --
          ,f_chkdate_sw      INTEGER  -- 日期檢核 --
          ,f_format_date     CHAR(9)  -- 格式化的日期 --

    DEFINE f_ins_pscn        CHAR(1)  --  N:不做 pscn 維護
          ,f_call_psc00m00   CHAR(1)  --  N:進入領取
          ,f_psc00m00_rcode  CHAR(1)


    LET f_rcode=0
    LET f_chkdate_sw=true
    LET f_format_date=""

    MESSAGE " 請輸入條件。Esc: 接受，End: 放棄。" ATTRIBUTE (YELLOW)

    OPEN WINDOW w_psc00m01 AT 10,11 WITH FORM "psc00m01"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST )

    LET f_rcode         =0
    LET f_polf_exist    =0
    LET f_pscb_exist    =0
    LET f_chkdate_sw    =TRUE
    LET f_format_date   =""
    LET f_ins_pscn      ="N"
    LET f_psc00m00_rcode="0"

    DISPLAY p_policy_no,p_cp_anniv_date TO policy_no,cp_anniv_date

    INPUT p_policy_no,p_cp_anniv_date FROM
          policy_no,cp_anniv_date
          ATTRIBUTE (BLUE ,REVERSE ,UNDERLINE)

          AFTER FIELD policy_no
                SELECT count(*) INTO f_polf_exist
                FROM   polf
                WHERE  policy_no=p_policy_no

                IF f_polf_exist=0  THEN
                   ERROR "保單不存在!!"
                   NEXT FIELD policy_no
                END IF

          AFTER FIELD cp_anniv_date
                CALL CheckDate(p_cp_anniv_date) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "日期輸入錯誤!!"
                   NEXT FIELD cp_anniv_date
                END IF
                LET p_cp_anniv_date=f_format_date
                DISPLAY p_cp_anniv_date TO cp_anniv_date

          AFTER INPUT
                IF INT_FLAG=TRUE  THEN
                   EXIT INPUT
                END IF

                SELECT count(*) INTO f_polf_exist
                FROM   polf
                WHERE  policy_no=p_policy_no

                IF f_polf_exist=0  THEN
                   ERROR "保單不存在!!"
                   NEXT FIELD policy_no
                END IF

                CALL CheckDate(p_cp_anniv_date) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "日期輸入錯誤!!"
                   NEXT FIELD cp_anniv_date
                END IF

                LET p_cp_anniv_date=f_format_date
                DISPLAY p_cp_anniv_date TO cp_anniv_date

                SELECT count(*)
                INTO   f_pscb_exist
                FROM   pscb
                WHERE  policy_no    =p_policy_no
                AND    cp_anniv_date=p_cp_anniv_date
                AND    cp_sw in ("1","3","4","7")

                IF f_pscb_exist =0 THEN
                   ERROR "還本檔中無此筆資料 !!"
                   NEXT  FIELD policy_no
                END IF

    END INPUT

    IF INT_FLAG THEN
       ERROR "給付修改放棄 !!"
       LET INT_FLAG = FALSE
       CLOSE WINDOW w_psc00m01
       RETURN
    END IF

    CLOSE WINDOW w_psc00m01

    LET p_act_return_date=p_tran_date

    CALL psc01m_init()
    CALL psc01m_query() RETURNING f_rcode
    IF f_rcode !=0 THEN
       ERROR "給付資料,放棄修改 !!"
    ELSE
       ERROR "給付修改完成 !!"
    END IF

    RETURN
END FUNCTION -- psc00m_sel_4 --

------------------------------------------------------------------------------
--  函式名稱: psc00m_sel_5
--  作    者: jessica Chang
--  日    期: 089/01/06
--  處理概要: 選擇照會單的列印--單筆
--  重要函式:
------------------------------------------------------------------------------
FUNCTION  psc00m_sel_5()

    DEFINE f_rcode           INTEGER
          ,f_copies          INTEGER
          ,f_rpt_name_1      CHAR(30)
          ,f_rpt_code_1      CHAR(20)
          ,f_rpt_cmd         CHAR(1024)
    DEFINE f_polf_exist      INTEGER  -- 保單檢核 --
          ,f_pscb_exist      INTEGER  -- 還本檔檢核 --
          ,f_chkdate_sw      INTEGER  -- 日期檢核 --
          ,f_format_date     CHAR(9)  -- 格式化的日期 --

    DEFINE f_ins_pscn        CHAR(1)  --  N:不做 pscn 維護
          ,f_call_psc00m00   CHAR(1)  --  N:進入領取
          ,f_psc00m00_rcode  CHAR(1)


    MESSAGE " 請輸入條件。Esc: 接受，End: 放棄。" ATTRIBUTE (YELLOW)

    OPEN WINDOW w_psc00m09 AT 10,11 WITH FORM "psc00m09"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST )

    LET f_rcode         =0
    LET f_polf_exist    =0
    LET f_pscb_exist    =0
    LET f_chkdate_sw    =TRUE
    LET f_format_date   =""
    LET f_ins_pscn      ="N"
    LET f_psc00m00_rcode="0"

    DISPLAY p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code
	 TO policy_no,cp_anniv_date,cp_notice_sub_code

    INPUT p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code FROM
          policy_no,cp_anniv_date,cp_notice_sub_code
          ATTRIBUTE (BLUE ,REVERSE ,UNDERLINE)

          AFTER FIELD policy_no
                SELECT count(*) INTO f_polf_exist
                FROM   polf
                WHERE  policy_no=p_policy_no

                IF f_polf_exist=0  THEN
                   CALL get_ia(p_policy_no) RETURNING f_rtn ----0-正常; 1-有誤
                   IF f_rtn = 1 THEN
                   ERROR "保單不存在!!"
                   NEXT FIELD policy_no
                   ELSE
                       LET p_pt_sw = '1'
                   END IF
                END IF

          AFTER FIELD cp_anniv_date
                CALL CheckDate(p_cp_anniv_date) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "日期輸入錯誤!!"
                   NEXT FIELD cp_anniv_date
                END IF
                LET p_cp_anniv_date=f_format_date
                DISPLAY p_cp_anniv_date TO cp_anniv_date

	  AFTER FIELD cp_notice_sub_code
		IF LENGTH(p_cp_notice_sub_code CLIPPED)=0 THEN
		   ERROR "處理方式必須輸入   !!"
                       NEXT FIELD cp_notice_sub_code
                    END IF
		IF p_cp_notice_sub_code NOT MATCHES "[1-2]" THEN
		   ERROR "處理方式輸入錯誤   !!"
		   NEXT FIELD cp_notice_sub_code
		END IF

          AFTER INPUT
                IF INT_FLAG=TRUE  THEN
                   EXIT INPUT
                END IF

                SELECT count(*) INTO f_polf_exist
                FROM   polf
                WHERE  policy_no=p_policy_no

                IF f_polf_exist=0  THEN
                   CALL get_ia(p_policy_no) RETURNING f_rtn ----0-正常; 1-有誤
                   IF f_rtn = 1 THEN
                   ERROR "保單不存在!!"
                   NEXT FIELD policy_no
                   ELSE
                       LET p_pt_sw = '1'
                   END IF
                END IF

                CALL CheckDate(p_cp_anniv_date) RETURNING
                     f_chkdate_sw,f_format_date
                IF f_chkdate_sw=FALSE THEN
                   ERROR "日期輸入錯誤!!"
                   NEXT FIELD cp_anniv_date
                END IF

                LET p_cp_anniv_date=f_format_date
                DISPLAY p_cp_anniv_date TO cp_anniv_date

             IF p_pt_sw = '1' THEN ----給付保單
                SELECT count(*) INTO f_pscb_exist
                FROM   ptpd
                WHERE  policy_no      = p_policy_no
                AND    payout_due     = p_cp_anniv_date
--                AND    live_certi_ind = 'Y'
                AND    opt_notice_sw  in ( '1','2')----回覆狀態 1.等待回覆 2.已經回覆
                AND    process_sw     = '0'        ----初始值   1.已經給付
                IF f_pscb_exist = 0 THEN
                   ERROR "給付檔中無此筆資料 !!"
                   NEXT  FIELD policy_no
                END IF
                IF  g_poia.po_sts_code !='53' THEN 
                    ERROR '年金保單狀態不符，不需回覆'
                   NEXT  FIELD policy_no
                END IF

                IF  p_cp_anniv_date > AddDay(p_tx_date,45) OR g_poia.po_sts_code !='53' THEN 
                   ERROR '此保單位於非回覆期間，不需回覆'
                   NEXT  FIELD policy_no
                END IF

             ELSE
                SELECT count(*)
                INTO   f_pscb_exist
                FROM   pscb
                WHERE  policy_no    =p_policy_no
                AND    cp_anniv_date=p_cp_anniv_date
                AND    cp_sw in ("1","3","4","7","8")

                IF f_pscb_exist =0 THEN
                   ERROR "還本檔中無此筆資料 !!"
                   NEXT  FIELD policy_no
                END IF
             END IF
    END INPUT

    IF INT_FLAG THEN
       ERROR "放棄照會單的列印!!"
       LET INT_FLAG = FALSE
       CLOSE WINDOW w_psc00m09
       RETURN
    END IF

    CLOSE WINDOW w_psc00m09

    -- 照會單報表檔 --
    IF p_cp_notice_sub_code = "1" THEN
       LET f_rpt_code_1    ="psc00m01"
    ELSE
       LET f_rpt_code_1	   ="psc00m02"
    END IF

    IF p_cp_notice_sub_code = "1" THEN
       LET f_rpt_code_1    ="psc00m01"
    ELSE
       LET f_rpt_code_1    ="psc00m02"
    END IF

    LET ans = '1'
    IF p_cp_notice_sub_code = "1" THEN
    PROMPT " 請選擇列印方式 : 0.IDMS 列印  1:線上列印  ", p_bell
    ATTRIBUTE (YELLOW)
    FOR CHAR ans
    IF ans NOT MATCHES "[0]" THEN
       LET ans = '1'
    END IF
    IF ans IS NULL OR ans = ' ' THEN
       LET ans = '1'
    END IF
    END IF

    IF ans = '0' and p_cp_notice_sub_code = "1" THEN   -- 送至 PSM 平台
       CALL PSManagerName(f_rpt_code_1) RETURNING f_rpt_name_1
    ELSE                     -- Local
       CALL ReportName(f_rpt_code_1) RETURNING f_rpt_name_1
    END IF

    IF p_cp_notice_sub_code = "1" THEN
      IF p_pt_sw = '1' THEN
       START REPORT print_notice_pt TO f_rpt_name_1
           CALL psc_pt_notice(p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code,"O")
	    RETURNING f_rcode
       FINISH REPORT print_notice_pt
       ELSE

       START REPORT print_notice  TO f_rpt_name_1

CALL psc_print_notice(p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code,"O",ans,p_po_chg_rece_no)
            RETURNING f_rcode
       FINISH REPORT print_notice
      END IF
    ELSE
          IF p_pt_sw = '1' THEN
          START REPORT print_insure_pt TO f_rpt_name_1
	  CALL psc_ptins_notice(p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code)
	       RETURNING f_rcode
          FINISH REPORT print_insure_pt
          ELSE
       START REPORT print_insure  TO f_rpt_name_1

       CALL psc_insure_notice(p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code)
            RETURNING f_rcode
       FINISH REPORT print_insure
          END IF
    END IF
    IF f_rcode =0 THEN
       IF ans = '0' and p_cp_notice_sub_code = "1" THEN   --  PSM
          LET f_rpt_cmd = "psmanager ",f_rpt_name_1  -- PSM
          RUN f_rpt_cmd
          ERROR "照會單列印完成 !!"
       ELSE                     -- Local 列印
          LET f_copies=SelectPrinter (f_rpt_name_1)
          IF (f_copies ) THEN
             LET f_rpt_cmd= "locprn -n ",f_copies USING " <<< "
                           ,f_rpt_name_1 CLIPPED
             RUN f_rpt_cmd
             ERROR "照會單列印完成 !!"
          END IF
       END IF
    END IF

    RETURN
END FUNCTION -- psc00m_sel_5 --
-------------------------------------------------------------------------------------
FUNCTION psc01m_disb_type_1(f_serivce_agt_name
                           ,f_agt_deptbelong
                           )
    DEFINE f_serivce_agt_name  CHAR(40)
          ,f_agt_deptbelong    CHAR(6)
          ,f_sel_dept_code     CHAR(6)
          ,f_sel_dept_name     CHAR(18)

    DEFINE f_rcode INTEGER
          ,f_ans_sw CHAR(1)
          ,f_dept_name CHAR(18)
    DEFINE f_pay_ind CHAR(1)
          ,f_pay_name CHAR(30)
          ,f_pay_id   CHAR(10)
          ,f_tel_1		CHAR(11)
          ,f_dept_code CHAR(6)
	  ,f_dept_name_1 CHAR(18)

    LET f_rcode=0
    LET f_ans_sw="N"

    LET f_pay_ind=""
    LET f_pay_name=""
    LET f_pay_id=""
    LET f_dept_code=""
    LET f_dept_name_1=""
    LET f_tel_1 = ""

    SELECT dept_name INTO f_dept_name
    FROM   dept
    WHERE  dept_code=f_agt_deptbelong
		
		SELECT tel_1 
		INTO f_tel_1
		FROM addr 
		WHERE client_id = f_pay_id
			AND addr_ind = "E"

		
    IF length(f_dept_name CLIPPED)=0 THEN
       LET f_dept_name=""
    END IF

    OPEN WINDOW w_psc00m05 AT 10,11 WITH FORM "psc00m05"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                   , PROMPT LINE LAST )

--    DISPLAY p_data_s1.policy_no,p_data_s1.cp_anniv_date
--    TO      policy_no,cp_anniv_date

    INPUT   f_pay_ind,f_pay_id,f_pay_name,f_tel_1
    FROM    pay_ind,cp_pay_id,cp_pay_name,tel_1 

            AFTER FIELD pay_ind
              IF f_pay_ind="0" THEN
                 LET f_pay_name   	= f_serivce_agt_name
                 LET f_pay_id     	= p_agent_code
                 LET f_dept_code  	= f_agt_deptbelong
                 LET f_dept_name_1	= f_dept_name
                 LET f_tel_1            = ''
{
                 SELECT tel_1
                 INTO f_tel_1
                 FROM addr 
                 WHERE client_id = f_pay_id
                 AND addr_ind = "E"
}
                 DISPLAY f_serivce_agt_name,p_agent_code
                        ,f_tel_1,f_agt_deptbelong,f_dept_name
                 TO      cp_pay_name,cp_pay_id,tel_1,dept_code,dept_name
              END IF

            AFTER FIELD cp_pay_id
              LET f_pay_id=UPSHIFT(f_pay_id)
              IF length(f_pay_id   CLIPPED )=0 THEN
                 ERROR "應領資料必須輸入 !!"
                 NEXT FIELD cp_pay_id  
              ELSE
                 SELECT names
                 INTO   f_pay_name
                 FROM   clnt
                 WHERE  client_id=f_pay_id
                 IF STATUS = NOTFOUND THEN
                    LET f_pay_name=""
                 ELSE
                    LET f_pay_name=f_pay_name[1,20]
                 END IF
                 SELECT tel_1
                 INTO f_tel_1
                 FROM addr 
                 WHERE client_id = f_pay_id
                 AND addr_ind = "E"
		 DISPLAY f_pay_id   TO cp_pay_id
                 DISPLAY f_pay_name TO cp_pay_name
		 DISPLAY f_tel_1 TO tel_1             
              END IF

            AFTER FIELD cp_pay_name
              IF length(f_pay_name CLIPPED )=0 THEN
                 ERROR "應領資料必須輸入 !!"
                 NEXT FIELD cp_pay_name
              END IF

              CALL psc01m_dept_code()
                   RETURNING f_rcode
                            ,f_sel_dept_code
                            ,f_sel_dept_name
              LET f_rcode=0
              LET f_dept_code = f_sel_dept_code
              LET f_dept_name_1=f_sel_dept_name
              DISPLAY f_sel_dept_code,f_sel_dept_name
              TO dept_code,dept_name

            AFTER INPUT
              IF INT_FLAG=TRUE THEN
                 EXIT INPUT
              END IF

              IF length(f_pay_ind CLIPPED)=0 THEN
                 ERROR "應領資料必須輸入 !!"
                 NEXT FIELD pay_ind
              END IF

              IF length(f_dept_code CLIPPED)=0 THEN
                 ERROR "應領資料必須輸入 !!"
                 NEXT FIELD pay_ind
              END IF

              IF length(f_pay_name  CLIPPED)=0 THEN
                 ERROR "應領資料必須輸入 !!"
                 NEXT FIELD cp_pay_name
              END IF

              LET f_pay_id=UPSHIFT(f_pay_id) 
              IF length(f_pay_id  CLIPPED)=0 THEN
                 ERROR "應領資料必須輸入 !!"
                 NEXT FIELD cp_pay_id  
              END IF

              LET f_ans_sw=""
              PROMPT "  確認存檔請按 Y" FOR CHAR f_ans_sw
              IF UPSHIFT(f_ans_sw) !="Y" OR
                 f_ans_sw IS NULL        THEN
                 NEXT FIELD pay_ind
              END IF
    END INPUT

    IF INT_FLAG=TRUE THEN
       LET INT_FLAG=FALSE
       LET p_data_s1.cp_pay_name=""
       LET p_data_s1.cp_pay_id  =""
       LET p_dept_code 		=""
       LET p_data_s1.dept_name	=""
       LET p_tel_3 = ""
       LET f_rcode=1
       CLOSE WINDOW w_psc00m05
       RETURN f_rcode
    END IF

    LET p_data_s1.cp_pay_name=f_pay_name
    LET p_data_s1.cp_pay_id  =f_pay_id
    LET p_dept_code	     =f_dept_code
    LET p_data_s1.dept_name  =f_dept_name_1
    LET p_tel_3              =f_tel_1 CLIPPED

    CLOSE WINDOW w_psc00m05
    RETURN f_rcode

END FUNCTION -- psc01m_disb_type_1 --

FUNCTION psc01m_dept_code()
    DEFINE f_rcode    CHAR(1)
    DEFINE f_dept_code CHAR(6)
          ,f_dept_name CHAR(18)
    DEFINE f_i        INTEGER
          ,f_x        INTEGER
          ,f_y        INTEGER
    DEFINE f_dept ARRAY[11] OF RECORD
           dept_code CHAR(6)
          ,dept_name CHAR(18)
                  END RECORD

--089/11/21新增板橋、彰化行政中心
    LET f_dept[1].dept_code="90000"
    LET f_dept[1].dept_name="總公司"
    LET f_dept[2].dept_code="91000"
    LET f_dept[2].dept_name="台北分公司"
    LET f_dept[3].dept_code="92000"
    LET f_dept[3].dept_name="板橋行政中心"
    LET f_dept[4].dept_code="93000"
    LET f_dept[4].dept_name="中壢行政中心"
    LET f_dept[5].dept_code="94000"
    LET f_dept[5].dept_name="台中分公司"
    LET f_dept[6].dept_code="95000"
    LET f_dept[6].dept_name="嘉義分公司"
    LET f_dept[7].dept_code="96000"
    LET f_dept[7].dept_name="台南分公司"
    LET f_dept[8].dept_code="97000"
    LET f_dept[8].dept_name="高雄分公司"
    LET f_dept[9].dept_code="98000"
    LET f_dept[9].dept_name="屏東行政中心"
    LET f_dept[10].dept_code="9A000"
    LET f_dept[10].dept_name="彰化行政中心"
    LET f_dept[11].dept_code="9B000"
    LET f_dept[11].dept_name="中正分公司"
    
    LET f_rcode=0
    LET f_x=10
    LET f_y=31

    OPEN WINDOW w_psc00m06 AT f_x, f_y WITH FORM "psc00m06"
         ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                   , PROMPT LINE LAST )

    CALL SET_COUNT(11)
    LET f_dept_code=""
    LET f_dept_name=""
    LET INT_FLAG=FALSE

    DISPLAY ARRAY f_dept TO psc00m06.* ATTRIBUTE (BLUE ,REVERSE)

    IF (INT_FLAG = FALSE) THEN
        LET f_i    = ARR_CURR()
        LET f_dept_code         =f_dept[f_i].dept_code
        LET f_dept_name         =f_dept[f_i].dept_name
    ELSE
        LET f_rcode=2
        LET INT_FLAG = FALSE
        LET f_dept_code=""
        LET f_dept_name=""
    END IF

    CLOSE WINDOW w_psc00m06

    RETURN f_rcode,f_dept_code,f_dept_name

END FUNCTION -- psc01m_dept_code --

------------------------------------------------------------------------------
--  函式名稱: notice_print
--  作    者: kobe
--  日    期: 092/01/22
--  處理概要: 照會單列印
--  重要函式:
------------------------------------------------------------------------------
FUNCTION notice_print()

    DEFINE f_rpt_name		CHAR(30)
	  ,f_rpt_code		CHAR(20)
	  ,f_rpt_cmd		CHAR(1024)

    DEFINE f_copies		INTEGER
    DEFINE f_rcode		INTEGER

    LET f_rcode = 0

    IF p_cp_notice_sub_code = "1" THEN
       LET f_rpt_code = "psc00m01"
    ELSE
       IF p_cp_notice_sub_code = "2" THEN
	  LET f_rpt_code = "psc00m02"
       END IF
    END IF

    LET ans = '1'
    IF p_cp_notice_sub_code = "1" THEN
    PROMPT " 請選擇列印方式 : 0.IDMS 列印  1:線上列印  ", p_bell
    ATTRIBUTE (YELLOW)
    FOR CHAR ans
    IF ans NOT MATCHES "[0]" THEN
       LET ans = '1'
    END IF
    IF ans IS NULL OR ans = ' ' THEN
       LET ans = '1'
    END IF
    END IF

    IF ans = '0' and p_cp_notice_sub_code = "1" THEN   -- 送至 PSM 平台
       CALL PSManagerName(f_rpt_code) RETURNING f_rpt_name
    ELSE                     -- Local
       CALL ReportName(f_rpt_code) RETURNING f_rpt_name
    END IF

    IF p_cp_notice_sub_code = "1" THEN
       IF p_pt_sw = '1' THEN
       START REPORT print_notice_pt TO f_rpt_name
       CALL psc_pt_notice(p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code,"O")
	    RETURNING f_rcode
       FINISH REPORT print_notice_pt
       ELSE
       START REPORT print_notice TO f_rpt_name
CALL psc_print_notice(p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code,"O",ans,p_po_chg_rece_no)
	    RETURNING f_rcode
       FINISH REPORT print_notice
       END IF
    ELSE
       IF p_cp_notice_sub_code = "2" THEN
          IF p_pt_sw = '1' THEN
          START REPORT print_insure_pt TO f_rpt_name
	  CALL psc_ptins_notice(p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code)
	       RETURNING f_rcode
          FINISH REPORT print_insure_pt
          ELSE
          START REPORT print_insure TO f_rpt_name
	  CALL psc_insure_notice(p_policy_no,p_cp_anniv_date,p_cp_notice_sub_code)
	       RETURNING f_rcode
          FINISH REPORT print_insure
          END IF
       END IF
    END IF


    IF f_rcode =0 THEN
       IF ans = '0' and p_cp_notice_sub_code = "1" THEN   --  PSM
          LET f_rpt_cmd = "psmanager ",f_rpt_name  -- PSM
          RUN f_rpt_cmd
          ERROR "照會單列印完成 !!"
             SLEEP 1
       ELSE                     -- Local 列印
          LET f_copies=SelectPrinter (f_rpt_name)
          IF (f_copies ) THEN
             LET f_rpt_cmd= "locprn -n ",f_copies USING " <<< "
                           ,f_rpt_name CLIPPED
             RUN f_rpt_cmd
             ERROR "照會單列印完成 !!"
             SLEEP 1
          END IF
       END IF
    END IF

    RETURN f_rcode
END FUNCTION

------------------------------------------------------------------------------
--  函式名稱: dummy
--  作    者: jessica Chang
--  日    期: 87/04/08
--  處理概要: 還本查詢作業,功能尚未完整
--  重要函式:
------------------------------------------------------------------------------
FUNCTION dummy()
    ERROR "FUNCTION not yet  implemented."
END FUNCTION
-------------------------------------------------------------------------------
--  函式名稱:
--  處理概要:
--  輸入參數: (no)
--  輸出參數: TRUE -> o.k.    FALSE -> give up
-------------------------------------------------------------------------------
FUNCTION display_rece_no()
DEFINE f_rw     SMALLINT

   OPEN WINDOW psc00m10 AT 12,21 WITH FORM "psc00m10"
--   WHILE TRUE

     CALL SET_COUNT( p_po_chg_cnt )
     DISPLAY ARRAY p_po_chg TO s_psc00m10.*
         LET f_rw =  ARR_CURR()
--     END DISPLAY
--   END WHILE

   CLOSE WINDOW psc00m10

--display p_po_chg[f_rw].po_chg_rece_no
--call touch()

   RETURN f_rw
END FUNCTION
-------------------------------------------------------------------------------
--  函式名稱:rece_no_show()
--  處理概要:輸出受理編號選單
--  輸入參數: (no)
--  輸出參數: (no)
-------------------------------------------------------------------------------
FUNCTION rece_no_show()
    DEFINE rece_no_arr_curr INTEGER
    DEFINE f_po_chg_rece_no   LIKE apdt.po_chg_rece_no 
    DEFINE f_po_chg_rece_date LIKE apdt.po_chg_rece_date
    DEFINE f_po_chg_sts_code LIKE aplg.po_chg_sts_code
    DEFINE f_cnt  INTEGER
    LET f_cnt = 100
    SELECT COUNT(*)
      INTO f_cnt 
      FROM apdt ,apit  
     WHERE apdt.policy_no = p_policy_no
       AND apdt.po_chg_rece_no = apit.po_chg_rece_no
       AND apit.po_chg_code = '89'
       AND apdt.po_chg_sts_code IN ('2','4','A')    
    IF f_cnt = 0 THEN 
       INITIALIZE  p_po_chg_rece_no TO NULL
       LET p_po_chg_rece_no = ""
       ERROR "該保單號碼查無狀態(2,4,A)下之受理號碼，請查核!" ATTRIBUTE(RED ,REVERSE)
       RETURN 
    END IF 
    LET f_cnt = 1
    INITIALIZE p_po_chg[1].* TO NULL

    DECLARE p_key_apdt CURSOR FOR
        SELECT a.po_chg_rece_no,a.po_chg_rece_date,a.po_chg_sts_code
          FROM apdt a,apit b
         WHERE a.policy_no = p_policy_no
           AND a.po_chg_rece_no = b.po_chg_rece_no
           AND b.po_chg_code = '89'
           AND a.po_chg_sts_code IN ("2","4","A")
         ORDER BY a.po_chg_rece_no DESC
    FOREACH p_key_apdt INTO f_po_chg_rece_no,f_po_chg_rece_date,f_po_chg_sts_code 
         LET p_po_chg[f_cnt].po_chg_rece_no = f_po_chg_rece_no
         LET p_po_chg[f_cnt].po_chg_rece_date = f_po_chg_rece_date 
         LET p_po_chg[f_cnt].po_chg_sts_code = f_po_chg_sts_code
         LET f_cnt = f_cnt + 1
    END FOREACH
    LET f_cnt = f_cnt - 1
    IF f_cnt > 20 THEN 
       DISPLAY "受理編號超過二十筆，請洽資訊部" AT 24,1 ATTRIBUTE (RED ,REVERSE)
       RETURN
    END IF
    
        
    OPEN    WINDOW w_psc00m13 AT 7,19 WITH FORM "pa502s01" ATTRIBUTE( CYAN )
     CALL    SET_COUNT( f_cnt  )
     DISPLAY ARRAY p_po_chg TO sc_pa502s01.*
          ON KEY( INTERRUPT )
             EXIT DISPLAY
          ON KEY( ESC, ACCEPT ,RETURN )
             LET rece_no_arr_curr     = ARR_CURR()
             LET p_po_chg_rece_no = p_po_chg[ rece_no_arr_curr ].po_chg_rece_no
             EXIT DISPLAY
     END     DISPLAY
     CLOSE   WINDOW w_psc00m13
     
    RETURN
END FUNCTION 
-------------------------------------------------------------------------------
--  函式名稱:cmd_run()
--  處理概要:連結至指定程式
--  輸入參數: cmd
--  輸出參數: (no)
-------------------------------------------------------------------------------
FUNCTION cmd_run(cmd)
    DEFINE cmd  CHAR(100)
    LET cmd = cmd CLIPPED
    RUN cmd 
END FUNCTION

-------------------------------------------------------------------------------
--  函式名稱:ins_pscw()
--  處理概要:塞入pscw以便執行online過帳
--  輸入參數: 
--  輸出參數:
-------------------------------------------------------------------------------
FUNCTION ins_pscw()
    DEFINE f_pscw_cnt  SMALLINT
    LET f_pscw_cnt = 0
    SELECT count(*)
      INTO f_pscw_cnt 
      FROM pscw
     WHERE policy_no = p_data_s1.policy_no
       AND cp_anniv_date = p_data_s1.cp_anniv_date
display 'pscw cnt=',f_pscw_cnt
    IF f_pscw_cnt > 0 THEN
       DELETE FROM pscw
        WHERE policy_no = p_data_s1.policy_no
          AND cp_anniv_date = p_data_s1.cp_anniv_date
    END IF
display 'insert pscw'
    INSERT INTO pscw VALUES
                          (p_data_s1.policy_no,
                           p_data_s1.cp_anniv_date,
                           '1',
                           ' ',
                           '0',
                           '')
    IF SQLCA.SQLCODE != 0 THEN
       RETURN 0
    END IF
    RETURN 1
END FUNCTION  
    
-------------------------------------------------------------------------------
--  函式名稱:disp_addr()
--  處理概要:參考psg01m22顯示addr
--  輸入參數: client_id
--  輸出參數: addr_ind
-------------------------------------------------------------------------------
FUNCTION disp_addr(f_client_id)
    DEFINE f_client_id CHAR(10)
    DEFINE f_addr    RECORD LIKE addr.*    
    DEFINE
        p_edit_rsdr_show  ARRAY[30] OF RECORD
        function_ind          LIKE rsdr.function_ind     , --
        addr_ind              LIKE rsdr.addr_ind         , --
        address               LIKE rsdr.address          , --
        zip_code              LIKE rsdr.zip_code         , --
        tel_1                 LIKE rsdr.tel_1            , --
        tel_2                 LIKE rsdr.tel_2            , --
        fax                   LIKE rsdr.fax                --
    END RECORD

    DEFINE
        i                         SMALLINT                   , --
        idx                       SMALLINT                   , --
        f_arr_curr                SMALLINT                   , --
        f_addr_ind                CHAR                         --

    INITIALIZE p_edit_rsdr_show TO NULL
    LET idx = 1
    DECLARE p_key_addr CURSOR FOR
        SELECT *
          FROM addr
         WHERE client_id = f_client_id
         ORDER BY addr_ind
    FOREACH p_key_addr INTO f_addr.*
        LET p_edit_rsdr_show[idx].addr_ind = f_addr.addr_ind
        LET p_edit_rsdr_show[idx].address  = f_addr.address
        LET p_edit_rsdr_show[idx].zip_code = f_addr.zip_code
        LET p_edit_rsdr_show[idx].tel_1    = f_addr.tel_1
        LET p_edit_rsdr_show[idx].tel_2    = f_addr.tel_2
        LET p_edit_rsdr_show[idx].fax      = f_addr.fax
        LET idx = idx + 1
    END FOREACH
    OPTIONS FORM LINE FIRST

    OPEN WINDOW psg01m22 AT 5, 1 WITH FORM "psg01m22" ATTRIBUTE( CYAN )

    CALL SET_COUNT( idx - 1 )

    DISPLAY ARRAY p_edit_rsdr_show TO s_g01m220.* ATTRIBUTE( CYAN )

        ON KEY ( INTERRUPT )
            EXIT DISPLAY

        ON KEY ( RETURN, ACCEPT ,ESC)
            LET f_arr_curr = ARR_CURR()
            LET f_addr_ind = p_edit_rsdr_show[f_arr_curr].addr_ind
            EXIT DISPLAY
    END DISPLAY

    CLOSE WINDOW psg01m22

    OPTIONS FORM LINE FIRST + 2
    RETURN f_addr_ind 

END FUNCTION        ----- get_app_addr_ind -----
 
-------------------------------------------------------------------------------
--  函式名稱:ins_psc3()
--  處理概要:將地址留存至psc3
--  輸入參數: client_id
--  輸出參數: 
-------------------------------------------------------------------------------
FUNCTION ins_psc3()
    DEFINE f_psc3  RECORD LIKE psc3.*
    DEFINE f_address LIKE addr.address   
    DEFINE f_ans_sw  CHAR(1) 
    DEFINE f_zip_code LIKE psc3.zip_code
    DEFINE f_err INTEGER
    SELECT *
      INTO f_psc3.*
      FROM psc3
     WHERE policy_no = p_data_s1.policy_no
       AND cp_anniv_date = p_data_s1.cp_anniv_date
       AND addr_ind = 'Q'  
    IF STATUS = NOTFOUND THEN
       LET f_address = '' 
       LET f_zip_code = ''
    ELSE
       LET f_address = f_psc3.address
       LET f_zip_code = f_psc3.zip_code
       DELETE FROM psc3
       WHERE policy_no = p_data_s1.policy_no
         AND cp_anniv_date = p_data_s1.cp_anniv_date
         AND addr_ind = 'Q'
    END IF

    OPTIONS FORM LINE FIRST

    OPEN WINDOW psc00m13 AT 11,1 WITH FORM "psc00m13" 
       ATTRIBUTE ( BLUE, REVERSE, UNDERLINE, FORM LINE FIRST
                   , PROMPT LINE LAST )

--102/01/10 cmwang modify 
{ 
    INPUT p_data_s1.policy_no,p_data_s1.cp_anniv_date,f_zip_code
          ,f_address without defaults FROM psc00m13.*
}
    INPUT p_data_s1.policy_no,p_data_s1.cp_anniv_date
          ,f_address without defaults FROM psc00m13.*
    
    AFTER FIELD address
      CALL get_zip_code(f_address,length(f_address))
           RETURNING f_err,f_zip_code
      IF f_zip_code IS NULL THEN
         LET f_zip_code = " "
      END IF
      DISPLAY f_zip_code TO psc00m_zip.* ATTRIBUTE (BLUE,REVERSE,UNDERLINE)

    AFTER INPUT
        PROMPT "  確認存檔請按 Y" FOR CHAR f_ans_sw
        IF UPSHIFT(f_ans_sw) !="Y" OR
           f_ans_sw IS NULL        THEN
           NEXT FIELD address
        ELSE
           INSERT INTO psc3 VALUES (
                                    p_data_s1.policy_no,
                                    p_data_s1.cp_anniv_date,
                                    p_applicant_id,
                                    'Q',
                                    f_zip_code,
                                    f_address,
                                    p_tran_date,
                                    g_user)
                                      
                                    
        END IF

        
        ON KEY ( INTERRUPT )
            EXIT INPUT

    END INPUT

    CLOSE WINDOW psc00m13

    OPTIONS FORM LINE FIRST + 2
END FUNCTION

FUNCTION nonresp_sw_add()
  DEFINE f_psck_cnt	           SMALLINT
  DEFINE f_psck    RECORD LIKE psck.* 
  DEFINE f_rcode INTEGER

  LET f_rcode = 0

  SELECT   COUNT(*)
    INTO    f_psck_cnt 
    FROM    psck
    WHERE   policy_no = p_data_s1.policy_no 
     AND    cp_anniv_date = p_data_s1.cp_anniv_date 
      
  IF f_psck_cnt = 0 THEN 
     LET f_psck.policy_no = p_data_s1.policy_no 
     LET f_psck.cp_anniv_date = p_data_s1.cp_anniv_date
     LET f_psck.cp_remark_desc_1 = " "
     LET f_psck.cp_remark_desc_2 = " "  
     LET f_psck.cp_remark_desc_3 = " "
     LET f_psck.cp_remark_desc_4 = " "
     LET f_psck.cp_remark_desc_5 = " "
     LET f_psck.nonresp_sw = "Y"
     LET f_psck.process_date = GetDate(Today)
     LET f_psck.process_time = TIME 
     LET f_psck.process_user = g_user
     INSERT INTO psck VALUES(f_psck.*)
     IF SQLCA.SQLCODE != 0 THEN
        ROLLBACK WORK
        LET f_rcode=1
        RETURN f_rcode
     END IF
  ELSE
     UPDATE psck
     SET nonresp_sw = "Y"
     WHERE policy_no = p_data_s1.policy_no
     AND   cp_anniv_date = p_data_s1.cp_anniv_date
     IF SQLCA.SQLCODE != 0 THEN
        ROLLBACK WORK
        LET f_rcode=1
        RETURN f_rcode
     END IF
  END IF  

  UPDATE pscb 
  SET cp_remark_sw  = "Y"
  WHERE policy_no = p_data_s1.policy_no 
    AND cp_anniv_date = p_data_s1.cp_anniv_date 
  IF SQLCA.SQLCODE != 0 THEN
        ROLLBACK WORK
        LET f_rcode=1
        RETURN f_rcode
  END IF 
   
END FUNCTION 
FUNCTION usd_notify(f_notify_cp_anniv_date)
    DEFINE f_notify_cp_anniv_date LIKE pscb.cp_anniv_date
    DEFINE f_notify_cp_sw         LIKE pscb.cp_sw
    DEFINE f_notify_cp_notice_sw  LIKE pscb.cp_notice_sw
        
    LET f_notify_cp_sw = ''
    LET f_notify_cp_notice_sw = '' 

    DECLARE p_usd_notify CURSOR FOR
        SELECT cp_sw , cp_notice_sw
          FROM pscb 
         WHERE policy_no = g_polf.policy_no
           AND cp_anniv_date != f_notify_cp_anniv_date
         ORDER BY cp_anniv_date
    FOREACH p_usd_notify INTO f_notify_cp_sw,f_notify_cp_notice_sw
        IF f_notify_cp_sw = '7' THEN
           IF f_notify_cp_notice_sw = '1' OR f_notify_cp_notice_sw = '4' OR --"B1照會中"
              f_notify_cp_notice_sw = '0' THEN   --"C1未回覆"
              RETURN 1
           END IF
        END IF
        IF f_notify_cp_sw = '1' OR f_notify_cp_sw = '4' OR
           f_notify_cp_sw = '8' THEN
           IF f_notify_cp_notice_sw = '1' OR f_notify_cp_notice_sw = '4' OR --"B1照會中"
              f_notify_cp_notice_sw = '0' THEN  --"B3通知中"
              RETURN 1
           END IF
        END IF   
    END FOREACH
    RETURN 0
END FUNCTION  

------------------------------------------------------------------------------
-- 函式名稱: chk_benf_data()
-- 需求單號: SR151200331
-- 處理敘述: 檢查受益人資料(受益人中只要id或姓名沒資料就回傳FALSE)
-- 輸入參數: 無
-- 輸出參數: TRUE/FALSE
------------------------------------------------------------------------------
FUNCTION chk_benf_data()
	DEFINE f_benf_arr_cnt     SMALLINT
	DEFINE f_i                SMALLINT
	DEFINE f_client_id_len    SMALLINT
	DEFINE f_client_names_len SMALLINT
	DEFINE f_chk_ind          CHAR(1)
	DEFINE f_id_ind           CHAR(1)
	-- DEFINE f_cmd              CHAR(1200) --測試用
	
	LET f_chk_ind = TRUE
-- let f_cmd = "echo '","test","' >> /tmp/psc00m.log"
-- RUN f_cmd CLIPPED
	
	-- 據瞭解p_benf這個RECORD沒在用
	FOR f_i = 0 TO 99
		LET f_client_id_len    = 0
		LET f_client_names_len = 0
		LET f_client_id_len    = LENGTH( p_data_s2[ f_i ].client_id CLIPPED )
		LET f_client_names_len = LENGTH( p_data_s2[ f_i ].names CLIPPED )
		-- 受益人有ID但沒姓名的狀況
		IF f_client_id_len > 0 AND f_client_names_len = 0 THEN
			-- 受益人有ID但沒姓名且ID為身份證字號則FALSE
			LET f_id_ind = get_id_ind( p_data_s2[ f_i ].client_id )
			IF f_id_ind = "1" THEN
				LET f_chk_ind = FALSE
			END IF
		END IF
		-- 受益人沒ID但有姓名的狀況
		IF f_client_id_len = 0 AND f_client_names_len > 0 THEN
			LET f_chk_ind = FALSE
		END IF
-- let f_cmd = "echo '",p_data_s2[ f_i ].client_id CLIPPED,"' >> /tmp/psc00m.log"
-- RUN f_cmd CLIPPED
-- let f_cmd = "echo '",p_data_s2[ f_i ].names CLIPPED,"' >> /tmp/psc00m.log"
-- RUN f_cmd CLIPPED
	END FOR

	RETURN f_chk_ind
	
END FUNCTION -- chk_benf_data()

------------------------------------------------------------------------------
-- 函式名稱: get_id_ind( f_client_id )
-- 需求單號: SR151200331
-- 處理敘述: 抓取id指示
-- 輸入參數: 無
-- 輸出參數: id_ind[1234569]
------------------------------------------------------------------------------
FUNCTION get_id_ind( f_client_id )
	DEFINE f_client_id LIKE clnt.client_id
	DEFINE f_id_ind    LIKE clnt.id_ind
	
	LET f_id_ind = "X"
	SELECT id_ind
	INTO   f_id_ind
	FROM   clnt
	WHERE  client_id = f_client_id
	
	RETURN f_id_ind
	
END FUNCTION -- get_id_ind