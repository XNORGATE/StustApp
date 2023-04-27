import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

String extractHtmlContent(String html, String tagName,   {String className='',String id ='',int index = 0}) {
  // Parse the HTML string
 dom.Document document = parser.parse(html);

  List<dom.Element> elements;

  // Filter elements by tag name, class name, or id
  if (tagName.isNotEmpty) {
    elements = document.getElementsByTagName(tagName);
  } else {
    elements = document.querySelectorAll('*');
  }

  if (className.isNotEmpty) {
    elements = elements.where((element) => element.classes.contains(className)).toList();
  }

  if (id.isNotEmpty) {
    elements = elements.where((element) => element.id == id).toList();
  }

  // Check if elements are available
  if (elements.isNotEmpty && index >= 0 && index < elements.length) {
    // Return the specific element's inner HTML
    return elements[index].innerHtml;
  }

  return '';
}
