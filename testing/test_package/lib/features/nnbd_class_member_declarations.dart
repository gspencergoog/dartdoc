// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library nnbd_class_member_declarations;

/// Test required and covariant parameters
abstract class B {
  m1(
    int some,
    regular,
    covariant parameters, {
    required p1,
    int p2 = 3,
    required covariant p3,
    required covariant int p4,
  });
  m2(int sometimes, we, [String have, double optionals]);
}

/// Test nullable parameters, factories, members
class C {
  C() {}

  factory C.factory1(int? param, {Object? param2}) => C();

  int? testField;

  List<int?> get testFieldNullableParameter => [];

  List<Map<String, num?>>? method1() => null;

  void m3(void listen(int t)?, {void onDone()?}) {}
}
