/// a library with errors.
library doc_errors;

// This is the place to put documentation that has errors in it:
// This package is expected to fail.
abstract class DocumentationErrors {
  /// Animation method with invalid name
  ///
  /// {@animation 100 100 http://host/path/to/video.mp4 id=2isNot-A-ValidName}
  /// More docs
  void withInvalidNamedAnimation() {}

  /// Non-Unique Animation method (between methods)
  ///
  /// {@animation 100 100 http://host/path/to/video.mp4 id=barHerderAnimation}
  /// {@animation 100 100 http://host/path/to/video.mp4n id=barHerderAnimation}
  /// More docs
  void withAnimationNonUnique() {}

  /// Non-Unique deprecated Animation method (between methods)
  ///
  /// {@animation fooHerderAnimation 100 100 http://host/path/to/video.mp4}
  /// {@animation fooHerderAnimation 100 100 http://host/path/to/video.mp4}
  /// More docs
  void withAnimationNonUniqueDeprecated() {}

  /// Malformed Animation method with wrong parameters
  ///
  /// {@animation http://host/path/to/video.mp4}
  /// More docs
  void withAnimationWrongParams() {}

  /// Malformed Animation method with non-integer width
  ///
  /// {@animation 100px 100 http://host/path/to/video.mp4 id=badWidthAnimation}
  /// More docs
  void withAnimationBadWidth() {}

  /// Malformed Animation method with non-integer height
  ///
  /// {@animation 100 100px http://host/path/to/video.mp4 id=badHeightAnimation}
  /// More docs
  void withAnimationBadHeight() {}

  /// Animation with an argument that is not the id.
  ///
  /// Tests to see that it gives an error when arguments that are not
  /// recognized are added.
  /// {@animation 100 100 http://host/path/to/video.mp4 name=theName}
  void withAnimationUnknownArg() {}
}
