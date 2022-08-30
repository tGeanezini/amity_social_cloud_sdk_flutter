import 'package:amity_sdk/src/core/model/api_request/upload_file_request.dart';
import 'package:amity_sdk/src/data/data.dart';
import 'package:amity_sdk/src/domain/model/amity_file/amity_file_info.dart';
import 'package:amity_sdk/src/domain/model/amity_file/amity_file_properties.dart';
import 'package:amity_sdk/src/domain/model/amity_file/amity_upload_result.dart';
import 'package:amity_sdk/src/domain/repo/file_repo.dart';

/// File Repo Layer Impl
class FileRepoImpl extends FileRepo {
  /// File Db Adapter
  final FileDbAdapter fileDbAdapter;

  /// file Api Interface
  final FileApiInterface fileApiInterface;

  /// init [FileRepoImpl]
  FileRepoImpl({required this.fileDbAdapter, required this.fileApiInterface});

  @override
  Future<AmityFileProperties> getFileByIdFromDb(String fileId) {
    return Future.value(
        fileDbAdapter.getFileEntity(fileId).convertToAmityFileProperties());
  }

  @override
  Future<AmityUploadResult<AmityFile>> uploadFile(
      UploadFileRequest request) async {
    final data = await fileApiInterface.uploadFile(request);

    final fileProperties = await _saveDataToDb(data);

    return AmityUploadComplete(AmityFile(fileProperties.first));
  }

  Future<List<AmityFileProperties>> _saveDataToDb(
      List<FileResponse> data) async {
    //Convert to File Hive Entity
    //we have save the file first, since every object depends on file
    List<FileHiveEntity> fileHiveEntities =
        data.map((e) => e.convertToFileHiveEntity()).toList();

    //Save the File Entity
    for (var e in fileHiveEntities) {
      await fileDbAdapter.saveFileEntity(e);
    }

    return fileHiveEntities
        .map((e) => e.convertToAmityFileProperties())
        .toList();
  }

  @override
  Future<AmityUploadResult<AmityAudio>> uploadAudio(
      UploadFileRequest request) async {
    final data = await fileApiInterface.uploadFile(request);

    final fileProperties = await _saveDataToDb(data);

    return AmityUploadComplete(AmityAudio(fileProperties.first));
  }

  @override
  Future<AmityUploadResult<AmityImage>> uploadImage(
      UploadFileRequest request) async {
    final data = await fileApiInterface.uploadFile(request);

    final fileProperties = await _saveDataToDb(data);

    return AmityUploadComplete(AmityImage(fileProperties.first));
  }

  @override
  Future<AmityUploadResult<AmityVideo>> uploadVidoe(
      UploadFileRequest request) async {
    final data = await fileApiInterface.uploadVideo(request);

    final fileProperties = await _saveDataToDb(data);

    return AmityUploadComplete(AmityVideo(fileProperties.first));
  }
}
