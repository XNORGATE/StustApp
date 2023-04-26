import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

String extractHtmlContent(String html, String tagName,  String className, {int index = 0}) {
  // Parse the HTML string
  dom.Document document = parser.parse(html);

  // Find elements by tag name
  List<dom.Element> elements = document.getElementsByTagName(tagName);

  // Filter elements by class name if provided
  if (className.isNotEmpty) {
    elements = elements.where((element) => element.classes.contains(className)).toList();
  }

  // Check if elements are available
  if (elements.isNotEmpty && index >= 0 && index < elements.length) {
    // Return the specific element's inner HTML
    return elements[index].innerHtml;
  }

  return '';
}
