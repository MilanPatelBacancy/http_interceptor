/// When having an URL as String and no parameters sent then it adds
/// them to the string.


String addParametersToStringUrl(String url, Map<String, String>? parameters) {
  return buildUrlString(url, parameters);
}

Uri addParametersToUrl(Uri url, Map<String, String>? parameters) {
  if (parameters == null) return url;

  String paramUrl = url.origin + url.path;

  Map<String, String> newParameters = {};

  url.queryParameters.forEach((key, value) {
    newParameters[key] = value;
  });

  parameters.forEach((key, value) {
    newParameters[key] = value;
  });

  return Uri.parse(buildUrlString(paramUrl, newParameters));
}


/// Takes a string and appends [parameters] as query parameters of [url].
///
/// It does not check if [url] is valid, it just appends the parameters.
String buildUrlString(String url, Map<String, dynamic>? parameters) {
  // Avoids unnecessary processing.
  if (parameters == null) return url;

  // Check if there are parameters to add.
  if (parameters.length > 0) {
    // Checks if the string url already has parameters.
    if (url.contains("?")) {
      url += "&";
    } else {
      url += "?";
    }

    // Concat every parameter to the string url.
    parameters.forEach((key, value) {
      if (value is List) {
        if (value is List<String>) {
          for (String singleValue in value) {
            url += "$key=${Uri.encodeQueryComponent(singleValue)}&";
          }
        } else {
          for (dynamic singleValue in value) {
            url += "$key=${Uri.encodeQueryComponent(singleValue.toString())}&";
          }
        }
      } else if (value is String) {
        url += "$key=${Uri.encodeQueryComponent(value)}&";
      } else {
        url += "$key=${Uri.encodeQueryComponent(value.toString())}&";
      }
    });

    // Remove last '&' character.
    url = url.substring(0, url.length - 1);
  }

  return url;
}
