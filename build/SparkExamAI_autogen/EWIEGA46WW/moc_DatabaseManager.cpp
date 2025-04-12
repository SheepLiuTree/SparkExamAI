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
    QByteArrayData data[73];
    char stringdata0[975];
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
QT_MOC_LITERAL(12, 124, 19), // "getFaceDataByWorkId"
QT_MOC_LITERAL(13, 144, 10), // "verifyFace"
QT_MOC_LITERAL(14, 155, 10), // "userExists"
QT_MOC_LITERAL(15, 166, 14), // "updateFaceData"
QT_MOC_LITERAL(16, 181, 10), // "setSetting"
QT_MOC_LITERAL(17, 192, 3), // "key"
QT_MOC_LITERAL(18, 196, 5), // "value"
QT_MOC_LITERAL(19, 202, 10), // "getSetting"
QT_MOC_LITERAL(20, 213, 12), // "defaultValue"
QT_MOC_LITERAL(21, 226, 13), // "deleteSetting"
QT_MOC_LITERAL(22, 240, 14), // "getAllSettings"
QT_MOC_LITERAL(23, 255, 13), // "getAccessLogs"
QT_MOC_LITERAL(24, 269, 5), // "limit"
QT_MOC_LITERAL(25, 275, 6), // "offset"
QT_MOC_LITERAL(26, 282, 19), // "getAccessLogsByUser"
QT_MOC_LITERAL(27, 302, 14), // "cleanupOldLogs"
QT_MOC_LITERAL(28, 317, 10), // "daysToKeep"
QT_MOC_LITERAL(29, 328, 17), // "getUserAvatarPath"
QT_MOC_LITERAL(30, 346, 15), // "addQuestionBank"
QT_MOC_LITERAL(31, 362, 13), // "questionCount"
QT_MOC_LITERAL(32, 376, 18), // "deleteQuestionBank"
QT_MOC_LITERAL(33, 395, 6), // "bankId"
QT_MOC_LITERAL(34, 402, 19), // "getAllQuestionBanks"
QT_MOC_LITERAL(35, 422, 19), // "getQuestionBankById"
QT_MOC_LITERAL(36, 442, 18), // "updateQuestionBank"
QT_MOC_LITERAL(37, 461, 11), // "addQuestion"
QT_MOC_LITERAL(38, 473, 7), // "content"
QT_MOC_LITERAL(39, 481, 6), // "answer"
QT_MOC_LITERAL(40, 488, 8), // "analysis"
QT_MOC_LITERAL(41, 497, 7), // "options"
QT_MOC_LITERAL(42, 505, 14), // "deleteQuestion"
QT_MOC_LITERAL(43, 520, 10), // "questionId"
QT_MOC_LITERAL(44, 531, 14), // "updateQuestion"
QT_MOC_LITERAL(45, 546, 20), // "getQuestionsByBankId"
QT_MOC_LITERAL(46, 567, 15), // "getQuestionById"
QT_MOC_LITERAL(47, 583, 18), // "getRandomQuestions"
QT_MOC_LITERAL(48, 602, 5), // "count"
QT_MOC_LITERAL(49, 608, 15), // "importQuestions"
QT_MOC_LITERAL(50, 624, 9), // "questions"
QT_MOC_LITERAL(51, 634, 21), // "getAllKnowledgePoints"
QT_MOC_LITERAL(52, 656, 17), // "addKnowledgePoint"
QT_MOC_LITERAL(53, 674, 5), // "title"
QT_MOC_LITERAL(54, 680, 20), // "deleteKnowledgePoint"
QT_MOC_LITERAL(55, 701, 7), // "pointId"
QT_MOC_LITERAL(56, 709, 21), // "importKnowledgePoints"
QT_MOC_LITERAL(57, 731, 6), // "points"
QT_MOC_LITERAL(58, 738, 23), // "clearAllKnowledgePoints"
QT_MOC_LITERAL(59, 762, 20), // "saveUserAnswerRecord"
QT_MOC_LITERAL(60, 783, 8), // "userName"
QT_MOC_LITERAL(61, 792, 8), // "examType"
QT_MOC_LITERAL(62, 801, 14), // "totalQuestions"
QT_MOC_LITERAL(63, 816, 12), // "correctCount"
QT_MOC_LITERAL(64, 829, 10), // "answerData"
QT_MOC_LITERAL(65, 840, 20), // "getUserAnswerRecords"
QT_MOC_LITERAL(66, 861, 19), // "getAllAnswerRecords"
QT_MOC_LITERAL(67, 881, 19), // "getUserPracticeData"
QT_MOC_LITERAL(68, 901, 26), // "getUserMonthlyPracticeData"
QT_MOC_LITERAL(69, 928, 10), // "monthCount"
QT_MOC_LITERAL(70, 939, 24), // "getUserDailyPracticeData"
QT_MOC_LITERAL(71, 964, 4), // "year"
QT_MOC_LITERAL(72, 969, 5) // "month"

    },
    "DatabaseManager\0initDatabase\0\0addFaceData\0"
    "name\0gender\0workId\0faceImagePath\0"
    "avatarPath\0isAdmin\0deleteFaceData\0"
    "getAllFaceData\0getFaceDataByWorkId\0"
    "verifyFace\0userExists\0updateFaceData\0"
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
    "correctCount\0answerData\0getUserAnswerRecords\0"
    "getAllAnswerRecords\0getUserPracticeData\0"
    "getUserMonthlyPracticeData\0monthCount\0"
    "getUserDailyPracticeData\0year\0month"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_DatabaseManager[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
      54,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // methods: name, argc, parameters, tag, flags
       1,    0,  284,    2, 0x02 /* Public */,
       3,    6,  285,    2, 0x02 /* Public */,
       3,    5,  298,    2, 0x22 /* Public | MethodCloned */,
      10,    1,  309,    2, 0x02 /* Public */,
      11,    0,  312,    2, 0x02 /* Public */,
      12,    1,  313,    2, 0x02 /* Public */,
      13,    2,  316,    2, 0x02 /* Public */,
      14,    1,  321,    2, 0x02 /* Public */,
      15,    6,  324,    2, 0x02 /* Public */,
      15,    5,  337,    2, 0x22 /* Public | MethodCloned */,
      16,    2,  348,    2, 0x02 /* Public */,
      19,    2,  353,    2, 0x02 /* Public */,
      19,    1,  358,    2, 0x22 /* Public | MethodCloned */,
      21,    1,  361,    2, 0x02 /* Public */,
      22,    0,  364,    2, 0x02 /* Public */,
      23,    2,  365,    2, 0x02 /* Public */,
      23,    1,  370,    2, 0x22 /* Public | MethodCloned */,
      23,    0,  373,    2, 0x22 /* Public | MethodCloned */,
      26,    3,  374,    2, 0x02 /* Public */,
      26,    2,  381,    2, 0x22 /* Public | MethodCloned */,
      26,    1,  386,    2, 0x22 /* Public | MethodCloned */,
      27,    1,  389,    2, 0x02 /* Public */,
      27,    0,  392,    2, 0x22 /* Public | MethodCloned */,
      29,    1,  393,    2, 0x02 /* Public */,
      30,    2,  396,    2, 0x02 /* Public */,
      32,    1,  401,    2, 0x02 /* Public */,
      34,    0,  404,    2, 0x02 /* Public */,
      35,    1,  405,    2, 0x02 /* Public */,
      36,    2,  408,    2, 0x02 /* Public */,
      37,    5,  413,    2, 0x02 /* Public */,
      37,    4,  424,    2, 0x22 /* Public | MethodCloned */,
      42,    1,  433,    2, 0x02 /* Public */,
      44,    5,  436,    2, 0x02 /* Public */,
      44,    4,  447,    2, 0x22 /* Public | MethodCloned */,
      45,    1,  456,    2, 0x02 /* Public */,
      46,    1,  459,    2, 0x02 /* Public */,
      47,    2,  462,    2, 0x02 /* Public */,
      49,    2,  467,    2, 0x02 /* Public */,
      51,    0,  472,    2, 0x02 /* Public */,
      52,    2,  473,    2, 0x02 /* Public */,
      54,    1,  478,    2, 0x02 /* Public */,
      56,    1,  481,    2, 0x02 /* Public */,
      58,    0,  484,    2, 0x02 /* Public */,
      59,    6,  485,    2, 0x02 /* Public */,
      65,    3,  498,    2, 0x02 /* Public */,
      65,    2,  505,    2, 0x22 /* Public | MethodCloned */,
      65,    1,  510,    2, 0x22 /* Public | MethodCloned */,
      66,    2,  513,    2, 0x02 /* Public */,
      66,    1,  518,    2, 0x22 /* Public | MethodCloned */,
      66,    0,  521,    2, 0x22 /* Public | MethodCloned */,
      67,    1,  522,    2, 0x02 /* Public */,
      68,    2,  525,    2, 0x02 /* Public */,
      68,    1,  530,    2, 0x22 /* Public | MethodCloned */,
      70,    3,  533,    2, 0x02 /* Public */,

 // methods: parameters
    QMetaType::Bool,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Bool,    4,    5,    6,    7,    8,    9,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString,    4,    5,    6,    7,    8,
    QMetaType::Bool, QMetaType::QString,    6,
    QMetaType::QVariantList,
    QMetaType::QVariantMap, QMetaType::QString,    6,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString,    6,    7,
    QMetaType::Bool, QMetaType::QString,    6,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Bool,    6,    4,    5,    7,    8,    9,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QString,    6,    4,    5,    7,    8,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString,   17,   18,
    QMetaType::QString, QMetaType::QString, QMetaType::QString,   17,   20,
    QMetaType::QString, QMetaType::QString,   17,
    QMetaType::Bool, QMetaType::QString,   17,
    QMetaType::QVariantMap,
    QMetaType::QVariantList, QMetaType::Int, QMetaType::Int,   24,   25,
    QMetaType::QVariantList, QMetaType::Int,   24,
    QMetaType::QVariantList,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int, QMetaType::Int,    6,   24,   25,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int,    6,   24,
    QMetaType::QVariantList, QMetaType::QString,    6,
    QMetaType::Bool, QMetaType::Int,   28,
    QMetaType::Bool,
    QMetaType::QString, QMetaType::QString,    6,
    QMetaType::Bool, QMetaType::QString, QMetaType::Int,    4,   31,
    QMetaType::Bool, QMetaType::Int,   33,
    QMetaType::QVariantList,
    QMetaType::QVariantMap, QMetaType::Int,   33,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString,   33,    4,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QStringList,   33,   38,   39,   40,   41,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString,   33,   38,   39,   40,
    QMetaType::Bool, QMetaType::Int,   43,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::QStringList,   43,   38,   39,   40,   41,
    QMetaType::Bool, QMetaType::Int, QMetaType::QString, QMetaType::QString, QMetaType::QString,   43,   38,   39,   40,
    QMetaType::QVariantList, QMetaType::Int,   33,
    QMetaType::QVariantMap, QMetaType::Int,   43,
    QMetaType::QVariantList, QMetaType::Int, QMetaType::Int,   33,   48,
    QMetaType::Bool, QMetaType::Int, QMetaType::QVariantList,   33,   50,
    QMetaType::QVariantList,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString,   53,   38,
    QMetaType::Bool, QMetaType::Int,   55,
    QMetaType::Bool, QMetaType::QVariantList,   57,
    QMetaType::Bool,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString, QMetaType::QString, QMetaType::Int, QMetaType::Int, QMetaType::QString,    6,   60,   61,   62,   63,   64,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int, QMetaType::Int,    6,   24,   25,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int,    6,   24,
    QMetaType::QVariantList, QMetaType::QString,    6,
    QMetaType::QVariantList, QMetaType::Int, QMetaType::Int,   24,   25,
    QMetaType::QVariantList, QMetaType::Int,   24,
    QMetaType::QVariantList,
    QMetaType::QVariantMap, QMetaType::QString,    6,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int,    6,   69,
    QMetaType::QVariantList, QMetaType::QString,    6,
    QMetaType::QVariantList, QMetaType::QString, QMetaType::Int, QMetaType::Int,    6,   71,   72,

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
        case 5: { QVariantMap _r = _t->getFaceDataByWorkId((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 6: { bool _r = _t->verifyFace((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 7: { bool _r = _t->userExists((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 8: { bool _r = _t->updateFaceData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QString(*)>(_a[5])),(*reinterpret_cast< bool(*)>(_a[6])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 9: { bool _r = _t->updateFaceData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QString(*)>(_a[5])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 10: { bool _r = _t->setSetting((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 11: { QString _r = _t->getSetting((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 12: { QString _r = _t->getSetting((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 13: { bool _r = _t->deleteSetting((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 14: { QVariantMap _r = _t->getAllSettings();
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 15: { QVariantList _r = _t->getAccessLogs((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 16: { QVariantList _r = _t->getAccessLogs((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 17: { QVariantList _r = _t->getAccessLogs();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 18: { QVariantList _r = _t->getAccessLogsByUser((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])),(*reinterpret_cast< int(*)>(_a[3])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 19: { QVariantList _r = _t->getAccessLogsByUser((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 20: { QVariantList _r = _t->getAccessLogsByUser((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 21: { bool _r = _t->cleanupOldLogs((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 22: { bool _r = _t->cleanupOldLogs();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 23: { QString _r = _t->getUserAvatarPath((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 24: { bool _r = _t->addQuestionBank((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 25: { bool _r = _t->deleteQuestionBank((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 26: { QVariantList _r = _t->getAllQuestionBanks();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 27: { QVariantMap _r = _t->getQuestionBankById((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 28: { bool _r = _t->updateQuestionBank((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 29: { bool _r = _t->addQuestion((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QStringList(*)>(_a[5])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 30: { bool _r = _t->addQuestion((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 31: { bool _r = _t->deleteQuestion((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 32: { bool _r = _t->updateQuestion((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])),(*reinterpret_cast< const QStringList(*)>(_a[5])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 33: { bool _r = _t->updateQuestion((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< const QString(*)>(_a[4])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 34: { QVariantList _r = _t->getQuestionsByBankId((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 35: { QVariantMap _r = _t->getQuestionById((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 36: { QVariantList _r = _t->getRandomQuestions((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 37: { bool _r = _t->importQuestions((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QVariantList(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 38: { QVariantList _r = _t->getAllKnowledgePoints();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 39: { bool _r = _t->addKnowledgePoint((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 40: { bool _r = _t->deleteKnowledgePoint((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 41: { bool _r = _t->importKnowledgePoints((*reinterpret_cast< const QVariantList(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 42: { bool _r = _t->clearAllKnowledgePoints();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 43: { bool _r = _t->saveUserAnswerRecord((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])),(*reinterpret_cast< const QString(*)>(_a[3])),(*reinterpret_cast< int(*)>(_a[4])),(*reinterpret_cast< int(*)>(_a[5])),(*reinterpret_cast< const QString(*)>(_a[6])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 44: { QVariantList _r = _t->getUserAnswerRecords((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])),(*reinterpret_cast< int(*)>(_a[3])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 45: { QVariantList _r = _t->getUserAnswerRecords((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 46: { QVariantList _r = _t->getUserAnswerRecords((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 47: { QVariantList _r = _t->getAllAnswerRecords((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 48: { QVariantList _r = _t->getAllAnswerRecords((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 49: { QVariantList _r = _t->getAllAnswerRecords();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 50: { QVariantMap _r = _t->getUserPracticeData((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 51: { QVariantList _r = _t->getUserMonthlyPracticeData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 52: { QVariantList _r = _t->getUserMonthlyPracticeData((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 53: { QVariantList _r = _t->getUserDailyPracticeData((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< int(*)>(_a[2])),(*reinterpret_cast< int(*)>(_a[3])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
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
        if (_id < 54)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 54;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 54)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 54;
    }
    return _id;
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
