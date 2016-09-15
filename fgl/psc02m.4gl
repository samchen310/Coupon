------------------------------------------------------------------------------
--  �{���W��: psc02m.4gl
--  �@    ��: merlin
--  ��    ��: 
--  �B�z���n: �٥��d�O�@�~
--  ���n�禡:
------------------------------------------------------------------------------
-- ���ڬd�߫e�������ŧi g_check_count��0 �~�|����
-- 089/09/14:�ק�f�d��C�L�榡�P���e�A�����ɦL�\��
------------------------------------------------------------------------------
-- �ק��:JC
--  090/04/25:�ק���q�H�W�r����k,��id ��clnt,�_�h��� benf �� names
------------------------------------------------------------------------------
-- �ק��:merlin
-- 090/07/20:�}��O�檬�A66�A67�A73�i�d�O�@�~�Τw�������W�[������B
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
          ,p_applicant_id     LIKE clnt.client_id       -- �~�ȭ�ID   --
          ,p_applicant_name   LIKE clnt.names           -- �~�ȭ��m�W --
          ,p_coverage_no      LIKE colf.coverage_no     -- �I�ت���   --
          ,p_benf_cnt         INTEGER                   -- ���q�H��   -- 
          ,p_cp_sw            CHAR(1)                   -- �٥�����   -- 
          ,p_check_date       CHAR(9)

 
    -- �e���@�W�b������� --
    DEFINE p_data_s1 RECORD -- screen s1 -- 
           policy_no         LIKE pscb.policy_no       -- �O�渹�X   --
          ,cp_anniv_date     LIKE pscp.cp_anniv_date   -- �g�~��     --
          ,expired_sw        CHAR                      -- ����/�ͦs  --
          ,cp_remark_sw      LIKE pscb.cp_remark_sw    -- ���O����   --  
          ,cp_pay_name       LIKE pscb.cp_pay_name     -- ����H�m�W --
          ,cp_pay_id         LIKE pscb.cp_pay_id       -- ����ID     --
          ,dept_code         LIKE pscb.dept_code       -- ��������q --
                 END RECORD

    -- �e���@�ĤG������� --
    DEFINE p_data_s3 RECORD
           po_issue_date     LIKE polf.po_issue_date   -- �ͮĤ�     --
          ,paid_to_date      LIKE polf.paid_to_date    -- ú�O�פ�   --
          ,po_sts_code       LIKE polf.po_sts_code     -- �O�檬�A   --
          ,app_name          CHAR(12)                  -- �n�O�H     --
          ,insured_name      CHAR(12)                  -- �Q�O�H     --
          ,method            LIKE polf.method          -- ���O�覡   --
          ,dept_name         LIKE dept.dept_name       -- ��~���   --
          ,agent_name        LIKE clnt.names           -- �~�ȭ�     --
          ,chk_date          CHAR(9)                   -- ���I�䲼   --
                 END RECORD

    -- �e���@�ĤT������� --
    DEFINE p_data_s2 ARRAY[99] OF RECORD               -- ���q�H���� --
           names               LIKE benf.names         -- ���q�H�m�W --
          ,benf_ratio          LIKE benf.benf_ratio    -- ���q���   --
          ,remit_account       LIKE benf.remit_account -- �״ڱb��   --
          ,benf_order          LIKE benf.benf_order    -- �״ڻȦ�   --
                 END RECORD
 

    DEFINE p_pscb              RECORD LIKE pscb.*  
    DEFINE p_pscp              RECORD LIKE pscp.*

    -- �f�d�椺�e --    
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

-- �D�{�� --
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

    -- ��ܲĤ@�e�� --
    OPEN FORM psc02m01 FROM "psc02m01"
    DISPLAY FORM psc02m01 ATTRIBUTE (GREEN)

    CALL ShowLogo()
    -- JOB  CONTROL beg --
    CALL GetDocLname( '2') RETURNING p_name
    CALL JobControl()

    MENU "�п��"
       BEFORE MENU
            IF  NOT CheckAuthority("1", FALSE)  THEN
                HIDE OPTION "1)���"
            END IF
            IF  NOT CheckAuthority("2", FALSE)  THEN
                HIDE OPTION "2)�٥��d��"
            END IF
            IF  NOT CheckAuthority("3", FALSE)  THEN
                HIDE OPTION "3)�z�߬d��"
            END IF
            IF  NOT CheckAuthority("4", FALSE)  THEN
                HIDE OPTION "4)���ڬd��"
            END IF
            IF  NOT CheckAuthority("5", FALSE)  THEN
                HIDE OPTION "5)���O�d��"
            END IF
{
            IF  NOT CheckAuthority("6", FALSE)  THEN
                HIDE OPTION "6)�ɦL�f�d��"
            END IF
}
            IF  NOT CheckAuthority("7", FALSE)  THEN
                HIDE OPTION "7)�C�L�d�O�w�������"
            END IF
        COMMAND "1)���"
                 CALL psc02m_pay()

        COMMAND "2)�٥��d��"
                 RUN "psc01i.4ge"

        COMMAND "3)�z�߬d��"
                 CALL psc02m_init()
                 CALL qry_input() RETURNING p_pass_or_deny
                   IF p_pass_or_deny=0 THEN
                      CALL qryClaim(p_data_s1.policy_no,2,2)
                   END IF 

        COMMAND "4)���ڬd��"
                 CALL psc02m_init()
                 CALL qry_input() RETURNING p_pass_or_deny
                   IF p_pass_or_deny=0 THEN
                      LET g_check_count=0 
                      CALL qryCheck()   RETURNING p_check_date
                   END IF       

        COMMAND "5)���O�d��"
                 CALL psc02m_init()
                 CALL psc02m_input() RETURNING p_pass_or_deny
                   IF p_pass_or_deny=0 THEN
                      CALL pscninq(p_data_s1.policy_no,p_data_s1.cp_anniv_date)
                      RETURNING p_pass_or_deny
                   END IF
{
        COMMAND "6)�ɦL�f�d��" 
                 CALL psc02m_print("6") 
}
        COMMAND "7)�C�L�d�O�w�������"
                 CALL psc02m_print("7")

        COMMAND "0)����"
                 EXIT MENU
        END MENU 
 
    CLOSE FORM psc02m01

    -- JOB  CONTROL beg --
    CALL JobControl()

END MAIN -- �D�{������ --

------------------------------------------------------------------------------
--  �禡�W��: psc02m_pay
--  �@    ��: merlin
--  ��    ��: 
--  �B�z���n: �٥��d�O�@�~_����@�~
--  ���n�禡:
------------------------------------------------------------------------------          
FUNCTION psc02m_pay()
    DEFINE f_rcode      INTEGER    
    DEFINE f_pscb_cnt   INTEGER 
    DEFINE f_cp_sw      LIKE pscb.cp_sw
        
     CALL psc02m_init()
     CALL psc02m_input() RETURNING f_rcode

     --�P�_�O��O�_�w�٥�--     
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
          ERROR "�Х��٥��d�ߥ\��d�߬�����ơI" 
          ATTRIBUTE(RED,UNDERLINE)
       ELSE
          CALL psc02m_display()
          CALL psc02m_check() RETURNING f_rcode 
       END IF
       CALL Fatca_message()
     END IF     
END FUNCTION    ---  psc02m_pay ---

------------------------------------------------------------------------------
--  �禡�W��: psc02m_print()
--  �@    ��: merlin
--  ��    ��: 
--  �B�z���n: �٥��d�O�@�~_�C�L�@�~
--  ���n�禡:
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
                   ERROR "�O��w�٥��A�Х��٥��d�ߥ\��d�߬�����ơI" 
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
                      ERROR "�C�L�@�~���~�I�I"
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
                           ERROR "�C�L�@�~���~�I�I"
                       END IF
                 END IF
        END CASE
END FUNCTION      --- psc02m_print ---
------------------------------------------------------------------------------
--  �禡�W��: psc02m_init
--  �@    ��: merlin
--  ��    ��: 
--  �B�z���n: �٥��d�O�@�~_�e�����
--  ���n�禡:
------------------------------------------------------------------------------

FUNCTION psc02m_init()
    DEFINE f_i           SMALLINT -- array index ---

    LET   p_policy_no     =" "
    LET   p_applicant_id  =" "
    LET   p_applicant_name=" "
    LET   p_coverage_no   =1

    -- �e���@��� --
    LET   p_data_s1.policy_no              =" "       -- �O�渹�X   --
    LET   p_data_s1.cp_anniv_date          =" "       -- �٥��g�~�� --
    LET   p_data_s1.expired_sw             =" "       -- ����/�ͦs  --
    LET   p_data_s1.cp_remark_sw           =" "       -- ���O����   --
    LET   p_data_s1.cp_pay_name            =" "       -- ����H�m�W --
    LET   p_data_s1.cp_pay_id              =" "       -- ����HID   --
    LET   p_data_s1.dept_code              =" "       -- ��������q --                          

    -- �e���G��� --
    LET   p_data_s3.po_issue_date          =" "       -- �ͮĤ�     --
    LET   p_data_s3.paid_to_date           =" "       -- ú�O�פ�   --
    LET   p_data_s3.po_sts_code            =" "       -- �O�檬�A   --
    LET   p_data_s3.app_name               =" "       -- �n�O�H     --
    LET   p_data_s3.insured_name           =" "       -- �Q�O�H     --
    LET   p_data_s3.method                 =" "       -- ���O�覡   --
    LET   p_data_s3.dept_name              =" "       -- ��~���   --
    LET   p_data_s3.agent_name             =" "       -- �~�ȭ�     --
    LET   p_data_s3.chk_date               =" "       -- ���I�䲼   --

    -- �e���T detail ��� --
    FOR f_i=1 TO 4
       LET   p_data_s2[f_i].names          =" "       -- �m�W/�W��  --
       LET   p_data_s2[f_i].benf_ratio     = 0        -- ���q���   --
       LET   p_data_s2[f_i].remit_account  =" "       -- �״ڱb��   --
       LET   p_data_s2[f_i].benf_order     =" "       -- ���q����   --
    END FOR
    CLEAR FORM
END FUNCTION   -- psc02m_init --
------------------------------------------------------------------------------
--  �禡�W��: psc02m_input
--  �@    ��: merlin
--  ��    ��: 
--  �B�z���n: �٥��d�O�@�~_�e����J�]����A���O�d�ߡA����C�L�^
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION psc02m_input()
    DEFINE f_right_or_fault     INTEGER   -- ����ˬd t or f --
          ,f_formated_date      CHAR(9)   -- ����榡�� 999/99/99 --
          ,f_pscb_cnt           INTEGER   -- ���� perpare ���O���O��i���� --
          ,f_rcode              INTEGER

    LET f_rcode       =FALSE            
    LET INT_FLAG      =FALSE
    LET f_pscb_cnt    =0

    MESSAGE " END(F7):�����@�~"

    INPUT p_data_s1.policy_no,p_data_s1.cp_anniv_date
    FROM  policy_no,cp_anniv_date
    ATTRIBUTE(BLUE ,REVERSE ,UNDERLINE)
  
    AFTER FIELD policy_no
        IF p_data_s1.policy_no=" "            OR
           p_data_s1.policy_no="            " THEN
           ERROR "�O�渹�X������J!!"    ATTRIBUTE (RED)
           NEXT FIELD policy_no
        END IF
       -- ����ˬd --
       -- g_polf.����� --
       SELECT *
       INTO   g_polf.*
       FROM   polf
       WHERE  policy_no=p_data_s1.policy_no

       IF STATUS=NOTFOUND THEN
          ERROR "�L���i�O��!!" ATTRIBUTE (RED)
          NEXT FIELD policy_no
       END IF

    AFTER FIELD cp_anniv_date
        CALL CheckDate(p_data_s1.cp_anniv_date)
             RETURNING f_right_or_fault,f_formated_date

        IF f_right_or_fault = false THEN
           ERROR "�g�~���J���~!!" ATTRIBUTE (RED)
           NEXT FIELD cp_anniv_date
        END IF

        IF p_data_s1.cp_anniv_date="         " OR
           p_data_s1.cp_anniv_date=" "         THEN
           ERROR "�g�~�饲����J!!"  ATTRIBUTE (RED)
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

    -- ���_�@�~ --
    IF INT_FLAG=TRUE THEN
       LET f_rcode=TRUE 
       RETURN f_rcode
    END IF
    RETURN f_rcode
   
END FUNCTION    --- psc02m_input ---
------------------------------------------------------------------------------
--  �禡�W��: qry_input
--  �@    ��: merlin
--  ��    ��: 
--  �B�z���n: �٥��d�O�@�~_�e����J�]�z�ߡA���ڬd�ߡ^
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION qry_input()
    DEFINE f_right_or_fault     INTEGER   -- ����ˬd t or f --
          ,f_formated_date      CHAR(9)   -- ����榡�� 999/99/99 --
          ,f_pscb_cnt           INTEGER   -- ���� perpare ���O���O��i���� --
          ,f_rcode              INTEGER

    LET f_rcode       =FALSE            
    LET INT_FLAG      =FALSE
    LET f_pscb_cnt    =0

    MESSAGE " END(F7):�����@�~"

    INPUT p_data_s1.policy_no
    FROM  policy_no
    ATTRIBUTE(BLUE ,REVERSE ,UNDERLINE)

    AFTER FIELD policy_no
        IF p_data_s1.policy_no=" "            OR
           p_data_s1.policy_no="            " THEN
           ERROR "�O�渹�X������J!!"    ATTRIBUTE (RED)
           NEXT FIELD policy_no
        END IF

    ON KEY (F7)
       LET INT_FLAG=TRUE
       EXIT INPUT
    AFTER INPUT

       IF INT_FLAG=TRUE THEN
          EXIT INPUT
       END IF

       -- ����ˬd --
       -- g_polf.����� --
       SELECT *
       INTO   g_polf.*
       FROM   polf
       WHERE  policy_no=p_data_s1.policy_no

       IF STATUS=NOTFOUND THEN
          ERROR "�L���i�O��!!"   ATTRIBUTE (RED)
          NEXT FIELD policy_no
       END IF

    END INPUT
       MESSAGE " "      

    -- ���_�@�~ --
    IF INT_FLAG=TRUE THEN
       LET f_rcode=TRUE 
       RETURN f_rcode
    END IF
     RETURN f_rcode
   
END FUNCTION    --- qry_input ---

------------------------------------------------------------------------------
--  �禡�W��: psc02m_display
--  �@    ��: merlin
--  ��    ��: 
--  �B�z���n: �٥��d�O�@�~_�e�����
--  ���n�禡:
------------------------------------------------------------------------------
FUNCTION psc02m_display()
    
    DEFINE f_i                  INTEGER                 -- array �p�ƾ� 
          ,f_benf_cnt           INTEGER                 -- ���q�H�p�ƾ� 
          ,f_arr_cur            INTEGER                 -- ���q�H��J���p�� 
          ,f_scr_cur            INTEGER                 -- ���q�H�e�����p�� 
          ,f_disb_err           INTEGER                 -- ���q�H�Ȧ�b������ 

    DEFINE f_cp_anniv_date      LIKE pscb.cp_anniv_date      -- �g�~��   
          ,f_cp_sw              LIKE pscb.cp_sw              -- �٥����� 
          ,f_expired_sw         CHAR
          ,f_cp_remark_sw       LIKE pscb.cp_remark_sw       -- ���O���� 
          ,f_cp_pay_name        LIKE pscb.cp_pay_name        -- ����H�m�W 
          ,f_cp_pay_id          LIKE pscb.cp_pay_id          -- ����HID 
          ,f_pay_dept_code      LIKE pscb.dept_code          -- ��������q 

    DEFINE f_cp_notice_formtype LIKE pscr.cp_notice_formtype -- �q���Ѯ榡
          ,f_chk_sw             LIKE pscr.cp_chk_sw          -- �䲼���I�{����
          ,f_chk_date           LIKE pscr.cp_chk_date        -- ���I�{�䲼MAX��

    DEFINE f_arr                INTEGER
          ,f_dtl_real_amt       INTEGER
          ,f_dtl_cp_ann         LIKE pscb.cp_anniv_date
          ,f_client_ident       LIKE colf.client_ident       -- ���Y�H�ѧO�X
          ,f_applicant_id       LIKE clnt.client_id          -- �n�O�H�Ҹ�
          ,f_insured_id         LIKE clnt.client_id          -- �Q�O�I�H�Ҹ�
          ,f_app_name           LIKE clnt.names              -- �n�O�H�m�W
          ,f_insured_name       LIKE clnt.names              -- �Q�O�I�H�m�W
          ,f_agent_code         LIKE agnt.agent_code         -- �~�ȭ��N�X
          ,f_dept_code          LIKE dept.dept_code          -- �����N�X
          ,f_relation           CHAR(1)
          ,f_benf_client_id     CHAR(10)

    MESSAGE "END(F7):�����@�~"

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

     -- �P�_����/�ͦs���q�H
        IF p_data_s1.cp_anniv_date >= g_polf.expired_date THEN
           LET f_expired_sw = "Y"
           LET f_relation   = "M"
        ELSE
           LET f_expired_sw = "N"
           LET f_relation   = "L"
        END IF

     -- �e���@���ĤG����� --
        LET  p_data_s3.po_sts_code    = g_polf.po_sts_code
        LET  p_data_s3.method         = g_polf.method
        LET  p_data_s3.po_issue_date  = g_polf.po_issue_date
        LET  p_data_s3.paid_to_date   = g_polf.paid_to_date

     -- �~�ȭ�,�P��~��� --
        SELECT agent_code
        INTO   f_agent_code
        FROM   poag
        WHERE  policy_no=p_data_s1.policy_no
        AND    relation ="S"

        SELECT dept_code
        INTO   f_dept_code
        FROM   agnt
        WHERE  agent_code=f_agent_code  

     -- �n�O�HID,�m�W --
        CALL getNames(p_data_s1.policy_no,'O1')
             RETURNING p_applicant_id,p_applicant_name

     -- ���I�{�䲼��� --       
        SELECT cp_chk_date,coverage_no
        INTO   f_chk_date,p_coverage_no
        FROM   pscp
        WHERE  policy_no=p_policy_no
        AND    cp_anniv_date=p_data_s1.cp_anniv_date
        
     -- �Q�O�HID,�m�W --
        SELECT client_ident
        INTO   f_client_ident
        FROM   colf
        WHERE  policy_no=p_policy_no
        AND    coverage_no=p_coverage_no

     -- �Q�O�I�H�m�W --
        SELECT client_id
        INTO   f_insured_id
        FROM   pocl
        WHERE  policy_no=p_policy_no
        AND    client_ident=f_client_ident

        SELECT names
        INTO   f_insured_name
        FROM   clnt
        WHERE  client_id=f_insured_id

     -- �~�ȭ��m�W�A��~��� --
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
        
    -- �e���@���ĤG����� --
    -- �n�P�_�����Υͦs ���� relation="M" ,�ͦs relation="L" 
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

    -- ��ܨ��o�����(�e���@�ĤT����) --
       DISPLAY BY NAME p_data_s3.*  ATTRIBUTE (YELLOW)

    -- ��ܨ��o�����(�e���@�ĤG����) --
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

    -- ��ܨ��o�����(�e���@�Ĥ@����) --
    
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
--  �禡�W��: psc02m_check()
--  �@    ��: merlin
--  ��    ��: 
--  �B�z���n: �٥��d�O�@�~_�������P�_
--  ���n�禡:
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
        -- �P�_�O�檬�A�X�z�� --
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
           ERROR "�O�檬�A����!!"
           LET g_coupon_errmsg="�O�檬�A����!!" CLIPPED,p_data_s3.po_sts_code
           ERROR "erorr:",g_coupon_errmsg ATTRIBUTE(RED,UNDERLINE) 
           LET f_rcode=1
           EXIT WHILE
        END IF

        -- �P�_PTD �O�_�j���٥��g�~ --
        IF p_data_s3.po_sts_code != "43"  AND
           p_data_s3.po_sts_code != "44"  AND
           p_data_s3.po_sts_code != "46"  AND 
           p_data_s3.po_sts_code != "62"  THEN
           IF p_data_s3.paid_to_date < p_data_s1.cp_anniv_date THEN
              LET g_coupon_errmsg="ú�O�פ���٥��g�~��!!" CLIPPED
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

        -- �P�_����覡 --
        IF p_pscb.cp_disb_type != "1" THEN
           LET g_coupon_errmsg=" �٥�����覡���O�d�O���!!" CLIPPED
                               ,p_pscb.cp_disb_type     
           ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
           LET f_rcode=1
           EXIT WHILE
        END IF

        -- �������O�_�j��g�~�� --
        LET f_tran_date=GetDate(today)  
        IF f_tran_date < p_data_s1.cp_anniv_date THEN
           LET g_coupon_errmsg="�������p���٥��g�~��!!" CLIPPED
                               ,f_tran_date,p_data_s1.cp_anniv_date     
           ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
           LET f_rcode=1
           EXIT WHILE
        END IF

        -- ��������q�P�_ --
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
           LET g_coupon_errmsg="�ϥΪ̹��������q�䤣��!!" CLIPPED
                               ,f_dept_code
           ERROR "error:",g_coupon_errmsg ATTRIBUTE(RED,UNDERLINE)
           LET f_rcode=1
           EXIT WHILE
        END IF

        IF LENGTH(f_dept_belong CLIPPED) =0 THEN
           LET g_coupon_errmsg="�ϥΪ̩��ݤ����q�䤣��!!" CLIPPED
                               ,f_dept_code
           ERROR "error:",g_coupon_errmsg ATTRIBUTE(RED,UNDERLINE)
           LET f_rcode=1
           EXIT WHILE
        END IF
  
        IF f_dept_belong != p_data_s1.dept_code THEN
           LET g_coupon_errmsg="��������q�P�@�~�����q����!!" CLIPPED
                               ,f_dept_belong,p_data_s1.dept_code
           ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
           LET f_rcode=1
           EXIT WHILE
        END IF

        -- �O�_�����I�{�䲼 --
        CALL psc34s00(p_data_s1.policy_no,p_data_s1.cp_anniv_date,f_tran_date)  
             RETURNING f_rcode  
             IF f_rcode !=0 THEN
                LET g_coupon_errmsg="call psc03s00 error" 
                ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
                LET f_rcode=1
                EXIT WHILE
             END IF     

             IF g_coupon.g_chk_sw="N" THEN
                LET g_coupon_errmsg="�����I�{�䲼" 
                ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
                LET f_rcode=1
                EXIT WHILE
             END IF

        -- ������B�P�R�P���B�۲ŧ_ --
        LET   f_cp_pay_amt=g_pscp.cp_pay_amt*(-1)
        
        SELECT sum(journal_amount) 
        INTO   f_journal_amt            
        FROM   glrc
        WHERE  acct_no="28250019"
        AND    recn_code=p_data_s1.policy_no

        IF  f_journal_amt != f_cp_pay_amt       THEN
            LET g_coupon_errmsg="�R�P���B�P������B���šA�Ьd�߱b�ȧ@�~!!"
                                ,f_journal_amt,f_cp_pay_amt
            ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
            LET f_rcode=1
            EXIT WHILE
        END IF

        -- �O�_���z�߸�� --         
        CALL qryClaim(p_data_s1.policy_no,2,2)  

        -- �O�_�������z�@�~ --
        CALL getAcceptNo("9","")
             RETURNING  f_receive_no    

        IF  LENGTH(f_receive_no) =0     THEN
            LET g_coupon_errmsg="�|���������z�@�~!!"                            
            ERROR "error:", g_coupon_errmsg  ATTRIBUTE(RED,UNDERLINE) 
            LET f_rcode=1
            EXIT WHILE
        ELSE
            ERROR f_receive_no  ATTRIBUTE(RED,UNDERLINE) 
        END IF  

       -- �O�_�����`���� --     
       SELECT count(*)
       INTO   f_count
       FROM   psce
       WHERE  policy_no     = p_data_s1.policy_no
       AND    cp_anniv_date = p_data_s1.cp_anniv_date

       IF f_count !=0  THEN
          ERROR "�������`���νЬd���A�@�~!!" 
       END IF

      PROMPT '�O�_�ŦX�������[y/n]' ATTRIBUTE(RED,UNDERLINE)
      FOR CHAR f_ans_sw1
      IF UPSHIFT(f_ans_sw1) = 'Y' THEN
         PROMPT '�Ъ`�N!!�ͦs������f�d���̵��I���B�i��F���vñ��[y/n]' ATTRIBUTE(RED,UNDERLINE)
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
                  ERROR '���\!!' ATTRIBUTE(RED,UNDERLINE)
               ELSE
                  ERROR '�C�L�f�d���ѡA�ХѦC�L�@�~�ɦL'ATTRIBUTE(RED,UNDERLINE)
               END IF
            ELSE
               ERROR "erorr:",g_coupon_errmsg
            END IF  
         END IF
         IF UPSHIFT(f_ans_sw) = 'N' THEN
            ERROR '���}����@�~!!' ATTRIBUTE(RED,UNDERLINE)
            LET f_rcode=0
            EXIT WHILE
         END IF

      END IF
      IF UPSHIFT(f_ans_sw1) = 'N' THEN
         ERROR '���}����@�~!!' ATTRIBUTE(RED,UNDERLINE)
         LET f_rcode=0
         EXIT WHILE
      END IF
END WHILE
RETURN f_rcode
END FUNCTION  --- psc02m_check ---
------------------------------------------------------------------------------
--  �禡�W��: psc02m_report1()
--  �@    ��: merlin
--  ��    ��: 
--  �B�z���n: �٥��d�O�@�~_�C�L�f�d��
--  ���n�禡:
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
         process_date             CHAR(9)                       -- �@�~��
        ,applicant_name           LIKE clnt.names               -- �n�O�H�m�W
        ,insured_name             LIKE clnt.names               -- �Q�O�I�H�m�W
        ,po_sts_code              LIKE polf.po_sts_code         -- �O�檬�A
        ,modx                     CHAR(6)                       -- ú�k
        ,plan_desc                LIKE pldf.plan_desc           -- �٥��I��
        ,policy_no                LIKE pscp.policy_no           -- �O�渹�X
        ,face_amt                 INTEGER                       -- �O�I���B
        ,dept_name                LIKE dept.dept_name           -- ��~�B�N�X
        ,agent_name               LIKE clnt.names               -- �~�ȭ��N�X
        ,po_issue_date            LIKE pscp.po_issue_date       -- �ͮĤ�
        ,paid_to_date             LIKE pscp.paid_to_date        -- ú�O�פ�
        ,cp_pay_form_type         LIKE pscp.cp_pay_form_type    -- ���I�榡
        ,cp_anniv_date            LIKE pscp.cp_anniv_date       -- �g�~��
        ,div_option               LIKE pscp.div_option          -- ���Q����v
        ,cp_amt                   INTEGER                       -- ���I���B
        ,div_amt                  INTEGER                       -- �O����Q
        ,prem_susp                INTEGER                       -- ��ú
        ,minus_prem_susp          INTEGER                       -- ��ú
        ,apl_int                  INTEGER                       -- �۰ʹ�ú�Q��
        ,apl_amt                  INTEGER                       -- �۰ʹ�ú����
        ,loan_int                 INTEGER                       -- �ɴڧQ��
        ,loan_amt                 INTEGER                       -- �ɴڥ���
        ,cp_pay_amt               INTEGER                       -- �����I�b�B
        ,rtn_rece_no              CHAR(10)                      -- �ٴڦ��ڸ��X 
        ,cp_pay_name              CHAR(12)                      -- ����H�m�W
        ,cp_pay_id                LIKE pscb.cp_pay_id           -- ����HID
        ,pay_dept_code            LIKE pscb.dept_code           -- ��������q
        ,benf_cnt                 INTEGER
        ,plan_abbr_code           LIKE pldf.plan_abbr_code        --�s�WFEL���d���I 096/02
        ,receive_no               LIKE apdt.po_chg_rece_no
        ,tel                      LIKE addr.tel_1
                   END RECORD  
    LET f_rpt_cnt=0
    PROMPT '�O�_�C�L�|�p�p[y/n]' ATTRIBUTE(RED,UNDERLINE)
    FOR CHAR f_ans_sw
    IF  UPSHIFT(f_ans_sw) = 'Y' THEN                        
        LET f_rpt_cnt=3
    ELSE
        LET f_rpt_cnt=2
    END IF      

    LET f_rpt_name_1    =ReportName("psc02m01")
    
     START REPORT psc02m_notice     TO f_rpt_name_1    
       INITIALIZE r.* TO NULL

        -- Ū��pscp�D�ɸ�� --     
        SELECT * 
        INTO   p_pscp.*
        FROM   pscp
        WHERE  policy_no     = f_policy_no
        AND    cp_anniv_date = f_cp_anniv_date
        
        -- �~�ȭ��m�W --
        SELECT names
        INTO   r.agent_name
        FROM   clnt
        WHERE  client_id=p_pscp.agent_code

        -- ��~��� --
        SELECT dept_name
        INTO   r.dept_name
        FROM   dept
        WHERE  dept_code=p_pscp.dept_code

        -- ú�k --
        CASE 
            WHEN g_polf.modx="0"  
                 LET r.modx       =" �~ ú"
            WHEN g_polf.modx="1"  
                 LET r.modx       =" �� ú"             
            WHEN g_polf.modx="3"  
                 LET r.modx       =" �u ú"             
            WHEN g_polf.modx="6"  
                 LET r.modx       ="�b�~ú"             
            WHEN g_polf.modx="12"
                 LET r.modx       =" �~ ú"             
             OTHERWISE          
                 LET r.modx       ="    ú"                      
        END CASE        

        LET r.policy_no         = f_policy_no                   -- �O�渹�X
        LET r.cp_anniv_date     = f_cp_anniv_date               -- �٥��g�~�� 
        LET r.process_date      = GetDate(TODAY)                -- �B�z���
        LET r.applicant_name    = p_data_s3.app_name            -- �n�O�H�m�W
        LET r.insured_name      = p_data_s3.insured_name        -- �Q�O�I�H�m�W
        LET r.po_sts_code       = p_data_s3.po_sts_code         -- �O�檬�A
        LET r.policy_no         = p_pscp.policy_no              -- �O�渹�X
        LET r.face_amt          = p_pscp.face_amt               -- �O�I���B
        LET r.po_issue_date     = p_pscp.po_issue_date          -- �ͮĤ�
        LET r.paid_to_date      = p_pscp.paid_to_date           -- ú�O�פ�
        LET r.cp_pay_form_type  = p_pscp.cp_pay_form_type       -- ���I�榡
        LET r.cp_anniv_date     = p_pscp.cp_anniv_date          -- �g�~��
        LET r.div_option        = p_pscp.div_option             -- ���Q����v
        LET r.cp_amt            = p_pscp.cp_amt                 -- ���I���B
        LET r.div_amt           = p_pscp.accumulated_div        -- �O����Q
                                + p_pscp.div_int_balance         
                                + p_pscp.div_int        
        LET r.prem_susp         = p_pscp.prem_susp              -- ��ú
        LET r.minus_prem_susp   = p_pscp.rtn_minus_premsusp    -- ��ú
        LET r.apl_int           = p_pscp.rtn_apl_int            -- �۰ʹ�ú�Q��
        LET r.apl_amt           = p_pscp.rtn_apl_amt            -- �۰ʹ�ú����
        LET r.loan_int          = p_pscp.rtn_loan_int           -- �ɴڧQ��
        LET r.loan_amt          = p_pscp.rtn_loan_amt           -- �ɴڥ���
        LET r.cp_pay_amt        = p_pscp.cp_pay_amt             -- �����I�b�B
        LET r.rtn_rece_no       = p_pscp.rtn_rece_no            -- �ٴڦ��ڸ��X
        LET r.cp_pay_name       = p_data_s1.cp_pay_name[1,12]   -- ����H�m�W
        LET r.cp_pay_id         = p_data_s1.cp_pay_id           -- ����HID
        LET r.pay_dept_code     = p_data_s1.dept_code           -- ��������q
        LET r.benf_cnt          = 0
        LET r.receive_no        = f_receive_no
        
    SELECT psc_desc
      INTO r.tel
      FROM psc4
     WHERE policy_no = f_policy_no
       AND cp_anniv_date = f_cp_anniv_date
       AND psc_type = '2'
    -- Ū���I�ػ��� --
    SELECT plan_desc,plan_abbr_code            
    INTO   r.plan_desc,r.plan_abbr_code
    FROM   pldf
    WHERE  plan_code  = p_pscp.plan_code
    AND    rate_scale = p_pscp.rate_scale

    -- ���q�H��ƪ�� --        
    FOR f_i=1 TO 6
        LET   benf_arr[f_i].names               = ""      -- ���q�Hname --
        LET   benf_arr[f_i].benf_ratio          = ""      -- ���q���   --
        LET   benf_arr[f_i].cp_real_payamt      = ""      -- �����B   --
        LET   benf_arr[f_i].disb_no             = ""      -- �I�ڸ��X   --
    END FOR

    LET f_i=0
    LET f_benf_cnt=0

    SELECT count(*)
    INTO   f_benf_cnt
    FROM   pscd
    WHERE  policy_no=r.policy_no
    AND    cp_anniv_date=r.cp_anniv_date

    LET r.benf_cnt=f_benf_cnt

    -- Ū�����q�H��� --        
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
--  �禡�W��: psc02m_notice()
--  �@    ��: merlin
--  ��    ��: 
--  �B�z���n: �٥��d�O�@�~_�f�d�椺�e
--  ���n�禡:
------------------------------------------------------------------------------
REPORT psc02m_notice(r,f_rpt_cnt)
    DEFINE r            RECORD
         process_date             CHAR(9) 
        ,applicant_name           LIKE clnt.names               -- �n�O�H�m�W
        ,insured_name             LIKE clnt.names               -- �Q�O�I�H�m�W
        ,po_sts_code              LIKE polf.po_sts_code         -- �O�檬�A
        ,modx                     CHAR(6)                       -- ú�k
        ,plan_desc                LIKE pldf.plan_desc           -- �٥��I��
        ,policy_no                LIKE pscp.policy_no           -- �O�渹�X
        ,face_amt                 INTEGER                       -- �O�I���B
        ,dept_name                LIKE dept.dept_name           -- ��~�B�N�X
        ,agent_name               LIKE clnt.names               -- �~�ȭ��N�X
        ,po_issue_date            LIKE pscp.po_issue_date       -- �ͮĤ�
        ,paid_to_date             LIKE pscp.paid_to_date        -- ú�O�פ�
        ,cp_pay_form_type         LIKE pscp.cp_pay_form_type    -- ���I�榡
        ,cp_anniv_date            LIKE pscp.cp_anniv_date       -- �g�~��
        ,div_option               LIKE pscp.div_option          -- ���Q����v
        ,cp_amt                   INTEGER                       -- ���I���B
        ,div_amt                  INTEGER                       -- �O����Q
        ,prem_susp                INTEGER                       -- ��ú
        ,minus_prem_susp          INTEGER                       -- ��ú
        ,apl_int                  INTEGER                       -- �۰ʹ�ú�Q��
        ,apl_amt                  INTEGER                       -- �۰ʹ�ú����
        ,loan_int                 INTEGER                       -- �ɴڧQ��
        ,loan_amt                 INTEGER                       -- �ɴڥ���
        ,cp_pay_amt               INTEGER                       -- �����I�b�B
        ,rtn_rece_no              CHAR(10)                      -- �ٴڦ��ڸ��X
        ,cp_pay_name              CHAR(12)                      -- ����H�m�W
        ,cp_pay_id                LIKE pscb.cp_pay_id           -- ����HID
        ,pay_dept_code            LIKE pscb.dept_code           -- ��������q
        ,benf_cnt                 INTEGER      
        ,plan_abbr_code           LIKE pldf.plan_abbr_code      --�s�WFEL���I 096/02 
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

        -- �ͦs����� -- 
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
               LET r_cpform_var[14,21] = '���d�ˬd' 
           ELSE 
               LET r_cpform_var[18,21] = '�ͦs'
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
                       PRINT COLUMN  1 ,"�x"
                            ,COLUMN  6 ,f_i                         
                                        USING "#"
                            ,COLUMN 12 ,benf_arr[f_i].names CLIPPED
                            ,COLUMN 28 ,benf_arr[f_i].benf_ratio
                                        USING "###.##"
                            ,COLUMN 40 ,benf_arr[f_i].cp_real_payamt 
                                        USING "###,###,###"     
                            ,COLUMN 62 ,benf_arr[f_i].disb_no
                            ,COLUMN 79 ,"�x"
                   END FOR
               END IF           
           END FOR
        END IF  

        -- ��������� --
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
                       PRINT COLUMN  1 ,"�x"
                            ,COLUMN  6 ,f_i                         
                                        USING "#"
                            ,COLUMN 12 ,benf_arr[f_i].names CLIPPED
                            ,COLUMN 28 ,benf_arr[f_i].benf_ratio
                                        USING "###.##"
                            ,COLUMN 40 ,benf_arr[f_i].cp_real_payamt 
                                        USING "###,###,###"     
                            ,COLUMN 62 ,benf_arr[f_i].disb_no
                            ,COLUMN 79 ,"�x"
                   END FOR
               END IF           
           END FOR
        END IF  

       
       LET  r_cpform_var[51,78] = "�D��ñ�֡G__________________"

       CASE 
       WHEN f_rpt_cnt=1 
            PRINT COLUMN  6, "����Hñ���G"
                        PRINT COLUMN  1, "  "               
            PRINT COLUMN 40, r_cpform_var[51,78]                
            SKIP 3 LINES
            PRINT COLUMN 32, "�Ĥ@�p �  ���q�k���p"
       WHEN f_rpt_cnt=2 
            PRINT COLUMN 40, r_cpform_var CLIPPED
            PRINT COLUMN  1, "  "               
            PRINT COLUMN  1, "  "
            SKIP 3 LINES
            PRINT COLUMN 32, "�ĤG�p�   �O���p"
       WHEN f_rpt_cnt=3
            PRINT COLUMN 40, r_cpform_var CLIPPED
            PRINT COLUMN  1, "  "               
            PRINT COLUMN 40, r_cpform_var[51,78]                
            SKIP 3 LINES
            PRINT COLUMN 32, "�ĤT�p�   �|�p�k���p"
       END CASE

       PRINT COLUMN 5, ap003_barcode( "PS2090" ) CLIPPED, 2 SPACES, "PS2090"
       SKIP 1 LINES
       PRINT COLUMN 5, ap003_barcode(r.receive_no) CLIPPED,2 SPACES,r.receive_no
       SKIP 1 LINES
       PRINT COLUMN 5, ap003_barcode(r.policy_no) CLIPPED,2 SPACES,r.policy_no

       SKIP TO TOP OF PAGE      

END REPORT  -- psc02m_notice --
------------------------------------------------------------------------------
--  �禡�W��: psc02m_init_array()
--  �@    ��: merlin
--  ��    ��: 
--  �B�z���n: �٥��d�O�@�~_�f�d��榡
--  ���n�禡:
------------------------------------------------------------------------------   
FUNCTION psc02m_init_array()
        DEFINE f_rcode  INTEGER

LET p_cpform_1[1] = " "
LET p_cpform_1[2] = "               �ͦs������f�d��"
LET p_cpform_1[3] = "                                                           [���K���]"
LET p_cpform_1[4] = "      �O�渹�X�G                              ��    �� �G                       "  
LET p_cpform_1[5] = "      �n �O �H�G                              ��~��� �G                       "  
LET p_cpform_1[6] = "      �Q�O�I�H�G                              �~ �� �� �G                       "  
LET p_cpform_1[7] = "                                              ���z���X �G                       "   
LET p_cpform_1[8] = "�z�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�{"
LET p_cpform_1[9] = "�x  �٥��I��  �G                              �O�I���B  �G   xxx,xxx,xxx��    �x"
LET p_cpform_1[10]= "�x  �����ͮĤ�G                                                              �x"
LET p_cpform_1[11]= "�x  �٥��g�~��G xxxxxxxxx    �O�檬�A�G xx   ���Q��ܡG x     ú�k�G xxxxxx  �x"
LET p_cpform_1[12]= "�u�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�t"
LET p_cpform_1[13]= "�x                                                                            �x"
LET p_cpform_1[14]= "�x                   �O�I��                         xxx,xxx,xxx��             �x"
LET p_cpform_1[15]= "�x                                                                            �x"
LET p_cpform_1[16]= "�x                                                                            �x"
LET p_cpform_1[17]= "�x                     �����G�e����ú               xxx,xxx,xxx��             �x"
LET p_cpform_1[18]= "�x                           �۰ʹ�ú�O�O�Q��       xxx,xxx,xxx��             �x"
LET p_cpform_1[19]= "�x                           �۰ʹ�ú�O�O����       xxx,xxx,xxx��             �x"
LET p_cpform_1[20]= "�x                           �O��ɴڧQ��           xxx,xxx,xxx��             �x"
LET p_cpform_1[21]= "�x                           �O��ɴڥ���           xxx,xxx,xxx��             �x"
LET p_cpform_1[22]= "�x                                                                            �x"
LET p_cpform_1[23]= "�x               �����I�b�B                         xxx,xxx,xxx��             �x"
LET p_cpform_1[24]= "�x                                                                            �x"
LET p_cpform_1[25]= "�x  �ٴڦ��ڸ��X�Gxxxxxxxxxx                                                  �x"
LET p_cpform_1[26]= "�x                                                                            �x"
LET p_cpform_1[27]= "�x  ����H�m�W�Gxxxxxxxxxxxx   ����HID�Gxxxxxxxxxx  ��������q�Gxxxxxx       �x"
LET p_cpform_1[28]= "�x  ����H�q�ܡGxxxxxxxxxxxx                                                  �x"
LET p_cpform_1[29]= "�x                                                                            �x"
LET p_cpform_1[30]= "�x  �Ǹ�   ���q�H�m�W      ��v�H         ���I���B           �I�ڸ��X         �x"
LET p_cpform_1[31]= "�x                                                                            �x"
LET p_cpform_1[32]= "�|�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�}"

LET p_cpform_2[1] = " "
LET p_cpform_2[2] = "               ����������f�d��"
LET p_cpform_2[3] = ""
LET p_cpform_2[4] = "      �O�渹�X�G                              ��    �� �G                       "  
LET p_cpform_2[5] = "      �n �O �H�G                              ��~��� �G                       "
LET p_cpform_2[6] = "      �Q�O�I�H�G                              �~ �� �� �G                       "
LET p_cpform_2[7] = "                                              ���z���X �G                       " 
LET p_cpform_2[8] = "�z�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�{"
LET p_cpform_2[9] = "�x  �٥��I��  �G                              �O�I���B  �G   xxx,xxx,xxx��    �x"
LET p_cpform_2[10]= "�x  �����ͮĤ�G                                                              �x"
LET p_cpform_2[11]= "�x  �٥��g�~��G xxxxxxxxx    �O�檬�A�G xx   ���Q��ܡG x     ú�k�G xxxxxx  �x"
LET p_cpform_2[12]= "�u�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�t"
LET p_cpform_2[13]= "�x                                                                            �x"
LET p_cpform_2[14]= "�x               �����O�I��                         xxx,xxx,xxx��             �x"
LET p_cpform_2[15]= "�x                       �[�G�O����Q               xxx,xxx,xxx��             �x"
LET p_cpform_2[16]= "�x                           ��ú                   xxx,xxx,xxx��             �x"
LET p_cpform_2[17]= "�x                     �����G�e����ú               xxx,xxx,xxx��             �x"
LET p_cpform_2[18]= "�x                           �۰ʹ�ú�O�O�Q��       xxx,xxx,xxx��             �x"
LET p_cpform_2[19]= "�x                           �۰ʹ�ú�O�O����       xxx,xxx,xxx��             �x"
LET p_cpform_2[20]= "�x                           �O��ɴڧQ��           xxx,xxx,xxx��             �x"
LET p_cpform_2[21]= "�x                           �O��ɴڥ���           xxx,xxx,xxx��             �x"
LET p_cpform_2[22]= "�x                                                                            �x"
LET p_cpform_2[23]= "�x               �����I�b�B                         xxx,xxx,xxx��             �x"
LET p_cpform_2[24]= "�x                                                                            �x"
LET p_cpform_2[25]= "�x  �ٴڦ��ڸ��X�Gxxxxxxxxxx                                                  �x"
LET p_cpform_2[26]= "�x                                                                            �x"
LET p_cpform_2[27]= "�x  ����H�m�W�Gxxxxxxxxxxxx   ����HID�Gxxxxxxxxxx  ��������q�Gxxxxxx       �x"
LET p_cpform_2[28]= "�x  ����H�q�ܡGxxxxxxxxxxxx                                                  �x"
LET p_cpform_2[29]= "�x                                                                            �x"
LET p_cpform_2[30]= "�x  �Ǹ�   ���q�H�m�W      ��v�H         ���I���B           �I�ڸ��X         �x"
LET p_cpform_2[31]= "�x                                                                            �x"
LET p_cpform_2[32]= "�|�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�w�}"

LET f_rcode=1
RETURN f_rcode
END FUNCTION  -- psc02m_init_array --
------------------------------------------------------------------------------
--  �禡�W��: psc02m_inoput1()
--  �@    ��: merlin
--  ��    ��: 
--  �B�z���n: �٥��d�O�@�~_��������J
--  ���n�禡:
------------------------------------------------------------------------------  
FUNCTION psc02m_input1()
    DEFINE f_right_or_fault     INTEGER   -- ����ˬd t or f --
          ,f_formated_date      CHAR(9)   -- ����榡�� 999/99/99 --
          ,f_pscb_cnt           INTEGER   -- ���� perpare ���O���O��i���� --
          ,f_rcode              INTEGER
        
    DEFINE f_dept_code          LIKE pscb.dept_code
          ,f_start_date         CHAR(9)

    LET f_rcode         = 0             
    LET INT_FLAG        = FALSE
    LET f_pscb_cnt      = 0
    LET f_dept_code     = " "
    LET f_start_date    = " "
        
    MESSAGE " END(F7):�����@�~"

    OPEN WINDOW psc02m02   AT 10,11 WITH FORM "psc02m02"        
    ATTRIBUTE(BLUE, REVERSE, UNDERLINE, FORM LINE FIRST)

    INPUT f_dept_code,f_start_date
    FROM  dept_code,start_date   ATTRIBUTE(BLUE ,REVERSE ,UNDERLINE)

    AFTER FIELD dept_code
       IF f_dept_code=" "             OR
          f_dept_code="            "  THEN
          ERROR "����a�I������J!!"  ATTRIBUTE (RED)
          NEXT FIELD dept_code
       END IF

    AFTER FIELD start_date
       CALL CheckDate(f_start_date)
            RETURNING f_right_or_fault,f_formated_date
       IF f_right_or_fault = false THEN
          ERROR "�����J���~!!"   ATTRIBUTE (RED)
          NEXT FIELD start_date
       END IF

       IF f_start_date="         " OR
          f_start_date=" "         THEN
          ERROR "���������J!!"   ATTRIBUTE (RED)
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
    -- ���_�@�~ --
    IF INT_FLAG=TRUE THEN
       LET f_rcode=1
       RETURN f_rcode,f_dept_code,f_start_date
    END IF

    RETURN f_rcode ,f_dept_code,f_start_date

END FUNCTION    --- psc02m_input1 ---
------------------------------------------------------------------------------
--  �禡�W��: psc02m_report2()
--  �@    ��: merlin
--  ��    ��: 
--  �B�z���n: �٥��d�O�@�~_�w�������
--  ���n�禡:
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
         policy_no                LIKE pscb.policy_no           -- �O�渹�X
        ,cp_anniv_date            LIKE pscb.cp_anniv_date       -- �O��g�~��
        ,cp_sw                    LIKE pscb.cp_sw               -- �٥�����
        ,process_user             LIKE pscb.process_user        -- �ӿ�H
        ,change_date              LIKE pscb.change_date         -- �@�b��
        ,cp_pay_name              LIKE pscb.cp_pay_name         -- ����H�m�W
        ,dept_code                LIKE pscb.dept_code           -- ��������q
        ,cp_disb_type             LIKE pscb.cp_disb_type        -- �٥����I�覡
        ,agent_code               LIKE pscp.agent_code          -- �~�ȭ��N�X
        ,cp_amt  	          INTEGER                       -- �����I���B
        ,cp_pay_amt               INTEGER                       -- �����I�b�B
        ,cp_pay_form_type         LIKE pscp.cp_pay_form_type    -- �٥����I�Ѯ榡
                    END RECORD  

        LET r1.policy_no                = " "           -- �O�渹�X
        LET r1.cp_anniv_date            = " "           -- �٥��g�~��
        LET r1.cp_sw                    = " "           -- �٥�����
        LET r1.process_user             = " "           -- �ӿ�H
        LET r1.change_date              = " "           -- �@�b��
        LET r1.agent_code               = " "           -- �~�ȭ��N�X
        LET r1.cp_pay_amt               = 0             -- �����I�b�B
        LET r1.cp_pay_name              = " "           -- ����H�m�W
        LET r1.dept_code                = " "           -- ��������q
        LET r1.cp_pay_form_type         = ""            -- �٥����I�Ѯ榡
        
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
           ERROR "�L�w������"         
        ELSE
           -- Ū������a�I�W�� --
           SELECT  dept_name
           INTO    f_dept_name
           FROM    dept
           WHERE   dept_code=f_dept_code
                
           -- Ū���H������ --
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
           -- �~�ȭ��m�W --
           SELECT names
           INTO   f_agent_name
           FROM   clnt
           WHERE  client_id=r1.agent_code

           -- �P�_����  
           CASE
                WHEN r1.cp_pay_form_type = "5"
                     LET f_expired_sw    = "�ͦs"
                WHEN r1.cp_pay_form_type = "5.1"
                     LET f_expired_sw    = "�ͦs"
                WHEN r1.cp_pay_form_type = "6"
                     LET f_expired_sw    = "����"
                WHEN r1.cp_pay_form_type = "6.1"
                     LET f_expired_sw    = "����"
                WHEN r1.cp_pay_form_type = "6.2"
                     LET f_expired_sw    = "����"
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
--  �禡�W��: psc02m_notice1()
--  �@    ��: merlin
--  ��    ��: 
--  �B�z���n: �٥��d�O�@�~_�w�����������e
--  ���n�禡:
------------------------------------------------------------------------------
REPORT psc02m_notice1(r1,f_start_date,f_dept_code
                     ,f_agent_name,f_dept_name,f_expired_sw)
    DEFINE r1           RECORD
         policy_no                LIKE pscb.policy_no           -- �O�渹�X
        ,cp_anniv_date            LIKE pscb.cp_anniv_date
        ,cp_sw                    LIKE pscb.cp_sw               -- �٥�����
        ,process_user             LIKE pscb.process_user        -- �ӿ�H
        ,change_date              LIKE pscb.change_date         -- �@�b��
        ,cp_pay_name              LIKE pscb.cp_pay_name         -- ����H�m�W
        ,dept_code                LIKE pscb.dept_code           -- ��������q
        ,cp_disb_type             LIKE pscb.cp_disb_type
        ,agent_code               LIKE pscp.agent_code          -- �~�ȭ��N�X
        ,cp_amt                   INTEGER                       -- �����I���B
        ,cp_pay_amt               INTEGER                       -- �����I�b�B
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
             PRINT COLUMN  17,"�� �� �d �O �@ �~ __ �� �� �� �w �� �� �� ��"
             PRINT COLUMN  64,p_name CLIPPED
             SKIP 1 LINES                       
             PRINT COLUMN   1, "�L�����G ", GetDate(TODAY),
                   COLUMN  64, "����N�X�G ","PSC02M"
             PRINT COLUMN   1, "�@�~����G ",f_start_date,
                   COLUMN  22, "����a�I�G ",f_dept_name CLIPPED ,f_dept_code,
                   COLUMN  64, "�� "   , PAGENO USING "####"," ��"
             PRINT SetLine( "-",80 ) CLIPPED
             PRINT COLUMN   2, "�O�渹�X",   
                   COLUMN  15, "�٥��g�~��",		
                   COLUMN  28, "������B",
                   COLUMN  39, "�����B",
                   COLUMN  48, "����H",
                   COLUMN  57, "�~�ȭ�",
                   COLUMN  66, "�ӿ�H",
                   COLUMN  75, "���A"
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
      PRINT COLUMN  1,"��ơG",r_total_cnt USING "###,##&","��",
            COLUMN 18,"������B�X�p�G",r_sum_1 USING "###,###,##&" ," ��",
            COLUMN 50,"�����B�X�p�G",r_sum_2 USING "###,###,##&" ," ��"    
END REPORT
{
 �O�渹�X     �٥��g�~��   ������B   �����B ����H   �~�ȭ�   �ӿ�H   ���A
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
            PROMPT "�нT�{�O��O�_���FATCA�n����!!Y/N" FOR CHAR f_ans
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
