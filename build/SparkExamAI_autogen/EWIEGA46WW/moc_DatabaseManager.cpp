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
    QByteArrayData data[90];
    char stringdata0[1349];
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
QT_MOC_LITERAL(33, 397, 18), // "deleteQuestionBank"
QT_MOC_LITERAL(34, 416, 6), // "bankId"
QT_MOC_LITERAL(35, 423, 19), // "getAllQuestionBanks"
QT_MOC_LITERAL(36, 443, 19), // "getQuestionBankById"
QT_MOC_LITERAL(37, 463, 18), // "updateQuestionBank"
QT_MOC_LITERAL(38, 482, 11), // "addQuestion"
QT_MOC_LITERAL(39, 494, 7), // "content"
QT_MOC_LITERAL(40, 502, 6), // "answer"
QT_MOC_LITERAL(41, 509, 8), // "analysis"
QT_MOC_LITERAL(42, 518, 7), // "options"
QT_MOC_LITERAL(43, 526, 14), // "deleteQuestion"
QT_MOC_LITERAL(44, 541, 10), // "questionId"
QT_MOC_LITERAL(45, 552, 14), // "updateQuestion"
QT_MOC_LITERAL(46, 567, 20), // "getQuestionsByBankId"
QT_MOC_LITERAL(47, 588, 15), // "getQuestionById"
QT_MOC_LITERAL(48, 604, 18), // "getRandomQuestions"
QT_MOC_LITERAL(49, 623, 5), // "count"
QT_MOC_LITERAL(50, 629, 15), // "importQuestions"
QT_MOC_LITERAL(51, 645, 9), // "questions"
QT_MOC_LITERAL(52, 655, 21), // "getAllKnowledgePoints"
QT_MOC_LITERAL(53, 677, 17), // "addKnowledgePoint"
QT_MOC_LITERAL(54, 695, 5), // "title"
QT_MOC_LITERAL(55, 701, 20), // "deleteKnowledgePoint"
QT_MOC_LITERAL(56, 722, 7), // "pointId"
QT_MOC_LITERAL(57, 730, 21), // "importKnowledgePoints"
QT_MOC_LITERAL(58, 752, 6), // "points"
QT_MOC_LITERAL(59, 759, 23), // "clearAllKnowledgePoints"
QT_MOC_LITERAL(60, 783, 20), // "saveUserAnswerRecord"
QT_MOC_LITERAL(61, 804, 8), // "userName"
QT_MOC_LITERAL(62, 813, 8), // "examType"
QT_MOC_LITERAL(63, 822, 14), // "totalQuestions"
QT_MOC_LITERAL(64, 837, 12), // "correctCount"
QT_MOC_LITERAL(65, 850, 10), // "answerData"
QT_MOC_LITERAL(66, 861, 16), // "questionBankInfo"
QT_MOC_LITERAL(67, 878, 12), // "pentagonType"
QT_MOC_LITERAL(68, 891, 20), // "getUserAnswerRecords"
QT_MOC_LITERAL(69, 912, 19), // "getAllAnswerRecords"
QT_MOC_LITERAL(70, 932, 32), // "getUserCurrentMonthQuestionCount"
QT_MOC_LITERAL(71, 965, 25), // "getUserYearlyQuestionData"
QT_MOC_LITERAL(72, 991, 30), // "getUserRollingYearQuestionData"
QT_MOC_LITERAL(73, 1022, 26), // "getMaxMonthlyQuestionCount"
QT_MOC_LITERAL(74, 1049, 18), // "getUserAbilityData"
QT_MOC_LITERAL(75, 1068, 19), // "getUserPracticeData"
QT_MOC_LITERAL(76, 1088, 26), // "getUserMonthlyPracticeData"
QT_MOC_LITERAL(77, 1115, 10), // "monthCount"
QT_MOC_LITERAL(78, 1126, 24), // "getUserDailyPracticeData"
QT_MOC_LITERAL(79, 1151, 4), // "year"
QT_MOC_LITERAL(80, 1156, 5), // "month"
QT_MOC_LITERAL(81, 1162, 19), // "getUserPentagonData"
QT_MOC_LITERAL(82, 1182, 20), // "saveUserBankProgress"
QT_MOC_LITERAL(83, 1203, 20), // "currentQuestionIndex"
QT_MOC_LITERAL(84, 1224, 15), // "userAnswersJson"
QT_MOC_LITERAL(85, 1240, 19), // "getUserBankProgress"
QT_MOC_LITERAL(86, 1260, 24), // "updateUserWrongQuestions"
QT_MOC_LITERAL(87, 1285, 16), // "wrongQuestionIds"
QT_MOC_LITERAL(88, 1302, 23), // "getUserWrongQuestionIds"
QT_MOC_LITERAL(89, 1326, 22) // "deleteUserBankProgress"

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
    "deleteQuestionBank\0bankId\0getAllQuestionBanks\0"
    "getQuestionBankById\0updateQuestionBank\0"
    "addQuestion\0content\0answer\0analysis\0"
    "options\0deleteQuestion\0questionId\0"
    "updateQuestion\0getQuestionsByBankId\0"
    "getQuestionById\0getRandomQuestions\0"
    "count\0importQuestions\0questions\0"
    "getAllKnowledgePoints\0addKnowledgePoint\0"
    "title\0deleteKnowledgePoint\0pointId\0"
    "importKnowledgePoints\0points\0"
    "clearAllKnowledgePoints\0saveUserAnswerRecord\0"
    "userName\0examType\0totalQuestions\0"
    "correctCount\0answerData\0questionBankInfo\0"
    "pentagonType\0getUserAnswerRecords\0"
    "getAllAnswerRecords\0"
    "getUserCurrentMonthQuestionCount\0"
    "getUserYearlyQuestionData\0"
    "getUserRollingYearQuestionData\0"
    "getMaxMonthlyQuestionCount\0"
    "getUserAbilityData\0getUserPracticeData\0"
    "getUserMonthlyPracticeData\0monthCount\0"
    "getUserDailyPracticeData\0year\0month\0"
    "getUserPentagonData\0saveUserBankProgress\0"
    "currentQuestionIndex\0userAnswersJson\0"
    "getUserBankProgress\0updateUserWrongQuestions\0"
    "wrongQuestionIds\0getUserWrongQuestionIds\0"
    "deleteUserBankProgress"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_DatabaseManager[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
      68,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // methods: name, argc, parameters, tag, flags
       1,    0,  354,    2, 0x02 /* Public */,
       3,    6,  355,    2, 0x02 /* Public */,
       3,    5,  368,    2, 0x22 /* Public | MethodCloned */,
      10,    1,  379,    2, 0x02 /* Public */,
      11,    0,  382,    2, 0x02 /* Public */,
      12,    0,  383,    2, 0x02 /* Public */,
      13,    1,  384,    2, 0x02 /* Public */,
      14,    2,  387,    2, 0x02 /* Public */,
      15,    1,  392,    2, 0x02 /* Public */,
      16,    6,  395,    2, 0x02 /* Public */,
      16,    5,  408,    2, 0x22 /* Public | MethodCloned */,
      17,    2,  419,    2, 0x02 /* Public */,
      20,    2,  424,    2, 0x02 /* Public */,
      20,    1,  429,    2, 0x22 /* Public | MethodCloned */,
      22,    1,  432,    2, 0x02 /* Public */,
      23,    0,  435,    2, 0x02 /* Public */,
      24,    2,  436,    2, 0x02 /* Public */,
      24,    1,  441,    2, 0x22 /* Public | MethodCloned */,
      24,    0,  444,    2, 0x22 /* Public | MethodCloned */,
      27,    3,  445,    2, 0x02 /* Public */,
      27,    2,  452,    2, 0x22 /* Public | MethodCloned */,
      27,    1,  457,    2, 0x22 /* Public | MethodCloned */,
      28,    1,  460,    2, 0x02 /* Public */,
      28,    0,  463,    2, 0x22 /* Public | MethodCloned */,
      30,    1,  464,    2, 0x02 /* Public */,
      31,    2,  467,    2, 0x02 /* Public */,
      33,    1,  472,    2, 0x02 /* Public */,
      35,    0,  475,    2, 0x02 /* Public */,
      36,    1,  476,    2, 0x02 /* Public */,
      37,    2,  479,    2, 0x02 /* Public */,
      38,    5,  484,    2, 0x02 /* Public */,
      38,    4,  495,    2, 0x22 /* Public | MethodCloned */,
      43,    1,  504,    2, 0x02 /* Public */,
      45,    5,  507,    2, 0x02 /* Public */,
      45,    4,  518,    2, 0x22 /* Public | MethodCloned */,
      46,    1,  527,    2, 0x02 /* Public */,
      47,    1,  530,    2, 0x02 /* Public */,
      48,    2,  533,    2, 0x02 /* Public */,
      50,    2,  538,    2, 0x02 /* Public */,
      52,    0,  543,    2, 0x02 /* Public */,
      53,    2,  544,    2, 0x02 /* Public */,
      55,    1,  549,    2, 0x02 /* Public */,
      57,    1,  552,    2, 0x02 /* Public */,
      59,    0,  555,    2, 0x02 /* Public */,
      60,    8,  556,    2, 0x02 /* Public */,
      60,    7,  573,    2, 0x22 /* Public | MethodCloned */,
      60,    6,  588,    2, 0x22 /* Public | MethodCloned */,
      68,    3,  601,    2, 0x02 /* Public */,
      68,    2,  608,    2, 0x22 /* Public | MethodCloned */,
      68,    1,  613,    2, 0x22 /* Public | MethodCloned */,
      69,    2,  616,    2, 0x02 /* Public */,
      69,    1,  621,    2, 0x22 /* Public | MethodCloned */,
      69,    0,  624,    2, 0x22 /* Public | MethodCloned */,
      70,    1,  625,    2, 0x02 /* Public */,
      71,    1,  628,    2, 0x02 /* Public */,
      72,    1,  631,    2, 0x02 /* Public */,
      73,    0,  634,    2, 0x02 /* Public */,
      74,    1,  635,    2, 0x02 /* Public */,
      75,    1,  638,    2, 0x02 /* Public */,
      76,    2,  641,    2, 0x02 /* Public */,
      76,    1,  646,    2, 0x22 /* Public | MethodCloned */,
      78,    3,  649,    2, 0x02 /* Public */,
      81,    1,  656,    2, 0x02 /* Public */,
      82,    4,  659,    2, 0x02 /* Public */,
      85,    2,  668,    2, 0x02 /* Public */,
      86,    3,  673,    2, 0x02 /* Public */,
      88,    2,  680,    2, 0x02 /* Public */,
      89,    2,  685,    2, 0x02 /* Public */,

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
    QMetaType::Bool, QMetaType::Int,   34,
    QMetaType::QVariantList,
    QMetaType::QVariantMap, QMetaType::Int,   34,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString,   34,    4,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QStringList,   34,   39,   40,   41,   42,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString,   34,   39,   40,   41,
    QMetaType::Bool, QMetaType::Int,   44,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QStringList,   44,   39,   40,   41,   42,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString,   44,   39,   40,   41,
    QMetaType::QVariantList, QMetaType::Int,   34,
    QMetaType::QVariantMap, QMetaType::Int,   44,
    QMetaType::QVariantList, QMetaType::Int, QMetaType::Int,   34,   49,
    QMetaType::Bool, QMetaType::Int, QMetaType::QVariantList,   34,   51,
    QMetaType::QVariantList,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString,   54,   39,
    QMetaType::Bool, QMetaType::Int,   56,
    QMetaType::Bool, QMetaType::QVariantList,   58,
    QMetaType::Bool,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Int, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString,    6,   61,   62,   63,   64,   65,   66,   67,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Int, QMetaType::Int, QMetaType::QString, QMetaType::QString,    6,   61,   62,   63,   64,   65,   66,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Int, QMetaType::Int, QMetaType::QString,    6,   61,   62,   63,   64,   65,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int, QMetaType::Int,    6,   25,   26,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int,    6,   25,
    QMetaType::QVariantList, QMetaType::QString,    6,
    QMetaType::QVariantList, QMetaType::Int, QMetaType::Int,   25,   26,
    QMetaType::QVariantList, QMetaType::Int,   25,
    QMetaType::QVariantList,
    QMetaType::Int, QMetaType::QString,    6,
    QMetaType::QVariantList, QMetaType::QString,    6,
    QMetaType::QVariantList, QMetaType::QString,    6,
    QMetaType::Int,
    QMetaType::QVariantMap, QMetaType::QString,    6,
    QMetaType::QVariantMap, QMetaType::QString,    6,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int,    6,   77,
    QMetaType::QVariantList, QMetaType::QString,    6,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int, QMetaType::Int,    6,   79,   80,
    QMetaType::QVariantMap, QMetaType::QString,    6,
    QMetaType::Bool, QMetaType::QString, QMetaType::Int, QMetaType::Int, QMetaType::QString,    6,   34,   83,   84,
    QMetaType::QVariantMap, QMetaType::QString, QMetaType::Int,    6,   34,
    QMetaType::Bool, QMetaType::QString, QMetaType::Int, QMetaType::QVariantList,    6,   34,   87,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int,    6,   34,
    QMetaType::Bool, QMetaType::QString, QMetaType::Int,    6,   34,

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
        case 26: { bool _r = _t->deleteQuestionBank((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 27: { QVariantList _r = _t->getAllQuestionBanks();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 28: { QVariantMap _r = _t->getQuestionBankById((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 29: { bool _r = _t->updateQuestionBank((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 30: { bool _r = _t->addQuestion((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QStringList(*)>(_a[5])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 31: { bool _r = _t->addQuestion((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 32: { bool _r = _t->deleteQuestion((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 33: { bool _r = _t->updateQuestion((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QStringList(*)>(_a[5])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 34: { bool _r = _t->updateQuestion((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 35: { QVariantList _r = _t->getQuestionsByBankId((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 36: { QVariantMap _r = _t->getQuestionById((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 37: { QVariantList _r = _t->getRandomQuestions((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 38: { bool _r = _t->importQuestions((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QVariantList(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 39: { QVariantList _r = _t->getAllKnowledgePoints();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 40: { bool _r = _t->addKnowledgePoint((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 41: { bool _r = _t->deleteKnowledgePoint((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 42: { bool _r = _t->importKnowledgePoints((*reinterpret_cast< const QVariantList(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 43: { bool _r = _t->clearAllKnowledgePoints();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 44: { bool _r = _t->saveUserAnswerRecord((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< int(*)>(_a[4])),(*reinterpret_cast< int(*)>(_a[5])),(*reinterpret_cast< const QString(*)>(_a[6])),(*reinterpret_cast< const QString(*)>(_a[7])),(*reinterpret_cast< const QString(*)>(_a[8])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 45: { bool _r = _t->saveUserAnswerRecord((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< int(*)>(_a[4])),(*reinterpret_cast< int(*)>(_a[5])),(*reinterpret_cast< const QString(*)>(_a[6])),(*reinterpret_cast< const QString(*)>(_a[7])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 46: { bool _r = _t->saveUserAnswerRecord((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< int(*)>(_a[4])),(*reinterpret_cast< int(*)>(_a[5])),(*reinterpret_cast< const QString(*)>(_a[6])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 47: { QVariantList _r = _t->getUserAnswerRecords((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])),(*reinterpret_cast< int(*)>(_a[3])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 48: { QVariantList _r = _t->getUserAnswerRecords((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 49: { QVariantList _r = _t->getUserAnswerRecords((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 50: { QVariantList _r = _t->getAllAnswerRecords((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 51: { QVariantList _r = _t->getAllAnswerRecords((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 52: { QVariantList _r = _t->getAllAnswerRecords();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 53: { int _r = _t->getUserCurrentMonthQuestionCount((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = std::move(_r); }  break;
        case 54: { QVariantList _r = _t->getUserYearlyQuestionData((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 55: { QVariantList _r = _t->getUserRollingYearQuestionData((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 56: { int _r = _t->getMaxMonthlyQuestionCount();
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = std::move(_r); }  break;
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
        case 63: { bool _r = _t->saveUserBankProgress((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])),(*reinterpret_cast< int(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 64: { QVariantMap _r = _t->getUserBankProgress((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 65: { bool _r = _t->updateUserWrongQuestions((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])),(*reinterpret_cast< const QVariantList(*)>(_a[3])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 66: { QVariantList _r = _t->getUserWrongQuestionIds((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 67: { bool _r = _t->deleteUserBankProgress((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
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
        if (_id < 68)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 68;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 68)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 68;
    }
    return _id;
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
