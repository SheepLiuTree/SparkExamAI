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
    QByteArrayData data[16];
    char stringdata0[169];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_FaceRecognizer_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_FaceRecognizer_t qt_meta_stringdata_FaceRecognizer = {
    {
QT_MOC_LITERAL(0, 0, 14), // "FaceRecognizer"
QT_MOC_LITERAL(1, 15, 10), // "initialize"
QT_MOC_LITERAL(2, 26, 0), // ""
QT_MOC_LITERAL(3, 27, 10), // "detectFace"
QT_MOC_LITERAL(4, 38, 9), // "imagePath"
QT_MOC_LITERAL(5, 48, 14), // "extractFeature"
QT_MOC_LITERAL(6, 63, 5), // "image"
QT_MOC_LITERAL(7, 69, 12), // "compareFaces"
QT_MOC_LITERAL(8, 82, 10), // "image1Path"
QT_MOC_LITERAL(9, 93, 10), // "image2Path"
QT_MOC_LITERAL(10, 104, 9), // "loadImage"
QT_MOC_LITERAL(11, 114, 11), // "matToQImage"
QT_MOC_LITERAL(12, 126, 7), // "cv::Mat"
QT_MOC_LITERAL(13, 134, 3), // "mat"
QT_MOC_LITERAL(14, 138, 11), // "qImageToMat"
QT_MOC_LITERAL(15, 150, 18) // "detectFacePosition"

    },
    "FaceRecognizer\0initialize\0\0detectFace\0"
    "imagePath\0extractFeature\0image\0"
    "compareFaces\0image1Path\0image2Path\0"
    "loadImage\0matToQImage\0cv::Mat\0mat\0"
    "qImageToMat\0detectFacePosition"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_FaceRecognizer[] = {

 // content:
       8,       // revision
       0,       // classname
       0,    0, // classinfo
       8,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // methods: name, argc, parameters, tag, flags
       1,    0,   54,    2, 0x02 /* Public */,
       3,    1,   55,    2, 0x02 /* Public */,
       5,    1,   58,    2, 0x02 /* Public */,
       7,    2,   61,    2, 0x02 /* Public */,
      10,    1,   66,    2, 0x02 /* Public */,
      11,    1,   69,    2, 0x02 /* Public */,
      14,    1,   72,    2, 0x02 /* Public */,
      15,    1,   75,    2, 0x02 /* Public */,

 // methods: parameters
    QMetaType::Bool,
    QMetaType::Bool, QMetaType::QString,    4,
    QMetaType::Bool, QMetaType::QImage,    6,
    QMetaType::Float, QMetaType::QString, QMetaType::QString,    8,    9,
    QMetaType::QImage, QMetaType::QString,    4,
    QMetaType::QImage, 0x80000000 | 12,   13,
    0x80000000 | 12, QMetaType::QImage,    6,
    QMetaType::QVariantMap, QMetaType::QString,    4,

       0        // eod
};

void FaceRecognizer::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<FaceRecognizer *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: { bool _r = _t->initialize();
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 1: { bool _r = _t->detectFace((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 2: { bool _r = _t->extractFeature((*reinterpret_cast< const QImage(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< bool*>(_a[0]) = std::move(_r); }  break;
        case 3: { float _r = _t->compareFaces((*reinterpret_cast< const QString(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2])));
            if (_a[0]) *reinterpret_cast< float*>(_a[0]) = std::move(_r); }  break;
        case 4: { QImage _r = _t->loadImage((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QImage*>(_a[0]) = std::move(_r); }  break;
        case 5: { QImage _r = _t->matToQImage((*reinterpret_cast< const cv::Mat(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QImage*>(_a[0]) = std::move(_r); }  break;
        case 6: { cv::Mat _r = _t->qImageToMat((*reinterpret_cast< const QImage(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< cv::Mat*>(_a[0]) = std::move(_r); }  break;
        case 7: { QVariantMap _r = _t->detectFacePosition((*reinterpret_cast< const QString(*)>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    }
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
        if (_id < 8)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 8;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 8)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 8;
    }
    return _id;
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
