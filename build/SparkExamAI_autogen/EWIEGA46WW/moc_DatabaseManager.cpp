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
    QByteArrayData data[57];
    char stringdata0[737];
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
QT_MOC_LITERAL(47, 583, 15), // "importQuestions"
QT_MOC_LITERAL(48, 599, 9), // "questions"
QT_MOC_LITERAL(49, 609, 21), // "getAllKnowledgePoints"
QT_MOC_LITERAL(50, 631, 17), // "addKnowledgePoint"
QT_MOC_LITERAL(51, 649, 5), // "title"
QT_MOC_LITERAL(52, 655, 20), // "deleteKnowledgePoint"
QT_MOC_LITERAL(53, 676, 7), // "pointId"
QT_MOC_LITERAL(54, 684, 21), // "importKnowledgePoints"
QT_MOC_LITERAL(55, 706, 6), // "points"
QT_MOC_LITERAL(56, 713, 23) // "clearAllKnowledgePoints"

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
    "getQuestionById\0importQuestions\0"
    "questions\0getAllKnowledgePoints\0"
    "addKnowledgePoint\0title\0deleteKnowledgePoint\0"
    "pointId\0importKnowledgePoints\0points\0"
    "clearAllKnowledgePoints"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_DatabaseManager[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
      42,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // methods: name, argc, parameters, tag, flags
       1,    0,  224,    2, 0x02 /* Public */,
       3,    6,  225,    2, 0x02 /* Public */,
       3,    5,  238,    2, 0x22 /* Public | MethodCloned */,
      10,    1,  249,    2, 0x02 /* Public */,
      11,    0,  252,    2, 0x02 /* Public */,
      12,    1,  253,    2, 0x02 /* Public */,
      13,    2,  256,    2, 0x02 /* Public */,
      14,    1,  261,    2, 0x02 /* Public */,
      15,    6,  264,    2, 0x02 /* Public */,
      15,    5,  277,    2, 0x22 /* Public | MethodCloned */,
      16,    2,  288,    2, 0x02 /* Public */,
      19,    2,  293,    2, 0x02 /* Public */,
      19,    1,  298,    2, 0x22 /* Public | MethodCloned */,
      21,    1,  301,    2, 0x02 /* Public */,
      22,    0,  304,    2, 0x02 /* Public */,
      23,    2,  305,    2, 0x02 /* Public */,
      23,    1,  310,    2, 0x22 /* Public | MethodCloned */,
      23,    0,  313,    2, 0x22 /* Public | MethodCloned */,
      26,    3,  314,    2, 0x02 /* Public */,
      26,    2,  321,    2, 0x22 /* Public | MethodCloned */,
      26,    1,  326,    2, 0x22 /* Public | MethodCloned */,
      27,    1,  329,    2, 0x02 /* Public */,
      27,    0,  332,    2, 0x22 /* Public | MethodCloned */,
      29,    1,  333,    2, 0x02 /* Public */,
      30,    2,  336,    2, 0x02 /* Public */,
      32,    1,  341,    2, 0x02 /* Public */,
      34,    0,  344,    2, 0x02 /* Public */,
      35,    1,  345,    2, 0x02 /* Public */,
      36,    2,  348,    2, 0x02 /* Public */,
      37,    5,  353,    2, 0x02 /* Public */,
      37,    4,  364,    2, 0x22 /* Public | MethodCloned */,
      42,    1,  373,    2, 0x02 /* Public */,
      44,    5,  376,    2, 0x02 /* Public */,
      44,    4,  387,    2, 0x22 /* Public | MethodCloned */,
      45,    1,  396,    2, 0x02 /* Public */,
      46,    1,  399,    2, 0x02 /* Public */,
      47,    2,  402,    2, 0x02 /* Public */,
      49,    0,  407,    2, 0x02 /* Public */,
      50,    2,  408,    2, 0x02 /* Public */,
      52,    1,  413,    2, 0x02 /* Public */,
      54,    1,  416,    2, 0x02 /* Public */,
      56,    0,  419,    2, 0x02 /* Public */,

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
    QMetaType::Bool, QMetaType::Int, QMetaType::QVariantList,   33,   48,
    QMetaType::QVariantList,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString,   51,   38,
    QMetaType::Bool, QMetaType::Int,   53,
    QMetaType::Bool, QMetaType::QVariantList,   55,
    QMetaType::Bool,

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
        case 36: { bool _r = _t->importQuestions((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QVariantList(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 37: { QVariantList _r = _t->getAllKnowledgePoints();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 38: { bool _r = _t->addKnowledgePoint((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 39: { bool _r = _t->deleteKnowledgePoint((*reinterpret_cast< int(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 40: { bool _r = _t->importKnowledgePoints((*reinterpret_cast< const QVariantList(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 41: { bool _r = _t->clearAllKnowledgePoints();
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
        if (_id < 42)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 42;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 42)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 42;
    }
    return _id;
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
