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
    QByteArrayData data[30];
    char stringdata0[346];
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
QT_MOC_LITERAL(29, 328, 17) // "getUserAvatarPath"

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
    "daysToKeep\0getUserAvatarPath"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_DatabaseManager[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
      24,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // methods: name, argc, parameters, tag, flags
       1,    0,  134,    2, 0x02 /* Public */,
       3,    6,  135,    2, 0x02 /* Public */,
       3,    5,  148,    2, 0x22 /* Public | MethodCloned */,
      10,    1,  159,    2, 0x02 /* Public */,
      11,    0,  162,    2, 0x02 /* Public */,
      12,    1,  163,    2, 0x02 /* Public */,
      13,    2,  166,    2, 0x02 /* Public */,
      14,    1,  171,    2, 0x02 /* Public */,
      15,    6,  174,    2, 0x02 /* Public */,
      15,    5,  187,    2, 0x22 /* Public | MethodCloned */,
      16,    2,  198,    2, 0x02 /* Public */,
      19,    2,  203,    2, 0x02 /* Public */,
      19,    1,  208,    2, 0x22 /* Public | MethodCloned */,
      21,    1,  211,    2, 0x02 /* Public */,
      22,    0,  214,    2, 0x02 /* Public */,
      23,    2,  215,    2, 0x02 /* Public */,
      23,    1,  220,    2, 0x22 /* Public | MethodCloned */,
      23,    0,  223,    2, 0x22 /* Public | MethodCloned */,
      26,    3,  224,    2, 0x02 /* Public */,
      26,    2,  231,    2, 0x22 /* Public | MethodCloned */,
      26,    1,  236,    2, 0x22 /* Public | MethodCloned */,
      27,    1,  239,    2, 0x02 /* Public */,
      27,    0,  242,    2, 0x22 /* Public | MethodCloned */,
      29,    1,  243,    2, 0x02 /* Public */,

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
        if (_id < 24)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 24;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 24)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 24;
    }
    return _id;
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
