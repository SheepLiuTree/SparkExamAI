/****************************************************************************
** Meta object code from reading C++ file 'FaceRecognizer.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.15.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../../FaceRecognizer.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'FaceRecognizer.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.15.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_FaceRecognizer_t {
    QByteArrayData data[23];
    char stringdata0[261];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_FaceRecognizer_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_FaceRecognizer_t qt_meta_stringdata_FaceRecognizer = {
    {
QT_MOC_LITERAL(0, 0, 14), // "FaceRecognizer"
QT_MOC_LITERAL(1, 15, 20), // "rotationAngleChanged"
QT_MOC_LITERAL(2, 36, 0), // ""
QT_MOC_LITERAL(3, 37, 14), // "updateRotation"
QT_MOC_LITERAL(4, 52, 10), // "initialize"
QT_MOC_LITERAL(5, 63, 10), // "detectFace"
QT_MOC_LITERAL(6, 74, 9), // "imagePath"
QT_MOC_LITERAL(7, 84, 14), // "extractFeature"
QT_MOC_LITERAL(8, 99, 5), // "image"
QT_MOC_LITERAL(9, 105, 12), // "compareFaces"
QT_MOC_LITERAL(10, 118, 10), // "image1Path"
QT_MOC_LITERAL(11, 129, 10), // "image2Path"
QT_MOC_LITERAL(12, 140, 9), // "loadImage"
QT_MOC_LITERAL(13, 150, 11), // "matToQImage"
QT_MOC_LITERAL(14, 162, 7), // "cv::Mat"
QT_MOC_LITERAL(15, 170, 3), // "mat"
QT_MOC_LITERAL(16, 174, 11), // "qImageToMat"
QT_MOC_LITERAL(17, 186, 18), // "detectFacePosition"
QT_MOC_LITERAL(18, 205, 13), // "startRotation"
QT_MOC_LITERAL(19, 219, 8), // "interval"
QT_MOC_LITERAL(20, 228, 5), // "speed"
QT_MOC_LITERAL(21, 234, 12), // "stopRotation"
QT_MOC_LITERAL(22, 247, 13) // "rotationAngle"

    },
    "FaceRecognizer\0rotationAngleChanged\0"
    "\0updateRotation\0initialize\0detectFace\0"
    "imagePath\0extractFeature\0image\0"
    "compareFaces\0image1Path\0image2Path\0"
    "loadImage\0matToQImage\0cv::Mat\0mat\0"
    "qImageToMat\0detectFacePosition\0"
    "startRotation\0interval\0speed\0stopRotation\0"
    "rotationAngle"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_FaceRecognizer[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
      14,   14, // methods
       1,  120, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // signals: name, argc, parameters, tag, flags
       1,    0,   84,    2, 0x06 /* Public */,

 // slots: name, argc, parameters, tag, flags
       3,    0,   85,    2, 0x08 /* Private */,

 // methods: name, argc, parameters, tag, flags
       4,    0,   86,    2, 0x02 /* Public */,
       5,    1,   87,    2, 0x02 /* Public */,
       7,    1,   90,    2, 0x02 /* Public */,
       9,    2,   93,    2, 0x02 /* Public */,
      12,    1,   98,    2, 0x02 /* Public */,
      13,    1,  101,    2, 0x02 /* Public */,
      16,    1,  104,    2, 0x02 /* Public */,
      17,    1,  107,    2, 0x02 /* Public */,
      18,    2,  110,    2, 0x02 /* Public */,
      18,    1,  115,    2, 0x22 /* Public | MethodCloned */,
      18,    0,  118,    2, 0x22 /* Public | MethodCloned */,
      21,    0,  119,    2, 0x02 /* Public */,

 // signals: parameters
    QMetaType::Void,

 // slots: parameters
    QMetaType::Void,

 // methods: parameters
    QMetaType::Bool,
    QMetaType::Bool, QMetaType::QString,    6,
    QMetaType::Bool, QMetaType::QImage,    8,
    QMetaType::Float, QMetaType::QString, QMetaType::QString,   10,   11,
    QMetaType::QImage, QMetaType::QString,    6,
    QMetaType::QImage, 0x80000000 | 14,   15,
    0x80000000 | 14, QMetaType::QImage,    8,
    QMetaType::QVariantMap, QMetaType::QString,    6,
    QMetaType::Void, QMetaType::Int, QMetaType::Float,   19,   20,
    QMetaType::Void, QMetaType::Int,   19,
    QMetaType::Void,
    QMetaType::Void,

 // properties: name, type, flags
      22, QMetaType::Float, 0x00495001,

 // properties: notify_signal_id
       0,

       0        // eod
};

void FaceRecognizer::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<FaceRecognizer *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->rotationAngleChanged(); break;
        case 1: _t->updateRotation(); break;
        case 2: { bool _r = _t->initialize();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 3: { bool _r = _t->detectFace((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 4: { bool _r = _t->extractFeature((*reinterpret_cast< const QImage(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 5: { float _r = _t->compareFaces((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< float*>(_a[0]) = std::move(_r); }  break;
        case 6: { QImage _r = _t->loadImage((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QImage*>(_a[0]) = std::move(_r); }  break;
        case 7: { QImage _r = _t->matToQImage((*reinterpret_cast< const cv::Mat(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QImage*>(_a[0]) = std::move(_r); }  break;
        case 8: { cv::Mat _r = _t->qImageToMat((*reinterpret_cast< const QImage(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< cv::Mat*>(_a[0]) = std::move(_r); }  break;
        case 9: { QVariantMap _r = _t->detectFacePosition((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 10: _t->startRotation((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< float(*)>(_a[2]))); break;
        case 11: _t->startRotation((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 12: _t->startRotation(); break;
        case 13: _t->stopRotation(); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (FaceRecognizer::*)();
            if (*reinterpret_cast<_t *>(_a[1]) == static_cast<_t>(&FaceRecognizer::rotationAngleChanged)) {
                *result = 0;
                return;
            }
        }
    }
#ifndef QT_NO_PROPERTIES
    else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<FaceRecognizer *>(_o);
        Q_UNUSED(_t)
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< float*>(_v) = _t->rotationAngle(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
    } else if (_c == QMetaObject::ResetProperty) {
    }
#endif // QT_NO_PROPERTIES
}

QT_INIT_METAOBJECT const QMetaObject FaceRecognizer::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_FaceRecognizer.data,
    qt_meta_data_FaceRecognizer,
    qt_static_metacall,
    nullptr,
    nullptr
} };


const QMetaObject *FaceRecognizer::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *FaceRecognizer::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_FaceRecognizer.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int FaceRecognizer::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 14)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 14;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 14)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 14;
    }
#ifndef QT_NO_PROPERTIES
    else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyDesignable) {
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyScriptable) {
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyStored) {
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyEditable) {
        _id -= 1;
    } else if (_c == QMetaObject::QueryPropertyUser) {
        _id -= 1;
    }
#endif // QT_NO_PROPERTIES
    return _id;
}

// SIGNAL 0
void FaceRecognizer::rotationAngleChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
