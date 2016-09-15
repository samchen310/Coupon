------------------------------------------------------------------------------
--  µ{¦¡¦WºÙ: psc02m.4gl
--  §@    ªÌ: merlin
--  ¤é    ´Á: 
--  ³B²z·§­n: ÁÙ¥»Âd»O§@·~
--  ­«­n¨ç¦¡:
------------------------------------------------------------------------------
-- ²¼¾Ú¬d¸ß«e¥²¶·¥ý«Å§i g_check_count¡×0 ¤~·|§ä¸ê®Æ
-- 089/09/14:­×§ï¼f¬dªí¦C¦L®æ¦¡»P¤º®e¡A¨ú®ø¸É¦L¥\¯à
------------------------------------------------------------------------------
-- ­×§ïªÌ:JC
--  090/04/25:­×§ï¨ü¯q¤H¦W¦rªº§äªk,¦³id §äclnt,§_«hÅã¥Ü benf ªº names
------------------------------------------------------------------------------
-- ­×§ïªÌ:merlin
-- 090/07/20:¶}©ñ«O³æª¬ºA66¡A67¡A73¥iÂd»O§@·~¤Î¤w»â¨ú³øªí¼W¥[À³»âª÷ÃB
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
          ,p_applicant_id     LIKE clnt.client_id       -- ·~°È­ûID   --
          ,p_applicant_name   LIKE clnt.names           -- ·~°È­û©m¦W --
          ,p_coverage_no      LIKE colf.coverage_no     -- ÀIºØª©¥»   --
          ,p_benf_cnt         INTEGER                   -- ¨ü¯q¤H¼Æ   -- 
          ,p_cp_sw            CHAR(1)                   -- ÁÙ¥»«ü¥Ü   -- 
          ,p_check_date       CHAR(9)

 
    -- µe­±¤@¤W¥b³¡ªº¸ê®Æ --
    DEFINE p_data_s1 RECORD -- screen s1 -- 
           policy_no         LIKE pscb.policy_no       -- «O³æ¸¹½X   --
          ,cp_anniv_date     LIKE pscp.cp_anniv_date   -- ¶g¦~¤é     --
          ,expired_sw        CHAR                      -- º¡´Á/¥Í¦s  --
          ,cp_remark_sw      LIKE pscb.cp_remark_sw    -- µù°O«ü¥Ü   --  
          ,cp_pay_name       LIKE pscb.cp_pay_name     -- À³»â¤H©m¦W --
          ,cp_pay_id         LIKE pscb.cp_pay_id       -- À³»âID     --
          ,dept_code         LIKE pscb.dept_code       -- »â¨ú¤À¤½¥q --
                 END RECORD

    -- µe­±¤@²Ä¤G³¡¥÷¸ê®Æ --
    DEFINE p_data_s3 RECORD
           po_issue_date     LIKE polf.po_issue_date   -- ¥Í®Ä¤é     --
          ,paid_to_date      LIKE polf.paid_to_date    -- Ãº¶O²×¤é   --
          ,po_sts_code       LIKE polf.po_sts_code     -- «O³æª¬ºA   --
          ,app_name          CHAR(12)                  -- ­n«O¤H     --
          ,insured_name      CHAR(12)                  -- ³Q«O¤H     --
          ,method            LIKE polf.method          -- ¦¬¶O¤è¦¡   --
          ,dept_name         LIKE dept.dept_name       -- Àç·~³æ¦ì   --
          ,agent_name        LIKE clnt.names           -- ·~°È­û     --
          ,chk_date          CHAR(9)                   -- ¥¼§I¤ä²¼   --
                 END RECORD

    -- µe­±¤@²Ä¤T³¡¤À¸ê®Æ --
    DEFINE p_data_s2 ARRAY[99] OF RECORD               -- ¨ü¯q¤H±¡§Î --
           names               LIKE benf.names         -- ¨ü¯q¤H©m¦W --
          ,benf_ratio          LIKE benf.benf_ratio    -- ¨ü¯q¤ñ¨Ò   --
          ,remit_account       LIKE benf.remit_account -- ¶×´Ú±b¸¹   --
          ,benf_order          LIKE benf.benf_order    -- ¶×´Ú»È¦æ   --
                 END RECORD
 

    DEFINE p_pscb              RECORD LIKE pscb.*  
    DEFINE p_pscp              RECORD LIKE pscp.*

    -- ¼f¬d³æ¤º®e --    
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

-- ¥Dµ{¦¡ --
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

    -- Åã¥Ü²Ä¤@µe­± --
    OPEN FORM psc02m01 FROM "psc02m01"
    DISPLAY FORM psc02m01 ATTRIBUTE (GREEN)

    CALL ShowLogo()
    -- JOB  CONTROL beg --
    CALL GetDocLname( '2') RETURNING p_name
    CALL JobControl()

    MENU "½Ð¿ï¾Ü"
       BEFORE MENU
            IF  NOT CheckAuthority("1", FALSE)  THEN
                HIDE OPTION "1)»â¨ú"
            END IF
            IF  NOT CheckAuthority("2", FALSE)  THEN
                HIDE OPTION "2)ÁÙ¥»¬d¸ß"
            END IF
            IF  NOT CheckAuthority("3", FALSE)  THEN
                HIDE OPTION "3)²z½ß¬d¸ß"
            END IF
            IF  NOT CheckAuthority("4", FALSE)  THEN
                HIDE OPTION "4)²¼¾Ú¬d¸ß"
            END IF
            IF  NOT CheckAuthority("5", FALSE)  THEN
                HIDE OPTION "5)µù°O¬d¸ß"
            END IF
{
            IF  NOT CheckAuthority("6", FALSE)  THEN
                HIDE OPTION "6)¸É¦L¼f¬dªí"
            END IF
}
            IF  NOT CheckAuthority("7", FALSE)  THEN
                HIDE OPTION "7)¦C¦LÂd»O¤w»â¨ú³øªí"
            END IF
        COMMAND "1)»â¨ú"
                 CALL psc02m_pay()

        COMMAND "2)ÁÙ¥»¬d¸ß"
                 RUN "psc01i.4ge"

        COMMAND "3)²z½ß¬d¸ß"
                 CALL psc02m_init()
                 CALL qry_input() RETURNING p_pass_or_deny
                   IF p_pass_or_deny=0 THEN
                      CALL qryClaim(p_data_s1.policy_no,2,2)
                   END IF 

        COMMAND "4)²¼¾Ú¬d¸ß"
                 CALL psc02m_init()
                 CALL qry_input() RETURNING p_pass_or_deny
                   IF p_pass_or_deny=0 THEN
                      LET g_check_count=0 
                      CALL qryCheck()   RETURNING p_check_date
                   END IF       

        COMMAND "5)µù°O¬d¸ß"
                 CALL psc02m_init()
                 CALL psc02m_input() RETURNING p_pass_or_deny
                   IF p_pass_or_deny=0 THEN
                      CALL pscninq(p_data_s1.policy_no,p_data_s1.cp_anniv_date)
                      RETURNING p_pass_or_deny
                   END IF
{
        COMMAND "6)¸É¦L¼f¬dªí" 
                 CALL psc02m_print("6") 
}
        COMMAND "7)¦C¦LÂd»O¤w»â¨ú³øªí"
                 CALL psc02m_print("7")

        COMMAND "0)µ²§ô"
                 EXIT MENU
        END MENU 
 
    CLOSE FORM psc02m01

    -- JOB  CONTROL beg --
    CALL JobControl()

END MAIN -- ¥Dµ{¦¡µ²§ô --

------------------------------------------------------------------------------
--  ¨ç¦¡¦WºÙ: psc02m_pay
--  §@    ªÌ: merlin
--  ¤é    ´Á: 
--  ³B²z·§­n: ÁÙ¥»Âd»O§@·~_»â¨ú§@·~
--  ­«­n¨ç¦¡:
------------------------------------------------------------------------------          
FUNCTION psc02m_pay()
    DEFINE f_rcode      INTEGER    
    DEFINE f_pscb_cnt   INTEGER 
    DEFINE f_cp_sw      LIKE pscb.cp_sw
        
     CALL psc02m_init()
     CALL psc02m_input() RETURNING f_rcode

     --§PÂ_«O³æ¬O§_¤wÁÙ¥»--     
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
          ERROR "½Ð¥ÑÁÙ¥»¬d¸ß¥\¯à¬d¸ß¬ÛÃö¸ê®Æ¡I" 
          ATTRIBUTE(RED,UNDERLINE)
       ELSE
          CALL psc02m_display()
          CALL psc02m_check() RETURNING f_rcode 
       END IF
       CALL Fatca_message()
     END IF     
END FUNCTION    ---  psc02m_pay ---

------------------------------------------------------------------------------
--  ¨ç¦¡¦WºÙ: psc02m_print()
--  §@    ªÌ: merlin
--  ¤é    ´Á: 
--  ³B²z·§­n: ÁÙ¥»Âd»O§@·~_¦C¦L§@·~
--  ­«­n¨ç¦¡:
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
                   ERROR "«O³æ¤wÁÙ¥»¡A½Ð¥ÑÁÙ¥»¬d¸ß¥\¯à¬d¸ß¬ÛÃö¸ê®Æ¡I" 
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
                      ERROR "¦C¦L§@·~¦³»~¡I¡I"
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
                           ERROR "¦C¦L§@·~¦³»~¡I¡I"
                       END IF
                 END IF
        END CASE
END FUNCTION      --- psc02m_print ---
------------------------------------------------------------------------------
--  ¨ç¦¡¦WºÙ: psc02m_init
--  §@    ªÌ: merlin
--  ¤é    ´Á: 
--  ³B²z·§­n: ÁÙ¥»Âd»O§@·~_µe­±ªì­È
--  ­«­n¨ç¦¡:
------------------------------------------------------------------------------

FUNCTION psc02m_init()
    DEFINE f_i           SMALLINT -- array index ---

    LET   p_policy_no     =" "
    LET   p_applicant_id  =" "
    LET   p_applicant_name=" "
    LET   p_coverage_no   =1

    -- µe­±¤@¸ê®Æ --
    LET   p_data_s1.policy_no              =" "       -- «O³æ¸¹½X   --
    LET   p_data_s1.cp_anniv_date          =" "       -- ÁÙ¥»¶g¦~¤é --
    LET   p_data_s1.expired_sw             =" "       -- º¡´Á/¥Í¦s  --
    LET   p_data_s1.cp_remark_sw           =" "       -- µù°O«ü¥Ü   --
    LET   p_data_s1.cp_pay_name            =" "       -- À³»â¤H©m¦W --
    LET   p_data_s1.cp_pay_id              =" "       -- À³»â¤HID   --
    LET   p_data_s1.dept_code              =" "       -- »â¨ú¤À¤½¥q --                          

    -- µe­±¤G¸ê®Æ --
    LET   p_data_s3.po_issue_date          =" "       -- ¥Í®Ä¤é     --
    LET   p_data_s3.paid_to_date           =" "       -- Ãº¶O²×¤é   --
    LET   p_data_s3.po_sts_code            =" "       -- «O³æª¬ºA   --
    LET   p_data_s3.app_name               =" "       -- ­n«O¤H     --
    LET   p_data_s3.insured_name           =" "       -- ³Q«O¤H     --
    LET   p_data_s3.method                 =" "       -- ¦¬¶O¤è¦¡   --
    LET   p_data_s3.dept_name              =" "       -- Àç·~³æ¦ì   --
    LET   p_data_s3.agent_name             =" "       -- ·~°È­û     --
    LET   p_data_s3.chk_date               =" "       -- ¥¼§I¤ä²¼   --

    -- µe­±¤T detail ¸ê®Æ --
    FOR f_i=1 TO 4
       LET   p_data_s2[f_i].names          =" "       -- ©m¦W/¦WºÙ  --
       LET   p_data_s2[f_i].benf_ratio     = 0        -- ¨ü¯q¤ñ¨Ò   --
       LET   p_data_s2[f_i].remit_account  =" "       -- ¶×´Ú±b¸¹   --
       LET   p_data_s2[f_i].benf_order     =" "       -- ¨ü¯q¶¶¦ì   --
    END FOR
    CLEAR FORM
END FUNCTION   -- psc02m_init --
------------------------------------------------------------------------------
--  ¨ç¦¡¦WºÙ: psc02m_input
--  §@    ªÌ: merlin
--  ¤é    ´Á: 
--  ³B²z·§­n: ÁÙ¥»Âd»O§@·~_µe­±¿é¤J¡]»â¨ú¡Aµù°O¬d¸ß¡A³øªí¦C¦L¡^
--  ­«­n¨ç¦¡:
------------------------------------------------------------------------------
FUNCTION psc02m_input()
    DEFINE f_right_or_fault     INTEGER   -- ¤é´ÁÀË¬d t or f --
          ,f_formated_date      CHAR(9)   -- ¤é´Á®æ¦¡¤Æ 999/99/99 --
          ,f_pscb_cnt           INTEGER   -- °õ¦æ perpare «ü¥O¦³«O³æ¥i°õ¦æ --
          ,f_rcode              INTEGER

    LET f_rcode       =FALSE            
    LET INT_FLAG      =FALSE
    LET f_pscb_cnt    =0

    MESSAGE " END(F7):¨ú®ø§@·~"

    INPUT p_data_s1.policy_no,p_data_s1.cp_anniv_date
    FROM  policy_no,cp_anniv_date
    ATTRIBUTE(BLUE ,REVERSE ,UNDERLINE)
  
    AFTER FIELD policy_no
        IF p_data_s1.policy_no=" "            OR
           p_data_s1.policy_no="            " THEN
           ERROR "«O³æ¸¹½X¥²¶·¿é¤J!!"    ATTRIBUTE (RED)
           NEXT FIELD policy_no
        END IF
       -- ¸ê®ÆÀË¬d --
       -- g_polf.ªº¸ê®Æ --
       SELECT *
       INTO   g_polf.*
       FROM   polf
       WHERE  policy_no=p_data_s1.policy_no

       IF STATUS=NOTFOUND THEN
          ERROR "µL¦¹±i«O³æ!!" ATTRIBUTE (RED)
          NEXT FIELD policy_no
       END IF

    AFTER FIELD cp_anniv_date
        CALL CheckDate(p_data_s1.cp_anniv_date)
             RETURNING f_right_or_fault,f_formated_date

        IF f_right_or_fault = false THEN
           ERROR "¶g¦~¤é¿é¤J¿ù»~!!" ATTRIBUTE (RED)
           NEXT FIELD cp_anniv_date
        END IF

        IF p_data_s1.cp_anniv_date="         " OR
           p_data_s1.cp_anniv_date=" "         THEN
           ERROR "¶g¦~¤é¥²¶·¿é¤J!!"  ATTRIBUTE (RED)
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

    -- ¤¤Â_§@·~ --
    IF INT_FLAG=TRUE THEN
       LET f_rcode=TRUE 
       RETURN f_rcode
    END IF
    RETURN f_rcode
   
END FUNCTION    --- psc02m_input ---
------------------------------------------------------------------------------
--  ¨ç¦¡¦WºÙ: qry_input
--  §@    ªÌ: merlin
--  ¤é    ´Á: 
--  ³B²z·§­n: ÁÙ¥»Âd»O§@·~_µe­±¿é¤J¡]²z½ß¡A²¼¾Ú¬d¸ß¡^
--  ­«­n¨ç¦¡:
------------------------------------------------------------------------------
FUNCTION qry_input()
    DEFINE f_right_or_fault     INTEGER   -- ¤é´ÁÀË¬d t or f --
          ,f_formated_date      CHAR(9)   -- ¤é´Á®æ¦¡¤Æ 999/99/99 --
          ,f_pscb_cnt           INTEGER   -- °õ¦æ perpare «ü¥O¦³«O³æ¥i°õ¦æ --
          ,f_rcode              INTEGER

    LET f_rcode       =FALSE            
    LET INT_FLAG      =FALSE
    LET f_pscb_cnt    =0

    MESSAGE " END(F7):¨ú®ø§@·~"

    INPUT p_data_s1.policy_no
    FROM  policy_no
    ATTRIBUTE(BLUE ,REVERSE ,UNDERLINE)

    AFTER FIELD policy_no
        IF p_data_s1.policy_no=" "            OR
           p_data_s1.policy_no="            " THEN
           ERROR "«O³æ¸¹½X¥²¶·¿é¤J!!"    ATTRIBUTE (RED)
           NEXT FIELD policy_no
        END IF

    ON KEY (F7)
       LET INT_FLAG=TRUE
       EXIT INPUT
    AFTER INPUT

       IF INT_FLAG=TRUE THEN
          EXIT INPUT
       END IF

       -- ¸ê®ÆÀË¬d --
       -- g_polf.ªº¸ê®Æ --
       SELECT *
       INTO   g_polf.*
       FROM   polf
       WHERE  policy_no=p_data_s1.policy_no

       IF STATUS=NOTFOUND THEN
          ERROR "µL¦¹±i«O³æ!!"   ATTRIBUTE (RED)
          NEXT FIELD policy_no
       END IF

    END INPUT
       MESSAGE " "      

    -- ¤¤Â_§@·~ --
    IF INT_FLAG=TRUE THEN
       LET f_rcode=TRUE 
       RETURN f_rcode
    END IF
     RETURN f_rcode
   
END FUNCTION    --- qry_input ---

------------------------------------------------------------------------------
--  ¨ç¦¡¦WºÙ: psc02m_display
--  §@    ªÌ: merlin
--  ¤é    ´Á: 
--  ³B²z·§­n: ÁÙ¥»Âd»O§@·~_µe­±Åã¥Ü
--  ­«­n¨ç¦¡:
------------------------------------------------------------------------------
FUNCTION psc02m_display()
    
    DEFINE f_i                  INTEGER                 -- array ­p¼Æ¾¹ 
          ,f_benf_cnt           INTEGER                 -- ¨ü¯q¤H­p¼Æ¾¹ 
          ,f_arr_cur            INTEGER                 -- ¨ü¯q¤H¿é¤Jªº­p¼Æ 
          ,f_scr_cur            INTEGER                 -- ¨ü¯q¤Hµe­±ªº­p¼Æ 
          ,f_disb_err           INTEGER                 -- ¨ü¯q¤H»È¦æ±b¸¹¦³¿ù 

    DEFINE f_cp_anniv_date      LIKE pscb.cp_anniv_date      -- ¶g¦~¤é   
          ,f_cp_sw              LIKE pscb.cp_sw              -- ÁÙ¥»«ü¥Ü 
          ,f_expired_sw         CHAR
          ,f_cp_remark_sw       LIKE pscb.cp_remark_sw       -- µù°O«ü¥Ü 
          ,f_cp_pay_name        LIKE pscb.cp_pay_name        -- À³»â¤H©m¦W 
          ,f_cp_pay_id          LIKE pscb.cp_pay_id          -- À³»â¤HID 
          ,f_pay_dept_code      LIKE pscb.dept_code          -- »â¨ú¤À¤½¥q 

    DEFINE f_cp_notice_formtype LIKE pscr.cp_notice_formtype -- ³qª¾®Ñ®æ¦¡
          ,f_chk_sw             LIKE pscr.cp_chk_sw          -- ¤ä²¼¥¼§I²{«ü¥Ü
          ,f_chk_date           LIKE pscr.cp_chk_date        -- ¥¼§I²{¤ä²¼MAX¤é

    DEFINE f_arr                INTEGER
          ,f_dtl_real_amt       INTEGER
          ,f_dtl_cp_ann         LIKE pscb.cp_anniv_date
          ,f_client_ident       LIKE colf.client_ident       -- Ãö«Y¤HÃÑ§O½X
          ,f_applicant_id       LIKE clnt.client_id          -- ­n«O¤HÃÒ¸¹
          ,f_insured_id         LIKE clnt.client_id          -- ³Q«OÀI¤HÃÒ¸¹
          ,f_app_name           LIKE clnt.names              -- ­n«O¤H©m¦W
          ,f_insured_name       LIKE clnt.names              -- ³Q«OÀI¤H©m¦W
          ,f_agent_code         LIKE agnt.agent_code         -- ·~°È­û¥N½X
          ,f_dept_code          LIKE dept.dept_code          -- ³¡ªù¥N½X
          ,f_relation           CHAR(1)
          ,f_benf_client_id     CHAR(10)

    MESSAGE "END(F7):¨ú®ø§@·~"

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

     -- §PÂ_º¡´Á/¥Í¦s¨ü¯q¤H
        IF p_data_s1.cp_anniv_date >= g_polf.expired_date THEN
           LET f_expired_sw = "Y"
           LET f_relation   = "M"
        ELSE
           LET f_expired_sw = "N"
           LET f_relation   = "L"
        END IF

     -- µe­±¤@ªº²Ä¤G³¡¸ê®Æ --
        LET  p_data_s3.po_sts_code    = g_polf.po_sts_code
        LET  p_data_s3.method         = g_polf.method
        LET  p_data_s3.po_issue_date  = g_polf.po_issue_date
        LET  p_data_s3.paid_to_date   = g_polf.paid_to_date

     -- ·~°È­û,»PÀç·~³æ¦ì --
        SELECT agent_code
        INTO   f_agent_code
        FROM   poag
        WHERE  policy_no=p_data_s1.policy_no
        AND    relation ="S"

        SELECT dept_code
        INTO   f_dept_code
        FROM   agnt
        WHERE  agent_code=f_agent_code  

     -- ­n«O¤HID,©m¦W --
        CALL getNames(p_data_s1.policy_no,'O1')
             RETURNING p_applicant_id,p_applicant_name

     -- ¥¼§I²{¤ä²¼¤é´Á --       
        SELECT cp_chk_date,coverage_no
        INTO   f_chk_date,p_coverage_no
        FROM   pscp
        WHERE  policy_no=p_policy_no
        AND    cp_anniv_date=p_data_s1.cp_anniv_date
        
     -- ³Q«O¤HID,©m¦W --
        SELECT client_ident
        INTO   f_client_ident
        FROM   colf
        WHERE  policy_no=p_policy_no
        AND    coverage_no=p_coverage_no

     -- ³Q«OÀI¤H©m¦W --
        SELECT client_id
        INTO   f_insured_id
        FROM   pocl
        WHERE  policy_no=p_policy_no
        AND    client_ident=f_client_ident

        SELECT names
        INTO   f_insured_name
        FROM   clnt
        WHERE  client_id=f_insured_id

     -- ·~°È­û©m¦W¡AÀç·~³æ¦ì --
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
        
    -- µe­±¤@ªº²Ä¤G³¡¸ê®Æ --
    -- ­n§PÂ_º¡´Á©Î¥Í¦s º¡´Á relation="M" ,¥Í¦s relation="L" 
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

    -- Åã¥Ü¨ú±oªº¸ê®Æ(µe­±¤@²Ä¤T³¡¥÷) --
       DISPLAY BY NAME p_data_s3.*  ATTRIBUTE (YELLOW)

    -- Åã¥Ü¨ú±oªº¸ê®Æ(µe­±¤@²Ä¤G³¡¥÷) --
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

    -- Åã¥Ü¨ú±oªº¸ê®Æ(µe­±¤@²Ä¤@³¡¥÷) --
    
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
--  ¨ç¦¡¦WºÙ: psc02m_check()
--  §@    ªÌ: merlin
--  ¤é    ´Á: 
--  ³B²z·§­n: ÁÙ¥»Âd»O§@·~_»â¨ú±ø¥ó§PÂ_
--  ­«­n¨ç¦¡:
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
        -- §PÂ_«O³æª¬ºA¦X²z©Ê --
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
           ERROR "«O³æª¬ºA¤£²Å!!"
           LET g_coupon_errmsg="«O³æª¬ºA¤£²Å!!" CLIPPED,p_data_s3.po_sts_code
           ERROR "erorr:",g_coupon_errmsg ATTRIBUTE(RED,UNDERLINE) 
           LET f_rcode=1
           EXIT WHILE
        END IF

        -- §PÂ_PTD ¬O§_¤j©óÁÙ¥»¶g¦~ --
        IF p_data_s3.po_sts_code != "43"  AND
           p_data_s3.po_sts_code != "44"  AND
           p_data_s3.po_sts_code != "46"  AND 
           p_data_s3.po_sts_code != "62"  THEN
           IF p_data_s3.paid_to_date < p_data_s1.cp_anniv_date THEN
              LET g_coupon_errmsg="Ãº¶O²×¤é¡ÕÁÙ¥»¶g¦~¤é!!" CLIPPED
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

        -- §PÂ_»â¨ú¤è¦¡ --
        IF p_pscb.cp_disb_type != "1" THEN
           LET g_coupon_errmsg=" ÁÙ¥»»â¨ú¤è¦¡¤£¬OÂd»O»â¨ú!!" CLIPPED
                               ,p_pscb.cp_disb_type     
           ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
           LET f_rcode=1
           EXIT WHILE
        END IF

        -- »â¨ú¤é´Á¬O§_¤j©ó¶g¦~¤é --
        LET f_tran_date=GetDate(today)  
        IF f_tran_date < p_data_s1.cp_anniv_date THEN
           LET g_coupon_errmsg="»â¨ú¤é´Á¤p©óÁÙ¥»¶g¦~¤é!!" CLIPPED
                               ,f_tran_date,p_data_s1.cp_anniv_date     
           ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
           LET f_rcode=1
           EXIT WHILE
        END IF

        -- »â¨ú¤À¤½¥q§PÂ_ --
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
           LET g_coupon_errmsg="¨Ï¥ÎªÌ¹ïÀ³¤À¤½¥q§ä¤£¨ì!!" CLIPPED
                               ,f_dept_code
           ERROR "error:",g_coupon_errmsg ATTRIBUTE(RED,UNDERLINE)
           LET f_rcode=1
           EXIT WHILE
        END IF

        IF LENGTH(f_dept_belong CLIPPED) =0 THEN
           LET g_coupon_errmsg="¨Ï¥ÎªÌ©ÒÄÝ¤À¤½¥q§ä¤£¨ì!!" CLIPPED
                               ,f_dept_code
           ERROR "error:",g_coupon_errmsg ATTRIBUTE(RED,UNDERLINE)
           LET f_rcode=1
           EXIT WHILE
        END IF
  
        IF f_dept_belong != p_data_s1.dept_code THEN
           LET g_coupon_errmsg="»â¨ú¤À¤½¥q»P§@·~¤À¤½¥q¤£²Å!!" CLIPPED
                               ,f_dept_belong,p_data_s1.dept_code
           ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
           LET f_rcode=1
           EXIT WHILE
        END IF

        -- ¬O§_¦³¥¼§I²{¤ä²¼ --
        CALL psc34s00(p_data_s1.policy_no,p_data_s1.cp_anniv_date,f_tran_date)  
             RETURNING f_rcode  
             IF f_rcode !=0 THEN
                LET g_coupon_errmsg="call psc03s00 error" 
                ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
                LET f_rcode=1
                EXIT WHILE
             END IF     

             IF g_coupon.g_chk_sw="N" THEN
                LET g_coupon_errmsg="¦³¥¼§I²{¤ä²¼" 
                ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
                LET f_rcode=1
                EXIT WHILE
             END IF

        -- »â¨úª÷ÃB»P¨R¾Pª÷ÃB¬Û²Å§_ --
        LET   f_cp_pay_amt=g_pscp.cp_pay_amt*(-1)
        
        SELECT sum(journal_amount) 
        INTO   f_journal_amt            
        FROM   glrc
        WHERE  acct_no="28250019"
        AND    recn_code=p_data_s1.policy_no

        IF  f_journal_amt != f_cp_pay_amt       THEN
            LET g_coupon_errmsg="¨R¾Pª÷ÃB»P»â¨úª÷ÃB¤£²Å¡A½Ð¬d¸ß±b°È§@·~!!"
                                ,f_journal_amt,f_cp_pay_amt
            ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
            LET f_rcode=1
            EXIT WHILE
        END IF

        -- ¬O§_¦³²z½ß¸ê®Æ --         
        CALL qryClaim(p_data_s1.policy_no,2,2)  

        -- ¬O§_§¹¦¨¨ü²z§@·~ --
        CALL getAcceptNo("9","")
             RETURNING  f_receive_no    

        IF  LENGTH(f_receive_no) =0     THEN
            LET g_coupon_errmsg="©|¥¼§¹¦¨¨ü²z§@·~!!"                            
            ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
            LET f_rcode=1
            EXIT WHILE
        ELSE
            ERROR f_receive_no  ATTRIBUTE(RED,UNDERLINE) 
        END IF  

       -- ¬O§_¦³²§±`±¡§Î --     
       SELECT count(*)
       INTO   f_count
       FROM   psce
       WHERE  policy_no     = p_data_s1.policy_no
       AND    cp_anniv_date = p_data_s1.cp_anniv_date

       IF f_count !=0  THEN
          ERROR "´¿¦³²§±`±¡§Î½Ð¬d©ú¦A§@·~!!" 
       END IF

      PROMPT '¬O§_²Å¦X»â¨ú±ø¥ó[y/n]' ATTRIBUTE(RED,UNDERLINE)
      FOR CHAR f_ans_sw1
      IF UPSHIFT(f_ans_sw1) = 'Y' THEN
         PROMPT '½Ðª`·N!!¥Í¦sª÷»â¨ú¼f¬dªí¶·¨Ìµ¹¥Iª÷ÃB¶i¦æ¬F±ÂÅvÃ±®Ö[y/n]' ATTRIBUTE(RED,UNDERLINE)
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
                  ERROR '¦¨¥\!!' ATTRIBUTE(RED,UNDERLINE)
               ELSE
                  ERROR '¦C¦L¼f¬dªí¥¢±Ñ¡A½Ð¥Ñ¦C¦L§@·~¸É¦L'ATTRIBUTE(RED,UNDERLINE)
               END IF
            ELSE
               ERROR "erorr:",g_coupon_errmsg
            END IF  
         END IF
         IF UPSHIFT(f_ans_sw) = 'N' THEN
            ERROR 'Â÷¶}»â¨ú§@·~!!' ATTRIBUTE(RED,UNDERLINE)
            LET f_rcode=0
            EXIT WHILE
         END IF

      END IF
      IF UPSHIFT(f_ans_sw1) = 'N' THEN
         ERROR 'Â÷¶}»â¨ú§@·~!!' ATTRIBUTE(RED,UNDERLINE)
         LET f_rcode=0
         EXIT WHILE
      END IF
END WHILE
RETURN f_rcode
END FUNCTION  --- psc02m_check ---
------------------------------------------------------------------------------
--  ¨ç¦¡¦WºÙ: psc02m_report1()
--  §@    ªÌ: merlin
--  ¤é    ´Á: 
--  ³B²z·§­n: ÁÙ¥»Âd»O§@·~_¦C¦L¼f¬d³æ
--  ­«­n¨ç¦¡:
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
         process_date             CHAR(9)                       -- §@·~¤é
        ,applicant_name           LIKE clnt.names               -- ­n«O¤H©m¦W
        ,insured_name             LIKE clnt.names               -- ³Q«OÀI¤H©m¦W
        ,po_sts_code              LIKE polf.po_sts_code         -- «O³æª¬ºA
        ,modx                     CHAR(6)                       -- Ãºªk
        ,plan_desc                LIKE pldf.plan_desc           -- ÁÙ¥»ÀIºØ
        ,policy_no                LIKE pscp.policy_no           -- «O³æ¸¹½X
        ,face_amt                 INTEGER                       -- «OÀIª÷ÃB
        ,dept_name                LIKE dept.dept_name           -- Àç·~³B¥N½X
        ,agent_name               LIKE clnt.names               -- ·~°È­û¥N½X
        ,po_issue_date            LIKE pscp.po_issue_date       -- ¥Í®Ä¤é
        ,paid_to_date             LIKE pscp.paid_to_date        -- Ãº¶O²×¤é
        ,cp_pay_form_type         LIKE pscp.cp_pay_form_type    -- µ¹¥I®æ¦¡
        ,cp_anniv_date            LIKE pscp.cp_anniv_date       -- ¶g¦~¤é
        ,div_option               LIKE pscp.div_option          -- ¬õ§Q¿ï¾ÜÅv
        ,cp_amt                   INTEGER                       -- µ¹¥Iª÷ÃB
        ,div_amt                  INTEGER                       -- «O³æ¬õ§Q
        ,prem_susp                INTEGER                       -- ·¸Ãº
        ,minus_prem_susp          INTEGER                       -- ¤íÃº
        ,apl_int                  INTEGER                       -- ¦Û°Ê¹ÔÃº§Q®§
        ,apl_amt                  INTEGER                       -- ¦Û°Ê¹ÔÃº¥»ª÷
        ,loan_int                 INTEGER                       -- ­É´Ú§Q®§
        ,loan_amt                 INTEGER                       -- ­É´Ú¥»ª÷
        ,cp_pay_amt               INTEGER                       -- À³µ¹¥I²bÃB
        ,rtn_rece_no              CHAR(10)                      -- ÁÙ´Ú¦¬¾Ú¸¹½X 
        ,cp_pay_name              CHAR(12)                      -- »â¨ú¤H©m¦W
        ,cp_pay_id                LIKE pscb.cp_pay_id           -- »â¨ú¤HID
        ,pay_dept_code            LIKE pscb.dept_code           -- »â¨ú¤À¤½¥q
        ,benf_cnt                 INTEGER
        ,plan_abbr_code           LIKE pldf.plan_abbr_code        --·s¼WFEL°·±dµ¹¥I 096/02
        ,receive_no               LIKE apdt.po_chg_rece_no
        ,tel                      LIKE addr.tel_1
                   END RECORD  
    LET f_rpt_cnt=0
    PROMPT '¬O§_¦C¦L·|­pÁp[y/n]' ATTRIBUTE(RED,UNDERLINE)
    FOR CHAR f_ans_sw
    IF  UPSHIFT(f_ans_sw) = 'Y' THEN                        
        LET f_rpt_cnt=3
    ELSE
        LET f_rpt_cnt=2
    END IF      

    LET f_rpt_name_1    =ReportName("psc02m01")
    
     START REPORT psc02m_notice     TO f_rpt_name_1    
       INITIALIZE r.* TO NULL

        -- Åª¨úpscp¥DÀÉ¸ê®Æ --     
        SELECT * 
        INTO   p_pscp.*
        FROM   pscp
        WHERE  policy_no     = f_policy_no
        AND    cp_anniv_date = f_cp_anniv_date
        
        -- ·~°È­û©m¦W --
        SELECT names
        INTO   r.agent_name
        FROM   clnt
        WHERE  client_id=p_pscp.agent_code

        -- Àç·~³æ¦ì --
        SELECT dept_name
        INTO   r.dept_name
        FROM   dept
        WHERE  dept_code=p_pscp.dept_code

        -- Ãºªk --
        CASE 
            WHEN g_polf.modx="0"  
                 LET r.modx       =" ¦~ Ãº"
            WHEN g_polf.modx="1"  
                 LET r.modx       =" ¤ë Ãº"             
            WHEN g_polf.modx="3"  
                 LET r.modx       =" ©u Ãº"             
            WHEN g_polf.modx="6"  
                 LET r.modx       ="¥b¦~Ãº"             
            WHEN g_polf.modx="12"
                 LET r.modx       =" ¦~ Ãº"             
             OTHERWISE          
                 LET r.modx       ="    Ãº"                      
        END CASE        

        LET r.policy_no         = f_policy_no                   -- «O³æ¸¹½X
        LET r.cp_anniv_date     = f_cp_anniv_date               -- ÁÙ¥»¶g¦~¤é 
        LET r.process_date      = GetDate(TODAY)                -- ³B²z¤é´Á
        LET r.applicant_name    = p_data_s3.app_name            -- ­n«O¤H©m¦W
        LET r.insured_name      = p_data_s3.insured_name        -- ³Q«OÀI¤H©m¦W
        LET r.po_sts_code       = p_data_s3.po_sts_code         -- «O³æª¬ºA
        LET r.policy_no         = p_pscp.policy_no              -- «O³æ¸¹½X
        LET r.face_amt          = p_pscp.face_amt               -- «OÀIª÷ÃB
        LET r.po_issue_date     = p_pscp.po_issue_date          -- ¥Í®Ä¤é
        LET r.paid_to_date      = p_pscp.paid_to_date           -- Ãº¶O²×¤é
        LET r.cp_pay_form_type  = p_pscp.cp_pay_form_type       -- µ¹¥I®æ¦¡
        LET r.cp_anniv_date     = p_pscp.cp_anniv_date          -- ¶g¦~¤é
        LET r.div_option        = p_pscp.div_option             -- ¬õ§Q¿ï¾ÜÅv
        LET r.cp_amt            = p_pscp.cp_amt                 -- µ¹¥Iª÷ÃB
        LET r.div_amt           = p_pscp.accumulated_div        -- «O³æ¬õ§Q
                                + p_pscp.div_int_balance         
                                + p_pscp.div_int        
        LET r.prem_susp         = p_pscp.prem_susp              -- ·¸Ãº
        LET r.minus_prem_susp   = p_pscp.rtn_minus_premsusp    -- ¤íÃº
        LET r.apl_int           = p_pscp.rtn_apl_int            -- ¦Û°Ê¹ÔÃº§Q®§
        LET r.apl_amt           = p_pscp.rtn_apl_amt            -- ¦Û°Ê¹ÔÃº¥»ª÷
        LET r.loan_int          = p_pscp.rtn_loan_int           -- ­É´Ú§Q®§
        LET r.loan_amt          = p_pscp.rtn_loan_amt           -- ­É´Ú¥»ª÷
        LET r.cp_pay_amt        = p_pscp.cp_pay_amt             -- À³µ¹¥I²bÃB
        LET r.rtn_rece_no       = p_pscp.rtn_rece_no            -- ÁÙ´Ú¦¬¾Ú¸¹½X
        LET r.cp_pay_name       = p_data_s1.cp_pay_name[1,12]   -- »â¨ú¤H©m¦W
        LET r.cp_pay_id         = p_data_s1.cp_pay_id           -- »â¨ú¤HID
        LET r.pay_dept_code     = p_data_s1.dept_code           -- »â¨ú¤À¤½¥q
        LET r.benf_cnt          = 0
        LET r.receive_no        = f_receive_no
        
    SELECT psc_desc
      INTO r.tel
      FROM psc4
     WHERE policy_no = f_policy_no
       AND cp_anniv_date = f_cp_anniv_date
       AND psc_type = '2'
    -- Åª¨úÀIºØ»¡©ú --
    SELECT plan_desc,plan_abbr_code            
    INTO   r.plan_desc,r.plan_abbr_code
    FROM   pldf
    WHERE  plan_code  = p_pscp.plan_code
    AND    rate_scale = p_pscp.rate_scale

    -- ¨ü¯q¤H¸ê®Æªì­È --        
    FOR f_i=1 TO 6
        LET   benf_arr[f_i].names               = ""      -- ¨ü¯q¤Hname --
        LET   benf_arr[f_i].benf_ratio          = ""      -- ¨ü¯q¤ñ¨Ò   --
        LET   benf_arr[f_i].cp_real_payamt      = ""      -- ¹ê»âª÷ÃB   --
        LET   benf_arr[f_i].disb_no             = ""      -- ¥I´Ú¸¹½X   --
    END FOR

    LET f_i=0
    LET f_benf_cnt=0

    SELECT count(*)
    INTO   f_benf_cnt
    FROM   pscd
    WHERE  policy_no=r.policy_no
    AND    cp_anniv_date=r.cp_anniv_date

    LET r.benf_cnt=f_benf_cnt

    -- Åª¨ú¨ü¯q¤H¸ê®Æ --        
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
--  ¨ç¦¡¦WºÙ: psc02m_notice()
--  §@    ªÌ: merlin
--  ¤é    ´Á: 
--  ³B²z·§­n: ÁÙ¥»Âd»O§@·~_¼f¬d³æ¤º®e
--  ­«­n¨ç¦¡:
------------------------------------------------------------------------------
REPORT psc02m_notice(r,f_rpt_cnt)
    DEFINE r            RECORD
         process_date             CHAR(9) 
        ,applicant_name           LIKE clnt.names               -- ­n«O¤H©m¦W
        ,insured_name             LIKE clnt.names               -- ³Q«OÀI¤H©m¦W
        ,po_sts_code              LIKE polf.po_sts_code         -- «O³æª¬ºA
        ,modx                     CHAR(6)                       -- Ãºªk
        ,plan_desc                LIKE pldf.plan_desc           -- ÁÙ¥»ÀIºØ
        ,policy_no                LIKE pscp.policy_no           -- «O³æ¸¹½X
        ,face_amt                 INTEGER                       -- «OÀIª÷ÃB
        ,dept_name                LIKE dept.dept_name           -- Àç·~³B¥N½X
        ,agent_name               LIKE clnt.names               -- ·~°È­û¥N½X
        ,po_issue_date            LIKE pscp.po_issue_date       -- ¥Í®Ä¤é
        ,paid_to_date             LIKE pscp.paid_to_date        -- Ãº¶O²×¤é
        ,cp_pay_form_type         LIKE pscp.cp_pay_form_type    -- µ¹¥I®æ¦¡
        ,cp_anniv_date            LIKE pscp.cp_anniv_date       -- ¶g¦~¤é
        ,div_option               LIKE pscp.div_option          -- ¬õ§Q¿ï¾ÜÅv
        ,cp_amt                   INTEGER                       -- µ¹¥Iª÷ÃB
        ,div_amt                  INTEGER                       -- «O³æ¬õ§Q
        ,prem_susp                INTEGER                       -- ·¸Ãº
        ,minus_prem_susp          INTEGER                       -- ¤íÃº
        ,apl_int                  INTEGER                       -- ¦Û°Ê¹ÔÃº§Q®§
        ,apl_amt                  INTEGER                       -- ¦Û°Ê¹ÔÃº¥»ª÷
        ,loan_int                 INTEGER                       -- ­É´Ú§Q®§
        ,loan_amt                 INTEGER                       -- ­É´Ú¥»ª÷
        ,cp_pay_amt               INTEGER                       -- À³µ¹¥I²bÃB
        ,rtn_rece_no              CHAR(10)                      -- ÁÙ´Ú¦¬¾Ú¸¹½X
        ,cp_pay_name              CHAR(12)                      -- »â¨ú¤H©m¦W
        ,cp_pay_id                LIKE pscb.cp_pay_id           -- »â¨ú¤HID
        ,pay_dept_code            LIKE pscb.dept_code           -- »â¨ú¤À¤½¥q
        ,benf_cnt                 INTEGER      
        ,plan_abbr_code           LIKE pldf.plan_abbr_code      --·s¼WFELµ¹¥I 096/02 
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

        -- ¥Í¦s»â¨úªí -- 
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
               LET r_cpform_var[14,21] = '°·±dÀË¬d' 
           ELSE 
               LET r_cpform_var[18,21] = '¥Í¦s'
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
                       PRINT COLUMN  1 ,"¢x"
                            ,COLUMN  6 ,f_i                         
                                        USING "#"
                            ,COLUMN 12 ,benf_arr[f_i].names CLIPPED
                            ,COLUMN 28 ,benf_arr[f_i].benf_ratio
                                        USING "###.##"
                            ,COLUMN 40 ,benf_arr[f_i].cp_real_payamt 
                                        USING "###,###,###"     
                            ,COLUMN 62 ,benf_arr[f_i].disb_no
                            ,COLUMN 79 ,"¢x"
                   END FOR
               END IF           
           END FOR
        END IF  

        -- º¡´Á»â¨úªí --
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
                       PRINT COLUMN  1 ,"¢x"
                            ,COLUMN  6 ,f_i                         
                                        USING "#"
                            ,COLUMN 12 ,benf_arr[f_i].names CLIPPED
                            ,COLUMN 28 ,benf_arr[f_i].benf_ratio
                                        USING "###.##"
                            ,COLUMN 40 ,benf_arr[f_i].cp_real_payamt 
                                        USING "###,###,###"     
                            ,COLUMN 62 ,benf_arr[f_i].disb_no
                            ,COLUMN 79 ,"¢x"
                   END FOR
               END IF           
           END FOR
        END IF  

       
       LET  r_cpform_var[51,78] = "¥DºÞÃ±®Ö¡G__________________"

       CASE 
       WHEN f_rpt_cnt=1 
            PRINT COLUMN  6, "»â¨ú¤HÃ±³¹¡G"
                        PRINT COLUMN  1, "  "               
            PRINT COLUMN 40, r_cpform_var[51,78]                
            SKIP 3 LINES
            PRINT COLUMN 32, "²Ä¤@Áp ¡  ¤½¥qÂkÀÉÁp"
       WHEN f_rpt_cnt=2 
            PRINT COLUMN 40, r_cpform_var CLIPPED
            PRINT COLUMN  1, "  "               
            PRINT COLUMN  1, "  "
            SKIP 3 LINES
            PRINT COLUMN 32, "²Ä¤GÁp¡   «O¤áÁp"
       WHEN f_rpt_cnt=3
            PRINT COLUMN 40, r_cpform_var CLIPPED
            PRINT COLUMN  1, "  "               
            PRINT COLUMN 40, r_cpform_var[51,78]                
            SKIP 3 LINES
            PRINT COLUMN 32, "²Ä¤TÁp¡   ·|­pÂkÀÉÁp"
       END CASE

       PRINT COLUMN 5, ap003_barcode( "PS2090" ) CLIPPED, 2 SPACES, "PS2090"
       SKIP 1 LINES
       PRINT COLUMN 5, ap003_barcode(r.receive_no) CLIPPED,2 SPACES,r.receive_no
       SKIP 1 LINES
       PRINT COLUMN 5, ap003_barcode(r.policy_no) CLIPPED,2 SPACES,r.policy_no

       SKIP TO TOP OF PAGE      

END REPORT  -- psc02m_notice --
------------------------------------------------------------------------------
--  ¨ç¦¡¦WºÙ: psc02m_init_array()
--  §@    ªÌ: merlin
--  ¤é    ´Á: 
--  ³B²z·§­n: ÁÙ¥»Âd»O§@·~_¼f¬d³æ®æ¦¡
--  ­«­n¨ç¦¡:
------------------------------------------------------------------------------   
FUNCTION psc02m_init_array()
        DEFINE f_rcode  INTEGER

LET p_cpform_1[1] = " "
LET p_cpform_1[2] = "               ¥Í¦sª÷»â¨ú¼f¬dªí"
LET p_cpform_1[3] = "                                                           [¾÷±K¤å¥ó]"
LET p_cpform_1[4] = "      «O³æ¸¹½X¡G                              ¤é    ´Á ¡G                       "  
LET p_cpform_1[5] = "      ­n «O ¤H¡G                              Àç·~³æ¦ì ¡G                       "  
LET p_cpform_1[6] = "      ³Q«OÀI¤H¡G                              ·~ °È ­û ¡G                       "  
LET p_cpform_1[7] = "                                              ¨ü²z¸¹½X ¡G                       "   
LET p_cpform_1[8] = "¢z¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢{"
LET p_cpform_1[9] = "¢x  ÁÙ¥»ÀIºØ  ¡G                              «OÀIª÷ÃB  ¡G   xxx,xxx,xxx¤¸    ¢x"
LET p_cpform_1[10]= "¢x  «´¬ù¥Í®Ä¤é¡G                                                              ¢x"
LET p_cpform_1[11]= "¢x  ÁÙ¥»¶g¦~¤é¡G xxxxxxxxx    «O³æª¬ºA¡G xx   ¬õ§Q¿ï¾Ü¡G x     Ãºªk¡G xxxxxx  ¢x"
LET p_cpform_1[12]= "¢u¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢t"
LET p_cpform_1[13]= "¢x                                                                            ¢x"
LET p_cpform_1[14]= "¢x                   «OÀIª÷                         xxx,xxx,xxx¤¸             ¢x"
LET p_cpform_1[15]= "¢x                                                                            ¢x"
LET p_cpform_1[16]= "¢x                                                                            ¢x"
LET p_cpform_1[17]= "¢x                     ¦©°£¡G«e´Á¤íÃº               xxx,xxx,xxx¤¸             ¢x"
LET p_cpform_1[18]= "¢x                           ¦Û°Ê¹ÔÃº«O¶O§Q®§       xxx,xxx,xxx¤¸             ¢x"
LET p_cpform_1[19]= "¢x                           ¦Û°Ê¹ÔÃº«O¶O¥»ª÷       xxx,xxx,xxx¤¸             ¢x"
LET p_cpform_1[20]= "¢x                           «O³æ­É´Ú§Q®§           xxx,xxx,xxx¤¸             ¢x"
LET p_cpform_1[21]= "¢x                           «O³æ­É´Ú¥»ª÷           xxx,xxx,xxx¤¸             ¢x"
LET p_cpform_1[22]= "¢x                                                                            ¢x"
LET p_cpform_1[23]= "¢x               À³µ¹¥I²bÃB                         xxx,xxx,xxx¤¸             ¢x"
LET p_cpform_1[24]= "¢x                                                                            ¢x"
LET p_cpform_1[25]= "¢x  ÁÙ´Ú¦¬¾Ú¸¹½X¡Gxxxxxxxxxx                                                  ¢x"
LET p_cpform_1[26]= "¢x                                                                            ¢x"
LET p_cpform_1[27]= "¢x  »â¨ú¤H©m¦W¡Gxxxxxxxxxxxx   »â¨ú¤HID¡Gxxxxxxxxxx  »â¨ú¤À¤½¥q¡Gxxxxxx       ¢x"
LET p_cpform_1[28]= "¢x  »â¨ú¤H¹q¸Ü¡Gxxxxxxxxxxxx                                                  ¢x"
LET p_cpform_1[29]= "¢x                                                                            ¢x"
LET p_cpform_1[30]= "¢x  §Ç¸¹   ¨ü¯q¤H©m¦W      ¤ñ²v¢H         µ¹¥Iª÷ÃB           ¥I´Ú¸¹½X         ¢x"
LET p_cpform_1[31]= "¢x                                                                            ¢x"
LET p_cpform_1[32]= "¢|¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢}"

LET p_cpform_2[1] = " "
LET p_cpform_2[2] = "               º¡´Áª÷»â¨ú¼f¬dªí"
LET p_cpform_2[3] = ""
LET p_cpform_2[4] = "      «O³æ¸¹½X¡G                              ¤é    ´Á ¡G                       "  
LET p_cpform_2[5] = "      ­n «O ¤H¡G                              Àç·~³æ¦ì ¡G                       "
LET p_cpform_2[6] = "      ³Q«OÀI¤H¡G                              ·~ °È ­û ¡G                       "
LET p_cpform_2[7] = "                                              ¨ü²z¸¹½X ¡G                       " 
LET p_cpform_2[8] = "¢z¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢{"
LET p_cpform_2[9] = "¢x  ÁÙ¥»ÀIºØ  ¡G                              «OÀIª÷ÃB  ¡G   xxx,xxx,xxx¤¸    ¢x"
LET p_cpform_2[10]= "¢x  «´¬ù¥Í®Ä¤é¡G                                                              ¢x"
LET p_cpform_2[11]= "¢x  ÁÙ¥»¶g¦~¤é¡G xxxxxxxxx    «O³æª¬ºA¡G xx   ¬õ§Q¿ï¾Ü¡G x     Ãºªk¡G xxxxxx  ¢x"
LET p_cpform_2[12]= "¢u¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢t"
LET p_cpform_2[13]= "¢x                                                                            ¢x"
LET p_cpform_2[14]= "¢x               º¡´Á«OÀIª÷                         xxx,xxx,xxx¤¸             ¢x"
LET p_cpform_2[15]= "¢x                       ¥[¡G«O³æ¬õ§Q               xxx,xxx,xxx¤¸             ¢x"
LET p_cpform_2[16]= "¢x                           ·¸Ãº                   xxx,xxx,xxx¤¸             ¢x"
LET p_cpform_2[17]= "¢x                     ¦©°£¡G«e´Á¤íÃº               xxx,xxx,xxx¤¸             ¢x"
LET p_cpform_2[18]= "¢x                           ¦Û°Ê¹ÔÃº«O¶O§Q®§       xxx,xxx,xxx¤¸             ¢x"
LET p_cpform_2[19]= "¢x                           ¦Û°Ê¹ÔÃº«O¶O¥»ª÷       xxx,xxx,xxx¤¸             ¢x"
LET p_cpform_2[20]= "¢x                           «O³æ­É´Ú§Q®§           xxx,xxx,xxx¤¸             ¢x"
LET p_cpform_2[21]= "¢x                           «O³æ­É´Ú¥»ª÷           xxx,xxx,xxx¤¸             ¢x"
LET p_cpform_2[22]= "¢x                                                                            ¢x"
LET p_cpform_2[23]= "¢x               À³µ¹¥I²bÃB                         xxx,xxx,xxx¤¸             ¢x"
LET p_cpform_2[24]= "¢x                                                                            ¢x"
LET p_cpform_2[25]= "¢x  ÁÙ´Ú¦¬¾Ú¸¹½X¡Gxxxxxxxxxx                                                  ¢x"
LET p_cpform_2[26]= "¢x                                                                            ¢x"
LET p_cpform_2[27]= "¢x  »â¨ú¤H©m¦W¡Gxxxxxxxxxxxx   »â¨ú¤HID¡Gxxxxxxxxxx  »â¨ú¤À¤½¥q¡Gxxxxxx       ¢x"
LET p_cpform_2[28]= "¢x  »â¨ú¤H¹q¸Ü¡Gxxxxxxxxxxxx                                                  ¢x"
LET p_cpform_2[29]= "¢x                                                                            ¢x"
LET p_cpform_2[30]= "¢x  §Ç¸¹   ¨ü¯q¤H©m¦W      ¤ñ²v¢H         µ¹¥Iª÷ÃB           ¥I´Ú¸¹½X         ¢x"
LET p_cpform_2[31]= "¢x                                                                            ¢x"
LET p_cpform_2[32]= "¢|¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢w¢}"

LET f_rcode=1
RETURN f_rcode
END FUNCTION  -- psc02m_init_array --
------------------------------------------------------------------------------
--  ¨ç¦¡¦WºÙ: psc02m_inoput1()
--  §@    ªÌ: merlin
--  ¤é    ´Á: 
--  ³B²z·§­n: ÁÙ¥»Âd»O§@·~_³øªí±ø¥ó¿é¤J
--  ­«­n¨ç¦¡:
------------------------------------------------------------------------------  
FUNCTION psc02m_input1()
    DEFINE f_right_or_fault     INTEGER   -- ¤é´ÁÀË¬d t or f --
          ,f_formated_date      CHAR(9)   -- ¤é´Á®æ¦¡¤Æ 999/99/99 --
          ,f_pscb_cnt           INTEGER   -- °õ¦æ perpare «ü¥O¦³«O³æ¥i°õ¦æ --
          ,f_rcode              INTEGER
        
    DEFINE f_dept_code          LIKE pscb.dept_code
          ,f_start_date         CHAR(9)

    LET f_rcode         = 0             
    LET INT_FLAG        = FALSE
    LET f_pscb_cnt      = 0
    LET f_dept_code     = " "
    LET f_start_date    = " "
        
    MESSAGE " END(F7):¨ú®ø§@·~"

    OPEN WINDOW psc02m02   AT 10,11 WITH FORM "psc02m02"        
    ATTRIBUTE(BLUE, REVERSE, UNDERLINE, FORM LINE FIRST)

    INPUT f_dept_code,f_start_date
    FROM  dept_code,start_date   ATTRIBUTE(BLUE ,REVERSE ,UNDERLINE)

    AFTER FIELD dept_code
       IF f_dept_code=" "             OR
          f_dept_code="            "  THEN
          ERROR "»â¨ú¦aÂI¥²¶·¿é¤J!!"  ATTRIBUTE (RED)
          NEXT FIELD dept_code
       END IF

    AFTER FIELD start_date
       CALL CheckDate(f_start_date)
            RETURNING f_right_or_fault,f_formated_date
       IF f_right_or_fault = false THEN
          ERROR "¤é´Á¿é¤J¿ù»~!!"   ATTRIBUTE (RED)
          NEXT FIELD start_date
       END IF

       IF f_start_date="         " OR
          f_start_date=" "         THEN
          ERROR "¤é´Á¥²¶·¿é¤J!!"   ATTRIBUTE (RED)
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
    -- ¤¤Â_§@·~ --
    IF INT_FLAG=TRUE THEN
       LET f_rcode=1
       RETURN f_rcode,f_dept_code,f_start_date
    END IF

    RETURN f_rcode ,f_dept_code,f_start_date

END FUNCTION    --- psc02m_input1 ---
------------------------------------------------------------------------------
--  ¨ç¦¡¦WºÙ: psc02m_report2()
--  §@    ªÌ: merlin
--  ¤é    ´Á: 
--  ³B²z·§­n: ÁÙ¥»Âd»O§@·~_¤w»â¨ú³øªí
--  ­«­n¨ç¦¡:
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
         policy_no                LIKE pscb.policy_no           -- «O³æ¸¹½X
        ,cp_anniv_date            LIKE pscb.cp_anniv_date       -- «O³æ¶g¦~¤é
        ,cp_sw                    LIKE pscb.cp_sw               -- ÁÙ¥»«ü¥Ü
        ,process_user             LIKE pscb.process_user        -- ©Ó¿ì¤H
        ,change_date              LIKE pscb.change_date         -- §@±b¤é
        ,cp_pay_name              LIKE pscb.cp_pay_name         -- »â¨ú¤H©m¦W
        ,dept_code                LIKE pscb.dept_code           -- »â¨ú¤À¤½¥q
        ,cp_disb_type             LIKE pscb.cp_disb_type        -- ÁÙ¥»µ¹¥I¤è¦¡
        ,agent_code               LIKE pscp.agent_code          -- ·~°È­û¥N½X
        ,cp_amt  	          INTEGER                       -- À³µ¹¥Iª÷ÃB
        ,cp_pay_amt               INTEGER                       -- À³µ¹¥I²bÃB
        ,cp_pay_form_type         LIKE pscp.cp_pay_form_type    -- ÁÙ¥»µ¹¥I®Ñ®æ¦¡
                    END RECORD  

        LET r1.policy_no                = " "           -- «O³æ¸¹½X
        LET r1.cp_anniv_date            = " "           -- ÁÙ¥»¶g¦~¤é
        LET r1.cp_sw                    = " "           -- ÁÙ¥»«ü¥Ü
        LET r1.process_user             = " "           -- ©Ó¿ì¤H
        LET r1.change_date              = " "           -- §@±b¤é
        LET r1.agent_code               = " "           -- ·~°È­û¥N½X
        LET r1.cp_pay_amt               = 0             -- À³µ¹¥I²bÃB
        LET r1.cp_pay_name              = " "           -- »â¨ú¤H©m¦W
        LET r1.dept_code                = " "           -- »â¨ú¤À¤½¥q
        LET r1.cp_pay_form_type         = ""            -- ÁÙ¥»µ¹¥I®Ñ®æ¦¡
        
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
           ERROR "µL¤w»â¨ú¸ê®Æ"         
        ELSE
           -- Åª¨ú»â¨ú¦aÂI¦WºÙ --
           SELECT  dept_name
           INTO    f_dept_name
           FROM    dept
           WHERE   dept_code=f_dept_code
                
           -- Åª¨ú¥H»â¨ú¸ê®Æ --
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
           -- ·~°È­û©m¦W --
           SELECT names
           INTO   f_agent_name
           FROM   clnt
           WHERE  client_id=r1.agent_code

           -- §PÂ_º¡´Á  
           CASE
                WHEN r1.cp_pay_form_type = "5"
                     LET f_expired_sw    = "¥Í¦s"
                WHEN r1.cp_pay_form_type = "5.1"
                     LET f_expired_sw    = "¥Í¦s"
                WHEN r1.cp_pay_form_type = "6"
                     LET f_expired_sw    = "º¡´Á"
                WHEN r1.cp_pay_form_type = "6.1"
                     LET f_expired_sw    = "º¡´Á"
                WHEN r1.cp_pay_form_type = "6.2"
                     LET f_expired_sw    = "º¡´Á"
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
--  ¨ç¦¡¦WºÙ: psc02m_notice1()
--  §@    ªÌ: merlin
--  ¤é    ´Á: 
--  ³B²z·§­n: ÁÙ¥»Âd»O§@·~_¤w»â¨ú±±¨î³øªí¤º®e
--  ­«­n¨ç¦¡:
------------------------------------------------------------------------------
REPORT psc02m_notice1(r1,f_start_date,f_dept_code
                     ,f_agent_name,f_dept_name,f_expired_sw)
    DEFINE r1           RECORD
         policy_no                LIKE pscb.policy_no           -- «O³æ¸¹½X
        ,cp_anniv_date            LIKE pscb.cp_anniv_date
        ,cp_sw                    LIKE pscb.cp_sw               -- ÁÙ¥»«ü¥Ü
        ,process_user             LIKE pscb.process_user        -- ©Ó¿ì¤H
        ,change_date              LIKE pscb.change_date         -- §@±b¤é
        ,cp_pay_name              LIKE pscb.cp_pay_name         -- »â¨ú¤H©m¦W
        ,dept_code                LIKE pscb.dept_code           -- »â¨ú¤À¤½¥q
        ,cp_disb_type             LIKE pscb.cp_disb_type
        ,agent_code               LIKE pscp.agent_code          -- ·~°È­û¥N½X
        ,cp_amt                   INTEGER                       -- À³µ¹¥Iª÷ÃB
        ,cp_pay_amt               INTEGER                       -- À³µ¹¥I²bÃB
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
             PRINT COLUMN  17,"ÁÙ ¥» Âd »O §@ ·~ __ ÁÙ ¥» ª÷ ¤w »â ¨ú ³ø ªí"
             PRINT COLUMN  64,p_name CLIPPED
             SKIP 1 LINES                       
             PRINT COLUMN   1, "¦Lªí¤é´Á¡G ", GetDate(TODAY),
                   COLUMN  64, "³øªí¥N½X¡G ","PSC02M"
             PRINT COLUMN   1, "§@·~¤é´Á¡G ",f_start_date,
                   COLUMN  22, "»â¨ú¦aÂI¡G ",f_dept_name CLIPPED ,f_dept_code,
                   COLUMN  64, "²Ä "   , PAGENO USING "####"," ­¶"
             PRINT SetLine( "-",80 ) CLIPPED
             PRINT COLUMN   2, "«O³æ¸¹½X",   
                   COLUMN  15, "ÁÙ¥»¶g¦~¤é",		
                   COLUMN  28, "À³»âª÷ÃB",
                   COLUMN  39, "¹ê»âª÷ÃB",
                   COLUMN  48, "»â¨ú¤H",
                   COLUMN  57, "·~°È­û",
                   COLUMN  66, "©Ó¿ì¤H",
                   COLUMN  75, "«¬ºA"
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
      PRINT COLUMN  1,"¥ó¼Æ¡G",r_total_cnt USING "###,##&","¥ó",
            COLUMN 18,"À³»âª÷ÃB¦X­p¡G",r_sum_1 USING "###,###,##&" ," ¤¸",
            COLUMN 50,"¹ê»âª÷ÃB¦X­p¡G",r_sum_2 USING "###,###,##&" ," ¤¸"    
END REPORT
{
 «O³æ¸¹½X     ÁÙ¥»¶g¦~¤é   À³»âª÷ÃB   ¹ê»âª÷ÃB »â¨ú¤H   ·~°È­û   ©Ó¿ì¤H   «¬ºA
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
            PROMPT "½Ð½T»{«O¤á¬O§_¶ñ¨ãFATCAÁn©ú®Ñ!!Y/N" FOR CHAR f_ans
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
