/****************************************************************************
** Meta object code from reading C++ file 'FaceRecognition.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../../FaceRecognition.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'FaceRecognition.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_FaceRecognition_t {
    QByteArrayData data[10];
    char stringdata0[111];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_FaceRecognition_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_FaceRecognition_t qt_meta_stringdata_FaceRecognition = {
    {
QT_MOC_LITERAL(0, 0, 15), // "FaceRecognition"
QT_MOC_LITERAL(1, 16, 10), // "initEngine"
QT_MOC_LITERAL(2, 27, 0), // ""
QT_MOC_LITERAL(3, 28, 12), // "captureImage"
QT_MOC_LITERAL(4, 41, 8), // "savePath"
QT_MOC_LITERAL(5, 50, 13), // "recognizeFace"
QT_MOC_LITERAL(6, 64, 9), // "imagePath"
QT_MOC_LITERAL(7, 74, 6), // "workId"
QT_MOC_LITERAL(8, 81, 15), // "getPreviewImage"
QT_MOC_LITERAL(9, 97, 13) // "releaseCamera"

    },
    "FaceRecognition\0initEngine\0\0captureImage\0"
    "savePath\0recognizeFace\0imagePath\0"
    "workId\0getPreviewImage\0releaseCamera"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_FaceRecognition[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
       5,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // methods: name, argc, parameters, tag, flags
       1,    0,   39,    2, 0x02 /* Public */,
       3,    1,   40,    2, 0x02 /* Public */,
       5,    2,   43,    2, 0x02 /* Public */,
       8,    0,   48,    2, 0x02 /* Public */,
       9,    0,   49,    2, 0x02 /* Public */,

 // methods: parameters
    QMetaType::Bool,
    QMetaType::Bool, QMetaType::QString,    4,
    QMetaType::Bool, QMetaType::QString, QMetaType::QString,    6,    7,
    QMetaType::QVariantMap,
    QMetaType::Void,

       0        // eod
};

void FaceRecognition::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<FaceRecognition *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: { bool _r = _t->initEngine();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 1: { bool _r = _t->captureImage((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 2: { bool _r = _t->recognizeFace((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 3: { QVariantMap _r = _t->getPreviewImage();
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 4: _t->releaseCamera(); break;
        default: ;
        }
    }
}

QT_INIT_METAOBJECT const QMetaObject FaceRecognition::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_FaceRecognition.data,
    qt_meta_data_FaceRecognition,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *FaceRecognition::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *FaceRecognition::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_FaceRecognition.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int FaceRecognition::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 5)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 5;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 5)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 5;
    }
    return _id;
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
