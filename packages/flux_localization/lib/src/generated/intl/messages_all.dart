// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:implementation_imports, file_names, unnecessary_new
// ignore_for_file:unnecessary_brace_in_string_interps, directives_ordering
// ignore_for_file:argument_type_not_assignable, invalid_assignment
// ignore_for_file:prefer_single_quotes, prefer_generic_function_type_aliases
// ignore_for_file:comment_references

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:intl/src/intl_helpers.dart';

import 'messages_af.dart' deferred as messages_af;
import 'messages_am.dart' deferred as messages_am;
import 'messages_ar.dart' deferred as messages_ar;
import 'messages_as.dart' deferred as messages_as;
import 'messages_az.dart' deferred as messages_az;
import 'messages_be.dart' deferred as messages_be;
import 'messages_bg.dart' deferred as messages_bg;
import 'messages_bn.dart' deferred as messages_bn;
import 'messages_bo.dart' deferred as messages_bo;
import 'messages_bs.dart' deferred as messages_bs;
import 'messages_ca.dart' deferred as messages_ca;
import 'messages_cs.dart' deferred as messages_cs;
import 'messages_cy.dart' deferred as messages_cy;
import 'messages_da.dart' deferred as messages_da;
import 'messages_de.dart' deferred as messages_de;
import 'messages_el.dart' deferred as messages_el;
import 'messages_en.dart' deferred as messages_en;
import 'messages_es.dart' deferred as messages_es;
import 'messages_et.dart' deferred as messages_et;
import 'messages_eu.dart' deferred as messages_eu;
import 'messages_fa.dart' deferred as messages_fa;
import 'messages_fi.dart' deferred as messages_fi;
import 'messages_fil.dart' deferred as messages_fil;
import 'messages_fr.dart' deferred as messages_fr;
import 'messages_ga.dart' deferred as messages_ga;
import 'messages_gl.dart' deferred as messages_gl;
import 'messages_gsw.dart' deferred as messages_gsw;
import 'messages_gu.dart' deferred as messages_gu;
import 'messages_he.dart' deferred as messages_he;
import 'messages_hi.dart' deferred as messages_hi;
import 'messages_hr.dart' deferred as messages_hr;
import 'messages_hu.dart' deferred as messages_hu;
import 'messages_hy.dart' deferred as messages_hy;
import 'messages_id.dart' deferred as messages_id;
import 'messages_is.dart' deferred as messages_is;
import 'messages_it.dart' deferred as messages_it;
import 'messages_ja.dart' deferred as messages_ja;
import 'messages_ka.dart' deferred as messages_ka;
import 'messages_kk.dart' deferred as messages_kk;
import 'messages_km.dart' deferred as messages_km;
import 'messages_kn.dart' deferred as messages_kn;
import 'messages_ko.dart' deferred as messages_ko;
import 'messages_ku.dart' deferred as messages_ku;
import 'messages_ky.dart' deferred as messages_ky;
import 'messages_lo.dart' deferred as messages_lo;
import 'messages_lt.dart' deferred as messages_lt;
import 'messages_lv.dart' deferred as messages_lv;
import 'messages_mk.dart' deferred as messages_mk;
import 'messages_ml.dart' deferred as messages_ml;
import 'messages_mn.dart' deferred as messages_mn;
import 'messages_mr.dart' deferred as messages_mr;
import 'messages_ms.dart' deferred as messages_ms;
import 'messages_my.dart' deferred as messages_my;
import 'messages_nb.dart' deferred as messages_nb;
import 'messages_ne.dart' deferred as messages_ne;
import 'messages_nl.dart' deferred as messages_nl;
import 'messages_no.dart' deferred as messages_no;
import 'messages_or.dart' deferred as messages_or;
import 'messages_pa.dart' deferred as messages_pa;
import 'messages_pl.dart' deferred as messages_pl;
import 'messages_ps.dart' deferred as messages_ps;
import 'messages_pt_BR.dart' deferred as messages_pt_br;
import 'messages_pt_PT.dart' deferred as messages_pt_pt;
import 'messages_ro.dart' deferred as messages_ro;
import 'messages_ru.dart' deferred as messages_ru;
import 'messages_si.dart' deferred as messages_si;
import 'messages_sk.dart' deferred as messages_sk;
import 'messages_sl.dart' deferred as messages_sl;
import 'messages_sq.dart' deferred as messages_sq;
import 'messages_sr.dart' deferred as messages_sr;
import 'messages_sv.dart' deferred as messages_sv;
import 'messages_sw.dart' deferred as messages_sw;
import 'messages_ta.dart' deferred as messages_ta;
import 'messages_te.dart' deferred as messages_te;
import 'messages_th.dart' deferred as messages_th;
import 'messages_ti.dart' deferred as messages_ti;
import 'messages_tl.dart' deferred as messages_tl;
import 'messages_tr.dart' deferred as messages_tr;
import 'messages_ug.dart' deferred as messages_ug;
import 'messages_uk.dart' deferred as messages_uk;
import 'messages_ur.dart' deferred as messages_ur;
import 'messages_uz.dart' deferred as messages_uz;
import 'messages_vi.dart' deferred as messages_vi;
import 'messages_zh.dart' deferred as messages_zh;
import 'messages_zh_CN.dart' deferred as messages_zh_cn;
import 'messages_zh_TW.dart' deferred as messages_zh_tw;
import 'messages_zu.dart' deferred as messages_zu;

typedef Future<dynamic> LibraryLoader();
Map<String, LibraryLoader> _deferredLibraries = {
  'af': messages_af.loadLibrary,
  'am': messages_am.loadLibrary,
  'ar': messages_ar.loadLibrary,
  'as': messages_as.loadLibrary,
  'az': messages_az.loadLibrary,
  'be': messages_be.loadLibrary,
  'bg': messages_bg.loadLibrary,
  'bn': messages_bn.loadLibrary,
  'bo': messages_bo.loadLibrary,
  'bs': messages_bs.loadLibrary,
  'ca': messages_ca.loadLibrary,
  'cs': messages_cs.loadLibrary,
  'cy': messages_cy.loadLibrary,
  'da': messages_da.loadLibrary,
  'de': messages_de.loadLibrary,
  'el': messages_el.loadLibrary,
  'en': messages_en.loadLibrary,
  'es': messages_es.loadLibrary,
  'et': messages_et.loadLibrary,
  'eu': messages_eu.loadLibrary,
  'fa': messages_fa.loadLibrary,
  'fi': messages_fi.loadLibrary,
  'fil': messages_fil.loadLibrary,
  'fr': messages_fr.loadLibrary,
  'ga': messages_ga.loadLibrary,
  'gl': messages_gl.loadLibrary,
  'gsw': messages_gsw.loadLibrary,
  'gu': messages_gu.loadLibrary,
  'he': messages_he.loadLibrary,
  'hi': messages_hi.loadLibrary,
  'hr': messages_hr.loadLibrary,
  'hu': messages_hu.loadLibrary,
  'hy': messages_hy.loadLibrary,
  'id': messages_id.loadLibrary,
  'is': messages_is.loadLibrary,
  'it': messages_it.loadLibrary,
  'ja': messages_ja.loadLibrary,
  'ka': messages_ka.loadLibrary,
  'kk': messages_kk.loadLibrary,
  'km': messages_km.loadLibrary,
  'kn': messages_kn.loadLibrary,
  'ko': messages_ko.loadLibrary,
  'ku': messages_ku.loadLibrary,
  'ky': messages_ky.loadLibrary,
  'lo': messages_lo.loadLibrary,
  'lt': messages_lt.loadLibrary,
  'lv': messages_lv.loadLibrary,
  'mk': messages_mk.loadLibrary,
  'ml': messages_ml.loadLibrary,
  'mn': messages_mn.loadLibrary,
  'mr': messages_mr.loadLibrary,
  'ms': messages_ms.loadLibrary,
  'my': messages_my.loadLibrary,
  'nb': messages_nb.loadLibrary,
  'ne': messages_ne.loadLibrary,
  'nl': messages_nl.loadLibrary,
  'no': messages_no.loadLibrary,
  'or': messages_or.loadLibrary,
  'pa': messages_pa.loadLibrary,
  'pl': messages_pl.loadLibrary,
  'ps': messages_ps.loadLibrary,
  'pt_BR': messages_pt_br.loadLibrary,
  'pt_PT': messages_pt_pt.loadLibrary,
  'ro': messages_ro.loadLibrary,
  'ru': messages_ru.loadLibrary,
  'si': messages_si.loadLibrary,
  'sk': messages_sk.loadLibrary,
  'sl': messages_sl.loadLibrary,
  'sq': messages_sq.loadLibrary,
  'sr': messages_sr.loadLibrary,
  'sv': messages_sv.loadLibrary,
  'sw': messages_sw.loadLibrary,
  'ta': messages_ta.loadLibrary,
  'te': messages_te.loadLibrary,
  'th': messages_th.loadLibrary,
  'ti': messages_ti.loadLibrary,
  'tl': messages_tl.loadLibrary,
  'tr': messages_tr.loadLibrary,
  'ug': messages_ug.loadLibrary,
  'uk': messages_uk.loadLibrary,
  'ur': messages_ur.loadLibrary,
  'uz': messages_uz.loadLibrary,
  'vi': messages_vi.loadLibrary,
  'zh': messages_zh.loadLibrary,
  'zh_CN': messages_zh_cn.loadLibrary,
  'zh_TW': messages_zh_tw.loadLibrary,
  'zu': messages_zu.loadLibrary,
};

MessageLookupByLibrary? _findExact(String localeName) {
  switch (localeName) {
    case 'af':
      return messages_af.messages;
    case 'am':
      return messages_am.messages;
    case 'ar':
      return messages_ar.messages;
    case 'as':
      return messages_as.messages;
    case 'az':
      return messages_az.messages;
    case 'be':
      return messages_be.messages;
    case 'bg':
      return messages_bg.messages;
    case 'bn':
      return messages_bn.messages;
    case 'bo':
      return messages_bo.messages;
    case 'bs':
      return messages_bs.messages;
    case 'ca':
      return messages_ca.messages;
    case 'cs':
      return messages_cs.messages;
    case 'cy':
      return messages_cy.messages;
    case 'da':
      return messages_da.messages;
    case 'de':
      return messages_de.messages;
    case 'el':
      return messages_el.messages;
    case 'en':
      return messages_en.messages;
    case 'es':
      return messages_es.messages;
    case 'et':
      return messages_et.messages;
    case 'eu':
      return messages_eu.messages;
    case 'fa':
      return messages_fa.messages;
    case 'fi':
      return messages_fi.messages;
    case 'fil':
      return messages_fil.messages;
    case 'fr':
      return messages_fr.messages;
    case 'ga':
      return messages_ga.messages;
    case 'gl':
      return messages_gl.messages;
    case 'gsw':
      return messages_gsw.messages;
    case 'gu':
      return messages_gu.messages;
    case 'he':
      return messages_he.messages;
    case 'hi':
      return messages_hi.messages;
    case 'hr':
      return messages_hr.messages;
    case 'hu':
      return messages_hu.messages;
    case 'hy':
      return messages_hy.messages;
    case 'id':
      return messages_id.messages;
    case 'is':
      return messages_is.messages;
    case 'it':
      return messages_it.messages;
    case 'ja':
      return messages_ja.messages;
    case 'ka':
      return messages_ka.messages;
    case 'kk':
      return messages_kk.messages;
    case 'km':
      return messages_km.messages;
    case 'kn':
      return messages_kn.messages;
    case 'ko':
      return messages_ko.messages;
    case 'ku':
      return messages_ku.messages;
    case 'ky':
      return messages_ky.messages;
    case 'lo':
      return messages_lo.messages;
    case 'lt':
      return messages_lt.messages;
    case 'lv':
      return messages_lv.messages;
    case 'mk':
      return messages_mk.messages;
    case 'ml':
      return messages_ml.messages;
    case 'mn':
      return messages_mn.messages;
    case 'mr':
      return messages_mr.messages;
    case 'ms':
      return messages_ms.messages;
    case 'my':
      return messages_my.messages;
    case 'nb':
      return messages_nb.messages;
    case 'ne':
      return messages_ne.messages;
    case 'nl':
      return messages_nl.messages;
    case 'no':
      return messages_no.messages;
    case 'or':
      return messages_or.messages;
    case 'pa':
      return messages_pa.messages;
    case 'pl':
      return messages_pl.messages;
    case 'ps':
      return messages_ps.messages;
    case 'pt_BR':
      return messages_pt_br.messages;
    case 'pt_PT':
      return messages_pt_pt.messages;
    case 'ro':
      return messages_ro.messages;
    case 'ru':
      return messages_ru.messages;
    case 'si':
      return messages_si.messages;
    case 'sk':
      return messages_sk.messages;
    case 'sl':
      return messages_sl.messages;
    case 'sq':
      return messages_sq.messages;
    case 'sr':
      return messages_sr.messages;
    case 'sv':
      return messages_sv.messages;
    case 'sw':
      return messages_sw.messages;
    case 'ta':
      return messages_ta.messages;
    case 'te':
      return messages_te.messages;
    case 'th':
      return messages_th.messages;
    case 'ti':
      return messages_ti.messages;
    case 'tl':
      return messages_tl.messages;
    case 'tr':
      return messages_tr.messages;
    case 'ug':
      return messages_ug.messages;
    case 'uk':
      return messages_uk.messages;
    case 'ur':
      return messages_ur.messages;
    case 'uz':
      return messages_uz.messages;
    case 'vi':
      return messages_vi.messages;
    case 'zh':
      return messages_zh.messages;
    case 'zh_CN':
      return messages_zh_cn.messages;
    case 'zh_TW':
      return messages_zh_tw.messages;
    case 'zu':
      return messages_zu.messages;
    default:
      return null;
  }
}

/// User programs should call this before using [localeName] for messages.
Future<bool> initializeMessages(String localeName) async {
  var availableLocale = Intl.verifiedLocale(
    localeName,
    (locale) => _deferredLibraries[locale] != null,
    onFailure: (_) => null,
  );
  if (availableLocale == null) {
    return new Future.value(false);
  }
  var lib = _deferredLibraries[availableLocale];
  await (lib == null ? new Future.value(false) : lib());
  initializeInternalMessageLookup(() => new CompositeMessageLookup());
  messageLookup.addLocale(availableLocale, _findGeneratedMessagesFor);
  return new Future.value(true);
}

bool _messagesExistFor(String locale) {
  try {
    return _findExact(locale) != null;
  } catch (e) {
    return false;
  }
}

MessageLookupByLibrary? _findGeneratedMessagesFor(String locale) {
  var actualLocale = Intl.verifiedLocale(
    locale,
    _messagesExistFor,
    onFailure: (_) => null,
  );
  if (actualLocale == null) return null;
  return _findExact(actualLocale);
}
