import 'dart:async';
import 'dart:io' if (dart.library.html) 'dart:html';

import 'package:amity_sdk/src/core/core.dart';
import 'package:amity_sdk/src/domain/model/amity_file/amity_file_info.dart';
import 'package:amity_sdk/src/domain/model/amity_file/amity_upload_result.dart';
import 'package:amity_sdk/src/domain/usecase/file/file_image_upload_usecase.dart';

/// [AmityImageUploadQueryBuilder]

class AmityImageUploadQueryBuilder {
  final FileImageUploadUsecase _usecase;
  final File _file;
  String? _uploadId;
  bool _isFullImage = false;

  /// init [AmityImageUploadQueryBuilder]
  AmityImageUploadQueryBuilder(this._usecase, this._file);

  /// set the upload id for image
  AmityImageUploadQueryBuilder uploadId(String id) {
    _uploadId = id;
    return this;
  }

  /// set if this is full image
  AmityImageUploadQueryBuilder isFullImage(bool isFullImage) {
    _isFullImage = isFullImage;
    return this;
  }

  /// excute upload function
  StreamController<AmityUploadResult<AmityImage>> upload() {
    UploadFileRequest request = UploadFileRequest();
    if (_file.lengthSync() > MAX_FILE_SIZE) throw AmityException(message: 'FILE_SIZE_EXCEEDED', code: 800140);

    request.files.add(_file);
    request.fullImage = _isFullImage;
    if (_uploadId != null) request.uploadId = _uploadId;

    return _usecase.listen(request);
  }
}
