import 'package:cscmobi_app/multillanguage/lang_ar.dart';
import 'package:cscmobi_app/multillanguage/lang_bn.dart';
import 'package:cscmobi_app/multillanguage/lang_fil.dart';
import 'package:cscmobi_app/multillanguage/lang_hi.dart';
import 'package:cscmobi_app/multillanguage/lang_th.dart';
import 'package:cscmobi_app/multillanguage/lang_tr.dart';

import 'lang_de.dart';
import 'lang_en.dart';
import 'lang_es.dart';
import 'lang_fr.dart';
import 'lang_id.dart';
import 'lang_it.dart';
import 'lang_ja.dart';
import 'lang_ko.dart';
import 'lang_pt.dart';
import 'lang_vi.dart';

abstract class AppTranslation {
  static Map<String, Map<String, String>> translationsKeys = {
    "en": enUS,
    "vi": viVN,
    "fr": frFR, //France
    "it": itIT, //Italia
    "de": deDE, //German
    "ja": jaJP, //Japan
    "ko": koKR, //Korea
    "es": esES, //Spanish
    "pt": ptBR, //Portuguese
    "id": idID, //Indonesia,
    "hi": hiHI,
    "ar": arAR,
    "bn": bnBN,
    "fil": filFIL,
    "th": thTH,
    "tr": trTR,
  };
}
