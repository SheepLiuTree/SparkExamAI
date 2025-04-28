/****************************************************************************
** Meta object code from reading C++ file 'DatabaseManager.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../../DatabaseManager.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'DatabaseManager.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_DatabaseManager_t {
    QByteArrayData data[91];
    char stringdata0[1335];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_DatabaseManager_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_DatabaseManager_t qt_meta_stringdata_DatabaseManager = {
    {
QT_MOC_LITERAL(0, 0, 15), // "DatabaseManager"
QT_MOC_LITERAL(1, 16, 12), // "initDatabase"
QT_MOC_LITERAL(2, 29, 0), // ""
QT_MOC_LITERAL(3, 30, 11), // "addFaceData"
QT_MOC_LITERAL(4, 42, 4), // "name"
QT_MOC_LITERAL(5, 47, 6), // "gender"
QT_MOC_LITERAL(6, 54, 6), // "workId"
QT_MOC_LITERAL(7, 61, 13), // "faceImagePath"
QT_MOC_LITERAL(8, 75, 10), // "avatarPath"
QT_MOC_LITERAL(9, 86, 7), // "isAdmin"
QT_MOC_LITERAL(10, 94, 14), // "deleteFaceData"
QT_MOC_LITERAL(11, 109, 14), // "getAllFaceData"
QT_MOC_LITERAL(12, 124, 20), // "getAllFaceDataSorted"
QT_MOC_LITERAL(13, 145, 19), // "getFaceDataByWorkId"
QT_MOC_LITERAL(14, 165, 10), // "verifyFace"
QT_MOC_LITERAL(15, 176, 10), // "userExists"
QT_MOC_LITERAL(16, 187, 14), // "updateFaceData"
QT_MOC_LITERAL(17, 202, 10), // "setSetting"
QT_MOC_LITERAL(18, 213, 3), // "key"
QT_MOC_LITERAL(19, 217, 5), // "value"
QT_MOC_LITERAL(20, 223, 10), // "getSetting"
QT_MOC_LITERAL(21, 234, 12), // "defaultValue"
QT_MOC_LITERAL(22, 247, 13), // "deleteSetting"
QT_MOC_LITERAL(23, 261, 14), // "getAllSettings"
QT_MOC_LITERAL(24, 276, 13), // "getAccessLogs"
QT_MOC_LITERAL(25, 290, 5), // "limit"
QT_MOC_LITERAL(26, 296, 6), // "offset"
QT_MOC_LITERAL(27, 303, 19), // "getAccessLogsByUser"
QT_MOC_LITERAL(28, 323, 14), // "cleanupOldLogs"
QT_MOC_LITERAL(29, 338, 10), // "daysToKeep"
QT_MOC_LITERAL(30, 349, 17), // "getUserAvatarPath"
QT_MOC_LITERAL(31, 367, 15), // "addQuestionBank"
QT_MOC_LITERAL(32, 383, 13), // "questionCount"
QT_MOC_LITERAL(33, 397, 16), // "getQuestionBanks"
QT_MOC_LITERAL(34, 414, 18), // "deleteQuestionBank"
QT_MOC_LITERAL(35, 433, 6), // "bankId"
QT_MOC_LITERAL(36, 440, 11), // "addQuestion"
QT_MOC_LITERAL(37, 452, 7), // "content"
QT_MOC_LITERAL(38, 460, 6), // "answer"
QT_MOC_LITERAL(39, 467, 8), // "analysis"
QT_MOC_LITERAL(40, 476, 7), // "options"
QT_MOC_LITERAL(41, 484, 20), // "getQuestionsByBankId"
QT_MOC_LITERAL(42, 505, 15), // "getQuestionById"
QT_MOC_LITERAL(43, 521, 10), // "questionId"
QT_MOC_LITERAL(44, 532, 16), // "getQuestionCount"
QT_MOC_LITERAL(45, 549, 20), // "saveUserAnswerRecord"
QT_MOC_LITERAL(46, 570, 8), // "userName"
QT_MOC_LITERAL(47, 579, 8), // "examType"
QT_MOC_LITERAL(48, 588, 14), // "totalQuestions"
QT_MOC_LITERAL(49, 603, 12), // "correctCount"
QT_MOC_LITERAL(50, 616, 10), // "answerData"
QT_MOC_LITERAL(51, 627, 16), // "questionBankInfo"
QT_MOC_LITERAL(52, 644, 12), // "pentagonType"
QT_MOC_LITERAL(53, 657, 20), // "getUserAnswerRecords"
QT_MOC_LITERAL(54, 678, 16), // "saveUserProgress"
QT_MOC_LITERAL(55, 695, 14), // "questionBankId"
QT_MOC_LITERAL(56, 710, 18), // "wrongQuestionsMode"
QT_MOC_LITERAL(57, 729, 20), // "currentQuestionIndex"
QT_MOC_LITERAL(58, 750, 11), // "userAnswers"
QT_MOC_LITERAL(59, 762, 15), // "getUserProgress"
QT_MOC_LITERAL(60, 778, 18), // "deleteUserProgress"
QT_MOC_LITERAL(61, 797, 19), // "getAllQuestionBanks"
QT_MOC_LITERAL(62, 817, 19), // "getQuestionBankById"
QT_MOC_LITERAL(63, 837, 18), // "updateQuestionBank"
QT_MOC_LITERAL(64, 856, 14), // "deleteQuestion"
QT_MOC_LITERAL(65, 871, 14), // "updateQuestion"
QT_MOC_LITERAL(66, 886, 18), // "getRandomQuestions"
QT_MOC_LITERAL(67, 905, 5), // "count"
QT_MOC_LITERAL(68, 911, 15), // "importQuestions"
QT_MOC_LITERAL(69, 927, 9), // "questions"
QT_MOC_LITERAL(70, 937, 21), // "getAllKnowledgePoints"
QT_MOC_LITERAL(71, 959, 17), // "addKnowledgePoint"
QT_MOC_LITERAL(72, 977, 5), // "title"
QT_MOC_LITERAL(73, 983, 20), // "deleteKnowledgePoint"
QT_MOC_LITERAL(74, 1004, 7), // "pointId"
QT_MOC_LITERAL(75, 1012, 21), // "importKnowledgePoints"
QT_MOC_LITERAL(76, 1034, 6), // "points"
QT_MOC_LITERAL(77, 1041, 23), // "clearAllKnowledgePoints"
QT_MOC_LITERAL(78, 1065, 18), // "getUserAbilityData"
QT_MOC_LITERAL(79, 1084, 19), // "getUserPracticeData"
QT_MOC_LITERAL(80, 1104, 26), // "getUserMonthlyPracticeData"
QT_MOC_LITERAL(81, 1131, 10), // "monthCount"
QT_MOC_LITERAL(82, 1142, 24), // "getUserDailyPracticeData"
QT_MOC_LITERAL(83, 1167, 4), // "year"
QT_MOC_LITERAL(84, 1172, 5), // "month"
QT_MOC_LITERAL(85, 1178, 19), // "getUserPentagonData"
QT_MOC_LITERAL(86, 1198, 19), // "getAllAnswerRecords"
QT_MOC_LITERAL(87, 1218, 32), // "getUserCurrentMonthQuestionCount"
QT_MOC_LITERAL(88, 1251, 25), // "getUserYearlyQuestionData"
QT_MOC_LITERAL(89, 1277, 30), // "getUserRollingYearQuestionData"
QT_MOC_LITERAL(90, 1308, 26) // "getMaxMonthlyQuestionCount"

    },
    "DatabaseManager\0initDatabase\0\0addFaceData\0"
    "name\0gender\0workId\0faceImagePath\0"
    "avatarPath\0isAdmin\0deleteFaceData\0"
    "getAllFaceData\0getAllFaceDataSorted\0"
    "getFaceDataByWorkId\0verifyFace\0"
    "userExists\0updateFaceData\0setSetting\0"
    "key\0value\0getSetting\0defaultValue\0"
    "deleteSetting\0getAllSettings\0getAccessLogs\0"
    "limit\0offset\0getAccessLogsByUser\0"
    "cleanupOldLogs\0daysToKeep\0getUserAvatarPath\0"
    "addQuestionBank\0questionCount\0"
    "getQuestionBanks\0deleteQuestionBank\0"
    "bankId\0addQuestion\0content\0answer\0"
    "analysis\0options\0getQuestionsByBankId\0"
    "getQuestionById\0questionId\0getQuestionCount\0"
    "saveUserAnswerRecord\0userName\0examType\0"
    "totalQuestions\0correctCount\0answerData\0"
    "questionBankInfo\0pentagonType\0"
    "getUserAnswerRecords\0saveUserProgress\0"
    "questionBankId\0wrongQuestionsMode\0"
    "currentQuestionIndex\0userAnswers\0"
    "getUserProgress\0deleteUserProgress\0"
    "getAllQuestionBanks\0getQuestionBankById\0"
    "updateQuestionBank\0deleteQuestion\0"
    "updateQuestion\0getRandomQuestions\0"
    "count\0importQuestions\0questions\0"
    "getAllKnowledgePoints\0addKnowledgePoint\0"
    "title\0deleteKnowledgePoint\0pointId\0"
    "importKnowledgePoints\0points\0"
    "clearAllKnowledgePoints\0getUserAbilityData\0"
    "getUserPracticeData\0getUserMonthlyPracticeData\0"
    "monthCount\0getUserDailyPracticeData\0"
    "year\0month\0getUserPentagonData\0"
    "getAllAnswerRecords\0"
    "getUserCurrentMonthQuestionCount\0"
    "getUserYearlyQuestionData\0"
    "getUserRollingYearQuestionData\0"
    "getMaxMonthlyQuestionCount"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_DatabaseManager[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
      70,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // methods: name, argc, parameters, tag, flags
       1,    0,  364,    2, 0x02 /* Public */,
       3,    6,  365,    2, 0x02 /* Public */,
       3,    5,  378,    2, 0x22 /* Public | MethodCloned */,
      10,    1,  389,    2, 0x02 /* Public */,
      11,    0,  392,    2, 0x02 /* Public */,
      12,    0,  393,    2, 0x02 /* Public */,
      13,    1,  394,    2, 0x02 /* Public */,
      14,    2,  397,    2, 0x02 /* Public */,
      15,    1,  402,    2, 0x02 /* Public */,
      16,    6,  405,    2, 0x02 /* Public */,
      16,    5,  418,    2, 0x22 /* Public | MethodCloned */,
      17,    2,  429,    2, 0x02 /* Public */,
      20,    2,  434,    2, 0x02 /* Public */,
      20,    1,  439,    2, 0x22 /* Public | MethodCloned */,
      22,    1,  442,    2, 0x02 /* Public */,
      23,    0,  445,    2, 0x02 /* Public */,
      24,    2,  446,    2, 0x02 /* Public */,
      24,    1,  451,    2, 0x22 /* Public | MethodCloned */,
      24,    0,  454,    2, 0x22 /* Public | MethodCloned */,
      27,    3,  455,    2, 0x02 /* Public */,
      27,    2,  462,    2, 0x22 /* Public | MethodCloned */,
      27,    1,  467,    2, 0x22 /* Public | MethodCloned */,
      28,    1,  470,    2, 0x02 /* Public */,
      28,    0,  473,    2, 0x22 /* Public | MethodCloned */,
      30,    1,  474,    2, 0x02 /* Public */,
      31,    2,  477,    2, 0x02 /* Public */,
      33,    0,  482,    2, 0x02 /* Public */,
      34,    1,  483,    2, 0x02 /* Public */,
      36,    5,  486,    2, 0x02 /* Public */,
      41,    1,  497,    2, 0x02 /* Public */,
      42,    1,  500,    2, 0x02 /* Public */,
      44,    1,  503,    2, 0x02 /* Public */,
      45,    8,  506,    2, 0x02 /* Public */,
      45,    7,  523,    2, 0x22 /* Public | MethodCloned */,
      45,    6,  538,    2, 0x22 /* Public | MethodCloned */,
      53,    3,  551,    2, 0x02 /* Public */,
      53,    2,  558,    2, 0x22 /* Public | MethodCloned */,
      53,    1,  563,    2, 0x22 /* Public | MethodCloned */,
      54,    5,  566,    2, 0x02 /* Public */,
      59,    3,  577,    2, 0x02 /* Public */,
      60,    3,  584,    2, 0x02 /* Public */,
      61,    0,  591,    2, 0x02 /* Public */,
      62,    1,  592,    2, 0x02 /* Public */,
      63,    2,  595,    2, 0x02 /* Public */,
      36,    5,  600,    2, 0x02 /* Public */,
      36,    4,  611,    2, 0x22 /* Public | MethodCloned */,
      64,    1,  620,    2, 0x02 /* Public */,
      65,    5,  623,    2, 0x02 /* Public */,
      65,    4,  634,    2, 0x22 /* Public | MethodCloned */,
      65,    5,  643,    2, 0x02 /* Public */,
      66,    2,  654,    2, 0x02 /* Public */,
      68,    2,  659,    2, 0x02 /* Public */,
      70,    0,  664,    2, 0x02 /* Public */,
      71,    2,  665,    2, 0x02 /* Public */,
      73,    1,  670,    2, 0x02 /* Public */,
      75,    1,  673,    2, 0x02 /* Public */,
      77,    0,  676,    2, 0x02 /* Public */,
      78,    1,  677,    2, 0x02 /* Public */,
      79,    1,  680,    2, 0x02 /* Public */,
      80,    2,  683,    2, 0x02 /* Public */,
      80,    1,  688,    2, 0x22 /* Public | MethodCloned */,
      82,    3,  691,    2, 0x02 /* Public */,
      85,    1,  698,    2, 0x02 /* Public */,
      86,    2,  701,    2, 0x02 /* Public */,
      86,    1,  706,    2, 0x22 /* Public | MethodCloned */,
      86,    0,  709,    2, 0x22 /* Public | MethodCloned */,
      87,    1,  710,    2, 0x02 /* Public */,
      88,    1,  713,    2, 0x02 /* Public */,
      89,    1,  716,    2, 0x02 /* Public */,
      90,    0,  719,    2, 0x02 /* Public */,

 // methods: parameters
    QMetaType::Bool,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Bool,    4,    5,    6,    7,    8,    9,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString,    4,    5,    6,    7,    8,
    QMetaType::Bool, QMetaType::QString,    6,
    QMetaType::QVariantList,
    QMetaType::QVariantList,
    QMetaType::QVariantMap, QMetaType::QString,    6,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString,    6,    7,
    QMetaType::Bool, QMetaType::QString,    6,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Bool,    6,    4,    5,    7,    8,    9,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString,    6,    4,    5,    7,    8,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString,   18,   19,
    QMetaType::QString, QMetaType::QString, QMetaType::QString,   18,   21,
    QMetaType::QString, QMetaType::QString,   18,
    QMetaType::Bool, QMetaType::QString,   18,
    QMetaType::QVariantMap,
    QMetaType::QVariantList, QMetaType::Int, QMetaType::Int,   25,   26,
    QMetaType::QVariantList, QMetaType::Int,   25,
    QMetaType::QVariantList,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int, QMetaType::Int,    6,   25,   26,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int,    6,   25,
    QMetaType::QVariantList, QMetaType::QString,    6,
    QMetaType::Bool, QMetaType::Int,   29,
    QMetaType::Bool,
    QMetaType::QString, QMetaType::QString,    6,
    QMetaType::Bool, QMetaType::QString, QMetaType::Int,    4,   32,
    QMetaType::QVariantList,
    QMetaType::Bool, QMetaType::Int,   35,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QVariantList,   35,   37,   38,   39,   40,
    QMetaType::QVariantList, QMetaType::Int,   35,
    QMetaType::QVariantMap, QMetaType::Int,   43,
    QMetaType::Int, QMetaType::Int,   35,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Int, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString,    6,   46,   47,   48,   49,   50,   51,   52,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Int, QMetaType::Int, QMetaType::QString, QMetaType::QString,    6,   46,   47,   48,   49,   50,   51,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Int, QMetaType::Int, QMetaType::QString,    6,   46,   47,   48,   49,   50,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int, QMetaType::Int,    6,   25,   26,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int,    6,   25,
    QMetaType::QVariantList, QMetaType::QString,    6,
    QMetaType::Bool, QMetaType::QString, QMetaType::Int, QMetaType::Bool, QMetaType::Int, QMetaType::QString,    6,   55,   56,   57,   58,
    QMetaType::QString, QMetaType::QString, QMetaType::Int, QMetaType::Bool,    6,   55,   56,
    QMetaType::Bool, QMetaType::QString, QMetaType::Int, QMetaType::Bool,    6,   55,   56,
    QMetaType::QVariantList,
    QMetaType::QVariantMap, QMetaType::Int,   35,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString,   35,    4,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QStringList,   35,   37,   38,   39,   40,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString,   35,   37,   38,   39,
    QMetaType::Bool, QMetaType::Int,   43,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QStringList,   43,   37,   38,   39,   40,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString,   43,   37,   38,   39,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QVariantList,   43,   37,   38,   39,   40,
    QMetaType::QVariantList, QMetaType::Int, QMetaType::Int,   35,   67,
    QMetaType::Bool, QMetaType::Int, QMetaType::QVariantList,   35,   69,
    QMetaType::QVariantList,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString,   72,   37,
    QMetaType::Bool, QMetaType::Int,   74,
    QMetaType::Bool, QMetaType::QVariantList,   76,
    QMetaType::Bool,
    QMetaType::QVariantMap, QMetaType::QString,    6,
    QMetaType::QVariantMap, QMetaType::QString,    6,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int,    6,   81,
    QMetaType::QVariantList, QMetaType::QString,    6,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int, QMetaType::Int,    6,   83,   84,
    QMetaType::QVariantMap, QMetaType::QString,    6,
    QMetaType::QVariantList, QMetaType::Int, QMetaType::Int,   25,   26,
    QMetaType::QVariantList, QMetaType::Int,   25,
    QMetaType::QVariantList,
    QMetaType::Int, QMetaType::QString,    6,
    QMetaType::QVariantList, QMetaType::QString,    6,
    QMetaType::QVariantList, QMetaType::QString,    6,
    QMetaType::Int,

       0        // eod
};

void DatabaseManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<DatabaseManager *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: { bool _r = _t->initDatabase();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 1: { bool _r = _t->addFaceData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QString(*)>(_a[5])),(*reinterpret_cast< bool(*)>(_a[6])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 2: { bool _r = _t->addFaceData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QString(*)>(_a[5])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 3: { bool _r = _t->deleteFaceData((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 4: { QVariantList _r = _t->getAllFaceData();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 5: { QVariantList _r = _t->getAllFaceDataSorted();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 6: { QVariantMap _r = _t->getFaceDataByWorkId((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 7: { bool _r = _t->verifyFace((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 8: { bool _r = _t->userExists((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 9: { bool _r = _t->updateFaceData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QString(*)>(_a[5])),(*reinterpret_cast< bool(*)>(_a[6])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 10: { bool _r = _t->updateFaceData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QString(*)>(_a[5])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 11: { bool _r = _t->setSetting((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 12: { QString _r = _t->getSetting((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 13: { QString _r = _t->getSetting((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 14: { bool _r = _t->deleteSetting((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 15: { QVariantMap _r = _t->getAllSettings();
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 16: { QVariantList _r = _t->getAccessLogs((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 17: { QVariantList _r = _t->getAccessLogs((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 18: { QVariantList _r = _t->getAccessLogs();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 19: { QVariantList _r = _t->getAccessLogsByUser((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])),(*reinterpret_cast< int(*)>(_a[3])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 20: { QVariantList _r = _t->getAccessLogsByUser((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 21: { QVariantList _r = _t->getAccessLogsByUser((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 22: { bool _r = _t->cleanupOldLogs((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 23: { bool _r = _t->cleanupOldLogs();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 24: { QString _r = _t->getUserAvatarPath((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 25: { bool _r = _t->addQuestionBank((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 26: { QVariantList _r = _t->getQuestionBanks();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 27: { bool _r = _t->deleteQuestionBank((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 28: { bool _r = _t->addQuestion((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QVariantList(*)>(_a[5])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 29: { QVariantList _r = _t->getQuestionsByBankId((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 30: { QVariantMap _r = _t->getQuestionById((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 31: { int _r = _t->getQuestionCount((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = std::move(_r); }  break;
        case 32: { bool _r = _t->saveUserAnswerRecord((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< int(*)>(_a[4])),(*reinterpret_cast< int(*)>(_a[5])),(*reinterpret_cast< const QString(*)>(_a[6])),(*reinterpret_cast< const QString(*)>(_a[7])),(*reinterpret_cast< const QString(*)>(_a[8])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 33: { bool _r = _t->saveUserAnswerRecord((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< int(*)>(_a[4])),(*reinterpret_cast< int(*)>(_a[5])),(*reinterpret_cast< const QString(*)>(_a[6])),(*reinterpret_cast< const QString(*)>(_a[7])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 34: { bool _r = _t->saveUserAnswerRecord((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< int(*)>(_a[4])),(*reinterpret_cast< int(*)>(_a[5])),(*reinterpret_cast< const QString(*)>(_a[6])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 35: { QVariantList _r = _t->getUserAnswerRecords((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])),(*reinterpret_cast< int(*)>(_a[3])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 36: { QVariantList _r = _t->getUserAnswerRecords((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 37: { QVariantList _r = _t->getUserAnswerRecords((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 38: { bool _r = _t->saveUserProgress((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])),(*reinterpret_cast< bool(*)>(_a[3])),(*reinterpret_cast< int(*)>(_a[4])),(*reinterpret_cast< const QString(*)>(_a[5])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 39: { QString _r = _t->getUserProgress((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])),(*reinterpret_cast< bool(*)>(_a[3])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 40: { bool _r = _t->deleteUserProgress((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])),(*reinterpret_cast< bool(*)>(_a[3])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 41: { QVariantList _r = _t->getAllQuestionBanks();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 42: { QVariantMap _r = _t->getQuestionBankById((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 43: { bool _r = _t->updateQuestionBank((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 44: { bool _r = _t->addQuestion((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QStringList(*)>(_a[5])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 45: { bool _r = _t->addQuestion((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 46: { bool _r = _t->deleteQuestion((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 47: { bool _r = _t->updateQuestion((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QStringList(*)>(_a[5])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 48: { bool _r = _t->updateQuestion((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 49: { bool _r = _t->updateQuestion((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QVariantList(*)>(_a[5])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 50: { QVariantList _r = _t->getRandomQuestions((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 51: { bool _r = _t->importQuestions((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QVariantList(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 52: { QVariantList _r = _t->getAllKnowledgePoints();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 53: { bool _r = _t->addKnowledgePoint((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 54: { bool _r = _t->deleteKnowledgePoint((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 55: { bool _r = _t->importKnowledgePoints((*reinterpret_cast< const QVariantList(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 56: { bool _r = _t->clearAllKnowledgePoints();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 57: { QVariantMap _r = _t->getUserAbilityData((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 58: { QVariantMap _r = _t->getUserPracticeData((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 59: { QVariantList _r = _t->getUserMonthlyPracticeData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 60: { QVariantList _r = _t->getUserMonthlyPracticeData((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 61: { QVariantList _r = _t->getUserDailyPracticeData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])),(*reinterpret_cast< int(*)>(_a[3])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 62: { QVariantMap _r = _t->getUserPentagonData((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 63: { QVariantList _r = _t->getAllAnswerRecords((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 64: { QVariantList _r = _t->getAllAnswerRecords((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 65: { QVariantList _r = _t->getAllAnswerRecords();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 66: { int _r = _t->getUserCurrentMonthQuestionCount((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = std::move(_r); }  break;
        case 67: { QVariantList _r = _t->getUserYearlyQuestionData((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 68: { QVariantList _r = _t->getUserRollingYearQuestionData((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 69: { int _r = _t->getMaxMonthlyQuestionCount();
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    }
}

QT_INIT_METAOBJECT const QMetaObject DatabaseManager::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_DatabaseManager.data,
    qt_meta_data_DatabaseManager,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *DatabaseManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *DatabaseManager::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_DatabaseManager.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int DatabaseManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 70)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 70;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 70)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 70;
    }
    return _id;
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
