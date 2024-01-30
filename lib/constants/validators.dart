

import 'package:easy_localization/easy_localization.dart';

import '../l10n/locale_keys.g.dart';

String? validateEmail(value, isValid, arabic) {
  if (value == null || value.isEmpty) {
    return arabic ? 'رجاءا أدخل بريدك الإلكتروني' : 'Please enter your email';
  }
  if (value.isNotEmpty && isValid == false) {
    return arabic ? 'يرجى إدخال البريد الإلكتروني الصحيح' : 'Please enter a valid email';
  }
  return null;
}

String? validatePassword(value, email, arabic) {
  if (email.isNotEmpty) {
    if (value.isEmpty || value == null) {
      return arabic ? 'الرجاء إدخال كلمة المرور' : 'Please enter password';
    }
    if (value.length < 3) {
      return arabic ? 'الرجاء إدخال كلمة السر الصحيحة' : 'Please enter a valid password';
    }
  }
  return null;
}

String? validateSamePassword(value, password, arabic) {
  if (value != password) {
    return arabic ? 'تأكيد كلمة المرور يجب أن تكون نفس كلمة المرور' : 'Confirm password must be same as password';
  } else if (value.isEmpty && password.isEmpty) {
    return null;
  } else if (value == null || value.isEmpty) {
    return arabic ? 'الرجاء إدخال تأكيد كلمة المرور' : 'Please enter confirm password';
  }

  return null;
}

String? validateYear(value) {
  if (value == null || value.length == 0) {
    return 'Please enter your car purchase year';
  }
  int year = int.parse(value);
  if (year >= 1950 && year <= 2030) {
    return null;
  } else {
    return 'Please enter a valid car purchase year';
  }
}

String? validatePrice(value, arabic) {
  String? checkNullEmpty = checkNullEmptyValidation(value, 'price', arabic);
  if (checkNullEmpty != null) {
    return checkNullEmpty;
  }
  return null;
}

String? validateMobile(value, arabic) {
  String? checkNullEmpty = checkNullEmptyValidation(value, LocaleKeys.phoneNumber.tr(), arabic);
  if (checkNullEmpty != null) {
    return checkNullEmpty;
  }
  if (value.length != 10) {
    return arabic ? "يرجى إدخال رقم هاتف صالح" : 'Please enter a valid mobile number';
  }
  return null;
}

String? checkNullEmptyValidation(value, title, arabic) {
  if (value == null || value.isEmpty) {
    return (arabic) ? 'من فضلك أدخل $title' : 'Please enter your $title ';
  }
  return null;
}

intToStringFormatter(value) {
  NumberFormat numberFormat = NumberFormat("##,##,##0");
  var parse = int.parse(value);
  var formattedValue = numberFormat.format(parse);
  return formattedValue;
}

formattedTime(value) {
  var date = DateTime.fromMicrosecondsSinceEpoch(value);
  var formattedDate = DateFormat.yMMMd().format(date);
  return formattedDate;
}
