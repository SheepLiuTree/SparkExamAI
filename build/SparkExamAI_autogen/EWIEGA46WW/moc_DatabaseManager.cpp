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
    QByteArrayData data[96];
    char stringdata0[1438];
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
QT_MOC_LITERAL(10, 94, 8), // "password"
QT_MOC_LITERAL(11, 103, 11), // "addUserData"
QT_MOC_LITERAL(12, 115, 14), // "deleteFaceData"
QT_MOC_LITERAL(13, 130, 14), // "getAllFaceData"
QT_MOC_LITERAL(14, 145, 20), // "getAllFaceDataSorted"
QT_MOC_LITERAL(15, 166, 19), // "getFaceDataByWorkId"
QT_MOC_LITERAL(16, 186, 10), // "verifyFace"
QT_MOC_LITERAL(17, 197, 10), // "userExists"
QT_MOC_LITERAL(18, 208, 14), // "updateFaceData"
QT_MOC_LITERAL(19, 223, 14), // "verifyPassword"
QT_MOC_LITERAL(20, 238, 21), // "verifyUserCredentials"
QT_MOC_LITERAL(21, 260, 18), // "updateUserPassword"
QT_MOC_LITERAL(22, 279, 11), // "newPassword"
QT_MOC_LITERAL(23, 291, 10), // "setSetting"
QT_MOC_LITERAL(24, 302, 3), // "key"
QT_MOC_LITERAL(25, 306, 5), // "value"
QT_MOC_LITERAL(26, 312, 10), // "getSetting"
QT_MOC_LITERAL(27, 323, 12), // "defaultValue"
QT_MOC_LITERAL(28, 336, 13), // "deleteSetting"
QT_MOC_LITERAL(29, 350, 14), // "getAllSettings"
QT_MOC_LITERAL(30, 365, 13), // "getAccessLogs"
QT_MOC_LITERAL(31, 379, 5), // "limit"
QT_MOC_LITERAL(32, 385, 6), // "offset"
QT_MOC_LITERAL(33, 392, 19), // "getAccessLogsByUser"
QT_MOC_LITERAL(34, 412, 14), // "cleanupOldLogs"
QT_MOC_LITERAL(35, 427, 10), // "daysToKeep"
QT_MOC_LITERAL(36, 438, 17), // "getUserAvatarPath"
QT_MOC_LITERAL(37, 456, 15), // "addQuestionBank"
QT_MOC_LITERAL(38, 472, 13), // "questionCount"
QT_MOC_LITERAL(39, 486, 18), // "deleteQuestionBank"
QT_MOC_LITERAL(40, 505, 6), // "bankId"
QT_MOC_LITERAL(41, 512, 19), // "getAllQuestionBanks"
QT_MOC_LITERAL(42, 532, 19), // "getQuestionBankById"
QT_MOC_LITERAL(43, 552, 18), // "updateQuestionBank"
QT_MOC_LITERAL(44, 571, 11), // "addQuestion"
QT_MOC_LITERAL(45, 583, 7), // "content"
QT_MOC_LITERAL(46, 591, 6), // "answer"
QT_MOC_LITERAL(47, 598, 8), // "analysis"
QT_MOC_LITERAL(48, 607, 7), // "options"
QT_MOC_LITERAL(49, 615, 14), // "deleteQuestion"
QT_MOC_LITERAL(50, 630, 10), // "questionId"
QT_MOC_LITERAL(51, 641, 14), // "updateQuestion"
QT_MOC_LITERAL(52, 656, 20), // "getQuestionsByBankId"
QT_MOC_LITERAL(53, 677, 15), // "getQuestionById"
QT_MOC_LITERAL(54, 693, 18), // "getRandomQuestions"
QT_MOC_LITERAL(55, 712, 5), // "count"
QT_MOC_LITERAL(56, 718, 15), // "importQuestions"
QT_MOC_LITERAL(57, 734, 9), // "questions"
QT_MOC_LITERAL(58, 744, 21), // "getAllKnowledgePoints"
QT_MOC_LITERAL(59, 766, 17), // "addKnowledgePoint"
QT_MOC_LITERAL(60, 784, 5), // "title"
QT_MOC_LITERAL(61, 790, 20), // "deleteKnowledgePoint"
QT_MOC_LITERAL(62, 811, 7), // "pointId"
QT_MOC_LITERAL(63, 819, 21), // "importKnowledgePoints"
QT_MOC_LITERAL(64, 841, 6), // "points"
QT_MOC_LITERAL(65, 848, 23), // "clearAllKnowledgePoints"
QT_MOC_LITERAL(66, 872, 20), // "saveUserAnswerRecord"
QT_MOC_LITERAL(67, 893, 8), // "userName"
QT_MOC_LITERAL(68, 902, 8), // "examType"
QT_MOC_LITERAL(69, 911, 14), // "totalQuestions"
QT_MOC_LITERAL(70, 926, 12), // "correctCount"
QT_MOC_LITERAL(71, 939, 10), // "answerData"
QT_MOC_LITERAL(72, 950, 16), // "questionBankInfo"
QT_MOC_LITERAL(73, 967, 12), // "pentagonType"
QT_MOC_LITERAL(74, 980, 20), // "getUserAnswerRecords"
QT_MOC_LITERAL(75, 1001, 19), // "getAllAnswerRecords"
QT_MOC_LITERAL(76, 1021, 32), // "getUserCurrentMonthQuestionCount"
QT_MOC_LITERAL(77, 1054, 25), // "getUserYearlyQuestionData"
QT_MOC_LITERAL(78, 1080, 30), // "getUserRollingYearQuestionData"
QT_MOC_LITERAL(79, 1111, 26), // "getMaxMonthlyQuestionCount"
QT_MOC_LITERAL(80, 1138, 18), // "getUserAbilityData"
QT_MOC_LITERAL(81, 1157, 19), // "getUserPracticeData"
QT_MOC_LITERAL(82, 1177, 26), // "getUserMonthlyPracticeData"
QT_MOC_LITERAL(83, 1204, 10), // "monthCount"
QT_MOC_LITERAL(84, 1215, 24), // "getUserDailyPracticeData"
QT_MOC_LITERAL(85, 1240, 4), // "year"
QT_MOC_LITERAL(86, 1245, 5), // "month"
QT_MOC_LITERAL(87, 1251, 19), // "getUserPentagonData"
QT_MOC_LITERAL(88, 1271, 20), // "saveUserBankProgress"
QT_MOC_LITERAL(89, 1292, 20), // "currentQuestionIndex"
QT_MOC_LITERAL(90, 1313, 15), // "userAnswersJson"
QT_MOC_LITERAL(91, 1329, 19), // "getUserBankProgress"
QT_MOC_LITERAL(92, 1349, 24), // "updateUserWrongQuestions"
QT_MOC_LITERAL(93, 1374, 16), // "wrongQuestionIds"
QT_MOC_LITERAL(94, 1391, 23), // "getUserWrongQuestionIds"
QT_MOC_LITERAL(95, 1415, 22) // "deleteUserBankProgress"

    },
    "DatabaseManager\0initDatabase\0\0addFaceData\0"
    "name\0gender\0workId\0faceImagePath\0"
    "avatarPath\0isAdmin\0password\0addUserData\0"
    "deleteFaceData\0getAllFaceData\0"
    "getAllFaceDataSorted\0getFaceDataByWorkId\0"
    "verifyFace\0userExists\0updateFaceData\0"
    "verifyPassword\0verifyUserCredentials\0"
    "updateUserPassword\0newPassword\0"
    "setSetting\0key\0value\0getSetting\0"
    "defaultValue\0deleteSetting\0getAllSettings\0"
    "getAccessLogs\0limit\0offset\0"
    "getAccessLogsByUser\0cleanupOldLogs\0"
    "daysToKeep\0getUserAvatarPath\0"
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
      76,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // methods: name, argc, parameters, tag, flags
       1,    0,  394,    2, 0x02 /* Public */,
       3,    7,  395,    2, 0x02 /* Public */,
       3,    6,  410,    2, 0x22 /* Public | MethodCloned */,
       3,    5,  423,    2, 0x22 /* Public | MethodCloned */,
      11,    6,  434,    2, 0x02 /* Public */,
      11,    5,  447,    2, 0x22 /* Public | MethodCloned */,
      11,    4,  458,    2, 0x22 /* Public | MethodCloned */,
      12,    1,  467,    2, 0x02 /* Public */,
      13,    0,  470,    2, 0x02 /* Public */,
      14,    0,  471,    2, 0x02 /* Public */,
      15,    1,  472,    2, 0x02 /* Public */,
      16,    2,  475,    2, 0x02 /* Public */,
      17,    1,  480,    2, 0x02 /* Public */,
      18,    7,  483,    2, 0x02 /* Public */,
      18,    6,  498,    2, 0x22 /* Public | MethodCloned */,
      18,    5,  511,    2, 0x22 /* Public | MethodCloned */,
      19,    2,  522,    2, 0x02 /* Public */,
      20,    3,  527,    2, 0x02 /* Public */,
      21,    2,  534,    2, 0x02 /* Public */,
      23,    2,  539,    2, 0x02 /* Public */,
      26,    2,  544,    2, 0x02 /* Public */,
      26,    1,  549,    2, 0x22 /* Public | MethodCloned */,
      28,    1,  552,    2, 0x02 /* Public */,
      29,    0,  555,    2, 0x02 /* Public */,
      30,    2,  556,    2, 0x02 /* Public */,
      30,    1,  561,    2, 0x22 /* Public | MethodCloned */,
      30,    0,  564,    2, 0x22 /* Public | MethodCloned */,
      33,    3,  565,    2, 0x02 /* Public */,
      33,    2,  572,    2, 0x22 /* Public | MethodCloned */,
      33,    1,  577,    2, 0x22 /* Public | MethodCloned */,
      34,    1,  580,    2, 0x02 /* Public */,
      34,    0,  583,    2, 0x22 /* Public | MethodCloned */,
      36,    1,  584,    2, 0x02 /* Public */,
      37,    2,  587,    2, 0x02 /* Public */,
      39,    1,  592,    2, 0x02 /* Public */,
      41,    0,  595,    2, 0x02 /* Public */,
      42,    1,  596,    2, 0x02 /* Public */,
      43,    2,  599,    2, 0x02 /* Public */,
      44,    5,  604,    2, 0x02 /* Public */,
      44,    4,  615,    2, 0x22 /* Public | MethodCloned */,
      49,    1,  624,    2, 0x02 /* Public */,
      51,    5,  627,    2, 0x02 /* Public */,
      51,    4,  638,    2, 0x22 /* Public | MethodCloned */,
      52,    1,  647,    2, 0x02 /* Public */,
      53,    1,  650,    2, 0x02 /* Public */,
      54,    2,  653,    2, 0x02 /* Public */,
      56,    2,  658,    2, 0x02 /* Public */,
      58,    0,  663,    2, 0x02 /* Public */,
      59,    2,  664,    2, 0x02 /* Public */,
      61,    1,  669,    2, 0x02 /* Public */,
      63,    1,  672,    2, 0x02 /* Public */,
      65,    0,  675,    2, 0x02 /* Public */,
      66,    8,  676,    2, 0x02 /* Public */,
      66,    7,  693,    2, 0x22 /* Public | MethodCloned */,
      66,    6,  708,    2, 0x22 /* Public | MethodCloned */,
      74,    3,  721,    2, 0x02 /* Public */,
      74,    2,  728,    2, 0x22 /* Public | MethodCloned */,
      74,    1,  733,    2, 0x22 /* Public | MethodCloned */,
      75,    2,  736,    2, 0x02 /* Public */,
      75,    1,  741,    2, 0x22 /* Public | MethodCloned */,
      75,    0,  744,    2, 0x22 /* Public | MethodCloned */,
      76,    1,  745,    2, 0x02 /* Public */,
      77,    1,  748,    2, 0x02 /* Public */,
      78,    1,  751,    2, 0x02 /* Public */,
      79,    0,  754,    2, 0x02 /* Public */,
      80,    1,  755,    2, 0x02 /* Public */,
      81,    1,  758,    2, 0x02 /* Public */,
      82,    2,  761,    2, 0x02 /* Public */,
      82,    1,  766,    2, 0x22 /* Public | MethodCloned */,
      84,    3,  769,    2, 0x02 /* Public */,
      87,    1,  776,    2, 0x02 /* Public */,
      88,    4,  779,    2, 0x02 /* Public */,
      91,    2,  788,    2, 0x02 /* Public */,
      92,    3,  793,    2, 0x02 /* Public */,
      94,    2,  800,    2, 0x02 /* Public */,
      95,    2,  805,    2, 0x02 /* Public */,

 // methods: parameters
    QMetaType::Bool,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Bool, QMetaType::QString,    4,    5,    6,    7,    8,    9,   10,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Bool,    4,    5,    6,    7,    8,    9,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString,    4,    5,    6,    7,    8,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Bool, QMetaType::QString,    4,    5,    6,    8,    9,   10,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Bool,    4,    5,    6,    8,    9,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString,    4,    5,    6,    8,
    QMetaType::Bool, QMetaType::QString,    6,
    QMetaType::QVariantList,
    QMetaType::QVariantList,
    QMetaType::QVariantMap, QMetaType::QString,    6,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString,    6,    7,
    QMetaType::Bool, QMetaType::QString,    6,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Bool, QMetaType::QString,    6,    4,    5,    7,    8,    9,   10,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Bool,    6,    4,    5,    7,    8,    9,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString,    6,    4,    5,    7,    8,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString,    6,   10,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString,    4,    6,   10,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString,    6,   22,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString,   24,   25,
    QMetaType::QString, QMetaType::QString, QMetaType::QString,   24,   27,
    QMetaType::QString, QMetaType::QString,   24,
    QMetaType::Bool, QMetaType::QString,   24,
    QMetaType::QVariantMap,
    QMetaType::QVariantList, QMetaType::Int, QMetaType::Int,   31,   32,
    QMetaType::QVariantList, QMetaType::Int,   31,
    QMetaType::QVariantList,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int, QMetaType::Int,    6,   31,   32,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int,    6,   31,
    QMetaType::QVariantList, QMetaType::QString,    6,
    QMetaType::Bool, QMetaType::Int,   35,
    QMetaType::Bool,
    QMetaType::QString, QMetaType::QString,    6,
    QMetaType::Bool, QMetaType::QString, QMetaType::Int,    4,   38,
    QMetaType::Bool, QMetaType::Int,   40,
    QMetaType::QVariantList,
    QMetaType::QVariantMap, QMetaType::Int,   40,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString,   40,    4,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QStringList,   40,   45,   46,   47,   48,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString,   40,   45,   46,   47,
    QMetaType::Bool, QMetaType::Int,   50,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QStringList,   50,   45,   46,   47,   48,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString,   50,   45,   46,   47,
    QMetaType::QVariantList, QMetaType::Int,   40,
    QMetaType::QVariantMap, QMetaType::Int,   50,
    QMetaType::QVariantList, QMetaType::Int, QMetaType::Int,   40,   55,
    QMetaType::Bool, QMetaType::Int, QMetaType::QVariantList,   40,   57,
    QMetaType::QVariantList,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString,   60,   45,
    QMetaType::Bool, QMetaType::Int,   62,
    QMetaType::Bool, QMetaType::QVariantList,   64,
    QMetaType::Bool,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Int, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString,    6,   67,   68,   69,   70,   71,   72,   73,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Int, QMetaType::Int, QMetaType::QString, QMetaType::QString,    6,   67,   68,   69,   70,   71,   72,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Int, QMetaType::Int, QMetaType::QString,    6,   67,   68,   69,   70,   71,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int, QMetaType::Int,    6,   31,   32,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int,    6,   31,
    QMetaType::QVariantList, QMetaType::QString,    6,
    QMetaType::QVariantList, QMetaType::Int, QMetaType::Int,   31,   32,
    QMetaType::QVariantList, QMetaType::Int,   31,
    QMetaType::QVariantList,
    QMetaType::Int, QMetaType::QString,    6,
    QMetaType::QVariantList, QMetaType::QString,    6,
    QMetaType::QVariantList, QMetaType::QString,    6,
    QMetaType::Int,
    QMetaType::QVariantMap, QMetaType::QString,    6,
    QMetaType::QVariantMap, QMetaType::QString,    6,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int,    6,   83,
    QMetaType::QVariantList, QMetaType::QString,    6,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int, QMetaType::Int,    6,   85,   86,
    QMetaType::QVariantMap, QMetaType::QString,    6,
    QMetaType::Bool, QMetaType::QString, QMetaType::Int, QMetaType::Int, QMetaType::QString,    6,   40,   89,   90,
    QMetaType::QVariantMap, QMetaType::QString, QMetaType::Int,    6,   40,
    QMetaType::Bool, QMetaType::QString, QMetaType::Int, QMetaType::QVariantList,    6,   40,   93,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int,    6,   40,
    QMetaType::Bool, QMetaType::QString, QMetaType::Int,    6,   40,

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
        case 1: { bool _r = _t->addFaceData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QString(*)>(_a[5])),(*reinterpret_cast< bool(*)>(_a[6])),(*reinterpret_cast< const QString(*)>(_a[7])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 2: { bool _r = _t->addFaceData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QString(*)>(_a[5])),(*reinterpret_cast< bool(*)>(_a[6])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 3: { bool _r = _t->addFaceData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QString(*)>(_a[5])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 4: { bool _r = _t->addUserData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< bool(*)>(_a[5])),(*reinterpret_cast< const QString(*)>(_a[6])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 5: { bool _r = _t->addUserData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< bool(*)>(_a[5])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 6: { bool _r = _t->addUserData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 7: { bool _r = _t->deleteFaceData((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 8: { QVariantList _r = _t->getAllFaceData();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 9: { QVariantList _r = _t->getAllFaceDataSorted();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 10: { QVariantMap _r = _t->getFaceDataByWorkId((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 11: { bool _r = _t->verifyFace((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 12: { bool _r = _t->userExists((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 13: { bool _r = _t->updateFaceData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QString(*)>(_a[5])),(*reinterpret_cast< bool(*)>(_a[6])),(*reinterpret_cast< const QString(*)>(_a[7])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 14: { bool _r = _t->updateFaceData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QString(*)>(_a[5])),(*reinterpret_cast< bool(*)>(_a[6])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 15: { bool _r = _t->updateFaceData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QString(*)>(_a[5])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 16: { bool _r = _t->verifyPassword((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 17: { bool _r = _t->verifyUserCredentials((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 18: { bool _r = _t->updateUserPassword((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 19: { bool _r = _t->setSetting((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 20: { QString _r = _t->getSetting((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 21: { QString _r = _t->getSetting((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 22: { bool _r = _t->deleteSetting((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 23: { QVariantMap _r = _t->getAllSettings();
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 24: { QVariantList _r = _t->getAccessLogs((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 25: { QVariantList _r = _t->getAccessLogs((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 26: { QVariantList _r = _t->getAccessLogs();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 27: { QVariantList _r = _t->getAccessLogsByUser((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])),(*reinterpret_cast< int(*)>(_a[3])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 28: { QVariantList _r = _t->getAccessLogsByUser((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 29: { QVariantList _r = _t->getAccessLogsByUser((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 30: { bool _r = _t->cleanupOldLogs((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 31: { bool _r = _t->cleanupOldLogs();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 32: { QString _r = _t->getUserAvatarPath((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 33: { bool _r = _t->addQuestionBank((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 34: { bool _r = _t->deleteQuestionBank((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 35: { QVariantList _r = _t->getAllQuestionBanks();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 36: { QVariantMap _r = _t->getQuestionBankById((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 37: { bool _r = _t->updateQuestionBank((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 38: { bool _r = _t->addQuestion((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QStringList(*)>(_a[5])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 39: { bool _r = _t->addQuestion((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 40: { bool _r = _t->deleteQuestion((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 41: { bool _r = _t->updateQuestion((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QStringList(*)>(_a[5])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 42: { bool _r = _t->updateQuestion((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 43: { QVariantList _r = _t->getQuestionsByBankId((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 44: { QVariantMap _r = _t->getQuestionById((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 45: { QVariantList _r = _t->getRandomQuestions((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 46: { bool _r = _t->importQuestions((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QVariantList(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 47: { QVariantList _r = _t->getAllKnowledgePoints();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 48: { bool _r = _t->addKnowledgePoint((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 49: { bool _r = _t->deleteKnowledgePoint((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 50: { bool _r = _t->importKnowledgePoints((*reinterpret_cast< const QVariantList(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 51: { bool _r = _t->clearAllKnowledgePoints();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 52: { bool _r = _t->saveUserAnswerRecord((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< int(*)>(_a[4])),(*reinterpret_cast< int(*)>(_a[5])),(*reinterpret_cast< const QString(*)>(_a[6])),(*reinterpret_cast< const QString(*)>(_a[7])),(*reinterpret_cast< const QString(*)>(_a[8])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 53: { bool _r = _t->saveUserAnswerRecord((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< int(*)>(_a[4])),(*reinterpret_cast< int(*)>(_a[5])),(*reinterpret_cast< const QString(*)>(_a[6])),(*reinterpret_cast< const QString(*)>(_a[7])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 54: { bool _r = _t->saveUserAnswerRecord((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< int(*)>(_a[4])),(*reinterpret_cast< int(*)>(_a[5])),(*reinterpret_cast< const QString(*)>(_a[6])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 55: { QVariantList _r = _t->getUserAnswerRecords((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])),(*reinterpret_cast< int(*)>(_a[3])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 56: { QVariantList _r = _t->getUserAnswerRecords((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 57: { QVariantList _r = _t->getUserAnswerRecords((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 58: { QVariantList _r = _t->getAllAnswerRecords((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 59: { QVariantList _r = _t->getAllAnswerRecords((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 60: { QVariantList _r = _t->getAllAnswerRecords();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 61: { int _r = _t->getUserCurrentMonthQuestionCount((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = std::move(_r); }  break;
        case 62: { QVariantList _r = _t->getUserYearlyQuestionData((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 63: { QVariantList _r = _t->getUserRollingYearQuestionData((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 64: { int _r = _t->getMaxMonthlyQuestionCount();
            if (_a[0]) *reinterpret_cast< int*>(_a[0]) = std::move(_r); }  break;
        case 65: { QVariantMap _r = _t->getUserAbilityData((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 66: { QVariantMap _r = _t->getUserPracticeData((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 67: { QVariantList _r = _t->getUserMonthlyPracticeData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 68: { QVariantList _r = _t->getUserMonthlyPracticeData((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 69: { QVariantList _r = _t->getUserDailyPracticeData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])),(*reinterpret_cast< int(*)>(_a[3])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 70: { QVariantMap _r = _t->getUserPentagonData((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 71: { bool _r = _t->saveUserBankProgress((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])),(*reinterpret_cast< int(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 72: { QVariantMap _r = _t->getUserBankProgress((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 73: { bool _r = _t->updateUserWrongQuestions((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])),(*reinterpret_cast< const QVariantList(*)>(_a[3])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 74: { QVariantList _r = _t->getUserWrongQuestionIds((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 75: { bool _r = _t->deleteUserBankProgress((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
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
        if (_id < 76)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 76;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 76)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 76;
    }
    return _id;
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
