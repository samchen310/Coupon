-------------------------------------------------------------------------------
--  函式名稱: pc961p0.4gl
--  作    者: jano
--  日    期: 90-08-10
--  處理概要: 抵繳他張保單資料相關處理
--            編輯/查詢/存檔等均透過 pc961_process() 完成，傳入參數為一 record，
--            包括還本保單、週年日、處理碼、他張保單及過帳狀態異動時所需之資料；
--            程式依據處理碼以決定要處理的事項。
--            目前他張保單最多可輸入10筆。
--  說    明: 處理碼 -- "EDIT"(編輯): 新增或修改資料時, 必須為未過帳狀態
--                      "SAVE"(存檔): 資料編輯後確定存檔時, 必須為未過帳狀態
--                      "DELE"(刪除): 要將整批資料刪除時, 必須為未過帳狀態
--                      "PASS"(過帳): 過還本帳時, 必須為未過帳狀態
--                      "QURY"(查詢): 查詢資料時
--  修    改: 102/07/31 cmwang 新增還本保單受益人 = 抵繳保單受益人條件(L或M)
--                             新增 pc961_chk_id_2
-------------------------------------------------------------------------------
DATABASE life

GLOBALS "../def/common.4gl"

-------------------------------------------------------------------------------
--  define program variables
-------------------------------------------------------------------------------
    DEFINE p_pcpm       RECORD LIKE pcpm.*
    DEFINE p_pcpc       RECORD LIKE pcpc.*
    DEFINE p_data       RECORD
                            policy_no           LIKE pcpm.policy_no
                          , cp_anniv_date       LIKE pcpm.cp_anniv_date
                          , prss_code           CHAR(4)
                          , tran_date           LIKE pcpm.tran_date
                          , cp_pay_amt          LIKE pcpm.cp_pay_amt
                          , col_policy_no_1     LIKE pcpc.col_policy_no
                          , col_policy_no_2     LIKE pcpc.col_policy_no
                          , col_policy_no_3     LIKE pcpc.col_policy_no
                          , col_policy_no_4     LIKE pcpc.col_policy_no
                          , col_policy_no_5     LIKE pcpc.col_policy_no
                          , col_policy_no_6     LIKE pcpc.col_policy_no
                          , col_policy_no_7     LIKE pcpc.col_policy_no
                          , col_policy_no_8     LIKE pcpc.col_policy_no
                          , col_policy_no_9     LIKE pcpc.col_policy_no
                          , col_policy_no_10    LIKE pcpc.col_policy_no
                        END RECORD
    DEFINE p_man        RECORD
                            policy_no           LIKE pcpm.policy_no
                          , cp_anniv_date       LIKE pcpm.cp_anniv_date
                          , sts_code            LIKE pcpm.pcpm_sts_code
                        END RECORD
    DEFINE p_ary        ARRAY[ 10 ] OF RECORD
                            col_policy_no       LIKE pcpc.col_policy_no
                          , o1_name             CHAR(10)      --101/09 yirong新增
                          , i1_name             CHAR(10)      --101/09 yirong新增
                          , po_sts_code         LIKE polf.po_sts_code
                          , method              LIKE polf.method
                          , paid_to_date        LIKE polf.paid_to_date
                        END RECORD
    DEFINE p_ary1        ARRAY[ 10 ] OF RECORD
                         o1_id               CHAR(10)
                          , i1_id               CHAR(10)
                        END RECORD

    DEFINE p_set_cnt    SMALLINT
    DEFINE p_arr_cnt    SMALLINT
    DEFINE p_x, p_y     SMALLINT
    DEFINE p_error      CHAR(78)
    DEFINE p_today      CHAR(9)
    DEFINE p_cross      CHAR(1)  -- 避免不正常使用之旗標
    DEFINE p_benf_relation CHAR(1)   ---101/09 檢核受益人資格


------------------------------------------------------------------------------
--  函式名稱: pc961_process()
--  處理概要: 抵繳他張保單資料相關處理
--  輸入參數: 還本保單資料
--  輸出參數: TRUE/FALSE, 錯誤訊息, 還本保單資料
------------------------------------------------------------------------------
FUNCTION pc961_process ( f_data,f_benf_relation )
    DEFINE f_data       RECORD
                            policy_no           LIKE pcpm.policy_no
                          , cp_anniv_date       LIKE pcpm.cp_anniv_date
                          , prss_code           CHAR(4)  -- 處理碼
                          , tran_date           LIKE pcpm.tran_date
                          , cp_pay_amt          LIKE pcpm.cp_pay_amt
                          , col_policy_no_1     LIKE pcpc.col_policy_no
                          , col_policy_no_2     LIKE pcpc.col_policy_no
                          , col_policy_no_3     LIKE pcpc.col_policy_no
                          , col_policy_no_4     LIKE pcpc.col_policy_no
                          , col_policy_no_5     LIKE pcpc.col_policy_no
                          , col_policy_no_6     LIKE pcpc.col_policy_no
                          , col_policy_no_7     LIKE pcpc.col_policy_no
                          , col_policy_no_8     LIKE pcpc.col_policy_no
                          , col_policy_no_9     LIKE pcpc.col_policy_no
                          , col_policy_no_10    LIKE pcpc.col_policy_no
                        END RECORD
    DEFINE f_sts_code   LIKE pcpm.pcpm_sts_code
    DEFINE i            SMALLINT
    DEFINE f_arr, f_scr SMALLINT
    DEFINE f_benf_relation CHAR(1)   ---101/09 檢核受益人資格

    -- 系統值設定
    LET p_today   = GetDate( TODAY )
    LET p_set_cnt = 10
    LET p_x       = 8
    LET p_y       = 20

    -- 設定初值
    LET p_error = NULL
    LET p_cross = "0"
    INITIALIZE p_man.* TO NULL
    INITIALIZE p_ary   TO NULL
    INITIALIZE p_ary1   TO NULL
    LET p_arr_cnt = 0
    LET p_data.* = f_data.*
    LET p_benf_relation = f_benf_relation

    -- 檢核是否傳入空值
    IF f_data.policy_no IS NULL THEN
        LET p_error = "請給予還本保單號碼。"
        RETURN FALSE, p_error, f_data.*
    END IF
    IF f_data.cp_anniv_date IS NULL THEN
        LET p_error = "請給予還本保單週年日。"
        RETURN FALSE, p_error, f_data.*
    END IF
    IF f_data.prss_code IS NULL THEN
        LET p_error = "請給予欲處理狀態。"
        RETURN FALSE, p_error, f_data.*
    END IF

    -- 取得還本保單資料
    SELECT policy_no, cp_anniv_date, pcpm_sts_code
      INTO p_data.policy_no, p_data.cp_anniv_date, f_sts_code
      FROM pcpm
     WHERE policy_no = f_data.policy_no
       AND cp_anniv_date = f_data.cp_anniv_date

    IF STATUS = NOTFOUND THEN
        LET p_data.policy_no = f_data.policy_no
        LET p_data.cp_anniv_date = f_data.cp_anniv_date
        LET f_sts_code = NULL
    END IF

    -- 設定資料/欄位值
    LET p_data.prss_code    = f_data.prss_code
    LET p_man.policy_no     = p_data.policy_no
    LET p_man.cp_anniv_date = p_data.cp_anniv_date
    LET p_man.sts_code      = f_sts_code

    -- 檢核是否已過帳
    IF p_man.sts_code = "1" AND p_data.prss_code != "QURY" THEN
        LET p_error = "還本保單已作帳，無法修改資料。"
        RETURN FALSE, p_error, f_data.*
    END IF

    CASE
        WHEN p_data.prss_code = "EDIT"
            LET INT_FLAG = FALSE
            IF NOT pc961_editor() THEN
                RETURN FALSE, p_error, f_data.*
            END IF
            IF INT_FLAG THEN
                LET INT_FLAG = FALSE
                RETURN TRUE, p_error, f_data.*
            END IF

        WHEN p_data.prss_code = "SAVE"
          OR p_data.prss_code = "DELE"
          OR p_data.prss_code = "PASS"
            IF NOT pc961_saving() THEN
                RETURN FALSE, p_error, f_data.*
            END IF

        WHEN p_data.prss_code = "QURY"
            CALL pc961_query()

        OTHERWISE
            LET p_error = "處理代碼未定義。"
            RETURN FALSE, p_error, f_data.*

    END CASE

    RETURN TRUE, p_error, p_data.*

END FUNCTION   -- pc961_process --

------------------------------------------------------------------------------
--  函式名稱: pc961_select()
--  處理概要: 取得抵繳他張保單資料
--  輸入參數: 還本保單號碼, 還本週年日
--  輸出參數: TRUE/FALSE
------------------------------------------------------------------------------
FUNCTION pc961_select ( f_policy_no, f_ann_date )
    DEFINE f_policy_no  LIKE pcpm.policy_no
    DEFINE f_ann_date   LIKE pcpm.cp_anniv_date
    DEFINE f_seq        LIKE pcpc.pcpc_seq
    DEFINE f_no         LIKE pcpc.col_policy_no
    DEFINE i, f_ok      SMALLINT

    -- 設定初值
    LET p_error = NULL

    -- 取得抵繳保單資料
    DECLARE pc961_select_cur CURSOR FOR
     SELECT pcpc_seq, col_policy_no
       FROM pcpc
      WHERE policy_no = f_policy_no
        AND cp_anniv_date = f_ann_date
      ORDER BY pcpc_seq

    LET i = 0
    FOREACH pc961_select_cur INTO f_seq, f_no
        IF LENGTH( f_no CLIPPED ) = 0 THEN
            CONTINUE FOREACH
        END IF
        LET i = i + 1
        IF i > p_set_cnt THEN
            LET p_error = "資料超出範圍，請洽資訊部。"
            EXIT FOREACH
        END IF
        LET p_ary[ i ].col_policy_no = f_no
        CALL pc961_get_polf ( i ) RETURNING f_ok
    END FOREACH

    LET p_arr_cnt = i

    IF p_error IS NOT NULL THEN
        RETURN FALSE
    END IF

    RETURN TRUE

END FUNCTION   -- pc961_select --

------------------------------------------------------------------------------
--  函式名稱: pc961_trn_data()
--  處理概要: 將 record 轉成 array
--  輸入參數: 
--  輸出參數:
------------------------------------------------------------------------------
FUNCTION pc961_trn_data()

    LET p_ary[ 1 ].col_policy_no = p_data.col_policy_no_1
    LET p_ary[ 2 ].col_policy_no = p_data.col_policy_no_2
    LET p_ary[ 3 ].col_policy_no = p_data.col_policy_no_3
    LET p_ary[ 4 ].col_policy_no = p_data.col_policy_no_4
    LET p_ary[ 5 ].col_policy_no = p_data.col_policy_no_5
    LET p_ary[ 6 ].col_policy_no = p_data.col_policy_no_6
    LET p_ary[ 7 ].col_policy_no = p_data.col_policy_no_7
    LET p_ary[ 8 ].col_policy_no = p_data.col_policy_no_8
    LET p_ary[ 9 ].col_policy_no = p_data.col_policy_no_9
    LET p_ary[ 10 ].col_policy_no = p_data.col_policy_no_10
    LET p_arr_cnt = 10

END FUNCTION   -- pc961_trn_data --

------------------------------------------------------------------------------
--  函式名稱: pc961_editor()
--  處理概要: 編輯抵繳他張保單資料
--  輸入參數: (no)
--  輸出參數: TRUE/FALSE
------------------------------------------------------------------------------
FUNCTION pc961_editor()
    DEFINE i, f_ok      SMALLINT
    DEFINE f_arr, f_scr SMALLINT
    DEFINE f_po_sts_code LIKE polf.po_sts_code
    DEFINE f_expired_date LIKE polf.expired_date
    DEFINE f_ind CHAR(1)

    -- 設定初值
    LET p_error = NULL
    LET f_ind = '0'

    -- 取得明細資料
    IF LENGTH(p_data.col_policy_no_1 CLIPPED) = 0 THEN
        IF NOT pc961_select( p_data.policy_no, p_data.cp_anniv_date ) THEN
            ERROR " ",p_error CLIPPED," " ATTRIBUTE (RED,UNDERLINE)
            RETURN FALSE
        END IF
    ELSE
        CALL pc961_trn_data()
        FOR i = 1 TO p_arr_cnt
            CALL pc961_get_polf ( i ) RETURNING f_ok
        END FOR
    END IF
    SELECT po_sts_code,expired_date
      INTO f_po_sts_code,f_expired_date
      FROM polf
     WHERE policy_no =p_man.policy_no
    IF f_po_sts_code = '43' OR
       f_po_sts_code = '44' OR
       f_po_sts_code = '46' OR
       f_po_sts_code = '62' THEN
       LET f_ind = '1'
    ELSE
       IF p_man.cp_anniv_date >= f_expired_date THEN
          LET f_ind = '1'
       END IF
    END IF


    -- 開啟畫面
    OPEN WINDOW pc961p01 AT p_x,10 WITH FORM "pc961p01"
    ATTRIBUTE (GREEN, REVERSE, UNDERLINE, FORM LINE FIRST)

    DISPLAY BY NAME p_man.policy_no, p_man.cp_anniv_date

    CALL SET_COUNT( p_arr_cnt )
    LET INT_FLAG = FALSE
    INPUT ARRAY p_ary WITHOUT DEFAULTS FROM sa_961p01.*
        BEFORE ROW
            LET f_arr = ARR_CURR()
            LET f_scr = SCR_LINE()

        AFTER FIELD col_policy_no
            IF (p_ary[ f_arr ].col_policy_no IS NULL) AND
                FGL_LASTKEY() != FGL_KEYVAL("UP") AND
                FGL_LASTKEY() != FGL_KEYVAL("ACCEPT") THEN
                ERROR " 請輸入保單號碼。" ATTRIBUTE (RED,UNDERLINE)
                NEXT FIELD col_policy_no
            ELSE
                IF p_ary[ 1 ].col_policy_no IS NULL AND
                   f_ind = '1' THEN
                   ERROR "本保單已無需繳費,請輸入它張保單或放棄" ATTRIBUTE (RED,UNDERLINE)
                   NEXT FIELD col_policy_no
                END IF
            END IF
            IF p_ary[ f_arr ].col_policy_no IS NOT NULL THEN
                IF p_ary[ f_arr ].col_policy_no = p_man.policy_no THEN
                    ERROR " 此保單號碼為還本保單，不需輸入。"
                        ATTRIBUTE (RED,UNDERLINE)
                    NEXT FIELD col_policy_no
                END IF
                IF NOT pc961_get_polf ( f_arr ) THEN
                    ERROR " 無此保單號碼或狀態不符。" ATTRIBUTE (RED,UNDERLINE)
                    NEXT FIELD col_policy_no
                END IF
                IF NOT pc961_chk_id ( f_arr ) AND 
                   NOT pc961_chk_id_2 (f_arr)       THEN
                    ERROR " 本張保單不符抵繳保費規定。" ATTRIBUTE (RED,UNDERLINE)
                    NEXT FIELD col_policy_no
                END IF
            ELSE
                LET p_ary[ f_arr ].o1_name      = NULL
                LET p_ary[ f_arr ].i1_name      = NULL
                LET p_ary[ f_arr ].po_sts_code  = NULL
                LET p_ary[ f_arr ].method       = NULL
                LET p_ary[ f_arr ].paid_to_date = NULL
            END IF
            DISPLAY p_ary[ f_arr ].o1_name, p_ary[ f_arr ].i1_name
                  , p_ary[ f_arr ].po_sts_code, p_ary[ f_arr ].method
                  , p_ary[ f_arr ].paid_to_date
                 TO sa_961p01[ f_scr ].o1_name, sa_961p01[ f_scr ].i1_name
                  , sa_961p01[ f_scr ].po_sts_code, sa_961p01[ f_scr ].method
                  , sa_961p01[ f_scr ].paid_to_date

    END INPUT

    CLOSE WINDOW pc961p01

    IF INT_FLAG THEN
        IF f_ind = '1' THEN
           LET p_error = "本保單若選擇抵繳需輸入它張保單號碼!!。"
           RETURN FALSE
        ELSE  
           ERROR " 放棄編輯他張保單資料。" ATTRIBUTE (RED,UNDERLINE)
           RETURN TRUE
        END IF 
    END IF

    FOR i = 1 TO p_set_cnt
        IF i > ARR_COUNT() THEN
            LET p_ary[ i ].col_policy_no = NULL
        END IF
        CASE i
            WHEN 1
                LET p_data.col_policy_no_1 = p_ary[ i ].col_policy_no
            WHEN 2
                LET p_data.col_policy_no_2 = p_ary[ i ].col_policy_no
            WHEN 3
                LET p_data.col_policy_no_3 = p_ary[ i ].col_policy_no
            WHEN 4
                LET p_data.col_policy_no_4 = p_ary[ i ].col_policy_no
            WHEN 5
                LET p_data.col_policy_no_5 = p_ary[ i ].col_policy_no
            WHEN 6
                LET p_data.col_policy_no_6 = p_ary[ i ].col_policy_no
            WHEN 7
                LET p_data.col_policy_no_7 = p_ary[ i ].col_policy_no
            WHEN 8
                LET p_data.col_policy_no_8 = p_ary[ i ].col_policy_no
            WHEN 9
                LET p_data.col_policy_no_9 = p_ary[ i ].col_policy_no
            WHEN 10
                LET p_data.col_policy_no_10 = p_ary[ i ].col_policy_no
            OTHERWISE
                LET p_error = "資料超出範圍，請洽資訊部。"
                EXIT FOR
        END CASE
    END FOR

    IF p_error IS NOT NULL THEN
        RETURN FALSE
    END IF

    RETURN TRUE

END FUNCTION   -- pc961_editor --

------------------------------------------------------------------------------
--  函式名稱: pc961_query()
--  處理概要: 查詢抵繳他張保單資料
--  輸入參數: 
--  輸出參數: 
------------------------------------------------------------------------------
FUNCTION pc961_query()

    -- 設定初值
    LET p_error = NULL

    IF p_man.sts_code IS NULL THEN
        ERROR " 找不到資料。" ATTRIBUTE (RED,UNDERLINE)
        RETURN
    END IF

    -- 取得明細資料
    IF NOT pc961_select( p_data.policy_no, p_data.cp_anniv_date ) THEN
        ERROR " ",p_error CLIPPED," " ATTRIBUTE (RED,UNDERLINE)
        RETURN
    END IF
    IF p_arr_cnt = 0 THEN
        ERROR " 無抵繳他張保單資料。" ATTRIBUTE (RED,UNDERLINE)
        RETURN
    END IF

    -- 開啟畫面
    OPEN WINDOW pc961p01 AT p_x,p_y WITH FORM "pc961p01"
    ATTRIBUTE (GREEN, REVERSE, UNDERLINE, FORM LINE FIRST)

    DISPLAY BY NAME p_man.policy_no, p_man.cp_anniv_date

    CALL SET_COUNT( p_arr_cnt )
    DISPLAY ARRAY p_ary TO sa_961p01.*

    CLOSE WINDOW pc961p01

END FUNCTION   -- pc961_query --

------------------------------------------------------------------------------
--  函式名稱: pc961_saving()
--  處理概要: 抵繳他張保單資料存檔
--  輸入參數: 
--  輸出參數: TRUE/FALSE
------------------------------------------------------------------------------
FUNCTION pc961_saving()

    WHENEVER ERROR CONTINUE

    -- 初值設定
    LET p_error = NULL
    INITIALIZE p_pcpm.* TO NULL
    INITIALIZE p_pcpc.* TO NULL

    -- 資料檢核
    IF p_cross = "0" THEN  -- 未經由 pc961_process() 進入
        LET p_cross = "S"
    ELSE
        LET p_error = "資料不完整，無法處理。"
        RETURN FALSE
    END IF
    IF p_man.sts_code = "1" THEN
        LET p_error = "資料已過帳，不可存檔。"
        RETURN FALSE
    END IF
    IF p_data.prss_code = "PASS" THEN
        IF p_data.cp_pay_amt IS NULL THEN
            LET p_error = "請給予還本抵扣金額。"
            RETURN FALSE
        END IF
        IF p_data.tran_date  IS NULL THEN
            LET p_error = "請給予帳務日期。"
            RETURN FALSE
        END IF
    END IF

    -- 資料設定
    LET p_pcpm.policy_no     = p_data.policy_no
    LET p_pcpm.cp_anniv_date = p_data.cp_anniv_date
    LET p_pcpm.pcpm_sts_code = p_man.sts_code
    IF p_pcpm.pcpm_sts_code IS NULL THEN
        LET p_pcpm.pcpm_sts_code = "0"
    END IF
    LET p_pcpm.pcpm_sts_date = p_today
    IF p_pcpm.pcpm_sts_code = "1" OR p_data.prss_code = "PASS" THEN
        CALL pc961_getCollDept( p_pcpm.policy_no )
            RETURNING p_pcpm.collector, p_pcpm.dept_belong
    END IF
    LET p_pcpm.cp_pay_amt    = p_data.cp_pay_amt
    LET p_pcpm.tran_date     = p_data.tran_date
    LET p_pcpm.process_date  = p_today
    LET p_pcpm.process_time  = TIME
    LET p_pcpm.process_user  = g_user

    -- 存檔處理
    CASE
        WHEN p_data.prss_code = "DELE"
            IF NOT pc961_delete() THEN
                RETURN FALSE
            END IF

        WHEN p_data.prss_code = "SAVE"
            IF NOT pc961_delete() THEN
                RETURN FALSE
            END IF
            CALL pc961_trn_data()
            IF NOT pc961_insert() THEN
                RETURN FALSE
            END IF

        WHEN p_data.prss_code = "PASS"
            LET p_pcpm.pcpm_sts_code = "1"
            LET p_pcpm.pcpm_sts_date = p_pcpm.tran_date
            IF NOT pc961_update() THEN
                RETURN FALSE
            END IF

        OTHERWISE
            LET p_error = "處理代碼未定義，無法存檔。"
            RETURN FALSE

    END CASE

    RETURN TRUE

END FUNCTION   -- pc961_saving --

------------------------------------------------------------------------------
--  函式名稱: pc961_delete()
--  處理概要: 刪除資料
--  輸入參數: 
--  輸出參數: TRUE/FALSE
------------------------------------------------------------------------------
FUNCTION pc961_delete()

    WHENEVER ERROR CONTINUE

    -- 資料檢核
    IF p_cross = "S" THEN  -- 未經由 pc961_saving() 進入
        LET p_cross = "S"
    ELSE
        LET p_error = "資料不完整，無法處理。"
        RETURN FALSE
    END IF

    -- 資料刪除
    DELETE FROM pcpm
     WHERE policy_no     = p_pcpm.policy_no
       AND cp_anniv_date = p_pcpm.cp_anniv_date
    IF SQLCA.SQLCODE <> 0 THEN
        LET p_error = getMessage( "pcpm", "3", SQLCA.SQLCODE, SQLCA.SQLERRM )
        RETURN FALSE
    END IF

    DELETE FROM pcpc
     WHERE policy_no     = p_pcpm.policy_no
       AND cp_anniv_date = p_pcpm.cp_anniv_date
    IF SQLCA.SQLCODE <> 0 THEN
        LET p_error = getMessage( "pcpc", "3", SQLCA.SQLCODE, SQLCA.SQLERRM )
        RETURN FALSE
    END IF

    RETURN TRUE

    WHENEVER ERROR STOP

END FUNCTION   -- pc961_delete --
     
------------------------------------------------------------------------------
--  函式名稱: pc961_insert()
--  處理概要: 新增還本保單資料
--  輸入參數: 
--  輸出參數: TRUE/FALSE
------------------------------------------------------------------------------
FUNCTION pc961_insert()
    DEFINE i, f_cnt     SMALLINT

    WHENEVER ERROR CONTINUE

    -- 資料檢核
    IF p_cross = "S" THEN  -- 未經由 pc961_saving() 進入
        LET p_cross = "S"
    ELSE
        LET p_error = "資料不完整，無法處理。"
        RETURN FALSE
    END IF

    -- 資料新增
    INSERT INTO pcpm VALUES ( p_pcpm.* )
    IF SQLCA.SQLCODE <> 0 THEN
        LET p_error = getMessage( "pcpm", "1", SQLCA.SQLCODE, SQLCA.SQLERRM )
        RETURN FALSE
    END IF
     
    -- 新增他張保單
    LET p_pcpc.policy_no     = p_pcpm.policy_no
    LET p_pcpc.cp_anniv_date = p_pcpm.cp_anniv_date
    LET p_pcpc.pcpc_seq      = 0

    FOR i = 1 TO p_arr_cnt
        IF LENGTH( p_ary[ i ].col_policy_no CLIPPED ) = 0 THEN
            CONTINUE FOR
        END IF
        SELECT COUNT(*)
          INTO f_cnt
          FROM pcpc
         WHERE policy_no = p_pcpc.policy_no
           AND cp_anniv_date = p_pcpc.cp_anniv_date
           AND col_policy_no = p_ary[ i ].col_policy_no
        IF f_cnt > 0 THEN
            LET p_error = "他張保單號碼重複，無法存檔。"
        END IF
        LET p_pcpc.pcpc_seq = p_pcpc.pcpc_seq + 1
        LET p_pcpc.col_policy_no = p_ary[ i ].col_policy_no
        INSERT INTO pcpc VALUES ( p_pcpc.* )
        IF SQLCA.SQLCODE <> 0 THEN
            LET p_error = getMessage("pcpc","1",SQLCA.SQLCODE,SQLCA.SQLERRM)
            EXIT FOR
        END IF
    END FOR

    IF p_error IS NOT NULL THEN
        RETURN FALSE
    END IF

    RETURN TRUE

    WHENEVER ERROR STOP

END FUNCTION   -- pc961_insert --

------------------------------------------------------------------------------
--  函式名稱: pc961_update()
--  處理概要: 過帳更新資料 (若不存在則新增一筆)
--  輸入參數: 
--  輸出參數: TRUE/FALSE
------------------------------------------------------------------------------
FUNCTION pc961_update()

    WHENEVER ERROR CONTINUE

    -- 資料檢核
    IF p_cross = "S" THEN  -- 未經由 pc961_saving() 進入
        LET p_cross = "S"
    ELSE
        LET p_error = "資料不完整，無法處理。"
        RETURN FALSE
    END IF

    -- 資料更新
    UPDATE pcpm
       SET * = p_pcpm.*
     WHERE policy_no     = p_pcpm.policy_no
       AND cp_anniv_date = p_pcpm.cp_anniv_date
    IF SQLCA.SQLCODE <> 0 OR SQLCA.SQLERRD[3] > 1 THEN
        LET p_error = getMessage( "pcpm", "2", SQLCA.SQLCODE, SQLCA.SQLERRM )
        RETURN FALSE
    END IF
    -- 資料未更新: 新增
    IF SQLCA.SQLERRD[3] = 0 THEN
        INSERT INTO pcpm VALUES ( p_pcpm.* )
        IF SQLCA.SQLCODE <> 0 THEN
            LET p_error = getMessage("pcpm","1",SQLCA.SQLCODE,SQLCA.SQLERRM)
            RETURN FALSE
        END IF
    END IF

    RETURN TRUE

    WHENEVER ERROR STOP

END FUNCTION   -- pc961_update --

------------------------------------------------------------------------------
--  函式名稱: pc961_get_polf()
--  處理概要: 取得其他保單資料
--  輸入參數: 序號
--  輸出參數: TRUE/FALSE
------------------------------------------------------------------------------
FUNCTION pc961_get_polf ( f_arr )
    DEFINE f_arr        SMALLINT

    SELECT po_sts_code, method, paid_to_date
      INTO p_ary[ f_arr ].po_sts_code, p_ary[ f_arr ].method
         , p_ary[ f_arr ].paid_to_date
      FROM polf 
     WHERE policy_no = p_ary[ f_arr ].col_policy_no
       AND po_sts_code in ('42','47','48','50') 
       AND currency = 'TWD'

    IF STATUS = NOTFOUND THEN
        LET p_ary[ f_arr ].po_sts_code  = NULL
        LET p_ary[ f_arr ].method       = NULL
        LET p_ary[ f_arr ].paid_to_date = NULL
        LET p_ary[ f_arr ].i1_name      = NULL
        LET p_ary[ f_arr ].o1_name      = NULL
        RETURN FALSE
    END IF

    SELECT names[1,10],clnt.client_id
      INTO p_ary[ f_arr ].o1_name,p_ary1[ f_arr ].o1_id
      FROM pocl ,clnt
     WHERE pocl.policy_no = p_ary[ f_arr ].col_policy_no
       AND pocl.client_ident = 'O1'
       AND pocl.client_id = clnt.client_id

    SELECT names[1,10],clnt.client_id
      INTO p_ary[ f_arr ].i1_name,p_ary1[ f_arr ].i1_id
      FROM pocl ,clnt
     WHERE pocl.policy_no = p_ary[ f_arr ].col_policy_no
       AND pocl.client_ident = 'I1'
       AND pocl.client_id = clnt.client_id


    RETURN TRUE

END FUNCTION   -- pc961_get_polf --

------------------------------------------------------------------------------
--  函式名稱: pc961_getCollDept()
--  處理概要: 取得還本保單之 collector 及 dept_belong
--  輸入參數: 保單號碼
--  輸出參數: collector, dept_belong
------------------------------------------------------------------------------
FUNCTION pc961_getCollDept( f_policy_no )
    DEFINE f_policy_no          LIKE polf.policy_no
         , f_collector          LIKE bill.collector
         , f_dept_belong        LIKE dept.dept_belong
    DEFINE f_method             LIKE polf.method
         , f_dept_code          LIKE dept.dept_code
         , f_coll_name          LIKE clnt.names

    -- 初值設定
    LET f_collector = NULL
    LET f_dept_belong = NULL
    LET f_method = NULL
    LET f_dept_code = NULL

    -- 取得還本保單之收費方式
    SELECT method
      INTO f_method
      FROM polf
     WHERE policy_no = f_policy_no
 
{
    -- 依收費方式取得保單目前之收費代碼
    CASE f_method
        WHEN "3"  -- 收費員收費
            SELECT b.collector_no, c.dept_code
              INTO f_collector, f_dept_code
              FROM polf a, pczp b, pccm c
             WHERE a.policy_no = f_policy_no
               AND a.collect_code = b.collect_code
               AND b.collector_no = c.collector_no
            IF STATUS = NOTFOUND THEN
                LET f_collector = "0999"  -- 問題件
                SELECT dept_code
                  INTO f_dept_code
                  FROM pccm
                 WHERE collector_no = f_collector
            END IF

        WHEN "6"   --業務員收費
            SELECT b.agent_code, c.dept_code
              INTO f_collector, f_dept_code
              FROM polf a, poag b, agnt c
             WHERE a.policy_no = f_policy_no
               AND a.policy_no = b.policy_no
               AND b.relation = 'S'
               AND b.agent_code = c.agent_code
            IF STATUS = NOTFOUND THEN
                LET f_collector = 'A888888888'
                SELECT dept_code
                  INTO f_dept_code
                  FROM agnt
                 WHERE agent_code = f_collector
            END IF

        OTHERWISE
            LET f_dept_code = NULL
            SELECT DISTINCT collector
              INTO f_collector
              FROM pcmt
             WHERE po_ind = "1"
               AND method = f_method
            IF SQLCA.SQLCODE <> 0 THEN
                LET f_collector = NULL
            END IF

    END CASE
}
    CALL MethodToCol( f_policy_no, f_method ) RETURNING f_collector, f_coll_name
    -- 依收費方式取得部門代碼
    CASE f_method
        WHEN "3"  -- 收費員收費
            SELECT dept_code
              INTO f_dept_code
              FROM pccm
             WHERE collector_no = f_collector
        WHEN "6"   --業務員收費
            SELECT dept_code
              INTO f_dept_code
              FROM agnt
             WHERE agent_code = f_collector
    END CASE

    -- 依據收費方式之 dept_code 取得 dept_belong, 若無則歸屬總公司
    SELECT dept_belong
      INTO f_dept_belong
      FROM dept
     WHERE dept_code = f_dept_code
    IF STATUS = NOTFOUND THEN
        LET f_dept_belong = "90000"
    END IF

    RETURN f_collector, f_dept_belong

END FUNCTION   -- pc961_getCollDept --

------------------------------------------------------------------------------
--  函式名稱: pc961_chk_id()
--  處理概要: 檢核抵繳保單要被保險人或生存滿期受益人是否為還本保單受益人
--  輸入參數: 序號
--  輸出參數: TRUE/FALSE
------------------------------------------------------------------------------
FUNCTION pc961_chk_id ( f_arr )
    DEFINE f_arr        SMALLINT
    DEFINE f_benf_id    CHAR(10)   --還本保單受益人
    DEFINE f_cnt        SMALLINT   
    DEFINE f_cnt_2      SMALLINT 
    DEFINE f_benf_id_2  CHAR(10)   --抵繳保單受益人
    
    LET f_cnt = 0
    SELECT count(*)
      INTO f_cnt
      FROM benf
     WHERE policy_no = p_data.policy_no
       AND relation  = p_benf_relation
    IF f_cnt = 0 THEN
       RETURN FALSE
    END IF


    DECLARE benf_chk_cur CURSOR FOR
        SELECT client_id
          FROM benf
         WHERE policy_no = p_data.policy_no
           AND relation  = p_benf_relation
    FOREACH benf_chk_cur INTO f_benf_id
--display 'ttt=',f_benf_id
        IF f_benf_id is NULL OR
           f_benf_id = '' OR
           f_benf_id =' ' THEN
           RETURN FALSE
        END IF
       
        IF f_benf_id != p_ary1[f_arr].o1_id THEN
           IF f_benf_id != p_ary1[f_arr].i1_id THEN

---A1263310 102/07/31 cmwang新增還本保單受益人 = 抵繳保單受益人條件(L或M)
           ---判斷抵繳保單號碼在benf檔有沒有還本保單受益人的資料
              LET f_cnt_2 = 0 
              SELECT   COUNT(*)
                INTO   f_cnt_2 
                FROM   benf
               WHERE   policy_no = p_ary[f_arr].col_policy_no 
                 AND   client_id = f_benf_id
                 AND   relation in ('L','M')
              IF f_cnt_2 = 0 THEN
                 RETURN FALSE
              END IF                              

           END IF  
        END IF  
    END FOREACH 

    RETURN TRUE
END FUNCTION
------------------------------------------------------------------------
--  函式名稱: pc961_chk_id_2()  102/07/31新增
--  處理概要: 檢核抵繳保單要保險人是否為還本保單要保人
--  輸入參數: 序號
--  輸出參數: TRUE/FALSE
------------------------------------------------------------------------------
FUNCTION pc961_chk_id_2(f_arr)
   DEFINE f_arr        SMALLINT
   DEFINE f_o1_id      LIKE pocl.client_id  --還本保單要保人

   SELECT   client_id
     INTO   f_o1_id 
     FROM   pocl 
    WHERE   policy_no = p_data.policy_no 
      AND   client_ident = 'O1'
     
   IF p_ary1[f_arr].o1_id != f_o1_id THEN 
      RETURN FALSE 
   END IF 
 
   RETURN TRUE 

END FUNCTION 

