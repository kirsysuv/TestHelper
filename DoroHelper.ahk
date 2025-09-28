#Requires AutoHotkey >=v2.0
#SingleInstance Force
#Include <github>
#Include <FindText>
#Include <GuiCtrlTips>
#Include <RichEdit>
CoordMode "Pixel", "Client"
CoordMode "Mouse", "Client"
;退出时保存设置
OnExit(WriteSettings)
;检测管理员身份
if !A_IsAdmin {
    MsgBox "请以管理员身份运行Doro"
    ExitApp
}
;region 设置常量
try TraySetIcon "doro.ico"
currentVersion := "v1.7.3"
;tag 检查脚本哈希
SplitPath A_ScriptFullPath, , , &scriptExtension
scriptExtension := StrLower(scriptExtension)
if (scriptExtension = "ahk") {
    currentVersion := currentVersion . "-beta"
}
usr := "1204244136"
repo := "DoroHelper"
;endregion 设置常量
;region 设置变量
;tag 简单开关
global g_settings := Map(
    ;登录游戏
    "Login", 0,                  ;登录游戏总开关
    ;商店
    "Shop", 0,                   ;商店总开关
    "ShopCash", 1,               ;付费商店
    "ShopCashFree", 0,           ;付费商店免费物品
    "ShopCashFreePackage", 0,     ;付费商店免费STEPUP
    "ShopNormal", 1,             ;普通商店
    "ShopNormalFree", 0,         ;普通商店：免费物品
    "ShopNormalDust", 0,         ;普通商店：芯尘盒
    "ShopNormalPackage", 0,      ;普通商店：简介个性化礼包
    "ShopArena", 1,              ;竞技场商店
    "ShopArenaBookFire", 0,      ;竞技场商店：燃烧手册
    "ShopArenaBookWater", 0,     ;竞技场商店：水冷手册
    "ShopArenaBookWind", 0,      ;竞技场商店：风压手册
    "ShopArenaBookElec", 0,      ;竞技场商店：电击手册
    "ShopArenaBookIron", 0,      ;竞技场商店：铁甲手册
    "ShopArenaBookBox", 0,       ;竞技场商店：手册宝箱
    "ShopArenaPackage", 0,       ;竞技场商店：简介个性化礼包
    "ShopArenaFurnace", 0,       ;竞技场商店：公司武器熔炉
    "ShopScrap", 1,              ;废铁商店
    "ShopScrapGem", 0,           ;废铁商店：珠宝
    "ShopScrapVoucher", 0,       ;废铁商店：好感券
    "ShopScrapResources", 0,     ;废铁商店：养成资源
    "ShopScrapTeamworkBox", 0,   ;废铁商店：团队合作宝箱
    "ShopScrapKitBox", 0,        ;废铁商店：保养工具箱
    "ShopScrapArms", 0,          ;废铁商店：企业精选武装
    ;模拟室
    "SimulationRoom", 0,         ;模拟室
    "SimulationNormal", 0,       ;普通模拟室
    "SimulationOverClock", 0,    ;模拟室超频
    ;竞技场
    "Arena", 0,                  ;竞技场总开关
    "AwardArena", 0,             ;竞技场收菜
    "ArenaRookie", 0,            ;新人竞技场
    "ArenaSpecial", 0,           ;特殊竞技场
    "ArenaChampion", 0,          ;冠军竞技场
    ;无限之塔
    "Tower", 0,                  ;无限之塔总开关
    "TowerCompany", 0,           ;企业塔
    "TowerUniversal", 0,         ;通用塔
    ;异常拦截
    "Interception", 0,           ;拦截战
    "InterceptionNormal", 0,     ;普通拦截战
    "InterceptionAnomaly", 0,    ;异常拦截战
    "InterceptionScreenshot", 0, ;拦截截图
    "InterceptionRedCircle", 0,  ;拦截红圈
    "InterceptionExit7", 0,      ;满7退出
    ;常规奖励
    "Award", 0,                  ;奖励领取总开关
    "AwardOutpost", 0,           ;前哨基地收菜
    "AwardOutpostExpedition", 0, ;派遣
    "AwardLoveTalking", 0,       ;咨询
    "AwardAppreciation", 0,      ;花絮鉴赏
    "AwardFriendPoint", 0,       ;好友点数
    "AwardMail", 0,              ;邮箱
    "AwardRanking", 0,           ;排名奖励
    "AwardDaily", 0,             ;任务
    "AwardPass", 0,              ;通行证
    ;小活动
    "Event", 0,                  ;活动总开关
    "EventSmall", 0,             ;小活动
    "EventSmallChallenge", 0,    ;小活动挑战
    "EventSmallStory", 0,        ;小活动剧情
    "EventSmallMission", 0,      ;小活动任务
    ;大活动
    "EventLarge", 0,             ;大活动
    "EventLargeSign", 0,         ;大活动签到
    "EventLargeChallenge", 0,    ;大活动挑战
    "EventLargeStory", 0,        ;大活动剧情
    "EventLargeCooperate", 0,    ;大活动协同作战
    "EventLargeMinigame", 0,     ;大活动小游戏
    "EventLargeDaily", 0,        ;大活动奖励
    ;特殊活动
    "EventSpecial", 0,           ;特殊活动
    "EventSpecialSign", 0,       ;特殊活动签到
    "EventSpecialChallenge", 0,  ;特殊活动挑战
    "EventSpecialStory", 0,      ;特殊活动剧情
    "EventSpecialCooperate", 0,  ;特殊活动协同作战
    "EventSpecialMinigame", 0,   ;特殊活动小游戏
    "EventSpecialDaily", 0,      ;特殊活动奖励
    ;限时奖励
    "AwardFreeRecruit", 0,       ;活动期间每日免费招募
    "AwardCooperate", 0,         ;协同作战
    "AwardSoloRaid", 0,          ;个人突击
    ;妙妙工具
    "StoryModeAutoStar", 0,      ;剧情模式自动收藏
    "StoryModeAutoChoose", 0,    ;剧情模式自动选择
    ;清除红点
    "ClearRed", 0,               ;总开关
    "ClearRedNotice", 0,         ;清除公告红点
    "ClearRedWallpaper", 0,      ;清除壁纸红点
    "ClearRedRecycling", 0,      ;自动升级循环室
    "ClearRedSynchro", 0,        ;自动升级同步器
    "ClearRedCube", 0,           ;自动升级魔方
    "ClearRedSynchroForce", 0,   ;开箱子
    "ClearRedLimit", 0,          ;自动突破妮姬
    ;启动/退出相关
    "CloseAdvertisement", 0,     ;关闭启动提示
    "CloseNoticeSponsor", 0,     ;关闭赞助提示
    "CloseHelp", 0,              ;关闭帮助提示
    "AutoCheckUpdate", 0,        ;自动检查更新
    "AutoCheckUserGroup", 0,     ;自动检查会员组
    "AutoDeleteOldFile", 0,      ;自动删除旧版本
    "DoroClosing", 0,            ;完成后自动关闭Doro
    "LoopMode", 0,               ;完成后自动关闭游戏
    "OpenBlablalink", 0,         ;完成后打开Blablalink
    "CheckEvent", 0,             ;活动结束提醒
    "AutoStartNikke", 0,         ;使用脚本启动NIKKE
    "Timedstart", 0,             ;定时启动
    ;其他
    "AutoFill", 0,               ;自动填充加成妮姬
    "CheckAuto", 0,              ;开启自动射击和爆裂
    "BluePill", 0,               ;万用开关
    "RedPill", 0                 ;万用开关
)
;tag 其他非简单开关
global g_numeric_settings := Map(
    "doroGuiX", 200,                ;DoroHelper窗口X坐标
    "doroGuiY", 200,                ;DoroHelper窗口Y坐标
    "TestModeValue", "",            ;调试模式值
    "StartupTime", "",              ;定时启动时间
    "StartupPath", "",              ;启动路径
    "SleepTime", 1000,              ;默认等待时间
    "InterceptionBoss", 1,          ;拦截战BOSS选择
    "Tolerance", 1,                 ;宽容度
    "MirrorCDK", "",                ;Mirror酱的CDK
    "Version", currentVersion,      ;版本号
    "UpdateChannels", "正式版",      ;更新渠道
    "DownloadSource", "GitHub",     ;下载源
    "UserGroup", "普通用户"          ;用户组
)
;tag 其他全局变量
outputText := ""
Victory := 0
BattleActive := 1
BattleSkip := 0
QuickBattle := 0
PicTolerance := g_numeric_settings["Tolerance"]
g_settingPages := Map()
Hashed := ""
stdScreenW := 3840
stdScreenH := 2160
nikkeID := ""
NikkeX := 0
NikkeY := 0
NikkeW := 0
NikkeH := 0
NikkeXP := 0
NikkeYP := 0
NikkeWP := 0
NikkeHP := 0
TrueRatio := 1
;tag 彩蛋
konami_code := "UUDDLRLRBA" ; 目标序列 (U=Up, D=Down, L=Left, R=Right)
key_history := ""           ; 用于存储用户按键历史的变量
if (scriptExtension = "ahk") {
    MyFileHash := HashGitSHA1(A_ScriptFullPath)
    global MyFileShortHash := SubStr(MyFileHash, 1, 7)
}
;tag 变量备份
g_default_settings := g_settings.Clone()
g_default_numeric_settings := g_numeric_settings.Clone()
;endregion 设置变量
;region 读取设置
SetWorkingDir A_ScriptDir
;tag 变量名修改提示
try {
    LoadSettings()
    if InStr(currentVersion, "v1.6.6") and g_numeric_settings["Version"] != currentVersion {
        MsgBox("该版本的「开启自动射击和爆裂」选项被重置了，请按需勾选")
        ; g_settings["CloseHelp"] := 0
        g_numeric_settings["Version"] := currentVersion
    }
}
catch {
    WriteSettings()
}
;tag 初始化用户组
;0是普通用户，1是铜Doro会员，2是银Doro会员，3是金Doro会员，10是管理员
UserGroup := g_numeric_settings["UserGroup"]
if UserGroup = "管理员" {
    UserLevel := 10
}
if UserGroup = "金Doro会员" {
    UserLevel := 3
}
if UserGroup = "银Doro会员" {
    UserLevel := 2
}
if UserGroup = "铜Doro会员" {
    UserLevel := 1
}
if UserGroup = "普通用户" {
    UserLevel := 0
}
;endregion 读取设置
;region 识图素材
; FindText().PicLib("对应的内容")
; 左上角通用坐标
; NikkeX + 0.001 * NikkeW . " ", NikkeY + 0.001 * NikkeH . " ", NikkeX + 0.001 * NikkeW + 0.070 * NikkeW . " ", NikkeY + 0.001 * NikkeH + 0.070 * NikkeH . " "
;tag 未更新
FindText().PicLib("|<白色的叉叉>*220$28.zzzzszzzz1zzzsXzzz77zzsyDzz7wTzszszz7zlzszzXz7zz7szzyD7zzwMzzzs7zzzkzzzz3zzzs7zzz6DzzswTzz7szzszlzz7znzszz7z7zyDszzwT7zzsszzzlDzzzVzzzzc", 1)
;tag 登录
FindText().PicLib("|<不再显示的框>*200$51.000000000000000000000000001zzzzzy00zzzzzzw0Dzzzzzzk3zzzzzzz0Tzzzzzzs7zzzzzzz0z000003s7s00000T0z000003s7s00000T0z000003s7s00000T0z000003s7s00000T0z000003s7s00000T0z000003s7s00000T0z000003s7s00000T0z000003s7s00000T0z000003s7s00000T0z000003s7s00000T0z000003s7s00000T0z000003s7s00000T0z000003s7s00000T0z000003s7s00000T0z000003s7s00000T0z000003s7s00000T0z000003s7zzzzzzz0Tzzzzzzs1zzzzzzy0Dzzzzzzk0zzzzzzw01zzzzzy000000000000000000000000004", 1)
FindText().PicLib("|<签到·全部领取的全部>*200$68.zznzzzwTzzzzzsDzzy7z0Dzzw7zzzkzk0zzy0zzzk7w07zz03zz00701zzU0Tzk01kkTzkA3zw00QQDzk7UDzkwD73zk3w1zwT3lkzk3zk7z3kwQTU1zy0DksT67k0zzk3yC7lXwU0001s00AMzg0000S0036Dzs001zU00lVzz000zs00AQDzzsTzzzzz73zzy7zzzzzlszzzVzzzzzwSDzk00Dz0077Vzw003zk01lsTz000zw00QS7zk00Dz1w721zzy7zzkzVk0zzzVzzwDsQMDzzsTzz3y767z00007k01lzzU0001y00QTzs0000TU077zy00007s01lzzzzzzzwDsQTzs", 1)
;tag 通用
FindText().PicLib("|<红点>F8541D-0.74$20.07k0Tz0Dzs7zz3zztzzyTzzrzzzzzzzzzzzzxzzzTzzrzzszzyDzzUzzkDzs1zs07s2", 1)
FindText().PicLib("|<圈中的感叹号>*150$37.zzs7zzzzU0Dzzy001zzy000Dzy1zs3zw3zz0zy3zzsDy3zzy3y7zzzUy3zzzsT3zszy73zwTzXVzyDzklzzzzsEzzzzy8Tzzzz4TzzzzUDzwTzk7zyDzs3zz7zw1zzXzy0Tzlzz0DzszzX7zwTzlVzyDzkkzz7zswTzXzsS7zlzwDVzzzwDkTzzwDw7zzw7z1zzs7zkDzk7zw0T0DzzU00Dzzw00TzzzU1zzk", 1)
FindText().PicLib("|<带圈白勾>*200$56.zzzw03zzzzzzs003zzzzzk000zzzzzk000Tzzzzs000Dzzzzs01z7zzzzw07zzzzzzy07zzzzvzz07zzzzwTzU7zzzzy3zk3zzzzz0Ts1zzzzzU7y0zzzzzk3z0Tzzzzs1zUDzzzzw0zs7zzzzy0Tw1zzzzz0Dz0zzzzzU7zkDzzzzk3zs7zzzzs1zy1zzzzw0zzUzzzzy0TzsDzzzz0Dzw3zrzzU7zz0zszzk3zzkDw7zs1zzw3y0zw0zzz0zk7y0TzzkDy0z0Dzy03zk7U7zzU0zy0k3zzs0Dzk01zzw23zy00zzz0Uzzk0Tzzk87zy0Dzzw61zzk7zzy1UTzy3zzzUQ3zzlzzzkD0zzyzzzw3s7zzzzzy0y1zzzzzzUTkDzzzzzk7w1zzzzzs3zUDzzzzw1zw1zzzzy0Tz0Dzzzz0Dzs1zzzzU7zz07zzzU3zzs0TzzU1zzz00zzU0zzzw00000TzzzU0000Tzzzy0000Dzzzzs000DzzzzzU00Tzzzzzzk1zzzy", 1)
FindText().PicLib("|<灰色空心方框>*200$36.0Tzzy01zzzzU7zzzzkDk007sT0000wS0000Sw0000Cs0000Ds0000Ds00007s00007s00007s00007s00007s00007s00007s00007s00007s00007s00007s00007s00007s00007s00007s00007s00007s00007s00007s0000Ds0000Cw0000SS0000yD0001wDzzzzs3zzzzk1zzzz0U", 1)
FindText().PicLib("|<方舟的图标>*100$90.0000000s0000000000007zzU00000000003zzzzU000000000zzzzzz000000003zzzzzzU0000000Dzzzzzzs0000000Tzzzzzzy0000001zzzzzzzzU000007zzzzzzzzs00000Dzzzzzzzzy00000zzzzcSDzzzU0001zzzw0S3zzzk0003zzzk0S0zzzs0007zzzU0S0Dzzw000Dzzz00S07zzy000Tzzy00S01zzz000zzzw00S00zzzU01zzzs00S00Tzzk03zzzk00y00Tzzs03zzzk03z00Dzzw07zzzU0Dzk07zzy07zzzU0zzw03zzz0Dzzz01zzy03zzzUDzzz03zzz01zzzUTzzz03zzz01zzzkTzzz07zzzU0zzzszzzz07zzzU0zzzszzzzUDzzzk0zzzwzzzzzzzzzk0zzzwzzzzzzzzzs0zzzyTzzzzzzzzzzzzzyTzzz1zzzzzzzzzzDzzz07zzzzzzzzzDzzz07zzzxzzzzz7zzz07zzzk0zzzz7zzz03zzzk0zzzz3zzz03zzzU0zzzy3zzzU1zzzU0zzzy1zzzU0zzz00zzzw0zzzk0Tzy01zzzw0Tzzk07zw01zzzs0Tzzs01zk03zzzk0Dzzs00z007zzzk07zzw00S007zzzU03zzy00S00Dzzz001zzz00S00Tzzy000zzzU0S00zzzw000Tzzs0S01zzzw000Dzzw0S07zzzk0003zzz0S0DzzzU0001zzzsy1zzzz00000TzzzyDzzzw00000Dzzzzzzzzs000003zzzzzzzzk000000zzzzzzzzU000000Tzzzzzzy00000007zzzzzzU00000000zzzzzy0000000003zzzzk0000000000Dzzz000000000000z9U00000U", 1)
FindText().PicLib("|<左上角的方舟>*150$65.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz3zzzzUzzzzy3zzzy3zzzzw7zzzw7zzzzwDzzs003zzzkDzzk007zU0001zU00Dz00003z000Ty00007y7jkzy0000DwCDVzzy3zzzsMD3zzwDzzzksC7zzsTzzzVsQDzzk00Ty3tsDzz000T00003zy000y00007zw003w0000DzsDy7s0000TzkzwDz1zw7zz1zsTy7bsTzy3zkzwC3kzzsDzVzkQ3VzzkTy3zUw33zz1zw7z3yC7zw3zsTw7ywDzUDz0zkTzsTy0z01z0zy0zy3z07y3zw1zyDy0TyDzs3zyzw7zzzzsTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzk", 1)
FindText().PicLib("|<确认的白色勾>*200$46.zzzzzzwDzzzzzz0Tzzzzzs0zzzzzz03zzzzzs0Dzzzzz01zzzzzs0Dzzzzz01zzzzzs0Dzzzzz01zzzzzs0Dzzzzz01zlzzzs0Dy3zzz01zk7zzs0Dz0Dzz01zw0Tzs0Dzk0zz01zzU1zs0Dzy03z01zzw07s0Dzzs0D01zzzk080DzzzU001zzzz000Dzzzy001zzzzw00Dzzzzw01zzzzzs0Dzzzzzk1zzzzzzUDzzzzzz1zzzzzzyTzzzzU", 1)
FindText().PicLib("|<黄色的小时>FFC700-0.90$135.0000Dz00000000000000zk00001zs00000000000007y00000Dz00000000000000zk00001zs00000000000007y00000Dz000000DzzzU000zk00001zs000001zzzw0007y00000Dz000000DzzzU000zk00001zs000001zzzw0007y00000Dz000000DzzzU000zk00001zs000001zzzw0007y00000Dz000000DzzzU001zs00001zs000001zzzwDzzzzz0000Dz000000Dw1zVzzzzzs0001zs000001zUDwDzzzzz0000Dz000000Dw1zVzzzzzs0k01zs07U001zUDwDzzzzz07y0Dz07w000Dw1zVzzzzzs1zs1zs3zk001zUDwDzzzzz0Dz0Dz0Ty000Dw1zVzzzzzs1zs1zs1zs001zUDwDzzzzy0Dz0Dz0Dz000Dw1zU000zs01zk1zs1zw001zUDw0007y00Ty0Dz07zU00Dy1zU000zk03zk1zs0zy001zzzw0007y00Ty0Dz03zk00DzzzU000zk07zU1zs0Tz001zzzw0Q07y00zw0Dz01zs00DzzzUDU0zk07zU1zs0Dz001zzzw7y07y00zs0Dz00zw00DzzzVzs0zk0Dz01zs07zU01zzzwDz07y01zs0Dz00zy00Dy1zUzw0zk0Dz01zs03zk01zUDw3zk7y03zk0Dz00Ty00Dw1zUTz0zk0Ty01zs01zs01zUDw1zs7y07zk0Dz00Dz00Dw1zU7zUzk0zw01zs01zw01zUDw0zy7y0DzU0Dz007zU0Dw1zU3zkzk1zs01zs00zw01zUDw0Dz7y0Tz00Dz007zk0Dw1zU1zkzk3zs01zs00Ty01zUDw07s7y0zy00Dz003zk0Dw1zU0w0zk7zk01zs00Tz01zkDw0207y0Dw00Dz003zs0DzzzU000zk0T001zs00Dz01zzzw0007y00s00Dz001z00DzzzU000zk02001zs00DU01zzzw0007y00000Dz001U00DzzzU000zk00001zs000001zzzw0007y00000Dz000000DzzzU000zk00001zs000001zk000007y00000Dz000000Dw000000zk00001zs000001zU00000Dy000A0zz000000Dw0001zzzk000zzzs000001zU0007zzy0007zzy000000000000zzzk000zzzk000000000003zzy0003zzy000000000000TzzU000TzzU000000000003zzs0001zzs000000000000Dzy0000Dzw0000000000001zw00001zs000000000000000004", 1)
FindText().PicLib("|<公告的图标>*150$44.zzzszzzzzzw7zzzzzy1zzzzzzUDzzzzzs3zzzzzs0Tzzzzs01zzzzs007zzzw000Tzzy0003zzz0000TzzU0003zzs0000zzw00007zy00001zzU0000Dzs00003zw00000zz00000Dzk00001zw00000Tz000007zk00001zw00000Tz000007zk00001zw00000Tz000007zk00001zw00000Tz000007zk00001zw00000Tz000007zk00001zs00000Dw000001y000000D0000001U000000000000000000000UsM3VokTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw01zzzzz00zzzzzs0Tzzzzz0Dzzzzzw7zzy", 1)
FindText().PicLib("|<黄色的遗失物品的图标>FF9900-0.80$78.zzzzzzzzzzzzzzzzzzzzzzzzzzTzzzzzzzzzzzzTzzzzzzzzzzzyDzzzzzzzzzzzyDzzzzzzzzzzzw7zzzw0Tzzzzzs3zzzk03zzzzzs3zzzU01zzzzzk1zzz000zzzzzk1zzy000TzzzzU0zzw0z0TzzzzU0zzw3zkDzzzz00Tzw7zsDzzzy00Dzs7zw7zzzy00DzsDzw7zzzy007zsDzw7zzzw007zsDzw7zzzs003zsDzw7zzzs001zsDzw7zzzk001zsDzw7zzzk000zs7zw7zzzU000zw7zsDzzz0000Tw3zkDzzz0000Dy1zUTzzy0000Dy000Dzzy00007z0007zzw00007zU003zzs00003zs041zzs00001zw0S0zzk00001zzzz0Tzk00000zzzzUDzU00000zzzzk7z000000Tzzzs3z000000Tzzzw1y000000Dzzzy3y0000007zzzz3w0000007zzzzbs0000003zzzzzs0000003zzzzzk0000001zzzzzk0000000zzzzzU0000000zzzzzU0000000zzzzz00000000Tzzzy00000000Dzzzy00000000Dzzzw000000007zzzw000000007zzzs000000003zzzk000000001zzzk000000001s07U000000000k03U000000000s030000000000M020000000000A060000000000A0A000000000060A000000000060M000000000030E000000000010k00000000001UU00000000000VU00000000000l000000000000S000000000000S000000000000A0000000000004000000U", 1)
FindText().PicLib("|<抽卡·确认>*200$87.zzzyDzzzzzzy7zzzzzVzzzzDzzkzzk03wDzzzkTzy7zw00D1zzzy1zzkzzU03s00zzs7zy7zw00S007zzUTzkzzz3zk00zzy1zy7zzsTw7sDzzsDzkzzy3z1z1zzzXzy7zzkzsTkTzzyzzkzzy7y3w7zzzzzy7zzkzU000Tzzzzkzzw7s0003zzzzy7zzVy0000TzzzzkzzwDk0003s07zy7zzVy0T3wT00zzUzzs033sTXs07zw7zz00sT3wTU0zzUzzk073sT3zy7zw3zy00s000TzkzzUTzUT70003zy7zw3zw3ss000TzkzzUTz0T71kT3zy7zs1zs3ssT3wTzkzz0DzUT73sTXzy7zs1zw3ssT3wTzkzz07zwT73sT3zy7zkEzzXss000Tzkzy23zwT70003zy7zksTzXsk000Tzksw71zwT60003zy67VwDzVkkz3wTzk0sDUzw067sTXzy061y7zU0Uz3wTzk3kTkTw047sTXzw0w7z1zU01z3wTzUT0zs7wTsDsTXzs7kDzUTXy3z20Dz1w3zy1wTkTsE3zwz0zzs7ry7z20TzzsDzzVzztzzk7zzznzzyQ", 1)
;tag 商店
;tag 付费商店
FindText().PicLib("|<付费商店的图标>7EBBED-0.80$24.0UVU1VkU13sE27s807w44Dy68Tz2EzzVlzzkVzzk3zzs7zzwDzzyDzzyTzzwDzzw7zzs3zzk3zzkVzzVEzz2MTy48DyA4Dw827sE13kU1VkU0UV0U", 1)
FindText().PicLib("|<礼物的下半>*150$51.s007z000z000Tk007s003y000z000Tk007s003y000z000Tk007s003y000z000Tk007s003y000z000Tk007s003y000z000Tk007s003y000z000Tk007s003y000z000Tk007s003y000z000Tk007s003y000zU00zs00Dzzzzzzzzzzzzzzzzzzzzzzzzzw", 1)
FindText().PicLib("|<商店的图标>*240$69.0000w0000000001zs000000000TzU00000000zzz00000001zzzw0000000zzzzk0Dzw00zzs7zDzzzU07zy0Tzzzzy00zw01zzzzzs0Dw003zzzzzU1y000Dzz07y0Dk000zk00Tk1w01k3y001z0DU0D0TU00Ds3s33w7w000zUT0TzVz0003w3s7zwDs030Dkz1zzXy0kQ1z7kDzwTUDzs7ty0zz7w3zz0TDk7zsz0Tzs3ty0TyDk3zz0TTU0zly0Tzk7vw00wTU3zw0zTk003y0Dz0Dvz000Ds0zk3zDw001zU3w0Tszs007y0707z3zU03zk001zzzy00zz000Dzzzs1zzs003zzzzlzzzU00Tzzzzzzzw007zzzzzzzzk07zzU", 1)
;tag 普通商店
FindText().PicLib("|<左上角的百货商店>*150$121.zzzzzzVkzzzzUzzzzsTzU0003zUsT7zzkTzzzw7zk0001zUw41y6000zzy3zs0000z0S00y0000DU00040000T0C01y00007k0001zs7zy0007z00003s0000zw7zzU20TXzkT1zw0000Ty3zzs10DkzsDUzy3zzzzy0zzzUw00zw7kzz1z3zz0007zkT00Ty3kDzUzUzzU003zsDU0TU000DkTkTzk001zw7y0zk0007sDs01sDzUzzzzzzs0003w7w00wDzsTy000DwD73Vy7y00S7zwDz0007y63Ukz3z1zz3zy7zU003z01k0TVzUzzU003zk001zU3w0DkzkTzk001zsTzkzk0w07sM007s000zwD3sTsE013wA003w000Ty7UwDwA01Vy6001y7zwDz3kS7y67Vky3000z3zy7zVsT3z33ssT1VzsTVzz3zks8DzVU0QDVkzwDk001zzk43zkk0C7ksDw7s000zz040DsM073kQ003w000Tk0D01wADvVsC001y000Ds0Tw0y7zw0wD000z3zy7y0zzkz3zz0z7UzkTVzz3zbzzyzVzzVzzlzyD", 1)
FindText().PicLib("|<简介个性化礼包>*150$222.100U0003000000003k00006000010000080003s0w0007U0000s007k0y007lw007UDU00T0007s1y000Dk0001y007kyy00Dlw00DkDU00T0007ztzz00Tk0003w007kyy00DVw007kDU00z000Dzvzz00zs0007y007kyy00TVw003kDU00zzzsTzzzz01zw000Dz007kyy00T1w703kDU01zzzwTTDrs07zz000TzU07wyy00z1wDVzyDU03zzzwyD7Xs0Dwzk00zzs0Tyzzy1y1wTlzyDU07zzzwSD3Xk0zsTw03zDw0Tzzzy1y1wzVzyDU0Dzzzw5y11U7zUDzkDy7z0zzzzy3y1xz1zyDU0Tk01w3tzzyDz07zkzw1zkzzzzy7y1zy01wDU0zk01w3vzzyDy01zXztszwzzsy0Dy1zy01wDU0zzzVw1zzzy7s00TXzVsTwznsy0Dy1zw03sDU0DzzVw1tzzy7U0071z1s7szlky07y1zs07sDU05zzVwDU00y27k7k0w1s3kzkky03y1zk0DsDU01zzVsD7zsy07k7k0E1s0kTkOy03y3zU0TwDU01wDVsD7zsy07k7k001s007kzzw0y7y01zyDU01wDVsD7zsy07k7k003s007kzzw0yDw03zzDU01zzXsD7zsy07k7k003s007kzzw0zzw03zzDU01zzXsD7Vsy07k7k001s007kTzw0zzw01zzDU01zzzsD7zsy0DU7k001s007k0y00zzw31rqDUU1zzjsD7zsy0DU7k001s007k0y00yzw3lbmDUw1w0DkD7zsy0DU7k001s007k0y00yFw7k7kDUw1w0DUD7Vsy0TU7k001s007k0y00y1w7k7kDUw1w00AD7zsy0z07k001s007k0y00y1w7k7kDUw1w00TD7zsy1z07k001s007nzzz0y1yDk7kDVw1w00zD7zwy3y07k001s007nzzz0y1zzU7kDzw1zzzzD00Dy7y07k001s007nzzz0y1zzU7k7zs0zzzyD007w3w07k001s007nzzz0y0zz07k7zs0zzzwD007s0s07k001s007nzzz0y0Ty07k1zU0DzzsD00000007k001s003k0000S00003k00000000U", 1)
FindText().PicLib("|<FREE>*200$58.00s3zU0w000300y03k000A01s0D003zkQ7XzwDwDz3wCDzkzkzwDkszz3z3zkz3Vzw7w0D3sC03k0E0QDVs0D0101k07U1w047z00yDzkzkzw07szz3z3zkwDXzwDwDz3ky03k00zwDVs07007zsz7U0w02", 1)
FindText().PicLib("|<芯尘盒>*150$106.0000000000000020000y0T0000000000S0003s1w0003w00003w000DU7k000Dk0000Ts000y0T0000z10007zk07zzzzy0DXwC000zzk0Tzzzzs0yDnw00Dzzk1zzzzzU7szDs03znzs7zzzzy0z3wTk0zzzzwTzzzzs7wDkzUTzzzzw0y0T00zUz1z3zzzzzU3s1w07w3w3y7yzzny0DVbk0zUDk7sDk007k00T001w0z0DUnzzzm003w003U3w0s0Dzzz0007s00007k000zzzw000Tk000000003s07k000z00003w000Dzzz007ly1000Dk000zzzw0ST7sy000z0003zzzk1xwTXs003w000Dzzz0DrksDk3zzzz0000000yT20z0Dzzzw0Dzzzw3tw01y0zzzzk0zzzzkTbk07s3zzzz03zzzz1yT08TUDzzzw0Dzzzw7lw0wy003w000yTDbkz7k3vw00Dk003twyT3wT0Djk00z000Dbntw7Vzzyw003w000yTDbs67zzk0zzzzzwzzzzzs0Tzz03zzzzznzzzzzk0zzs0DzzzzzDzzzzz01zz00zzzzzwzzzzzs000001zzzz7Vzzzzzc", 1)
FindText().PicLib("|<信用点的图标>B6996B-0.70$48.00000Q0000001u0000003xU00000Dzk00000Pyk00000zz800001yzY00006xzy0000Dzw30000Txo10000jzU0U003Tzbkk007zzDsM00DzwD0800rzwDa401zzUPq403zz0NS605zz0Bi20Tzw0Cw50zyw07yT1zyw01cz6zzs001zAzzk007qTzxk00Dczzx000Tkzzz000xUzzvUU3v0zvs047w0Lzs10Ds0/ruAEyk0DzkM1x007zEk3y003zU0Dg001Tk0TM000js0zU000zs1z0000Tw7q0000/yDs00005zzk00007vxU00003yu000001zw000000js000000Kk000000D00000U", 1)
;tag 竞技场商店
FindText().PicLib("|<竞技场商店的图标>*100$71.zzzzy00zzzzzzzzzU00Dzzzzzzzw000DzzzzzzzU0007zzzzzzy0000Dzzzzzzs0000DzzzzzzU1zs0Dzzzzzy0Tzw0Tzzzzzs1zzs0zzzzzzUDszs1zzzzzy0z0zk1zzzzzw1w1zk3Dzzzzs7s3z0C3zzzxUTk7y0S1zzzb0zUDw0z0zzwA3y0Ts1zUTzUM7w0zU7zkTy1kDs1z0DzkDs70zk7w0zzkDUS1z0DU3zzkD1w3y0Q0DzzkQ3s7k000zzzkMDkD0003zzzUUTUQ000Tzzz00y0s003zzzy01w3s003zzzw03s3s003zzzs47k7s103zzzkM7UDk303zzz0s70TU707zzy3kC0z0T07zzs7kC1w0z0DzxUTkA3s1y0DzVVzsM7k3w0Tz3Dzss7U7w0Tw6zzwkD0Tw0TkDzzzUA0zs0S0zzzzU01zs001zzzz003zk007zzzz00C1k00Tzzzz00Q3k01zzzzz01zzk0DzzzzzU7zzk0zzz", 1)
FindText().PicLib("|<水冷代码的图标>13E0F8-0.90$26.00U000M0M0C0C07U7U1w3w0z0z0TkTkDy7w7zVy1zsD0zz00Tzk0Dzw03zz01zzs0Tzy0DzzU3zzs0zzw0Dzz03zzk0zzs07zw01zy00Dz000z002", 1)
FindText().PicLib("|<铁甲代码的图标>FAA325-0.90$32.0S0000Ts1y0Ty0TkDzsTz7zzTztzzbzzTztzzrzyTzzzzjzzzznzzzzwzzvzzTzwDzbzz1zkzzkDVbzk00yTk01zlU01zy000Tzk00Dzy003zz000zzk00Dzw007zz001zzU00Tzs003zy000Tz0003z0000C000U", 1)
FindText().PicLib("|<风压代码的图标>58F42B-0.85$35.003k0000Dk0000zk0003zk000D7Xy00STTw1zzwzw7zzztwDzzj3sDzwS3q000sDzzzE0Szzzzzszzzzzk0Dzzz0000zk3zzw007zzzU07zzzU000zzU0000D0000kD0001kS0007Uw000D1k000DDU000Ty0000Ts0000T00E", 1)
FindText().PicLib("|<燃烧代码的图标>FD1D88-0.82$25.000U000k001k003s001w003y007z007zU07zk07zw07zz07zzk7zzs3zzy3zbzXzVzlzUzwzkTyzk7zTs3zjw0zvy0Txz07wzU3yDk1z7w0z3y0T0zUD0Dk702w700620E", 1)
FindText().PicLib("|<电击代码的图标>FC2BF6-0.90$21.001000E006001k00A003U00w00D001s00T007k01y00Tk03w00zU0Dw01zs0Tzz7zzlzzyDzzXzzszzy03zk0Dw01z00Dk03y00TU03s00y007U00w00D001k00A003000M002000U00U", 1)
FindText().PicLib("|<公司武器熔炉>*150$212.000000000000000y400000003k07003k03003U1k00000001zzDXU3zwDzk0w07s00y03s01z1y01zzzzy0zznxw0zzbzw0D00y00DU0y00TUTU0TzzzzUDzwzTUDztzz03k0Dk03s0Dk0Ds7w07zzzzs3zzDnw3zyTzk0wDzzy0y01w03w0zU1zzzzy0Tznwz0zzbzw0D3zzzUDU0T01z07s0TzzzzU000z70DXtwT03qzzzs3vDzzkTU1z000007s000Dkk3tyT7k1zzzzy0yzzzwDs0Ds00001y3zzzzz0zzbzw3zzs0TXzjzzz7w01z0TzzwTUzzzzzkDztzz0zzzUDszzzzznz00Ts7zzz7sDzzzzw3zyTzkDzjyDwDzvzzxzVU3z1zzzky3zzzzz0zzbzw3zsTXw3zyz0Tzkz0TsTzzwDUzzzzzk01yDs0zwTkTUzzDk7zsDs3w00007s0007k000TXy0TzDvnwDznw1zy7w0y00000y00y1w000DsTU7j1xzT7jUz0TD1z0707zzkDU0DUT00zzzzzlzkCTnVvsDzzlUzU0U1zzy3s3ns7k0TzzzzyTw1DyESy3zzw0Tk000TzzVy0wzxw07zzzzzVT07zk1jUzzz07w0007zzsDUDjzT00zzzzzs7k7zz03sDzzk3y0M01zzy7s3vzrk01zsTy01w3zTy0y3zzw0z0y00T0TVy0yzxy00Dw1zU0TXzXzUTUz0T0TkDk07k7sTUDjzDU0Dy0Dy07xzszs7wDU7kDs3y01w1y7s3vs3s0Dz03zs1zTzzy1zXs007w0TU0T0TVy0yy0y47zzbzzUzvzzz0Twy001y07w07zzsDUDjUDVUzztzzsDzTzzk7zDU00zUDzU1zzy3s3vs3wSDzyTzw3zlzzk3zzs00zzzzs0TzzVy0yzyTDVzzbzy1yyT1w0yzy00Dzzzz07zzsTUDzzbnsDbtwT0TD7kT0Tbz003zzzzk1w027sDzztyy3tyT7kDlVw7k7ljk00zzzzy0T00zy7zzyDz0zzbzw7sETzw3w3w007zzkTk7U07zVzzz3zkDztzz1y07zz0y1y001z007w0001zkDzk0Tw3zyTzkD01zzk7UDU000000w0000Tw3y003y0zzbzw1U0Tzw1k1k000000A00007w0U000T0DblwT0807kT080A008", 1)
FindText().PicLib("|<代码手册选择宝箱的图标>*200$88.00000Dzzy00000000000zjww00000000007zzzy0000000003jzzzs000000000Tzzzzg000000007Tzzzzs00000000zzzzyzw0000000Dzyzrzzy000000Djzzzzzyz000007zzlz3zzzzs000TvzU3sDk7zjk003vzk0zUy03zzw07zzs0Ty3zk1zzy3xzw0DzsDzs0zzThzy0Dzw0nzw0Tzrzy07zw040zy07zzz07zy0000TzU1zz01zzU0000Tzs0TU1zzw01g01zzy0Q0zzz00A801zrzU0Dzz000zU00Tvz0Dzs0001w0000zzvzs0000000000Tzzy000000000007zz0000000000003y", 1)
;tag 废铁商店
FindText().PicLib("|<废铁商店的图标>*150$67.zzy000007zzzzy000003zzzzz000000zzzzz000000TzzzzU000007zzzzU000001zzzzk000000zzzzk3zzzz0Dzzzk3zzzzk7zzzs1zzzzs1zzzs1zzzzy0zzzw1zzzzz0Dzzw0zzzzzk3zzy0zs3zzs1zzy0Tw0zzy0Tzy0Ty07zzUDzz0Dz00zzk3zz0DzU07zw1zzUDzs01zy0TzU7zz00TzU7zU7zzk0Dzk3zk3zzy07zw0zk3zzzk3zz0Ts1zzzw1zzU7s1zzkDzzzs3w1zzs1zzzw0w0zzw0Tzzz0A0zzy03zzzU60Tzz00Tzzs00TzzU03zzw0U7zzw00zzy0E3zzz00Tzz0Q0zzzs0Dzz0D0Tzzz07zz0DU7zzzs3zzU7s1zzUy1zzU7w0zzk7zzzk7z0Dzs0zzzk3zU7zw0Dzzk3zs1zy01zzs1zy0zz00Dzs1zz0Dzk03zw0zzk3zy00zw0zzs1zzU0Ty0zzy0Tzw0Dy0Tzz0DzzU7z0Tzzk3zzw3z0Dzzw1zzzzz0Dzzy0TzzzzU7zzzU7zzzzU7zzzk3zzzzk7zzzw0zzzzk3zzzy0000003zzzzU000001zzzzs000001zzzzw000000zzzzz000000zzzzzU00000zzzzzs00000Tzz", 1)
FindText().PicLib("|<珠宝>*150$75.000000000000000000000000000000000000000007k000DU000000y0001y000zzbrk000Dk007zwyy0001z000zzbrk0Tzzzzs7zwyy03zzzzz0TzjzzsTzzzzs0T1zzz3zzzzz03sDzzsTzzzzs0T3zzz3w000z03sTzzkTU007s0T7sy03zzzzz0TzS7k0Dzzzzk7zsky00Dzzzk0zz67s01zzzy07zvzzzUDzzzk0TzTzzw00Dk000T3zzzU01y0003sTzzw00Dk000T07zk07zzzU03s0Ty00zzzw00T07zk07zzzU03s1zz00zzzw00TsDzw07zzzU03zXzzU00Dns03zwzzy001yz00zzjrrs00Dnw07zzwyTU01yDk0TtzbnyDzzzzk3kDsyDVzzzzy0E0y7ksDzzzzk003Uy21zzzzy00007k0Dzzzzk0000y000000000000000000000000000000000000000000000U", 1)
FindText().PicLib("|<黄色的礼物图标>*175$36.07U1w00Ts7y00zwDz00sST7U1kDQ3U1k7w3U1k7s3U0s3k7UTzwDzyTzwDzzzzwDzzzzwDzzzzwDzzzzwDzzzzwDzzzzwDzzzzwDzzzzwDzzzzwDzzzzwDzzTzwDzy0000000000000000000000003zwDzs3zwDzs3zwDzs3zwDzs3zwDzs3zwDzs3zwDzs3zwDzs3zwDzs3zwDzs1zwDzkU", 1)
FindText().PicLib("|<资源的图标>*190$45.zk000007s000000y1zk0007Uzzk000sDzz00067zTw000VzYzk004Dltz0003tzns000QzzbU007DzzA000sTzVk0070zli001s1sxk00D00Ti001s0Dxk00D03zi000s0Txk00703zi000s0TtU00303ww000S0SDU00Vw37s004Dw3y000kzvzU0033zzs000A7zy0000kDz0000U", 1)
FindText().PicLib("|<黄色的信用点图标>E5C99C-0.61$26.0k000TzU07zy0AzzsDzzz1zzzUDzbk3zw01zD00Tls1ryT0zznsTyyS7zbnlzswSTy7brzVwxxwD7zT1szrsDDsz1vy7wTz1zzzsDzzz1zzvUDzyE0TzUU", 1)
FindText().PicLib("|<团队合作宝箱图标>*130$123.0000000007zU00000000000000000DzzU0000000000000000DzDzU0000000000000007w03z0000000000000000s001s000000000000000Dk00TU00000000000000DzVwzzU0000000000000DyDkzzzU000000000000Dy0S3s7zU00000000000Tw03kS07zk0000000000Dw07y3y03zk000000000zw07z0Ty03zw00000001zs0Dz000y03zw0000000zs0Dy0000S01zs00001yzk0Dl00004T00zvy003zzk0DUE00000T01zzy00zbk0D0E01400UD01y7w0T060D0E00EU000D0207s700MT00000s00007U00DVk0TT0000000000077U0SM0Dz6000000000027tU1z00Hm000000000000A00Dz0z70000000000006703zwTs8011000004800Uz1zzrzU0000000000008AwTzxw7Y00000000000181zzzz07s00000000000w07zzzk07k0000000000y00zzzy007U000000000S00Dzzzy007U00000000S00Dzzzzy00Dy0000007z00Dzzzzzw00Dy000007z00Dzzzzzzw00Ty02403zU0Dzzzzzzzw00Ts0101zU0Dzzzzzyzzs00TU000TU07zzzzzy3zzs00TU00Dk07zzzzzzkTzzk00T007k07zzzzzzy3zzzk00zETk07zzzzzzzkTzzzk01y3s03zzzzzzzy3zzzzk0zsz07zzzzzzzTUTzzzzkC0063zzzzzzzlU3zzzzzXU00FzzzzzzzyA0TzzzzzQ001TzzzzzzzlU3bzzzzzU00DzzzzzzzyA0Q7zzzzzk0RzzzzzvzzlU3UDzzzzz07zzzzzwzzyA0M0DzzzzzzzzzzzwPzzlU300Tzz7zzzzzzzyDzzyA0M00Tzsbzzzzzzz9jzzlU3000Tz4Tzzzzzz09zzyA0M000zsVzzzzzz0DDzzlU30001z43zzzzzX3zzzyA0M0001sUDzzzzUjzzzzlU30000140zzzzVDzzzzyU", 1)
FindText().PicLib("|<保养工具箱图标>*150$70.08000007U3k01xzzz00y0TU07rzzw03w1y00zTzzk7zzzzU3tzzz0zzzzz0Tbzzw3zzzzw1wT07k7zzzzkDlw0T0Tzzzy1y7k1w007w007sT07k3zzzz0zVzzz0Dzzzw7y7zzw0zzzzkzsTzzk1zzzy3zVzzz007s00Dy07s07zzzzyTs0DU0TzzzztzU1y01zzzzzWyTzzz7zzzzy3tzzzw7zkDy0DbzzzkTy0Tw0yTzzz7zk0zy3tzzzsTzkTzwDU7zk0zz1zzUy0zzU3vw7tw3s7zz06DkTVUDUzzy00z1y00y7zzw07s7s03tzDjs0TUTU0DzwyTk7y1y00zzXsz1zk7s03twDVsDy0TU0DXUy30Tk1y00y03s00y07s01s0DU01U0DU2", 1)
FindText().PicLib("|<企业精选武装图标>*150$70.000T200D07k0DztwQ01w0T01zzbvs3bk1w07zyTjkTT0Dk0TztyTVzxzzzUzzbty3zrzzy000TXU7TTzzs001y609xzzzbzzzzy07k3w0Tzzzzs0T07k1zzzzzUDw0T07zzzzy3zk3w0TzzzzszzDzzs000y03zwzzzU1w3s07rnzzy07kDU0MTDzzkST0y001wC001xzvs003ns007rzjU000Dk00TTyy03zzzzzlxzvw0Dzzzzz7rzbk0zzzzzwTT0T01zzzzzVxw1w803zT3s7rk7kk0zsyTkTT0TXlzy3zy1xzwyTDzs7zU7zzntwTzUTw1zzzDrkzyzzsDzzwTy07zszyzzzVzs0zzVzxzy03zU3zy3zbw007w0Dw01wE000DU0w000m", 1)
;tag 招募
FindText().PicLib("|<招募·SKIP的图标>*210$32.DzvzzlzwDzwDz1zz0zk7zk3w0zw0T03z03k0Tk0A03w0100D00001k000040000000000E0000A0100D00k07k0Q03w0T03z0Dk3zkDw1zw7z0zz7zkzznzyTzy", 1)
FindText().PicLib("|<确认>*200$87.zzzyDzzzzzzy7zzzzzVzzzzDzzkzzk03wDzzzkTzy7zw00D1zzzy1zzkzzU03s00zzs7zy7zw00T007zzUTzkzzz3zk00zzy1zy7zzsTw7sDzzsDzkzzz3zVz1zzzVzy7zzkzsTkTzzyTzkzzy7y3y7zzzzzy7zzkzU000Tzzzzkzzy7s0003zzzzy7zzVz0000TzzzzkzzwDk0003s07zy7zzVy0T3wTU0zzUzzs033sTXs07zy7zz00sT3wTU0zzUzzs073sT3zy7zw3zy00s000TzkzzUTzkT70003zy7zw3zw3ss000TzkzzUDz0T71sT3zy7zs1zs3ssT3wTzkzz0DzUT73sTXzy7zs0zw3ssT3wTzkzz27zwT73sT3zy7zkEzzXss000Tzkzy23zwT70003zy7zksTzXss000Tzksw71zwT60003zy67UwDzVskz3wTzk0sDUzw067sTXzy061y7zU0kz3wTzk3kTkTw047sTXzw0w7z1zU01z3wTzUT0zs7wTsDsTXzs7kDzUTXz3z30Dz1w3zy1wTkTsE3zwz0zzs7ry7z20Tzzw7zzVzztzzk7zzznzzyA", 1)
;tag 战斗
FindText().PicLib("|<进入战斗的进>*150$53.zTzzUTkDzsDzy0z0TzUDzw1y0zy0Dzs3w1zw0Dzk7s3zw0DzUDk7zw0Dz0TUDzw0Dy0z0Tzw0Q00000zw0k00000zw3U00001zwD000003zsy000007zzw00000Dzzs00000Tzzzs1s01zzzzk7s3zzzzzUDk7zzzzz0TUDz00Ty0z0Ty00zw1y0zs01zs3w1zk03k00001U0700000100C00000300Q000007y0s00000Dw1k00000Ts3U00000zk7000003zUDw0zUDzz0Ts1z0Tzy0zk3y0zzw1z0Dw1zzs3w0Ts3zzk7s1zk7zzUDU3zUDzz0S0Dz0Tzy0w0Ty0zzs0w1zw0zz00w7zs1zw00QTzk7zk00Bzzzzv0000DzU000000000000s000000E3w000000kDy000001kTz000003VzzU0000Dbzzz000Tw", 1)
FindText().PicLib("|<灰色的进>8A8886-0.90$58.0U00TUDU007001y0z001y007s7w00Dw00TUTk00Ts01y1z000zk07s7w001zU0TUTk003z03y1z0007yDzzzzw00Dkzzzzzk00S3zzzzz001kDzzzzw0000zzzzzk0003zzzzz0000Dzzzzw00000zUTk000001y0z0000007s3w000000TUTk01zz01y1z007zw07s7w00Tzk0zUDk01zz03z1zUU7zwTzzzzy0Tzlzzzzzs01z7zzzzzU07wTzzzzy00Tlzzzzzs01z7zzzzzU07w0Tk7w000Tk1y0Tk001z0Ds1z0007w0zU7w000Tk7w0Tk001z0Tk1z0007w3z07w000TkTs0Tk001z3z01z0007w7w07w000zkDU0Tk007zkQ01z001zzUU00000Dzzk000001zzzy007zkDyDzzzzzz1zkDzzzzzw5y0TzzzzzU3k0Tzzzzy0700Dzzzzs0M001zzzk08", 1)
FindText().PicLib("|<灰色的AUTO图标>7F8586-0.90$39.003z00003zz0001zzy100zzzwQ0DzzzrU7zUDzw1zk0DzUDs00Ty3y001zkz000Ty7s007zly001zzDU001zvw0000zT00000Ps00000T000003s0000Sy00003zk0000Ty00003vs0000T300003s00000Tk00003vs0000zTs0007nzw001yTzU00DVzs003wDy000z1zk00Ts7zU07y0zz03zU7zzzzs0tzzzw023zzz0007zzU0007zU04", 1)
FindText().PicLib("|<灰色的射击图标>8F8F8D-0.90$56.0000TU00000007s00000001y00000000TU00000007s00000001y00000000TU00000007s0000001VyC000001sTXs00001y7szU0000zlyDw0000TsTVzU000Dw7sDw0007w1y0zU003y0TU7w000z07s0z000TU1y07s007k0TU0y003w07s0Dk00y00001w00000000000000000000000000000000000000Dzzw00Dzzzzzz003zzzzzzk00zzzzzzw00Dzzzzzz003zzzzzzk00zzzk00000000000000000000000000003k00003k00y00001w00Dk0TU0z001w07s0DU00TU1y07s003w0TU3w000zU7s1z0007w1y0zU000zkTUzk0007y7sTs0000zlyDw00007wTXy00000T7sy000001lyC0000000TU00000007s00000001y00000000TU00000007s00000001y00000000TU00000007s0002", 1)
FindText().PicLib("|<灰色的锁>434343-0.90$35.007k0001zw000Dzy000zzy003zzy007yDw00Tk3w00y03s03w07s07k07k0DU0DU0T00T00y00z01w00y03s01w07U03s0000000000007zzzzszzzzztzzzzzrzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzlzzzzz1zzzzw1zzzzs3zzzzk7zzzzkDzzzzkzzzzzXzzzzz7zzzzyDzzzzwTzzzzszzzzzzzzzzzzzzzzzzzzjzzzzzTzzzzwTzzzzkTzzzz4", 1)
FindText().PicLib("|<放弃战斗的图标>*200$44.zzzzzy1zzzzzz07zzzzzU1zzzzzs0Dzzzzy03zzzzzU0zzzzzs0Dzzzzy03zzzzz00zzw0000Tzy0000Dzz0000DzzU000Tzzk0007zzs3k03zzw1s01zzz0w00zzzsS00DzzzD001zzzzU00Tzzzk003zzzs010Tzzw00s3zzy00T0Tzz003sTzzU00TDw00003zz00000Tzk000U3zw000Q0Tz000DU3zk007w0TzzzzzU3zzzzzw0zzzzzzUDzzzzzw3zzzzzz0zzzzzzkDzzzzzw3zzzzzz0zzzzzzkDzzzzzw3zzzzzz0zzzzzzkDzzzzzw3zzzzzz0zs", 1)
FindText().PicLib("|<LV.>*200$71.1zzzs7zzzkDy3zzzs7zzz0zw7zzzk7zzy1zsDzzzkDzzs7zkTzzzUDzzkDzUzzzzUTzz0zz1zzzz0Tzw1zy3zzzz0zzs7zw7zzzy0zzUDzsDzzzy1zz0zzkTzzzw1zw1zzUzzzzw3zs7zz1zzzzs3zUDzy3zzzzs7z0zzw7zzzzk7w1zzsDzzzzkDs7zzkTzzzzUDUDzzUzzzzzUT0zzz1zzzzz0Q1zzy3zzzzz0s7zzw7zzzzy0UDzzsDzzzzy00zzzkTzzzzw01zzzUzzzzzw07zzz1zzzzzs0Dzzy1zzzzzs0zzzw3zzzzzs1zzzs3zzzzzk7zzzs3zzzzzkDzzzk0001zzUzzzzk0001zzVzzz1k0003zz7zzy3k0007zzDzzw7s000DzyzzzsDw000TzzzzzkE", 1)
;普通战斗、无限塔胜利或失败会出现该图标
FindText().PicLib("|<TAB的图标>*200$49.01zzzzzzU0zzzzzzk0Tzzzzzs0Dzzzzzw07zzzzzy03zzzzzz01zzzzzzU0zzzzzzk0Tzzzzzs0Dzzzzzw07zzzzzy03zzzzzz01z00zzzU0zU0Tzzk0Tk0Dzzs0Ds07zzw07w03zzy03y01zzz01z00zzzU0zU0Tzzk0Tk0Dzzs0Ds07w0007w03y0003y01z0001z00zU000zU0Tk000Tk0Ds000Ds07w0007w03y0003y01z0001z00zU000zU0Tk000Tk0Ds000Ds07w0007w03y0003y01z0001z00zU000zU0Tk000Tk0Ds000Ds07w0007w03y0003y01z00zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU0000000000000000000000000000000000000000U", 1)
;特殊竞技场快速战斗会出现该图标
FindText().PicLib("|<重播的图标>*200$66.zzzzz0Dzzzzzzzz000Tzzzzzzw0007zzzzzzk0000zzzzzz00000Dzzzzw000007zzzzk00C001zzzzU0Dzy00zvzz01zzzk0Dnzy07zzzw07Xzw0Tzzzz033zs0zzzzzk01zk3zzzzzs01zU7zzzzzw01z0Dzzzzzy01y0Tzzzzzz01y0zzzzzzz01w0zzzzzzy01w1zzzzzzw00s3zzzzzzs00s7zzxzzzk00k7zzwzzzw00kDzzwTzzzz0kDzzw7zzzzzUTzzw3zzzzzUTzzw1zzzzzUTzzw0zzzzzUTzzw0Dzzzz0zzzw07zzzz0zzzw03zzzz0zzzw01zzzz0zzzw00Tzzz0zzzw00Dzzz0zzzw007zzz0zzzw001zzz0zzzw001zzz0zzzw007zzz0zzzw00Dzzz0zzzw00Tzzz0zzzw00zzzz0zzzw03zzzUUTzzw07zzz0UTzzw0Dzzz0UTzzw0zzzz0kDzzw1zzzy0kDzzw3zzzy0kDzzw7zzzy1k7zzwTzzzw1s3zzwzzzzw3s3zzxzzzzs3w1zzzzzzzk7w0zzzzzzzk7y0TzzzzzzUDy0Tzzzzzz0Dz0Dzzzzzy0TzU3zzzzzw0zzk1zzzzzk1zzs0zzzzzU3zzw0Dzzzz07zzy07zzzw0Dzzz00zzzk0TzzzU07zw00zzzzk000001zzzzw000007zzzzz00000Tzzzzzk0001zzzzzzy000Dzzzzzzzs03zzzzU", 1)
;拦截扫荡会出现该图标
FindText().PicLib("|<ESC>*150$62.zzzzzzzzzzzzzzzzzzzzzU03w03zU0Tk00y00Tk01w00D003s00T003k00y003k00w00DU00w3zz1y3s7kD0zzkTUy3y3kDzw7wDUzUw3zz0zzsDsD00Dk0zy3zzk03w00zUzzw00zU07sDzz00Dw00y3zzk03zk07Uzzw3zzzs1sDzz0zzzzUS3y3kDzw7s7UzUw3zz1y1sDsD0zzkTUS1w3k00w007U00w00D001s00D003k00z007k00y00Tk01y00Ds0Dz01zzzzzzzzzzzzzzzzzzzzzs", 1)
;判断胜利状态
FindText().PicLib("|<白色的下一关卡>FFFFFF-0.70$155.0000000000000000000000D00000000000000000600D0000T00000000000000000y00z0000y007zzzzzk00000001y01w0001w00DzzzzzU00000001y07s0003s00Tzzzzz000000001w0DU0007zzszzzzzy000000003w0z0000Dzzlzzzzzw000000003k1w0000TzzU00y00000000007zzzzk000zzz001w0000000000Dzzzzk001zzw003s0000000000TzzzzU003s00007k0000000000zzzzz0007k0000DU0000000001zzzzy000DU0000TU000000000003w00000T00000zk000000000007s003zzzzzs01zs00000000000Dk007zzzzzk03zw01zzzzzz000TU00DzzzzzU07zy03zzzzzy000z000Tzzzzz00Dzy07zzzzzw003y000zzzzzy00TDz0DzzzzzsTzzzzz000T00000yDz0Tzzzzzkzzzzzy000y00001w7z00000001zzzzzw001w00003s3y00000003zzzzzs003s00007k3s0000000003zU00007zU000DU1U0000000007zU0000Dzs000T000000000000Dz00000Tzw000y000000000000zz00000zzy001w000000000003zz00001wTz003s00000000000DszU0003sDz007k00000000001zlzU0007k3w00DU0000000000Dz1zk000DU1k00T00000000001zw1zs000T00000y0000000000TzU0zz000y00001w0000000003zy00zy001w00003s0000000003zk00Ts003s00007k0000000003y000TU007k0000DU0000000003U0007000DU01", 1)
FindText().PicLib("|<编队的图标>*200$53.zw3zzz0Tzzk1zzw0Tzy01zzU0Tzs03zz00Tzk0Dzz00TzU0S0D00zy01s0D01zw07U0C01zs0C00C03zk0w00Q07zk1s00w0TzU3U01s0zz07003k3zz0C007U7zz0S00D0TzzUw00S3zzz0s00sDzzs1s03k3zz03s0D01zw03s0y01zk07s7w01z00TU7w01y01w03w03s07k01w07k0D001s0700w001s0C01k001k0Q07U003k0M0C0007U0k0w000701U1s000C0303U000S04070000Q000C0000s000w0001k001s0003k003k0007U007U000D03zz0000Tzzzy0000zzzzs0001zzzzk0003zzU", 1)
;红圈
FindText().PicLib("|<红圈的上边缘黄边>FFFF40-0.90$43.00000000000000000000000000000000000000znz000zztzzsDzzwzzzzzzyTzzzzzzDzzzzzzbzzzzzznzzzzzztzzzzy0001zz000000s00000000000000000000000000000000000000000000000000000000000000000000000E", 1)
FindText().PicLib("|<红圈的下边缘黄边>FFFF40-0.90$44.000000000000000000000000000000000000000000000000000A000000/w00000zzzU00TzzzzyTzzzzzzbzzzzzztzzzzzzyTzzzzzzbzzz7zztzzy01zyTzU0001Y000000000000000000000000000000008", 1)
FindText().PicLib("|<红圈的左边缘黄边>FFFF40-0.90$27.00zU007y000zk007w001zU00Dw001zU00Dw001z000Ds003z000Ts003z000Ts003z000Ts003z000Ts003z000Ts003y000Tk0000000Tk003z000Ts003y000Tk003z000Ts003z000Ts003z000Ts003y000Ds001z000Ds001z000Ds001z0007w000zk007y0U", 1)
FindText().PicLib("|<红圈的右边缘黄边>FFFF40-0.90$20.0zU0Ts07y01zU0Ds03z00zk0Dw03z00Tk07w01z00Ts07y01zU0Ts07y01zU0Ts07y01zU0S000001zU0Ts07y01zU0Ts07y01zU0Ts07y01zU0Ts07w02z00Tk03w00z00Dk03w04y01DU0Ns01y0U", 1)
;tag 模拟室
FindText().PicLib("|<模拟室>*150$96.wDsS7z3zzzzzzVzzwDsQ7z3szwDzzUzzwD000z3sTwDU0001wD000z3sRwDU0000wD000z3s1wDU0000sD001z3s0wDU000001sQ7s0M0wDU000001zzzs0MEMDVzzzU01001s0MMMDU000001001s0MMMDy000DsD001z3sM8Dy000DsD3z1z3sQ8Dy000Ds7001z3sQ0TzkDUzs7001z3sQsTzUTUTk3001z0MTsTy000Dk11z1y0MTkTw0007k0001s0MTkTw0003U0001s0MTkTy00y7U1001s1sRkTyTVzT0/z1zs3sFUTzzVzz0Dz1zz3s0UDw00070C000z3s00Dw00070C000z3s007w0007YC000z3k307w0007gDw0Dz3kC07zzUzzwDs07z3UQ23zzVzzwDUA1z3Us63U0000wA0S0M3lk73U0000wA0z0w3vsD3U0000wC3zVw7zwTDU0000wDDztwTzzzzzzzzzU", 1)
FindText().PicLib("|<结束模拟的图标>#659-0.90$45.000000z000000Tw000003zk00000zy000007zs00000zz000007zs00000zy000007zk00Dzzzw003zzzz000zzzw000DzzzU003zzzw000z3zz000Dkzzk001wDzw00073zzU000kzzy0000Dzzs0003zzzU000zzny000DzwDs003zz0z000zzw3k00DzzkA0zzzzz007zzzzw00zzzxzk07zzz3z00zzzkTw07zzw0zk000007z000000Dw000000zU000007w000000TU000003w000000TU000003w000000TU000003w000000TU000003w000000TU000003w0U", 1)
FindText().PicLib("|<开始模拟的开始>*140$73.zzzzzzzDzyzzzzzzzzzVzy3zw00001zUzz1zy00000TkTz0zz00000DsDzUzzU00007w7zUTzk00003y7zkSDzw7y3zy1jkC3zy3z1zw01sD1zz1zUzy00s7kTzUzkTz00Q7s7zkTsDzU0A3y3zsDw7zw64000zw7y3zy70000Ty3z1zz300007z1zUTz1UU000000007UkE0T0000003kMNzzl000001sQDzzzU00000sA7U01zw3z0zw23U00Ty3zUzz01k00Dz1zkTzk1s007zUzsDzw0w003zUTw7zz0S3z1zkDy3zzk73zUzkDz1zzs1VzkTs7zUzzs0EzsDs7zkTzs08Tw7s3zsDzs4ADy3s3zw7zs3C001k3zy3zs3b000s3zz1zw3zU00S3zzUzz3zk00DXzzkTzXzsDw7vzzsDzzzwDz3U", 1)
FindText().PicLib("|<快速模拟的图标>*200$71.zzzzz00zzzzzzzzz0007zzzzzzzk0001zzzzzzy00000zzzzzzk00000Tzzzzz000000Dzzzzs000000DzzzzU000000Dzzzy00000007zzzs00000007zzzU00000007zzy000000007zzs000000007zzU00000000Dzy000000000Dzs000000000Dzk000000000Dz0000000000Ty0070060000Ts00T00S0000zk01z01y0000z007z07z0001y00Dz0Tz0001w00zz0zz0003k00zz0zz0007U00zz0zz0006000zz0zz000A000Tz0zz000M000Tz0zz000k000Tz0zz000U000Tz0Tz0000000Tz0Tz0000000Tz0Tz0000000Tz0Tz0000000Tz0Tz0000000zz0zy0000001zw3zw0000007zkDzk000000Tz0zz0000001zw3zw0000007zkDzk00E000zz0zz001U003zw3zs003000DzkDzU007000zz0zy000C003zs3zs000Q00DzkDzU001w00zz0zy0003s00zs1zs0007k00zU1zU000Tk00y01y0000zU00s01s0003zU00U01U0007z0000000000Tz0000000000zz0000000003zy000000000Dzy000000000zzy000000003zzy00000000Dzzy00000000Tzzy00000001zzzy0000000Dzzzz0000000zzzzz0000003zzzzz000000TzzzzzU00003zzzzzzs0000Tzzzzzzw0003zzzzzzzz000zzzzzzzzzw1zzzzzk", 1)
FindText().PicLib("|<跳过增益效果选择的图标>*150$42.E008000w00S000y00T000zU0Tk00zk0Ts00zw0Ty00zy0Tz00zzUTzU0zzkTzs0zzsTzw0zzyTzz0zzzzzzUzzzzzzszzzzzzwzzzzzzyzzzzzzzzzzzzzyzzzzzzwzzzzzzszzzzzzUzzyzzz0zzwzzw0zzkzzs0zzUTzk0zy0Tz00zw0Ty00zk0Ts00zU0Tk00y00T000w00S000U", 1)
FindText().PicLib("|<模拟结束的图标>*100$63.000Tzzzzzs000Dzzzzzzk003zzzzzzzU00zzzzzzzy007zzzzzzzk01zU00007y00Ds00000Ds01y000001z00Dk000007s01y000000z0000000007s000000000z0000000007s000000000z0000000007s000000000z0000000007s00A000000z003U000007s00w000000z00DU000007s07w000000z01zU000007s0Tw000000z07zzzz0007s1zzzzs000z0zzzzz0007sDzzzzs000z3zzzzz0007szzzzzs000zTzzzzz0007zzzzzzs000zTzzzzz0007szzzzzs000z3zzzzz0007sDzzzzs000z0Tzzzz0007s1zzzzs000z07zzzz0007s0Tw000000z00zU000007s03w000000z007U000007s00Q000000z001U000007s000000000z0000000007s000000000z0000000007s000000000z0000000007s000000000z00Dk000007s01y000001z00Ds00000Ds01zU00007y007zzzzzzzk00zzzzzzzw003zzzzzzz000Dzzzzzzk000Tzzzzzs4", 1)
FindText().PicLib("|<模拟室·不再显示>*200$42.00000000000000000000003zzzk00Dzzzy00Tzzzz00z000TU1s0007k3k0003k3U0001s7U0000s7U0000s700000s700000s700000s700000s700000s700000s700000s700000s700000s700000s700000s700000s700000s700000s700000s700000s700000s700000s700000s7U0000s7U0001s3k0001s3s0003k1w0007U0zzzzz00Tzzzy007zzzw0000000000000000000000U", 1)
;tag 模拟室超频
FindText().PicLib("|<红框中的0>*90$43.z00000Tz000007z3zzzzVz3zzzzsT3zzzzy73k0007V3k0001s3k0000S1k00007Uk00001kM00000sA00000Q600000C30000071U0Ds03Uk0Dz01kM0Dzk0sA0C0s0Q6070A0C30306071U1U303Uk0k1U1kM0M0k0sA0A0M0Q6070A0C303UC071U0zz03Uk0Dz01kM01y00sA00000Q600000C30000071U00003Uk00003kQ00003sD00003s3k0003sEw0003sQDzzzzsT3zzzzsTkzzzzsTw00000Tz00000Tk", 1)
FindText().PicLib("|<BIOS>*190$79.001zkzw1zzU03U00TsTs0DzU00k007wDk01zU008001y7k00TU000Dzkz3kDs7kzzU7zsTVsDy3sTzs3zwDksDzUwDzzVzy7sQDzsS7zzk003wADzwD003s001y67zz3k00Q000T33zzVw0060007VVzzkz0013zy3kkzzsTzzk1zzVsMTzwDzzw0zzsQC7zwDzzy0TzwC73zw7zzz0Dzw73Uzy7kzzU7zy7VsDw3sDzk3zy3ky0s3y3zU0003sTU03z000E003wDs03zk00M003y7z07zy00Q007z7zwzzzk1z", 1)
FindText().PicLib("|<蓝色的25>00AEFD-0.80$69.zzzzk0TzzzzbzzzzU3zzzzwzzzzz0Tzzzzbzzzzs3zzzzwzzzzzUTzzzzbzzzzy3zzzzw0000TkTU00000001y3w00000000DkTU00000000z3w00000000DkTU00000001y3w00000000TkTU00000zzzw3zzzs01zzzzUTzzzw0Tzzzs3zzzzsDzzzz0TzzzzVzzzzU3zzzzyTzzzk0Tzzzzny000000003zzU000000007zs000000000zz0000000003zs000000000zz0000000007zs000000000zz000000000Tzzzzzy3zzzzyzzzzzkTzzzzrzzzzy3zzzzwzzzzzkTzzzz7zzzzy3zzzzU00000EDzw004", 1)
FindText().PicLib("|<开始模拟>*200$185.zzzzzzzzzzzzzzzzwzzzzrzzzzzzzzzzzzzzzzzsTzz7zzzkTz1y3zzUzzzzzzzzzzzzzzkTzw3zzzUzy3w7zz1zzzz1zzzzzzzzzVzzs7zzz1zw7kDzy3w3zy3w000000Tz3zzUTzzy3w0000zw7s7zw7s000000zw7zz0zzzw7s0001zsDkSTsDk000001zsDzw3zzzsDk0003zkTUEzkTU000003zkTzs7zzzkTU0007zUz0UzUzbk0z0DzzUzzkTXzzUzy3w7zz1y11z1zzkDzUzzz1zz0w3zU07w7sDz00Q31y3zzUzz1zzU01w3w7z00DsTkzy00s63w7zz1zy3zz003s7s7y00Tzzzzw01kA7sDzy3zw7zy007UTs7w00s000Ds03UQ7kTzw7zsDzw00D1zsDs01k000Tk070sD0zzsDzkTzs00Q3zkDzUzU000zz1y1kC3zzkTzUzzy3Uk7U0Tz1z1zz1zy3w3kQ7zzUzz1zzwD10000Ty3y3zy3zw7s7UsDzz1zy3zzkS60000zw3w7zw7zsDkDUkTzy3zw7zzUwA0000zk3s000DzkTUT1Uzzw3zkDzz1kQ0001zU7k000TzUz0yT1zDk7w0Dzy7Us1zy3z07U000zz1y3zy3s0000003sD1rzzyTw071zz1zy0Q3zs7k0000007kS3zzzzzs0C3zy3zw0M7zkTU000000DUwDzzzzzk0A0007z00kDzUz0000000T1kTzzzzz088000Dk01UTz1zzs3zk7zy1Uy0007y0Mk000TU070zy3zzkDzkTzw01w000Ds0nU000zU1y3xs3zzUTzUzzw03s000Tk1zzsDzz03w3nk7zz0zz1zzw0Dk000z03zzkTzyA7sC3UDzy3zy3zzy0TUzy1w07zz0zzzsDk860Dzs7zw7zzy0z1zy3s8DU0003zkTU0A0TzkDzsDzzw1y3zw7skT00007zUz00k0Tz0TzkTzzs1w7zsDlUy0000Dz1y03U0zy1zzUzzzk1sDzkTr1w0000Ty3w0S10zs3zz1zzz01kTzUzi3zy01zzw7s1w31zUDzy3zzw03Uzz1zw7zw03zzsDU7kC3z0Tzw7zzs471zy3zsDzkA3zzkT0z0Q3w1zzsDzzUQS3zs7zkTy0Q1zzUy3w1w7k7zzkTzw1xw000DzUzk1s0zz3wDk7sC0DzzUzzk3zs000Tz1s07w0DU7wz0Dk80zzz1zzUDzk000zy3k0zw0T0Dzy0zkM3zzy3zzUzzU001zw7U3zw1y0Tzy3zXsDzzw7zzXzz1zw3zsDUzzy7w1zzzDzTtzzzsDzzTzy3zw7zkTDzzzTwTzzzzzy", 1)
FindText().PicLib("|<模拟室·链接等级>*150$86.00M0k001UA00007670C0s0s701k01xlk3XzsDzzkQzwTzzkszz7zzwCDzDnzwT7zXiQs3UtX0n0DllktbC1mCss0q3wAs0vv0NnC7zRUCTzkzzwDsntzzz3bzw7zz3yAzCxzktzz01k0z3bXX1UD1k3zzz3VsPykMDzzwzzzkzTCzhznvzz0070TrnXXTwyTzkSTyDlzkskw3VlkTzzXUvwDA60sys7zzs1yS3vVUC7y0D1k3zbUzwM3UTU1sQ3xnyCzzntzy0Cz0wTvnATwwTXU1DU0CwQ00C660801k0040U", 1)
FindText().PicLib("|<不选择的图标>*140$58.000000008030000001k0S000000DU3w000001z0Ts00000Dy3zk00001zwTzU0000Dzvzz00001zzbzz0000DzwDzw0001zzUTzs000Dzw0zzs001zzU1zzk00Dzw03zzU01zzU07zz00Dzw00Dzy01zzU00Tzw0Dzw000zzs1zzU000zzkDzw0003zzVzzU0003zzDzw00007zzzzU0000Dzzzw00000TzzzU00000zzzw000001zzzU000003zzw0000007zzU000000Dzw0000001zzU000000Dzw0000001zzU000000Dzw0000001zzU600000Dzw0w00001zzU7s0000Dzw0zk0001zzU7zU000Dzw0zz0001zzU3zy000Dzw0Dzw001zzU0Tzs00Dzw00zzk01zzU01zzU0Dzw003zz01zzU007zy0Dzw000Dzw1zzU000TzsDzw0000zzlzzU0001zzjzw00003zzTzU00007zszw00000Dz1zU00000Ts3w000000z07U000001s0A00000030U", 1)
FindText().PicLib("|<模拟室超频·获得>*150$51.yDszzbzzzky7zsM030001y73wM000DVszXy7kzsT00TtzDy7s03rDtjtX7wQFy8zwMzXkDl3z700S3yATks03UTlXwDzzs300D1k01C801kC00DVw0C1zwDwDkzmDzly1w7zlU01UDUzyA000Fw3zlU016D4DyD7lzlklzlsSDyCD7yDXlzV1sDlyCDUETVyDy1w77yDlzkTzzzzzDzDw", 1)
;tag 竞技场
FindText().PicLib("|<竞技场·收菜的图标>01C5F3-0.90$38.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000Dzzzzw3zzzzz00000000000000000000000000000000000000U", 1)
FindText().PicLib("|<方舟·竞技场>*150$91.zz3zzwDz3zy7zzzk0007y7zVzz3k03s0001z3zkzzVs00w0000zVzsDzkw00S0000zkw007sS00Ty7w7z02003wDz0Tz3y3zU0001y7z0zU0001k0U00s0S0zk0000s0Tkzw0C0zs0000TUzsTy040000000DkzwDz02001zzzzzsS007wD000w000zwD001y7k00S000Ty0U00z3u40D000Dy0E00zVz347Vzw7w0A7kTkz323kzz3y063sDsTVV3s001z0DVsDwDVVVw000zUDkM7y0Ukky000Ty7w07z00ksT000Tz3z07z00sQDy73zzVzU7y06sS7y3VwTkzk3z0DsC3y3ky7sTU0TUTwD1s1sC3wC003tzw71U1w01k7000Tzs40k1y01s3UD0Tzw70Q3zU0y3sTsDzz7USDzzzz7xzzDzzzkT", 1)
FindText().PicLib("|<左上角的竞技场>*150$91.zz3zzyDz3zy7zzzs0007y7zUzz3k07w0001z3zkTzVs01y0000zVzsDzkw00T0000Tkw007sS00Tz7y7zU6003wDz0Tz1z3zU0001y7z0zzUT0zk0000s0T0zs0000s0TkTw0C0zw0000TUzsDy040060000DkTw7z00001zzzzzsT00DwD000w000zw7U01y7k00y000Dy0k00z3s40T000Dy0M00zVz24DUzy7w0A7kTkz327kzz3y073sDsTVX3s001z0DVsDwDVVVw000zk7sQ7y0Ukky000Ty7w07z00ksT000Dz3z07z00sQDy31zzVzk3y00sS7z3UyTkzk3z0DsC3y1sT7sTk0zUTwD3w1wD3wD003tzwD1U1y01k7000Tzs40s1z00w3UD0Tzw60Q3zk0y1sTsDzz7UTDzzzz7zzzDzzzkz", 1)
FindText().PicLib("|<蓝色的新人>79A6F4-0.80$59.1s01k00y003k0Tk01w01jnDzk03s03zzTy007U07zwzU00T00Dzts000z00D7Xk001y00SD7U003w00wyD0007s07zzS000Dk0DzyzzU0Tk0Tzxzz01zU0zzvzy03z001s7zs07z003kDD00Ty07zySS00zy0Dzwww03xw0Tztts07lw07xXnk0TXw0Fv7bU0y3w1zzTD03w7s3riwS0Dk7wDDTsw0z07wSSTls7w07wNwDXkTs07yDkS7UzU07wDUQD0w007kS0ES0k0030000Q00000E", 1)
FindText().PicLib("|<免费>*210$59.zrzzzzySDzz1zzzzkMDzw01zzU000Tk01zz0001zU03zzz3VXy3sDzzy637sDkTzw000DUT0zzk000Q0000zVkkTs0001z100UM0003y0000sDUy7zkC3VsT3wDzUyD3ky7sTw3wQ7VwDkz0Dvwz0001y0Tzvy0003y0007w0007z000Dzw0Dzy000Tzs0zzwDzkzzUlzzszzlzy3XzzlwD3zs77tzXky7z0SDlzL1gzs1wD3zU61z0Ds07k0w0C0zk0S07z06Dzk0y0zzsTzzzzwzzzzk", 1)
FindText().PicLib("|<ON>*200$53.zk1zzzzzVy00ztzzz3s00Tkzzy7U00TUzzwC0z0T0zzsM7zUy0TzkkTzUw0TzV1zzVs0Tz27zz1k0Ty4Dzz3U0Dw0Tzy71UDs0zzwC3UDk1zzsQ7k7U3zzksDk707zzVkTk64Dzy3Uzk08DzwD1zs0MDzkS3zs0kDz1wDzs1kDw3sTzw3k00Dkzzw7k00zVzzwDk03z3zzyTk0Ty7zzyzy7zyDzzz", 1)
FindText().PicLib("|<OFF>*120$83.zk1zzk001zU003y00zy0003w0003s00zs0003k0007U00zk0007U000C000z0000S0000M000y0000w0001U7w0w7zzzsDzzz0zy1kDzzzUTzzw3zy1UTzzz0zzzs7zw30003y0007kTzw60007w000DUzzsA000Ds000T1zzkM000Tk000y3zzUk000zU001w7zz1U001z0003sDzy30zzzy1zzzkDzs61zzzw3zzzUTzkA3zzzs7zzzUTz0s7zzzkDzzz0Tw1kDzzzUTzzz0007UTzzz0zzzy000T0zzzy1zzzy000y1zzzw3zzzy007w3zzzs7zzzz00Ts7zzzkDzzzzU3zkDzzzkTzzy", 1)
FindText().PicLib("|<蓝色的特殊>79A6F4-0.80$59.100M0000003k1w0000w07U3s1zwVs3D3zzXztvk7S7zz7znrUCwDzyDzjz0TyDzs7UTzwzw1w0D0zzvzs3s0TzzzrzzzzlzzzzDTDzzXzz7UQwTzz7zwD0tszzySDMS0nk07UwTzzw7U0D1szzzsDnzzbhzzzkTjzzjTjzzjzTzzRz1zkzyzzyPy3zUzsQDU3sDzVzUwD03kTz3D1sS0DVzz0S3sw0S7zz0w3ls1wzDT1s33kDnwSy3k1zUz3sws7U3z3w71skD03w3k43k0S07s3007U0w0A0000D0U", 1)
FindText().PicLib("|<内部的紫色应援>CD98E6-0.70$59.00000000000000000000000000000001w01s03k003s03lzzU007k07bzzU1zzzwD7zz07zzzsSDzy0DzzznzTxw0TzzzbzTvk0zzzzDzzzk1w7UwTzzzU3zj3szrzz07zT7kSDzy0DzyDUwTzy0Tywy1zzzw0yxxw3zzzs1xzvsTzzzk3vzzVzzzzU7rzz3znzy0Dbzw3y7zw0TDXs7sTzk0wQDU3lzzU3s0T07Xzy07zzzwDDzw0Dzzztzzzz0Tzzznzzzz0xzzzbvzzw0vzzzDXDbk0U000C081U00000000000000000002", 1)
FindText().PicLib("|<晋级赛内部的应援>*150$79.0000000000000000000000000000000000000000001s001w00000003w000y00zy0001z000T7zzz0000zU00DVzzzk0zzzzzk7kzzzs0Tzzzzw3sTzzk0Dzzzzy1w7zly07zzzzzDznvsz03zzzzzbztwyz01zzzzznzwTTT00z010M1zyDjzU0TUDUDUzzTzzy0Dkbs7wTzjzzz07vnw3w0y7zzzU3zxy3y0T3zzzk1zyTVz0DVzzzk0zzDkz07lzzzy0TjrszU3vzzzz0DrvwTk1zzzzzUDvwzDk3zzzzzk7wzTjs7zzzzzs3yTjrs3zwDzz01yDrzw1zy7zzs0z7zzy0zw3zzw0TVyty0Tw3zzw0Dkz1z0Ay1zzy07sS0z00T1ztz03w00zU0DUzzz03y00zU07kzzz01z00Tk03szzzU0zzzzzy3wzrzk0zzzzzzDyzzzzUTzzzzzbzzzzzsDrzzzzlzjzzzs3vzzzzszXvzTw0w00000Tkky1w04000007008040000000000000000000000000000000000000000E", 1)
;tag 无限之塔
FindText().PicLib("|<无限之塔的无限>*135$63.s0003s0A00S0000T00003k0003s0000S0000T01U03k0003sAADkTzkDzz3VUy3zy3zzsMQ00TzkTzz33U03zy3zzsMQ00TzkDzz33Uy300000sMQDkM0000733U0300000sQA00M000073VU03zw0DzsQA00TzU1zz3VV1rzs0DzsQAAATz01zz3VVU1zk0Dzs0AA0Dy31zz21Vk3zUMDnsMQC0zs71y737VsDy0sDUsTwD0z0D1w73z007k3s00sTs0U80z0073z0600Ds01sTk0sA7zU0T3z0DVnzz07sTsTyQ", 1)
FindText().PicLib("|<无限之塔·OPEN>*200$95.zwDzzzzzzzzzzzzzy03zw00zw00DkDz3s01zs00Ts00TUTy7U01zk00Tk00z0TwC001zU00TU01y0zsM3w3z1z0T0zzw0zkkTw3y3z0y3zzs0zV0zw7w7z1w7zzk1z23zs7sDy3sDzzU1y07zsDkTw7kTzz13w0DzkTUzsDUzzy23s0zzUz1zkT00Dw67k1zz1y3z0y00DsA7U3zy3w3s3w00TkQD07zw7s00Ds00zUsC0DzsDk00zk03z1sQ0TzkTU03zUzzy3kM0TzUz01zz1zzw7kk0zz1y1zzy3zzsDUV1zw3w7zzw7zzkTU21zsDsDzzsDzzUzU63zUTkTzzkTzz1z0A1y1zUzzzUTzy3z0Q003z1zzz001w7y0w00Dy3zzy003sDy1w01zw7zzw007kTw3y07zsDzzs00DUzw7zXzzzzzzzzzzzzzs", 1)
FindText().PicLib("|<STAGE>*90$66.s3s1y7zUDk103k0w3y07U003k0w3y07k001U0w3y07k001U0Q1y03k01zw3w1y3zkT3zw7s1y3zkT3zw7s1y3zkT3zw7s1y3zkT3zw7s0y3zkT1zw7s0y3zkT03w7s0y3Vk/01w7k0y3Vk101w7kEy3Vk101w7kky3Vk1y1w7kkS3Vk1z1w7kkS3VkTz1w7UkS3VkTz1w7UkS3VkTz1w7U0S3VkTz1w7U0C3VkTy1w7U0C31kT01w7U0C01k001w70sC01k001w71sC01k0U3w71sD01k1U", 1)
FindText().PicLib("|<无限之塔·向右的箭头>*100$21.0Tzs3zz0Tzw1zzUDzy0zzk7zy0zzs3zz0Tzs3zzUDzw1zzUDzy0zzk7zz0Tzs3zz0Tzw1zzUDzw1zzk7zy0zzs3zz0Tzs3zzUDzw1zzUDzy0zzk7zy0zzs3zz0Tzw1zzUDzw1zzk7zw1zzUDzs3zz0Tzs3zy0zzk7zy0zzUDzw1zzUDzs3zz0Tzk7zy0zzk7zw1zzUDzw1zz0Tzs3zy0Tzk7zy0zzUDzw1zzUDzs3zz0Tzs3zy0zzk7zw1zzUDzw1zz0Tzs3zz0Tzw", 1)
FindText().PicLib("|<塔内的无限之塔>*200$106.00000000001U00kC300000Dwzz00D003UsS3zzzUzvzw00w00CTzzDzzy3zjzk01s00tzzwzzzsCSs7007U03bzzk0w00tnUQ7zzz0C7Xs03k03bDzkTzzy3yCrU0D00Cwzz1zzzsTszw00w00vXzw3zzz1zUz0Tzzz3iC1k003s7y7z3zzzyCws7000DU7VwyDzzzstnzw001w0CTVzzzzzXbDzk00DU0vzzw0Tk0CSzz001w03jzzU1z00svbA00TU0CNzk0Dw03XiQs03w00s0000zk0CytzU0TU03tzz07j00vnXw03s00Drzw0yw33jCDU0z003zTzk7nkCC0sy0Ts00TtkD0yD1ss3Xs3z001y70wDkzzXUTvsTz0Db0Q3ny1zyC1zjnvzzy01zzDk7zks7yT73zzs07zwQ0Dy3US0MM3zz00Tzk0000C0000000001k68", 1)
;tag 拦截战
FindText().PicLib("|<拦截战>*150$93.wDzyTzkzVzzszsTzVyDkTy7wAzz7z3jwDkw7w01U3zszsMzVy7UzU0A8Dz7z33wDsQDw01VUzsTsMTVz33zU0ACDz073XU1skTzkTVnzs0sCw0800C00003z07VzU1001k0000Ts0s8C0800C00003z3w01wD001s0000zsT00DVzzzzklwDzz7s03wDzzzy4DVnzszUDzVzzzzU0AADy3zVXw1zzzw00VVw00wAC0A00z0040DU07VX01U03k47U3w00w0Q0A00S00C0TU07k7UDU03s01k3wDky0wVzzzzU0C0zVy7kDwDzzzyCDkDwDky1zVzzzzk0C1zVy7kTwDzzzy01kQwDky3DVzzzzk0A3XU070MwC001yAD08Q00k07Vk007k0003U0401UC000y0000w0000C1k007k00k7Uy4C1kTzzzyDzD1wDknsQ", 1)
FindText().PicLib("|<红字的异常>*36$69.zzzzzzzzkTzzzzzzzzsS3sTw0001zw3kD0zU000DzkC1kDw0001zy3kC3zU000Dw00000w7zz1zU00007UzzsDw00000w0001zU00007U000Dw7zyDUw0001zUzz0A7U000Dw4000Uw7zzwTUU0047UzzzUw4000Uw00007zUzs7zU0000zw7z0zy0000DzU007zs0003zw000zzw003zzU007zy3zVzzzy1zzzkTsDzzzsDzzy3z1zzU0003U00003w0000M00000TU0003000003w0000M00000TU0003U00003w7sDUTs7z1zzUz1w3y0zsDzw7sC0T0Dz1zzUz103U3zsDzw7sA0S0zz1zzUz1U7kDzsDzw7sA1z7zz1zzzz1xzU", 1)
FindText().PicLib("|<克拉肯的克>*200$72.zzzzzU1zzzzzzzzzzU1zzzzzzzzzzU1zzzzzzzzzzU1zzzzzzzzzzU1zzzzzzzzzz01zzzzzs00000000003s00000000003s00000000003s00000000003s00000000003s00000000003s00000000003s00000000003s00000000003zzzzz00zzzzzzzzzzU1zzzzzzzzzzU1zzzzzzzzzzU1zzzzzzzzzzU1zzzzzzzzzz01zzzzzzy000000007zzy000000007zzy000000007zzy000000007zzy000000007zzy000000007zzy000000007zzy000000007zzy000000007zzy07zzzzs07zzy07zzzzw07zzy07zzzzw07zzy07zzzzw07zzy07zzzzw07zzy07zzzzw07zzy07zzzzw07zzy03zzzzs07zzy000000007zzy000000007zzy000000007zzy000000007zzy000000007zzy000000007zzy000000007zzy000000007zzzzU0Ds07zzzzzzk0Tw0Dzzzzzzk0Tw0Dzzzzzzk0Tw0DzzzzzzU0Tw0DzzzzzzU0Tw0DzzzzzzU0zw0Dzzzzzz00zw0Dzzzzzz00zw0Dzszzzy00zw0DzsDzzw01zw0Dzs1zzw01zw0Dzs0zzk03zw0Dzs0zzU03zw0Dzs0zy007zw07zk0zs007zw07zk0z000Dzw03zU0k000Tzw000000000zzw00001U001zzw00001k003zzy00001k00Dzzy00003s00Tzzz00003w01zzzz00007w07zzzzU000Dy0zzzzzs000zy7zzzzzzzzzzU", 1)
FindText().PicLib("|<镜像容器的镜>*200$75.zzzzzzzzzDzzzznzzzzzw1zzzzw3zzzzy07zzzzU3zzzzk0zzzzw0Tzzzy03zzzz03zzU00000Dzs0Tzw000001zy000DU00000DzU001w000001zw000DU00000Dz0001w000001zs000DU00000Dy0001w000001zU000DzsDzUDzs0001zs0zw0Ty0000Dz07z03zU0001zw0zs0zs03zzzzU3z0DzU0zzzk000000Q07zzy0000003k1zzzk000000S0Tzzy0000003s0001k000000T0000C0000003s0001k000000TU000C0000003w0001k000000Tw000DzzzzzzzzU001zzzzzzzzw000DzzzzzzzzU001y000003zw000Dk00000Tzy07zy000003zzs0zzk00000Tzz07zy000003zzs0zzk00000Tzz07zy0TzzU3zzs0zzk3zzw0Ts0000y0DzzU3z00007k00000Ts0000y000003z00007k00000Ts0000y000003z00007k00000Ts0000y0DzzU3z00007k3zzw0Ts0000y0TzzU3z00007k00000Tzy07zy000003zzs0zzk00000Tzz07zy000003zzs0zzk00000Tzz07zy000003zzs0zDz00k0Tzzz07Vzw0D07zzzs0k7zU3s0zzzy000zw0T07zzzk007z03s0zzzy000zs0T07zzzk003y03s0zzzw000Tk0z07rzz0003w07s0wDzs001z00z07UDy000TU0Ds0w0zU00Dk01z03U7w007s00Ts080zk01w007z000Dz00zk01zw001zs0Tz00DzU00DzU7zw07zw003zw3zzU1zzk00Tzkzzy0zzz007zyTzzsDzzy03zzzzzzDzzzzzzU", 1)
FindText().PicLib("|<茵迪维利亚的茵>*200$69.zzw0DzzU1zzzzz01zzs0Dzzzzs0Dzz01zzzzz01zzs0Dzzzzs0Dzz01zzs00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007zy00zzk07zzzzs0Dzz01zzzzz01zzs0Dzzzzs0Dzz01zzzzzU7zzwwzzzzzzzzzzzzzzzzzzzzzzzzzzw0000000001z0000000000Ds0000000001z0000000000Ds0000000001z0000000000Ds0000000001z0000000000Ds0Dzzzzzz01z03zzzzzzs0Ds0Tzzzzzz01z03zzk1zzs0Ds0Tzy0Dzz01z03zzk1zzs0Ds0Tzy0Dzz01z03k00000s0Ds0Q00000301z03U00000M0Ds0Q00000301z03U00000M0Ds0Q00000301z03U00000M0Ds0Q00000301z03zz007zs0Ds0Tzw00zz01z03zz003zs0Ds0Tzs00Dz01z03zy000zs0Ds0TzU003z01z03zs0007s0Ds0Ty0000T01z03zU0001s0Ds0Tk03U0701z03k00S00M0Ds0Q007s0101z03k01zU0M0Ds0T00zz0701z03s0Dzw1s0Ds0TU7zzkT01z03y3zzz3s0Ds0Tlzzzwz01z03zzzzzjs0Ds0000000001z0000000000Ds0000000001z0000000000Ds0000000001z0000000000Ds0000000001z0000000000Ds0000000001z01zzzzzzs0Ds0Tzzzzzz01w", 1)
FindText().PicLib("|<过激派的过>*200$74.zzzzzzzzz03zzzzzzzzzzk0zzzzzzzzzzw0Dzzszzzzzzz03zzw7zzzzzzk0zzw0zzzzzzw0Dzy07zzzzzz03zy00zzzzzzk0zzU07zzzzzw0Dzw00zzzzzz03zzU07zzzzzk0zzw01zzzzzw0DzzU0Dzzzzy01zzw01s00000007zU0C00000001zs03U0000000Tz03s00000007zs1y00000001zz1zU0000000Tzkzs00000007zyTy00000001zzzzU0000000Tzzzs00000007zzzzzzzzw0Dzzzzzzzzzz03zzzzzzzzzzk0zzzzzzzXzzw0DzzzzzzUTzz03zw003zk3zzk0zz000Tk0Tzw0Dzk00Ds07zz03zw003z00zzk0zz000zs07zw0Dzk00Dy00zz03zw003zk0Dzk0zz000zy01zw0Dzk00DzU0Dz03zw003zw03zk0zzzk0zzU0Tw0Dzzw0Dzs03z03zzz01zz01zk0zzzk0Tzs1zw0Dzzw0Dzy1zz03zzz03zzkzzk0zzzk0zzyzzw0Dzzw0Dzzzzz03zzz03zzzzzk0zzzk0zzzzzs0Dzzw0Dzzw0003zzz03zzzU000zzzk0zzzs000Dzzw0Dzzy0003zzz03zzzk001zzzk0zzzw000Tzzw0Dzzz000Dzzw01zzzs007zzy00Dzzy007zzy000zzzU0Dzzz0001zzzzzzzzU0007zzzzzzsk00001zzzzU08000000000000000000000001U00000000000Q07U00000000703y000000003s1zs00000000z0TzU0000000DsDzy00000003y7zzw0000000zlzzzw000000TyzzzzzU00DzzU", 1)
FindText().PicLib("|<死神的死>*200$73.k00000000000s00000000000Q00000000000C000000000007000000000003U00000000001k00000000000s00000000000Q00000000000C000000000007zz00zzw07zzzzzU0zzy03zzzzzk0Tzz01zzzzzk0DzzU0zzzzzs0Dzzk0Tzzzzw07zzs0Dzzzzw03zzw07zzzzy01zby03zzzzy0000T01zzzzz00001U0zwzzz00000k0TwDzzU0000M0Dw3zzU0000A07w1zzk0000603s0Tzk0000701s07zk00003U0s01zs00001k0M00Ts03z00s00007s03zk0Q0000Dw03zk0S0000Dw03zs0D0000Tw01zw07U000Tw01zy07k000zw01zy03s001zw00lz01w001zzU0kT01y003zzs0s7U0z007zzy0s0U0TU07zzzUM000Tk0DzzzsQ000Ds0DzzzyQ000Dw07zzzzy0007y03zzzzzU003z01zzzzzs003zU0zzzzzy001zk0TzzzzzU01zs0Dzzzzzw01zw07zzzzzy00zy03zzzzzy00zz01zwzzzy00TzU0zy7zzy00Tzk0Ty0Tzy00Tzs0Dz03zy00Dzw07zU1zy00Dzy03zk0zy00Dzz01zs0Tw00DzzU0zs0Tw007zzk07s0Ds007zzs00007k007zzw00003U007zzz00003k007zzzU0001w00Dzzzk0000z00Dzzzw0000zk0Dzzzz0000zw0Dzzzzk000zz0Tzzzzy001zzkzzzzzzzzzzztzzzzzzzzzzs", 1)
FindText().PicLib("|<异常拦截·向右的箭头>*20$53.z0007zzzzw0003zzzzw0007zzzzw0003zzzzw0003zzzzw0007zzzzw0003zzzzs0003zzzzw0007zzzzw0007zzzzs0003zzzzw0003zzzzw0007zy00w0003zw00s0003zy00w0007zw00w0007zw00w0003zw00w0003zy01w0007zw00w0003zw00w0003zw01w0007zw01w0007zw00w0003zw01w0003zy01w0007zs03s000Dzk07U000Tz00S0001zw01s0007zk07U000Tz00S0001zw01s0007zk07U000Tz00S0001zw01s0007zk07U000Tz00S0001zw01s0007zk07U000Tzk0S0001zzzzs0007zzzzU000Tzzzy0001zzzzs0007zzzzU000Tzzzy0001zzzzs0007zzzzU000Tzzzy0001zzzzs0007zzzzU000Tzzzz0001zzzzU", 1)
FindText().PicLib("|<拦截战·进入战斗的进>*200$43.xzzkTUzsTzsDkDs7zw7s7w1zy3w3z0Tz1y1zk7zUz0zw1zkTUTz0M0000Tkw0000Dwy00007zz00003zzU0001zzzUDUTzzzsDkDzzzw7s7zzzy3w3w0Dz1y1y03zUz0z01zkDUTU0s0000E0M00007UA00003s600001w300000y1k0000T0zkTkDzUTkDs7zkDs7w3zs7s7y1zw3w3z0zy1w3zUTz0w1zkDzUS1zs7zUDUzw3zU3szy1zU0zzzzzU03zzzzU003zy00D000000Dk00000Dy000017zk0001rzzk001k", 1)
FindText().PicLib("|<拦截战·快速战斗的图标>*200$50.00zU0Tzzs07w03zzz00zU0Tzzs07w03zzz00zU0Tzzs07w03zzz00zU0Tzzs07w03zzz00zU0Tzzs07w03zzz00zU0Tzzs07w03zzz00zU0Tzzs07w03zzz00zU0Tzzs07w03zzz00zU0Tzzs07w03zzz00zU0Tzzs07w03zzw03y01zzy01z00zzz00zU0TzzU0Tk0Dzzk0Ds07zzs07w03zzw03y01zzy01z00zzz00zU0TzzU0Tk0Dzzk0Ds07zzs07w03zzw03y01zzy01z00zzz00zU0TzzU0Tk0Dzzk0Ds07zzs07w03zzw03y01zzzU", 1)
FindText().PicLib("|<拦截战·红色框的7>B83900-0.90$53.00Tzzzw0001zzzzs0007zzzzs000Dzzzzs000zzzzzk001zzzzzk007zzzzzU00DzzzzzU00zzzzzzU03zzzzzz007zzzzzz00Tzzzzzy00zzy1zzy03zzs1zzw0Dzzk3zzw0Tzzk7zzw1zzzwTzzs3zzzszzzsDzzzlzzzkTzzz3zzzlzzzy7zzzbzzzwDzzzjzzzszzzzzzzzVzzzyTzzz3zzzwzzzy7zzzkzzzwTzzz0zzzszzzy1zzzlzzzs1zzz3zzzk3zzy7zzz03zzzzzzy07zzzzzzs07zzzzzzU07zzzzzz00Dzzzzzw00Dzzzzzs00TzzzzzU00Tzzzzy000Tzzzzw000zzzzzk000zzzzzU001zzzzy0001zzzzw0003zzzzk0003zzzz008", 1)
;tag 前哨基地
FindText().PicLib("|<前哨基地的图标>*100$47.Q0TUw1UCQ0TXk60sA0Dj0M3UC0Dw1UC0C07s60s0707sM3k0707tUD10703y0w3U7U3w3k7U3U3yD0DU3U1yw0DU1U1zk0Dk1k1zU0Dk1k0zk0Dk1k0zk0Dk0s0Tk07s0s0Tk0Ds0s0Tk0zs0w0Ds3vs0w0DsD3s0Q0Dsw3w0S07nk7w0S07jUBw0C07y0ly0C03", 1)
FindText().PicLib("|<溢出资源的图标>*100$34.zzyzzzzzUzzzzs0zzzy7UzzzVzUzzkTzUzw7zzVzVzzzVsTzzzV3zzzz03zzzs03zzy003zzUk03zsD003y3w003Uzk000Dz0003zw000Tzk001zz0007zw000Tzk001zz0007zw000Tzk001zw8007z3s00Tkzs01wDzs073zzs0ETzzs0Dzzzw3zzzzwzzy", 1)
FindText().PicLib("|<进行歼灭的歼灭>*200$77.zzzzz7zzzzzzz003zU7w000006006007s00000A008007k00000M00E01zU00000y1zk0zzzzsDzzy7zjVzzzzkTzzsDzz3zzzzUzzzkTzy7zzzz1zzzU0TwDzzzy3zzz00zsTzzzw7zTw01zkzzz3sDw7s03zVzzy7kTsDkw7z3zzsDUzUz1wDw7zzkT0z1y7kE003z1y1y3wDVU007y3w3sDkT3000DsDk7kT066000TUTU71y20Dw1zz1z0C7w00zy7zz3y0SDwE1zwDzzjs0Tzxs3zsTzzzk0zzzsDzkzzzz0UzzzkTzVzzzy30zzzUzz3zzzs71zzy3zy7zzzUS1zzs7zwDzzy0y1zzkTzsTzzs3y0zz1zzkzzz0Dw0zw3zzVzzs0zw0TUDzz3zz03zy060zzy7zk0Dzy063zzwDzk1zzy0CDzzsTzkDzzz0xzzzkzzVzzzznU", 1)
FindText().PicLib("|<获得奖励的图标>*200$47.zzzsDzzzzzzkTzzzzzzUzzzzzzz1zzzzzzy3zzzzzzw7zzzzzzsDzzzzzzkTzzzzzzUzzzzzzz1zzzzzzy3zzzzzzw7zzzzzzsDzzzzzzkTzzzzzzUzzzzzzz1zzzzzk000Tzzzk000zzzzU003zzzzU00DzzzzU00zzzzz001zzzzz007zzzzz00Dzzzzy00zzy3zy03zy07zy07zw0Dzw0Tzs0Tzw1zzk0zzw3zzU1zzsDzz03zzszzy07zztzzw0Dzzzzzs0Tzzzzzk0zzzzzzU1zzzzzz03zzzzzy07zzzzzw0Dzzzzzs0Tzzzzzk0Tzzzzz000000001000000070000000D0000000z0000007k", 1)
FindText().PicLib("|<派遣公告栏的图标>*200$96.zzzzzzzyTzzzzzzzzzzzzzzw7zzzzzzzzzzzzzzk1zzzzzzzzzzzzzz00zzzzzzzzzzzzzw00Dzzzzzzzzzzzzs003zzzzzzzzzzzzU000zzzzzzzzzzzy0000Dzzzzzzzzzzw00U07zzzzzzzzzzk03k01zzzzzzzzzz007w00Tzzzzzzzzw00Tz00Dzzzzzzzzk01zzk03zzzzzzzzU07zzw00zzzzzzzy00DyDy00Dzzzzzzs00zs3zU07zzzzzzU03zU1zs01zzzzzz00Dy1kTw00Tzzzzw00zw7w7z007zzzzk01zkTy1zk01zzzzU07z1zzUzw00zzzy00Ty3zzsDz00Dzzs00zsDzzy3zU03zzU03zUzzzzUzs01zy00Dy1zzzzkDy00Tw00zw7zzzzw7zU07k03zkTzzzzz1zk01007z1zzzzzzUTw0000Tw7zzzzzzsDz0001zkDzzzzzzy3zU007zUzzzzzzzzUzs00Dy3zzzzTzzzsDy00Ds7zzzyDzzzw7y00DkTzzzw7zzzz1y00D1zzzzs3zzzzky00D7zzzzk1zzzzwy00D7zzzzU0zzzzwy00D7zzzz00Tzzzwy00D7zzzy00Tzzzwy00D7zzzz00zzzzwy00D7zzzzU1zzzzwy00D7zzzzk3zzzzwy00D7zzzzs7zzzzwy00D7zrzzwDzzxzwy00D7zrzzyTzztzwy00D7znzzzzzztzwy00D7znzzzzzztzwy00D7zlzzzzzzlzwy00D7zlzzzzzzVzwy00D7zkzzzzzzVzwy00D7zkTzzzzz1zwy00D7zkTzzzzz1zwy00D7zkDzzzzy1zwy00D7zkDzzTzy1zwy00D7zk7zwDzw1zwy00D7zk7zs7zw1zwy00D7zk3zk1zs1zwy00D7zk3zU0zk1zwy00D7zk1z00Tk1zwy00D7zk0w00DU1zwy00D7zk0s003U1zwy00D7zk0E00101zwy00D7zk0000001zwy00D7zk0000001zwy00D7zk0000001zwy00D7zk0000001zwy00D7zk0000001zwy00D7zk0000001zwy00D7zk0000001zwy00D7zs0000003zwy00D7zy000000Dzwy00D7zz000000zzwy00D7zzk00001zzwy00D7zzw00007zzwy00D3zzy0000Tzzsy00D0zzzU001zzzUy00DkDzzs003zzy1y00Dw7zzy00Dzzw7y00Dz1zzzU0zzzkTw003zUTzzk1zzz0zs000zsDzzw7zzw7zU000Dy3zzzTzzkDy00U07zUzzzzzzUzw00s01zkDzzzzy3zk03w00Tw7zzzzs7z007z007z1zzzzkTw00Tzk01zkTzzz1zk01zzw00zs7zzw7zU07zzy00Dy3zzkDy00TzzzU03zUzzUzs00zzzzs01zsDy3zU03zzzzw00Tw3sDz00Dzzzzz007z1UTw00zzzzzzk01zk1zk01zzzzzzw00zw7z007zzzzzzz00DzTy00TzzzzzzzU03zzs00zzzzzzzzs00zzU03zzzzzzzzy00Ty00DzzzzzzzzzU07w00zzzzzzzzzzk01k03zzzzzzzzzzw00007zzzzzzzzzzz0000Tzzzzzzzzzzzk001zzzzzzzzzzzzs003zzzzzzzzzzzzy00DzzzzzzzzzzzzzU0zzzzzzzzzzzzzzs3zzzzzzzzzzzzzzw7zzzzzzzzzzzzzzzTzzzzzzzU", 1)
FindText().PicLib("|<派遣公告栏最左上角的派遣>*200$113.000000000000003z0001U00001y000000Dz0007U0000zy00A03zzzzs0Tk000Tzy01w0Tzzzzw0zs00Tzzy07w0zzzzzs3zs1zzzzy0Tw1zzzzzk7zwzzzzzy3zw3zzzzzUTzxzzzzzw3zw7zzzzz0TzvzzzzzU7zwDzzzzy0Dzbzzzzk07zwTzzzzw0DzDzzzs007zwzzzzzs07wTzzk0007ztzzzzzk07kzzU0C007zXzzzzzU07Vzk03y007y3zzzzy0023zU1zy007nzzzzzzk007z3zzy0077zzzzzzk00DyTzzy000DzzzzzzbU0Twzzzy000TzzzzzzDU0ztzzzy000zzzzzzyzk1znzzzs001zzzzzztzs3zbzzy00000000007zw7zDzzU0TzsDzzzzkDzwDyTzz00zzsTzzzzUTzsTwzry01zzkzzzzz0Tzkztzjw03zzVzzzzy0Dz1znzTsk7zz3zzzzw0Dw3zbyzvkDzy7zzzzs07s7zDwzzkTzwDzzzzk07UDyTtzzkzzsTzzzzU030Twznzzlzzkzzzzz0000ztzbzzk3zVzzzzy00A1zXzDzzU7z3zzzzw00Q3z7yTzy0Dy7z000001w7yDwzzk0TwDzzzzw03wTwTszz00zsTzzzzs07wzszlzs01zkzzzzzk0TxzlzXzU03zVzzzzzU0zvzXz7zU07z3zzzzz03zbz7y7z00Dy7zU0Dy07zDwDwDy00TwDzzzzw0TwzsTsTy00zsTzzzzs1ztzkzkTy01zkzzzzzk3znzVzbzw07zVzzzzzUDz7z3zzzw0zznzzzzz0TyTw7zzzw3zzzzzzzy1zszsTzzzwDzzz00003nzlzkzzzzwzzzzzzzzzjz7zXzzzzvzzzzzzzzzTyDy7zzrzXzzzzzzzzyzszwDzyDy7zjzzzzzzxzlzsTzkDs7y7zzzzzzlz7zUTw0Dk7s3zzzzzzUy7z0zU0D07k1zzzzzz0s3w0w00A0D00Tzzzzy0k1s1U0000C003zzzzk001U000000800000002", 1)
FindText().PicLib("|<蓝底白色右箭头>*200$56.0000zU0000007zzk000007zzzU00007zzzy00007zzzzk0003zzzzz0003zzzzzs001zzzzzzU00zzzzzzw00TzzzzzzU0Dzzzzzzs07zzzzzzz01zzzzzzzs0zzzzzzzz0Tzzzzzzzk7zwzzDzzy3zy7zVzzzUzz0zkDzzwTzU7s1zzz7zw0z0DzzlzzU7s1zzyzzw0T07zzjzzU3s0zzvzzw0T07zyzzzU3s0zzzzzw0T07zzzzzU3s0zzzzzw0T07zzzzzU7s0zzzzzk1w0Tzzzzs0y0Dzzzzw0T07zzzzy0DU3zzzzz07k1zzjzzU3s0zzvzzk1w0TzyTzs1y0Dzzbzw0z07zzlzy0TU7zzwDzkDw1zzz3zy7zUzzzUTznzwzzzs7zzzzzzzw0zzzzzzzz07zzzzzzzU1zzzzzzzk0Dzzzzzzw01zzzzzzy00Dzzzzzz001zzzzzzU00DzzzzzU001zzzzzk0007zzzzs0000Tzzzs00001zzzs000007zzk0000003y0000U", 1)
FindText().PicLib("|<白底蓝色右箭头>*200$57.zzzzszzzzzzzz007zzzzzz0007zzzzzU000Dzzzzk0000Tzzzw00001zzzy000003zzzU00000Dzzs000000zzy0000003zzU000000Dzs0000000zz00000007zk0000000Tw00000001zU0A03000Ds03k0w000z00z0Dk007k0Dw3z000S01zkTw003k07z1zk00Q00Ty7zU01U00zsDy00A003zUzs01U00Dy3zU0A000zsDy01U003zUzs08000Dy3zU00001zkTy00000Dy3zU0U003zUzs0A000zsDy01U00Dy3zU0A003zUzs01U00zsDy00A00Ty7zU01k07z1zk00S01zkTw003k0Dw3z000T00z0Dk007s03k0w000zU0A03000Dw00000001zk0000000Tz00000007zs0000000zzU000000Dzy0000003zzs000000zzzU00000Dzzy000003zzzw00001zzzzk0000TzzzzU000Dzzzzz0007zzzzzz007zzzzzzzszzzzw", 1)
;tag 咨询
FindText().PicLib("|<咨询的图标>*150$51.zyDzzzXzzzUzzzsDzzs7zzz0zzz0zzzs7zzs7zzz0zzz0zzzs7zzs7zzz0zw70s00s71Us70070s070s00s700s70070s070s00s700s70070s07zs00zz00zz007zs07zs00zz0000000000000000000000000000000000000000000000000000000000000Tzzzzzzs3zzzzzzz0Tzzzzzzs3zzzzzzz0Tzzszzzs3zzz7zzz0TzzkTzzs3zzw1zzz0Tzs00zzs3zz007zz0Tzw01zzs3zzU0Dzz0Tzy03zzs3zzs0zzz0Tzz07zzs3zzs0zzz0Tzz07zzs3zztwzzz0Tzzzzzzs3zzzzzzz0Tzzzzzzs3zzzzzzz0Tzzzzzzs3zzzzzzz0Tzzzzzzs00000000000000000U0000000600000003U", 1)
FindText().PicLib("|<》》》>*200$58.3U03U03U00zU0zU0zU07z07z07z00zy0zy0zy03zw3zw3zw0DzkDzkDzk0zzUzzUzzU3zy3zz3zy0DzwDzwDzw0TzsTzsTzs0zzkzzkzzk3zz3zz3zz07zy7zy7zy0DzsDzsDzs0zzkzzkzzk1zzVzzVzzU3zz3zz3zz0DzwDzwDzw0TzsTzsTzs1zzlzzlzzk3zz7zz3zz0DzwTzwDzw1zzlzzlzzk7zy7zy7zy0zzkzzkzzk3zz3zz3zz0TzsTzsTzs3zz3zz3zz0DzsDzsDzs1zzVzzVzzUDzwDzyDzw0zzkzzkzzk7zy7zy7zy0zzkTzkzzk3zz3zz3zy0DzsDzsDzs0zz0zz1zz03zw3zw3zw0DzUDzUDzU0Tw0Tw0Tw00zU0zU0zU01w01w01w00U", 1)
FindText().PicLib("|<红色的20进度>FE3829-0.90$11.000007UDkTkzlzXz7yDwTszlzXz7wDsT0000004", 1)
FindText().PicLib("|<咨询·MAX>*200$72.00000000D00Tk00600U0Dk0zs00C01k0Dk1yw00S01k07s3wz00y03s03w3wzU3y03s01y7szk7z07w01yDkzwDz07w00zTUzyzz0Dy00TzUzzzz0Dy00Dz0wzyT0Tz00Dy0wTwT0TT007w0wDsT0yDU07w0w3kT1yDU07y0w10T1w7k0Dz0w00T3w7k0Tz0w00T3s3s0zzUw00T7s3w0zDkw00T7k1w1y7sw00TDk1y3w7ww00TDU0y7s3ww00TTU0z7s1yw00STU0TDk0zw00ST00TDU0TU", 1)
FindText().PicLib("|<红色的收藏图标>FD2F1A-0.80$46.zzzwTzzzzzzVzzzzzzy3zzzzzzkDzzzzzz0Tzzzzzs1zzzzzzU3zzzzzw07zzzzzk0Tzzzzy00zzzzzs03zzzzz007zzzzs00Dzzzy000Dzzk00000zk0000004000000000000000U00000020000000Q0000003s000000Tk000003zU00000Tz000003zy00000Tzw00003zzs0000Tzzk0001zzz00007zzw0000Tzzk0001zzz00007zzs0000TzzU0001zzy00007zzs0000TzzU0000zzy00E03zzk0Dk0Dzz03zk0zzw0zzk3zzk7zzkDzzXzzzkzs", 1)
FindText().PicLib("|<快速咨询的图标>*200$47.01z00zzz01z00zzz01z01zzz01z00zzz01z01zzz01z00zzz01z00zzz01z01zzz01z00zzz01z00zzz01z01zzz01z00zzz01z00zzz01z01zzz01z00zzz01z00zzz01z01zzz01z00zzz01z01zzw07w07zzk0Tk0Tzz01z01zzw07w07zzk0Tk0Tzz01z01zzw07w07zzk0Tk0Tzz01z01zzw07w07zzk0Tk0Tzz01z01zzw07w07zzk0Tk0Tzz01z01zzw07w07zzk0Tk0Tzz01z01zzz", 1)
FindText().PicLib("|<咨询的咨>*200$50.zzzxzzzzzzzy1zzzznzzUTzzzw7zk7zzzy0Tw1zzzz01z0Tzzjs0DU0000TU3s00007y0w00001zsS00000TzDU0000Dzzk7s3w3zzs1y1z0zzw0zUTUTzz0Tk7s7zzs7w1y3zzzXz0DUzzyDzU1zTzw3zs0Tzzs0Tw03zzk07y00TzU03z083zk03z070Tw03zU3k1z03z00y03s7y00zk027zU0Tz01zzw0Dzs0Tzz0DzzUDzzsTzzz7zzyTzzzzzzzbzzzzzy000000zzU00000Dzs000003zy000000zzU00000Dzs3zzzs3zy0zzzy0zzUDzzzUDzs3zzzs3zy0zzzy0zzUDzzzUDzs3zzzs3zy0zzzy0zzU00000Dzs000003zy000000zzU00000Dzs000003zy0zzzy0zzUDzzzUDs", 1)
FindText().PicLib("|<咨询·向右的图标>*200$46.007zzzzw00Dzzzzs00Tzzzzk01zzzzz003zzzzy007zzzzw00Tzzzzk00zzzzzU01zzzzz007zzzzw00Dzzzzs00Tzzzzk01zzzzz003zzzzy007zzzzw00Tzzzzs00zzzzzU01zzzzz007zzzzy00Dzzzzs00Tzzzzk00zzzzzU03zzzzy007zzzzw00Dzzzzk00zzzzzU01zzzzz003zzzzw00Dzzzzs00Tzzzzk00zzzzz003zzzzy007zzzzw00Tzzzzs00zzzzzU01zzzzz003zzzzy00Dzzzzs00Tzzzzk00zzzzzU03zzzzy007zzzzw00Dzzzzs00TzzzzU01zzzzz003zzzzy00Dzzzzs00zzzzz003zzzzw00TzzzzU01zzzzw00Dzzzzk01zzzzy00Dzzzzk00zzzzz007zzzzs00zzzzz007zzzzw00TzzzzU03zzzzw00DzzzzU01zzzzy00Dzzzzk00zzzzz007zzzzs00zzzzz003zzzzw00TzzzzU01zzzzw00Dzzzzk01zzzzy00Dzzzzk00zzzzz007zzzzs00zzzzzU03zzzzw00TzzzzU03zzzzy00Dzzzzk01zzzzy00Dzzzzk00zzzzz007zzzzs00zzzzz003zzzzw00TzzzzU01zzzzw00Dzzzzk01zzzzy007zzzzk00zzzzz007zzzzs00TzzzzU03zzzzw00Tzzzzs", 1)
FindText().PicLib("|<灰色的咨询次数0>5C5C5F-0.80$24.000000000Ty01zzU3zzk7zzs7U1s700s700wD00wD00wD00wD00wD00wD00wD00w700w700s7U1s3zzk1zzU0zz000000000U", 1)
FindText().PicLib("|<EPI>FC3E32-0.80$59.0zzz1zzs0QDzzz3zzy0wzzzy7zzy1vzzzwDzzy3zzzzsTzzy7z0000w01wDw0001s01sTs0003k03kzk0007U0DVzk000DU1z3zzzw0Tzzy7zzzs0zzzsDzzzk1zzzUTzzzU3zzw0zk0007k001zU000D0003z0000S0007y0000w000Dw0001s000Ts0003k000zs0007U001zzzzwD0003rzzzsS0007bzzzkw000D7zzzVs000S3zzz3k000y", 1)
FindText().PicLib("|<播放>*200$88.y3zzzyTzzXzwDzzs7zy00zzs7zkDzzUS0001zzUTz0zzy1s0003zy1zs3zzs7k000Dzs3zUDzzUT0003zzkTy0zzy1w1UQ7zy0zs7zzs7s61UTk007UTzs03kM61z000Q000U0D0UMDw001k00200w210zk0070008000000D000M000U000000zUDzU0020000003y0zy000DUS0000Dw3zk3kDy1s0000zkDz0D0zs7z001zz0080w3zUTs007zw0003UDy1z0007zk00060zs5k010Dz0000M7zU00M60Dw0001UTw003UQ0zk00021z000S1s7y0k8007k001s7kTs70l00z00A0003zUQ3g03w07k000Dy1kDs0Dk0T0000zs70zU1zU1w0003zUQ3z07ys7kC1UDy1kDw0zzUT0sD0zs70zk3zy1w0003z0Q3z0Dzs7k000Dw3kDs0TzUT0000zkD0z00zy1w0003y0w3s01zs7k000Ds3kD001zUT0sD0z0S0k003w1w3UM3w1s2060207k000DUA000w0M0z0000y0k1U7s1k3w0003w7060zkD0Tk000Dww0wDzlw3z0zz0zvs7tzzjU", 1)
FindText().PicLib("|<领取>*200$70.znzzzzzzzzzzy3zzzy007zzzsDU00s00Tzzz0y003U01zzzw3s00C00000TU7U01s00001w0Dy7zkQ7007k0TkTz1kQ00S30z1zw71kT1kC0007k07Vw60A000T00S7Uk0M001w01sC300n1w7k07UsCD3wDkT1kT3UwwDkV1w71wC3ztz247kQ7kETU0Q8ET0ET11y00kV1w01y07s03247k07s0TU0A8ET00TU3zz1kV1w01z0Dzw7247kQ7w1zzUw8ET1kTk7zw7kV1w70DUTw0T047k00w1zU3w0rw003U3y0Dy0Tk00C07w1zs0zU03k0Ts7z01y0ES00TkDs43tz1UC0zUQ0s7zw60s3z3k7kTzkM7kTyTUzXzz1lznzzyDzTzw7jzy", 1)
FindText().PicLib("|<红底的N图标>FE522E-0.90$40.03zzz001zzzzU0DzzzzU1zzzzy07zzzzw1zzzzzwDzzzzzkzzzzzzbzzzzDyTtzzsTtzXzzVzry7zy7zzs7zsTzzUDzVzzy0Ty7zzs0zsTzzU0zVzzy01y7zzs03sTzzUk3Vzzy3U67zzsD00TzzUz01zzy3y07zzsDw0TzzUzw1zzy3zs7zzsDzkTxzUzzVzry3zzbzTsTzzTszzzzzzXzzzzzw7zzzzzkTzzzzy0TzzzzU1zzzzy01zzzzU01zzzs0U", 1)
;tag 奖励
FindText().PicLib("|<好友的图标>*200$46.000Dk000003zs00000zzk00007zzk0000zzz00007zzy0000Tzzw0003zzzk000DzzzU000zzzy0003zzzs000DzzzU000zzzy0003zzzs000DzzzU000zzzw0001zzzk0007zzz0000Dzzs0000Tzz00000zzs00001zz000001zU00000000000000000000000000000000000000000000000000000000003zz00003zzzk001zzzzs00Tzzzzw07zzzzzs0zzzzzzs7zzzzzzkzzzzzzzXzzzzzzyTzzzzzzxzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzTzzzzzzy", 1)
FindText().PicLib("|<灰色的全部>BBBBBB-0.90$77.002000020000000D0000y0000000z0001w0Tz0003y0001w0zz000Dy007zztzz000zy00Dzznzy003zz00Tzzbns00Dtz00zzzD7k41zVz00zzwSDUM7y1zU0y7kwS1kzs1zk1wDVtw7bz00zs1wT3nsTzw00zw3tw7bUyzzzzzs7nsDT0wzzzzzVzzySw0lrzzzy3zzyxw00Dzzz07zzxtw1UDzzy0Dzzvns300Dk000007Xs600TU00000D7kA00z000000S7U03zzz01zzswD007zzz03zzlsS00Dzzy07zzXkw00Tzzw0Dzz7Xs000TU00T0yDzk400z000y1wSzUM01y001w3sxy0E03w003s7lvs07zzzzs7zzXm00DzzzzkDzz7U00TzzzzUTzyD000zzzzz0zzwS000zzzzy1w3sw008", 1)
FindText().PicLib("|<每日任务·MISSION>*200$205.zU0Ts07zk1zs003zw001w0Tzw00zzzy01zz003k00zs0zk001zs000y0Dzk007zzs00Dz000k00Dw0Tk000zk000T07zk000zzs001z0008003y0Dk000Ts000DU3zk000Dzs000T0000000z07k000Ds0007k1zU0003zs000DU000000DU3k0007w0003s0zk0000zs0003U0000007k1s0003w0001w0Tk0000Ts0000k0000001s0w0001y0000y0Dk00007w0000E0000000w0S0000z0000T07s00003y000080Tk0Ds0S0C07zzz03zzzU3s03z00z03y000Tw0Dw0D0703zzzU3zzzk1w07zk0T03zU00Dy07z07U3U3zzzk1zzzs0y07zw0DU1zs007zU3zU3k1k1zzzs0zzzw0T07zz03k1zw003zk1zk1s0s0Tzzw0Tzzy0D03zzU1s0zy001zs0zs0w0Q0Dzzy07zzz07U1zzs0w0Tz000zw0Tw0S0D000zzU00zzU3k1zzw0S0DzU00Ty0Dy0D07U003zk001zk1s0zzy0D07zk00Dz07z07U3k000Ts000Ds0w0Tzz07U3zs007zU3zU3k1s0007y0003w0S0DzzU3k1zw003zk1zk1s0y0001z0000y0D07zzs1s0zy001zs0zs0w0TU000zk000D07U3zzw0w0Tz000zw0Tw0S0Ds000Dw0007U3k1zzw0S0DzU00Ty0Dy0D07y0007z0003k1s0zzy0D07zk00Dz07z07U3zk003zs000s0w0Tzz07U3zs007zU3zU3k3zzzU0zzzk0Q0S07zzU3k1zw003zk1zk1s1zzzs0Tzzw0C0D03zzk1s0zy001zs0zs0w0zzzy0Dzzz0707k1zzk0w0Tz000zw0Tw0S0Tzzz07zzzU3U3s0Tzs0S0DzU00Ty0Dy0D0DzzzU3zzzk1k1w07zs0T07zk00Dz07z07U7zzzU1zzzs0s0y01zs0DU3zs007zU3zU3k3zzzU0zzzk0Q0TU0Dk07k1zw003zk1zk1s1s0000w0000C0Dk00007s0zy001zs0zs0w0y0000S0000D07w00003w0Tz000zw0Tw0S0T0000DU0007U3y00003y0DzU00Ty0Dy0D0DU000Dk0007k1zU0003z07zk00Dz07z07U7k0007s0003s0zs0003zU3zs007zU3zU3k3s0007w0003w0Ty0003zk1zw003zk1zk1s1w0007y0003y0Dzk003zs0zy001zs0zs0w0y000Dz0007z07zy007zw0Tz000zw0Tw0S0T000zzU00TzU3zzw0zzy0DzU2", 1)
;tag 活动·通用
FindText().PicLib("|<活动地区的地区>*150$62.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzsTz3zzzzzzy7zkzw0000TVzwDz00007sT33zk0001y7kkzw0000TVwA8T3zzzzkD303kzzszk0kk0wDDy3w0A00D3Uz1z03003ks7Uzk0k0kwD0kDzVk0AD3s07zsM033kz03zy70kkwDs1zzVkAAD3z0TzsS333kzU1zy7kkUwDU0DzUAA0T3k41zs3307kk3UDw0EkXw01w1w0AADz31zkz0D3zrkszwTkDkzsQDzzzyDwDy71zzzzzz001k0001zzk00w0000Tzy00D00007zzk07k0001zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzs", 1)
FindText().PicLib("|<活动·切换的图标>*200$54.zzzU3zzzzzzw00Dzzzzzk003zzzzz0000Tzzzy0000Dzzzw00003zzzs03w01zzzk0TzU0zzzU1zzs0TzzU3zzy1zzz07zzzXzzz0Dzzzrzzz0Tzzzzzzz0Tzzzzzzy0zzzzzvzy0zzzzzlzC0zzzzzUzU0zzzzy0Tk07zzzw0Ds01zzzk07w07zzzU03y0Dzzzz01z0zzzzzU0zVzzzzz0Tznzzzzz0Tzzzzzzz0Tzzzzzzy0Tzzzzzzy0Tzztzzzw0zzzUTzzs0zzz0Dzzk1zzz03zzU1zzzU0Ty03zzzk00007zzzw0000Dzzzy0000TzzzzU001zzzzzs003zzzzzz00TzzU", 1)
FindText().PicLib("|<作战出击的击>*200$63.zzzzs1zzzzzzzzz03zzzzzzzzs0Tzzzzzzzz03zzzzzzzzs0Tzzzzzzzz03zzzzy0Tzs0Tzzzzk00D03zzzzy00000Dzzzzk000003zzzy00000000zzk00000000Dy000000001zk00000000Dzz00000001zzzzU00000Dzzzzs00001zzzzz01s00Dzzzzs0Tzw1zzzzz03zzzzUTzzs0Tzzzs00Dz03zzzz000000Tzzzs000001zzzz00000001zzs000000000z000000000000000000000U0000000007zk00000000zzzs0000007zzzz000000zzzzs0A0007s0zz03zy00z03zs0Tzzz7s0Tz03zzzzz03zs0Tzzzzs0Tz03zs3zz03zs0Tz03zs0Tz03zs0Tz03zs0Tz03zs0Tz03zs0Tz03zs0Tz03zs0Tz03zs0Tz03zs0Tz03zs0Tz03zs0Tz03zs0Tz03zs00D03zs0Tz00000Dz03zs000007s0Tz000000003zs00000000Tz000000003zs00000000Tzzk0000003zzzzk00000Tzzzzzs0003zzzzzzzs00Tzzzzzzzz03zzzzzzzzs0TzzzzzzzzU3zzzzzzzzzszU", 1)
FindText().PicLib("|<前往区域的图标>*155$39.zzznzzzzzyDzzzzzlzzzzzy3zzzzzkTzzzzy0zzzzzU3zs0000Dz00000zs00003z00000Ds00000z000003s00000D000000s00000300000080000000000000000000000000M000007000001s00000T000007s00001z00000Ts00007z00000zs0000Dzzzzk3zzzzy1zzzzzkTzzzzy7zzzzzlzzzzzyTzzzzzrzzw", 1)
;tag 小活动
FindText().PicLib("|<小活动·挑战>*150$70.wDwADzzVzsTzkzkkzzy7zVnz3z33zzsTy67wDwADzzVzsMTkykktzy7zVkz3V33VzsTy71U04AA7zU0sSQ000kkzy03Vzk0E303zs0D7z01UA0TzU3w07ky0k3zy7w00T3s30DzsTU01wDoA5zzVz00zkzkkzzy7w0zz2T33zzsTz3Xw1wA3zk03wC7U7kk7z007ksk0S30Dw00T3307UA0Tk01w4A0w0k0z3y7s1k30311wTsTU7wA0AC3lzVy0zkkUkwT7y7s7z3a73vwTsTUTwDsQDzlzVy3jkz1kwT7y7kCD3sD3kwDkS0swD0wD3k01k13ks7kQD00400830zU1w00081UA7y07kzV1k61szs0z7y6TUsDrzs7zzzzz3U", 1)
FindText().PicLib("|<小活动·放大镜的图标>*150$31.zsDzzzU0zzzU0Dzz001zzUzUzzUzwDzUzz3zkzzVzszzsTsTzwDwDzy7y7zzXz3zzlzVzzkzkzzsTwDzsTy7zwDzVzwDzkTw7zw1k3zz000Tzk067zz0T1zzzzkTzzzw7zzzz1zzzzkTzzzw7zzzz1zzzzlzzzzxk", 1)
FindText().PicLib("|<小活动·关卡图标>*200$74.zzzs03zw0000E3w000zs0000000000Dw00000000003z0000001zzw0zU7zzU00Dzz0Ds1zzs003zzU3w0Dzy00UTzk0z01zzV0C3zs4DkkTzsk3kTw33wC3zyQ0y3y1kz3kTzj0DkT0yDky3zzk3y3UzXwDkTzw0zkkTsz3y7zz0Dy07yDkzk1zk3zk3zXwDy0Tw0zy1zsz3zU7z0Dz0TyDkzw3zk3zU3zXwDy0zw0zk0zsz3z03z0DwCDyDkzUUTk3y7XzXwDkS3w0z1wzsz3sDUT0DUz0SDkw7w3k3kTw7bwC3zUQ0sDzUtz31zw30A7zw0TkkTzk003zzU7w0Dzy001zzw1z07zzk00zzzUTk3zzw0000003w00000000000z00000200000Dk00000U00003w01zzzs", 1)
FindText().PicLib("|<小活动·关卡图标2>*50$73.000000007z007U1zzy07zzzzzzzzzz0DzzzzzzzzzzU7zzzzzzU00Tk3w003zzk00Ds3z001zzw00Dw1zU01zyT00DS0vs00tz7k0D70Qy00MzUw0D3UCDU0ATkS0T1k71s00Ds7UT0k3UQ007w1sT0M1k7003y0ST0A0s3k01z07z060Q0zs0zU0z030C0Dw0Tk0TU1U703w0Ds0TU0k3U1y07w0Ds0M1k1z03y0Dw0A0s1zk1z0D6060Q1sw0zUD1030C1wD0TkD0k1U70w3kDsD0DUk3Uw1y7wD03sM1kw0TXyD00yA0sw03tz700Da0Qw00SzzU01z0Dw00DzzU00TU7y003zzU00Dk3y001zTzzzzw1zzzzzjzzzzy0zzzzzrzzzzz0TzzzzvzzzzzU000002", 1)
;tag 大活动
FindText().PicLib("|<大活动·红色的N框>FB4419-0.90$24.3w007zy0TzzkzzzszzzwzzzyzDzzz7yTz3yDz0yDz0SDz0CDz46Dz70Dz7UDz7kDz7sDT7yDTzzTDzzz7zzy1zzw07zsU", 1)
FindText().PicLib("|<大活动·签到印章>*150$122.wzyTzzzzzzzzzzzzzwTzz3z1zzzzzsTzrzzzzy3zzUzkTz003y7zUs03w0003s0803k00VVz0600y0000w0000w008MT01U0Dk000D0000D00267k1s03zUzUzU1UkTy77VVw7y00zwDsDkMMS7z1VsMT3zVsDy1w3yC07VzksC67kzsS3k0001vw0zzs01VVwDy7Uw0000Ty07zy00MMT1zVsD00007y1UTzU0667k0MS3zzzzzw0y0zs01VVw067UzU003s0DU0zxzsMT01VsDs000w0000Dz3y67k0MS3y7zsDUk043zkzVVwDy7UzVzz3ww03ty00MMT3zVsDs000zzyTzzU0667kzsS3y000DzD3sTs01VVwDy7UzVzz3z1ky7y00MMT3xVsDsTzUzsS71zz3y67U0MS3y000Dy3VkzzkzVVk0640zU003zksMDzwDTsS01VUDzy3zzwzS7zz03y7U0sM7k0001zzz1zs00zVs7y63s000080000w00C0TTzVzy000020000D00zU7zzsTzk0001U0003kDzs3zzy7zzzsDzs0000zzzz1zzzVzzzy3zy", 1)
FindText().PicLib("|<大活动·全部领取>*150$166.000M00001k000003000000000000003s0000TU00000TU0000000000000Tk0001y07zw01y3zzz7zzw000003z00007w0Tzs0DkDzzwTzzs00000Ty000Tzzlzzk0z0zzzlzzzzzz003zw003zzz7zz07y3zzz7zzzzzy00Tzs00DzzwTzw0zw7zzwDzzzzzs03zzs00zzzlwTU3zs0TU0TVwTzzU0zszk03zzz7ly0Tzk1w01y7lzzy07z1zk0DzzwT7s3yzUDk07sT7zzs1zs3zU07kTVwT0TlzDzzUTzwDUTUTz07zU0z1y7nw3z3zzzy1zzkz1y7zs0DzU1yDkTDkTz7zzzs7zz1w7lzy00TzU7sz1wy3zyDTzzUTzw7kTDzk00zzUTXs7ns7vwNyVy1zzkT3wTzzzzzw1yTkTT0D7t7k3s7wz1yDkzzzzzzVzzztzw0MDUTDDUTVw3sz1zzzzzw7zzzbzs00Q1wwy1y7kDXs2DzzztUTzzyTDU3zy7nns7sz0zTU0zzzzU1zzztwz0DzyTDDUTzw3xy000Tk007zzzblw0zzxwwy1zzk7zs001z0000000T7s3zzbnns7zz0Tz0007w0000001wDUDzyTDDUTzw1zw000Tk0000007ky00Dlwwy1zzk3zk07zzzk07zzwT3s00z7rns7sz0Dy00zzzzU0TzzlwDk03sTTDUTVw0zs03zzzy01zzz7kz00TVzwy1y7s1z00Dzzzs07zzwT3w03w7zns7szw7w00zzzzU0TzzlwTU3zkTzDUTzzkTk000Tk001w0z7zy0zy1zsy7zzz3zU001z0007k3wTzs3zs0Dw0TzzwTz0007w000T0Dlxz07z01zs1zzzXzy000Tk001y0z7rw0Dw07zk7zzsTzw003z0007zzwTT00Tk0zzUDwz3zzsTzzzzz0Tzzlw000zUDtz0k1wTszlzzzzzw1zzz7k001z3zXy007nz1z7zzzzzk7zzwT0003sTw7w00T7s7sTzzzzz0Tzzlw000D0z0DU01wD071zzzzzw1w0z7k000M3s0Q007ks0800000007k1s000000600000T0002", 1)
FindText().PicLib("|<大活动·挑战>*100$61.sTzzzzzzzzwDkEzzUzkzy7s8TzkTsMz3w4DzsDw8TVy26zw7y67ks127y0733000V1z03VnU00E1zU1kvk0081zk0s080k40zsDU07Vs20zw7k03kw10Ty3s01sTUVzz1w0Lw3kEzzUzEMy0s87w00w880M40y00S4A0820D00D060k103U07U70E0U1ky3k3o80kksTVs3y60MMwDkw1z3cACy7sT1TVw67T3sD0Xkw733U070EsQ3VVk0300MA3k0s0000E41s0Q0000A31w0C000k63lz0D3wAw73zzkTzzzz7U", 1)
FindText().PicLib("|<挑战关卡>*150$121.sTlVzz3zVzztzwzzzkzzwDkkzzVzknzkTw7zzsDzy7sMTzkzsEzwDy3zzw7zz3wADzsTw8Ty3y3zzy00TVu66Tw7y67zVz1zzz00600327y073bzkz1zzzU03001U3z03Vzy0003zzk01U00k3zU1kwz0001zzsDzk10M1zkTs0TU000zzw7zy3kA1zsTU07k000Tzy3zzVs60zwDk03zz1zzk0001kz33zy7s0TzzUzzk0000s7VVzz3y1rzzkTzs0000Q3kkDs03sszzsDzw000081sM3w00w8S0000D000000sA0y00S4D00007zy3zw1k60D00D0DU0003zz1zy0U303Vw7U7k0001zzUbz0E1V1kz3k7zzU7zzzk0zwA0klsTVw3zzU3zzzs03y6EMRwDky3zzU0zzzw00T3sQDy7sS3DzU07zzy307VsC7D3sD1Xz0A1zzz1s7kw73XU060Fy0D07zzUz3sQ7VVk0200s0Dk0TzkTzU87k0s0000M0Dw0TzsDzs43s0w001US0TzUDzw7zw7Xy0S7sFsDUzzwDzy3zyDzzUzzzzyDvzzzzzz1zz", 1)
FindText().PicLib("|<红色的关卡的循环图标>E50000-0.70$71.000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001U00000000003k00000000007k0000000000Ds0000000000Tw0000000000zy0000000Tzzzy0Tzzs00zzzzz0zzzk01zzzzzVzzzU03zzzzzXzzz007zzzzy7zzy00DzzzzkDzzw00Tzzzz0Tzzs00zk7zs000Tk01z07z0000zU03y0Ds0001z007w0TU0003y00Ds0w00007w00Tk1U0000Ds00zU000000Tk01z0000000zU03y0000001z007w0000003y00Ds0000007w00Tk000000Ds00zU0000A0Tk01z00001s0zU03y00007k1z007w0000zU3y00Ds0007z07w00Tk000Ty0Ds00zzzU3zzzzk01zzz0TzzzzU03zzy3zzzzz007zzwDzzzzy00DzzsTzzzzw00TzzkDzzzzs00zzzU7zzzzk00zzy03zw0000000001zk0000000001zU0000000000z00000000000S00000000000Q00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001", 1)
FindText().PicLib("|<黄色的关卡的循环图标>F9A90E-0.60$56.003000000000w00000000DU00000003y00000000zs0000000DzU0000zzzzw0zzzzzzzzkDzzzzzzzz3zzzzzzzzszzzzzzzzwDzzzzzzzw3zzzzzzzy0zzzzw0zy0007zy0Dy0001zzU3y0000Tzs0z00007zy0D00001zzU300000Tzs0000007zy0000001zzU000000Tzs0000007zy0000001zzU000000Tzs0000307zy00003k1zzU0001w0Tzs0001z07zy0001zk1zzU000zw0Tzzzs0zzzzzzzy0zzzzzzzzUzzzzzzzzsTzzzzzzzy7zzzzzzzzUTzzzzzzzs1zzzzw00Q07zs0000000Tw00000003z00000000Dk00000000w000000003002", 1)
FindText().PicLib("|<大活动·STORY>*150$103.w0TU00Tw0Ty01z0zUQ03k00Ds07z00DkTkQ00s007s00zU03sDkA00w003s00Tk00w3sC1kzy1zs1k7sDUD1w61yzz0zw3w1w7s7UQ70zzzUTw3z0y3y3sC3UTzzkDy1zUT1z1w71s3zzs7z0zsDUzUz11w0Dzw3zUzw3kTUTUUz01zy1zkTy1s60Ts0zk0Dz0zsDz0w00Dw0Tw07zUTw7zUS00Dz0Tzk1zkDy3zkT00DzUDzy0zs7z0zsDU0DzsDzzkTw3zUTs7kQ3zw7zzsDy1zsDw3sD0zy3z7w7z0zw3w3w7UTz1zUw3zUTy0Q1y3s7zUzU01zkDzU01z1w3zkTk01zs7zs01zUz0zsDw01zw3zy01zkTUTw7zU3zy1zzk3zsDs7y3z", 1)
FindText().PicLib("|<剧情活动>*150$121.zzzzbwDz3zzzzz7zzzszs00zVy7z1zz7zs1zzzsDw00Tkz3U00T0s00T00w7y00AMTVU00DUA00TU0S3z006ADk000DsC01zk0D1zVz327s3s7zz703zs07Uzk01V3k0003zzzVzzzz00M00kVk0001zzzkzzzz00A00MEs0TUzzzzsDzzzU0400A8Q1000Dbk003000023Vy4C0k003Us001U07113kz270M001UA000k03VkU01V3UDzzzs6000M01ksE00EVU7U03z3zkzzkzsQ8008Ew3k00zvzsTzsTwC40048TVs00TzzwDzsAS727Vy4DkwDsDzy007wAD3V3kz27sS7w7zD003y771kU01V3wD003zXU00y3VVsE00kVy7U01zUk00T3Ukw000Mkz3k00zksTsDU08S00sDsTVs00TkQDw7U00D00y7wDkw00DkS7y3k00D04T3y7sS007sD3z1s3w7U201z3wD3y3sDU00wDw10X00w1y7Xw1w7k00Tzy20NU0S0z3ly0y7s00Dzz3UDk0D0zVsz0zbw007zzlkDsz7VzkwTUzzy7z7zzzsz", 1)
FindText().PicLib("|<剧情活动·黑色十字>2B2B2B-0.90$67.00000D00000000007U0000000003k0000000001s0000000000w0000000000S0000000000D00000000007U0000000003k0000000001s0000000000w0000000000S0000000000D00000000007U0000000003k0000000001s0000000000w0000000000S0000000000D00000000007U0000000003k0000000001s0000000000w0000000000S0000000000D00000000007U0000000003k0000000001s0000000000w0000000000S0000000000D00000000007U0000DzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU00007U0000000003k0000000001s0000000000w0000000000S0000000000D00000000007U0000000003k0000000001s0000000000w0000000000S0000000000D00000000007U0000000003k0000000001s0000000000w0000000000S0000000000D00000000007U0000000003k0000000001s0000000000w0000000000S0000000000D00000000007U0000000003k0000000001s0000000000w0000000000S0000000000D00000000007U0000000003k00004", 1)
FindText().PicLib("|<剧情活动·0%>*150$36.k0DkDXU07kD3007XD3003XC71y3XC71y3XCD1y3UAD1y3kAT1y3sMT1y3zsz1y3zkz1y3zlz1y3zVz1y3zVz1y3zX01y3z201y3z6A1y3y6A003yCA003wCAU07wS0k0DsT0U", 1)
FindText().PicLib("|<大活动·剩余时间>*150$128.zznzlzzyTzzzzzyDzzzzzzs0TsTzz3zzzzzzVzXzzzy007y7zzUzzzzzzsTkQ000U07zVzzk3zz00zy7y300080TwMTzs0Tzk0DzVzkE003z7z67zs63zw03zsTy7zzkU00lVzw7kDz3kU00zbzzw0004MTw3y1zkw800Dzzzz000167w1zk7wD2003kzzzkU00lVw0zz0D3kU00wC00wDANwMQ00001kwDzVz3U0D3X4T6700000wD3zsTks03kUl0lVsM00CD00zy7wC7sw0AEAMTTy3zzk0ATVz3XyD034767zzkzzw033sTkszXksl7lVzzwDzz3kkS7wC7kwCAFgMTzy3zzkwC7Vz3U0D034N67s0001wD3ksTks03k0lUFVy0000T3kw67wC00wC8MAMTU0007kwDVVz3XyD3w3z67zzUzzwD3xsTkszXkz0DlVzzwDzz00zy7wCDswDU1yMTwD3Xzk0DzVz3U0D3k07y7y3kkDw03zsTks03ks1UzVz1wC1z01zy7wC00w8AQDsTUz3kDkzzzVz3zzz077by7kTkz1wDzzkTkzzzk3lzs1sC0DkDzzy0DwDzzU9wTy0T7k7y7zzzU3z3zzs3z7zkDzw1zzzzzs1zkzzz1zzzwTzz3zzzzzzzzwTzzzs", 1)
FindText().PicLib("|<大活动·关卡图标>*100$120.001kzzsS003z3zy7k000001kTzsS001y3zy7k000001kTzsS001y1zy7k000001sTzkS003y0zy7s0013zzsTzky7zzy0zy7zy7z3zzsDzky7zzy0Ty7zy7z3zzwDzUy7zzy0Ty7zy7z3zzwDzVy7zzy4Dy7zy7z3zzwDzVy7zzy6Dy7zy7z3zzy7zVy7zzy67y7zy7z3zzy7z3y7zzy77y7zy7z3zzy7z3y7zzy73y7zy7z3zzz3z3y3zzy7Vy7zy7z007z3y7y007y7Vy7zy7z007z3y7y007y7ky7zy7z007zVy7y007y7kS7zy7z3zzzVyDy7zzy7sS7zy7z3zzzVwDy7zzy7sC7zy7z3zzzlwDy7zzy7wC7zy7z3zzzkwTy7zzy7y67zy7z3zzzksTy7zzy7y67zy7z3zzzssTy7zzy7z27zy7z3zzzsMzy7zzy7z27zy7z3zzzsMzy7zzy7zU7zy7z3zzzw0zy7zzy7zk7zy7z3zzzw1zy7zzy7zk7zy7z001zw1zy003y7zs7zy7z000zw1zy001y7zs7zy7z000zy3zy001y7zw7zy7z000zy3zy001z7zw7zy7zU", 1)
FindText().PicLib("|<大活动·关卡图标2>*100$99.001zzzzzzzzzzzzzs00zzzzzzzzzzzzzz00Dzzzzzzzzzzzzzs03zzzzzzzzzzzzzz00zzzzzzzzzzzzzzs0Dzzzzzzzzzzzzzz03zzzzzzzzzzzzzzs0zzzzzzzzzzzzzzz0Dzzzzzzzzzzzzzzs3zzzzzzzzzzzzzzz0zz03zzzzzzzzzzzsDzs07zzzzzzzzzyD3zz7sTzzzzzzzzzlszzszXzzzzzzzzzyDDzz7wTlzi7zlzsTk/zzszXs3sUDs3w0s0Tzz7wS0D00y0D07UDzzsz3XtsT7XsvwSDzzz7kwz77wQzbzXlzzzs0D7wszX7wzwSDzzz03s077wM07s3lzzzswT00szX00w0SDzzz7Xs0D7wM073nlzzzsyD7zszX7zlySDzzz7lszz7swzyDnlzzzsz7Xzsz7XzlwSDzzz7sQ7D1Vy7C63kzzzszXk1s0Ts1s0T0zzzbyTUT47zUTUnwDzzzzzzzszzzzzzzzzzzzzzzz7zzzzzzzzzzzzzzzszzzzzzzzzzzzzzzz7zzzzzzzzzzzzzzzszzzzzzzzU", 1)
FindText().PicLib("|<大活动·任务>*150$58.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzlzyTzkzzzz3y0zy3zzzw001zk00zzV00Ty001zw40DzU007zkvkzw1z0zy3z3zk3s7zkDwDz421zz0zkzzs07zs3z3zy003zUDwDy0001y0U00s0y0Dw2003Vzztzw800Dzkzzzkzkzzy3zzz3z3zk001zwDwDz0007zkzkzw000Tz3z3zzUzVzwDwDzw7yDzkzUzzUzkzz3003k7y3zwA00C0w0Tzkk00wDk1zzXzzznzUzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzy", 1)
FindText().PicLib("|<大活动·小游戏>*150$91.zzzzzzzrzzzzzzzzzUzzyz3sTzzz3nzzkTzy7UwDzzzVUzzsDzy0sS7zzzkkDzw7zzUQT0300sQ7zy3zzs0001U0QD3zz1zzzE000k0C7rzzUzzzs000Q071sT7kTDzw00Tzz3U0DUsC3zTVsTzj0003kQ71z3kw07XU001kS3kT0MTU1Ukk0DsD1sDUQ0M0s8M3nw7Uy3wC0A0y0DVsS3kT1zj07Uz0DksC3sDUTzU3kzk7sQD1w7sDzlVsTw3wA70y3w7zkkU1z1y07Uz1z1wMM00z0T07UTUzUy4A00T0DU3kTkTkT2600DU3s2yDsDsD133kzU0w37jw7yTV3VsTUEQ3Vzy3zzkVlwDUQQ0kzz1zzkEky7kCM00Tk0zzsEMT3wDs00Ts0Tzs0EA1zDy20Dw0Tzw4M60zzzbU7z0DzzbA70zzzzs7zUzzzzzDlzzzzz7U", 1)
FindText().PicLib("|<大活动·小游戏·返回>*150$76.wzzzw3zzzzzzzVzw007s0000083w000DU00000U7k000S0000030T0003s00000C0w007zU00000s1k1zzy000003kT0zzzs7zzzkDXw3ztzUTzzz0zTk000y1zzzw3zz0003s7U03kDzw000DUQ0070zzk001y1k00Q20D0007s7001k00w7TUTUQ007003kMw1y1kD0Q00C01kDs70y1k00s000zUQ3s70U3U007y1kDUQ3kC1U0Ts70y1kD0s703zUQ3s70w30y0Dy1k00Q3kA3s0zs7001kD0kC01zUQ0070w00k03y1k00Q3k00003s7001kD00E10DUTzzz0w03US1y1zzzw3U6C3wDs7zzzkA05wztzUDzzy0U03zzqS000000000000s000000000007U00000Us0000S0000027s0001s00000Azw000DUDzzy0vzz007y1zzzw2", 1)
FindText().PicLib("|<大活动·小游戏·十字>*100$54.zzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzw0Tzzz000000000000000000000000000000000000000000000000000000000000000000000000000000000zzzy0Dzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0Tzzzzzzy0TzzzU", 1)
FindText().PicLib("|<大活动·小游戏·扩充完成>*200$157.y7zzXzzzzkzzzzzzXzzzzzzUwTz3zz1zzzzkDzzzzz0zzzzzzkQ7zVzzkTzzzw3zzzzzUTzzzzzsA1zkzzsDzzzy1zzzzzk7zzzzzw70TsTzw7zzzz0zzzk00001zzzy3kTwDzy1zzzzUzzzs00000zzzy0s7y3s000y000003w00000Ts00000E0A000T000001y00000Dw00000806000DU00000z000007y000004030007k00000TVzzzy3z00000201U3jzw00000Tkzzzz1zU000wD00kTzzzz0TwTzsTzzzUzkTz1zzy3sDzzzz0Tw7zwC000kTsDzkTzz3w7zzzz0Tw1zy7000QDw7zsD7zVy3zzzz0Tz0TzzU00Dzy3zw7Uzkz1zzzz0DzU7zzk007zz0063kTsDUzzzz00001zzzzzzzzU031kTw0kTzzz00000Tzzzzzzzk01UsDw0MDzzzk0000Dzzzzzzzs00kM7k0A7zzzs00003w000007w00M07k063zzzw00001y000003y3sC03s031zzzz00s7Vz000001z1w703y0DUzzzzzUy3vzU00000zUy3U1z0DkzzzzzUT1zzm00000TkT1k1zy7sTzzzzkDUzzzz1y3zzsDVw0zz3wDzzzzsDkTzzzUz1zzs7ky0zzVw7zzzzs7sDvzzkTUzzw3kT0yzky3zzzzw3w7wTzsDkTzy30D0T7sT1zzzzw1y3y7zs7sDvz1U70DVwD0zzzzw1z1z3zw7w7wTUk303ky7Uzzzzs1zUz1zw3y3w7UQ301kS3kTzzzk0zkDUzs3z1y3kSy000M1kDzzzU0zs00T01zU03kDy000C0kDzzzk0zw00T01zk01s7z0A070M7zzzw1zz00Dk3zw00y7zkT07US7zzzz1zzU0Ds3zy00zXzwTk3szrzzzzbzzy1zyTzzk1ztzzTy7k", 1)
FindText().PicLib("|<快速战斗的图标>*200$46.01z01zzy03y03zzw07w07zzs0Ds0Dzzk0Tk0TzzU0zU0zzz01z01zzy03y03zzw07w07zzs0Ds0Dzzk0Tk0TzzU0zU0zzz01z01zzy03y03zzw07w07zzs0Ds0Dzzk0Tk0TzzU0zU0zzy03y03zzk0Tk0Tzy03y03zzk0Tk0Tzy03y03zzk0Tk0Tzy03y03zzk0Tk0Tzy03y03zzk0Tk0Tzy03y03zzk0Tk0Tzy03y03zzk0Tk0Tzy03y03zzk0Tk0Tzy03y03zzk0Tk0TzzU", 1)
FindText().PicLib("|<进行战斗的进>*200$25.zzzzzzzzyTnnz7tlzVwszsw8DyM01zw01zzVXzztlz1wszUwADsM01yA00z7XXzXnlzllszskwTwQyDw6zjw0TySQ00DDk07zzzzzzzzk", 1)
FindText().PicLib("|<MAX>*150$41.1w7sD7W3sDUSD47kT0wC8DUy1wMED1w3slUS3s7lX0s7kDl61kDUTUQ3UTAT0s70wMy1lC1sly7WQXlXwD4t7X7sS8mD6DkwFYSATVsm8wMz3lYFsky3X9XU1s76H703kCA6C07UAMAQSCAMkMswQMlUllsslXVXXlVV7377V7WCCCD2D4QQMS4S4", 1)
FindText().PicLib("|<大活动·协同作战>*150$122.sTzzzzzzzzzzzzzzzzzzy7y7zzzzzzzwTXzzwDy7zVzVzz00007y3kTzz3zVXsTsTzk0001zVwDzzkzsMy7y7zw0000TkS3zzwDy67VzVzz1zzw7w7U01z03VlsS00TkzzzVy3k00Tk0sRy7U07wDzzsTUw007w0C7w0801z30067kC001z03UU0200Tkk01Vs3V1zzkzk000y67wA00MS0kETzwDk03VzVVz3zzy708A7zz3w07sQsM3kzzzVk2700zkzUBy66C0wC00sS0tk0Dw7z3DVV3UD3U0C7UDw03k03klsMEs3ks03Vy3z00w00w8S6AC0QC7ksTUzkTz00D2DV33U73VwC7sDw7zky3k3sEUs1ksT3Vy3z1zwDky0y6MS4QC7ksTUzk073wDUTVw7V73U0C7sDw01kz3sDsT1sTks03Vy3z00QDky3y7Uy7wC00sTUzk0D3wD0rVsDVz3Uzy7sDw7zk03U8sQ7kzksTzVy3z1zw00k0C630DwDzy0TUzkTz00003V0s3z3zzU7sDw7zk0060sMS1zkzzs3y3z1zwDkXkS7DVzwDzy1zUzkTzXzzyC", 1)
FindText().PicLib("|<大活动·灰色的全部>595958-0.90$74.006000070000001s0007k000000z0001w0Tz000Tk000TU7zw00Dz007zztzz007zs01zzyTzk03zz00TzzbXs03zDs07zztsy01zVzU0T3wSDU1zkDy07ky7bk1zk1zk0wDVtw5zs07zUDXsSS3zw00zw3tw7bUrzzzzy0yT1vs4zzzzzXzzzSy0CzzzxkzzzrjU0Dzzz0Dzzxtw000z001zzySD000Dk000007Xs003w000001sy000z000000S7U0Tzzw0Dzz7Vs07zzz03zzlsS01zzzk0zzwS7U0Tzzw0Dzz7Xs003w003s7lzy000z000y1wSzU00Dk00DUT7jk003w003zzlvs0zzzzz0zzwS00DzzzzkDzz7U03zzzzw3zzls00zzzzz0zzwS00000000D0T7U08", 1)
;tag 特殊活动BOOM!THEGHOST!
;tag 协同作战
FindText().PicLib("|<COOP的P>*150$64.00000000zk000000003y000000000zk000000007y000000000zk000000007y000000000zk000000007y000000000zk000000007y000000000zk000000007y000000000zk00001zzzzy000007zzzzk00100Tzzzy000A01zzzzk001k07zzzy000D00Tzzzk001w01zzzy000Dk07zzzk001z00Tw00000Dw01zU00001zk07y00000Dz00Ts00001zw01zU0000Dzk07y00001zz00Ts0000Dzw01zU0001zzk07y0000Dzz00Ts0001zzw01zU000Dzzk07y0001zzz00Ts000Dzzw01zz001zzzk07zzzzzzzz00Tzzzzzzzw01zzzzzzzzk07zzzzzzzz00Tzzzzzzzw01zzzzzzzzk07zzzzzzzz00Tzzzzzzzw01zzzzzzzzk07zzzzzzzz00Tzzzzzzzw01zzzzzzzzk07zzzzzzzz00Tzzzzzzzw01zzzzzzzzk07zzzzzzzz00Tzzzzzzzw01zzzzzzzzk07zzzzzzzz00Tzzzzzzzw01zzzzzzzzs", 1)
FindText().PicLib("|<开始匹配的开始>*200$88.zzzzzzzzkTzwDzzzzzzzzzz1zzkTzw000001zw7zy1zzk000003zkTzs7zz000000Dz3zzUzzw000000zwDzw3zzk000003zkzzkTrzzkDzUzzy3zy1wDzzUzy3zzk6TsDUzzy3zsDzw00T0z1zzsDzUzzU01w7w3zzUzy3zy007UzsDzy3zsDzs00Q3zUTzsDzUzzw71kTy0zzUzy3zzkQ60003zy3zsDzz3kE0007zsDzUzzwD30000TzUzy3zzkwA0001U000001y3ks07y00000007sC3Xzzsk000000TVsDzzzj0000001y7Uzzzzw0000007kS7zzzzzz0zw3zz0kT0007zw7zsDzw01w000TzkTzUzzw07k001zy1zy3zzs0z0007zs7zsDzzk3w3zUTzUTzUzzzUDkTz1zw3zy3zzz0T1zw7zkDzsDzzw0w7zkTy1zzUzzzU1kTz1zk7zy3zzy071zw7z0TzsDzzk0Q7zkTs3zzUzzy1VkTz1z0Tzy3zzkDD0007s1zzsDzy0xw000S0DzzUzzk7zk001s1zzy3zz0zz0007kDzzsDzy7zw000TXzzzUzzszzkTz1zTzzy3zzzzz1zw7U", 1)
FindText().PicLib("|<普通>*200$112.007001k00000000000003y007w0000000000U00Tw00zs00100Dzzzz001zk07zU00D00zzzzz003zU0Tw001y03zzzzy00Dy03zk00Dw0Dzzzzs3zzzzzzzs1zs0zzzzz0TzzzzzzzU7zk3zzzzs1zzzzzzzy0DzU0DkTz07zzzzzzzs0TzU0znzs0TzzzzzzzU0zz0Dzzy01zzzzzzzy01zw0zzzk07zzzzzzzs03zU1zzy003y7yDwDw007w01zzs00TsTszkzk00DU07zzs01zlzXz3z000Q1zzzzzk3z7yDwDs000U7zzzzz0DwTszlzU0000Tzzzzw0TtzXz7w00001zzzzzk1zbyDwzk00007zzzzz07sTszlz00000TsTsDwTzzzzzzzy0001zUzUznzzzzzzzzwDzs7y7z7zDzzzzzzzzkzzkTzzzzwzzzzzzzzz3zz1zzzzznzzzzzzzzwDzw7zzzzzDzzzzzzzzkzzkTzzzzwzzzzzzzzz3zz1zzzzzk000000000Dzw7y7y3z0000000000zzkTsDsDw0Tzzzzzy003z1zzzzzk1zzzzzzs00Dw7zzzzz07zzzzzzU00zkTzzzzw0Tzzzzzy003z1zzzzzk1zzzzzzs00Dw7zzzzz07zzzzzzU00zkTzzzzw0Tw000Dy003z1zVzUzk1zU000zs00Dw7y3y3z07z0003zU00zkTsDvzw0Tzzzzzy003z1zUzjzk1zzzzzzs00Dw7y3yTz07zzzzzzU00zkTsDtzs0Tzzzzzy003zVzUzbzU1zzzzzzs00zz7y3yTs07zzzzzzU07zyE000w00Ts000Dy00zzz0000001zU000zs0Dzzzk007zk7zzzzzzU1zzzzzzzzz0Tzzzzzy07zXzzzzzzs1zzzzzzs0Dw3zzzzzzU7zzzzzzU0TU7zzzzzy0Tzzzzzy00w07zzzzzs1zzzzzzs03k03zzzzz07z0003zU06000Tzzw00Ts0007y00000000002", 1)
FindText().PicLib("|<准备>*200$87.zzzzzzzzzyDzzzzzzkT7zzzzUTzzzxzy3UTzzzs3zzzwDzkS1zzzy0zzzz0zw7kDzzzU000zw3zUz0zzzs0001zUTsDw7zzy0000Dy1z1zVzzzU0003zkDk0001zk1zy0zz0y0000Ds07zUDzs7U0001w00Ts3zzUQ0000Dk00w0zzw30TsDzz3k00Dzzlk3z1zzwz003zzyy0TsDzzzy00zzzzU3z1zzzz001zzzs0TsDzzy0000Tzy00000Tk000000zU00003k007U00Dy20000T003zU03zsk0003s07zzk0Tzi3z1zzUDzzzw7zzkTsDzw00000Dzsy3z1zzy00000zz1kTsDzzk00007zkC0000zy00000zy1k0003zk00007zkS0000Ty3z1z0zw3k0003zkTkDs7zUy0000Ty00000zs7kTsDzzk00007z0y3z1zzy00000zkDkTsDzzk00007y1y3z1zzy3y1z0zUDk0001zkTsDs7w3y0000Dy3y1z0zUTk0001zk00007s7y0000Dy00000zkzk0001zk00007zzy3zzzzy00000zzzkTzzzzk00007zzy3zzzzy3zzz1zU", 1)
;tag 通行证
FindText().PicLib("|<通行证·2>*200$49.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzUDzzzzzy00zzzzzs007zzzzs000zzzzk000Dzzzk0003zzzk0Tk1zzzs1zy1zzzs1zzlzzzs3zzzzzzw3zzzzzzw1zzzzDzy1zzzz3zy0zzzz0zz0zzzz0DzUTzzz03zkTzzz00zsDzzz00Dw7zzzy1z007zzz0zk07zzzUTw07zzzkDz07zzzkDzk7zzzs7zw7zzzs3zz7zzzw1zzrzzzw1zzzzzzw1zzzwzzw0zzzwDzw0zzzw1zs0zzzw0000zzzz0000zzzzk000zzzzy000zzzzzU01zzzzzy07zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz", 1)
FindText().PicLib("|<通行证·3+>*200$57.zzzzzzzzDzzzzzzzztzzzzzzzzz7zzzzzzzzwTzzzzzzzzVzzzzzzzzy3zzzzzzzzs7zzzzzzzzkzy3s0000DrzkT00001zzy3s0000DzzkT00001zzy3s0000DzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzkT00001zzy3s0000DzzkT00001zzy3s0000DzzkT00001zzy3s0000DzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzkT00001zzy3s0000DzzkT00001zzy3s0000DzzkT00001zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw", 1)
FindText().PicLib("|<通行证·任务>*100$69.znzzszzy3zzzw7zk3zzUzzzzUz00Tzs7zzzs0001zy0007z1000zzU000TkA01zzk0003y3U0Tzs0000zUTy3zy07zUDs7zkTzk0Ts3z0zy3zz20s0zk7zkTzxs00Tw0zy3zzzU07z07zkTzzU003s0zy3zw00000060007U0000A0k000y03y01m60007kDzzkSkk000zzw7zzy60007zzUzzzkzy3zz00007y7zkTzs0000Tkzy3zz00003y7zkTzs0000zkzy3zzzUDw7y7zkTzzw3zkzkzy3zzz0zw7y7zkTzzkDzUzkw001zs3zwDy70007s0zz1zks000w0DU0Dy70007k3y03zks000z1zk0zy7zzzztzy0Tw", 1)
FindText().PicLib("|<通行证·奖励>*100$68.zlzzzzzzzzzzsDkzzzzzy3zy3s7zz003UzXUw00TU00sDkMC001s00C3y63000S003UzUU000DU00sDwM07y3sTzy3zS27z1y3zzUzz0n7UTU01U0D0DUkDs00M0303s07y0060000z03zU01U000Dk1zsADy306300zy73zVkXUU0zzVkzsQ/sA0zzsQ0S73y30zzy707VkzUvzzzVk1sQDzw7zzsQ0S73zy1zzy7271k00000DVVVkw000003sMMQD000000y6673k00000DVVVUwDzk3zzsMMMC3zs0Tzy6667Uzs03zzV3V1sTs1U7zk0s0y7k0w03w0A0D100TU0D00020M0Ty03U101k60Tzw1w8kQw3lzzzszrDzj1s", 1)
FindText().PicLib("|<SP灰色的全部>7D7C7E-0.90$73.000000020000003k000DU000003w0007k1zs003y0003w0zz003zU01zzwTzk03zs00zzzDzs03zy00Tzzbzs03yTk0Dzznlw07y7w07zzlsy07y1zU0y7kwy0Dy0Tw0T3sST0Tw07zU7VwDDVzw00zw3tw7bUzzzzzy1wy3rk7zzzzy7zztvk1zzzzy7zzyxw03zzzm3zzzSS01zzzs1zzzjDU00Dk000007Xk007s000003lw003w000001sy03zzz01zzswD01zzzk0zzwS7U0zzzs0TzyD3k0Tzzw0Dzz7Xs0Dzzw07kDXzw003w003k7lvy001y001s3sxy000z000y1wSy0TzzzzUTzyDA0DzzzzkDzz7U07zzzzs7zzXk03zzzzw3zzls01zzzzy1w3sw02", 1)
FindText().PicLib("|<购买PASS的图标>*200$45.0Dzzzzzs1zzzzzz07zzzzzs0zzzzzzy000000Dk000000z0000007s000000zU00000Dw000001zk00000Ty000003zs00000zz000007zs00001zzU0000Dzw00003zzk0000zzy00007zzs0001zzz0000Dzzw0003zzz0000Tzzs0007zzy0007zzzUTzzzzzw7zzzzzz1zzzzzzsDzzzzzz00000Dzs00001zzU0000Dzy00001zzw0000Tzzzzzzzzzzzzzzzzy3zzw7zzUDzz0Tzs0zzk3zz07zy0Dzs0zzk1zz07zy0Tzw0zzk3zzUDzz0zzz7zzyDw", 1)
;tag 单人突击
FindText().PicLib("|<灰色的挑战>484A4E-0.90$90.1y07lw000T00TU01y07ly000z00TU01y07ly000z00TXU1y07ly000z00Tjk1y07ly000z00Tjk1y07ly800z00Tbs1y3blyS00z00TXw1yDblyTU0z00TXwTzzrlyzU0zzsTVwzzzzlyz00zzsTVkzzzzlzz00zzsTU0zzzzlzy00zzsDUSzzvzlzw00zzsDzyzztzlzw00z01zzy1y1zlzs00z0Dzzy1y1zlzs00z0Dzzy1y0zlzk00z0Dzzs1y07ly000z07zsU1yE7ly000z07zks1zs7ly000z00Dly1zs7lzU0zzzkDly3zs7lzk0zzzkDlwTzsTlzs0zzzk7nwzzszlzw0zzzk7nszz3zlzy0zzzk7zszy7zlzz0zbjk7zkTyTzlzzUz07k7zkTyzzlyTkz07k7zU1yTzlyTUz07k7zU1yTjlyDUy07k3z01yCTVy70z07k3z01y4TVy20z07k3yA1y0zVy60z07k7wC1y0zVy7Uz07kDyD1y1z1y7kzzzkTyT1y3z1y7kzzzkzzT1y7y1yDkzzzvzzz1yDw1zzkzzzzzzyTyzw1zzUzzzzyTyTyzs1zzUzzzzwTyDwTU0zz0z07vkDwDwD00zz0z07lU7wDk600Dw0000003sU", 1)
FindText().PicLib("|<RAID>*80$89.zy003y003y0w00Dzw007w003w1k00Dzs007s007s3U00TzU00DU00DU7000zz000T000D0Q000zy000S000S0s001zs000s1U0s3k0M1zk7w1k7w1k70Dk7z0Ds7UDk3UC0zUDy0zUC0zUC0w1y0Tw1z0Q1z0Q1k3w1zk3w0s3y1s3UDs3zUDs3UDs3UD0Tk7z0Tk700070S1zUTy0z0C000C0s3y0zs3y0s000s3k7w1zk203k001k7UDk7zU007U003UC0zUDy000z000C0Q1z0zw001w000Q1s3w0zs001s3y0s3UDs3zU003U7s3k70Tk7z00070Tk70S0z0Dy0z0C0z0C0w3y0zs1y0s1y0M1k7w1zk7w1k7w1k7UDs3zUDs3UDs3UC0TUDy0zUC0TUD0Q1z0Tw1z0Q1z0Q1s3w0zs3y0s3y0s3UDs3zk7s3k7w3k70Tk7z0Tk70Tk70S000Ty0zUC0zUC0s001zw3y0w1y0Q1k007zk7w1k7w1k3U00TzUDs3UDs3UC001zz0zU70TU70Q007zzzz0Tzz0S1s00Tzzzy0zzy0zzzzzzzzzs3zzw1zzzzzzzzzk7zzk7zzzzzzzzzUzzzUzzzzzzzzzy7zzz3zzzzzzzzzwTzzwTzzzzzzzzzvzzzvzzzzzzzzw", 1)
FindText().PicLib("|<单人突击·挑战>*200$90.y1zyCTzzzzzzUTzy1zs61zzz0zzUTzy1zs61zzz0zzUSTy1zs61zzz0zzUMDy1zs61zzz0zzUM7y1zs61zzz0zzUM3y1yM61Xzz0zzUQ3y1sM61Uzz007US1U000610Tz007US70000610Tz007UTD0000610zz007kTz0080601zz007kDl00A0601zz007k0100A0603zz0Ty001y1y0603zz0Ts001y1y0607zz0Ts001y1z0617zz0Ts001y1zs61zzz0Ts03zy1Ds61zzz0Ts0DTy0Ds61zzz0TzkD7y07s60Dz000DkC1s07s607z000DkC1007U603z000DsA30070C01z000Ds4300w0C00z000Ds07U1s0C00T000Ds07U1U0C10D0zkDs07U1U0C1UD0zkDs0Dy1U0C1kT0zkDs0Ty1k0C1kz0zkDw0Ty1sUC1tz0zkDw0zy1tUS1zz0zkDw0ry1z0S1vz0zkDs1ny1z0S1sz0zkDk1ky1y0y1sD000DU1Uy1w0y1sD000D00Uy1s1y1kD000A000U1k1y00D0000000U103y00T0000001U1U7y00T00001U1k3kDz00T0zkA3k3k3sTz00z0zkCDs3kDwzzk1zUzzzzw7U", 1)
FindText().PicLib("|<个人突击·进入战斗的进>*200$43.wzzkTVzwDzsDUTw3zw7kDy0zy3s7zUDz1w3zs3zUy1zy0zUD0TzUs0000zsw0000Tyy0000Dzz00007zzk0007zzzkT0zzzzsDUTzzzw7kDy0Ty3s7y07z1w3z03zUy1zU1k0001k0s0000TUQ0000DsC00007w700003y3y0y1zz1zUz0zzUzUTUTzkTkTkDzsDkDs7zw7kDw3zy3s7y1zz1s7z0zzUy3zUTz0DXzkDz03vzwDz00Tzzzz000Tzw00Q00000UTU0000MTw0000CTzU000Djzzs1zz", 1)
FindText().PicLib("|<红色的MODE>F12C1D-0.90$121.0000000y00Dzy0007zzzk000403zs07zzw00Dzzzw000607zz03zzzU0Dzzzz000D07zzk1zzzs0Dzzzzs00DU7zzw0zzzy07zzzzy00Dk7w1z0S00zU7k000zU0Ds7s0DkD007s3k000Tw0Tw3s03s7U01w1s000Dz0Ty3s00y3k00T0w0007zkTz1s00D1s007US0003ryzjUw007Uw003kDzzz1szzXkw001sS001w7zzzUwDzVsS000wD000S3zzzkS3zUwD000S7U00D1zzzsD0T0S7U00D3k007Uzzzw7U70D3k007Vs003kS0003k007Vs003kw001sD0001s003ky003kS001s7U000w001sD001sD000w3k000S000w7k01w7U00y1s000D000S1w01w3k00y0w0007U00D0z01y1s00z0S0003k007UDs3y0w01z0DU001s003k3zzy0Tzzz03zzzzw001s0zzy0Dzzz01zzzzy000w0Dzy07zzz00Tzzzz000S01zw03zzy007zzzzU00D007k01zzs000zzzy", 1)
;tag 剧情模式
FindText().PicLib("|<SKIP的图标>*200$20.7szky7w7Uz0M3k20Q00100000040030M3kC1wDVz7sznyTy", 1)
FindText().PicLib("|<1>*150$38.zzzzzwzzzzzz7zzzzztzzzzzyTzkzzzXzUDzzszU3zzyDk0zzzXw0Dzzsz03zzyDlUzzzXzsDzzszy3zzyDzUzzzXzsDzzszy3zzyDzUzzzXzsDzzszy3zzyDzUzzzXzsDzzszy3zzyDzUzzzXzsDzzszy3zzyDzUzzzXzsDzzszy3zzyDzzzzzXzzzzztzzzzzyTzzzzz7zzzzznU", 1)
FindText().PicLib("|<2>*150$14.zzzzzU7k0w0D7XzszkDk3s3w7z7zlzw0D03k0zzzzzU", 1)
FindText().PicLib("|<白色的AUTO>FFFFFF-0.90$110.03z00Dk0TUzzzw0zzy00zk03w07sDzzz0Tzzk0Dw00z01y3zzzkDzzy07zU0Dk0TUzzzw3zzzk1zs03w07sDzzz1zzzw0Ty00z01y00z00Tk0z0Dzk0Dk0TU0Dk07s0Dk3tw03w07s03w01y03w0yT00z01y00z00TU0z0Tbs0Dk0TU0Dk07s0Dk7ly03w07s03w01y03w1wDU0z01y00z00TU0z0z3s0Dk0TU0Dk07s0DkDUz03w07s03w01y03w3s7k0z01y00z00TU0z1y1w0Dk0TU0Dk07s0DkTUTU3w07s03w01y03w7k7s0z01y00z00TU0z3w0y0Dk0TU0Dk07s0Dkzzzk3w07s03w01y03wDzzw0z01y00z00TU0z3zzz0Dk0TU0Dk07s0Dlzzzs3w07s03w01y03wTzzy0z01y00z00TU0z7k0TUDk0TU0Dk07s0Dnw03w3w07s03w01y03wz00z0Tzzy00z00TzzzDU0Dk7zzzU0Dk07zzzrs01y1zzzk03w00zzzty00TUDzzw00z00DzzyT007s1zzy00Dk01zzzDk01z0Dzy003w007zz2", 1)
FindText().PicLib("|<灰色的星星>5B5D5F-0.90$41.0008000000s000001k000007k00000DU00000zU00001z000007z00000Ty00000zy00003zy00007zw0000zzy007zzzzz1zzzzzzrzzzzzzrzzzzzz7zzzzzw7zzzzzk7zzzzz07zzzzw07zzzzk07zzzz007zzzw007zzzk007zzz000Tzzz000zzzy001zzzw003zzzs007zzzk00Tzzzk00zzzzU01zyzz003zkTy007y0Dw00Dk07s00y003k00k001U4", 1)
FindText().PicLib("|<记录播放的播放>*200$93.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzUzzzzbzzszz1zzzw3zzU0Tzw3zs7zzzUS0001zzUTz0zzzw3k0007zw3zk7zzzUT0000zzUDy0zzzw3s000Tzy3zk7zzzUT0M71zzUDy0zzzw3w30kDs003k7zzs03kM61z000Q000z00S10kTs003U007s03k843z000Q000z0000001s0030007s000000Ds3zs000z0000001z0Tz0007zUS0000Dw3zk3k7zw3k0001zUTy0S1zzUTw007zw00U3kDzw3z000zzU000S1zzUTk001zw0001UDzw2s00U7zU000A3zzU00M60Dw0001UTzs0070s1zU00003zw001s7UTs30U00Ty000D0y3z0s6807zk030000zs70v00zy03s0007z0s7w07zk0T0000zs70zU1zz03s0007z0s7w0DzvUT0s60zs70zk3zzw3s71s7z0s7y0TzzUT0000zk70zk1zzw3s0007y1s7w07zzUT0000zkD0z00Tzw3s0007w1s7k01zzUT0000zUD0w007zw3s71s7s3k6000Tz0T0E60z0S0U1U0z07s0007k6000S07s0z0000y0k1U7s1zU7s0007sC0A1zUTw1z0000znk3kTy7zUTs7zs7zT0zDzwzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzw", 1)
FindText().PicLib("|<Bla的图标>*200$116.jzzzzzzzzzzzzzzzzzzkzzzzzzzzzzzzzzzzzzW0zzzzzzzzzzzzzzzzz0k0zzzzzzzzzzzzzzzs0y03zzzzzzzzzzzzzzs0Tk03zzzzzzzzzzzzz00Dy007zzzz000Tzzzy007zk00Tzzz0000zzzy003zy003zzs00000zzz001zzk00Tzk000003zzU00zzy007zs000000Dzs00Tzzk00zs0000000Ts00Dzzy007s00000003y007zzzs00w00000000T003zzzzzsQ000000001s07zzzzzzy000000000Dzzzzzzzzz0000000000zzzzzzzzzU0000000007zzzzzzzzU0000000000zzzzzzzzk00000000007zzzzzzzs00000000000zzzzzzzy000000000007zzzzzzy000000000000zzzzzzzU00000000000Dzzzzzzk000000000001zzzzzzs000000000000Dzzzzzw0000000000003zzzzzz0000000000000TzzzzzU0000000000003zzzzzU0000000000000zzzzzs00000000000007zzzzy000DU0001s0001zzzzzU007s0000z0000Dzzzzs001y0000Dk0003zzzzs000TU0003w0000Tzzzy0007s0000zU0007zzzzU001y0000Ds0001zzzzs000TU0003y0000Dzzzy0007s0000zU0003zzzy0001y0000Ds0000zzzzU000TU0003y0000Dzzzw0007s0000z00001zzzz0001y0000Dk0000Tzzzk000TU0003w00007zzzw0007s0000z00000zzzy0001y0000Ds0000DzzzU000TU0003y00003zzzs0003s0000S00000zzzy000000000000000DzzzU000000000000003zzzs000000000000000zzzy000000000000000DzzzU000000000000003zzzs000000000000000zzzy000000000000000Dzzzk000000000000003zzzw000000000000000zzzz000000000000000Dzzzk000000000000007zzzw000000000000001zzzz000000000000000Tzzzk00000000000000Dzzzy000000000000003zzzzU00000000000000zzzzs00000000000000Dzzzz000000000000007zzzzk00000000000001zzzzy00000000000000TzzzzU0000000000000Dzzzzs00000000000007zzzzz00000000000001zzzzzs0000000000000Tzzzzy0000000000000Dzzzzzk0000000000007zzzzzw0000000000003zzzzzzU000000000000zzzzzzw000000000000Tzzzzzz000000000000Dzzzzzzs000000000003zzzzzzz000000000000zzzzzzzs00000000000Tzzzzzzz00000000000Dzzzzzzzs00000000007zzzzzzzz00000000003zzzzzzzzs0000000001zzzzzzzzzU000000000Tzzzzzzzzw000000000DzzzzzzzzzU000000007zzzzzzzzzz000000003zzzzzzzzzzs00000001zzzzzzzzzzzU0000001zzzzzzzzzzzy0000000zzzzzzzzzzzzs000000Tzzzzzzzzzzzzk00000Dzzzzzzzzzzzzzw0000Dzzzzzzzzzzzzzzzw007zzzzzzzzzzzzzzzzU07zzzzzzzzzzzzzzzzk07zzzzzzzzzzzzzzzzw03zzzzzzzzzzzzzzzzz07zzzzzzzzzzzzzzzzzU3zzzzzzzzzzzzzzzzzk7zzzzzzzzzzzzzzzzzsDzzzzzzzzzzzzzzzzzzDzzzzzzzzy", 1)
FindText().PicLib("|<WIFI的图标>*200$38.zzzzzzzzzzzzzzy01zzzw003zzs000Dzw0000zw00007y00Q00z03zy03k3s3s1y3k03Uzlk00ATzk001zzs000Dzz0003zzs7y1zzz7Vszzzz07TzzzU0Tzzzs07zzzz03zzzzs1zzzzz0zzzzzsTzzzzzDzzzzzzzzzzzzzzzU", 1)
FindText().PicLib("|<对话框·对话>*220$58.zzzzzk0003zzzzy0000Dzzzzs0000zzzzzk0003zzzzzU000DzzzzzkC00zzzzzz0s03zzzzzzzU0Dzzzzzzs00zzzzzzz003zzzzzzw00Dzzzzzz000zzzzzzs003zzzzzy000Dzzwzz0000zzznzw0003zzy000000Dzz0000000zzs0000003zy0000000DzU0000000zU00000003s0000000000000000000000000002", 1)
FindText().PicLib("|<对话框·想法>*150$84.000000000001zz000000000003zz000000000007zz00000000000Dzz00000000000zzz00000000003zzzzs00000Dzzzzzzzs00000Dzzzzzzzs00000Dzzzzzzzs00000Dzzzzzzzs00000Dzzzzzzzw00000Dzzzzzzzw00000Tzzzzzzzw00000Tzzzzzzzy00000Tzzzzzzzy00000zzzzzzzzz00000zzzzzzzzzU0001zzzzzzzzzk0003zzzzzzzzzs0007zzzzzzzzzw000Dzzzzzzzzzy000zzzzzzzzzzzU03zzzzzzzzzzzy0TzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzkDzzzzzzzzzzzy01zzzzzzzzzzzw00Tzzzzzzzzzzs00Tzzzzzzzzzzk00DzzzzzzzzzzU007zzzzzzzzzzU007zzzzzzzzzzU007zzzzzzzzzz0003zzzzzzzzzz0003zzzzzzzzzz0003zzzzzzzzzz0003zzzzzzzzzz0003zzzzzzzzzzU007zzzzzzzzzzU007zzzzzzzzzzU007zzzzzzzzzzk00Dzzzzzzzzzzk00Dzzzzzzzzzzs00Tzzzzzzzzzzy00zzzzzzzzzzzz03zzzzzzzzzzzzsTzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU", 1)
;tag 快速爆裂模式
FindText().PicLib("|<爆裂·A>*200$24.zzzzzzzzzs7zzs3zzk3zzk3zzk1zzk1zzVVzzVUzzVkzz1kzz3kTz3kTy3sTy00Ty00Dw00Dw00Dw007wDw7sDw7sDy3sTy3kTy3zzzzzzzzU", 1)
FindText().PicLib("|<爆裂·S>*200$21.zzzzzzzz0DzU0Ds00z007k00y3w7kTky3y7kTzy0Tzk07z00Dw00zs07zy0Tzy3zzkS3y3kTkS003s00T007s00zk0TzzzzzzzU", 1)
;tag 推图模式
FindText().PicLib("|<推图·放大镜>*200$51.zzzy03zzzzzy003zzzzz0007zzzzk000Dzzzw0000zzzy0Dz01zzzU7zz07zzs3zzy0Tzz0zzzw1zzkDzzzkDzw3zzzz0zzUzz3zw7zsDzsTzUTz1zz3zy3zkTzsTzsDy3zz3zz1zkzzsTzsDw7zz3zzVzUzzsTzw7w7zz3zzUzUz0003w7wDs000TUzVz0003w7w7s000TUzUzzkTzw7w7zz3zzUzUzzsTzwDy7zz3zz1zkTzsTzsDy3zz3zz1zsDzsTzkTz1zz3zw3zw7zsTzUzzUTzzzs7zy1zzzy1zzs7zzzUTzz0Tzzs3zzk0zzw0zzw01zy0Dzz000s07zzk60001zzw1s000zzz0Tk00Tzzk7zs0Tzzw1zzzzzzz0Tzzzzzzk7zzzzzzw1zzzzzzz0Tzzzzzzs7zzzzzzzVzzzzzzzyTzzzzzzzU", 1)
FindText().PicLib("|<推图·缩小镜>*200$51.zzzzk7zzzzzzU03zzzzzU007zzzzk000Dzzzw0000zzzz07zU1zzzk3zzU7zzw1zzz0Tzz0zzzw3zzkDzzzkDzy3zzzz0zzUzzzzw7zs7zzzzkTz1zzzzy3zsDzzzzsDy3zzzzz1zkTzzzzwDy7zzzzzUzkzzzzzw7w7zzzzzUzUz0003y7w7s000TkzUz0003y7w7s000TkzUzU003y7w7zzzzzUzkzzzzzw7y3zzzzzUzkTzzzzsDy3zzzzz1zsDzzzzsDz1zzzzy3zw7zzzzUTzUTzzzs7zy1zzzz1zzs7zzzUDzz0Tzzs3zzk0zzy0zzw01zz0Dzz001y03zzk60001zzw1w000Tzz0Tk00Dzzk7zk0Dzzw1zzzzzzz0Tzzzzzzk7zzzzzzw1zzzzzzz0Tzzzzzzs7zzzzzzzVzzzzzzzyTzzzzzzzU", 1)
FindText().PicLib("|<推图·红色的三角>DF8DAB-0.925$42.00000M000000M000007s000007s00000Ts00000Ts00001zs00001zs00007zy00007zy0000Tzy0000Tzy0001zzy0001zzy0001zzy000Tzzy000Tzzy001zzzzU01zzzzU07zzzzU07zzzzU0zzzzzU0zzzzzU3zzzzzU3zzzzzUDzzzzzsDzzzzzszzzzzzszzzzzzs0zzzzzs0zzzzzs000Tzzs000Tzzs00007zs00007zs000000T000000TU", 1)
FindText().PicLib("|<推图·地图的指针>*200$40.zzw0zzzzy00Tzzz000Dzzs000Tzy0000Tzk0000zy00001zk00003z00000Ds00000TU00000w000003k000006007s00M01zs01U0Dzk0600zz00007zy0000Tzs0001zzU0007zy0000Tzs0001zzU0803zw00U0Dzk0600Ty00M00TU01k000007000000w000003s00000TU00001z000007w00000zs00003zU0000Tz00001zw0000Dzs0001zzU0007zz0000zzy0003zzs000Tzzk003zzzU00Dzzy001zzzw00Dzzzs00zzzzU07zzzz00zzzzy07zzzzw0Tzzzzk3zzzzzUTzzzzz3zzzzzyTzzs", 1)
;tag 清除红点
FindText().PicLib("|<循环室·升级>*200$81.zzyTkzzzXzzzzzzz1w7zzwDzzzzzzU7Uzzz1w003zzU0Q7zzsDU00TzU07Uzzy3w003zU07w7zzkTU00TU03zUzzw7w007w01zw7zzUzw7Uzk0DzUzzsDzkw7y71zw7zz3lw7UzzwDzUzzkQ7UwDzzVzw7zw7Uw71zzwDzUzzUkDUsDzzVzw7zs01w703zwDzUzz00TUs0DzVzw7zs07w601U00000DU0zUk0M000000zsDw7y30000007y3zUTkM000000zkTs3y3U00000Dw6D0Dkzz1zw7zz01s1w7zsDzUzzk0707Uzz1zw7zw01s0sDzsDzUzz00y031zy1zw7zs0zkE0TzkTzUzzVzy303zy3zw7zwztUw0zzUTzUzzzw47U7zw7zw7zzw00y1zz0zzUzzw00DU7zkDzw7zy001s0Tw1zzUzzU0kC00y0Tzw7zw0y3U03U7zzUzzUTUE3U41zzw7zwTs60y1kTzzUzzzzUsDsD7zzw7zzzyDbznzzzzkzzzzzzzzw", 1)
FindText().PicLib("|<同步器·增强>*200$131.zzzzztzzbzzzzzzzzzzzzzz0Dzz1zy0zzzzzzzzzzzzzy0Tzk3zw0Dzzzzzzzzzzzzw0zz03zs0Dz0007zzs00Dzs1zy03zU0zy0007U0000Tzk3zy07z03zw000D00000zzU7zw07w0Dzs000S00001zz0Dzw0Ds0Tzk000w00003zy0Tzw1zU1zzU001s00007zw0zzk3y03zz0003k0000Dzs1zU000007y0007U0000Tzk3z000000Dw000D07zs0zzU7y000000Tzzw0S0Dzk1zz0Dw000000zzzs0w0TzU3zy0Ts000001zzzk1s0zz07zs0zk000003zzzU3k0000Ds001UDw1zU7zzz07U0000Tk0030Qs3b0Dzzy0D00000zU00600k700Tw000S00001z000A01UA00zk000w00003y000M210M01zU001s00007w000k620kE3z0003k0000Ds001UA011U7y0007ny03zzk0030Q0030Dw000Dzy0Dzzk00C0s00C0Ts000Tzw0Tzzz0Dw1k00Q0zk000zzs0zzzy0Ts3X0Rs1zU003k00001zw0zk360FU3z0DzzU00003zs1zU000007y0Tzz000007zk3z000000Dw0zzy00000DzU7y000000Ts1zzw00000Tz0Dw000000zU3zzs00000zy0Ts000001z07zzk00001zw0zvzzzzzzy0DzzU00003zs1zzzzzzzzw00070D07U7zk3zzzzzzzzs00060S0D0DzU7zk00003zk000Q0w0S0Tz0DzU00007zU000s1s0w0zy0Tz00000Dz0001k3k1k1zw0zy00000Tw0003U00003zs1lw00000zs0007000007zk03s00001zk000C00000DzU07k1zzU3zrzs0Q00000Tz00DU7zz07zzzs0s00000zw00T07zy0Dzzzk1k00001z000y00000TzzzU3U00003k000w00000zzzy077y03U7U001s00001zzzw0Dzy0D0T0007k00003zzzs0zzw0Q0z001zU00007zzzk1zzs0s0y00Dz00000DzzzU3zzk1k1w03zy0Dzw0Tzzz07zzU3U3w0Tzw0Tzs0zzzw0Dz00003s3zzs0zzk1zzzs0M000007kzzzk00003zzzU0k000007rzzzU00007zy003U00000Dzzzz00000Dzw007000000Dzzzy00000Tzs00C000000Tzzzw00000zzs00Q000000zzzzs00001zzk01s000000zzzzk1zzU3zzU07k000Tk1zzzzU7zz07zz00TU1zzzU7zzzz0Dzy0Dzy03zzzzzzVzzzzy0Tzy0TzzzzzzzzzzDs", 1)
FindText().PicLib("|<同步器·开始增强>*200$157.zzzzzzznzzrzzzzzrzDzzzzzzzzzzzzzzsTzkTzzVzVzUzzzzzzzw00000TwDzsDzzkzkTUTk07001w00000Dy7zs7zzsTsDkTs03U00y000007y3zw7zzwDy3kTw01k00T000003z1zy3zzy7z7sDy00s00DU00001zVzy3tzz3s000TzsQDy7zw7z1zzkzz1kTzVw000DzwC7z3zy3zUzz00T1w7zky0007zy73zVzz1zkTzU07Vy3zkT7sz3zz3U00zzUzsDzk07UzUz01WAQVzzVk00TzkTw7zs03UzkDU0laAEz00s00DzsDy3zz1VkTs7k0Ml68TU0Q007zw7z1zzVkk001s0AMWADk0Dz3zzy3zUzzksE000zkyCF67s07zVzzz1zkTzsQ8000DsT3Mr3wDzzUzzzUzsDzsC60047wDVwDVy7zU006000001wC31zz7y7k000y7zk003000000y71zzzjz3s000T3zs001U00000T3VzzzzzVw000DVzw63Uk00000D1kzzzzzkzzzzzk067VkTy3zkTzUES001zsTk00Ds033ksDz1zsDzs0D000zwDs007w01VsQ7zUzw7zy0DU00Ty7w003y00kMC3zkTy3zzU7k00Dz2S001zzkM001zkDz1zzs3sTy7zU73zkzzsA000zsDzUzzy0wDz3zU3VzsTzw6000Ts7zkTzz0C7zVz01k00Dzy3zUwzw3zsDzzU73zkz01s007zz1zsMTw3zw7zzU1VzsTU7w003zzUzwA7w1zy3zzUUkzwDkDy7zVzzkzy71w1zz1zzUMsTy7wzz3zkzzsTy00w1zzUzzUSw003zzzU00TzsA000A1zzkTzUTy001zzzk00Dy0600061zzsDzkTz000zzzs007z070003Vzzw7zwTzU00TzzwDy3zk3U0DUtzzy3zzTzkzwDzzy7zVzs3zzzsk", 1)
FindText().PicLib("|<妮姬·筛选红点>*150$28.zw0zzy00TzU00Tw0Q0zUTy1w3zw3kTzsC3zzkMTzzVVzzy0Dzzw0zzzk3zzzUDzzy0zzzk3zzz0Dzzw0zzzk1zzy27zzsMDzz1kTzsD0zz0y0TU7w000zs007zs01zzs0Ty", 1)
FindText().PicLib("|<妮姬·极限突破>*200$157.z3zzzzzzzzzzzzzzlzzzzzzz3zzVzzzzzzzzzzzzzzUzzzzzzzVzzkzzzzzk0C001zzzkDzzs01zkzzsS001zs03000zzzs7zzw00zsTzwD000zw01U00Tk00000y00TwDzy7U00Ty00k00Ds00000T00Dy3zz3k00Dz3ksTw7w00000Dy3y000T1zVw7zVsQDy3y000007z3z000803ky7zkwC7z1z3zzzy3zVzU00401sT3zsQD000zVyDwT1zUzk00600wD1zwC7U00Tky1w3UzkTswD300y7Vzy73k00DsQ1y0ETsTwS7Vy3z3kzz33s007zw1zU3zsDyD3kz0zVs0TVVwDy3zs1zw0zw7z7VszUTks0Dkky7z1zk3zzUDy03XkyTk7kQ07sQD3zUzs3zzs7y01ksDTk1sC03wD3U00Ty7w777z00k003s0w3z1y7Vk00DzDy31rz00M001s0C1zVz3ks007zzz1kTzUQA000w170TUzVwA003zzzUw7zUC60TUy0XUDkTky673zzzzkS7zk730DsS0HU3sTsT33Vwz000000w3VU7sD0Dk1sDwDVVsQDU00000S1kk1wD27s0QDy7UkwA3k00000D0sMEw713w847z30MS03s000007sQAAC7VVw603zVUQD03zzy0DzzwC6623kky3U3zkkC7k7zzz07zzy733U3wsT3k3zsMT3s7zzz01zzz3VVk1yQD1w1zwDzVy3zzz0kTzzU0Vw1zy7Vy0zy7zkz0zzz0w3zzk0Ey0zz3Uy07z3zsSEDzy0S0zzs08T0DzVkS01zVzs0A3zw0TU3zw00C03zkkS00Dkzw060Tk0Tw07y3sC00TsEA0k3sTw03UD00zz00z3y41k3w8C0w1wDy03s7k1zzs0zVy21w1y6DVzVy7zUTy7w3zzz0TzzX1z1z3btzxz3zlzzryDzzzwTzztnztk", 1)
FindText().PicLib("|<妮姬·核心强化>*200$177.zzzzzTzzzzzzzzzzzzzzzzzzzzzzzzw7zz3zzzzzzzzzzzzzzzzzzy7w7zzzUzzkDzzzzXzzzzzzzzzzzzzkDUzzzwDzy1zzzzs7zzzy00Q000zzw1w7zzzVzzsDzzzz0Tzzzk03U007zzUTUzzzwDzz0zzzzs1zzzy00Q000zzw3w7zzzVy0000zzzU3zzzk03U007zz0zUzzzwDk0007zzz0Dzzy00Q7zUzzk7w7zDz0y0000zzzw0zzzzy3Uzw7zy1zUzkQ00E0007zzzk3zzzzkQ7zUzzUDw7y1U020000zzzz0Dzzzy3Uzw7zs3zUzUA00TsDzzzzzy1zzzzkQ000zz0Tw7s1U03y1zzzzzzsTzzzy3U007zk3zUy0Q00TkTzzzzzzbzzy00Q000zw0Tw7U7z0zw7sTzzs7zzzzk03U007z03zUs1zs7z0z0zzz0zzyTy00Tz1zzk0Tw70Tz0zsDkDzbs7zz1zk03zsTzw03zUk7zk3w1k3zw70zzsDy00Tz1zzU0Tw01zy0C000TzUs7zz0zkzzU003w03zU0Tzk1k007zw70zzs7y7zs000Tk0Tw07zw07001zzUs7zzUzkzz0003z43zU1zzU0s00Tzs70zzw3y7zs000TtUTw0Tzw03Ts7jz0s7zzUTUzz1kC3zw3z07zz08Tw1sDsD0zzy1w00MD3sTzUTk1zzs1Xz0S0z1s7zzkDU031sT3zw3s0Tzy0AzU7UDsD0zzy1w00MD3kTzUS07zzk1zs1w3z1s7zzsDU031sC3zw300zzw4Dw0T0TkD0zzz0w00M000TzU007zzVVy0Dk7y1s7zzs7zy30003zw200zwsADk3w1zkT0zzDUzzkM000TzUMA7zVVVz1z0Ty3s7zsQ3zy30003zw3bUzw4QDwzU7zUT0zz1UzzkTz1szzUTw7zUnVzzs0zw3s7zsATzw7zsS7zw3zUzw6wDzw03zUT0zy3zzzUzz3UzzUTw7zUzVzy00Dz7s7zkTzzw7zsS3zw3zUzw7wDzU20zzz0zy3zzzUzz1kTzUTw7z0zVzU0s3zzw7zUTzzw7k001zw3zUTkDwDk0TUDzzU003zzz0k000DzUTw001zVs0Dy0zzw000zzw0C0000zw3zU00DwD03zs7zzU007zzU1k0007zUTy003zVw1zzVzzy001zzw0S00Tkzw3zs00zwDVzzyzzzy01zzzk7nzzy7zUTzk0Tzbzzzzzzzzzzzzzzzzzzzrzy7zzzzw", 1)
FindText().PicLib("|<妮姬·极限突破的红色红点>FB452A-0.85$18.1zU3zsDzwTzyTzzTzzzzzzzzTzzTzzTzyDzw3zs0z0U", 1)
FindText().PicLib("|<前哨基地·同步器>*200$35.s0zy0DU0zs0D00zU0800y00000s000S1kD00w3UT01s70y03kC1w07UQ3s0D0s7k0S1kDU0w3UT01zz0y03zy1zs7zw3zkDzs7zUTzkDz0zzUTy1zz0zw3zy1zs03w3zs03s7zs03kDzs03UTzzk70zzzkC1zzzUQ3zzz0s7zzy1kDzzw3UTzzs70zzzkC1zsDUQ3s0T0s7k0y1kDU1w3UT03s70y07kC1w0DUQ3s0T0s7k0S1k70003U0000DU0700zU0S03zU0z0DzU7k", 1)
FindText().PicLib("|<前哨基地·进入的图标>*200$77.zzzzzk03zzzzzzzzzk000Dzzzzzzzy00007zzzzzzzk00003zzzzzzw000001zzzzzzk000000zzzzzy0000000zzzzzs0000000Tzzzz00000000Tzzzw00000000Tzzzs00000000TzzzU00000000Tzzw000000000Tzzs000000000TzzU000000000Tzy0000000000Tzs0000000000zzU0000000000zz00000000000zy00000000001zs00000000E01zk00000001k03z000000007k03w00000000Tk07s00000001zk07k00000007zk0D00000000Tzk0C00000003zzk0Q00000007zzU0s000U000Tzy01k007k003zzs03000DU007zzU02000zU00Tzy004007zU01zzs00800DzU07zzU00E00zzU0Tzy000U03zzU1zzs001007zzUDzzU00200DzzUzzy000000DzzVzzs000800Dzzzzzk000E00Dzzzzy0000U00Dzzzzs0001000DzzzzU0002000Dzzzz00004000Dzzzs0000Q000DzzzU0000s000Dzzy00001k000Dzzw00003U000DzzU00007U000Dzz00000T0000Dzw00000y0000Dzk00003y0000Dz000007w0000Dw00000Tw0000Dk00000zs0000D000001zs0000A000007zk0000000000Tzk0000000000zzk0000000003zzk000000000DzzU000000000TzzU000000001zzzU000000007zzzU00000000TzzzU00000001zzzzU0000000Dzzzzk0000000zzzzzk0000003zzzzzk000000Dzzzzzs000001zzzzzzw00000Tzzzzzzy00001zzzzzzzzU000Tzzzzzzzzy00Tzzzzs", 1)
FindText().PicLib("|<自动选择的图标>*200$48.01000Dy003U00Dy003k00Dy007k00Dy00Ds00Dy00Ds00Dy00Tw00Dy00zy00Dy00zy00Dy01zz00Dy03zzU0Dy03zzk0Dy07zzk0Dy0Dzzs0Dy0Dzzs0Dy0Tzzw0Dy0zzzy0Dy0zzzz0Dy0Tzzy0Dy00Tw00Dy00Tw00Dy00Tw00Dy00Tw00Dy00Tw0Tzzy0Tw0zzzz0Tw0Tzzz0Tw0Dzzy0Tw0Dzzw0Tw07zzs0Tw07zzs0Tw03zzk0Tw01zzU0Tw00zzU0Tw00zz00Tw00Tz00Tw00Dy00Tw00Dw00Tw007w00Tw003s00Tw003k00Tw001U00Tw001U0U", 1)
FindText().PicLib("|<同步器·消耗道具使用的图标>*200$82.0Dzzzzzzzzzzk07zzzzzzzzzzzs0zzzzzzzzzzzzk7zzzzzzzzzzzzUzzzzzzzzzzzzz7y000zzzzzzzzyTU000zzzzzzzztw0001zzzzzzzzjk0007zzzzzzzzy0000Dzzzzzzzzs0000zzzzzzzzzU0003zzzzzzzzy0000Dzzzzzzzzs0000zzzzzzzzzU0003zzzzzzzzy0000Dzzzzzzzzs0000zzzzzzzzzU0003zzzzzzzzy0000Dzzzzzzzzs0000zzzzzzzzzU0003zzzzzzzzy0000Dzzzzzzzzs0000zzzzzzzzzU0003zzzzzzzzy0000Dzzzzzzzzs0000zzzzzzzzzU0003zzzzzzzzy0000Dzzzzzzzzw0001zzzzzzzzrk0007zzzzzzzyTU000zzzzzzzztzU00DzzzzzzzzXzzzzzzzzzzzzw7zzzzzzzzzzzzUDzzzzzzzzzzzw0TzzzzzzzzzzzU0Tzzzzzzzzzzs2", 1)
;endregion 识图素材
;region 创建GUI
;tag 基础配置
g_settingPages := Map("Default", [], "Login", [], "Shop", [], "SimulationRoom", [], "Arena", [], "Tower", [], "Interception", [], "Event", [], "Award", [], "Settings", [],)
title := "DoroHelper - " currentVersion
doroGui := Gui("+Resize", title)
doroGui.Tips := GuiCtrlTips(doroGui) ; 为 doroGui 实例化 GuiCtrlTips
doroGui.Tips.SetBkColor(0xFFFFFF)
doroGui.Tips.SetTxColor(0x000000)
doroGui.Tips.SetMargins(3, 3, 3, 3)
doroGui.MarginY := Round(doroGui.MarginY * 1)
doroGui.SetFont('s12', 'Microsoft YaHei UI')
;tag 框
doroGui.AddGroupBox("x10 y10 w250 h210 ", "更新")
BtnUpdate := doroGui.Add("Button", "xp+50 yp-1 w80 h25", "检查更新").OnEvent("Click", ClickOnCheckForUpdate)
BtnSponsor := doroGui.Add("Button", "x+10  w50 h25", "赞助").OnEvent("Click", MsgSponsor)
BtnHelp := doroGui.Add("Button", "x+10 w50 h25", "帮助").OnEvent("Click", ClickOnHelp)
doroGui.Add("Text", "x20 y40 R1 +0x0100", "版本：" currentVersion)
cbAutoCheckVersion := AddCheckboxSetting(doroGui, "AutoCheckUpdate", "自动检查", "x170 yp R1")
doroGui.Tips.SetTip(cbAutoCheckVersion, "启动时自动检查版本`n该功能启用时会略微降低启动速度`nahk版暂时改为下载最新版的压缩包")
doroGui.Add("Text", "x20 y65 R1 +0x0100 Section", "用户组：")
TextUserGroup := doroGui.Add("Text", "x+0.5  R1 +0x0100", g_numeric_settings["UserGroup"] . "❔️")
doroGui.Tips.SetTip(TextUserGroup, "用户组会在你正式运行Doro时检查，也可以勾选右边的自动检查在每次启动时检查`n你可以通过支持DoroHelper来获得更高级的用户组，支持方式请点击赞助按钮`n普通用户：可以使用大部分功能`r`n会员用户：可以提前使用某些功能")
try doroGui.Add("Text", "x20 y90 R1 +0x0100", "哈希值：" MyFileShortHash)
cbAutoCheckUserGroup := AddCheckboxSetting(doroGui, "AutoCheckUserGroup", "自动检查", "x170 ys R1")
doroGui.Tips.SetTip(cbAutoCheckUserGroup, "启动时自动检查用户组`n该功能启用时会略微降低启动速度`n如果你不是会员，开启这个功能对你来说没有意义")
cbAutoDeleteOldFile := AddCheckboxSetting(doroGui, "AutoDeleteOldFile", "自动删除", "yp+25")
doroGui.Tips.SetTip(cbAutoDeleteOldFile, "更新后自动删除旧版本")
;tag 更新渠道
doroGui.Add("Text", "Section x20 yp+30 R1 +0x0100", "更新渠道")
if g_numeric_settings["UpdateChannels"] = "正式版" {
    var := 1
}
else if g_numeric_settings["UpdateChannels"] = "测试版" {
    var := 2
}
else {
    var := 3
}
cbUpdateChannels := doroGui.Add("DropDownList", "x140 yp w100 Choose" var, ["正式版", "测试版", "AHK版"])
cbUpdateChannels.OnEvent("Change", (Ctrl, Info) => g_numeric_settings["UpdateChannels"] := Ctrl.Text)
PostMessage(0x153, -1, 30, cbUpdateChannels)  ; 设置选区字段的高度.
PostMessage(0x153, 0, 30, cbUpdateChannels)  ; 设置列表项的高度.
;tag 资源下载
doroGui.Add("Text", "xs R1 +0x0100", "资源下载源")
if g_numeric_settings["DownloadSource"] = "GitHub" {
    var := 1
}
else {
    var := 2
}
cbDownloadSource := doroGui.AddDropDownList(" x140 yp w100 Choose" var, ["GitHub", "Mirror酱"])
cbDownloadSource.OnEvent("Change", (Ctrl, Info) => ShowMirror(Ctrl, Info))
PostMessage(0x153, -1, 30, cbDownloadSource)
PostMessage(0x153, 0, 30, cbDownloadSource)
;tag Mirror酱
MirrorText := doroGui.Add("Text", "xs R1 +0x0100", "Mirror酱CDK")
MirrorInfo := doroGui.Add("Text", "x+2 yp-1 R1 +0x0100", "❔️")
doroGui.Tips.SetTip(MirrorInfo, "Mirror酱是一个第三方应用分发平台，让你能在普通网络环境下更新应用`n网址：https://mirrorchyan.com/zh/（付费使用）`nMirror酱和Doro会员并无任何联系")
MirrorEditControl := doroGui.Add("Edit", "x140 yp+1 w100 h20")
MirrorEditControl.Value := g_numeric_settings["MirrorCDK"]
MirrorEditControl.OnEvent("Change", (Ctrl, Info) => g_numeric_settings["MirrorCDK"] := Ctrl.Value)
; 初始化隐藏状态
if g_numeric_settings["DownloadSource"] = "Mirror酱" {
    ShowMirror(cbDownloadSource, "")
} else {
    MirrorText.Visible := false
    MirrorEditControl.Visible := false
    MirrorInfo.Visible := false
}
;tag 任务列表
global g_taskListCheckboxes := []
doroGui.AddGroupBox("x10 y230 w250 h315 ", "任务列表")
doroGui.SetFont('s12')
BtnSaveSettings := doroGui.Add("Button", "xp+100 yp w60 h30", "保存").OnEvent("Click", SaveSettings)
doroGui.SetFont('s9')
BtnCheckAll := doroGui.Add("Button", "xp+70 R1", "☑️").OnEvent("Click", CheckAllTasks)
doroGui.Tips.SetTip(BtnCheckAll, "勾选全部")
BtnUncheckAll := doroGui.Add("Button", "xp+40 R1", "⛔️").OnEvent("Click", UncheckAllTasks)
doroGui.Tips.SetTip(BtnUncheckAll, "取消勾选全部")
doroGui.SetFont('s14')
cbLogin := AddCheckboxSetting(doroGui, "Login", "登录/基础", "x20 yp+35 Section", true)
doroGui.Tips.SetTip(cbLogin, "是否先尝试登录游戏")
BtnLogin := doroGui.Add("Button", "x180 yp-2 w60 h30", "设置").OnEvent("Click", (Ctrl, Info) => ShowSetting("Login"))
cbShop := AddCheckboxSetting(doroGui, "Shop", "商店", "xs", true)
doroGui.Tips.SetTip(cbShop, "总开关：控制是否执行所有与商店相关的任务`r`n具体的购买项目请在右侧详细设置")
BtnShop := doroGui.Add("Button", "x180 yp-2 w60 h30", "设置").OnEvent("Click", (Ctrl, Info) => ShowSetting("Shop"))
cbSimulationRoom := AddCheckboxSetting(doroGui, "SimulationRoom", "模拟室", "xs", true)
doroGui.Tips.SetTip(cbSimulationRoom, "总开关：控制是否执行模拟室相关的任务")
BtnSimulationRoom := doroGui.Add("Button", "x180 yp-2 w60 h30", "设置").OnEvent("Click", (Ctrl, Info) => ShowSetting("SimulationRoom"))
cbArena := AddCheckboxSetting(doroGui, "Arena", "竞技场", "xs", true)
doroGui.Tips.SetTip(cbArena, "总开关：控制是否执行竞技场相关的任务，如领取奖励、挑战不同类型的竞技场`r`n请在右侧详细设置")
BtnArena := doroGui.Add("Button", "x180 yp-2 w60 h30", "设置").OnEvent("Click", (Ctrl, Info) => ShowSetting("Arena"))
cbTower := AddCheckboxSetting(doroGui, "Tower", "无限之塔", "xs", true)
doroGui.Tips.SetTip(cbTower, "总开关：控制是否执行无限之塔相关的任务，包括企业塔和通用塔的挑战")
BtnTower := doroGui.Add("Button", "x180 yp-2 w60 h30", "设置").OnEvent("Click", (Ctrl, Info) => ShowSetting("Tower"))
cbInterception := AddCheckboxSetting(doroGui, "Interception", "拦截战", "xs", true)
doroGui.Tips.SetTip(cbInterception, "总开关：控制是否执行拦截战任务`r`nBOSS选择、请在右侧详细设置")
BtnInterception := doroGui.Add("Button", "x180 yp-2 w60 h30", "设置").OnEvent("Click", (Ctrl, Info) => ShowSetting("Interception"))
cbAward := AddCheckboxSetting(doroGui, "Award", "奖励收取", "xs", true)
doroGui.Tips.SetTip(cbAward, "总开关：控制是否执行各类日常奖励的收取任务`r`n请在右侧详细设置")
BtnAward := doroGui.Add("Button", "x180 yp-2 w60 h30", "设置").OnEvent("Click", (Ctrl, Info) => ShowSetting("Award"))
cbEvent := AddCheckboxSetting(doroGui, "Event", "活动", "xs", true)
doroGui.Tips.SetTip(cbEvent, "总开关：控制是否执行大小活动的刷取`r`n请在右侧详细设置")
BtnEvent := doroGui.Add("Button", "x180 yp-2 w60 h30", "设置").OnEvent("Click", (Ctrl, Info) => ShowSetting("Event"))
;tag 启动设置
doroGui.SetFont('s12')
doroGui.AddGroupBox("x10 yp+40 w250 h100 ", "启动选项")
BtnReload := doroGui.Add("Button", "x110 yp-2 w60 h30", "重启").OnEvent("Click", SaveAndRestart)
doroGui.Tips.SetTip(BtnReload, "保存设置并重启 DoroHelper")
doroGui.SetFont('s14')
BtnArena := doroGui.Add("Button", "x180 yp-2 w60 h30", "设置").OnEvent("Click", (Ctrl, Info) => ShowSetting("Settings"))
doroGui.SetFont('s12')
BtnDoro := doroGui.Add("Button", "w80 xm+80 yp+50", "DORO!").OnEvent("Click", ClickOnDoro)
;tag 二级设置
doroGui.SetFont('s12')
doroGui.AddGroupBox("x280 y10 w300 h640 ", "任务设置")
;tag 二级默认Default
SetNotice := doroGui.Add("Text", "x290 y40 w280 +0x0100 Section", "====提示====`n请到左侧「任务列表」处对每个任务进行详细设置。鼠标悬停以查看对应详细信息。有问题先点左上角的帮助")
g_settingPages["Default"].Push(SetNotice)
SetSize := doroGui.Add("Text", "w280 +0x0100", "====游戏尺寸设置（窗口化）====`n推荐1080p分辨率的用户使用游戏内部的全屏，1080p以上分辨率的用户选择1080p，也可以适当放大")
g_settingPages["Default"].Push(SetSize)
Btn1080 := doroGui.Add("Button", "w60 h30 ", "1080p")
Btn1080.OnEvent("Click", (Ctrl, Info) => AdjustSize(1920, 1080))
g_settingPages["Default"].Push(Btn1080)
;tag 二级登录Login
SetLogin := doroGui.Add("Text", "x290 y40 R1 +0x0100 Section", "====登录选项[金Doro]====")
g_settingPages["Login"].Push(SetLogin)
StartupText := AddCheckboxSetting(doroGui, "AutoStartNikke", "使用脚本启动NIKKE", "R1 ")
g_settingPages["Login"].Push(StartupText)
StartupPathText := doroGui.Add("Text", "xs+20 R1 +0x0100", "启动器路径")
g_settingPages["Login"].Push(StartupPathText)
StartupPathEdit := doroGui.Add("Edit", "x+5 yp+1 w160 h20")
StartupPathEdit.Value := g_numeric_settings["StartupPath"]
StartupPathEdit.OnEvent("Change", (Ctrl, Info) => g_numeric_settings["StartupPath"] := Ctrl.Value)
g_settingPages["Login"].Push(StartupPathEdit)
StartupPathInfo := doroGui.Add("Text", "x+2 yp-1 R1 +0x0100", "❔️")
doroGui.Tips.SetTip(StartupPathInfo, "例如：C:\NIKKE\Launcher\nikke_launcher.exe")
g_settingPages["Login"].Push(StartupPathInfo)
SetTimedstart := AddCheckboxSetting(doroGui, "Timedstart", "定时启动", "xs R1")
doroGui.Tips.SetTip(SetTimedstart, "勾选后，脚本会在指定时间自动视为点击DORO！，让程序保持后台即可")
g_settingPages["Login"].Push(SetTimedstart)
StartupTimeText := doroGui.Add("Text", "xs+20 R1 +0x0100", "启动时间")
g_settingPages["Login"].Push(StartupTimeText)
StartupTimeEdit := doroGui.Add("Edit", "x+5 yp+1 w100 h20")
StartupTimeEdit.Value := g_numeric_settings["StartupTime"]
StartupTimeEdit.OnEvent("Change", (Ctrl, Info) => g_numeric_settings["StartupTime"] := Ctrl.Value)
g_settingPages["Login"].Push(StartupTimeEdit)
StartupTimeInfo := doroGui.Add("Text", "x+2 yp-1 R1 +0x0100", "❔️")
doroGui.Tips.SetTip(StartupTimeInfo, "填写格式为 HHmmss`n例如：080000 表示早上8点")
g_settingPages["Login"].Push(StartupTimeInfo)
cbLoopMode := AddCheckboxSetting(doroGui, "LoopMode", "自律模式", "xs+20 R1 +0x0100")
doroGui.Tips.SetTip(cbLoopMode, "勾选后，当 DoroHelper 完成所有已选任务后，NIKKE将自动退出，同时会自动重启Doro，以便再次定时启动")
g_settingPages["Login"].Push(cbLoopMode)
SetNormalTitle := doroGui.Add("Text", "xs R1", "===基础设置===")
g_settingPages["Login"].Push(SetNormalTitle)
CheckAutoText := AddCheckboxSetting(doroGui, "CheckAuto", "开启自动射击和爆裂", "R1 ")
g_settingPages["Login"].Push(CheckAutoText)
;tag 二级商店Shop
SetShop := doroGui.Add("Text", "x290 y40 R1 +0x0100 Section", "====商店选项====")
g_settingPages["Shop"].Push(SetShop)
SetShopCashTitle := doroGui.Add("Text", "R1", "===付费商店===")
g_settingPages["Shop"].Push(SetShopCashTitle)
SetShopCashFree := AddCheckboxSetting(doroGui, "ShopCashFree", "购买付费商店免费珠宝", "R1 ")
g_settingPages["Shop"].Push(SetShopCashFree)
SetShopCashFreePackage := AddCheckboxSetting(doroGui, "ShopCashFreePackage", "购买付费商店免费礼包", "R1 ")
g_settingPages["Shop"].Push(SetShopCashFreePackage)
SetShopNormalTitle := doroGui.Add("Text", "R1", "===普通商店===")
g_settingPages["Shop"].Push(SetShopNormalTitle)
SetShopNormalFree := AddCheckboxSetting(doroGui, "ShopNormalFree", "购买普通商店免费商品", "R1 ")
g_settingPages["Shop"].Push(SetShopNormalFree)
SetShopNormalDust := AddCheckboxSetting(doroGui, "ShopNormalDust", "用信用点买芯尘盒", "R1")
doroGui.Tips.SetTip(SetShopNormalDust, "勾选后，在普通商店中如果出现可用信用点购买的芯尘盒，则自动购买")
g_settingPages["Shop"].Push(SetShopNormalDust)
SetShopNormalPackage := AddCheckboxSetting(doroGui, "ShopNormalPackage", "购买简介个性化礼包", "R1 ")
doroGui.Tips.SetTip(SetShopNormalPackage, "勾选后，在普通商店中如果出现可用游戏内货币购买的简介个性化礼包，则自动购买")
g_settingPages["Shop"].Push(SetShopNormalPackage)
SetShopArenaTitle := doroGui.Add("Text", " R1 xs +0x0100", "===竞技场商店===")
doroGui.Tips.SetTip(SetShopArenaTitle, "设置与游戏内竞技场商店（使用竞技场代币购买）相关选项")
g_settingPages["Shop"].Push(SetShopArenaTitle)
; SetShopArena := AddCheckboxSetting(doroGui, "ShopArena", "总开关", "R1")
; g_settingPages["Shop"].Push(SetShopArena)
SetShopArenaBookFire := AddCheckboxSetting(doroGui, "ShopArenaBookFire", "燃烧", "R1")
doroGui.Tips.SetTip(SetShopArenaBookFire, "在竞技场商店中自动购买所有的燃烧代码手册")
g_settingPages["Shop"].Push(SetShopArenaBookFire)
SetShopArenaBookWater := AddCheckboxSetting(doroGui, "ShopArenaBookWater", "水冷", "R1 X+0.1")
doroGui.Tips.SetTip(SetShopArenaBookWater, "在竞技场商店中自动购买所有的水冷代码手册")
g_settingPages["Shop"].Push(SetShopArenaBookWater)
SetShopArenaBookWind := AddCheckboxSetting(doroGui, "ShopArenaBookWind", "风压", "R1 X+0.1")
doroGui.Tips.SetTip(SetShopArenaBookWind, "在竞技场商店中自动购买所有的风压代码手册")
g_settingPages["Shop"].Push(SetShopArenaBookWind)
SetShopArenaBookElec := AddCheckboxSetting(doroGui, "ShopArenaBookElec", "电击", "R1 X+0.1")
doroGui.Tips.SetTip(SetShopArenaBookElec, "在竞技场商店中自动购买所有的电击代码手册")
g_settingPages["Shop"].Push(SetShopArenaBookElec)
SetShopArenaBookIron := AddCheckboxSetting(doroGui, "ShopArenaBookIron", "铁甲", "R1 X+0.1")
doroGui.Tips.SetTip(SetShopArenaBookIron, "在竞技场商店中自动购买所有的铁甲代码手册")
g_settingPages["Shop"].Push(SetShopArenaBookIron)
SetShopArenaBookBox := AddCheckboxSetting(doroGui, "ShopArenaBookBox", "购买代码手册宝箱", "xs R1.2")
doroGui.Tips.SetTip(SetShopArenaBookBox, "在竞技场商店中自动购买代码手册宝箱，可随机开出各种属性的代码手册")
g_settingPages["Shop"].Push(SetShopArenaBookBox)
SetShopArenaPackage := AddCheckboxSetting(doroGui, "ShopArenaPackage", "购买简介个性化礼包", "R1.2")
doroGui.Tips.SetTip(SetShopArenaPackage, "在竞技场商店自动购买简介个性化礼包")
g_settingPages["Shop"].Push(SetShopArenaPackage)
SetShopArenaFurnace := AddCheckboxSetting(doroGui, "ShopArenaFurnace", "购买公司武器熔炉", "R1.2")
doroGui.Tips.SetTip(SetShopArenaFurnace, "在竞技场商店中自动购买公司武器熔炉，用于装备转化")
g_settingPages["Shop"].Push(SetShopArenaFurnace)
SetShopScrapTitle := doroGui.Add("Text", "R1 xs Section +0x0100", "===废铁商店===")
g_settingPages["Shop"].Push(SetShopScrapTitle)
; SetShopScrap := AddCheckboxSetting(doroGui, "ShopScrap", "总开关", "R1")
; g_settingPages["Shop"].Push(SetShopScrap)
SetShopScrapGem := AddCheckboxSetting(doroGui, "ShopScrapGem", "购买珠宝", "R1.2")
doroGui.Tips.SetTip(SetShopScrapGem, "在废铁商店中自动购买珠宝")
g_settingPages["Shop"].Push(SetShopScrapGem)
SetShopScrapVoucher := AddCheckboxSetting(doroGui, "ShopScrapVoucher", "购买全部好感券", "R1.2")
g_settingPages["Shop"].Push(SetShopScrapVoucher)
SetShopScrapResources := AddCheckboxSetting(doroGui, "ShopScrapResources", "购买全部养成资源", "R1.2")
g_settingPages["Shop"].Push(SetShopScrapResources)
SetScrapTeamworkBox := AddCheckboxSetting(doroGui, "ShopScrapTeamworkBox", "购买团队协作宝箱", "R1.2")
g_settingPages["Shop"].Push(SetScrapTeamworkBox)
SetShopScrapKitBox := AddCheckboxSetting(doroGui, "ShopScrapKitBox", "购买保养工具箱", "R1.2")
g_settingPages["Shop"].Push(SetShopScrapKitBox)
SetShopScrapArmsBox := AddCheckboxSetting(doroGui, "ShopScrapArms", "购买企业精选武装", "R1.2")
g_settingPages["Shop"].Push(SetShopScrapArmsBox)
;tag 二级模拟室SimulationRoom
SetSimulationTitle := doroGui.Add("Text", "x290 y40 R1 +0x0100 Section", "====模拟室选项====")
g_settingPages["SimulationRoom"].Push(SetSimulationTitle)
SetSimulationNormal := AddCheckboxSetting(doroGui, "SimulationNormal", "普通模拟室", "R1")
doroGui.Tips.SetTip(SetSimulationNormal, "勾选后，自动进行普通模拟室超频挑战`r`n此功能需要你在游戏内已经解锁了快速模拟功能才能正常使用，需要预勾选5C")
g_settingPages["SimulationRoom"].Push(SetSimulationNormal)
SetSimulationOverClock := AddCheckboxSetting(doroGui, "SimulationOverClock", "模拟室超频", "R1")
doroGui.Tips.SetTip(SetSimulationOverClock, "勾选后，自动进行模拟室超频挑战`r`n程序会默认尝试使用你上次进行超频挑战时选择的增益标签组合`r`n挑战难度必须是25，且需要勾选「禁止无关人员进入」和「好战型战术」")
g_settingPages["SimulationRoom"].Push(SetSimulationOverClock)
;tag 二级竞技场Arena
SetArenaTitle := doroGui.Add("Text", "x290 y40 R1 +0x0100 Section", "====竞技场选项====")
g_settingPages["Arena"].Push(SetArenaTitle)
SetAwardArena := AddCheckboxSetting(doroGui, "AwardArena", "竞技场收菜", "R1")
doroGui.Tips.SetTip(SetAwardArena, "领取竞技场每日奖励")
g_settingPages["Arena"].Push(SetAwardArena)
SetArenaRookie := AddCheckboxSetting(doroGui, "ArenaRookie", "新人竞技场", "R1")
doroGui.Tips.SetTip(SetArenaRookie, "使用五次每日免费挑战次数挑战第三位")
g_settingPages["Arena"].Push(SetArenaRookie)
SetArenaSpecial := AddCheckboxSetting(doroGui, "ArenaSpecial", "特殊竞技场", "R1")
doroGui.Tips.SetTip(SetArenaSpecial, "使用两次每日免费挑战次数挑战第三位")
g_settingPages["Arena"].Push(SetArenaSpecial)
SetArenaChampion := AddCheckboxSetting(doroGui, "ArenaChampion", "冠军竞技场", "R1")
doroGui.Tips.SetTip(SetArenaChampion, "在活动期间进行跟风竞猜")
g_settingPages["Arena"].Push(SetArenaChampion)
;tag 二级无限之塔Tower
SetTowerTitle := doroGui.Add("Text", "x290 y40 R1 +0x0100 Section", "====无限之塔选项====")
g_settingPages["Tower"].Push(SetTowerTitle)
SetTowerCompany := AddCheckboxSetting(doroGui, "TowerCompany", "爬企业塔", "R1")
doroGui.Tips.SetTip(SetTowerCompany, "勾选后，自动挑战当前可进入的所有企业塔，直到无法通关或每日次数用尽`r`n只要有一个是0/3就会判定为打过了从而跳过该任务")
g_settingPages["Tower"].Push(SetTowerCompany)
SetTowerUniversal := AddCheckboxSetting(doroGui, "TowerUniversal", "爬通用塔", "R1")
doroGui.Tips.SetTip(SetTowerUniversal, "勾选后，自动挑战通用无限之塔，直到无法通关")
g_settingPages["Tower"].Push(SetTowerUniversal)
;tag 二级拦截战Interception
SetInterceptionTitle := doroGui.Add("Text", "x290 y40 R1 +0x0100 Section", "====拦截战选项====")
g_settingPages["Interception"].Push(SetInterceptionTitle)
SetInterceptionNormal := AddCheckboxSetting(doroGui, "InterceptionNormal", "普通拦截[暂不支持]", "R1")
g_settingPages["Interception"].Push(SetInterceptionNormal)
SetInterceptionAnomaly := AddCheckboxSetting(doroGui, "InterceptionAnomaly", "异常拦截", "R1")
g_settingPages["Interception"].Push(SetInterceptionAnomaly)
DropDownListBoss := doroGui.Add("DropDownList", "Choose" g_numeric_settings["InterceptionBoss"], ["克拉肯(石)，编队1", "镜像容器(手)，编队2", "茵迪维利亚(衣)，编队3", "过激派(头)，编队4", "死神(脚)，编队5"])
doroGui.Tips.SetTip(DropDownListBoss, "在此选择异常拦截任务中优先挑战的BOSS`r`n请确保游戏内对应编号的队伍已经配置好针对该BOSS的阵容`r`n例如，选择克拉肯(石)，编队1，则程序会使用你的编队1去挑战克拉肯")
DropDownListBoss.OnEvent("Change", (Ctrl, Info) => g_numeric_settings["InterceptionBoss"] := Ctrl.Value)
g_settingPages["Interception"].Push(DropDownListBoss)
SetInterceptionNormalTitle := doroGui.Add("Text", "R1", "===基础选项===")
g_settingPages["Interception"].Push(SetInterceptionNormalTitle)
SetInterceptionScreenshot := AddCheckboxSetting(doroGui, "InterceptionScreenshot", "结果截图", "R1.2")
doroGui.Tips.SetTip(SetInterceptionScreenshot, "勾选后，在每次异常拦截战斗结束后，自动截取结算画面的图片，并保存在程序目录下的「截图」文件夹中")
g_settingPages["Interception"].Push(SetInterceptionScreenshot)
SetRedCircle := AddCheckboxSetting(doroGui, "InterceptionRedCircle", "自动打红圈", "R1.2")
doroGui.Tips.SetTip(SetRedCircle, "勾选后，在异常拦截中遇到克拉肯时会自动进行红圈攻击`n请务必在设置-战斗-全部中勾选「同步游标与准星」`n只对克拉肯有效")
g_settingPages["Interception"].Push(SetRedCircle)
SetInterceptionExit7 := AddCheckboxSetting(doroGui, "InterceptionExit7", "满7自动退出[金Doro]", "R1.2")
doroGui.Tips.SetTip(SetInterceptionExit7, "免责声明：如果遇到任何问题导致提前退出请自行承担损失")
g_settingPages["Interception"].Push(SetInterceptionExit7)
;tag 二级奖励Award
SetAwardTitle := doroGui.Add("Text", "x290 y40 R1 +0x0100 Section", "====奖励选项====")
g_settingPages["Award"].Push(SetAwardTitle)
SetAwardNormalTitle := doroGui.Add("Text", "R1", "===常规奖励===")
g_settingPages["Award"].Push(SetAwardNormalTitle)
SetAwardOutpost := AddCheckboxSetting(doroGui, "AwardOutpost", "领取前哨基地防御奖励+1次免费歼灭", "R1")
doroGui.Tips.SetTip(SetAwardOutpost, "自动领取前哨基地的离线挂机收益，并执行一次每日免费的快速歼灭以获取额外资源")
g_settingPages["Award"].Push(SetAwardOutpost)
SetAwardOutpostExpedition := AddCheckboxSetting(doroGui, "AwardOutpostExpedition", "领取并重新派遣委托", "R1 xs+15")
doroGui.Tips.SetTip(SetAwardOutpostExpedition, "自动领取已完成的派遣委托奖励，并根据当前可用妮姬重新派遣新的委托任务")
g_settingPages["Award"].Push(SetAwardOutpostExpedition)
SetAwardLoveTalking := AddCheckboxSetting(doroGui, "AwardLoveTalking", "咨询妮姬", "R1 xs Section")
doroGui.Tips.SetTip(SetAwardLoveTalking, "自动进行每日的妮姬咨询，以提升好感度`r`n你可以通过在游戏内将妮姬设置为收藏状态来调整咨询的优先顺序`r`n会循环直到次数耗尽")
g_settingPages["Award"].Push(SetAwardLoveTalking)
SetAwardAppreciation := AddCheckboxSetting(doroGui, "AwardAppreciation", "花絮鉴赏", "R1 xs+15")
doroGui.Tips.SetTip(SetAwardAppreciation, "自动观看并领取花絮鉴赏中当前可领取的奖励")
g_settingPages["Award"].Push(SetAwardAppreciation)
SetAwardFriendPoint := AddCheckboxSetting(doroGui, "AwardFriendPoint", "好友点数收取", "R1 xs")
doroGui.Tips.SetTip(SetAwardFriendPoint, "收取并回赠好友点数")
g_settingPages["Award"].Push(SetAwardFriendPoint)
SetAwardMail := AddCheckboxSetting(doroGui, "AwardMail", "邮箱收取", "R1.2")
doroGui.Tips.SetTip(SetAwardMail, "收取邮箱中所有奖励")
g_settingPages["Award"].Push(SetAwardMail)
SetAwardRanking := AddCheckboxSetting(doroGui, "AwardRanking", "方舟排名奖励", "R1.2")
doroGui.Tips.SetTip(SetAwardRanking, "自动领取方舟内各类排名活动（如无限之塔排名、竞技场排名等）的结算奖励")
g_settingPages["Award"].Push(SetAwardRanking)
SetAwardDaily := AddCheckboxSetting(doroGui, "AwardDaily", "任务收取", "R1.2")
doroGui.Tips.SetTip(SetAwardDaily, "收取每日任务、每周任务、主线任务以及成就等已完成任务的奖励")
g_settingPages["Award"].Push(SetAwardDaily)
SetAwardPass := AddCheckboxSetting(doroGui, "AwardPass", "通行证收取", "R1.2")
doroGui.Tips.SetTip(SetAwardPass, "收取当前通行证中所有可领取的等级奖励")
g_settingPages["Award"].Push(SetAwardPass)
SetAwardCooperate := AddCheckboxSetting(doroGui, "AwardCooperate", "协同作战", "R1.2")
doroGui.Tips.SetTip(SetAwardCooperate, "参与每日三次的普通难度协同作战`r`n也可参与大活动的协同作战")
g_settingPages["Award"].Push(SetAwardCooperate)
SetAwardSoloRaid := AddCheckboxSetting(doroGui, "AwardSoloRaid", "单人突击日常", "R1.2")
doroGui.Tips.SetTip(SetAwardSoloRaid, "参与单人突击，自动对最新的关卡进行战斗或快速战斗")
g_settingPages["Award"].Push(SetAwardSoloRaid)
SetLimitedAwardTitle := doroGui.Add("Text", "R1 Section +0x0100", "===限时奖励===")
doroGui.Tips.SetTip(SetLimitedAwardTitle, "设置在特定活动期间可领取的限时奖励或可参与的限时活动")
g_settingPages["Award"].Push(SetLimitedAwardTitle)
SetAwardFreeRecruit := AddCheckboxSetting(doroGui, "AwardFreeRecruit", "活动期间每日免费招募[失效]", "R1.2")
doroGui.Tips.SetTip(SetAwardFreeRecruit, "勾选后，如果在特定活动期间有每日免费招募机会，则自动进行募")
g_settingPages["Award"].Push(SetAwardFreeRecruit)
;tag 二级活动Event
SetEventUniversal := doroGui.Add("Text", "x290 y40 R1 +0x0100 Section", "====通用选项====")
g_settingPages["Event"].Push(SetEventUniversal)
SetAutoFill := AddCheckboxSetting(doroGui, "AutoFill", "剧情活动自动添加妮姬[金Doro]", "R1 ")
g_settingPages["Event"].Push(SetAutoFill)
SetEventTitle := doroGui.Add("Text", "R1 +0x0100", "====活动选项[银Doro]====")
g_settingPages["Event"].Push(SetEventTitle)
SetEventSmall := AddCheckboxSetting(doroGui, "EventSmall", "小活动总开关[未开放]", "R1")
g_settingPages["Event"].Push(SetEventSmall)
SetEventSmallChallenge := AddCheckboxSetting(doroGui, "EventSmallChallenge", "小活动挑战", "R1 xs+15")
g_settingPages["Event"].Push(SetEventSmallChallenge)
SetEventSmallStory := AddCheckboxSetting(doroGui, "EventSmallStory", "小活动剧情", "R1 xs+15")
g_settingPages["Event"].Push(SetEventSmallStory)
SetEventSmallMission := AddCheckboxSetting(doroGui, "EventSmallMission", "小活动任务", "R1 xs+15")
g_settingPages["Event"].Push(SetEventSmallMission)
SetEventLarge := AddCheckboxSetting(doroGui, "EventLarge", "大活动总开关[REBORN EVIL]", "R1 xs")
g_settingPages["Event"].Push(SetEventLarge)
SetEventLargeSign := AddCheckboxSetting(doroGui, "EventLargeSign", "大活动签到", "R1 xs+15")
g_settingPages["Event"].Push(SetEventLargeSign)
SetEventLargeChallenge := AddCheckboxSetting(doroGui, "EventLargeChallenge", "大活动挑战", "R1 xs+15")
g_settingPages["Event"].Push(SetEventLargeChallenge)
SetEventLargeStory := AddCheckboxSetting(doroGui, "EventLargeStory", "大活动剧情", "R1 xs+15")
g_settingPages["Event"].Push(SetEventLargeStory)
SetEventLargeCooperate := AddCheckboxSetting(doroGui, "EventLargeCooperate", "大活动协同作战", "R1 xs+15")
g_settingPages["Event"].Push(SetEventLargeCooperate)
SetEventLargeMinigame := AddCheckboxSetting(doroGui, "EventLargeMinigame", "大活动小游戏", "R1 xs+15")
doroGui.Tips.SetTip(SetEventLargeMinigame, "购买「扩充物品栏」后需要开启蓝色药丸")
g_settingPages["Event"].Push(SetEventLargeMinigame)
SetEventLargeDaily := AddCheckboxSetting(doroGui, "EventLargeDaily", "大活动奖励", "R1 xs+15")
g_settingPages["Event"].Push(SetEventLargeDaily)
SetEventSpecial := AddCheckboxSetting(doroGui, "EventSpecial", "特殊活动总开关[未开放]", "R1 xs")
g_settingPages["Event"].Push(SetEventSpecial)
SetEventSpecialSign := AddCheckboxSetting(doroGui, "EventSpecialSign", "特殊活动签到", "R1 xs+15")
g_settingPages["Event"].Push(SetEventSpecialSign)
SetEventSpecialChallenge := AddCheckboxSetting(doroGui, "EventSpecialChallenge", "特殊活动挑战", "R1 xs+15")
g_settingPages["Event"].Push(SetEventSpecialChallenge)
SetEventSpecialStory := AddCheckboxSetting(doroGui, "EventSpecialStory", "特殊活动剧情❔️", "R1 xs+15")
doroGui.Tips.SetTip(SetEventSpecialStory, "部分关卡可能有特殊关，此时需要手动完成任务")
g_settingPages["Event"].Push(SetEventSpecialStory)
SetEventSpecialCooperate := AddCheckboxSetting(doroGui, "EventSpecialCooperate", "特殊活动协同作战[暂时禁用]", "R1 xs+15")
g_settingPages["Event"].Push(SetEventSpecialCooperate)
SetEventSpecialMinigame := AddCheckboxSetting(doroGui, "EventSpecialMinigame", "特殊活动小游戏", "R1 xs+15")
doroGui.Tips.SetTip(SetEventSpecialMinigame, "默认不使用技能，开启蓝色药丸后使用技能")
g_settingPages["Event"].Push(SetEventSpecialMinigame)
SetEventSpecialDaily := AddCheckboxSetting(doroGui, "EventSpecialDaily", "特殊活动奖励", "R1 xs+15")
g_settingPages["Event"].Push(SetEventSpecialDaily)
;tag 二级设置Settings
SetSettingsTitle := doroGui.Add("Text", "x290 y40 R1 +0x0100 Section", "====设置选项====")
g_settingPages["Settings"].Push(SetSettingsTitle)
cbClearRed := AddCheckboxSetting(doroGui, "ClearRed", "任务完成后[金Doro]", "R1")
g_settingPages["Settings"].Push(cbClearRed)
cbClearRedRecycling := AddCheckboxSetting(doroGui, "ClearRedRecycling", "自动升级循环室", "R1 xs+15")
g_settingPages["Settings"].Push(cbClearRedRecycling)
cbClearRedSynchro := AddCheckboxSetting(doroGui, "ClearRedSynchro", "自动升级同步器", "R1 xs+15")
g_settingPages["Settings"].Push(cbClearRedSynchro)
cbClearRedSynchroForce := AddCheckboxSetting(doroGui, "ClearRedSynchroForce", "开箱子", "R1 x+5")
g_settingPages["Settings"].Push(cbClearRedSynchroForce)
cbClearRedLimit := AddCheckboxSetting(doroGui, "ClearRedLimit", "自动突破/强化妮姬", "R1 xs+15")
g_settingPages["Settings"].Push(cbClearRedLimit)
cbClearRedCube := AddCheckboxSetting(doroGui, "ClearRedCube", "自动升级魔方", "R1 xs+15")
g_settingPages["Settings"].Push(cbClearRedCube)
cbClearRedNotice := AddCheckboxSetting(doroGui, "ClearRedNotice", "清除公告红点", "R1 xs+15")
g_settingPages["Settings"].Push(cbClearRedNotice)
cbClearRedWallpaper := AddCheckboxSetting(doroGui, "ClearRedWallpaper", "清除壁纸红点", "R1 xs+15")
g_settingPages["Settings"].Push(cbClearRedWallpaper)
cbOpenBlablalink := AddCheckboxSetting(doroGui, "OpenBlablalink", "任务完成后打开Blablalink", "R1 xs")
doroGui.Tips.SetTip(cbOpenBlablalink, "勾选后，当 DoroHelper 完成所有已选任务后，会自动在你的默认浏览器中打开 Blablalink 网站")
g_settingPages["Settings"].Push(cbOpenBlablalink)
cbCloseAdvertisement := AddCheckboxSetting(doroGui, "CloseAdvertisement", "移除启动广告[铜Doro]", "R1")
g_settingPages["Settings"].Push(cbCloseAdvertisement)
cbCloseNoticeSponsor := AddCheckboxSetting(doroGui, "CloseNoticeSponsor", "移除赞助提示[铜Doro]", "R1")
g_settingPages["Settings"].Push(cbCloseNoticeSponsor)
cbCheckEvent := AddCheckboxSetting(doroGui, "CheckEvent", "活动结束提醒[铜Doro]", "R1")
doroGui.Tips.SetTip(cbCheckEvent, "勾选后，DoroHelper 会在活动结束前进行提醒`r`n注意：此功能需要会员用户组才能使用")
g_settingPages["Settings"].Push(cbCheckEvent)
cbDoroClosing := AddCheckboxSetting(doroGui, "DoroClosing", "任务完成后关闭DoroHelper", "R1")
g_settingPages["Settings"].Push(cbDoroClosing)
;tag 妙妙工具
doroGui.SetFont('s12')
doroGui.AddGroupBox("x600 y10 w400 h240 Section", "妙妙工具")
MiaoInfo := doroGui.Add("Text", "xp+70 yp-1 R1 +0x0100", "❔️")
doroGui.Tips.SetTip(MiaoInfo, "提供一些与日常任务流程无关的额外小功能")
doroGui.Add("Button", "xp xs+10 w80 h30", "仓库地址").OnEvent("Click", (*) => Run("https://github.com/1204244136/DoroHelper"))
doroGui.Add("Button", "x+10 w80 h30", "Blablalink").OnEvent("Click", (*) => Run("https://www.blablalink.com/"))
doroGui.Add("Button", "x+10 w80 h30", "CDK兑换").OnEvent("Click", (*) => Run("https://nikke.hayasa.link/"))
doroGui.Add("Button", "x+10 w100 h30", "加入反馈群").OnEvent("Click", (*) => Run("https://qm.qq.com/q/ZhvLeKMO2q"))
TextStoryModeLabel := doroGui.Add("Text", "xp R1 xs+10 +0x0100", "剧情模式")
doroGui.Tips.SetTip(TextStoryModeLabel, "尝试自动点击对话选项`r`n自动进行下一段剧情，自动启动auto")
AddCheckboxSetting(doroGui, "StoryModeAutoStar", "自动收藏", "x+5  R1")
AddCheckboxSetting(doroGui, "StoryModeAutoChoose", "自动抉择", "x+5 R1")
BtnStoryMode := doroGui.Add("Button", " x+5 yp-3 w60 h30", "←启动").OnEvent("Click", StoryMode)
TextTestModeLabel := doroGui.Add("Text", "xp R1 xs+10 +0x0100", "调试模式")
doroGui.Tips.SetTip(TextTestModeLabel, "根据输入的函数直接执行对应任务")
TestModeEditControl := doroGui.Add("Edit", "x+10 yp w145 h20")
doroGui.Tips.SetTip(TestModeEditControl, "输入要执行的任务的函数名")
TestModeEditControl.Value := g_numeric_settings["TestModeValue"]
BtnTestMode := doroGui.Add("Button", " x+5 yp-3 w60 h30", "←启动").OnEvent("Click", TestMode)
TextQuickBurst := doroGui.Add("Text", "xp R1 xs+10 +0x0100", "快速爆裂模式")
doroGui.Tips.SetTip(TextQuickBurst, "启动后，会自动使用爆裂，速度比自带的自动快。`n默认先A后S。适合凹分时解手")
BtnQuickBurst := doroGui.Add("Button", " x+5 yp-3 w60 h30", "←启动").OnEvent("Click", QuickBurst)
TextAutoAdvance := doroGui.Add("Text", "xp R1 xs+10 +0x0100", "推图模式beta[金Doro]")
doroGui.Tips.SetTip(TextAutoAdvance, "半自动推图。视野调到最大。在地图中靠近怪的地方启动，有时需要手动找怪和找机关")
BtnAutoAdvance := doroGui.Add("Button", " x+5 yp-3 w60 h30", "←启动").OnEvent("Click", AutoAdvance)
BtnBluePill := AddCheckboxSetting(doroGui, "BluePill", "蓝色药丸", "xp R1 xs+10 +0x0100")
BtnRedPill := AddCheckboxSetting(doroGui, "RedPill", "红色药丸", "x+10 R1 +0x0100")
doroGui.Add("Text", "x+10 +0x0100", "问就是没用")
;tag 日志
doroGui.AddGroupBox("x600 y260 w400 h390 Section", "日志")
doroGui.Add("Button", "xp+320 yp-5 w80 h30", "导出日志").OnEvent("Click", CopyLog)
doroGui.SetFont('s10')
LogBox := RichEdit(doroGui, "xs+10 ys+30 w380 h340 -HScroll +0x80 ReadOnly")
LogBox.WordWrap(true)
LogBox.Value := "日志开始……`r`n" ;初始内容
HideAllSettings()
ShowSetting("Default")
doroGui.Show("x" g_numeric_settings["doroGuiX"] " y" g_numeric_settings["doroGuiY"])
;endregion 创建GUI
;region 彩蛋
CheckSequence(key_char) {
    global key_history, konami_code
    ; 将当前按键对应的字符追加到历史记录中
    key_history .= key_char
    ; 为了防止历史记录字符串无限变长，我们只保留和目标代码一样长的末尾部分
    if (StrLen(key_history) > StrLen(konami_code)) {
        key_history := SubStr(key_history, -StrLen(konami_code) + 1)
    }
    ; 检查当前的历史记录是否与目标代码完全匹配
    if (key_history == konami_code) {
        AddLog("🎉 彩蛋触发！ 🎉！Konami Code 已输入！")
        TextUserGroup.Value := "炫彩Doro"
        key_history := ""    ; 重置历史记录，以便可以再次触发
    }
}
#HotIf WinActive(title)
~Up:: CheckSequence("U")
~Down:: CheckSequence("D")
~Left:: CheckSequence("L")
~Right:: CheckSequence("R")
~b:: CheckSequence("B")
~a:: CheckSequence("A")
#HotIf
;endregion 彩蛋
;region 前置任务
;tag 检查用户组
if g_settings["AutoCheckUserGroup"]
    CheckUserGroup
;tag 广告
; 如果满足以下任一条件，则显示广告：
; 1. 未勾选关闭广告 (无论用户是谁)
; 2. 是普通用户 (无论是否勾选了关闭广告，因为普通用户无法关闭)
if (!g_settings["CloseAdvertisement"] OR UserLevel < 1) {
    ; 额外判断，如果用户是普通用户且勾选了关闭广告，则弹窗提示
    if (g_settings["CloseAdvertisement"] and UserLevel < 1) {
        MsgBox("普通用户无法关闭广告，请点击赞助按钮升级会员组")
    }
    Advertisement
}
if !g_settings["CloseHelp"] {
    ClickOnHelp
}
;tag 删除旧文件
if g_settings["AutoDeleteOldFile"]
    DeleteOldFile
;tag 检查更新
if g_settings["AutoCheckUpdate"]
    CheckForUpdate(false)
;tag 检查脚本哈希
SplitPath A_ScriptFullPath, , , &scriptExtension
scriptExtension := StrLower(scriptExtension)
if (scriptExtension = "ahk") {
    AddLog("当前文件的GitSHA-1短哈希是：" MyFileShortHash)
}
;tag 定时启动
if g_settings["Timedstart"] {
    if UserLevel >= 3 {
        if !g_numeric_settings["StartupTime"] {
            MsgBox("请设置定时启动时间")
            Pause
        }
        StartDailyTimer()
        return
    } else {
        MsgBox("当前用户组不支持定时启动，请点击赞助按钮升级会员组")
        Pause
    }
}
;endregion 前置任务
;region 点击运行
ClickOnDoro(*) {
    ;清空文本
    LogBox.Value := ""
    ;写入设置
    WriteSettings()
    ;设置窗口标题匹配模式为完全匹配
    SetTitleMatchMode 3
    if g_settings["Login"] {
        if g_settings["AutoStartNikke"] {
            if UserLevel >= 3 {
                AutoStartNikke() ;登陆到主界面
            }
            else {
                MsgBox("当前用户组不支持使用脚本启动NIKKE，请点击赞助按钮升级会员组")
                Pause
            }
        }
    }
    Initialization
    if !g_settings["AutoCheckUserGroup"]
        CheckUserGroup
    if g_settings["Login"]
        Login() ;登陆到主界面
    if g_settings["Shop"] {
        if g_settings["ShopCashFree"]
            ShopCash()
        if g_settings["ShopNormal"]
            ShopNormal()
        if g_settings["ShopArena"]
            ShopArena()
        if g_settings["ShopScrap"]
            ShopScrap()
        BackToHall
    }
    if g_settings["SimulationRoom"] {
        if g_settings["SimulationNormal"] ;模拟室超频
            SimulationNormal()
        if g_settings["SimulationOverClock"] ;模拟室超频
            SimulationOverClock()
        GoBack
    }
    if g_settings["Arena"] {
        if g_settings["AwardArena"] ;竞技场收菜
            AwardArena()
        if g_settings["ArenaRookie"] or g_settings["ArenaSpecial"] or g_settings["ArenaChampion"] {
            EnterToArk()
            EnterToArena()
            if g_settings["ArenaRookie"] ;新人竞技场
                ArenaRookie()
            if g_settings["ArenaSpecial"] ;特殊竞技场
                ArenaSpecial()
            if g_settings["ArenaChampion"] ;冠军竞技场
                ArenaChampion()
            GoBack
        }
    }
    if g_settings["Tower"] {
        if g_settings["TowerCompany"]
            TowerCompany()
        if g_settings["TowerUniversal"]
            TowerUniversal()
        GoBack
    }
    if g_settings["Interception"] {
        if g_settings["InterceptionAnomaly"]
            InterceptionAnomaly()
    }
    BackToHall
    if g_settings["Award"] {
        if g_settings["AwardOutpost"] ;使用键名检查 Map
            AwardOutpost()
        if g_settings["AwardLoveTalking"]
            AwardLoveTalking()
        if g_settings["AwardFriendPoint"]
            AwardFriendPoint()
        if g_settings["AwardMail"]
            AwardMail()
        if g_settings["AwardRanking"] ;方舟排名奖励
            AwardRanking()
        if g_settings["AwardDaily"]
            AwardDaily()
        if g_settings["AwardPass"]
            AwardPass()
        if g_settings["AwardFreeRecruit"]
            AwardFreeRecruit()
        if g_settings["AwardCooperate"]
            AwardCooperate()
        if g_settings["AwardSoloRaid"]
            AwardSoloRaid()
    }
    if g_settings["Event"] {
        if UserLevel < 2 {
            MsgBox("当前用户组不支持活动，请点击赞助按钮升级会员组")
            Pause
        }
        if g_settings["EventSmall"]
            EventSmall()
        if g_settings["EventLarge"]
            EventLarge()
        if g_settings["EventSpecial"]
            EventSpecial()
        BackToHall
    }
    if g_settings["ClearRed"] {
        if UserLevel < 3 {
            MsgBox("当前用户组不支持清除红点，请点击赞助按钮升级会员组")
            Pause
        }
        ClearRed()
        BackToHall
    }
    if g_settings["LoopMode"] {
        WinClose winID
        SaveAndRestart
    }
    if g_settings["CheckEvent"] {
        if UserLevel < 1 {
            MsgBox("当前用户组不支持活动结束提醒，请点击赞助按钮升级会员组")
            Pause
        }
        CheckEvent()
    }
    CalculateAndShowSpan()
    if UserLevel < 1 or !g_settings["CloseNoticeSponsor"] {
        Result := MsgBox("Doro完成任务！" outputText "`n可以支持一下Doro吗", , "YesNo")
        if Result = "Yes"
            MsgSponsor
    }
    if UserLevel > 0 and UserLevel < 10 and g_settings["CloseNoticeSponsor"] {
        Result := MsgBox("Doro完成任务！" outputText "`n感谢你的支持～")
    }
    if UserLevel = 10 and g_settings["CloseNoticeSponsor"] {
        Result := MsgBox("Doro完成任务！" outputText "`n感谢你的辛苦付出～")
    }
    if g_settings["OpenBlablalink"]
        Run("https://www.blablalink.com/")
    if g_settings["DoroClosing"] {
        if InStr(currentVersion, "beta") {
            MsgBox ("测试版本禁用自动关闭！")
            Pause
        }
        ExitApp
    }
}
;endregion 点击运行
;region 启动辅助函数
;tag 脚本启动NIKKE
AutoStartNikke() {
    global NikkeX
    global NikkeY
    global NikkeW
    global NikkeH
    targetExe := "nikke.exe"
    if WinExist("ahk_exe " . targetExe) {
        AddLog("NIKKE已经在运行中，跳过启动")
        return
    }
    while g_numeric_settings["StartupPath"] != "" {
        SetTitleMatchMode 2 ; 使用部分匹配模式
        targetExe := "nikke_launcher.exe"
        gameExe := "nikke.exe" ; 游戏主进程
        ; 尝试找到标题包含"NIKKE"的主窗口
        mainWindowID := WinExist("NIKKE ahk_exe " . targetExe)
        if mainWindowID {
            AddLog("找到了NIKKE主窗口！ID: " mainWindowID)
            actualWinTitle := WinGetTitle(mainWindowID)
            AddLog("实际窗口标题是: " actualWinTitle)
            ; 激活该窗口
            WinActivate(mainWindowID)
            WinGetClientPos &NikkeX, &NikkeY, &NikkeW, &NikkeH, mainWindowID
            TrueRatio := NikkeH / stdScreenH
            ; 设置超时时间（例如2分钟）
            startTime := A_TickCount
            timeout := 120000
            ; 循环点击直到游戏启动或超时
            while (A_TickCount - startTime < timeout) {
                ; 检查游戏是否已经启动
                if ProcessExist(gameExe) {
                    AddLog("检测到游戏进程 " gameExe " 已启动，停止点击")
                    Sleep 10000 ; 等待游戏稳定
                    break 2 ; 跳出两层循环
                }
                ; 执行点击启动按钮
                AddLog("点击启动按钮...")
                UserClick(594, 1924, TrueRatio)
                ; 等待一段时间再次点击（例如3-5秒）
                Sleep 3000
            }
            ; 检查是否超时
            if (A_TickCount - startTime >= timeout) {
                AddLog("启动超时，未能检测到游戏进程", "Maroon")
            }
            break
        }
        else if WinExist("ahk_exe " . targetExe) {
            AddLog("启动器已运行但未找到主窗口，等待主窗口出现...")
            ; 等待主窗口出现
            startTime := A_TickCount
            timeout := 30000 ; 等待30秒
            while (A_TickCount - startTime < timeout) {
                if WinExist("NIKKE ahk_exe " . targetExe) {
                    AddLog("主窗口出现，重新检测")
                    break
                }
                Sleep 1000
            }
            if (A_TickCount - startTime >= timeout) {
                AddLog("等待主窗口超时，尝试重新启动启动器")
                Run(g_numeric_settings["StartupPath"])
                sleep 5000
            }
        }
        else {
            AddLog("正在启动NIKKE启动器，请稍等……")
            Run(g_numeric_settings["StartupPath"])
            sleep 5000
        }
    }
}
;tag 初始化
Initialization() {
    global NikkeX
    global NikkeY
    global NikkeW
    global NikkeH
    LogBox.SetText()
    targetExe := "nikke.exe"
    if WinExist("ahk_exe " . targetExe) {
        global winID := WinExist("ahk_exe " . targetExe) ;获取窗口ID
        actualWinTitle := WinGetTitle(winID)      ;获取实际窗口标题
        if WinGetCount("ahk_exe " . targetExe) > 1 {
            MsgBox("金Doro会员支持多开自动运行")
        }
        AddLog("找到了进程为 '" . targetExe . "' 的窗口！实际窗口标题是: " . actualWinTitle)
        if actualWinTitle = "胜利女神：新的希望" {
            MsgBox ("不支持国服，自动关闭！")
            MsgBox ("为了各自生活的便利，请不要在公开场合发布本软件国服相关的修改版本，谢谢配合！")
            ExitApp
        }
        ;激活该窗口
        WinActivate(winID)
    }
    else {
        ;没有找到该进程的窗口
        MsgBox("没有找到进程为 '" . targetExe . "' 的窗口，初始化失败！")
        Pause
    }
    nikkeID := winID
    WinGetClientPos &NikkeX, &NikkeY, &NikkeW, &NikkeH, nikkeID
    WinGetPos &NikkeXP, &NikkeYP, &NikkeWP, &NikkeHP, nikkeID
    global TrueRatio := NikkeH / stdScreenH ;确定nikke尺寸之于额定尺寸（4K）的比例
    GameRatio := Round(NikkeW / NikkeH, 3)
    AddLog("项目地址https://github.com/1204244136/DoroHelper")
    AddLog("当前的doro版本是" currentVersion)
    AddLog("屏幕宽度是" A_ScreenWidth)
    AddLog("屏幕高度是" A_ScreenHeight)
    AddLog("游戏画面比例是" GameRatio)
    AddLog("图片缩放系数是" Round(TrueRatio, 3))
    if TrueRatio < 0.5 {
        Result := MsgBox("检测到NIKKE窗口尺寸过小，建议按ctrl+3调整游戏画面并重启脚本，是否暂停程序？", , "YesNo")
        if Result = "Yes"
            Pause
    }
    if GameRatio = 1.779 or GameRatio = 1.778 or GameRatio = 1.777 {
        AddLog("游戏是标准的16：9尺寸")
    }
    else MsgBox("请在nikke设置中将画面比例调整为16:9")
    ; 尝试归类为2160p (4K) 及其变种
    if (A_ScreenWidth >= 3840 and A_ScreenHeight >= 2160) {
        if (A_ScreenWidth = 3840 and A_ScreenHeight = 2160) {
            AddLog("显示器是标准4K分辨率 (2160p)")
        } else if (A_ScreenWidth = 5120 and A_ScreenHeight = 2160) {
            AddLog("显示器是4K 加宽 (21:9 超宽屏)")
        } else if (A_ScreenWidth = 3840 and A_ScreenHeight = 2400) {
            AddLog("显示器是4K 增高 (16:10 宽屏)")
        } else {
            AddLog("显示器是4K 及其它变种分辨率")
        }
    }
    ; 尝试归类为1440p (2K) 及其变种
    else if (A_ScreenWidth >= 2560 and A_ScreenHeight >= 1440) {
        if (A_ScreenWidth = 2560 and A_ScreenHeight = 1440) {
            AddLog("显示器是标准2K分辨率 (1440p)")
        } else if (A_ScreenWidth = 3440 and A_ScreenHeight = 1440) {
            AddLog("显示器是2K 加宽 (21:9 超宽屏)")
        } else if (A_ScreenWidth = 5120 and A_ScreenHeight = 1440) {
            AddLog("显示器是2K 超宽 (32:9 超级带鱼屏)")
        } else if (A_ScreenWidth = 2560 and A_ScreenHeight = 1600) {
            AddLog("显示器是2K 增高 (16:10 宽屏)")
        } else {
            AddLog("显示器是2K 及其它变种分辨率")
        }
    }
    ; 尝试归类为1080p 及其变种
    else if (A_ScreenWidth >= 1920 and A_ScreenHeight >= 1080) {
        if (A_ScreenWidth = 1920 and A_ScreenHeight = 1080) {
            AddLog("显示器是标准1080p分辨率")
            if NikkeW < 1920 and NikkeH < 1080 {
                MsgBox("NIKKE尺寸过小，请尝试全屏运行。否则的话能正常运行就偷着乐吧，跑不了也别反馈")
            }
        } else if (A_ScreenWidth = 2560 and A_ScreenHeight = 1080) {
            AddLog("显示器是1080p 加宽 (21:9 超宽屏)")
        } else if (A_ScreenWidth = 3840 and A_ScreenHeight = 1080) {
            AddLog("显示器是1080p 超宽 (32:9 超级带鱼屏)")
        } else if (A_ScreenWidth = 1920 and A_ScreenHeight = 1200) {
            AddLog("显示器是1080p 增高 (16:10 宽屏)")
        } else {
            AddLog("显示器是1080p 及其它变种分辨率")
        }
    }
    else {
        AddLog("显示器不足1080p分辨率")
    }
}
;tag 定时启动
StartDailyTimer() {
    ; 1. 获取目标时间字符串，例如 "080000"
    target_time_string := g_numeric_settings["StartupTime"]
    ; 2. 创建一个表示今天目标时间的时间戳，例如 "20250806080000"
    today_target_time := A_YYYY . A_MM . A_DD . target_time_string
    local next_run_time ; 声明为局部变量
    ; 3. 比较当前时间 A_Now 和今天目标时间
    if (A_Now > today_target_time) {
        ; 如果当前时间已过，则将目标设置为明天的同一时间
        ; 首先，使用 DateAdd 获取 24 小时后的时间戳
        tomorrow_timestamp := DateAdd(A_Now, 1, "d")
        ; 然后，提取出明天的日期部分 (YYYYMMDD)
        tomorrow_date_part := SubStr(tomorrow_timestamp, 1, 8)
        ; 最后，将明天的日期和目标时间拼接起来
        next_run_time := tomorrow_date_part . target_time_string
    } else {
        ; 如果当前时间未到，则设置定时器到今天
        next_run_time := today_target_time
    }
    ; 4.使用 DateDiff() 精确计算距离下一次执行还有多少秒
    seconds_until_next_run := DateDiff(next_run_time, A_Now, "Seconds")
    ; 5. 将秒转换为毫秒
    milliseconds := seconds_until_next_run * 1000
    ; 计算小时、分钟和秒
    local hours_until := seconds_until_next_run // 3600
    local minutes_until := Mod(seconds_until_next_run, 3600) // 60
    local seconds_until := Mod(seconds_until_next_run, 60)
    ; 6. 格式化日志输出，方便阅读和调试
    AddLog("定时器已设置。下一次执行时间："
        . SubStr(next_run_time, 1, 4) . "-"
        . SubStr(next_run_time, 5, 2) . "-"
        . SubStr(next_run_time, 7, 2) . " "
        . SubStr(next_run_time, 9, 2) . ":"
        . SubStr(next_run_time, 11, 2) . ":"
        . SubStr(next_run_time, 13, 2)
        . " (在 " . hours_until . " 小时 " . minutes_until . " 分 " . seconds_until . " 秒后)")
    ; 7. 使用负值来设置一个只执行一次的定时器
    SetTimer(ClickOnDoro, -milliseconds)
}
;endregion 启动辅助函数
;region 更新辅助函数
;tag 统一检查更新
CheckForUpdate(isManualCheck) {
    ; 全局变量声明 - 确保这些在函数外部有定义
    global currentVersion, usr, repo, latestObj, g_settings, g_numeric_settings
    latestObj := Map( ; 初始化 latestObj Map
        "version", "",
        "change_notes", "无更新说明",
        "download_url", "",
        "source", "",
        "display_name", ""
    )
    local foundNewVersion := false
    local sourceName := ""
    local channelInfo := (g_numeric_settings["UpdateChannels"] == "测试版") ? "测试版" : "正式版"
    ; ==================== AHK文件更新检查=====================
    if (g_numeric_settings["UpdateChannels"] == "AHK版") {
        if (scriptExtension = "exe") {
            MsgBox "exe版本不可直接更新至ahk版本，请查看群公告下载完整的ahk版本文件"
            return
        }
        ; 获取远程文件的 Git SHA-1 哈希值
        ; --------------------------------------
        local path := "DoroHelper.ahk"
        local remoteSha := ""
        try {
            AddLog("正在从 GitHub API 获取最新版本文件哈希值……")
            ; 直接内联 WinHttp.WinHttpRequest 逻辑
            local whr := ComObject("WinHttp.WinHttpRequest.5.1")
            local apiUrl := "https://api.github.com/repos/" . usr . "/" . repo . "/contents/" . path
            whr.Open("GET", apiUrl, false) ; false for synchronous request
            whr.SetRequestHeader("User-Agent", "DoroHelper-AHK-Script") ; 设置User-Agent以满足GitHub API要求
            whr.Send()
            if (whr.Status != 200) {
                throw Error("API请求失败", -1, "状态码: " . whr.Status)
            }
            ; 手动解析 JSON 以提取 'sha' 字段
            local responseText := whr.ResponseText
            local shaMatch := ""
            if (RegExMatch(responseText, '"sha"\s*:\s*"(.*?)"', &shaMatch)) {
                remoteSha := shaMatch[1]
            } else {
                throw Error("JSON解析失败", -1, "未能从API响应中找到'sha'字段。")
            }
        } catch as e {
            AddLog("获取远程哈希失败，错误信息: " . e.Message)
            if (isManualCheck) {
                MsgBox "无法检查更新，请检查网络或稍后再试。", "错误", "IconX"
            }
            return
        }
        if (remoteSha = "") {
            AddLog("无法获取远程文件哈希值，更新中止。")
            if (isManualCheck) {
                MsgBox "无法获取远程文件信息，无法检查更新。", "错误", "IconX"
            }
            return
        }
        ; 获取本地文件的 Git SHA-1 哈希值
        ; --------------------------------------
        local localSha := ""
        try {
            localScriptPath := A_ScriptDir "\DoroHelper.ahk"
            if !FileExist(localScriptPath) {
                ; 如果文件不存在，可以认为需要下载
                localSha := ""
            } else {
                localSha := HashGitSHA1(localScriptPath) ; 调用你提供的 Git SHA-1 哈希函数
            }
        } catch as e {
            AddLog("计算本地文件哈希失败，错误信息: " e.Message)
            if (isManualCheck) {
                MsgBox "计算本地文件哈希时出错，无法检查更新。", "错误", "IconX"
            }
            return
        }
        AddLog("远程文件哈希值: " remoteSha)
        AddLog("本地文件哈希值: " localSha)
        ; 比较哈希值，决定是否需要下载
        ; --------------------------------------
        if (remoteSha = localSha) {
            ; 如果哈希值相同，说明已是最新版本，无需下载
            AddLog("文件哈希一致，当前已是最新版本。")
            if (isManualCheck) {
                MsgBox("当前已是最新版本，无需更新。")
            }
            return
        }
        ; --- 只有哈希值不一致时，才执行以下下载和替换代码 ---
        AddLog("发现文件哈希不匹配，准备下载新版本。")
        ; 定义目标URL和本地保存路径
        ; url 中也直接使用全局变量 usr 和 repo
        url := "https://raw.githubusercontent.com/" usr "/" repo "/main/" path
        currentScriptDir := A_ScriptDir
        NewFileName := "DoroHelper" A_Now ".ahk"
        localFilePath := currentScriptDir "\" NewFileName
        ; 下载文件到脚本所在目录
        try {
            AddLog("正在下载最新 AHK 版本，请稍等……")
            Download(url, localFilePath)
            AddLog("文件下载成功！已保存到当前目录: " localFilePath)
        } catch as e {
            MsgBox "下载失败，错误信息: " e.Message
            return
        }
        ; 下载后不再需要进行哈希校验，因为我们已经通过远程哈希确定了版本
        MsgBox("发现新版本！已下载至同目录下，软件即将退出")
        OldName := "DoroHelperOld" A_Now ".ahk"
        if !InStr(A_ScriptFullPath, OldName) {
            try {
                newPath := A_ScriptDir "\" OldName
                FileMove A_ScriptFullPath, newPath
                FileMove localFilePath, "DoroHelper.ahk"
                ExitApp
            } catch as e {
                MsgBox "重命名失败: " e.Message
            }
        } else {
            MsgBox "脚本已经在重命名后的状态下运行"
        }
        return
    }
    ; ==================== Mirror酱 更新检查 ====================
    if (g_numeric_settings["DownloadSource"] == "Mirror酱") {
        latestObj.source := "mirror"
        latestObj.display_name := "Mirror酱"
        sourceName := "Mirror酱"
        AddLog(sourceName . " 更新检查：开始 (" . channelInfo . " 渠道)……")
        if Trim(g_numeric_settings["MirrorCDK"]) = "" {
            if (isManualCheck) {
                MsgBox("Mirror酱 CDK 为空，无法检查更新", sourceName . "检查更新错误", "IconX")
            }
            AddLog(sourceName . " 更新检查：CDK为空")
            return
        }
        local apiUrl := "https://mirrorchyan.com/api/resources/DoroHelper/latest?"
        apiUrl .= "cdk=" . g_numeric_settings["MirrorCDK"]
        if (g_numeric_settings["UpdateChannels"] == "测试版") {
            apiUrl .= "&channel=beta"
        }
        local HttpRequest := ""
        local ResponseStatus := 0
        local ResponseBody := "" ; 用于存储原始字节流
        try {
            HttpRequest := ComObject("WinHttp.WinHttpRequest.5.1")
            HttpRequest.Open("GET", apiUrl, false)
            HttpRequest.SetRequestHeader("User-Agent", "DoroHelper-AHK-Script/" . currentVersion)
            HttpRequest.Send()
            ResponseStatus := HttpRequest.Status
            if (ResponseStatus = 200) { ; 仅当成功时获取 ResponseBody
                ResponseBody := HttpRequest.ResponseBody
            }
        } catch as e {
            if (isManualCheck) {
                MsgBox(sourceName . " API 请求失败: " . e.Message, sourceName . "检查更新错误", "IconX")
            }
            return
        }
        local ResponseTextForJson := "" ; 用于 JSON 解析的文本
        if (ResponseStatus = 200) {
            if (IsObject(ResponseBody) && (ComObjType(ResponseBody) & 0x2000)) { ; 检查是否为 SafeArray (VT_ARRAY)
                try {
                    local dataPtr := 0
                    local lBound := 0
                    local uBound := 0
                    DllCall("OleAut32\SafeArrayGetLBound", "Ptr", ComObjValue(ResponseBody), "UInt", 1, "Int64*", &lBound)
                    DllCall("OleAut32\SafeArrayGetUBound", "Ptr", ComObjValue(ResponseBody), "UInt", 1, "Int64*", &uBound)
                    local actualSize := uBound - lBound + 1
                    if (actualSize > 0) {
                        DllCall("OleAut32\SafeArrayAccessData", "Ptr", ComObjValue(ResponseBody), "Ptr*", &dataPtr)
                        ResponseTextForJson := StrGet(dataPtr, actualSize, "UTF-8")
                        DllCall("OleAut32\SafeArrayUnaccessData", "Ptr", ComObjValue(ResponseBody))
                        AddLog(sourceName . " DEBUG: ResponseBody (SafeArray) converted to UTF-8 string using StrGet.")
                    } else {
                        AddLog(sourceName . " 警告: SafeArray 大小为0或无效")
                        ResponseTextForJson := "" ; 确保 ResponseTextForJson 有定义
                    }
                } catch as e_sa {
                    AddLog(sourceName . " 错误: 处理 ResponseBody (SafeArray) 失败: " . e_sa.Message ". 类型: " . ComObjType(ResponseBody, "Name"))
                    ResponseTextForJson := HttpRequest.ResponseText ; 回退
                    AddLog(sourceName . " 警告: SafeArray 处理失败，回退到 HttpRequest.ResponseText，可能存在编码问题")
                }
            } else if (IsObject(ResponseBody)) {
                AddLog(sourceName . " 警告: ResponseBody 是对象但不是 SafeArray (类型: " . ComObjType(ResponseBody, "Name") . ")，尝试 ADODB.Stream")
                try {
                    local Stream := ComObject("ADODB.Stream")
                    Stream.Type := 1 ; adTypeBinary
                    Stream.Open()
                    Stream.Write(ResponseBody)
                    Stream.Position := 0
                    Stream.Type := 2 ; adTypeText
                    Stream.Charset := "utf-8"
                    ResponseTextForJson := Stream.ReadText()
                    Stream.Close()
                    AddLog(sourceName . " DEBUG: ResponseBody (non-SafeArray COM Object) converted to UTF-8 string using ADODB.Stream.")
                } catch as e_adodb {
                    AddLog(sourceName . " 错误: ADODB.Stream 处理 ResponseBody (non-SafeArray COM Object) 失败: " . e_adodb.Message)
                    ResponseTextForJson := HttpRequest.ResponseText ; 最终回退
                    AddLog(sourceName . " 警告: ADODB.Stream 失败，回退到 HttpRequest.ResponseText，可能存在编码问题")
                }
            } else {
                AddLog(sourceName . " 警告: ResponseBody 不是 COM 对象，或请求未成功。将直接使用 HttpRequest.ResponseText")
                ResponseTextForJson := HttpRequest.ResponseText
            }
            AddLog(sourceName . " API Response Status 200. Decoded ResponseTextForJson (first 500 chars): " . SubStr(ResponseTextForJson, 1, 500))
            try {
                local JsonData := Json.Load(&ResponseTextForJson)
                if (!IsObject(JsonData)) {
                    if (isManualCheck) MsgBox(sourceName . " API 响应格式错误", sourceName . "检查更新错误", "IconX")
                        AddLog(sourceName . " API 响应未能解析为JSON. ResponseText (first 200): " . SubStr(ResponseTextForJson, 1, 200))
                    return
                }
                local jsonDataCode := JsonData.Get("code", -1)
                local potentialData := JsonData.Get("data", unset)
                if (jsonDataCode != 0) {
                    local errorMsg := sourceName . " API 返回错误。 Code: " . jsonDataCode . "."
                    if (JsonData.Has("msg") && Trim(JsonData.msg) != "") {
                        errorMsg .= " 消息: " . JsonData.msg
                    } else {
                        errorMsg .= " (API未提供详细错误消息)"
                    }
                    if (isManualCheck) {
                        MsgBox(errorMsg, sourceName . "检查更新错误", "IconX")
                    }
                    AddLog(errorMsg)
                    return
                }
                if (!IsSet(potentialData) || !IsObject(potentialData)) {
                    local errorMsg := sourceName . " API 响应成功 (code 0)，但 'data' 字段缺失或非对象类型"
                    if (JsonData.Has("msg") && Trim(JsonData.msg) != "") {
                        errorMsg .= " API 消息: " . JsonData.msg
                    }
                    if (isManualCheck) {
                        MsgBox(errorMsg, sourceName . "检查更新错误", "IconX")
                    }
                    AddLog(errorMsg . " Type of 'data' retrieved: " . Type(potentialData))
                    return
                }
                local mirrorData := potentialData
                latestObj.version := mirrorData.Get("version_name", "")
                latestObj.change_notes := mirrorData.Get("release_note", "无更新说明")
                latestObj.download_url := mirrorData.Get("url", "")
                if latestObj.version = "" {
                    if (isManualCheck) {
                        MsgBox(sourceName . " API 响应中版本信息为空", sourceName . "检查更新错误", "IconX")
                    }
                    AddLog(sourceName . " 更新检查：API响应中版本信息为空")
                    return
                }
                AddLog(sourceName . " 更新检查：获取到版本 " . latestObj.version)
                if (CompareVersionsSemVer(latestObj.version, currentVersion) > 0) {
                    foundNewVersion := true
                    AddLog(sourceName . " 版本比较：发现新版本")
                } else {
                    AddLog(sourceName . " 版本比较：当前已是最新或更新")
                }
            } catch as e {
                local errorDetails := "错误类型: " . Type(e) . ", 消息: " . e.Message
                if e.HasProp("What") errorDetails .= "`n触发对象/操作: " . e.What
                    if e.HasProp("File") errorDetails .= "`n文件: " . e.File
                        if e.HasProp("Line") errorDetails .= "`n行号: " . e.Line
                            if (isManualCheck) MsgBox("处理 " . sourceName . " JSON 数据时发生内部错误: `n" . errorDetails, sourceName . "检查更新错误", "IconX")
                                AddLog(sourceName . " 更新检查：处理JSON时发生内部错误: " . errorDetails)
                AddLog(sourceName . " 相关的 ResponseTextForJson (前1000字符): " . SubStr(ResponseTextForJson, 1, 1000))
                return
            }
        } else { ; ResponseStatus != 200
            local errorResponseText := HttpRequest.ResponseText ; 尝试获取错误响应文本
            local responseTextPreview := SubStr(errorResponseText, 1, 300)
            if (isManualCheck) {
                MsgBox(sourceName . " API 请求失败！`n状态码: " . ResponseStatus . "`n响应预览:`n" . responseTextPreview, sourceName . " API 错误", "IconX")
            }
            AddLog(sourceName . " API 请求失败！状态码: " . ResponseStatus . ", 响应预览: " . responseTextPreview)
            return
        }
        ; ==================== Github 更新检查 ====================
    } else {
        latestObj.source := "github"
        latestObj.display_name := "Github"
        sourceName := "Github"
        AddLog(sourceName . " 更新检查：开始 (" . channelInfo . " 渠道)……")
        try {
            local allReleases := Github.historicReleases(usr, repo) ; 获取所有版本
            if !(allReleases is Array) || !allReleases.Length {
                if (isManualCheck) {
                    MsgBox("无法获取 Github 版本列表，请检查网络或仓库信息", sourceName . "检查更新错误", "IconX")
                }
                AddLog(sourceName . " 更新检查：无法获取版本列表")
                return
            }
            local targetRelease := ""
            if (g_numeric_settings["UpdateChannels"] == "测试版") {
                AddLog(sourceName . " 更新检查：测试版优先，已选定 Release")
                targetRelease := allReleases[1]
                if !(IsObject(targetRelease) && (targetRelease.HasProp("version") || targetRelease.HasProp("tag_name"))) {
                    local errMsg := sourceName . " 更新检查：获取到的最新预发布 Release 对象无效或缺少版本信息"
                    if (isManualCheck) MsgBox(errMsg, sourceName . "检查更新错误", "IconX")
                        AddLog(errMsg)
                    return
                }
            } else {
                AddLog(sourceName . " 更新检查：正式版优先，正在查找……")
                for release_item in allReleases {
                    if !(IsObject(release_item) && (release_item.HasProp("version") || release_item.HasProp("tag_name"))) {
                        AddLog(sourceName . " DEBUG: 跳过一个无效的或缺少版本信息的 Release 对象")
                        continue
                    }
                    local current_release_version := release_item.HasProp("version") ? release_item.version : release_item.tag_name
                    if !(InStr(current_release_version, "beta") || InStr(current_release_version, "alpha") || InStr(current_release_version, "rc")) {
                        targetRelease := release_item
                        AddLog(sourceName . " 更新检查：找到正式版 " . current_release_version)
                        break
                    }
                }
                if !IsObject(targetRelease) {
                    AddLog(sourceName . " 更新检查：未找到正式版，将使用最新版本进行比较")
                    targetRelease := allReleases[1]
                    if !(IsObject(targetRelease) && (targetRelease.HasProp("version") || targetRelease.HasProp("tag_name"))) {
                        local errMsg := sourceName . " 更新检查：回退到的最新 Release 对象也无效或缺少版本信息"
                        if (isManualCheck) MsgBox(errMsg, sourceName . "检查更新错误", "IconX")
                            AddLog(errMsg)
                        return
                    }
                }
            }
            if !IsObject(targetRelease) {
                local errMsg := sourceName . " 更新检查：最终未能确定有效的 targetRelease 对象"
                if (isManualCheck) MsgBox(errMsg, sourceName . "检查更新错误", "IconX")
                    AddLog(errMsg)
                return
            }
            ; 版本号
            if (targetRelease.HasProp("version")) {
                latestObj.version := targetRelease.version
            } else if (targetRelease.HasProp("tag_name")) {
                latestObj.version := targetRelease.tag_name
            } else {
                latestObj.version := ""
                AddLog(sourceName . " 警告: Release 对象缺少 'version' 或 'tag_name' 属性")
            }
            ; 更新内容
            if (targetRelease.HasProp("change_notes")) {
                latestObj.change_notes := targetRelease.change_notes
            } else if (targetRelease.HasProp("body")) {
                latestObj.change_notes := targetRelease.body
            } else {
                latestObj.change_notes := "无更新说明"
            }
            if Trim(latestObj.change_notes) = "" {
                latestObj.change_notes := "无更新说明"
            }
            ; 下载链接
            latestObj.download_url := "" ; 初始化
            if (targetRelease.HasProp("downloadURL") && Trim(targetRelease.downloadURL) != "") {
                latestObj.download_url := targetRelease.downloadURL
                AddLog(sourceName . " 找到下载链接 (from downloadURL): " . latestObj.download_url)
            }
            else if (targetRelease.HasProp("assets") && targetRelease.assets is Array && targetRelease.assets.Length > 0) {
                AddLog(sourceName . " DEBUG: (Fallback) 'downloadURL' not found. Checking 'assets'.")
                for asset in targetRelease.assets {
                    if IsObject(asset) && asset.HasProp("name") && asset.HasProp("browser_download_url") {
                        AddLog(sourceName . " DEBUG: Checking asset: " . asset.name)
                        if (InStr(asset.name, "DoroHelper") && InStr(asset.name, ".exe")) {
                            latestObj.download_url := asset.browser_download_url
                            AddLog(sourceName . " 找到 .exe asset 下载链接 (from assets): " . latestObj.download_url)
                            break
                        }
                    }
                }
                if (latestObj.download_url = "")
                    AddLog(sourceName . " 警告: 在 'assets' 中未精确匹配到 'DoroHelper*.exe' 或 'assets' 结构不符")
            }
            else if (targetRelease.HasProp("downloadURLs") && targetRelease.downloadURLs is Array && targetRelease.downloadURLs.Length > 0 && Trim(targetRelease.downloadURLs[1]) != "") {
                latestObj.download_url := targetRelease.downloadURLs[1]
                AddLog(sourceName . " 使用 downloadURLs[1] 作为下载链接 (Fallback): " . latestObj.download_url)
            }
            else if (targetRelease.HasProp("download_url") && Trim(targetRelease.download_url) != "") {
                latestObj.download_url := targetRelease.download_url
                AddLog(sourceName . " 使用顶层 download_url 属性作为下载链接 (Fallback): " . latestObj.download_url)
            }
            else {
                AddLog(sourceName . " 警告: Release 对象未找到任何有效的下载链接属性 (已尝试: downloadURL, assets, downloadURLs, download_url)")
            }
            if latestObj.version = "" {
                local errMsg := sourceName . " 更新检查：未能从选定的 Release 对象获取版本号"
                if (isManualCheck) MsgBox(errMsg, sourceName . "检查更新错误", "IconX")
                    AddLog(errMsg)
                return
            }
            if latestObj.download_url = "" {
                AddLog(sourceName . " 警告: 未能为版本 " . latestObj.version . " 找到有效的下载链接")
            }
            AddLog(sourceName . " 更新检查：获取到版本 " . latestObj.version . (latestObj.download_url ? "" : " (下载链接未找到)"))
            if (CompareVersionsSemVer(latestObj.version, currentVersion) > 0) {
                foundNewVersion := true
                AddLog(sourceName . " 版本比较：发现新版本")
            } else {
                AddLog(sourceName . " 版本比较：当前已是最新或更新")
            }
        } catch as githubError {
            if (isManualCheck) {
                MsgBox("Github 检查更新失败: `n" . githubError.Message . (githubError.HasProp("Extra") ? "`nExtra: " . githubError.Extra : ""), sourceName . "检查更新错误", "IconX")
            }
            AddLog(sourceName . " 检查更新失败: " . githubError.Message . (githubError.HasProp("Extra") ? ". Extra: " . githubError.Extra : ""))
            return
        }
    }
    ; ==================== 处理检查结果 ====================
    if foundNewVersion {
        AddLog(sourceName . " 更新检查：发现新版本 " . latestObj.version . "，准备提示用户")
        if (latestObj.download_url = "" && isManualCheck) {
            MsgBox("已检测到新版本 " . latestObj.version . "，但未能获取到下载链接。请检查 Github 库或手动下载", "更新提示", "IconW")
        }
        local MyGui := Gui("+Resize", "更新提示 (" . latestObj.display_name . ")")
        MyGui.SetFont("s10", "Microsoft YaHei UI")
        MyGui.Add("Text", "w300 xm ym", "发现 DoroHelper 新版本 (" . channelInfo . " - " . latestObj.display_name . "):")
        MyGui.Add("Text", "xp+10 yp+25 w300", "最新版本: " . latestObj.version)
        MyGui.Add("Text", "xp yp+20 w300", "当前版本: " . currentVersion)
        MyGui.Add("Text", "xp yp+25 w300", "更新内容:")
        local notes_for_edit := latestObj.change_notes
        notes_for_edit := StrReplace(notes_for_edit, "`r`n", "`n") ; 先统一为 \n
        notes_for_edit := StrReplace(notes_for_edit, "`r", "`n")   ; \r 也统一为 \n
        notes_for_edit := StrReplace(notes_for_edit, "`n", "`r`n") ; 再统一为 Edit 控件的 \r\n
        MyGui.Add("Edit", "w250 h200 ReadOnly VScroll Border", notes_for_edit)
        MyGui.Add("Button", "xm+20 w100 h30 yp+220", "立即下载").OnEvent("Click", DownloadUpdate)
        MyGui.Add("Button", "x+20 w100 h30", "稍后提醒").OnEvent("Click", (*) => MyGui.Destroy())
        MyGui.Show("w320 h400 Center")
    } else if latestObj.version != "" {
        AddLog(sourceName . " 更新检查：当前已是最新版本 " . currentVersion)
        if (isManualCheck) {
            MsgBox("当前通道为:" . channelInfo . "通道 - " . latestObj.display_name . "`n最新版本为:" . latestObj.version "`n当前版本为:" . currentVersion "`n当前已是最新版本", "检查更新", "IconI")
        }
    } else {
        AddLog((sourceName ? sourceName : "更新") . " 更新检查：未能获取到有效的版本信息或检查被中止")
        if (isManualCheck) {
            MsgBox("未能完成更新检查。请查看日志了解详情", "检查更新", "IconX")
        }
    }
}
;tag 统一更新下载
DownloadUpdate(*) {
    global latestObj
    if !IsObject(latestObj) || !latestObj.Has("source") || latestObj.source = "" || !latestObj.Has("version") || latestObj.version = "" {
        MsgBox("下载错误：更新信息不完整，无法开始下载", "下载错误", "IconX")
        AddLog("下载错误：latestObj 信息不完整。 Source: " . latestObj.Get("source", "N/A") . ", Version: " . latestObj.Get("version", "N/A"))
        return
    }
    downloadTempName := "DoroDownload.exe"
    finalName := "DoroHelper-" latestObj.version ".exe"
    downloadUrlToUse := latestObj.download_url
    if downloadUrlToUse = "" {
        MsgBox("错误：找不到有效的 " . latestObj.display_name . " 下载链接", "下载错误", "IconX")
        AddLog(latestObj.display_name . " 下载错误：下载链接为空")
        return
    }
    AddLog(latestObj.display_name . " 下载：开始下载 " . downloadUrlToUse . " 到 " . A_ScriptDir "\" finalName)
    local downloadStatusCode := 0 ; 用于存储下载结果
    try {
        if latestObj.source == "github" {
            ErrorLevel := 0
            Github.Download(downloadUrlToUse, A_ScriptDir "\" downloadTempName)
            downloadStatusCode := ErrorLevel
            if downloadStatusCode != 0 {
                throw Error("Github 下载失败 (ErrorLevel: " . downloadStatusCode . "). 检查 Github.Download 库的内部提示或网络")
            }
        } else if latestObj.source == "mirror" {
            ErrorLevel := 0
            Download downloadUrlToUse, A_ScriptDir "\" downloadTempName
            downloadStatusCode := ErrorLevel
            if downloadStatusCode != 0 {
                throw Error("Mirror酱下载失败 (错误代码: " . downloadStatusCode . ")")
            }
        } else {
            throw Error("未知的下载源: " . latestObj.source)
        }
        FileMove A_ScriptDir "\" downloadTempName, A_ScriptDir "\" finalName, 1
        MsgBox("新版本已通过 " . latestObj.display_name . " 下载至当前目录: `n" . A_ScriptDir "\" finalName, "下载完成")
        AddLog(latestObj.display_name . " 下载：成功下载并保存为 " . finalName)
        ExitApp
    } catch as downloadError {
        MsgBox(latestObj.display_name . " 下载失败: `n" . downloadError.Message, "下载错误", "IconX")
        AddLog(latestObj.display_name . " 下载失败: " . downloadError.Message)
        if FileExist(A_ScriptDir "\" downloadTempName) {
            try {
                FileDelete(A_ScriptDir "\" downloadTempName)
            } catch {
                ; 忽略删除临时文件失败
            }
        }
    }
}
;tag 点击检查更新
ClickOnCheckForUpdate(*) {
    AddLog("手动检查更新")
    CheckForUpdate(true)
}
;tag 版本比较
CompareVersionsSemVer(v1, v2) {
    _IsNumericString(str) => RegExMatch(str, "^\d+$")
    v1 := RegExReplace(v1, "^v", "")
    v2 := RegExReplace(v2, "^v", "")
    v1Parts := StrSplit(v1, "+", , 2)
    v2Parts := StrSplit(v2, "+", , 2)
    v1Base := v1Parts[1]
    v2Base := v2Parts[1]
    v1CoreParts := StrSplit(v1Base, "-", , 2)
    v2CoreParts := StrSplit(v2Base, "-", , 2)
    v1Core := v1CoreParts[1]
    v2Core := v2CoreParts[1]
    v1Pre := v1CoreParts.Length > 1 ? v1CoreParts[2] : ""
    v2Pre := v2CoreParts.Length > 1 ? v2CoreParts[2] : ""
    v1CoreNums := StrSplit(v1Core, ".")
    v2CoreNums := StrSplit(v2Core, ".")
    loop 3 {
        local seg1Str := A_Index <= v1CoreNums.Length ? Trim(v1CoreNums[A_Index]) : "0"
        local seg2Str := A_Index <= v2CoreNums.Length ? Trim(v2CoreNums[A_Index]) : "0"
        if !_IsNumericString(seg1Str) {
            seg1Str := "0"
        }
        if !_IsNumericString(seg2Str) {
            seg2Str := "0"
        }
        num1 := Integer(seg1Str)
        num2 := Integer(seg2Str)
        if (num1 > num2) {
            return 1
        }
        if (num1 < num2) {
            return -1
        }
    }
    hasV1Pre := v1Pre != ""
    hasV2Pre := v2Pre != ""
    if (hasV1Pre && !hasV2Pre) {
        return -1
    }
    if (!hasV1Pre && hasV2Pre) {
        return 1
    }
    if (!hasV1Pre && !hasV2Pre) {
        return 0
    }
    v1PreSegments := StrSplit(v1Pre, ".")
    v2PreSegments := StrSplit(v2Pre, ".")
    maxLen := Max(v1PreSegments.Length, v2PreSegments.Length)
    loop maxLen {
        if (A_Index > v1PreSegments.Length) {
            return -1
        }
        if (A_Index > v2PreSegments.Length) {
            return 1
        }
        seg1 := Trim(v1PreSegments[A_Index])
        seg2 := Trim(v2PreSegments[A_Index])
        isNum1 := _IsNumericString(seg1)
        isNum2 := _IsNumericString(seg2)
        if (isNum1 && isNum2) {
            numSeg1 := Integer(seg1)
            numSeg2 := Integer(seg2)
            if (numSeg1 > numSeg2)
                return 1
            if (numSeg1 < numSeg2)
                return -1
        } else if (!isNum1 && !isNum2) {
            ; 强制进行字符串比较
            compareResult := StrCompare(seg1, seg2)
            if (compareResult > 0)
                return 1
            if (compareResult < 0)
                return -1
        } else {
            if (isNum1)
                return -1
            if (isNum2)
                return 1
        }
    }
    return 0
}
;tag 删除旧程序
DeleteOldFile(*) {
    currentScriptPath := A_ScriptFullPath
    scriptDir := A_ScriptDir
    foundAnyDeletableFile := false ; 标志，只有当发现可删除的文件时才设置为true
    loop files, scriptDir . "\*.*" {
        currentFile := A_LoopFileFullPath
        fileName := A_LoopFileName
        ; 确保要删除的文件包含 "DoroHelper" (不区分大小写)
        ; 并且最重要的是：确保要删除的文件不是当前正在运行的脚本文件本身
        if (InStr(fileName, "DoroHelper", false) && currentFile != currentScriptPath) {
            ; 如果这是第一次发现可删除的文件，则输出初始日志
            if (!foundAnyDeletableFile) {
                AddLog("开始在目录 " . scriptDir . " 中查找并删除旧版本文件")
                AddLog("当前正在运行的脚本路径: " . currentScriptPath)
                foundAnyDeletableFile := true
            }
            try {
                FileDelete currentFile
                AddLog("成功删除旧版本程序: " . currentFile) ; 只有成功删除才输出此日志
            } catch as e {
                AddLog("删除文件失败: " . currentFile . " 错误: " . e.Message)
            }
        } else if (currentFile = currentScriptPath) {
            ; 即使是自身，如果之前没有发现可删除文件，也不输出初始日志
            if (foundAnyDeletableFile) { ; 只有在已经开始输出日志后，才记录跳过自身
                AddLog("跳过当前运行的程序（自身）: " . currentFile)
            }
        }
    }
    ; 只有当确实有文件被处理（删除或尝试删除），才输出结束日志
    if (foundAnyDeletableFile) {
        AddLog("旧版本文件删除操作完成")
    }
    ; 如果foundAnyDeletableFile仍然是false，则意味着没有找到任何符合删除条件的文件，
    ; 并且根据要求，此时不会输出任何日志。
}
;endregion 更新辅助函数
;region 身份辅助函数
;tag 下载指定URL的内容
DownloadUrlContent(url) {
    try {
        ; 1. 创建 WinHttpRequest COM 对象用于网络请求
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", url, true) ; 使用异步模式
        whr.Send()
        ; 2. 等待请求完成，超时时间为 10 秒
        whr.WaitForResponse(10)
        ; 3. 检查 HTTP 状态码是否为 200 (成功)
        if (whr.Status != 200) {
            AddLog("下载失败，HTTP状态码: " . whr.Status)
            return ""
        }
        ; 4. 获取原始的二进制响应体 (ResponseBody)，而不是 ResponseText
        responseBody := whr.ResponseBody
        ; 5. 使用 ADODB.Stream 对象来处理二进制流并正确解码
        stream := ComObject("ADODB.Stream")
        stream.Type := 1 ; 1 = adTypeBinary
        stream.Open()
        stream.Write(responseBody)
        stream.Position := 0
        stream.Type := 2 ; 2 = adTypeText
        stream.Charset := "utf-8" ; << 核心步骤：明确指定使用 UTF-8 解码
        ; 6. 读取解码后的文本内容并返回
        content := stream.ReadText()
        stream.Close()
        return content
    } catch as e {
        AddLog("下载发生错误: " . e.Message)
        return ""
    }
}
;tag 计算SHA256哈希值
/**
 * 计算一个字符串或一个文件的 SHA-256 哈希值。
 * 
 * @param {String} input 要进行哈希计算的源，可以是一个字符串，也可以是文件的完整路径。
 * @returns {String} 返回计算出的 64 位十六进制哈希字符串。
 * @throws {Error} 如果在任何加密 API 调用环节失败，则抛出异常。
 */
HashSHA256(input) {
    hProv := 0, hHash := 0
    ; 初始化 Windows Cryptography API
    if !DllCall("Advapi32\CryptAcquireContextW", "Ptr*", &hProv, "Ptr", 0, "Ptr", 0, "UInt", 24, "UInt", 0xF0000000) {
        throw Error("CryptAcquireContext 失败", -1, "无法获取加密服务提供者句柄")
    }
    ; 创建一个 SHA-256 哈希算法对象
    if !DllCall("Advapi32\CryptCreateHash", "Ptr", hProv, "UInt", 0x800C, "Ptr", 0, "UInt", 0, "Ptr*", &hHash) {
        DllCall("Advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
        throw Error("CryptCreateHash 失败", -1, "无法创建哈希对象")
    }
    ; 判断输入是文件还是字符串，并分别进行哈希数据更新
    if FileExist(input) {
        ; =================== 修改开始 ===================
        try {
            ; 1. 一次性读取整个文件的内容 (假设为 UTF-8 编码)
            fileContent := FileRead(input, "UTF-8")
            ; 2. 将所有行尾序列 (CRLF 和 CR) 统一替换为 LF
            normalizedContent := StrReplace(fileContent, "`r`n", "`n") ; 先替换 CRLF
            normalizedContent := StrReplace(normalizedContent, "`r", "`n")   ; 再替换独立的 CR
            ; 3. 像处理普通字符串一样处理转换后的内容
            strByteLen := StrPut(normalizedContent, "UTF-8") - 1
            if (strByteLen >= 0) {
                strBuf := Buffer(strByteLen)
                StrPut(normalizedContent, strBuf, "UTF-8")
                if !DllCall("Advapi32\CryptHashData", "Ptr", hHash, "Ptr", strBuf, "UInt", strByteLen, "UInt", 0) {
                    throw Error("CryptHashData (文件) 失败", -1, "更新文件哈希数据时出错")
                }
            }
        } catch as e {
            ; 如果在文件处理过程中发生错误，确保释放加密资源
            DllCall("Advapi32\CryptDestroyHash", "Ptr", hHash)
            DllCall("Advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
            throw e
        }
        ; =================== 修改结束 ===================
    } else {
        ; 输入文字符串的情况 (此部分保持不变)
        strByteLen := StrPut(input, "UTF-8") - 1
        if (strByteLen >= 0) {
            strBuf := Buffer(strByteLen)
            StrPut(input, strBuf, "UTF-8")
            if !DllCall("Advapi32\CryptHashData", "Ptr", hHash, "Ptr", strBuf, "UInt", strByteLen, "UInt", 0) {
                throw Error("CryptHashData (字符串) 失败", -1, "更新字符串哈希数据时出错")
            }
        }
    }
    ; 获取最终的哈希值
    hashSize := 32
    hashBuf := Buffer(hashSize)
    if !DllCall("Advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", hashBuf, "UInt*", &hashSize, "UInt", 0) {
        DllCall("Advapi32\CryptDestroyHash", "Ptr", hHash)
        DllCall("Advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
        throw Error("CryptGetHashParam 失败", -1, "无法获取最终的哈希值")
    }
    ; 将二进制哈希值格式化为十六进制字符串
    hexHash := ""
    loop hashSize {
        hexHash .= Format("{:02x}", NumGet(hashBuf, A_Index - 1, "UChar"))
    }
    ; 清理并释放资源
    DllCall("Advapi32\CryptDestroyHash", "Ptr", hHash)
    DllCall("Advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
    return hexHash
}
;tag 计算Git SHA-1哈希值 (已修正行尾序列问题)
/**
 * 计算一个文件的 Git SHA-1 哈希值（Blob类型）。
 * @param {String} filePath 要进行哈希计算的文件的完整路径。
 * @returns {String} 返回计算出的 40 位十六进制 Git SHA-1 哈希字符串。
 * @throws {Error} 如果在任何文件操作或加密 API 调用环节失败，则抛出异常。
 */
HashGitSHA1(filePath) {
    if !FileExist(filePath) {
        throw Error("文件不存在", -1, "指定的Git SHA-1哈希文件路径无效: " . filePath)
    }
    ; 1. 以二进制模式读取整个文件内容到 Buffer
    fileObj := FileOpen(filePath, "r")
    fileContentBuf := Buffer(fileObj.Length)
    fileObj.RawRead(fileContentBuf, fileContentBuf.Size)
    fileObj.Close()
    ; 2. 在 Buffer 中处理换行符：将所有CRLF (`r`n) 和 CR (`r`) 替换为 LF (`n`)
    normalizedContentBuf := Buffer(fileContentBuf.Size)
    newSize := 0
    i := 0
    while i < fileContentBuf.Size {
        byte := NumGet(fileContentBuf, i, "UChar")
        if byte = 13 { ; 是一个 CR (`r`)
            NumPut("UChar", 10, normalizedContentBuf, newSize) ; 写入一个 LF (`n`)
            newSize += 1
            ; 如果 CR 后面紧跟着一个 LF (即 CRLF)，则跳过那个 LF
            if (i + 1 < fileContentBuf.Size and NumGet(fileContentBuf, i + 1, "UChar") = 10) {
                i += 1
            }
        } else { ; 不是 CR
            NumPut("UChar", byte, normalizedContentBuf, newSize) ; 直接复制原字节
            newSize += 1
        }
        i += 1
    }
    normalizedContentBuf.Size := newSize ; 调整 Buffer 的实际大小
    ; 3. 构建Git Blob头部，格式为: "blob <size>\0"
    gitHeaderStr := "blob " . newSize . Chr(0)
    requiredSize := StrPut(gitHeaderStr, "UTF-8")
    gitHeaderBuf := Buffer(requiredSize)
    StrPut(gitHeaderStr, gitHeaderBuf, "UTF-8")
    gitHeaderLen := requiredSize - 1
    ;================================================================================
    ; Windows Cryptography API 调用部分
    ;================================================================================
    hProv := 0, hHash := 0
    ; 4. 初始化 Windows Cryptography API
    if !DllCall("Advapi32\CryptAcquireContextW", "Ptr*", &hProv, "Ptr", 0, "Ptr", 0, "UInt", 24, "UInt", 0xF0000000) {
        throw Error("CryptAcquireContext 失败", -1, "无法获取加密服务提供者句柄")
    }
    ; 5. 创建一个 SHA-1 哈希算法对象 (CALG_SHA1: 0x8004)
    if !DllCall("Advapi32\CryptCreateHash", "Ptr", hProv, "UInt", 0x8004, "Ptr", 0, "UInt", 0, "Ptr*", &hHash) {
        DllCall("Advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
        throw Error("CryptCreateHash 失败", -1, "无法创建哈希对象")
    }
    try {
        ; 6. 更新哈希数据：先传入头部，再传入文件内容
        if !DllCall("Advapi32\CryptHashData", "Ptr", hHash, "Ptr", gitHeaderBuf, "UInt", gitHeaderLen, "UInt", 0) {
            throw Error("CryptHashData (头部) 失败", -1, "更新头部哈希数据时出错")
        }
        if !DllCall("Advapi32\CryptHashData", "Ptr", hHash, "Ptr", normalizedContentBuf, "UInt", newSize, "UInt", 0) {
            throw Error("CryptHashData (内容) 失败", -1, "更新文件内容哈希数据时出错")
        }
    } catch as e {
        ; 如果在处理过程中发生错误，确保释放加密资源
        DllCall("Advapi32\CryptDestroyHash", "Ptr", hHash)
        DllCall("Advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
        throw e
    }
    ; 7. 获取最终的哈希值
    hashSize := 20
    hashBuf := Buffer(hashSize)
    if !DllCall("Advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", hashBuf, "UInt*", &hashSize, "UInt", 0) {
        DllCall("Advapi32\CryptDestroyHash", "Ptr", hHash)
        DllCall("Advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
        throw Error("CryptGetHashParam 失败", -1, "无法获取最终的哈希值")
    }
    ; 8. 将二进制哈希值格式化为十六进制字符串
    hexHash := ""
    loop hashSize {
        hexHash .= Format("{:02x}", NumGet(hashBuf, A_index - 1, "UChar"))
    }
    ; 9. 清理并释放资源
    DllCall("Advapi32\CryptDestroyHash", "Ptr", hHash)
    DllCall("Advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
    return hexHash
}
;tag 获取主板序列号的函数
GetMainBoardSerial() {
    wmi := ComObjGet("winmgmts:\\.\root\cimv2")
    query := "SELECT * FROM Win32_BaseBoard"
    for board in wmi.ExecQuery(query) {
        ; Mainboard serial is typically in 'SerialNumber'
        return board.SerialNumber
    }
    return "未找到序列号"
}
;tag 获取CPU序列号的函数
GetCpuSerial() {
    wmi := ComObjGet("winmgmts:\\.\root\cimv2")
    ; Win32_Processor class contains CPU information
    query := "SELECT * FROM Win32_Processor"
    for cpu in wmi.ExecQuery(query) {
        ; CPU serial is typically in 'ProcessorID' or 'SerialNumber'
        ; ProcessorID is more commonly available and unique for CPUs
        return cpu.ProcessorID
    }
    return "未找到序列号"
}
;tag 获取第一块硬盘序列号的函数
GetDiskSerial() {
    wmi := ComObjGet("winmgmts:\\.\root\cimv2")
    query := "SELECT * FROM Win32_DiskDrive"
    for disk in wmi.ExecQuery(query) {
        ; 返回找到的第一块硬盘的序列号
        return disk.SerialNumber
    }
    ; 如果没有找到任何硬盘，返回一个默认值
    return "未找到序列号"
}
;tag 获取所有硬盘序列号的函数（用于校验设备码）
GetDiskSerialsForValidation() {
    wmi := ComObjGet("winmgmts:\\.\root\cimv2")
    query := "SELECT * FROM Win32_DiskDrive"
    diskSerials := [] ; 创建一个空数组
    for disk in wmi.ExecQuery(query) {
        ; 将每个硬盘的序列号添加到数组中
        diskSerials.Push(disk.SerialNumber)
    }
    return diskSerials
}
;tag 确定用户组
CheckUserGroup() {
    global TextUserGroup, UserGroup
    ; 1. 初始化默认用户组
    try {
        TextUserGroup.Value := "普通用户"
        UserGroup := "普通用户"
        expiryDate := "19991231"
    }
    ; 2. 获取硬件信息
    try {
        mainBoardSerial := GetMainBoardSerial()
        cpuSerial := GetCpuSerial()
        ; 获取所有硬盘的序列号数组（注意：此函数需要单独实现）
        diskSerials := GetDiskSerialsForValidation()
        ; 检查是否成功获取硬盘序列号
        if (diskSerials.Length = 0) {
            AddLog("警告: 未检测到任何硬盘序列号。")
        }
    } catch as e {
        AddLog("获取硬件信息失败: " e.Message)
        return
    }
    ; 3. 从网络获取用户组数据
    jsonUrl := "https://gitee.com/con_sul/DoroHelper/raw/main/group/GroupArrayV3.json"
    jsonContent := DownloadUrlContent(jsonUrl)
    if (jsonContent = "") {
        AddLog("无法获取用户组信息，请检查网络后尝试重启程序")
        return
    }
    ; 4. 解析JSON数据
    try {
        groupData := Json.Load(&jsonContent)
        if !IsObject(groupData) {
            AddLog("解析 JSON 文件失败或格式不正确")
            return
        }
    } catch as e {
        AddLog("解析 JSON 文件时发生错误: " e.Message)
        return
    }
    ; 5. 校验用户组成员资格
    CurrentDate := A_YYYY A_MM A_DD
    isMember := false
    ; 为每一块硬盘生成一个哈希值
    for diskSerial in diskSerials {
        Hashed := HashSHA256(mainBoardSerial . cpuSerial . diskSerial)
        for _, memberInfo in groupData {
            ; 检查 memberInfo 是否为对象且包含 'hash' 键，并与计算的哈希值匹配
            if IsObject(memberInfo) && memberInfo.Has("hash") && (memberInfo["hash"] == Hashed) {
                ; 找到匹配项，继续校验有效期和等级
                if memberInfo.Has("expiry_date") && memberInfo.Has("tier") {
                    expiryDate := memberInfo["expiry_date"]
                    if (expiryDate >= CurrentDate) {
                        UserGroup := memberInfo["tier"]
                        TextUserGroup.Value := UserGroup
                        g_numeric_settings["UserGroup"] := UserGroup
                        AddLog("验证成功，当前用户组：" UserGroup)
                        AddLog("有效期至" expiryDate)
                        ; 设置用户级别和托盘图标的逻辑...
                        if (UserGroup == "管理员") {
                            global UserLevel := 10
                        }
                        if (UserGroup == "金Doro会员") {
                            try TraySetIcon("icon\GoldDoro.ico")
                            global UserLevel := 3
                        }
                        if (UserGroup == "银Doro会员") {
                            try TraySetIcon("icon\SilverDoro.ico")
                            global UserLevel := 2
                        }
                        if (UserGroup == "铜Doro会员") {
                            try TraySetIcon("icon\CopperDoro.ico")
                            global UserLevel := 1
                        }
                        isMember := true
                        break ; 找到有效的匹配项，退出内部循环 (groupData loop)
                    } else {
                        AddLog("会员已过期 (到期日: " expiryDate ")。已降级为普通用户")
                    }
                } else {
                    AddLog("警告: 在JSON中找到设备ID，但会员信息不完整 (缺少tier或expiry_date)")
                }
            }
            if (isMember) {
                break ; 找到有效的匹配项，退出内部循环 (groupData loop)
            }
        }
        if (isMember) {
            break ; 找到有效的匹配项，退出外部循环 (diskSerials loop)
        }
    }
    if (!isMember) {
        AddLog("当前设备非会员")
    }
    UserGroupInfo := { MembershipType: UserGroup, ExpirationTime: expiryDate }
    return UserGroupInfo
}
;endregion 身份辅助函数
;region GUI辅助函数
;tag 保存并重启
SaveAndRestart(*) {
    WriteSettings() ; 保存设置到文件
    AddLog("设置已保存，正在重启 DoroHelper……")
    Reload() ; 重启脚本
}
;tag 全选任务列表
CheckAllTasks(*) {
    for cb in g_taskListCheckboxes {
        cb.Value := 1 ; 视觉上勾选
        g_settings[cb.settingKey] := 1 ; 同步数据
    }
}
;tag 全不选任务列表
UncheckAllTasks(*) {
    for cb in g_taskListCheckboxes {
        cb.Value := 0 ; 视觉上取消勾选
        g_settings[cb.settingKey] := 0 ; 同步数据
    }
}
;tag 展示MirrorCDK输入框
ShowMirror(Ctrl, Info) {
    ; 正确的写法是获取控件的 .Value 属性（或 .Text 属性）
    g_numeric_settings["DownloadSource"] := cbDownloadSource.Text
    if Ctrl.Value = 2 {
        MirrorText.Visible := true
        MirrorEditControl.Visible := true
        MirrorInfo.Visible := true
    } else {
        MirrorText.Visible := false
        MirrorEditControl.Visible := false
        MirrorInfo.Visible := false
    }
}
;tag 隐藏所有二级设置
HideAllSettings() {
    global g_settingPages
    ; 遍历Map中的每一个页面（键值对）
    for pageName, controlsArray in g_settingPages {
        ; 遍历该页面的所有控件
        for control in controlsArray {
            control.Visible := false
        }
    }
}
;tag 展示二级设置页面
ShowSetting(pageName) {
    global g_settingPages
    ; 步骤1: 先隐藏所有设置页面的控件
    HideAllSettings()
    ; 步骤2: 再显示指定页面的控件
    if g_settingPages.Has(pageName) {
        targetControls := g_settingPages[pageName]
        for control in targetControls {
            control.Visible := true
        }
    } else {
        AddLog("错误：尝试显示的设置页面 '" . pageName . "' 未定义")
    }
}
;endregion GUI辅助函数
;region 消息辅助函数
;tag 活动结束提醒
CheckEvent(*) {
    MyFileShortHash := SubStr(A_Now, 1, 8)
    if MyFileShortHash = "20250923" {
        MsgBox "COINS IN RUSH活动将在今天结束，请尽快完成活动！记得捡垃圾、搬空商店！"
    }
    if MyFileShortHash = "20250922" {
        MsgBox "单人突击将在今天结束，请没凹的尽快凹分！"
    }
    if MyFileShortHash = "20250903" {
        MsgBox "小活动ABSOLUTE将在今天结束，请尽快搬空商店！"
    }
}
MsgSponsor(*) {
    global guiTier, guiDuration, guiSponsor, guiPriceText
    guiSponsor := Gui("+Resize", "赞助")
    guiSponsor.SetFont('s10', 'Microsoft YaHei UI')
    guiSponsor.Add("Text", "w400 Wrap", "现在 DoroHelper 的绝大部分维护和新功能的添加都是我在做，这耗费了我大量时间和精力，希望有条件的小伙伴们能支持一下")
    guiSponsor.Add("Text", "xm w400 Wrap", "赞助信息与当前设备绑定。需要注意的是，赞助并不构成实际上的商业行为，如果遇到不可抗力因素，本人有权随时停止维护，最终解释权归本人所有")
    LV := guiSponsor.Add("ListView", "w400 h200", ["　　　　　　　　　　", "普通用户", "铜 Doro", "银 Doro", "金 Doro"])
    LV.Add(, "每月（30天）价格", "免费", "6元", "18元", "30元")
    LV.Add(, "大部分功能", "✅️", "✅️", "✅️", "✅️")
    LV.Add(, "移除广告和赞助提示", "", "✅️", "✅️", "✅️")
    LV.Add(, "活动结束提醒", "", "✅️", "✅️", "✅️")
    LV.Add(, "轮换活动", "", "", "✅️", "✅️")
    LV.Add(, "路径和定时启动", "", "", "", "✅️")
    LV.Add(, "自动推图", "", "", "", "✅️")
    LV.Add(, "其他最新功能", "", "", "", "✅️")
    if (scriptExtension = "ahk") {
        picUrl1 := "img\weixin.png"
        picUrl2 := "img\alipay.png"
        guiSponsor.Add("Picture", "w200 h200", picUrl1)
        guiSponsor.Add("Picture", "yp w200 h200", picUrl2)
    }
    else {
        picUrl1 := "https://s1.imagehub.cc/images/2025/09/12/c3fd38a9b6ae2e677b4e2f411ebc49a8.jpg"
        picUrl2 := "https://s1.imagehub.cc/images/2025/09/12/f69df12697d7bb2a98ef61108e46e787.jpg"
        local tempFile1 := A_Temp . "\doro_sponsor1.jpg"
        local tempFile2 := A_Temp . "\doro_sponsor2.jpg"
        try {
            Download picUrl1, tempFile1
            guiSponsor.Add("Picture", "w200 h200", tempFile1)
            Download picUrl2, tempFile2
            guiSponsor.Add("Picture", "yp w200 h200", tempFile2)
        }
        catch {
            guiSponsor.Add("Text", "w400 h200 Center", "无法加载赞助图片，请检查网络连接。")
        }
    }
    guiSponsor.SetFont('s12', 'Microsoft YaHei UI')
    ; guiSponsor.Add("Text", "xm w400 Wrap cred", "为庆祝1.6版本，在9月4日游戏版本更新前包年免两月`n已包年的用户请凭付款截图联系续期三个月")
    guiSponsor.SetFont('s10', 'Microsoft YaHei UI')
    guiSponsor.Add("Text", "xm w280 Wrap", "赞助信息生成器")
    ; 添加 Choose1 确保默认选中
    guiTier := guiSponsor.Add("DropDownList", "Choose1 w120", ["铜Doro会员", "银Doro会员", "金Doro会员", "管理员"])
    guiDuration := guiSponsor.Add("DropDownList", "yp x150 Choose1 w120", ["1个月", "3个月", "6个月", "12个月", "36个月"])
    guiSponsor.Add("Text", "xm r1", "需要赞助：")
    guiPriceText := guiSponsor.Add("Text", "x+5 w60", "")
    guiSponsor.Add("Button", "yp x150 h30", "我已赞助，生成信息").OnEvent("Click", CalculateSponsorInfo)
    ; 确保回调函数正确绑定
    guiTier.OnEvent("Change", UpdateSponsorPrice)
    guiDuration.OnEvent("Change", UpdateSponsorPrice)
    ; 初始化价格显示
    UpdateSponsorPrice()
    guiSponsor.Show()
}
UpdateSponsorPrice(*) {
    ; 获取当前选中的值
    tierSelected := guiTier.Text
    durationSelected := guiDuration.Text
    ; 检查是否为空值
    if (tierSelected = "" or durationSelected = "") {
        guiPriceText.Text := "赞助金额：请选择选项"
        return
    }
    ; 定义价格映射
    priceMap := Map(
        "铜Doro会员", 6,
        "银Doro会员", 18,
        "金Doro会员", 30,
        "管理员", -1
    )
    ; 从 durationSelected 中提取月份数
    monthsText := StrReplace(durationSelected, "个月")
    if (monthsText = "" or !IsNumber(monthsText)) {
        guiPriceText.Text := "赞助金额：无效时长"
        return
    }
    months := Integer(monthsText)
    ; 计算总价格
    pricePerMonth := priceMap[tierSelected]
    totalPrice := pricePerMonth * months . "元"
    ; if months = 12 {
    ;     totalPrice := pricePerMonth * (months - 2) . "元"
    ; }
    ; 更新文本控件的内容
    guiPriceText.Text := totalPrice
}
CalculateSponsorInfo(thisGuiButton, info) {
    ; 步骤1：获取设备唯一标识
    mainBoardSerial := GetMainBoardSerial()
    cpuSerial := GetCpuSerial()
    diskSerial := GetDiskSerial()
    Hashed := HashSHA256(mainBoardSerial . cpuSerial . diskSerial)
    ; 步骤2：获取会员信息
    tierSelected := guiTier.Text
    durationSelected := guiDuration.Text
    ; 步骤3：计算过期日期
    Month := StrReplace(durationSelected, "个月")
    UserGroupInfo := CheckUserGroup() ; 获取用户的会员信息
    ; 检查用户是否已是会员且未过期
    ; 注意：这里需要将过期时间补全至完整格式进行比较
    if (UserGroupInfo.MembershipType != "免费用户" && UserGroupInfo.ExpirationTime . "000000" > A_Now) {
        ; 如果是续费，检查续费类型是否与原有类型一致
        if (UserGroupInfo.MembershipType != tierSelected) {
            MsgBox("您已经是" . UserGroupInfo.MembershipType . "。如果想续费，请选择和现有会员类型一致的选项。")
            return ; 终止函数
        }
        ; 从原有过期日期开始计算
        expiryDate := DateAdd(UserGroupInfo.ExpirationTime . "000000", 30 * Month, "days")
        UserStatus := "老用户续费" ; 新增：定义用户状态
    } else {
        ; 如果是新用户或已过期，则从今天开始计算
        expiryDate := DateAdd(A_Now, 30 * Month, "days")
        UserStatus := "新用户开通" ; 新增：定义用户状态
    }
    ; 步骤4：生成 JSON 字符串
    ; 确保 JSON 中的日期依然是 YYYYMMDD 格式
    jsonString := UserStatus "`n"
    jsonString .= "(将这段文字替换成你的付款截图)`n"
    jsonString .= "  {" . "`n"
    jsonString .= "    `"hash`": `"" Hashed "`"," . "`n"
    jsonString .= "    `"tier`": `"" tierSelected "`"," . "`n"
    jsonString .= "    `"expiry_date`": `"" SubStr(expiryDate, 1, 8) "`"" . "`n"
    jsonString .= "  },"
    ; 步骤5：复制到剪切板
    A_Clipboard := jsonString
    ; 给出提示
    MsgBox("赞助信息已生成并复制到剪贴板，请将其连同付款记录发给我。`n可以加入DoroHelper反馈群(584275905)并私信我`n也可以发我的 qq 邮箱(1204244136@qq.com)或海外邮箱(zhi.11@foxmail.com)`n（只选一个即可，邮箱标题建议注明几个月的金/银/铜oro，正文再复制赞助信息）`n24 小时内我会进行登记并通知，之后重启软件并勾选用户组的「自动检查」即可")
}
;tag 帮助
ClickOnHelp(*) {
    MyHelp := Gui(, "帮助")
    MyHelp.SetFont('s10', 'Microsoft YaHei UI')
    MyHelp.Add("Text", "w600", "- 如有问题请先尝试将更新渠道切换至AHK版并进行更新（需要优质网络）。如果无法更新或仍有问题请加入反馈qq群584275905，反馈必须附带日志和录屏")
    MyHelp.Add("Text", "w600", "- 使用前请先完成所有特殊任务，以防图标错位")
    MyHelp.Add("Text", "w600", "- 游戏分辨率需要设置成**16:9**的分辨率，小于1080p可能有问题，暂不打算特殊支持")
    MyHelp.Add("Text", "w600", "- 由于使用的是图像识别，请确保游戏画面完整在屏幕内，且**游戏画面没有任何遮挡**")
    MyHelp.Add("Text", "w600", "- 多显示器请支持的显示器作为主显示器，将游戏放在主显示器内")
    MyHelp.Add("Text", "w600", "- 未激活正版Windows会有水印提醒，请激活正版Windows")
    MyHelp.Add("Text", "w600", "- 不要使用微星小飞机、游戏加加等悬浮显示数据的软件")
    MyHelp.Add("Text", "w600", "- 游戏画质越高，脚本出错的几率越低")
    MyHelp.Add("Text", "w600", "- 游戏帧数建议保持60，帧数过低时，部分场景的行动可能会被吞，导致问题")
    MyHelp.Add("Text", "w600", "- 如遇到识别问题，请尝试关闭会改变画面颜色相关的功能或设置，例如")
    MyHelp.Add("Text", "w600", "- 软件层面：各种驱动的色彩滤镜，部分笔记本的真彩模式")
    MyHelp.Add("Text", "w600", "- 设备层面：显示器的护眼模式、色彩模式、色温调节、HDR等")
    MyHelp.Add("Text", "w600", "- 游戏语言设置为**简体中文**，设定-画质-开启光晕效果，设定-画质-开启颜色分级，不要使用太亮的大厅背景")
    MyHelp.Add("Text", "w600", "- 推荐使用win11操作系统，win10可能有未知bug")
    MyHelp.Add("Text", "w600", "- 反馈任何问题前，请先尝试复现，如能复现再进行反馈，反馈时必须有录屏和全部日志")
    MyHelp.Add("Text", "w600", "- 鼠标悬浮在控件上会有对应的提示，请勾选或点击前仔细阅读！")
    MyHelp.Add("Text", "w600", "- ctrl+1关闭程序、ctrl+2暂停程序、ctrl+3~7调整游戏大小")
    MyHelp.Add("Text", "w600", "- 如果遇到启动了但毫无反应的情况，请检查杀毒软件(如360、火绒等)是否拦截了DoroHelper的运行，请将其添加信任")
    MyHelp.Add("Text", "w600", "- 如果遇到ACE安全中心提示，请尝试卸载wegame")
    AddCheckboxSetting(MyHelp, "CloseHelp", "我已认真阅读以上内容，并保证出现问题反馈前会再次检查，现在我想让这个弹窗不再主动显示", "")
    MyHelp.Show()
}
;tag 广告
Advertisement() {
    adTitle := "AD"
    MyAd := Gui(, adTitle)
    MyAd.SetFont('s10', 'Microsoft YaHei UI')
    ; MyAd.Add("Text", "w300", "====帮助====")
    ; MyAd.Add("Text", , "第一次运行请先点击左上角的帮助")
    MyAd.Add("Text", "w300", "====广告位招租====")
    MyAd.Add("Text", , "可以通过赞助免除启动时的广告，启动选项-设置-移除启动广告")
    MyAd.Add("Text", , "详情见左上角的「赞助」按钮")
    MyAd.Add("Link", , '<a href="https://pan.baidu.com/s/1pAq-o6fKqUPkRcgj_xVcdA?pwd=2d1q">ahk版和exe版的网盘下载链接</a>')
    MyAd.Add("Link", , '<a href="https://nikke.hayasa.link/">====Nikke CDK Tool====</a>')
    MyAd.Add("Text", "w500", "一个用于管理《胜利女神：NIKKE》CDK 的现代化工具网站，支持支持国际服、国服、港澳台服多服务器、多账号的CDK一键兑换")
    MyAd.Add("Link", , '<a href="https://mirrorchyan.com/">===Mirror酱===</a>')
    MyAd.Add("Text", "w500", "Mirror酱是一个第三方应用分发平台，可以让你更方便地下载和更新应用现已支持 DoroHelper 的自动更新下载，和DoroHelper本身的会员功能无关")
    MyAd.Show()
    Sleep 500
    if not WinExist(adTitle) {
        MsgBox("警告：广告窗口已被拦截或阻止！请关闭您的广告拦截软件，以确保程序正常运行", "警告")
        ExitApp
    }
}
;tag 复制日志
CopyLog(*) {
    A_Clipboard := LogBox.GetText()
    ; 给出提示
    MsgBox("日志内容已复制到剪贴板，请将其连同录屏发到群里")
}
;endregion 消息辅助函数
;region 数据辅助函数
;tag 写入数据
WriteSettings(*) {
    ; 写入当前坐标
    try {
        WinGetPos(&x, &y, &w, &h)
        g_numeric_settings["doroGuiX"] := x
        g_numeric_settings["doroGuiY"] := y
    }
    ;从 g_settings Map 写入开关设置
    for key, value in g_settings {
        IniWrite(value, "settings.ini", "Toggles", key)
    }
    for key, value in g_numeric_settings {
        IniWrite(value, "settings.ini", "NumericSettings", key)
    }
}
;tag 读出数据
LoadSettings() {
    default_settings := g_settings.Clone()
    ;从 Map 加载开关设置
    for key, defaultValue in default_settings {
        readValue := IniRead("settings.ini", "Toggles", key, defaultValue)
        g_settings[key] := readValue
    }
    default_numeric_settings := g_numeric_settings.Clone() ; 保留一份默认数值设置
    for key, defaultValue in default_numeric_settings {
        ; 不再检查是否为数字，直接读取并赋值
        readValue := IniRead("settings.ini", "NumericSettings", key, defaultValue)
        g_numeric_settings[key] := readValue
    }
}
;tag 保存数据
SaveSettings(*) {
    WriteSettings()
    MsgBox "设置已保存！"
}
IsCheckedToString(foo) {
    if foo
        return "Checked"
    else
        return ""
}
/**
 * 添加一个与 g_settings Map 关联的复选框到指定的 GUI 对象.
 * @param guiObj Gui - 要添加控件的 GUI 对象.
 * @param settingKey String - 在 g_settings Map 中对应的键名.
 * @param displayText String - 复选框旁边显示的文本标签.
 * @param options String - (可选) AutoHotkey GUI 布局选项字符串 (例如 "R1 xs+15").
 * @param addToTaskList Boolean - (可选) 如果为 true, 则将此复选框添加到全局任务列表数组中.
 */
AddCheckboxSetting(guiObj, settingKey, displayText, options := "", addToTaskList := false) {
    global g_settings, g_taskListCheckboxes ;确保能访问全局变量
    ;检查 settingKey 是否存在于 g_settings 中
    if !g_settings.Has(settingKey) {
        MsgBox("错误: Setting key '" settingKey "' 在 g_settings 中未定义!", "添加控件错误", "IconX")
        return ;或者抛出错误
    }
    ;构建选项字符串，确保 Checked/空字符串 在选项之后，文本之前
    initialState := IsCheckedToString(g_settings[settingKey])
    fullOptions := options (options ? " " : "") initialState ;如果有 options，加空格分隔
    ;添加复选框控件，并将 displayText 作为第三个参数
    cbCtrl := guiObj.Add("Checkbox", fullOptions, displayText)
    ;给控件附加 settingKey，方便后面识别
    cbCtrl.settingKey := settingKey
    ;绑定 Click 事件，使用胖箭头函数捕获当前的 settingKey
    cbCtrl.OnEvent("Click", (guiCtrl, eventInfo) => ToggleSetting(settingKey, guiCtrl, eventInfo))
    ;如果指定，则添加到任务列表数组
    if (addToTaskList) {
        g_taskListCheckboxes.Push(cbCtrl)
    }
    ;返回创建的控件对象 (可选，如果需要进一步操作)
    return cbCtrl
}
;通用函数，用于切换 g_settings Map 中的设置值
ToggleSetting(settingKey, guiCtrl, *) {
    global g_settings
    ;切换值 (0 变 1, 1 变 0)
    g_settings[settingKey] := 1 - g_settings[settingKey]
    ;可选: 如果需要，可以在这里添加日志记录
    ;ToolTip("切换 " settingKey " 为 " g_settings[settingKey])
}
;endregion 数据辅助函数
;region 坐标辅助函数
;tag 点击
UserClick(sX, sY, k) {
    uX := Round(sX * k) ;计算转换后的坐标
    uY := Round(sY * k)
    CoordMode "Mouse", "Client"
    Send "{Click " uX " " uY "}" ;点击转换后的坐标
}
;tag 按住
UserPress(sX, sY, k) {
    uX := Round(sX * k) ;计算转换后的坐标
    uY := Round(sY * k)
    CoordMode "Mouse", "Client"
    Send "{Click " uX " " uY " " 0 "}" ;点击转换后的坐标
    Send "Click " "Down" "}"
}
;tag 移动
UserMove(sX, sY, k) {
    uX := Round(sX * k) ;计算转换后的坐标
    uY := Round(sY * k)
    CoordMode "Mouse", "Client"
    Send "{Click " uX " " uY " " 0 "}" ;点击转换后的坐标
}
;tag 颜色判断
IsSimilarColor(targetColor, color) {
    tr := Format("{:d}", "0x" . substr(targetColor, 3, 2))
    tg := Format("{:d}", "0x" . substr(targetColor, 5, 2))
    tb := Format("{:d}", "0x" . substr(targetColor, 7, 2))
    pr := Format("{:d}", "0x" . substr(color, 3, 2))
    pg := Format("{:d}", "0x" . substr(color, 5, 2))
    pb := Format("{:d}", "0x" . substr(color, 7, 2))
    distance := sqrt((tr - pr) ** 2 + (tg - pg) ** 2 + (tb - pb) ** 2)
    if (distance < 15)
        return true
    return false
}
;tag 颜色
UserCheckColor(sX, sY, sC, k) {
    loop sX.Length {
        uX := Round(sX[A_Index] * k)
        uY := Round(sY[A_Index] * k)
        uC := PixelGetColor(uX, uY)
        if (!IsSimilarColor(uC, sC[A_Index]))
            return 0
    }
    return 1
}
;tag 画面调整
AdjustSize(TargetX, TargetY) {
    Initialization()
    WinGetPos(&X, &Y, &Width, &Height, nikkeID)
    WinGetClientPos(&ClientX, &ClientY, &ClientWidth, &ClientHeight, nikkeID)
    ; 计算非工作区（标题栏和边框）的高度和宽度
    NonClientHeight := Height - ClientHeight
    NonClientWidth := Width - ClientWidth
    NewClientX := (A_ScreenWidth / 2) - (NikkeWP / 2)
    NewClientY := (A_ScreenHeight / 2) - (NikkeHP / 2)
    NewClientWidth := TargetX
    NewClientHeight := TargetY
    ; 计算新的窗口整体大小，以适应新的工作区大小
    NewWindowX := NewClientX
    NewWindowY := NewClientY
    NewWindowWidth := NewClientWidth + NonClientWidth
    NewWindowHeight := NewClientHeight + NonClientHeight
    ; 使用 WinMove 移动和调整窗口大小
    WinMove 0, 0, NewWindowWidth, NewWindowHeight, nikkeID
}
;endregion 坐标辅助函数
;region 日志辅助函数
;tag 添加日志
AddLog(text, color := "black") {
    ; 确保 LogBox 控件存在
    if (!IsObject(LogBox) || !LogBox.Hwnd) {
        return
    }
    ;静态变量保存上一条内容
    static lastText := ""
    ;如果内容与上一条相同则跳过
    if (text = lastText)
        return
    lastText := text  ;保存当前内容供下次比较
    ; 将光标移到文本末尾
    LogBox.SetSel(-1, -1)
    ; 保存当前选择位置
    sel := LogBox.GetSel()
    start := sel.S
    ; 插入时间戳
    timestamp := FormatTime(, "HH:mm:ss")
    timestamp_text := timestamp "  "
    LogBox.ReplaceSel(timestamp_text)
    ; 设置时间戳为灰色
    sel_before := LogBox.GetSel()
    LogBox.SetSel(start, start + StrLen(timestamp_text))
    font_gray := {}
    font_gray.Color := "gray"
    LogBox.SetFont(font_gray)
    LogBox.SetSel(sel_before.S, sel_before.S) ; 恢复光标位置
    ; 保存时间戳后的位置
    text_start := sel_before.S
    ; 插入文本内容
    LogBox.ReplaceSel(text "`r`n")
    ; 计算文本内容的长度
    text_length := StrLen(text)
    ; 只选择文本内容部分（不包括时间戳）
    LogBox.SetSel(text_start, text_start + text_length)
    ; 使用库提供的 SetFont 方法设置文本颜色
    font := {}
    font.Color := color
    LogBox.SetFont(font)
    ; 设置悬挂缩进 - 使用段落格式
    ; 创建一个 PARAFORMAT2 对象来设置悬挂缩进
    PF2 := RichEdit.PARAFORMAT2()
    PF2.Mask := 0x05 ; PFM_STARTINDENT | PFM_OFFSET
    PF2.StartIndent := 0   ; 总缩进量（缇单位，1缇=1/1440英寸）
    PF2.Offset := 940       ; 悬挂缩进量（负值表示悬挂）
    ; 应用段落格式到选中的文本
    SendMessage(0x0447, 0, PF2.Ptr, LogBox.Hwnd) ; EM_SETPARAFORMAT
    ; 取消选择并将光标移到底部
    LogBox.SetSel(-1, -1)
    ; 自动滚动到底部
    LogBox.ScrollCaret()
}
;tag 日志的时间戳转换
TimeToSeconds(timeStr) {
    ;期望 "HH:mm:ss" 格式
    parts := StrSplit(timeStr, ":")
    if (parts.Length != 3) {
        return -1 ;格式错误
    }
    ;确保部分是数字
    if (!IsInteger(parts[1]) || !IsInteger(parts[2]) || !IsInteger(parts[3])) {
        return -1 ;格式错误
    }
    hours := parts[1] + 0 ;强制转换为数字
    minutes := parts[2] + 0
    seconds := parts[3] + 0
    ;简单的验证范围（不严格）
    if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59 || seconds < 0 || seconds > 59) {
        return -1 ;无效时间
    }
    return hours * 3600 + minutes * 60 + seconds
}
;tag 读取日志框内容 根据 HH:mm:ss 时间戳推算跨度，输出到日志框
CalculateAndShowSpan(ExitReason := "", ExitCode := "") {
    global outputText
    local logContent := LogBox.GetText()
    ; 使用正则表达式提取所有时间戳
    local timestamps := []
    local pos := 1
    local match := ""
    while (pos := RegExMatch(logContent, "(?<time>\d{2}:\d{2}:\d{2})\s{2,}", &match, pos)) {
        timestamps.Push(match["time"])
        pos += match.Len
    }
    ; 检查是否有足够的时间戳
    if (timestamps.Length < 2) {
        AddLog("推算跨度失败：需要至少两个时间戳")
        return
    }
    local earliestTimeStr := timestamps[1]
    local latestTimeStr := timestamps[timestamps.Length]
    local earliestSeconds := TimeToSeconds(earliestTimeStr)
    local latestSeconds := TimeToSeconds(latestTimeStr)
    if (earliestSeconds = -1 || latestSeconds = -1) {
        AddLog("推算跨度失败：日志时间格式错误")
        return
    }
    ; 计算时间差（正确处理跨天）
    local spanSeconds := latestSeconds - earliestSeconds
    ; 如果差值为负，说明可能跨天了
    if (spanSeconds < 0) {
        spanSeconds += 24 * 3600  ; 加上一天的秒数
    }
    local spanMinutes := Floor(spanSeconds / 60)
    local remainingSeconds := Mod(spanSeconds, 60)
    outputText := "已帮你节省时间: "
    if (spanMinutes > 0) {
        outputText .= spanMinutes " 分 "
    }
    outputText .= remainingSeconds " 秒"
    AddLog(outputText)
    if (spanSeconds < 10) {
        MsgBox("没怎么运行就结束了，任务列表勾了吗？还是没有进行详细的任务设置呢？")
    }
}
;endregion 日志辅助函数
;region 流程辅助函数
;tag 点左下角的小房子的对应位置的右边（不返回）
Confirm() {
    UserClick(474, 2028, TrueRatio)
    Sleep 500
}
;tag 按Esc
GoBack() {
    if (ok := FindText(&X, &Y, NikkeX + 0.658 * NikkeW . " ", NikkeY + 0.639 * NikkeH . " ", NikkeX + 0.658 * NikkeW + 0.040 * NikkeW . " ", NikkeY + 0.639 * NikkeH + 0.066 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("方舟的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
        return
    }
    ; AddLog("返回")
    Send "{Esc}"
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.518 * NikkeW . " ", NikkeY + 0.609 * NikkeH . " ", NikkeX + 0.518 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.609 * NikkeH + 0.033 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
    }
    Send "{]}"
    Sleep 500
}
;tag 结算招募
Recruit() {
    AddLog("结算招募")
    while !(ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.944 * NikkeW . " ", NikkeY + 0.011 * NikkeH . " ", NikkeX + 0.944 * NikkeW + 0.015 * NikkeW . " ", NikkeY + 0.011 * NikkeH + 0.029 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("招募·SKIP的图标"), , 0, , , , , TrueRatio, TrueRatio)) { ;如果没找到SKIP就一直点左下角（加速动画）
        Confirm
    }
    FindText().Click(X, Y, "L") ;找到了就点
    Sleep 1000
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.421 * NikkeW . " ", NikkeY + 0.889 * NikkeH . " ", NikkeX + 0.421 * NikkeW + 0.028 * NikkeW . " ", NikkeY + 0.889 * NikkeH + 0.027 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("确认"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
}
;tag 点掉推销
RefuseSale() {
    if (ok := FindText(&X, &Y, NikkeX + 0.438 * NikkeW . " ", NikkeY + 0.853 * NikkeH . " ", NikkeX + 0.438 * NikkeW + 0.124 * NikkeW . " ", NikkeY + 0.853 * NikkeH + 0.048 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("黄色的小时"), , , , , , , TrueRatio, TrueRatio)) {
        UserClick(333, 2041, TrueRatio)
        Sleep 500
        if (ok := FindText(&X, &Y, NikkeX + 0.504 * NikkeW . " ", NikkeY + 0.594 * NikkeH . " ", NikkeX + 0.504 * NikkeW + 0.127 * NikkeW . " ", NikkeY + 0.594 * NikkeH + 0.065 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
            Sleep 500
        }
    }
}
;tag 判断是否开启自动
CheckAuto() {
    if (ok := FindText(&X, &Y, NikkeX + 0.005 * NikkeW . " ", NikkeY + 0.012 * NikkeH . " ", NikkeX + 0.005 * NikkeW + 0.073 * NikkeW . " ", NikkeY + 0.012 * NikkeH + 0.043 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("灰色的AUTO图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("检测到未开启自动爆裂，已开启")
        Send "{Tab}"
    }
    if (ok := FindText(&X, &Y, NikkeX + 0.005 * NikkeW . " ", NikkeY + 0.012 * NikkeH . " ", NikkeX + 0.005 * NikkeW + 0.073 * NikkeW . " ", NikkeY + 0.012 * NikkeH + 0.043 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("灰色的射击图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("检测到未开启自动射击，已开启")
        Send "{LShift}"
    }
}
;tag 跳过boss入场动画
Skipping() {
    while true {
        UserClick(2123, 1371, TrueRatio)
        Sleep 500
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
            Sleep 500
            FindText().Click(X, Y, "L")
            AddLog("跳过动画")
            break
        }
        if (A_Index > 30) {
            break
        }
    }
}
;tag 进入战斗
EnterToBattle() {
    ;是否能进入战斗，0表示根本没找到进入战斗的图标，1表示能，2表示能但次数耗尽（灰色的进入战斗）
    global BattleActive
    ;是否能跳过动画
    global BattleSkip
    ;是否能快速战斗
    global QuickBattle
    QuickBattle := 0
    ; AddLog("尝试进入战斗")
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.506 * NikkeW . " ", NikkeY + 0.826 * NikkeH . " ", NikkeX + 0.506 * NikkeW + 0.145 * NikkeW . " ", NikkeY + 0.826 * NikkeH + 0.065 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("快速战斗的图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击快速战斗")
        FindText().Click(X + 50 * TrueRatio, Y, "L")
        BattleActive := 1
        QuickBattle := 1
        Sleep 500
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.553 * NikkeW . " ", NikkeY + 0.683 * NikkeH . " ", NikkeX + 0.553 * NikkeW + 0.036 * NikkeW . " ", NikkeY + 0.683 * NikkeH + 0.040 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("MAX"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
            Sleep 500
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.470 * NikkeW . " ", NikkeY + 0.733 * NikkeH . " ", NikkeX + 0.470 * NikkeW + 0.157 * NikkeW . " ", NikkeY + 0.733 * NikkeH + 0.073 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("进行战斗的进"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
            Sleep 500
        }
        BattleSkip := 0
    }
    else if (ok := FindText(&X, &Y, NikkeX + 0.499 * NikkeW . " ", NikkeY + 0.786 * NikkeH . " ", NikkeX + 0.499 * NikkeW + 0.155 * NikkeW . " ", NikkeY + 0.786 * NikkeH + 0.191 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("进入战斗的进"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击进入战斗")
        BattleActive := 1
        BattleSkip := 1
        FindText().Click(X + 50 * TrueRatio, Y, "L")
        Sleep 500
    }
    else if (ok := FindText(&X, &Y, NikkeX + 0.519 * NikkeW . " ", NikkeY + 0.831 * NikkeH . " ", NikkeX + 0.519 * NikkeW + 0.134 * NikkeW . " ", NikkeY + 0.831 * NikkeH + 0.143 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("灰色的进"), , , , , , , TrueRatio, TrueRatio)) {
        BattleActive := 2
    }
    else {
        BattleActive := 0
        AddLog("无法战斗")
    }
}
;tag 战斗结算
BattleSettlement(modes*) {
    global Victory
    Screenshot := false
    RedCircle := false
    Exit7 := false
    EventStory := false
    for mode in modes {
        switch mode {
            case "Screenshot":
            {
                Screenshot := true
                if BattleSkip := 1
                    AddLog("截图功能已启用", "Green")
            }
            case "RedCircle":
            {
                RedCircle := true
                if BattleSkip := 1
                    AddLog("红圈功能已启用", "Green")
            }
            case "Exit7":
            {
                Exit7 := true
                if BattleSkip := 1
                    AddLog("满7自动退出功能已启用", "Green")
            }
            case "EventStory":
            {
                EventStory := true
                if BattleSkip := 1
                    AddLog("剧情跳过功能已启用", "Green")
            }
            default: MsgBox "格式输入错误，你输入的是" mode
        }
    }
    if (BattleActive = 0 or BattleActive = 2) {
        AddLog("由于无法战斗，跳过战斗结算")
        if BattleActive = 2 {
            Send "{Esc}"
        }
        return
    }
    AddLog("等待战斗结算")
    while true {
        if Exit7 {
            if (ok := FindText(&X, &Y, NikkeX + 0.512 * NikkeW . " ", NikkeY + 0.072 * NikkeH . " ", NikkeX + 0.512 * NikkeW + 0.020 * NikkeW . " ", NikkeY + 0.072 * NikkeH + 0.035 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("拦截战·红色框的7"), , , , , , , TrueRatio, TrueRatio)) {
                Send "{Esc}"
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.382 * NikkeW . " ", NikkeY + 0.890 * NikkeH . " ", NikkeX + 0.382 * NikkeW + 0.113 * NikkeW . " ", NikkeY + 0.890 * NikkeH + 0.067 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("放弃战斗的图标"), , , , , , , TrueRatio, TrueRatio)) {
                    Sleep 500
                    FindText().Click(X, Y, "L")
                    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.518 * NikkeW . " ", NikkeY + 0.609 * NikkeH . " ", NikkeX + 0.518 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.609 * NikkeH + 0.033 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                        Sleep 500
                        FindText().Click(X, Y, "L")
                    }
                    AddLog("满7自动退出")
                }
            }
        }
        if RedCircle {
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.12 * PicTolerance, 0.13 * PicTolerance, FindText().PicLib("红圈的上边缘黄边"), , 0, , , , , TrueRatio, TrueRatio)) {
                AddLog("检测到红圈的上边缘黄边")
                FindText().Click(X, Y + 70 * TrueRatio, 0)
                Sleep 100
                Click "down left"
                Sleep 700
                Click "up left"
                Sleep 100
            }
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.12 * PicTolerance, 0.13 * PicTolerance, FindText().PicLib("红圈的下边缘黄边"), , 0, , , , , TrueRatio, TrueRatio)) {
                AddLog("检测到红圈的下边缘黄边")
                FindText().Click(X, Y - 70 * TrueRatio, 0)
                Sleep 100
                Click "down left"
                Sleep 700
                Click "up left"
                Sleep 100
            }
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.12 * PicTolerance, 0.11 * PicTolerance, FindText().PicLib("红圈的左边缘黄边"), , 0, , , , , TrueRatio, TrueRatio)) {
                AddLog("检测到红圈的左边缘黄边")
                FindText().Click(X + 70 * TrueRatio, Y, 0)
                Sleep 100
                Click "down left"
                Sleep 700
                Click "up left"
                Sleep 100
            }
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.12 * PicTolerance, 0.13 * PicTolerance, FindText().PicLib("红圈的右边缘黄边"), , 0, , , , , TrueRatio, TrueRatio)) {
                AddLog("检测到红圈的右边缘黄边")
                FindText().Click(X - 70 * TrueRatio, Y, 0)
                Sleep 100
                Click "down left"
                Sleep 700
                Click "up left"
                Sleep 100
            }
        }
        if EventStory {
            ; 跳过剧情
            Send "{]}"
            ; 区域变化的提示
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.445 * NikkeW . " ", NikkeY + 0.561 * NikkeH . " ", NikkeX + 0.445 * NikkeW + 0.111 * NikkeW . " ", NikkeY + 0.561 * NikkeH + 0.056 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("前往区域的图标"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y + 400 * TrueRatio, "L")
            }
        }
        ; 检测自动战斗和爆裂
        if g_settings["CheckAuto"] {
            CheckAuto
        }
        ;无限之塔的位置
        if (ok := FindText(&X, &Y, NikkeX + 0.855 * NikkeW . " ", NikkeY + 0.907 * NikkeH . " ", NikkeX + 0.855 * NikkeW + 0.031 * NikkeW . " ", NikkeY + 0.907 * NikkeH + 0.081 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("TAB的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("[无限之塔胜利]TAB已命中")
            break
        }
        ; 无限之塔失败的位置
        else if (ok := FindText(&X, &Y, NikkeX + 0.784 * NikkeW . " ", NikkeY + 0.895 * NikkeH . " ", NikkeX + 0.784 * NikkeW + 0.031 * NikkeW . " ", NikkeY + 0.895 * NikkeH + 0.078 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("TAB的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("[无限之塔失败]TAB已命中")
            break
        }
        ; 新人竞技场+模拟室+异常拦截的位置
        else if (ok := FindText(&X, &Y, NikkeX + 0.954 * NikkeW . " ", NikkeY + 0.913 * NikkeH . " ", NikkeX + 0.954 * NikkeW + 0.043 * NikkeW . " ", NikkeY + 0.913 * NikkeH + 0.080 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("TAB的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("[新人竞技场|模拟室|异常拦截|推图]TAB已命中")
            break
        }
        else if (ok := FindText(&X, &Y, NikkeX + 0.012 * NikkeW . " ", NikkeY + 0.921 * NikkeH . " ", NikkeX + 0.012 * NikkeW + 0.036 * NikkeW . " ", NikkeY + 0.921 * NikkeH + 0.072 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("重播的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("[竞技场快速战斗失败]重播的图标已命中")
            break
        }
        else if (ok := FindText(&X, &Y, NikkeX + 0.484 * NikkeW . " ", NikkeY + 0.877 * NikkeH . " ", NikkeX + 0.484 * NikkeW + 0.032 * NikkeW . " ", NikkeY + 0.877 * NikkeH + 0.035 * NikkeH . " ", 0.25 * PicTolerance, 0.25 * PicTolerance, FindText().PicLib("ESC"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("[扫荡|活动推关]ESC已命中")
            break
        }
        ; 基地防御等级提升的页面
        if (ok := FindText(&X, &Y, NikkeX + 0.424 * NikkeW . " ", NikkeY + 0.424 * NikkeH . " ", NikkeX + 0.424 * NikkeW + 0.030 * NikkeW . " ", NikkeY + 0.424 * NikkeH + 0.030 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("LV."), , , , , , , TrueRatio, TrueRatio)) {
            Confirm
        }
        ;间隔500ms
        Sleep 500
    }
    ;是否需要截图
    if Screenshot {
        Sleep 1000
        TimeString := FormatTime(, "yyyyMMdd_HHmmss")
        FindText().SavePic(A_ScriptDir "\截图\" TimeString ".jpg", NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, ScreenShot := 1)
    }
    ;有灰色的锁代表赢了但次数耗尽
    if (ok := FindText(&X, &Y, NikkeX + 0.893 * NikkeW . " ", NikkeY + 0.920 * NikkeH . " ", NikkeX + 0.893 * NikkeW + 0.019 * NikkeW . " ", NikkeY + 0.920 * NikkeH + 0.039 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("灰色的锁"), , , , , , , TrueRatio, TrueRatio)) {
        Victory := Victory + 1
        if Victory > 1 {
            AddLog("共胜利" Victory "次")
        }
    }
    ;有编队代表输了，点Esc
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("编队的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("战斗失败！尝试返回")
        GoBack
        Sleep 1000
        return False
    }
    ;如果有下一关，就点下一关（爬塔的情况）
    else if (ok := FindText(&X, &Y, NikkeX + 0.889 * NikkeW . " ", NikkeY + 0.912 * NikkeH . " ", NikkeX + 0.889 * NikkeW + 0.103 * NikkeW . " ", NikkeY + 0.912 * NikkeH + 0.081 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("白色的下一关卡"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("战斗成功！尝试进入下一关")
        Victory := Victory + 1
        if Victory > 1 {
            AddLog("共胜利" Victory "次")
        }
        FindText().Click(X, Y + 20 * TrueRatio, "L")
        Sleep 5000
        if EventStory {
            BattleSettlement("EventStory")
        }
        else {
            BattleSettlement()
        }
    }
    ;没有编队也没有下一关就点Esc（普通情况或者爬塔次数用完了）
    else {
        AddLog("战斗结束！")
        GoBack
        Sleep 1000
        Send "{]}"
        Confirm
        return True
    }
    ;递归结束时清零
    Victory := 0
}
;tag 活动挑战
Challenge() {
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.005 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.063 * NikkeW . " ", NikkeY + 0.005 * NikkeH + 0.050 * NikkeH . " ", 0.35 * PicTolerance, 0.35 * PicTolerance, FindText().PicLib("挑战关卡"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("进入挑战关卡页面")
    }
    Sleep 1000
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.354 * NikkeW . " ", NikkeY + 0.344 * NikkeH . " ", NikkeX + 0.354 * NikkeW + 0.052 * NikkeW . " ", NikkeY + 0.344 * NikkeH + 0.581 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红色的关卡的循环图标"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X + 50 * TrueRatio, Y, "L")
        Sleep 1000
    }
    else if (ok := FindText(&X, &Y, NikkeX + 0.354 * NikkeW . " ", NikkeY + 0.344 * NikkeH . " ", NikkeX + 0.354 * NikkeW + 0.052 * NikkeW . " ", NikkeY + 0.344 * NikkeH + 0.581 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("黄色的关卡的循环图标"), , , , , , 3, TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
    }
    EnterToBattle
    if BattleSkip = 1 {
        Skipping
    }
    BattleSettlement
}
;tag 返回大厅
BackToHall(AD := False) {
    ; AddLog("返回大厅")
    while true {
        if !WinActive(nikkeID) {
            MsgBox ("窗口未聚焦，程序已中止")
            Pause
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.658 * NikkeW . " ", NikkeY + 0.639 * NikkeH . " ", NikkeX + 0.658 * NikkeW + 0.040 * NikkeW . " ", NikkeY + 0.639 * NikkeH + 0.066 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("方舟的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
            if AD = False {
                break
            }
            ; 点右上角的公告图标
            UserClick(3568, 90, TrueRatio)
            Sleep 500
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.477 * NikkeW . " ", NikkeY + 0.082 * NikkeH . " ", NikkeX + 0.477 * NikkeW + 0.021 * NikkeW . " ", NikkeY + 0.082 * NikkeH + 0.042 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("公告的图标"), , , , , , , TrueRatio, TrueRatio)) {
                ; AddLog("已返回大厅")
                UserClick(333, 2041, TrueRatio)
                Sleep 500
                break
            }
            else RefuseSale
        } else {
            ; 点左下角的小房子的位置
            UserClick(333, 2041, TrueRatio)
            Sleep 500
            Send "{]}"
            RefuseSale
        }
        if A_Index > 50 {
            MsgBox ("返回大厅失败，程序已中止")
            Pause
        }
    }
    Sleep 1000
}
;tag 进入方舟
EnterToArk() {
    AddLog("进入方舟")
    while True {
        Sleep 500
        if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.658 * NikkeW . " ", NikkeY + 0.639 * NikkeH . " ", NikkeX + 0.658 * NikkeW + 0.040 * NikkeW . " ", NikkeY + 0.639 * NikkeH + 0.066 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("方舟的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X + 50 * TrueRatio, Y, "L") ;找得到就尝试进入
        }
        if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.014 * NikkeW . " ", NikkeY + 0.026 * NikkeH . " ", NikkeX + 0.014 * NikkeW + 0.021 * NikkeW . " ", NikkeY + 0.026 * NikkeH + 0.021 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("左上角的方舟"), , , , , , , TrueRatio, TrueRatio)) {
            ; AddLog("已进入方舟")
            break
        }
        else BackToHall() ;找不到就先返回大厅
    }
    Sleep 2000
}
;tag 推关模式
AdvanceMode(Picture, Picture2?) {
    Sleep 500
    while true {
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.305 * NikkeW . " ", NikkeY + 0.230 * NikkeH . " ", NikkeX + 0.305 * NikkeW + 0.388 * NikkeW . " ", NikkeY + 0.230 * NikkeH + 0.691 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib(Picture), , , , , , 3, TrueRatio, TrueRatio)) {
            loop 2 {
                try {
                    FindText().Click(ok[A_Index].X, ok[A_Index].Y, "L")
                }
                ; 自动填充加成妮姬
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.352 * NikkeW . " ", NikkeY + 0.713 * NikkeH . " ", NikkeX + 0.352 * NikkeW + 0.304 * NikkeW . " ", NikkeY + 0.713 * NikkeH + 0.107 * NikkeH . " ", 0.25 * PicTolerance, 0.25 * PicTolerance, FindText().PicLib("剧情活动·黑色十字"), , , , , , 1, TrueRatio, TrueRatio)) {
                    if g_settings["AutoFill"] and UserLevel >= 3 {
                        AddLog("点击黑色的加号")
                        FindText().Click(X, Y, "L")
                        Sleep 500
                        FindText().Click(X, Y, "L")
                        Sleep 2000
                        if (ok := FindText(&X, &Y, NikkeX + 0.034 * NikkeW . " ", NikkeY + 0.483 * NikkeH . " ", NikkeX + 0.034 * NikkeW + 0.564 * NikkeW . " ", NikkeY + 0.483 * NikkeH + 0.039 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("剧情活动·0%"), , , , , , 1, TrueRatio, TrueRatio)) {
                            loop ok.Length {
                                AddLog("添加第" A_Index "个妮姬")
                                FindText().Click(ok[A_Index].x, ok[A_Index].y, "L")
                                Sleep 1000
                                if A_Index = 5 {
                                    break
                                }
                            }
                        }
                        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.917 * NikkeW . " ", NikkeY + 0.910 * NikkeH . " ", NikkeX + 0.917 * NikkeW + 0.077 * NikkeW . " ", NikkeY + 0.910 * NikkeH + 0.057 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                            AddLog("点击储存")
                            FindText().Click(X, Y, "L")
                            Sleep 2000
                        }
                    }
                    else {
                        MsgBox ("请手动选择妮姬")
                    }
                }
                EnterToBattle
                BattleSettlement("EventStory")
                ; 区域变化的提示
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.445 * NikkeW . " ", NikkeY + 0.561 * NikkeH . " ", NikkeX + 0.445 * NikkeW + 0.111 * NikkeW . " ", NikkeY + 0.561 * NikkeH + 0.056 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("前往区域的图标"), , , , , , , TrueRatio, TrueRatio)) {
                    FindText().Click(X, Y + 400 * TrueRatio, "L")
                }
                if BattleActive = 2 {
                    return
                }
                if QuickBattle = 1 {
                    return
                }
                Sleep 1000
            }
        }
        else {
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.305 * NikkeW . " ", NikkeY + 0.230 * NikkeH . " ", NikkeX + 0.305 * NikkeW + 0.388 * NikkeW . " ", NikkeY + 0.230 * NikkeH + 0.691 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib(Picture2), , , , , , 3, TrueRatio, TrueRatio)) {
                loop 2 {
                    try {
                        FindText().Click(ok[A_Index].X, ok[A_Index].Y, "L")
                    }
                    EnterToBattle
                    BattleSettlement("EventStory")
                    ; 区域变化的提示
                    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.445 * NikkeW . " ", NikkeY + 0.561 * NikkeH . " ", NikkeX + 0.445 * NikkeW + 0.111 * NikkeW . " ", NikkeY + 0.561 * NikkeH + 0.056 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("前往区域的图标"), , , , , , , TrueRatio, TrueRatio)) {
                        FindText().Click(X, Y + 400 * TrueRatio, "L")
                    }
                    if BattleActive = 2 {
                        return
                    }
                    if QuickBattle = 1 {
                        return
                    }
                }
            }
        }
        Sleep 3000
        Send "{]}" ;防止最后一关剧情卡死
    }
}
;endregion 流程辅助函数
;region 登录
Login() {
    check := 0
    while True {
        AddLog("正在登录")
        if (check = 3) {
            break
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.658 * NikkeW . " ", NikkeY + 0.639 * NikkeH . " ", NikkeX + 0.658 * NikkeW + 0.040 * NikkeW . " ", NikkeY + 0.639 * NikkeH + 0.066 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("方舟的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
            check := check + 1
            Sleep 1000
            continue
        }
        else check := 0
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.516 * NikkeW . " ", NikkeY + 0.844 * NikkeH . " ", NikkeX + 0.516 * NikkeW + 0.136 * NikkeW . " ", NikkeY + 0.844 * NikkeH + 0.140 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("签到·全部领取的全部"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
            Sleep 1000
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.533 * NikkeW . " ", NikkeY + 0.908 * NikkeH . " ", NikkeX + 0.533 * NikkeW + 0.115 * NikkeW . " ", NikkeY + 0.908 * NikkeH + 0.059 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("获得奖励的图标"), , , , , , , TrueRatio * 0.8, TrueRatio * 0.8)) {
            FindText().Click(X, Y, "L")
            Sleep 1000
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.356 * NikkeW . " ", NikkeY + 0.179 * NikkeH . " ", NikkeX + 0.356 * NikkeW + 0.287 * NikkeW . " ", NikkeY + 0.179 * NikkeH + 0.805 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("不再显示的框"), , 0, , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
            Sleep 1000
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.443 * NikkeW . " ", NikkeY + 0.703 * NikkeH . " ", NikkeX + 0.443 * NikkeW + 0.116 * NikkeW . " ", NikkeY + 0.703 * NikkeH + 0.051 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("确认的白色勾"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("确认服务器")
            FindText().Click(X + 50 * TrueRatio, Y, "L")
            Sleep 1000
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.504 * NikkeW . " ", NikkeY + 0.610 * NikkeH . " ", NikkeX + 0.504 * NikkeW + 0.090 * NikkeW . " ", NikkeY + 0.610 * NikkeH + 0.056 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("确认的白色勾"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("确认下载内容")
            FindText().Click(X + 50 * TrueRatio, Y, "L")
            Sleep 1000
        }
        UserClick(330, 2032, TrueRatio)
        Sleep 1000
        if !WinActive(nikkeID) {
            MsgBox ("窗口未聚焦，程序已中止")
            Pause
        }
    }
    AddLog("已处于大厅页面，登录成功")
}
;endregion 登录
;region 商店
;tag 付费商店
ShopCash() {
    AddLog("开始任务：付费商店", "Fuchsia")
    AddLog("寻找付费商店")
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.250 * NikkeW . " ", NikkeY + 0.599 * NikkeH . " ", NikkeX + 0.250 * NikkeW + 0.027 * NikkeW . " ", NikkeY + 0.599 * NikkeH + 0.047 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("付费商店的图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击付费商店")
        FindText().Click(X, Y, "L")
        Sleep 2000
        if g_settings["ShopCashFree"] {
            AddLog("领取免费珠宝")
            while true {
                if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.386 * NikkeW . " ", NikkeY + 0.632 * NikkeH . " ", NikkeX + 0.386 * NikkeW + 0.016 * NikkeW . " ", NikkeY + 0.632 * NikkeH + 0.025 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("灰色空心方框"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("发现日服特供的框")
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
                        AddLog("点击确认")
                        FindText().Click(X, Y, "L")
                    }
                }
                else if (ok := FindText(&X, &Y, NikkeX + 0.040 * NikkeW . " ", NikkeY + 0.178 * NikkeH . " ", NikkeX + 0.040 * NikkeW + 0.229 * NikkeW . " ", NikkeY + 0.178 * NikkeH + 0.080 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("礼物的下半"), , , , , , , TrueRatio, TrueRatio)) {
                    Sleep 500
                    AddLog("点击一级页面")
                    FindText().Click(X + 20 * TrueRatio, Y + 20 * TrueRatio, "L")
                    Sleep 500
                }
                else break
            }
            while (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.010 * NikkeW . " ", NikkeY + 0.259 * NikkeH . " ", NikkeX + 0.010 * NikkeW + 0.351 * NikkeW . " ", NikkeY + 0.259 * NikkeH + 0.051 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击二级页面")
                FindText().Click(X - 20 * TrueRatio, Y + 20 * TrueRatio, "L")
                Sleep 1000
                if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.089 * NikkeW . " ", NikkeY + 0.334 * NikkeH . " ", NikkeX + 0.089 * NikkeW + 0.019 * NikkeW . " ", NikkeY + 0.334 * NikkeH + 0.034 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , 5, TrueRatio, TrueRatio)) {
                    AddLog("点击三级页面")
                    FindText().Click(X - 20 * TrueRatio, Y + 20 * TrueRatio, "L")
                    Sleep 1000
                    Confirm
                    Sleep 500
                    Confirm
                }
                if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("白色的叉叉"), , , , , , , TrueRatio, TrueRatio)) {
                    FindText().Click(X, Y, "L")
                    AddLog("检测到白色叉叉，尝试重新执行任务")
                    BackToHall
                    ShopCash
                }
            }
            else {
                AddLog("奖励已全部领取")
            }
        }
        if g_settings["ShopCashFreePackage"] {
            AddLog("领取免费礼包")
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.180 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.266 * NikkeW . " ", NikkeY + 0.180 * NikkeH + 0.077 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击一级页面")
                FindText().Click(X - 20 * TrueRatio, Y + 20 * TrueRatio, "L")
                Sleep 1000
                if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.010 * NikkeW . " ", NikkeY + 0.259 * NikkeH . " ", NikkeX + 0.010 * NikkeW + 0.351 * NikkeW . " ", NikkeY + 0.259 * NikkeH + 0.051 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("点击二级页面")
                    FindText().Click(X - 20 * TrueRatio, Y + 20 * TrueRatio, "L")
                    Sleep 1000
                    ;把鼠标移动到商品栏
                    UserMove(1918, 1060, TrueRatio)
                    Send "{WheelUp 3}"
                    Sleep 1000
                }
                if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.332 * NikkeW . " ", NikkeY + 0.443 * NikkeH . " ", NikkeX + 0.332 * NikkeW + 0.327 * NikkeW . " ", NikkeY + 0.443 * NikkeH + 0.466 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("点击三级页面")
                    FindText().Click(X - 20 * TrueRatio, Y + 20 * TrueRatio, "L")
                    Sleep 1000
                    Confirm
                }
            }
            AddLog("奖励已全部领取")
        }
        if g_settings["ClearRed"] {
            while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.001 * NikkeW . " ", NikkeY + 0.191 * NikkeH . " ", NikkeX + 0.001 * NikkeW + 0.292 * NikkeW . " ", NikkeY + 0.191 * NikkeH + 0.033 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红底的N图标"), , , , , , , 0.83 * TrueRatio, 0.83 * TrueRatio)) {
                FindText().Click(X, Y, "L")
                Sleep 1000
                while (ok := FindText(&X, &Y, NikkeX + 0.005 * NikkeW . " ", NikkeY + 0.254 * NikkeH . " ", NikkeX + 0.005 * NikkeW + 0.468 * NikkeW . " ", NikkeY + 0.254 * NikkeH + 0.031 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红底的N图标"), , , , , , , TrueRatio, TrueRatio)) {
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                    UserClick(208, 608, TrueRatio)
                    Sleep 1000
                }
            }
        }
    }
    BackToHall
}
;tag 普通商店
ShopNormal() {
    if g_settings["ShopNormalFree"] = False and g_settings["ShopNormalDust"] = False and g_settings["ShopNormalPackage"] = False {
        AddLog("普通商店购买选项均未启用，跳过此任务", "Fuchsia")
        return
    }
    AddLog("开始任务：普通商店", "Fuchsia")
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.236 * NikkeW . " ", NikkeY + 0.633 * NikkeH . " ", NikkeX + 0.236 * NikkeW + 0.118 * NikkeW . " ", NikkeY + 0.633 * NikkeH + 0.103 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("商店的图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击商店图标")
        FindText().Click(X + 20 * TrueRatio, Y - 20 * TrueRatio, "L")
    }
    else {
        MsgBox("商店图标未找到")
    }
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("左上角的百货商店"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("已进入百货商店")
    }
    Sleep 1000
    ; 定义所有可购买物品的信息 (使用 Map)
    PurchaseItems := Map(
        "免费商品", {
            Text: FindText().PicLib("红点"),
            Setting: g_settings["ShopNormalFree"],
            Tolerance: 0.4 * PicTolerance },
        "芯尘盒", {
            Text: FindText().PicLib("芯尘盒"),
            Setting: g_settings["ShopNormalDust"],
            Tolerance: 0.2 * PicTolerance },
        "简介个性化礼包", {
            Text: FindText().PicLib("简介个性化礼包"),
            Setting: g_settings["ShopNormalPackage"],
            Tolerance: 0.2 * PicTolerance }
    )
    loop 2 {
        for Name, item in PurchaseItems {
            if (!item.Setting) {
                continue ; 如果设置未开启，则跳过此物品
            }
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.061 * NikkeW . " ", NikkeY + 0.493 * NikkeH . " ", NikkeX + 0.061 * NikkeW + 0.416 * NikkeW . " ", NikkeY + 0.493 * NikkeH + 0.038 * NikkeH . " ", item.Tolerance, item.Tolerance, item.Text, , , , , , , TrueRatio, TrueRatio)) {
                loop ok.Length {
                    AddLog("购买" . Name)
                    FindText().Click(ok[A_Index].x, ok[A_Index].y, "L")
                    Sleep 1000
                    if name = "芯尘盒" {
                        if (ok0 := FindText(&X := "wait", &Y := 2, NikkeX + 0.430 * NikkeW . " ", NikkeY + 0.716 * NikkeH . " ", NikkeX + 0.430 * NikkeW + 0.139 * NikkeW . " ", NikkeY + 0.716 * NikkeH + 0.034 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("信用点的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
                            AddLog("检测到信用点支付选项")
                        }
                        else {
                            AddLog("未检测到信用点支付选项")
                            Confirm
                            Sleep 1000
                            continue
                        }
                    }
                    if (ok1 := FindText(&X := "wait", &Y := 2, NikkeX + 0.506 * NikkeW . " ", NikkeY + 0.786 * NikkeH . " ", NikkeX + 0.506 * NikkeW + 0.088 * NikkeW . " ", NikkeY + 0.786 * NikkeH + 0.146 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
                        FindText().Click(X, Y, "L")
                        Sleep 1000
                    }
                    while !(ok2 := FindText(&X := "wait", &Y := 1, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("左上角的百货商店"), , 0, , , , , TrueRatio, TrueRatio)) {
                        Confirm
                    }
                }
            } else {
                AddLog(Name . "未找到，跳过购买")
            }
        }
        while (ok := FindText(&X, &Y, NikkeX + 0.173 * NikkeW . " ", NikkeY + 0.423 * NikkeH . " ", NikkeX + 0.173 * NikkeW + 0.034 * NikkeW . " ", NikkeY + 0.423 * NikkeH + 0.050 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("FREE"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("尝试刷新商店")
            FindText().Click(X - 100 * TrueRatio, Y + 30 * TrueRatio, "L")
            Sleep 500
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.504 * NikkeW . " ", NikkeY + 0.593 * NikkeH . " ", NikkeX + 0.504 * NikkeW + 0.127 * NikkeW . " ", NikkeY + 0.593 * NikkeH + 0.066 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                Sleep 500
                AddLog("刷新成功")
            }
        } else {
            AddLog("没有免费刷新次数了，跳过刷新")
            break ; 退出外层 loop 2 循环，因为没有免费刷新了
        }
        Sleep 2000
    }
}
;tag 竞技场商店
ShopArena() {
    AddLog("开始任务：竞技场商店", "Fuchsia")
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.001 * NikkeW . " ", NikkeY + 0.355 * NikkeH . " ", NikkeX + 0.001 * NikkeW + 0.041 * NikkeW . " ", NikkeY + 0.355 * NikkeH + 0.555 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("竞技场商店的图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("进入竞技场商店")
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    ; 定义所有可购买物品的信息 (使用 Map)
    PurchaseItems := Map(
        "燃烧代码手册", {
            Text: FindText().PicLib("燃烧代码的图标"),
            Setting: g_settings["ShopArenaBookFire"],
            Tolerance: 0.2 * PicTolerance },
        "水冷代码手册", {
            Text: FindText().PicLib("水冷代码的图标"),
            Setting: g_settings["ShopArenaBookWater"],
            Tolerance: 0.2 * PicTolerance },
        "风压代码手册", {
            Text: FindText().PicLib("风压代码的图标"),
            Setting: g_settings["ShopArenaBookWind"],
            Tolerance: 0.3 * PicTolerance },
        "电击代码手册", {
            Text: FindText().PicLib("电击代码的图标"),
            Setting: g_settings["ShopArenaBookElec"],
            Tolerance: 0.2 * PicTolerance },
        "铁甲代码手册", {
            Text: FindText().PicLib("铁甲代码的图标"),
            Setting: g_settings["ShopArenaBookIron"],
            Tolerance: 0.2 * PicTolerance },
        "代码手册宝箱", {
            Text: FindText().PicLib("代码手册选择宝箱的图标"),
            Setting: g_settings["ShopArenaBookBox"],
            Tolerance: 0.3 * PicTolerance },
        "简介个性化礼包", {
            Text: FindText().PicLib("简介个性化礼包"),
            Setting: g_settings["ShopArenaPackage"],
            Tolerance: 0.3 * PicTolerance },
        "公司武器熔炉", {
            Text: FindText().PicLib("公司武器熔炉"),
            Setting: g_settings["ShopArenaFurnace"],
            Tolerance: 0.3 * PicTolerance }
    )
    ; 遍历并购买所有物品
    for Name, item in PurchaseItems {
        if (!item.Setting) {
            continue ; 如果设置未开启，则跳过此物品
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.061 * NikkeW . " ", NikkeY + 0.499 * NikkeH . " ", NikkeX + 0.061 * NikkeW + 0.499 * NikkeW . " ", NikkeY + 0.499 * NikkeH + 0.119 * NikkeH . " ", item.Tolerance, item.Tolerance, item.Text, , , , , , , TrueRatio, TrueRatio)) {
            ; 手册要根据找到个数多次执行
            loop ok.Length {
                FindText().Click(ok[A_Index].x, ok[A_Index].y, "L")
                if (ok1 := FindText(&X := "wait", &Y := 2, NikkeX + 0.506 * NikkeW . " ", NikkeY + 0.786 * NikkeH . " ", NikkeX + 0.506 * NikkeW + 0.088 * NikkeW . " ", NikkeY + 0.786 * NikkeH + 0.146 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
                    Sleep 500
                    AddLog("购买" . Name)
                    FindText().Click(X, Y, "L")
                    Sleep 500
                    while !(ok2 := FindText(&X := "wait", &Y := 1, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("左上角的百货商店"), , 0, , , , , TrueRatio, TrueRatio)) {
                        Confirm
                    }
                }
            }
        }
        else {
            AddLog(Name . "未找到，跳过购买")
        }
    }
}
;tag 废铁商店
ShopScrap() {
    AddLog("开始任务：废铁商店", "Fuchsia")
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.001 * NikkeW . " ", NikkeY + 0.355 * NikkeH . " ", NikkeX + 0.001 * NikkeW + 0.041 * NikkeW . " ", NikkeY + 0.355 * NikkeH + 0.555 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("废铁商店的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    ; 定义所有可购买物品的信息 (使用 Map)
    PurchaseItems := Map(
        "珠宝", {
            Text: FindText().PicLib("珠宝"),
            Setting: g_settings["ShopScrapGem"],
            Tolerance: 0.2 * PicTolerance },
        "好感券", {
            Text: FindText().PicLib("黄色的礼物图标"),
            Setting: g_settings["ShopScrapVoucher"],
            Tolerance: 0.3 * PicTolerance },
        "养成资源", {
            Text: FindText().PicLib("资源的图标"),
            Setting: g_settings["ShopScrapResources"],
            Tolerance: 0.2 * PicTolerance },
        "信用点", {
            Text: FindText().PicLib("黄色的信用点图标"),
            Setting: g_settings["ShopScrapResources"],
            Tolerance: 0.3 * PicTolerance },
        "团队合作宝箱", {
            Text: FindText().PicLib("团队合作宝箱图标"),
            Setting: g_settings["ShopScrapTeamworkBox"],
            Tolerance: 0.25 * PicTolerance },
        "保养工具箱", {
            Text: FindText().PicLib("保养工具箱图标"),
            Setting: g_settings["ShopScrapKitBox"],
            Tolerance: 0.3 * PicTolerance },
        "企业精选武装", {
            Text: FindText().PicLib("企业精选武装图标"),
            Setting: g_settings["ShopScrapArms"],
            Tolerance: 0.3 * PicTolerance }
    )
    ; 遍历并购买所有物品
    for Name, item in PurchaseItems {
        if (!item.Setting) {
            continue ; 如果设置未开启，则跳过此物品
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.054 * NikkeW . " ", NikkeY + 0.479 * NikkeH . " ", NikkeX + 0.054 * NikkeW + 0.934 * NikkeW . " ", NikkeY + 0.479 * NikkeH + 0.344 * NikkeH . " ", item.Tolerance, item.Tolerance, item.Text, , , , , , 1, TrueRatio, TrueRatio)) {
            ; 根据找到的同类图标数量进行循环购买
            loop ok.Length {
                FindText().Click(ok[A_Index].x, ok[A_Index].y, "L")
                AddLog("已找到" . Name)
                Sleep 1000
                if (okMax := FindText(&X := "wait", &Y := 2, NikkeX + 0.590 * NikkeW . " ", NikkeY + 0.593 * NikkeH . " ", NikkeX + 0.590 * NikkeW + 0.035 * NikkeW . " ", NikkeY + 0.593 * NikkeH + 0.045 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("MAX"), , 0, , , , , TrueRatio, TrueRatio)) {
                    ; AddLog("点击max")
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                }
                if (ok1 := FindText(&X := "wait", &Y := 2, NikkeX + 0.506 * NikkeW . " ", NikkeY + 0.786 * NikkeH . " ", NikkeX + 0.506 * NikkeW + 0.088 * NikkeW . " ", NikkeY + 0.786 * NikkeH + 0.146 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
                    AddLog("购买" . Name)
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                    while !(ok2 := FindText(&X := "wait", &Y := 1, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("左上角的百货商店"), , 0, , , , , TrueRatio, TrueRatio)) {
                        Confirm
                    }
                }
            }
        } else {
            AddLog(Name . "未找到，跳过购买")
        }
    }
}
;endregion 商店
;region 模拟室
;tag 模拟室
SimulationNormal() {
    EnterToArk
    AddLog("开始任务：模拟室", "Fuchsia")
    AddLog("查找模拟室入口")
    while (ok := FindText(&X, &Y, NikkeX + 0.370 * NikkeW . " ", NikkeY + 0.544 * NikkeH . " ", NikkeX + 0.370 * NikkeW + 0.069 * NikkeW . " ", NikkeY + 0.544 * NikkeH + 0.031 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("模拟室"), , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("进入模拟室")
        FindText().Click(X, Y - 50 * TrueRatio, "L")
        Sleep 1000
    }
    while true {
        if (ok := FindText(&X, &Y, NikkeX + 0.897 * NikkeW . " ", NikkeY + 0.063 * NikkeH . " ", NikkeX + 0.897 * NikkeW + 0.102 * NikkeW . " ", NikkeY + 0.063 * NikkeH + 0.060 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("结束模拟的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
            MsgBox("请手动结束模拟后重新运行该任务")
            Pause
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.442 * NikkeW . " ", NikkeY + 0.535 * NikkeH . " ", NikkeX + 0.442 * NikkeW + 0.118 * NikkeW . " ", NikkeY + 0.535 * NikkeH + 0.101 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("开始模拟的开始"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("点击开始模拟")
            FindText().Click(X + 30 * TrueRatio, Y, "L")
            Sleep 500
            break
        }
        else Confirm
    }
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.501 * NikkeW . " ", NikkeY + 0.830 * NikkeH . " ", NikkeX + 0.501 * NikkeW + 0.150 * NikkeW . " ", NikkeY + 0.830 * NikkeH + 0.070 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("快速模拟的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("点击快速模拟")
        Sleep 500
        FindText().Click(X + 100 * TrueRatio, Y, "L")
    }
    else {
        AddLog("没有解锁快速模拟，跳过该任务", "Olive")
        return
    }
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.474 * NikkeW . " ", NikkeY + 0.521 * NikkeH . " ", NikkeX + 0.474 * NikkeW + 0.052 * NikkeW . " ", NikkeY + 0.521 * NikkeH + 0.028 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("模拟室·不再显示"), , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("点击不再显示")
        Sleep 500
        FindText().Click(X, Y, "L")
        Sleep 500
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.441 * NikkeW . " ", NikkeY + 0.602 * NikkeH . " ", NikkeX + 0.441 * NikkeW + 0.119 * NikkeW . " ", NikkeY + 0.602 * NikkeH + 0.050 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("确认快速模拟指南")
            Sleep 500
            FindText().Click(X, Y, "L")
        }
    }
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.428 * NikkeW . " ", NikkeY + 0.883 * NikkeH . " ", NikkeX + 0.428 * NikkeW + 0.145 * NikkeW . " ", NikkeY + 0.883 * NikkeH + 0.069 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("跳过增益效果选择的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
        Sleep 500
        AddLog("跳过增益选择")
        FindText().Click(X + 100 * TrueRatio, Y, "L")
        Sleep 1000
    }
    EnterToBattle
    if BattleActive = 0 {
        if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.485 * NikkeW . " ", NikkeY + 0.681 * NikkeH . " ", NikkeX + 0.485 * NikkeW + 0.030 * NikkeW . " ", NikkeY + 0.681 * NikkeH + 0.048 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio * 1.25, TrueRatio * 1.25)) {
            FindText().Click(X, Y, "L")
            EnterToBattle
        }
    }
    BattleSettlement
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.364 * NikkeW . " ", NikkeY + 0.323 * NikkeH . " ", NikkeX + 0.364 * NikkeW + 0.272 * NikkeW . " ", NikkeY + 0.323 * NikkeH + 0.558 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("模拟结束的图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击模拟结束")
        Sleep 500
        FindText().Click(X + 50 * TrueRatio, Y, "L")
        Sleep 500
        FindText().Click(X + 50 * TrueRatio, Y, "L")
    }
    while !(ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
        Confirm
    }
}
;tag 模拟室超频
SimulationOverClock(mode := "") {
    if mode != "force" {
        if !g_settings["SimulationNormal"] {
            EnterToArk
            AddLog("查找模拟室入口")
            while (ok := FindText(&X, &Y, NikkeX + 0.370 * NikkeW . " ", NikkeY + 0.544 * NikkeH . " ", NikkeX + 0.370 * NikkeW + 0.069 * NikkeW . " ", NikkeY + 0.544 * NikkeH + 0.031 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("模拟室"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("进入模拟室")
                FindText().Click(X, Y - 50 * TrueRatio, "L")
                Sleep 1000
            }
        }
        AddLog("开始任务：模拟室超频", "Fuchsia")
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.453 * NikkeW . " ", NikkeY + 0.775 * NikkeH . " ", NikkeX + 0.453 * NikkeW + 0.095 * NikkeW . " ", NikkeY + 0.775 * NikkeH + 0.050 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红框中的0"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("模拟室超频未完成")
            UserClick(1918, 1637, TrueRatio) ; 点击模拟室超频按钮
            Sleep 1000
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
                Confirm
            }
        }
        else {
            AddLog("模拟室超频已完成！")
            return
        }
    }
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.434 * NikkeW . " ", NikkeY + 0.573 * NikkeH . " ", NikkeX + 0.434 * NikkeW + 0.132 * NikkeW . " ", NikkeY + 0.573 * NikkeH + 0.077 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("BIOS"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.376 * NikkeW . " ", NikkeY + 0.236 * NikkeH . " ", NikkeX + 0.376 * NikkeW + 0.047 * NikkeW . " ", NikkeY + 0.236 * NikkeH + 0.078 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("蓝色的25"), , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("难度正确")
    }
    else {
        AddLog("难度不是25，跳过")
        return
    }
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.373 * NikkeW . " ", NikkeY + 0.878 * NikkeH . " ", NikkeX + 0.373 * NikkeW + 0.253 * NikkeW . " ", NikkeY + 0.878 * NikkeH + 0.058 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("开始模拟"), , 0, , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 3000
    }
    final := false
    while true {
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.365 * NikkeW . " ", NikkeY + 0.552 * NikkeH . " ", NikkeX + 0.365 * NikkeW + 0.269 * NikkeW . " ", NikkeY + 0.552 * NikkeH + 0.239 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("模拟室超频·获得"), , 0, , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
        }
        if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.485 * NikkeW . " ", NikkeY + 0.681 * NikkeH . " ", NikkeX + 0.485 * NikkeW + 0.030 * NikkeW . " ", NikkeY + 0.681 * NikkeH + 0.048 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio * 1.25, TrueRatio * 1.25)) {
            final := True
            AddLog("挑战最后一关")
            FindText().Click(X, Y, "L")
        }
        EnterToBattle
        BattleSettlement
        if final = True {
            break
        }
        AddLog("模拟室超频第" A_Index "关已通关！")
        while true {
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.377 * NikkeW . " ", NikkeY + 0.345 * NikkeH . " ", NikkeX + 0.377 * NikkeW + 0.246 * NikkeW . " ", NikkeY + 0.345 * NikkeH + 0.419 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("模拟室·链接等级"), , , , , , 3, TrueRatio, TrueRatio)) {
                AddLog("获取增益")
                Sleep 1000
                FindText().Click(X, Y, "L")
                Sleep 1000
            }
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.497 * NikkeW . " ", NikkeY + 0.714 * NikkeH . " ", NikkeX + 0.497 * NikkeW + 0.162 * NikkeW . " ", NikkeY + 0.714 * NikkeH + 0.278 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                Sleep 1000
            }
            if A_Index > 1 {
                break
            }
        }
        if A_Index > 10 {
            MsgBox("循环次数异常！请勾选「禁止无关人员进入」和「好战型战术」")
            ExitApp
        }
    }
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.364 * NikkeW . " ", NikkeY + 0.323 * NikkeH . " ", NikkeX + 0.364 * NikkeW + 0.272 * NikkeW . " ", NikkeY + 0.323 * NikkeH + 0.558 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("模拟结束的图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击模拟结束")
        Sleep 500
        FindText().Click(X + 50 * TrueRatio, Y, "L")
        Sleep 500
        Confirm
    }
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.367 * NikkeW . " ", NikkeY + 0.755 * NikkeH . " ", NikkeX + 0.367 * NikkeW + 0.267 * NikkeW . " ", NikkeY + 0.755 * NikkeH + 0.093 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("不选择的图标"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    Sleep 1000
}
;endregion 模拟室
;region 竞技场
;tag 竞技场收菜
AwardArena() {
    EnterToArk()
    AddLog("开始任务：竞技场收菜", "Fuchsia")
    AddLog("查找奖励")
    foundReward := false
    while (ok := FindText(&X, &Y, NikkeX + 0.568 * NikkeW . " ", NikkeY + 0.443 * NikkeH . " ", NikkeX + 0.568 * NikkeW + 0.015 * NikkeW . " ", NikkeY + 0.443 * NikkeH + 0.031 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("竞技场·收菜的图标"), , , , , , , TrueRatio, TrueRatio)) {
        foundReward := true
        AddLog("点击奖励")
        FindText().Click(X + 30 * TrueRatio, Y, "L")
        Sleep 1000
    }
    if foundReward {
        while (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("点击领取")
            FindText().Click(X + 50 * TrueRatio, Y, "L")
        }
        AddLog("尝试确认并返回方舟大厅")
        while !(ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.014 * NikkeW . " ", NikkeY + 0.026 * NikkeH . " ", NikkeX + 0.014 * NikkeW + 0.021 * NikkeW . " ", NikkeY + 0.026 * NikkeH + 0.021 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("左上角的方舟"), , , , , , , TrueRatio, TrueRatio)) {
            Confirm
        }
    }
    else AddLog("未找到奖励")
}
;tag 进入竞技场
EnterToArena() {
    if (ok := FindText(&X, &Y, NikkeX + 0.001 * NikkeW . " ", NikkeY + 0.002 * NikkeH . " ", NikkeX + 0.001 * NikkeW + 0.060 * NikkeW . " ", NikkeY + 0.002 * NikkeH + 0.060 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("左上角的竞技场"), , , , , , , TrueRatio, TrueRatio)) {
        return
    }
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.554 * NikkeW . " ", NikkeY + 0.640 * NikkeH . " ", NikkeX + 0.554 * NikkeW + 0.068 * NikkeW . " ", NikkeY + 0.640 * NikkeH + 0.029 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("方舟·竞技场"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击竞技场")
        FindText().Click(X, Y - 50 * TrueRatio, "L")
    }
    while !(ok := FindText(&X, &Y, NikkeX + 0.001 * NikkeW . " ", NikkeY + 0.002 * NikkeH . " ", NikkeX + 0.001 * NikkeW + 0.060 * NikkeW . " ", NikkeY + 0.002 * NikkeH + 0.060 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("左上角的竞技场"), , , , , , , TrueRatio, TrueRatio)) {
        Confirm
    }
    AddLog("进入竞技场")
    Sleep 1000
}
;tag 新人竞技场
ArenaRookie() {
    AddLog("开始任务：新人竞技场", "Fuchsia")
    AddLog("查找新人竞技场")
    while (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.372 * NikkeW . " ", NikkeY + 0.542 * NikkeH . " ", NikkeX + 0.372 * NikkeW + 0.045 * NikkeW . " ", NikkeY + 0.542 * NikkeH + 0.024 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("蓝色的新人"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击新人竞技场")
        FindText().Click(X + 20 * TrueRatio, Y, "L")
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("已进入新人竞技场")
            break
        }
        if A_Index > 3 {
            AddLog("新人竞技场未在开放期间，跳过任务")
            return
        }
    }
    AddLog("检测免费次数")
    skip := false
    while True {
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.578 * NikkeW . " ", NikkeY + 0.804 * NikkeH . " ", NikkeX + 0.578 * NikkeW + 0.059 * NikkeW . " ", NikkeY + 0.804 * NikkeH + 0.045 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("免费"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("有免费次数，尝试进入战斗")
            FindText().Click(X, Y + 10 * TrueRatio, "L")
        }
        else {
            AddLog("没有免费次数，尝试返回")
            break
        }
        if skip = false {
            Sleep 1000
            if (ok := FindText(&X, &Y, NikkeX + 0.393 * NikkeW . " ", NikkeY + 0.815 * NikkeH . " ", NikkeX + 0.393 * NikkeW + 0.081 * NikkeW . " ", NikkeY + 0.815 * NikkeH + 0.041 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("ON"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("快速战斗已开启")
                skip := true
            }
            else if (ok := FindText(&X, &Y, NikkeX + 0.393 * NikkeW . " ", NikkeY + 0.815 * NikkeH . " ", NikkeX + 0.393 * NikkeW + 0.081 * NikkeW . " ", NikkeY + 0.815 * NikkeH + 0.041 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("OFF"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("有笨比没开快速战斗，帮忙开了！")
                FindText().Click(X, Y, "L")
            }
        }
        EnterToBattle
        BattleSettlement
        while !(ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
            Confirm
        }
    }
    while (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
        GoBack
        Sleep 1000
    }
    AddLog("已返回竞技场页面")
}
;tag 特殊竞技场
ArenaSpecial() {
    AddLog("开始任务：特殊竞技场", "Fuchsia")
    AddLog("查找特殊竞技场")
    while (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.516 * NikkeW . " ", NikkeY + 0.543 * NikkeH . " ", NikkeX + 0.516 * NikkeW + 0.045 * NikkeW . " ", NikkeY + 0.543 * NikkeH + 0.022 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("蓝色的特殊"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击特殊竞技场")
        FindText().Click(X + 20 * TrueRatio, Y, "L")
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("已进入特殊竞技场")
            break
        }
        if A_Index > 3 {
            AddLog("特殊竞技场未在开放期间，跳过任务")
            return
        }
    }
    AddLog("检测免费次数")
    skip := false
    while True {
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.578 * NikkeW . " ", NikkeY + 0.804 * NikkeH . " ", NikkeX + 0.578 * NikkeW + 0.059 * NikkeW . " ", NikkeY + 0.804 * NikkeH + 0.045 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("免费"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("有免费次数，尝试进入战斗")
            FindText().Click(X, Y + 10 * TrueRatio, "L")
            Sleep 1000
        }
        else {
            AddLog("没有免费次数，尝试返回")
            break
        }
        if skip = false {
            Sleep 1000
            if (ok := FindText(&X, &Y, NikkeX + 0.393 * NikkeW . " ", NikkeY + 0.815 * NikkeH . " ", NikkeX + 0.393 * NikkeW + 0.081 * NikkeW . " ", NikkeY + 0.815 * NikkeH + 0.041 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("ON"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("快速战斗已开启")
                skip := true
            }
            else if (ok := FindText(&X, &Y, NikkeX + 0.393 * NikkeW . " ", NikkeY + 0.815 * NikkeH . " ", NikkeX + 0.393 * NikkeW + 0.081 * NikkeW . " ", NikkeY + 0.815 * NikkeH + 0.041 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("OFF"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("有笨比没开快速战斗，帮忙开了！")
                FindText().Click(X, Y, "L")
            }
        }
        EnterToBattle
        BattleSettlement
        while !(ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
            Confirm
        }
    }
    while (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
        GoBack
        Sleep 1000
    }
    AddLog("已返回竞技场页面")
}
;tag 冠军竞技场
ArenaChampion() {
    AddLog("开始任务：冠军竞技场", "Fuchsia")
    AddLog("查找冠军竞技场")
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.567 * NikkeW . " ", NikkeY + 0.621 * NikkeH . " ", NikkeX + 0.567 * NikkeW + 0.075 * NikkeW . " ", NikkeY + 0.621 * NikkeH + 0.047 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        AddLog("已找到红点")
        Sleep 1000
    }
    else {
        AddLog("未在应援期间")
        GoBack
        return
    }
    while (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.373 * NikkeW . " ", NikkeY + 0.727 * NikkeH . " ", NikkeX + 0.373 * NikkeW + 0.255 * NikkeW . " ", NikkeY + 0.727 * NikkeH + 0.035 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("内部的紫色应援"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("已找到二级应援文本")
        FindText().Click(X, Y - 200 * TrueRatio, "L")
        Sleep 1000
    }
    else {
        AddLog("未在应援期间")
        GoBack
        Sleep 2000
        return
    }
    while !(ok := FindText(&X, &Y, NikkeX + 0.443 * NikkeW . " ", NikkeY + 0.869 * NikkeH . " ", NikkeX + 0.443 * NikkeW + 0.117 * NikkeW . " ", NikkeY + 0.869 * NikkeH + 0.059 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("晋级赛内部的应援"), , , , , , , TrueRatio, TrueRatio)) {
        Confirm
        Sleep 1000
        if A_Index > 10 {
            AddLog("无法应援", "red")
            GoBack
            Sleep 2000
            return
        }
    }
    AddLog("已找到三级应援文本")
    FindText().Click(X, Y, "L")
    Sleep 4000
    if UserCheckColor([1926], [1020], ["0xF2762B"], TrueRatio) {
        AddLog("左边支持的人多")
        UserClick(1631, 1104, TrueRatio)
    }
    else {
        AddLog("右边支持的人多")
        UserClick(2097, 1096, TrueRatio)
    }
    Sleep 1000
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.503 * NikkeW . " ", NikkeY + 0.837 * NikkeH . " ", NikkeX + 0.503 * NikkeW + 0.096 * NikkeW . " ", NikkeY + 0.837 * NikkeH + 0.058 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    loop 2 {
        GoBack
        Sleep 2000
    }
}
;endregion 竞技场
;region 无限之塔
;tag 企业塔
TowerCompany() {
    EnterToArk
    AddLog("开始任务：企业塔", "Fuchsia")
    while (ok := FindText(&X, &Y, NikkeX + 0.539 * NikkeW . " ", NikkeY + 0.373 * NikkeH . " ", NikkeX + 0.539 * NikkeW + 0.066 * NikkeW . " ", NikkeY + 0.373 * NikkeH + 0.031 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("无限之塔的无限"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("进入无限之塔")
        FindText().Click(X, Y - 50 * TrueRatio, "L")
    }
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("已进入无限之塔")
        Sleep 1000
    }
    else {
        AddLog("进入无限之塔失败，跳过任务")
        return
    }
    TowerArray := []
    loop 4 {
        if (ok := FindText(&X, &Y, NikkeX + 0.356 * NikkeW + 270 * TrueRatio * (A_Index - 1) . " ", NikkeY + 0.521 * NikkeH . " ", NikkeX + 0.356 * NikkeW + 0.070 * NikkeW + 270 * TrueRatio * (A_Index - 1) . " ", NikkeY + 0.521 * NikkeH + 0.034 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("无限之塔·OPEN"), , , , , , , TrueRatio, TrueRatio)) {
            Status := "开放中"
        }
        else Status := "未开放"
        switch A_Index {
            case 1: Tower := "极乐净土之塔"
            case 2: Tower := "米西利斯之塔"
            case 3: Tower := "泰特拉之塔"
            case 4: Tower := "朝圣者/超标准之塔"
        }
        if Status = "开放中" {
            TowerArray.Push(Tower)
            AddLog(Tower "-" Status, "Green")
        }
        else AddLog(Tower "-" Status, "Gray")
    }
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.357 * NikkeW . " ", NikkeY + 0.518 * NikkeH . " ", NikkeX + 0.357 * NikkeW + 0.287 * NikkeW . " ", NikkeY + 0.518 * NikkeH + 0.060 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("无限之塔·OPEN"), , , , , , 1, TrueRatio, TrueRatio)) {
        count := ok.Length
        Sleep 1000
        FindText().Click(X, Y + 100 * TrueRatio, "L")
        Sleep 1000
        ; 添加变量跟踪当前关卡
        TowerIndex := 1
        ; 修改循环条件
        while (TowerIndex <= count) {
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.426 * NikkeW . " ", NikkeY + 0.405 * NikkeH . " ", NikkeX + 0.426 * NikkeW + 0.025 * NikkeW . " ", NikkeY + 0.405 * NikkeH + 0.024 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("STAGE"), , , , , , , TrueRatio, TrueRatio)) {
                Tower := TowerArray[TowerIndex]
                AddLog("已进入" Tower "的内部")
                Sleep 1000
                FindText().Click(X + 100 * TrueRatio, Y, "L")
                EnterToBattle
                BattleSettlement
                ; 成功完成当前关卡后，才增加索引
                TowerIndex++
            }
            else {
                RefuseSale
            }
            ; 检查是否已完成所有关卡
            if (TowerIndex > count) {
                break
            }
            ; 点向右的箭头进入下一关
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.569 * NikkeW . " ", NikkeY + 0.833 * NikkeH . " ", NikkeX + 0.569 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.833 * NikkeH + 0.069 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("无限之塔·向右的箭头"), , , , , , , TrueRatio, TrueRatio)) {
                Sleep 3000
                FindText().Click(X, Y, "L")
            }
            Sleep 1000
        }
        AddLog("所有塔都打过了")
    }
    loop 2 {
        GoBack
        Sleep 2000
    }
}
;tag 通用塔
TowerUniversal() {
    EnterToArk
    AddLog("开始任务：通用塔", "Fuchsia")
    while (ok := FindText(&X, &Y, NikkeX + 0.539 * NikkeW . " ", NikkeY + 0.373 * NikkeH . " ", NikkeX + 0.539 * NikkeW + 0.066 * NikkeW . " ", NikkeY + 0.373 * NikkeH + 0.031 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("无限之塔的无限"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("进入无限之塔")
        FindText().Click(X, Y - 50 * TrueRatio, "L")
    }
    while (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.548 * NikkeW . " ", NikkeY + 0.312 * NikkeH . " ", NikkeX + 0.548 * NikkeW + 0.096 * NikkeW . " ", NikkeY + 0.312 * NikkeH + 0.172 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("塔内的无限之塔"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击塔内的无限之塔")
        FindText().Click(X, Y, "L")
    }
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.426 * NikkeW . " ", NikkeY + 0.405 * NikkeH . " ", NikkeX + 0.426 * NikkeW + 0.025 * NikkeW . " ", NikkeY + 0.405 * NikkeH + 0.024 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("STAGE"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("已进入塔的内部")
        FindText().Click(X + 100 * TrueRatio, Y, "L")
        EnterToBattle
        BattleSettlement
        ; 点向右的箭头
        if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.569 * NikkeW . " ", NikkeY + 0.833 * NikkeH . " ", NikkeX + 0.569 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.833 * NikkeH + 0.069 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("无限之塔·向右的箭头"), , , , , , , TrueRatio, TrueRatio)) {
            Sleep 3000
            FindText().Click(X, Y, "L")
        }
        ; 循环等待箭头消失或处理广告
        while true {
            if (ok := FindText(&X := "wait0", &Y := 3, NikkeX + 0.569 * NikkeW . " ", NikkeY + 0.833 * NikkeH . " ", NikkeX + 0.569 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.833 * NikkeH + 0.069 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("无限之塔·向右的箭头"), , , , , , , TrueRatio, TrueRatio)) {
                break
            }
            RefuseSale
            Sleep 1000
            if (ok := FindText(&X, &Y, NikkeX + 0.569 * NikkeW . " ", NikkeY + 0.833 * NikkeH . " ", NikkeX + 0.569 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.833 * NikkeH + 0.069 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("无限之塔·向右的箭头"), , , , , , , TrueRatio, TrueRatio)) {
                Sleep 3000
                FindText().Click(X, Y, "L")
            }
        }
    }
}
;endregion 无限之塔
;region 拦截战
;tag 异常拦截
InterceptionAnomaly() {
    EnterToArk
    AddLog("开始任务：异常拦截", "Fuchsia")
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.401 * NikkeW . " ", NikkeY + 0.813 * NikkeH . " ", NikkeX + 0.401 * NikkeW + 0.069 * NikkeW . " ", NikkeY + 0.813 * NikkeH + 0.028 * NikkeH . " ", 0.45 * PicTolerance, 0.45 * PicTolerance, FindText().PicLib("拦截战"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("进入拦截战")
        FindText().Click(X, Y - 50 * TrueRatio, "L")
        Sleep 1000
    }
    Confirm
    while !(ok := FindText(&X, &Y, NikkeX + 0.580 * NikkeW . " ", NikkeY + 0.956 * NikkeH . " ", NikkeX + 0.580 * NikkeW + 0.074 * NikkeW . " ", NikkeY + 0.956 * NikkeH + 0.027 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红字的异常"), , , , , , , TrueRatio, TrueRatio)) {
        Confirm
        if A_Index > 20 {
            MsgBox("异常个体拦截战未解锁！本脚本暂不支持普通拦截！")
            Pause
        }
    }
    AddLog("已进入异常拦截界面")
    loop 5 {
        t := A_Index
        switch g_numeric_settings["InterceptionBoss"] {
            case 1:
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.438 * NikkeW . " ", NikkeY + 0.723 * NikkeH . " ", NikkeX + 0.438 * NikkeW + 0.119 * NikkeW . " ", NikkeY + 0.723 * NikkeH + 0.061 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("克拉肯的克"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("已选择BOSS克拉肯")
                    break
                }
            case 2:
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.438 * NikkeW . " ", NikkeY + 0.723 * NikkeH . " ", NikkeX + 0.438 * NikkeW + 0.119 * NikkeW . " ", NikkeY + 0.723 * NikkeH + 0.061 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("镜像容器的镜"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("已选择BOSS镜像容器")
                    break
                }
            case 3:
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.438 * NikkeW . " ", NikkeY + 0.723 * NikkeH . " ", NikkeX + 0.438 * NikkeW + 0.119 * NikkeW . " ", NikkeY + 0.723 * NikkeH + 0.061 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("茵迪维利亚的茵"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("已选择BOSS茵迪维利亚")
                    break
                }
            case 4:
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.438 * NikkeW . " ", NikkeY + 0.723 * NikkeH . " ", NikkeX + 0.438 * NikkeW + 0.119 * NikkeW . " ", NikkeY + 0.723 * NikkeH + 0.061 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("过激派的过"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("已选择BOSS过激派")
                    break
                }
            case 5:
                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.438 * NikkeW . " ", NikkeY + 0.723 * NikkeH . " ", NikkeX + 0.438 * NikkeW + 0.119 * NikkeW . " ", NikkeY + 0.723 * NikkeH + 0.061 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("死神的死"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("已选择BOSS死神")
                    break
                }
            default:
                MsgBox "BOSS选择错误！"
                Pause
        }
        AddLog("非对应BOSS，尝试切换")
        if (ok := FindText(&X, &Y, NikkeX + 0.584 * NikkeW . " ", NikkeY + 0.730 * NikkeH . " ", NikkeX + 0.584 * NikkeW + 0.023 * NikkeW . " ", NikkeY + 0.730 * NikkeH + 0.039 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("异常拦截·向右的箭头"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X + 10 * TrueRatio, Y, "L")
        }
        Sleep 500
    }
    FindText().Click(X, Y + 100 * TrueRatio, "L")
    Sleep 500
    Confirm
    if t > 1 {
        Sleep 2000
        switch g_numeric_settings["InterceptionBoss"] {
            case 1:
                UserClick(1858, 1470, TrueRatio)
                AddLog("选中队伍1")
            case 2:
                UserClick(2014, 1476, TrueRatio)
                AddLog("选中队伍2")
            case 3:
                UserClick(2140, 1482, TrueRatio)
                AddLog("选中队伍3")
            case 4:
                UserClick(2276, 1446, TrueRatio)
                AddLog("选中队伍4")
            case 5:
                UserClick(2414, 1474, TrueRatio)
                AddLog("选中队伍5")
            default:
                MsgBox "BOSS选择错误！"
                Pause
        }
    }
    Sleep 1000
    while True {
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.506 * NikkeW . " ", NikkeY + 0.826 * NikkeH . " ", NikkeX + 0.506 * NikkeW + 0.145 * NikkeW . " ", NikkeY + 0.826 * NikkeH + 0.065 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("拦截战·快速战斗的图标"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("已激活快速战斗")
            Sleep 500
            FindText().Click(X + 50 * TrueRatio, Y, "L")
            Sleep 500
            FindText().Click(X + 50 * TrueRatio, Y, "L")
            Sleep 500
        }
        else if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.503 * NikkeW . " ", NikkeY + 0.879 * NikkeH . " ", NikkeX + 0.503 * NikkeW + 0.150 * NikkeW . " ", NikkeY + 0.879 * NikkeH + 0.102 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("拦截战·进入战斗的进"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("未激活快速战斗，尝试普通战斗")
            FindText().Click(X, Y, "L")
            Sleep 1000
            Skipping
        }
        else {
            AddLog("异常拦截次数已耗尽")
            break
        }
        modes := []
        if g_settings["InterceptionRedCircle"]
            modes.Push("RedCircle")
        if g_settings["InterceptionScreenshot"]
            modes.Push("Screenshot")
        if g_settings["InterceptionExit7"] and UserLevel >= 3
            modes.Push("Exit7")
        global BattleActive := 1
        if g_settings["InterceptionRedCircle"] or g_settings["InterceptionExit7"] {
            AddLog("有概率误判，请谨慎开启该功能")
        }
        BattleSettlement(modes*)  ; 使用*展开数组为多个参数
        Sleep 2000
    }
}
;endregion 拦截战
;region 前哨基地
;tag 前哨基地收菜
AwardOutpost() {
    AddLog("开始任务：前哨基地收菜", "Fuchsia")
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.240 * NikkeW . " ", NikkeY + 0.755 * NikkeH . " ", NikkeX + 0.240 * NikkeW + 0.048 * NikkeW . " ", NikkeY + 0.755 * NikkeH + 0.061 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("前哨基地的图标"), , , , , , , TrueRatio, TrueRatio)) {
        while (ok := FindText(&X, &Y, NikkeX + 0.240 * NikkeW . " ", NikkeY + 0.755 * NikkeH . " ", NikkeX + 0.240 * NikkeW + 0.048 * NikkeW . " ", NikkeY + 0.755 * NikkeH + 0.061 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("前哨基地的图标"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击进入前哨基地")
            FindText().Click(X, Y, "L")
            Sleep 1000
        }
    }
    else {
        AddLog("未找到前哨基地！")
        return
    }
    while true {
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.884 * NikkeW . " ", NikkeY + 0.904 * NikkeH . " ", NikkeX + 0.884 * NikkeW + 0.114 * NikkeW . " ", NikkeY + 0.904 * NikkeH + 0.079 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("溢出资源的图标"), , , , , , , TrueRatio, TrueRatio)) {
            Sleep 1000
            AddLog("点击右下角资源")
            FindText().Click(X, Y, "L")
            Sleep 1000
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.527 * NikkeW . " ", NikkeY + 0.832 * NikkeH . " ", NikkeX + 0.527 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.832 * NikkeH + 0.041 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("获得奖励的图标"), , , , , , , TrueRatio, TrueRatio)) {
            break
        }
    }
    if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.490 * NikkeW . " ", NikkeY + 0.820 * NikkeH . " ", NikkeX + 0.490 * NikkeW + 0.010 * NikkeW . " ", NikkeY + 0.820 * NikkeH + 0.017 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        while (ok := FindText(&X, &Y, NikkeX + 0.490 * NikkeW . " ", NikkeY + 0.820 * NikkeH . " ", NikkeX + 0.490 * NikkeW + 0.010 * NikkeW . " ", NikkeY + 0.820 * NikkeH + 0.017 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X - 50 * TrueRatio, Y + 50 * TrueRatio, "L")
            AddLog("点击免费歼灭红点")
            Sleep 1000
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.465 * NikkeW . " ", NikkeY + 0.738 * NikkeH . " ", NikkeX + 0.465 * NikkeW + 0.163 * NikkeW . " ", NikkeY + 0.738 * NikkeH + 0.056 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("进行歼灭的歼灭"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击进行免费一举歼灭")
            FindText().Click(X, Y, "L")
            Sleep 1000
            while !(ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.503 * NikkeW . " ", NikkeY + 0.825 * NikkeH . " ", NikkeX + 0.503 * NikkeW + 0.121 * NikkeW . " ", NikkeY + 0.825 * NikkeH + 0.059 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("获得奖励的图标"), , , , , , , TrueRatio, TrueRatio)) {
                Confirm
                Sleep 1000
            }
        }
    }
    else AddLog("没有免费一举歼灭")
    AddLog("尝试常规收菜")
    if (ok := FindText(&X, &Y, NikkeX + 0.503 * NikkeW . " ", NikkeY + 0.825 * NikkeH . " ", NikkeX + 0.503 * NikkeW + 0.121 * NikkeW . " ", NikkeY + 0.825 * NikkeH + 0.059 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("获得奖励的图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击收菜")
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    else AddLog("没有可收取的资源")
    AddLog("尝试返回前哨基地主页面")
    while !(ok := FindText(&X, &Y, NikkeX + 0.884 * NikkeW . " ", NikkeY + 0.904 * NikkeH . " ", NikkeX + 0.884 * NikkeW + 0.114 * NikkeW . " ", NikkeY + 0.904 * NikkeH + 0.079 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("溢出资源的图标"), , , , , , , TrueRatio, TrueRatio)) {
        Confirm
    }
    AddLog("已返回前哨基地主页面")
    if g_settings["AwardOutpostExpedition"] ;派遣
        AwardOutpostExpedition()
    BackToHall(True)
}
;tag 派遣
AwardOutpostExpedition() {
    AddLog("开始任务：派遣委托", "Fuchsia")
    AddLog("查找派遣公告栏")
    if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.500 * NikkeW . " ", NikkeY + 0.901 * NikkeH . " ", NikkeX + 0.500 * NikkeW + 0.045 * NikkeW . " ", NikkeY + 0.901 * NikkeH + 0.092 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("派遣公告栏的图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击派遣公告栏")
        FindText().Click(X, Y, "L")
        Sleep 1000
        while (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.547 * NikkeW . " ", NikkeY + 0.807 * NikkeH . " ", NikkeX + 0.547 * NikkeW + 0.087 * NikkeW . " ", NikkeY + 0.807 * NikkeH + 0.066 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("获得奖励的图标"), , , , , , , TrueRatio * 0.8, TrueRatio * 0.8)) {
            AddLog("点击全部领取")
            FindText().Click(X + 100 * TrueRatio, Y, "L")
        }
        else AddLog("没有可领取的奖励")
        while !(ok := FindText(&X, &Y, NikkeX + 0.378 * NikkeW . " ", NikkeY + 0.137 * NikkeH . " ", NikkeX + 0.378 * NikkeW + 0.085 * NikkeW . " ", NikkeY + 0.137 * NikkeH + 0.040 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("派遣公告栏最左上角的派遣"), , , , , , , TrueRatio, TrueRatio)) {
            UserClick(1595, 1806, TrueRatio)
            Sleep 500
        }
        if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.456 * NikkeW . " ", NikkeY + 0.807 * NikkeH . " ", NikkeX + 0.456 * NikkeW + 0.087 * NikkeW . " ", NikkeY + 0.807 * NikkeH + 0.064 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("蓝底白色右箭头"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("尝试全部派遣")
            FindText().Click(X, Y, "L")
            Sleep 1000
        }
        else AddLog("没有可进行的派遣")
        if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.501 * NikkeW . " ", NikkeY + 0.814 * NikkeH . " ", NikkeX + 0.501 * NikkeW + 0.092 * NikkeW . " ", NikkeY + 0.814 * NikkeH + 0.059 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("白底蓝色右箭头"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击全部派遣")
            FindText().Click(X, Y, "L")
            Sleep 1000
        }
    }
    else AddLog("派遣公告栏未找到！")
}
;endregion 前哨基地
;region 咨询
;tag 好感度咨询
AwardLoveTalking() {
    while !(ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.009 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.069 * NikkeW . " ", NikkeY + 0.009 * NikkeH + 0.050 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , , , , , , TrueRatio, TrueRatio)) {
        UserClick(1493, 1949, TrueRatio)
        AddLog("点击妮姬的图标，进入好感度咨询")
    }
    Sleep 2000
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.818 * NikkeW . " ", NikkeY + 0.089 * NikkeH . " ", NikkeX + 0.818 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.089 * NikkeH + 0.056 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("咨询的图标"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
        if A_Index > 10 {
            MsgBox("未找到好感度咨询图标")
            Pause
        }
    }
    AddLog("已进入好感度咨询界面")
    ; 花絮鉴赏会
    if g_settings["AwardAppreciation"] {
        AwardAppreciation
    }
    while (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.118 * NikkeW . " ", NikkeY + 0.356 * NikkeH . " ", NikkeX + 0.118 * NikkeW + 0.021 * NikkeW . " ", NikkeY + 0.356 * NikkeH + 0.022 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("》》》"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X + 50 * TrueRatio, Y, "L")
        AddLog("点击左上角的妮姬")
        Sleep 500
    }
    AddLog("开始任务：妮姬咨询", "Fuchsia")
    while true {
        if (ok := FindText(&X, &Y, NikkeX + 0.572 * NikkeW . " ", NikkeY + 0.835 * NikkeH . " ", NikkeX + 0.572 * NikkeW + 0.008 * NikkeW . " ", NikkeY + 0.835 * NikkeH + 0.013 * NikkeH . " ", 0.25 * PicTolerance, 0.25 * PicTolerance, FindText().PicLib("灰色的咨询次数0"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("咨询次数已耗尽")
            break
        }
        if A_Index > 20 {
            AddLog("妮姬咨询任务已超过20次，结束任务")
            break
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.637 * NikkeW . " ", NikkeY + 0.672 * NikkeH . " ", NikkeX + 0.637 * NikkeW + 0.004 * NikkeW . " ", NikkeY + 0.672 * NikkeH + 0.013 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红色的20进度"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("图鉴已满")
            if (ok := FindText(&X, &Y, NikkeX + 0.541 * NikkeW . " ", NikkeY + 0.637 * NikkeH . " ", NikkeX + 0.541 * NikkeW + 0.030 * NikkeW . " ", NikkeY + 0.637 * NikkeH + 0.028 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("咨询·MAX"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("好感度也已满，跳过")
                if (ok := FindText(&X, &Y, NikkeX + 0.361 * NikkeW . " ", NikkeY + 0.512 * NikkeH . " ", NikkeX + 0.361 * NikkeW + 0.026 * NikkeW . " ", NikkeY + 0.512 * NikkeH + 0.046 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("红色的收藏图标"), , , , , , , TrueRatio, TrueRatio)) {
                    FindText().Click(X, Y, "L")
                    AddLog("取消收藏该妮姬")
                }
            }
            else if (ok := FindText(&X, &Y, NikkeX + 0.501 * NikkeW . " ", NikkeY + 0.726 * NikkeH . " ", NikkeX + 0.501 * NikkeW + 0.130 * NikkeW . " ", NikkeY + 0.726 * NikkeH + 0.059 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("快速咨询的图标"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("尝试快速咨询")
                FindText().Click(X, Y, "L")
                Sleep 1000
                if (ok := FindText(&X, &Y, NikkeX + 0.506 * NikkeW . " ", NikkeY + 0.600 * NikkeH . " ", NikkeX + 0.506 * NikkeW + 0.125 * NikkeW . " ", NikkeY + 0.600 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                    FindText().Click(X, Y, "L")
                    AddLog("已咨询" A_Index "次")
                    Sleep 1000
                }
            }
            else AddLog("该妮姬已咨询")
        }
        else {
            AddLog("图鉴未满")
            if (ok := FindText(&X, &Y, NikkeX + 0.502 * NikkeW . " ", NikkeY + 0.780 * NikkeH . " ", NikkeX + 0.502 * NikkeW + 0.131 * NikkeW . " ", NikkeY + 0.780 * NikkeH + 0.088 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("咨询的咨"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("尝试普通咨询")
                FindText().Click(X + 50 * TrueRatio, Y, "L")
                Sleep 1000
                if (ok := FindText(&X, &Y, NikkeX + 0.506 * NikkeW . " ", NikkeY + 0.600 * NikkeH . " ", NikkeX + 0.506 * NikkeW + 0.125 * NikkeW . " ", NikkeY + 0.600 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                    AddLog("已咨询" A_Index "次")
                }
                Sleep 1000
                while true {
                    AddLog("随机点击对话框")
                    UserClick(1894, 1440, TrueRatio) ;点击1号位默认位置
                    Sleep 200
                    UserClick(1903, 1615, TrueRatio) ;点击2号位默认位置
                    Sleep 200
                    Send "{]}" ;尝试跳过
                    Sleep 200
                    if A_Index > 5 and (ok := FindText(&X, &Y, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.009 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.069 * NikkeW . " ", NikkeY + 0.009 * NikkeH + 0.050 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , , , , , , TrueRatio, TrueRatio)) {
                        break
                    }
                }
                Sleep 1000
            }
            else {
                AddLog("该妮姬已咨询")
            }
        }
        while !(ok := FindText(&X, &Y, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.009 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.069 * NikkeW . " ", NikkeY + 0.009 * NikkeH + 0.050 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("确认咨询结算")
            Confirm
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.970 * NikkeW . " ", NikkeY + 0.403 * NikkeH . " ", NikkeX + 0.970 * NikkeW + 0.024 * NikkeW . " ", NikkeY + 0.403 * NikkeH + 0.067 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("咨询·向右的图标"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("下一个妮姬")
            FindText().Click(X - 30 * TrueRatio, Y, "L")
            Sleep 1000
        }
    }
    BackToHall
}
;tag 花絮鉴赏
AwardAppreciation() {
    AddLog("开始任务：花絮鉴赏", "Fuchsia")
    Sleep 1000
    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.979 * NikkeW . " ", NikkeY + 0.903 * NikkeH . " ", NikkeX + 0.979 * NikkeW + 0.020 * NikkeW . " ", NikkeY + 0.903 * NikkeH + 0.034 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红底的N图标"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X - 50 * TrueRatio, Y + 50 * TrueRatio, "L")
        AddLog("点击花絮")
    }
    else {
        AddLog("未找到花絮鉴赏的N图标")
        return
    }
    while (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.363 * NikkeW . " ", NikkeY + 0.550 * NikkeH . " ", NikkeX + 0.363 * NikkeW + 0.270 * NikkeW . " ", NikkeY + 0.550 * NikkeH + 0.316 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("EPI"), , , , , , 1, TrueRatio, TrueRatio)) {
        AddLog("播放第一个片段")
        FindText().Click(X, Y, "L")
    }
    while true {
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.559 * NikkeW . " ", NikkeY + 0.893 * NikkeH . " ", NikkeX + 0.559 * NikkeW + 0.070 * NikkeW . " ", NikkeY + 0.893 * NikkeH + 0.062 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("领取"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("领取奖励")
            FindText().Click(X, Y, "L")
            sleep 500
            FindText().Click(X, Y, "L")
            sleep 500
            FindText().Click(X, Y, "L")
            sleep 500
            break
        }
        else {
            AddLog("播放下一个片段")
            Send "{]}" ;尝试跳过
            if (ok := FindText(&X, &Y, NikkeX + 0.499 * NikkeW . " ", NikkeY + 0.513 * NikkeH . " ", NikkeX + 0.499 * NikkeW + 0.140 * NikkeW . " ", NikkeY + 0.513 * NikkeH + 0.072 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("播放"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
            }
        }
    }
    while !(ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.118 * NikkeW . " ", NikkeY + 0.356 * NikkeH . " ", NikkeX + 0.118 * NikkeW + 0.021 * NikkeW . " ", NikkeY + 0.356 * NikkeH + 0.022 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("》》》"), , , , , , , TrueRatio, TrueRatio)) {
        Confirm
    }
}
;endregion 咨询
;region 好友点数收取
AwardFriendPoint() {
    AddLog("开始任务：好友点数", "Fuchsia")
    while (ok := FindText(&X, &Y, NikkeX + 0.956 * NikkeW . " ", NikkeY + 0.211 * NikkeH . " ", NikkeX + 0.956 * NikkeW + 0.033 * NikkeW . " ", NikkeY + 0.211 * NikkeH + 0.068 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("好友的图标"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击好友")
        FindText().Click(X, Y, "L")
        Sleep 2000
    }
    while (ok := FindText(&X, &Y, NikkeX + 0.628 * NikkeW . " ", NikkeY + 0.822 * NikkeH . " ", NikkeX + 0.628 * NikkeW + 0.010 * NikkeW . " ", NikkeY + 0.822 * NikkeH + 0.017 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击赠送")
        FindText().Click(X - 50 * TrueRatio, Y + 50 * TrueRatio, "L")
        Sleep 2000
    }
    else {
        AddLog("好友点数已执行")
    }
    BackToHall
}
;endregion 好友点数收取
;region 邮箱收取
AwardMail() {
    AddLog("开始任务：邮箱", "Fuchsia")
    while (ok := FindText(&X, &Y, NikkeX + 0.962 * NikkeW . " ", NikkeY + 0.017 * NikkeH . " ", NikkeX + 0.962 * NikkeW + 0.008 * NikkeW . " ", NikkeY + 0.017 * NikkeH + 0.015 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击邮箱")
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    else {
        AddLog("邮箱已领取")
        return
    }
    while (ok := FindText(&X, &Y, NikkeX + 0.519 * NikkeW . " ", NikkeY + 0.817 * NikkeH . " ", NikkeX + 0.519 * NikkeW + 0.110 * NikkeW . " ", NikkeY + 0.817 * NikkeH + 0.063 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("白底蓝色右箭头"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("点击全部领取")
        FindText().Click(X + 50 * TrueRatio, Y, "L")
        Sleep 2000
    }
    BackToHall
}
;endregion 邮箱收取
;region 方舟排名奖励
;tag 排名奖励
AwardRanking() {
    AddLog("开始任务：方舟排名奖励", "Fuchsia")
    EnterToArk()
    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.979 * NikkeW . " ", NikkeY + 0.138 * NikkeH . " ", NikkeX + 0.979 * NikkeW + 0.010 * NikkeW . " ", NikkeY + 0.138 * NikkeH + 0.018 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X - 30 * TrueRatio, Y + 30 * TrueRatio, "L")
    }
    else {
        AddLog("没有可领取的排名奖励，跳过")
        BackToHall
        return
    }
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.909 * NikkeW . " ", NikkeY + 0.915 * NikkeH . " ", NikkeX + 0.909 * NikkeW + 0.084 * NikkeW . " ", NikkeY + 0.915 * NikkeH + 0.056 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("获得奖励的图标"), , , , , , , TrueRatio * 0.8, TrueRatio * 0.8)) {
        Sleep 1000
        AddLog("点击全部领取")
        FindText().Click(X, Y - 30 * TrueRatio, "L")
        Sleep 1000
    }
    BackToHall
}
;endregion 方舟排名奖励
;region 每日任务收取
AwardDaily() {
    AddLog("开始任务：每日任务收取", "Fuchsia")
    while (ok := FindText(&X, &Y, NikkeX + 0.874 * NikkeW . " ", NikkeY + 0.073 * NikkeH . " ", NikkeX + 0.874 * NikkeW + 0.011 * NikkeW . " ", NikkeY + 0.073 * NikkeH + 0.019 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        AddLog("点击每日任务图标")
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.466 * NikkeW . " ", NikkeY + 0.093 * NikkeH . " ", NikkeX + 0.466 * NikkeW + 0.068 * NikkeW . " ", NikkeY + 0.093 * NikkeH + 0.035 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("每日任务·MISSION"), , , , , , , TrueRatio, TrueRatio)) {
            while !(ok := FindText(&X, &Y, NikkeX + 0.548 * NikkeW . " ", NikkeY + 0.864 * NikkeH . " ", NikkeX + 0.548 * NikkeW + 0.093 * NikkeW . " ", NikkeY + 0.864 * NikkeH + 0.063 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("灰色的全部"), , , , , , , TrueRatio, TrueRatio)) {
                UserClick(2412, 1905, TrueRatio)
                AddLog("点击全部领取")
                Sleep 2000
            }
            Sleep 1000
            BackToHall
        }
    }
    else {
        AddLog("每日任务奖励已领取")
        return
    }
}
;endregion 每日任务收取
;region 通行证收取
;tag 查找通行证
AwardPass() {
    AddLog("开始任务：通行证", "Fuchsia")
    t := 0
    while true {
        if (ok := FindText(&X, &Y, NikkeX + 0.879 * NikkeW . " ", NikkeY + 0.150 * NikkeH . " ", NikkeX + 0.879 * NikkeW + 0.019 * NikkeW . " ", NikkeY + 0.150 * NikkeH + 0.037 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("通行证·3+"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("3+通行证模式")
            FindText().Click(X, Y, "L")
            Sleep 1000
            ; 检查红点并执行通行证
            if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.985 * NikkeW . " ", NikkeY + 0.124 * NikkeH . " ", NikkeX + 0.985 * NikkeW + 0.015 * NikkeW . " ", NikkeY + 0.124 * NikkeH + 0.261 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X - 50 * TrueRatio, Y + 50 * TrueRatio, "L")
                if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.553 * NikkeW . " ", NikkeY + 0.227 * NikkeH . " ", NikkeX + 0.553 * NikkeW + 0.090 * NikkeW . " ", NikkeY + 0.227 * NikkeH + 0.051 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("购买PASS的图标"), , , , , , , TrueRatio, TrueRatio)) {
                    t := t + 1
                    AddLog("执行第" t "个通行证")
                    OneAwardPass()
                }
                BackToHall()
                continue
            }
        }
        else if (ok := FindText(&X, &Y, NikkeX + 0.878 * NikkeW . " ", NikkeY + 0.151 * NikkeH . " ", NikkeX + 0.878 * NikkeW + 0.021 * NikkeW . " ", NikkeY + 0.151 * NikkeH + 0.036 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("通行证·2"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("2通行证模式")
            FindText().Click(X, Y, "L")
            Sleep 1000
        }
        else {
            AddLog("1通行证模式")
        }
        ; 检查红点并执行通行证
        if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.982 * NikkeW . " ", NikkeY + 0.126 * NikkeH . " ", NikkeX + 0.982 * NikkeW + 0.016 * NikkeW . " ", NikkeY + 0.126 * NikkeH + 0.032 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X - 50 * TrueRatio, Y + 50 * TrueRatio, "L")
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.553 * NikkeW . " ", NikkeY + 0.227 * NikkeH . " ", NikkeX + 0.553 * NikkeW + 0.090 * NikkeW . " ", NikkeY + 0.227 * NikkeH + 0.051 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("购买PASS的图标"), , , , , , , TrueRatio, TrueRatio)) {
                t := t + 1
                AddLog("执行第" t "个通行证")
                OneAwardPass()
            }
            BackToHall()
            continue
        }
        ; 检测是否有其他未完成的通行证
        if (ok := FindText(&X, &Y, NikkeX + 0.890 * NikkeW . " ", NikkeY + 0.149 * NikkeH . " ", NikkeX + 0.890 * NikkeW + 0.010 * NikkeW . " ", NikkeY + 0.149 * NikkeH + 0.016 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio * 0.8, TrueRatio * 0.8)) {
            FindText().Click(X, Y, "L")
        }
        else {
            AddLog("通行证已全部收取")
            break
        }
    }
}
;tag 执行一次通行证
OneAwardPass() {
    loop 2 {
        Sleep 2000
        if A_Index = 1 {
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.502 * NikkeW . " ", NikkeY + 0.281 * NikkeH . " ", NikkeX + 0.502 * NikkeW + 0.141 * NikkeW . " ", NikkeY + 0.281 * NikkeH + 0.070 * NikkeH . " ", 0.5 * PicTolerance, 0.5 * PicTolerance, FindText().PicLib("通行证·任务"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                Sleep 1000
            }
        }
        if A_Index = 2 {
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.356 * NikkeW . " ", NikkeY + 0.283 * NikkeH . " ", NikkeX + 0.356 * NikkeW + 0.142 * NikkeW . " ", NikkeY + 0.283 * NikkeH + 0.075 * NikkeH . " ", 0.5 * PicTolerance, 0.5 * PicTolerance, FindText().PicLib("通行证·奖励"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                Sleep 1000
            }
        }
        while !(ok := FindText(&X, &Y, NikkeX + 0.429 * NikkeW . " ", NikkeY + 0.903 * NikkeH . " ", NikkeX + 0.429 * NikkeW + 0.143 * NikkeW . " ", NikkeY + 0.903 * NikkeH + 0.050 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("灰色的全部"), , , , , , , TrueRatio, TrueRatio)) and !(ok := FindText(&X, &Y, NikkeX + 0.429 * NikkeW . " ", NikkeY + 0.903 * NikkeH . " ", NikkeX + 0.429 * NikkeW + 0.143 * NikkeW . " ", NikkeY + 0.903 * NikkeH + 0.050 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("SP灰色的全部"), , , , , , , TrueRatio, TrueRatio)) {
            UserClick(2168, 2020, TrueRatio) ;点领取
            Sleep 1000
        }
    }
    GoBack()
}
;endregion 通行证收取
;region 招募
;tag 每日免费招募
AwardFreeRecruit() {
    AddLog("开始任务：每日免费招募", "Fuchsia")
    Text每天免费 := "|<每天免费>*156$64.wzzzzzbzz9zU0s03w1z00S01U0DU7zmNnzzyTwQzk0601ztzU07Abs07zby00Q00t6S00QttwNna9s01nba3aE01z3z00Q03167wDw03s0DgNzUTz9zbAw03wMzsbSNnk07Xky6Qt0TztsTVUs20kTyDbzbDUMTsU"
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2 * PicTolerance, 0.2 * PicTolerance, Text每天免费, , 0, , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        AddLog("进入招募页面")
        Sleep 1000
        while (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.2 * PicTolerance, 0.2 * PicTolerance, Text每天免费, , 0, , , , , TrueRatio, TrueRatio)) {
            Text每日免费 := "|<每日免费>*122$73.szzs07z3zw00s01w01z07y00A00y00z03zU04TzzDwT3XzU0001zbyD007k0200Dnz7U01s00U07szXkkkw00MlXw01wQwS3W0E0y00y00C1l800D7wT007U04007byDk07s03a6Tnz7z0zwtll07tzXz2TyQss01w01z3DDA0w00y00y3X7UEDz1z00S3k30S3zVzbzDjw3Vzt"
            if (ok := FindText(&X := "wait", &Y := 2, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3 * PicTolerance, 0.3 * PicTolerance, Text每日免费, , 0, , , , , TrueRatio, TrueRatio)) {
                AddLog("进行招募")
                FindText().Click(X, Y, "L")
                Recruit()
            }
            else {
                ;点击翻页
                Sleep 1000
                UserClick(3774, 1147, TrueRatio)
                Sleep 1000
            }
        }
    }
    UserClick(1929, 1982, TrueRatio) ;点击大厅
}
;endregion 招募
;region 协同作战
;tag 协同作战入口
AwardCooperate() {
    AddLog("开始任务：协同作战", "Fuchsia")
    ;把鼠标移动到活动栏
    UserMove(150, 257, TrueRatio)
    while true {
        if (ok := FindText(&X := "wait", &Y := 0.5, NikkeX + 0.005 * NikkeW . " ", NikkeY + 0.074 * NikkeH . " ", NikkeX + 0.005 * NikkeW + 0.124 * NikkeW . " ", NikkeY + 0.074 * NikkeH + 0.088 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("COOP的P"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
            Sleep 500
            break
        }
        else {
            AddLog("尝试滑动左上角的活动栏")
            Send "{WheelDown 3}"
            Sleep 500
        }
        if (A_Index > 15) {
            AddLog("未能找到协同作战")
            return
        }
    }
    AwardCooperateBattle
    BackToHall
}
;tag 协同作战核心
AwardCooperateBattle() {
    while true {
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.851 * NikkeW . " ", NikkeY + 0.750 * NikkeH . " ", NikkeX + 0.851 * NikkeW + 0.134 * NikkeW . " ", NikkeY + 0.750 * NikkeH + 0.068 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("开始匹配的开始"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("开始匹配")
            FindText().Click(X, Y, "L")
            Sleep 500
        }
        else {
            AddLog("协同作战次数已耗尽或未在开放时间")
            return
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.508 * NikkeW . " ", NikkeY + 0.600 * NikkeH . " ", NikkeX + 0.508 * NikkeW + 0.120 * NikkeW . " ", NikkeY + 0.600 * NikkeH + 0.053 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("协同作战次数已耗尽")
            return
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.375 * NikkeW . " ", NikkeY + 0.436 * NikkeH . " ", NikkeX + 0.375 * NikkeW + 0.250 * NikkeW . " ", NikkeY + 0.436 * NikkeH + 0.103 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("普通"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("选择难度")
            FindText().Click(X, Y, "L")
            Sleep 500
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.373 * NikkeW . " ", NikkeY + 0.644 * NikkeH . " ", NikkeX + 0.373 * NikkeW + 0.253 * NikkeW . " ", NikkeY + 0.644 * NikkeH + 0.060 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("确认"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("确认匹配")
            FindText().Click(X, Y, "L")
        }
        while true {
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.511 * NikkeW . " ", NikkeY + 0.660 * NikkeH . " ", NikkeX + 0.511 * NikkeW + 0.106 * NikkeW . " ", NikkeY + 0.660 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
            }
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.444 * NikkeW . " ", NikkeY + 0.915 * NikkeH . " ", NikkeX + 0.444 * NikkeW + 0.112 * NikkeW . " ", NikkeY + 0.915 * NikkeH + 0.052 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("准备"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                break
            }
        }
        BattleSettlement
        sleep 5000
    }
}
;endregion 协同作战
;region 单人突击
AwardSoloRaid(stage7 := True) {
    if stage7 {
        AddLog("开始任务：单人突击", "Fuchsia")
    }
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.172 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.093 * NikkeW . " ", NikkeY + 0.172 * NikkeH + 0.350 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("RAID"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
    } else {
        AddLog("不在单人突击活动时间")
        return
    }
    while !(ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
        Confirm
        if A_Index > 3 {
            AddLog("未能找到单人突击活动")
            return
        }
    }
    Confirm
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.417 * NikkeW . " ", NikkeY + 0.806 * NikkeH . " ", NikkeX + 0.417 * NikkeW + 0.164 * NikkeW . " ", NikkeY + 0.806 * NikkeH + 0.073 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("灰色的挑战"), , , , , , , TrueRatio, TrueRatio)) {
        AddLog("不在单人突击活动时间")
        BackToHall
        return
    }
    if stage7 {
        AddLog("选中第七关")
        UserClick(2270, 231, TrueRatio)
        Sleep 1000
    }
    while True {
        if (ok := FindText(&X, &Y, NikkeX + 0.519 * NikkeW . " ", NikkeY + 0.618 * NikkeH . " ", NikkeX + 0.519 * NikkeW + 0.043 * NikkeW . " ", NikkeY + 0.618 * NikkeH + 0.037 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红色的MODE"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("挑战模式")
            BackToHall
            return
        }
        AddLog("检测快速战斗")
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.504 * NikkeW . " ", NikkeY + 0.728 * NikkeH . " ", NikkeX + 0.504 * NikkeW + 0.144 * NikkeW . " ", NikkeY + 0.728 * NikkeH + 0.074 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("快速战斗的图标"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("快速战斗已激活")
            FindText().Click(X + 50 * TrueRatio, Y, "L")
            Sleep 500
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.553 * NikkeW . " ", NikkeY + 0.683 * NikkeH . " ", NikkeX + 0.553 * NikkeW + 0.036 * NikkeW . " ", NikkeY + 0.683 * NikkeH + 0.040 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("MAX"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                Sleep 1000
            }
            if (ok := FindText(&X, &Y, NikkeX + 0.470 * NikkeW . " ", NikkeY + 0.733 * NikkeH . " ", NikkeX + 0.470 * NikkeW + 0.157 * NikkeW . " ", NikkeY + 0.733 * NikkeH + 0.073 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("进行战斗的进"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                BattleActive := 1
                Sleep 1000
            }
            BattleSettlement
            BackToHall
            return
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.413 * NikkeW . " ", NikkeY + 0.800 * NikkeH . " ", NikkeX + 0.413 * NikkeW + 0.176 * NikkeW . " ", NikkeY + 0.800 * NikkeH + 0.085 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("单人突击·挑战"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("快速战斗未激活，尝试普通战斗")
            FindText().Click(X, Y, "L")
            Sleep 1000
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.518 * NikkeW . " ", NikkeY + 0.609 * NikkeH . " ", NikkeX + 0.518 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.609 * NikkeH + 0.033 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                Sleep 1000
            }
            if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.512 * NikkeW . " ", NikkeY + 0.818 * NikkeH . " ", NikkeX + 0.512 * NikkeW + 0.142 * NikkeW . " ", NikkeY + 0.818 * NikkeH + 0.086 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("个人突击·进入战斗的进"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                Sleep 1000
                Skipping
                if BattleSettlement() = false {
                    AddLog("战斗结算失败，尝试返回大厅", "red")
                    BackToHall
                    return
                }
                sleep 5000
                while !(ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
                    Confirm
                }
            }
        }
        if stage7 {
            AddLog("第七关未开放")
            BackToHall
            AwardSoloRaid(stage7 := false)
            return
        }
        if !(ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.413 * NikkeW . " ", NikkeY + 0.800 * NikkeH . " ", NikkeX + 0.413 * NikkeW + 0.176 * NikkeW . " ", NikkeY + 0.800 * NikkeH + 0.085 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("单人突击·挑战"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("已无挑战次数，返回")
            BackToHall
            return
        }
    }
}
;endregion 单人突击
;region 小活动
EventSmall() {
    ; UserClick(2640, 1810, TrueRatio)
    ; Sleep 5000
    while true {
        if (ok := FindText(&X, &Y, NikkeX + 0.681 * NikkeW . " ", NikkeY + 0.748 * NikkeH . " ", NikkeX + 0.681 * NikkeW + 0.075 * NikkeW . " ", NikkeY + 0.748 * NikkeH + 0.057 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("作战出击的击"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y + 200 * TrueRatio, "L")
            if (ok := FindText(&X := "wait0", &Y := 3, NikkeX + 0.681 * NikkeW . " ", NikkeY + 0.748 * NikkeH . " ", NikkeX + 0.681 * NikkeW + 0.075 * NikkeW . " ", NikkeY + 0.748 * NikkeH + 0.057 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("作战出击的击"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("已进入小活动")
                Sleep 1000
                Confirm
                Sleep 1000
                break
            }
            else {
                AddLog("未找到小活动，可能是活动已结束或已完成或有新剧情")
                return
            }
        }
    }
    AddLog("开始任务：小活动", "Fuchsia")
    ;tag 挑战
    if g_settings["EventSmallChallenge"] {
        AddLog("开始任务：小活动·挑战", "Fuchsia")
        while true {
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.367 * NikkeW . " ", NikkeY + 0.776 * NikkeH . " ", NikkeX + 0.367 * NikkeW + 0.132 * NikkeW . " ", NikkeY + 0.776 * NikkeH + 0.069 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("小活动·挑战"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                ; 挑战
                Challenge
                break
            }
            if A_Index > 5 {
                MsgBox("未找到小活动挑战")
                Pause
            }
            sleep 1000
            Confirm
        }
        while (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("圈中的感叹号"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("尝试返回活动主页面")
            GoBack
            Sleep 1000
        }
        AddLog("已返回活动主页面")
    }
    ;tag 剧情活动
    if g_settings["EventSmallStory"] {
        AddLog("开始任务：小活动·剧情活动", "Fuchsia")
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.465 * NikkeW . " ", NikkeY + 0.740 * NikkeH . " ", NikkeX + 0.465 * NikkeW + 0.016 * NikkeW . " ", NikkeY + 0.740 * NikkeH + 0.029 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("小活动·放大镜的图标"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("尝试进入对应活动页")
            FindText().Click(X, Y - 100 * TrueRatio, "L")
            Sleep 500
        }
        Sleep 1000
        Confirm
        AdvanceMode("小活动·关卡图标", "小活动·关卡图标2")
        Sleep 1000
        GoBack
    }
    ;tag 任务
    if g_settings["EventSmallMission"] {
        AddLog("开始任务：小活动·任务领取", "Fuchsia")
        if (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.609 * NikkeW . " ", NikkeY + 0.785 * NikkeH . " ", NikkeX + 0.609 * NikkeW + 0.013 * NikkeW . " ", NikkeY + 0.785 * NikkeH + 0.024 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
            Sleep 1000
            AddLog("已进入任务界面")
            while (ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.529 * NikkeW . " ", NikkeY + 0.862 * NikkeH . " ", NikkeX + 0.529 * NikkeW + 0.111 * NikkeW . " ", NikkeY + 0.862 * NikkeH + 0.056 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("签到·全部领取的全部"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X + 50 * TrueRatio, Y, "L")
                AddLog("点击全部领取")
                Sleep 2000
                FindText().Click(X + 50 * TrueRatio, Y, "L")
                Sleep 500
            }
        }
        else {
            AddLog("没有可领取的任务")
        }
    }
}
;endregion 小活动
;region 大活动
EventLarge() {
    AddLog("开始任务：大活动", "Fuchsia")
    while (ok := FindText(&X, &Y, NikkeX + 0.658 * NikkeW . " ", NikkeY + 0.639 * NikkeH . " ", NikkeX + 0.658 * NikkeW + 0.040 * NikkeW . " ", NikkeY + 0.639 * NikkeH + 0.066 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("方舟的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
        if (ok := FindText(&X, &Y, NikkeX + 0.750 * NikkeW . " ", NikkeY + 0.813 * NikkeH . " ", NikkeX + 0.750 * NikkeW + 0.008 * NikkeW . " ", NikkeY + 0.813 * NikkeH + 0.018 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) or (ok := FindText(&X, &Y, NikkeX + 0.743 * NikkeW . " ", NikkeY + 0.804 * NikkeH . " ", NikkeX + 0.743 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.804 * NikkeH + 0.037 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("大活动·红色的N框"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("已找到大活动")
            UserClick(2782, 1816, TrueRatio)
            loop 3 {
                Sleep 500
                Confirm
            }
        }
        else if (ok := FindText(&X, &Y, NikkeX + 0.743 * NikkeW . " ", NikkeY + 0.804 * NikkeH . " ", NikkeX + 0.743 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.804 * NikkeH + 0.037 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("大活动·红色的N框"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("已找到大活动")
            UserClick(2782, 1816, TrueRatio)
            Sleep 1000
            Confirm
        }
        else if (ok := FindText(&X, &Y, NikkeX + 0.751 * NikkeW . " ", NikkeY + 0.864 * NikkeH . " ", NikkeX + 0.751 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.864 * NikkeH + 0.037 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("活动·切换的图标"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y - 100 * TrueRatio, "L")
            Sleep 3000
        }
        else {
            UserClick(2782, 1816, TrueRatio)
            Sleep 1000
            Confirm
        }
        if A_Index > 1 {
            AddLog("未找到大活动，可能是活动已结束")
            return
        }
    }
    while !(ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.29 * PicTolerance, 0.29 * PicTolerance, FindText().PicLib("活动地区的地区"), , 0, , , , , TrueRatio, TrueRatio)) {
        Confirm
        Send "{]}"
    }
    AddLog("已进入活动地区")
    Sleep 3000
    ;tag 签到
    if g_settings["EventLargeSign"] {
        AddLog("开始任务：大活动·签到", "Fuchsia")
        while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.553 * NikkeW . " ", NikkeY + 0.781 * NikkeH . " ", NikkeX + 0.553 * NikkeW + 0.105 * NikkeW . " ", NikkeY + 0.781 * NikkeH + 0.058 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("大活动·签到印章"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("尝试进入对应活动页")
            FindText().Click(X - 50 * TrueRatio, Y, "L")
            Sleep 1000
        }
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.534 * NikkeW . " ", NikkeY + 0.840 * NikkeH . " ", NikkeX + 0.534 * NikkeW + 0.099 * NikkeW . " ", NikkeY + 0.840 * NikkeH + 0.063 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("大活动·全部领取"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X + 50 * TrueRatio, Y, "L")
            AddLog("点击全部领取")
            Sleep 3000
            Confirm
        }
        while !(ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.29 * PicTolerance, 0.29 * PicTolerance, FindText().PicLib("活动地区的地区"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("尝试返回活动主页面")
            GoBack
            ; 领取活动赠送妮姬
            if (ok := FindText(&X, &Y, NikkeX + 0.436 * NikkeW . " ", NikkeY + 0.866 * NikkeH . " ", NikkeX + 0.436 * NikkeW + 0.128 * NikkeW . " ", NikkeY + 0.866 * NikkeH + 0.070 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("抽卡·确认"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                Sleep 500
            }
        }
        AddLog("已返回活动主页面")
    }
    ;tag 挑战
    if g_settings["EventLargeChallenge"] {
        AddLog("开始任务：大活动·挑战", "Fuchsia")
        while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.340 * NikkeW . " ", NikkeY + 0.812 * NikkeH . " ", NikkeX + 0.340 * NikkeW + 0.120 * NikkeW . " ", NikkeY + 0.812 * NikkeH + 0.049 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("大活动·挑战"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("尝试进入对应活动页")
            FindText().Click(X - 50 * TrueRatio, Y, "L")
            Sleep 500
        }
        Challenge
        while !(ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.29 * PicTolerance, 0.29 * PicTolerance, FindText().PicLib("活动地区的地区"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("尝试返回活动主页面")
            GoBack
        }
        AddLog("已返回活动主页面")
    }
    ;tag 剧情活动
    if g_settings["EventLargeStory"] {
        AddLog("开始任务：大活动·剧情活动", "Fuchsia")
        while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.343 * NikkeW . " ", NikkeY + 0.707 * NikkeH . " ", NikkeX + 0.343 * NikkeW + 0.116 * NikkeW . " ", NikkeY + 0.707 * NikkeH + 0.053 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("大活动·STORY"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("尝试进入对应活动页")
            FindText().Click(X - 50 * TrueRatio, Y, "L")
            Sleep 500
        }
        while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.339 * NikkeW . " ", NikkeY + 0.760 * NikkeH . " ", NikkeX + 0.339 * NikkeW + 0.116 * NikkeW . " ", NikkeY + 0.760 * NikkeH + 0.053 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("大活动·STORY"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("尝试进入对应活动页")
            FindText().Click(X - 50 * TrueRatio, Y, "L")
            Sleep 500
        }
        loop 3 {
            Confirm
            Sleep 500
        }
        while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.445 * NikkeW . " ", NikkeY + 0.765 * NikkeH . " ", NikkeX + 0.445 * NikkeW + 0.042 * NikkeW . " ", NikkeY + 0.765 * NikkeH + 0.029 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("大活动·剩余时间"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("进入剧情活动页面")
            Sleep 500
            FindText().Click(X, Y - 100 * TrueRatio, "L")
        }
        Confirm
        ; 执行剧情活动流程
        AdvanceMode("大活动·关卡图标", "大活动·关卡图标2")
        while !(ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.29 * PicTolerance, 0.29 * PicTolerance, FindText().PicLib("活动地区的地区"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("尝试返回活动主页面")
            Confirm
            GoBack
        }
        AddLog("已返回活动主页面")
    }
    ;tag 协同作战
    if g_settings["EventLargeCooperate"] {
        AddLog("开始任务：大活动·协同作战", "Fuchsia")
        while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.438 * NikkeW . " ", NikkeY + 0.866 * NikkeH . " ", NikkeX + 0.438 * NikkeW + 0.134 * NikkeW . " ", NikkeY + 0.866 * NikkeH + 0.046 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("大活动·协同作战"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("尝试进入对应活动页")
            FindText().Click(X - 50 * TrueRatio, Y, "L")
            Sleep 500
            if A_Index > 50 {
                AddLog("不在活动期间")
                break
            }
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.357 * NikkeW . " ", NikkeY + 0.575 * NikkeH . " ", NikkeX + 0.357 * NikkeW + 0.287 * NikkeW . " ", NikkeY + 0.575 * NikkeH + 0.019 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
            Sleep 1000
        }
        AwardCooperateBattle
        while !(ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.29 * PicTolerance, 0.29 * PicTolerance, FindText().PicLib("活动地区的地区"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("尝试返回活动主页面")
            GoBack
        }
        AddLog("已返回活动主页面")
    }
    ;tag 小游戏
    if g_settings["EventLargeMinigame"] {
        AddLog("开始任务：大活动·小游戏", "Fuchsia")
        while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.551 * NikkeW . " ", NikkeY + 0.715 * NikkeH . " ", NikkeX + 0.551 * NikkeW + 0.119 * NikkeW . " ", NikkeY + 0.715 * NikkeH + 0.044 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("大活动·小游戏"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("尝试进入对应活动页")
            FindText().Click(X - 50 * TrueRatio, Y, "L")
            Send "{]}"
            Sleep 500
        }
        Sleep 2000
        Send "{]}"
        Confirm
        AddLog("点第一个START")
        UserClick(1974, 1418, TrueRatio)
        Sleep 1000
        AddLog("点第二个START")
        UserClick(1911, 1743, TrueRatio)
        Sleep 3000
        if (ok := FindText(&X, &Y, NikkeX + 0.370 * NikkeW . " ", NikkeY + 0.245 * NikkeH . " ", NikkeX + 0.370 * NikkeW + 0.259 * NikkeW . " ", NikkeY + 0.245 * NikkeH + 0.461 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("大活动·小游戏·十字"), , , , , , 1, TrueRatio, TrueRatio)) {
            loop {
                if (ok := FindText(&X, &Y, NikkeX + 0.370 * NikkeW . " ", NikkeY + 0.245 * NikkeH . " ", NikkeX + 0.370 * NikkeW + 0.259 * NikkeW . " ", NikkeY + 0.245 * NikkeH + 0.461 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("大活动·小游戏·十字"), , , , , , 1, TrueRatio, TrueRatio)) {
                    AddLog("点击扩充")
                    FindText().Click(X, Y, "L")
                    Sleep 500
                }
                if (ok := FindText(&X, &Y, NikkeX + 0.499 * NikkeW . " ", NikkeY + 0.723 * NikkeH . " ", NikkeX + 0.499 * NikkeW + 0.142 * NikkeW . " ", NikkeY + 0.723 * NikkeH + 0.062 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("大活动·小游戏·扩充完成"), , , , , , , TrueRatio, TrueRatio)) {
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                    break
                }
            }
        }
        AddLog("点战斗开始")
        UserClick(1938, 2030, TrueRatio)
        Sleep 1000
        loop {
            Send "{Space}"
            Sleep 1000
            Send "{1}"
            Sleep 1000
            UserClick(1938, 2030, TrueRatio)
            Sleep 1000
            if A_Index > 12 {
                AddLog("结算战斗")
                Send "{Esc}"
                Sleep 1000
                AddLog("点击快速完成")
                UserClick(2120, 1858, TrueRatio)
                Sleep 1000
                AddLog("点击返回")
                UserClick(1806, 1682, TrueRatio)
                break
            }
        }
        while !(ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.29 * PicTolerance, 0.29 * PicTolerance, FindText().PicLib("活动地区的地区"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("尝试返回活动主页面")
            GoBack
        }
        AddLog("已返回活动主页面")
    }
    ;tag 领取奖励
    if g_settings["EventLargeDaily"] {
        AddLog("开始任务：大活动·领取奖励", "Fuchsia")
        while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.986 * NikkeW . " ", NikkeY + 0.172 * NikkeH . " ", NikkeX + 0.986 * NikkeW + 0.008 * NikkeW . " ", NikkeY + 0.172 * NikkeH + 0.019 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
            if (ok := FindText(&X, &Y, NikkeX + 0.956 * NikkeW . " ", NikkeY + 0.170 * NikkeH . " ", NikkeX + 0.956 * NikkeW + 0.041 * NikkeW . " ", NikkeY + 0.170 * NikkeH + 0.089 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("大活动·任务"), , , , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y - 50 * TrueRatio, "L")
                Sleep 1000
            }
            while !(ok := FindText(&X, &Y, NikkeX + 0.548 * NikkeW . " ", NikkeY + 0.864 * NikkeH . " ", NikkeX + 0.548 * NikkeW + 0.093 * NikkeW . " ", NikkeY + 0.864 * NikkeH + 0.063 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("大活动·灰色的全部"), , , , , , , TrueRatio, TrueRatio)) {
                UserClick(2412, 1905, TrueRatio)
                Sleep 1000
            }
            while !(ok := FindText(&X := "wait", &Y := 2, NikkeX + 0.003 * NikkeW . " ", NikkeY + 0.007 * NikkeH . " ", NikkeX + 0.003 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.007 * NikkeH + 0.054 * NikkeH . " ", 0.29 * PicTolerance, 0.29 * PicTolerance, FindText().PicLib("活动地区的地区"), , 0, , , , , TrueRatio, TrueRatio)) {
                AddLog("尝试返回活动主页面")
                GoBack
            }
            AddLog("已返回活动主页面")
        }
        else AddLog("奖励已领取")
    }
    ;tag 通行证
    if g_settings["AwardPass"] {
        UserClick(3554, 268, TrueRatio)
        Sleep 1000
        AddLog("开始任务：大活动·通行证", "Fuchsia")
        OneAwardPass()
    }
    BackToHall
}
;endregion 大活动
;region 特殊活动
EventSpecial() {
}
;endregion 特殊活动
;region 清除红点
ClearRed() {
    ;tag 自动升级循环室
    if g_settings["ClearRedRecycling"] {
        AddLog("自动升级循环室")
        if (ok := FindText(&X, &Y, NikkeX + 0.344 * NikkeW . " ", NikkeY + 0.719 * NikkeH . " ", NikkeX + 0.344 * NikkeW + 0.011 * NikkeW . " ", NikkeY + 0.719 * NikkeH + 0.018 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击进入前哨基地")
            FindText().Click(X, Y, "L")
            Sleep 1000
            if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.582 * NikkeW . " ", NikkeY + 0.805 * NikkeH . " ", NikkeX + 0.582 * NikkeW + 0.011 * NikkeW . " ", NikkeY + 0.805 * NikkeH + 0.023 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                Sleep 1000
                AddLog("点击进入循环室")
                FindText().Click(X, Y, "L")
                Sleep 1000
                if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.612 * NikkeW . " ", NikkeY + 0.907 * NikkeH . " ", NikkeX + 0.612 * NikkeW + 0.013 * NikkeW . " ", NikkeY + 0.907 * NikkeH + 0.020 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("点击进入")
                    FindText().Click(X, Y, "L")
                    Sleep 3000
                    Send "{WheelUp 2}"
                    while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.333 * NikkeW . " ", NikkeY + 0.040 * NikkeH . " ", NikkeX + 0.333 * NikkeW + 0.354 * NikkeW . " ", NikkeY + 0.040 * NikkeH + 0.865 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                        AddLog("点击类型研究/通用研究")
                        FindText().Click(X, Y + 200 * TrueRatio, "L")
                        Sleep 1000
                        loop {
                            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.397 * NikkeW . " ", NikkeY + 0.767 * NikkeH . " ", NikkeX + 0.397 * NikkeW + 0.089 * NikkeW . " ", NikkeY + 0.767 * NikkeH + 0.064 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("自动选择的图标"), , , , , , , TrueRatio, TrueRatio)) {
                                AddLog("点击自动选择")
                                FindText().Click(X, Y, "L")
                                Sleep 500
                            }
                            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.489 * NikkeW . " ", NikkeY + 0.764 * NikkeH . " ", NikkeX + 0.489 * NikkeW + 0.150 * NikkeW . " ", NikkeY + 0.764 * NikkeH + 0.071 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("循环室·升级"), , , , , , , TrueRatio, TrueRatio)) {
                                AddLog("点击升级")
                                FindText().Click(X, Y, "L")
                                Sleep 500
                                Confirm
                                Sleep 500
                                Confirm
                            }
                            else {
                                Confirm
                                break
                            }
                            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.573 * NikkeW . " ", NikkeY + 0.684 * NikkeH . " ", NikkeX + 0.573 * NikkeW + 0.037 * NikkeW . " ", NikkeY + 0.684 * NikkeH + 0.044 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("MAX"), , , , , , , TrueRatio, TrueRatio)) {
                                AddLog("点击MAX")
                                FindText().Click(X, Y, "L")
                                Sleep 500
                                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.423 * NikkeW . " ", NikkeY + 0.781 * NikkeH . " ", NikkeX + 0.423 * NikkeW + 0.157 * NikkeW . " ", NikkeY + 0.781 * NikkeH + 0.070 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("循环室·升级"), , , , , , , TrueRatio, TrueRatio)) {
                                    AddLog("点击升级")
                                    FindText().Click(X, Y, "L")
                                    Sleep 2000
                                    Confirm
                                    Sleep 500
                                    Confirm
                                    break
                                }
                            }
                        }
                    }
                    BackToHall
                }
            }
            else AddLog("未发现循环室红点")
        }
        else AddLog("未发现前哨基地红点")
    }
    ;tag 自动升级同步器
    if g_settings["ClearRedSynchro"] {
        AddLog("自动升级同步器")
        if g_settings["ClearRedSynchroForce"] {
            while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.240 * NikkeW . " ", NikkeY + 0.755 * NikkeH . " ", NikkeX + 0.240 * NikkeW + 0.048 * NikkeW . " ", NikkeY + 0.755 * NikkeH + 0.061 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("前哨基地的图标"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击进入前哨基地")
                FindText().Click(X, Y, "L")
                Sleep 1000
            }
            if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.408 * NikkeW . " ", NikkeY + 0.806 * NikkeH . " ", NikkeX + 0.408 * NikkeW + 0.046 * NikkeW . " ", NikkeY + 0.806 * NikkeH + 0.096 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("前哨基地·同步器"), , , , , , , TrueRatio, TrueRatio)) {
                Sleep 1000
                FindText().Click(X, Y, "L")
                Sleep 1000
                if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.504 * NikkeW . " ", NikkeY + 0.907 * NikkeH . " ", NikkeX + 0.504 * NikkeW + 0.123 * NikkeW . " ", NikkeY + 0.907 * NikkeH + 0.084 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("前哨基地·进入的图标"), , , , , , , TrueRatio, TrueRatio)) {
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                    loop {
                        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.477 * NikkeW . " ", NikkeY + 0.201 * NikkeH . " ", NikkeX + 0.477 * NikkeW + 0.043 * NikkeW . " ", NikkeY + 0.201 * NikkeH + 0.045 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("同步器·增强"), , , , , , , TrueRatio, TrueRatio)) {
                            AddLog("点击增强")
                            FindText().Click(X, Y, "L")
                            Sleep 1000
                        }
                        if (ok := FindText(&X, &Y, NikkeX + 0.599 * NikkeW . " ", NikkeY + 0.604 * NikkeH . " ", NikkeX + 0.599 * NikkeW + 0.030 * NikkeW . " ", NikkeY + 0.604 * NikkeH + 0.034 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("同步器·消耗道具使用的图标"), , , , , , , TrueRatio, TrueRatio)) {
                            FindText().Click(X, Y, "L")
                            Sleep 1000
                        }
                        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.416 * NikkeW . " ", NikkeY + 0.798 * NikkeH . " ", NikkeX + 0.416 * NikkeW + 0.091 * NikkeW . " ", NikkeY + 0.798 * NikkeH + 0.070 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("自动选择的图标"), , , , , , , TrueRatio, TrueRatio)) {
                            AddLog("点击自动选择")
                            FindText().Click(X, Y, "L")
                            Sleep 1000
                        }
                        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.505 * NikkeW . " ", NikkeY + 0.798 * NikkeH . " ", NikkeX + 0.505 * NikkeW + 0.112 * NikkeW . " ", NikkeY + 0.798 * NikkeH + 0.068 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("同步器·开始增强"), , , , , , , TrueRatio, TrueRatio)) {
                            AddLog("点击开始增强")
                            FindText().Click(X, Y, "L")
                            Sleep 3000
                            while !(ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.477 * NikkeW . " ", NikkeY + 0.201 * NikkeH . " ", NikkeX + 0.477 * NikkeW + 0.043 * NikkeW . " ", NikkeY + 0.201 * NikkeH + 0.045 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("同步器·增强"), , , , , , , TrueRatio, TrueRatio)) {
                                Confirm
                            }
                        }
                        else {
                            AddLog("资源不足")
                            break
                        }
                    }
                }
            }
        }
        if !g_settings["ClearRedSynchroForce"] {
            if (ok := FindText(&X, &Y, NikkeX + 0.344 * NikkeW . " ", NikkeY + 0.719 * NikkeH . " ", NikkeX + 0.344 * NikkeW + 0.011 * NikkeW . " ", NikkeY + 0.719 * NikkeH + 0.018 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击进入前哨基地")
                FindText().Click(X, Y, "L")
                Sleep 1000
                if (ok := FindText(&X := "wait", &Y := 5, NikkeX + 0.443 * NikkeW . " ", NikkeY + 0.804 * NikkeH . " ", NikkeX + 0.443 * NikkeW + 0.014 * NikkeW . " ", NikkeY + 0.804 * NikkeH + 0.025 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                    Sleep 1000
                    AddLog("点击进入同步器")
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                    if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.612 * NikkeW . " ", NikkeY + 0.907 * NikkeH . " ", NikkeX + 0.612 * NikkeW + 0.013 * NikkeW . " ", NikkeY + 0.907 * NikkeH + 0.020 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                        AddLog("点击进入")
                        FindText().Click(X, Y, "L")
                        Sleep 2000
                        loop {
                            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.477 * NikkeW . " ", NikkeY + 0.201 * NikkeH . " ", NikkeX + 0.477 * NikkeW + 0.043 * NikkeW . " ", NikkeY + 0.201 * NikkeH + 0.045 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("同步器·增强"), , , , , , , TrueRatio, TrueRatio)) {
                                AddLog("点击增强")
                                FindText().Click(X, Y, "L")
                                Sleep 1000
                                if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.505 * NikkeW . " ", NikkeY + 0.798 * NikkeH . " ", NikkeX + 0.505 * NikkeW + 0.112 * NikkeW . " ", NikkeY + 0.798 * NikkeH + 0.068 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("同步器·开始增强"), , , , , , , TrueRatio, TrueRatio)) {
                                    AddLog("点击开始增强")
                                    FindText().Click(X, Y, "L")
                                    Sleep 1000
                                }
                                else break
                            }
                            else {
                                Confirm
                            }
                        }
                    }
                }
                else AddLog("未发现同步器红点")
            }
            else AddLog("未发现前哨基地红点")
        }
    }
    ;tag 自动突破妮姬
    if g_settings["ClearRedLimit"] {
        BackToHall
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.395 * NikkeW . " ", NikkeY + 0.883 * NikkeH . " ", NikkeX + 0.395 * NikkeW + 0.011 * NikkeW . " ", NikkeY + 0.883 * NikkeH + 0.019 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击进入妮姬")
            FindText().Click(X, Y, "L")
            Sleep 1000
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.513 * NikkeW . " ", NikkeY + 0.191 * NikkeH . " ", NikkeX + 0.513 * NikkeW + 0.014 * NikkeW . " ", NikkeY + 0.191 * NikkeH + 0.022 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("妮姬·筛选红点"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击筛选红点")
                FindText().Click(X, Y, "L")
                Sleep 1000
                while (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.099 * NikkeW . " ", NikkeY + 0.284 * NikkeH . " ", NikkeX + 0.099 * NikkeW + 0.015 * NikkeW . " ", NikkeY + 0.284 * NikkeH + 0.023 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("点击带有红点的妮姬")
                    FindText().Click(X, Y, "L")
                    Sleep 2000
                    if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.960 * NikkeW . " ", NikkeY + 0.487 * NikkeH . " ", NikkeX + 0.960 * NikkeW + 0.011 * NikkeW . " ", NikkeY + 0.487 * NikkeH + 0.012 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("妮姬·极限突破的红色红点"), , , , , , , TrueRatio, TrueRatio)) {
                        AddLog("点击极限突破/核心强化的红点")
                        FindText().Click(X, Y, "L")
                        Sleep 1000
                        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.416 * NikkeW . " ", NikkeY + 0.822 * NikkeH . " ", NikkeX + 0.416 * NikkeW + 0.171 * NikkeW . " ", NikkeY + 0.822 * NikkeH + 0.074 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("妮姬·极限突破"), , , , , , , TrueRatio, TrueRatio)) {
                            AddLog("点击极限突破")
                            FindText().Click(X, Y, "L")
                            Sleep 1000
                            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.505 * NikkeW . " ", NikkeY + 0.593 * NikkeH . " ", NikkeX + 0.505 * NikkeW + 0.123 * NikkeW . " ", NikkeY + 0.593 * NikkeH + 0.064 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                                AddLog("确认")
                                FindText().Click(X, Y, "L")
                                Sleep 1000
                            }
                        }
                        if (ok := FindText(&X, &Y, NikkeX + 0.553 * NikkeW . " ", NikkeY + 0.683 * NikkeH . " ", NikkeX + 0.553 * NikkeW + 0.036 * NikkeW . " ", NikkeY + 0.683 * NikkeH + 0.040 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("MAX"), , , , , , , TrueRatio, TrueRatio)) {
                            AddLog("点击MAX")
                            FindText().Click(X, Y, "L")
                            Sleep 500
                        }
                        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.371 * NikkeW . " ", NikkeY + 0.785 * NikkeH . " ", NikkeX + 0.371 * NikkeW + 0.257 * NikkeW . " ", NikkeY + 0.785 * NikkeH + 0.076 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("妮姬·核心强化"), , , , , , , TrueRatio, TrueRatio)) {
                            AddLog("点击核心强化")
                            FindText().Click(X, Y, "L")
                            Sleep 1000
                            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.505 * NikkeW . " ", NikkeY + 0.593 * NikkeH . " ", NikkeX + 0.505 * NikkeW + 0.123 * NikkeW . " ", NikkeY + 0.593 * NikkeH + 0.064 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                                AddLog("确认")
                                FindText().Click(X, Y, "L")
                                Sleep 1000
                            }
                        }
                    }
                    loop 3 {
                        Confirm
                        Sleep 1000
                    }
                    GoBack
                }
                UserClick(1898, 2006, TrueRatio)
            }
        }
    }
    ;tag 自动升级魔方
    if g_settings["ClearRedCube"] {
        AddLog("自动升级魔方")
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.752 * NikkeW . " ", NikkeY + 0.626 * NikkeH . " ", NikkeX + 0.752 * NikkeW + 0.013 * NikkeW . " ", NikkeY + 0.626 * NikkeH + 0.029 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击进入方舟")
            FindText().Click(X, Y, "L")
            Sleep 1000
            if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.478 * NikkeW . " ", NikkeY + 0.106 * NikkeH . " ", NikkeX + 0.478 * NikkeW + 0.015 * NikkeW . " ", NikkeY + 0.106 * NikkeH + 0.031 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击进入迷失地区")
                Sleep 1000
                FindText().Click(X, Y, "L")
                Sleep 1000
                if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.983 * NikkeW . " ", NikkeY + 0.903 * NikkeH . " ", NikkeX + 0.983 * NikkeW + 0.011 * NikkeW . " ", NikkeY + 0.903 * NikkeH + 0.027 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                    AddLog("点击调和魔方")
                    Sleep 1000
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                    loop {
                        UserMove(1920, 598, TrueRatio)
                        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.339 * NikkeW . " ", NikkeY + 0.231 * NikkeH . " ", NikkeX + 0.339 * NikkeW + 0.322 * NikkeW . " ", NikkeY + 0.231 * NikkeH + 0.683 * NikkeH . " ", 0.23 * PicTolerance, 0.23 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                            AddLog("点击可升级魔方")
                            FindText().Click(X, Y, "L")
                            Sleep 1000
                            if (ok := FindText(&X, &Y, NikkeX + 0.551 * NikkeW . " ", NikkeY + 0.839 * NikkeH . " ", NikkeX + 0.551 * NikkeW + 0.017 * NikkeW . " ", NikkeY + 0.839 * NikkeH + 0.030 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                                AddLog("点击强化魔方")
                                FindText().Click(X, Y, "L")
                                Sleep 1000
                                if (ok := FindText(&X, &Y, NikkeX + 0.602 * NikkeW . " ", NikkeY + 0.759 * NikkeH . " ", NikkeX + 0.602 * NikkeW + 0.017 * NikkeW . " ", NikkeY + 0.759 * NikkeH + 0.029 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                                    AddLog("点击强化")
                                    FindText().Click(X, Y, "L")
                                    Sleep 500
                                    loop 10 {
                                        UserClick(1910, 2066, TrueRatio)
                                        GoBack
                                    }
                                }
                            }
                        }
                        else Send "{WheelDown 13}"
                        if A_Index > 5 {
                            AddLog("所有魔方已检查")
                            break
                        }
                    }
                }
            }
        }
    }
    ;tag 清除公告红点
    if g_settings["ClearRedNotice"] {
        AddLog("清除公告红点")
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.933 * NikkeW . " ", NikkeY + 0.012 * NikkeH . " ", NikkeX + 0.933 * NikkeW + 0.009 * NikkeW . " ", NikkeY + 0.012 * NikkeH + 0.023 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
            Sleep 3000
            FindText().Click(X, Y, "L")
            Sleep 1000
            while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.490 * NikkeW . " ", NikkeY + 0.128 * NikkeH . " ", NikkeX + 0.490 * NikkeW + 0.016 * NikkeW . " ", NikkeY + 0.128 * NikkeH + 0.029 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                if A_Index = 1 {
                    AddLog("清除活动公告红点")
                    FindText().Click(X - 30 * TrueRatio, Y + 30 * TrueRatio, "L")
                    Sleep 1000
                    ;把鼠标移动到活动栏
                    UserMove(1380, 462, TrueRatio)
                }
                AddLog("查找红点")
                while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.620 * NikkeW . " ", NikkeY + 0.189 * NikkeH . " ", NikkeX + 0.617 * NikkeW + 0.013 * NikkeW . " ", NikkeY + 0.189 * NikkeH + 0.677 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                    FindText().Click(X, Y, "L")
                    Sleep 2000
                    Confirm
                    Sleep 1000
                    UserMove(1380, 462, TrueRatio)
                }
                AddLog("尝试滚动活动栏")
                Send "{WheelDown 33}"
                Sleep 500
            }
            while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.617 * NikkeW . " ", NikkeY + 0.141 * NikkeH . " ", NikkeX + 0.617 * NikkeW + 0.017 * NikkeW . " ", NikkeY + 0.141 * NikkeH + 0.031 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                if A_Index = 1 {
                    AddLog("清除系统公告红点")
                    FindText().Click(X - 30 * TrueRatio, Y + 30 * TrueRatio, "L")
                    Sleep 1000
                    ;把鼠标移动到活动栏
                    UserMove(1380, 462, TrueRatio)
                }
                AddLog("查找红点")
                while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.614 * NikkeW . " ", NikkeY + 0.188 * NikkeH . " ", NikkeX + 0.614 * NikkeW + 0.029 * NikkeW . " ", NikkeY + 0.188 * NikkeH + 0.694 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红点"), , , , , , , TrueRatio, TrueRatio)) {
                    FindText().Click(X, Y, "L")
                    Sleep 2000
                    Confirm
                    Sleep 1000
                    UserMove(1380, 462, TrueRatio)
                }
                AddLog("尝试滚动活动栏")
                Send "{WheelDown 33}"
                Sleep 500
            }
            AddLog("公告红点已清除")
            BackToHall
        }
        else AddLog("未发现公告红点")
    }
    ;tag 清除壁纸红点
    if g_settings["ClearRedWallpaper"] {
        AddLog("清除壁纸红点")
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.980 * NikkeW . " ", NikkeY + 0.008 * NikkeH . " ", NikkeX + 0.980 * NikkeW + 0.019 * NikkeW . " ", NikkeY + 0.008 * NikkeH + 0.031 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红底的N图标"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击右上角的SUBMENU")
            FindText().Click(X, Y, "L")
            Sleep 1000
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.590 * NikkeW . " ", NikkeY + 0.441 * NikkeH . " ", NikkeX + 0.590 * NikkeW + 0.021 * NikkeW . " ", NikkeY + 0.441 * NikkeH + 0.042 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("红底的N图标"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击装饰大厅")
                FindText().Click(X, Y, "L")
                Sleep 1000
                while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.341 * NikkeW . " ", NikkeY + 0.371 * NikkeH . " ", NikkeX + 0.341 * NikkeW + 0.320 * NikkeW . " ", NikkeY + 0.371 * NikkeH + 0.028 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("红底的N图标"), , , , , , , 0.83 * TrueRatio, 0.83 * TrueRatio)) {
                    AddLog("点击立绘/活动/技能动画/珍藏品")
                    FindText().Click(X, Y, "L")
                    Sleep 1000
                    UserClick(1434, 856, TrueRatio)
                    Sleep 1000
                }
            }
        }
        else AddLog("未发现壁纸红点")
    }
}
;endregion 清除红点
;region 妙妙工具
;tag 剧情模式
StoryMode(*) {
    Initialization
    WriteSettings
    AddLog("开始任务：剧情模式", "Fuchsia")
    while True {
        while (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.936 * NikkeW . " ", NikkeY + 0.010 * NikkeH . " ", NikkeX + 0.936 * NikkeW + 0.051 * NikkeW . " ", NikkeY + 0.010 * NikkeH + 0.025 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("SKIP的图标"), , , , , , , TrueRatio, TrueRatio)) {
            if (ok := FindText(&X, &Y, NikkeX + 0.362 * NikkeW . " ", NikkeY + 0.589 * NikkeH . " ", NikkeX + 0.362 * NikkeW + 0.017 * NikkeW . " ", NikkeY + 0.589 * NikkeH + 0.283 * NikkeH . " ", 0.18 * PicTolerance, 0.18 * PicTolerance, FindText().PicLib("1"), , , , , , , TrueRatio, TrueRatio)) {
                if !g_settings["StoryModeAutoChoose"] {
                    if (ok := FindText(&X, &Y, NikkeX + 0.361 * NikkeW . " ", NikkeY + 0.638 * NikkeH . " ", NikkeX + 0.361 * NikkeW + 0.018 * NikkeW . " ", NikkeY + 0.638 * NikkeH + 0.282 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("2"), , , , , , , TrueRatio, TrueRatio)) {
                        continue
                    }
                }
                Sleep 1000
                Send "{1}"
                Sleep 500
            }
            if (ok := FindText(&X, &Y, NikkeX + 0.785 * NikkeW . " ", NikkeY + 0.004 * NikkeH . " ", NikkeX + 0.785 * NikkeW + 0.213 * NikkeW . " ", NikkeY + 0.004 * NikkeH + 0.071 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("白色的AUTO"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击AUTO")
                Send "{LShift Down}"
                Sleep 500
                Send "{LShift Up}"
                Click NikkeX + NikkeW, NikkeY, 0
            }
            if (ok := FindText(&X, &Y, NikkeX + 0.475 * NikkeW . " ", NikkeY + 0.460 * NikkeH . " ", NikkeX + 0.475 * NikkeW + 0.050 * NikkeW . " ", NikkeY + 0.460 * NikkeH + 0.080 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("Bla的图标"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击Bla的图标")
                Sleep 1000
                FindText().Click(X, Y, "L")
                Sleep 500
            }
            if (ok := FindText(&X, &Y, NikkeX + 0.366 * NikkeW . " ", NikkeY + 0.091 * NikkeH . " ", NikkeX + 0.366 * NikkeW + 0.012 * NikkeW . " ", NikkeY + 0.091 * NikkeH + 0.020 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("WIFI的图标"), , , , , , , TrueRatio, TrueRatio)) {
                if (ok := FindText(&X, &Y, NikkeX + 0.614 * NikkeW . " ", NikkeY + 0.210 * NikkeH . " ", NikkeX + 0.614 * NikkeW + 0.023 * NikkeW . " ", NikkeY + 0.210 * NikkeH + 0.700 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("对话框·对话"), , , , , , 3, TrueRatio, TrueRatio)) {
                    AddLog("点击对话")
                    FindText().Click(X - 100 * TrueRatio, Y - 100 * TrueRatio, "L")
                    sleep 1000
                }
                else {
                    AddLog("点击对话框的右下角")
                    UserClick(2382, 1894, TrueRatio)
                    sleep 1000
                }
            }
            if (ok := FindText(&X, &Y, NikkeX + 0.588 * NikkeW . " ", NikkeY + 0.754 * NikkeH . " ", NikkeX + 0.588 * NikkeW + 0.035 * NikkeW . " ", NikkeY + 0.754 * NikkeH + 0.055 * NikkeH . " ", 0.2 * PicTolerance, 0.2 * PicTolerance, FindText().PicLib("对话框·想法"), , , , , , 3, TrueRatio, TrueRatio)) {
                AddLog("点击想法")
                FindText().Click(X - 100 * TrueRatio, Y - 100 * TrueRatio, "L")
                sleep 1000
            }
        }
        if g_settings["StoryModeAutoStar"] {
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.611 * NikkeW . " ", NikkeY + 0.609 * NikkeH . " ", NikkeX + 0.611 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.609 * NikkeH + 0.033 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("灰色的星星"), , , , , , , TrueRatio, TrueRatio)) {
                sleep 1000
                AddLog("点击右下角灰色的星星")
                FindText().Click(X, Y, "L")
                Sleep 500
            }
            else if (ok := FindText(&X, &Y, NikkeX + 0.361 * NikkeW . " ", NikkeY + 0.369 * NikkeH . " ", NikkeX + 0.361 * NikkeW + 0.020 * NikkeW . " ", NikkeY + 0.369 * NikkeH + 0.041 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("灰色的星星"), , , , , , , TrueRatio, TrueRatio)) {
                AddLog("点击左上角灰色的星星")
                FindText().Click(X, Y, "L")
                sleep 1000
                MsgBox("剧情结束力~")
                return
            }
        }
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.500 * NikkeW . " ", NikkeY + 0.514 * NikkeH . " ", NikkeX + 0.500 * NikkeW + 0.139 * NikkeW . " ", NikkeY + 0.514 * NikkeH + 0.070 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("记录播放的播放"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击记录播放")
            FindText().Click(X, Y, "L")
            Sleep 500
            FindText().Click(X, Y, "L")
            Sleep 3000
        }
        if (ok := FindText(&X := "wait", &Y := 3, NikkeX + 0.785 * NikkeW . " ", NikkeY + 0.004 * NikkeH . " ", NikkeX + 0.785 * NikkeW + 0.213 * NikkeW . " ", NikkeY + 0.004 * NikkeH + 0.071 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("白色的AUTO"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击AUTO")
            Send "{LShift Down}"
            Sleep 500
            Send "{LShift Up}"
            Click NikkeX + NikkeW, NikkeY, 0
        }
        if !WinActive(nikkeID) {
            MsgBox "窗口未聚焦，程序已终止"
            return
        }
    }
}
;tag 调试模式
TestMode(BtnTestMode, Info) {
    g_numeric_settings["TestModeValue"] := TestModeEditControl.Value
    ; 1. 获取输入
    fullCallString := Trim(TestModeEditControl.Value)
    if (fullCallString = "") {
        MsgBox("请输入要执行的函数调用，例如: MyFunc(`"param1`", 123)")
        return
    }
    ; 2. 正则表达式解析 (允许函数名中带连字符)
    if RegExMatch(fullCallString, "i)^([\w-]+)\s*\((.*)\)$", &Match) {
        FuncName := Match[1]
        ParamString := Match[2]
    } else {
        MsgBox("无效的输入格式。`n`n请使用 '函数名(参数1, 参数2, ...)' 的格式。")
        return
    }
    ; 3. 获取函数引用
    try {
        fn := %FuncName%
    } catch {
        MsgBox("错误: 函数 '" FuncName "' 不存在。")
        return
    }
    ; 4. 解析参数 (简化版 - 直接传递变量名作为字符串)
    ParamsArray := []
    if (Trim(ParamString) != "") {
        ParamList := StrSplit(ParamString, ",")
        for param in ParamList {
            cleanedParam := Trim(param)
            ; 直接作为字符串传递，不进行任何引号处理
            ParamsArray.Push(cleanedParam)
        }
    }
    ; 5. 初始化并执行
    Initialization()
    try {
        Result := fn.Call(ParamsArray*)
        if (Result != "") {
            MsgBox("函数 '" FuncName "' 执行完毕。`n返回值: " Result)
        } else {
            MsgBox("函数 '" FuncName "' 执行完毕。")
        }
    } catch Error as e {
        MsgBox("执行函数 '" FuncName "' 时出错:`n`n" e.Message "`n`n行号: " e.Line "`n文件: " e.File)
    }
}
;tag 快速爆裂
QuickBurst(*) {
    Initialization()
    while true {
        if (ok := FindText(&X, &Y, NikkeX + 0.920 * NikkeW . " ", NikkeY + 0.458 * NikkeH . " ", NikkeX + 0.920 * NikkeW + 0.016 * NikkeW . " ", NikkeY + 0.458 * NikkeH + 0.031 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("爆裂·A"), , , , , , , TrueRatio, TrueRatio)) {
            Send "{a}"
        }
        if (ok := FindText(&X, &Y, NikkeX + 0.918 * NikkeW . " ", NikkeY + 0.551 * NikkeH . " ", NikkeX + 0.918 * NikkeW + 0.017 * NikkeW . " ", NikkeY + 0.551 * NikkeH + 0.028 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("爆裂·S"), , , , , , , TrueRatio, TrueRatio)) {
            Send "{s}"
        }
        if !WinActive(nikkeID) {
            MsgBox "窗口未聚焦，程序已终止"
            return
        }
    }
}
;tag 自动推图
AutoAdvance(*) {
    if UserLevel < 3 {
        MsgBox("当前用户组不支持活动，请点击赞助按钮升级会员组")
        return
    }
    Initialization()
    k := 9
    if (ok := FindText(&X, &Y, NikkeX + 0.013 * NikkeW . " ", NikkeY + 0.074 * NikkeH . " ", NikkeX + 0.013 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.074 * NikkeH + 0.047 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("推图·地图的指针"), , , , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        Sleep 1000
    }
    loop {
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("黄色的遗失物品的图标"), , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("找到遗失物品！")
            FindText().Click(X, Y, "L")
            Sleep 1000
            if (ok := FindText(&X := "wait", &Y := 5, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("带圈白勾"), , , , , , , TrueRatio, TrueRatio)) {
                Sleep 500
                FindText().Click(X, Y, "L")
            }
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.010 * NikkeW . " ", NikkeY + 0.084 * NikkeH . " ", NikkeX + 0.010 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.084 * NikkeH + 0.038 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("推图·放大镜"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("点击小地图")
            FindText().Click(X, Y, "L")
        }
        else {
            EnterToBattle
            k := 9
            if BattleActive = 1 {
                modes := ["EventStory"]
                if BattleSettlement(modes*) = False {
                    MsgBox("本日の勝敗結果：`nDoroの敗北")
                    return
                }
                else {
                    while !(ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.010 * NikkeW . " ", NikkeY + 0.084 * NikkeH . " ", NikkeX + 0.010 * NikkeW + 0.022 * NikkeW . " ", NikkeY + 0.084 * NikkeH + 0.038 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("推图·放大镜"), , , , , , , TrueRatio, TrueRatio)) {
                        Confirm
                    }
                }
            }
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.359 * NikkeW . " ", NikkeY + 0.251 * NikkeH . " ", NikkeX + 0.359 * NikkeW + 0.021 * NikkeW . " ", NikkeY + 0.251 * NikkeH + 0.040 * NikkeH . " ", 0.3 * PicTolerance, 0.3 * PicTolerance, FindText().PicLib("推图·缩小镜"), , , , , , , TrueRatio, TrueRatio)) {
            AddLog("已进入小地图")
            Sleep 1000
        }
        if (ok := FindText(&X := "wait", &Y := 1, NikkeX + 0.360 * NikkeW . " ", NikkeY + 0.254 * NikkeH . " ", NikkeX + 0.360 * NikkeW + 0.280 * NikkeW . " ", NikkeY + 0.254 * NikkeH + 0.495 * NikkeH . " ", 0.4 * PicTolerance, 0.4 * PicTolerance, FindText().PicLib("推图·红色的三角"), , , , , , k, TrueRatio * 0.8, TrueRatio * 0.8)) {
            Confirm
            AddLog("找到敌人")
            FindText().Click(X + (k - 9) * Random(-100, 100) * TrueRatio, Y + (k - 9) * Random(-100, 100) * TrueRatio, "L")
        }
        k := k + 2
        if k > 9
            k := k - 9
    }
}
;endregion 妙妙工具
;region 快捷键
;tag 关闭程序
^1:: {
    ExitApp
}
;tag 暂停程序
^2:: {
    Pause
}
;tag 初始化并调整窗口大小
^3:: {
    AdjustSize(1920, 1080)
}
^4:: {
    AdjustSize(2331, 1311)
}
^5:: {
    AdjustSize(2560, 1440)
}
^6:: {
    AdjustSize(3580, 2014)
}
^7:: {
    AdjustSize(3840, 2160)
}
;tag 调试指定函数
^0:: {
    ;添加基本的依赖
    Initialization()
}
;endregion 快捷键
