import 'package:image_picker/image_picker.dart' show XFile;

import '../models/curation.dart';
import '../models/recognition_result.dart';


abstract class RecognitionService {
  Future<RecognitionResult> recognize(XFile photo, List<Curation> candidates);
}
