// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

main() {
  List<int> list1 = <int>[1, 2, 3];
  List<int> list2 = const <int>[4, 5, 6];
  List<String> list3 = <String>[];
  Set<int> set1 = new Set<int>();
  set1..add(11)
      ..add(12)
      ..add(13);
  Set set2 = new Set();

  Expect.equals(2, list1.lastMatching((x) => x.isEven));
  Expect.equals(3, list1.lastMatching((x) => x.isOdd));
  Expect.throws(() => list1.lastMatching((x) => x > 3),
                (e) => e is StateError);
  Expect.equals(null, list1.lastMatching((x) => x > 3, orElse: () => null));
  Expect.equals(499, list1.lastMatching((x) => x > 3, orElse: () => 499));

  Expect.equals(6, list2.lastMatching((x) => x.isEven));
  Expect.equals(5, list2.lastMatching((x) => x.isOdd));
  Expect.throws(() => list2.lastMatching((x) => x == 0),
                (e) => e is StateError);
  Expect.equals(null, list2.lastMatching((x) => false, orElse: () => null));
  Expect.equals(499, list2.lastMatching((x) => false, orElse: () => 499));

  Expect.throws(() => list3.lastMatching((x) => x == 0),
                (e) => e is StateError);
  Expect.throws(() => list3.lastMatching((x) => true), (e) => e is StateError);
  Expect.equals(null, list3.lastMatching((x) => true, orElse: () => null));
  Expect.equals("str", list3.lastMatching((x) => false, orElse: () => "str"));

  Expect.equals(12, set1.lastMatching((x) => x.isEven));
  var odd = set1.lastMatching((x) => x.isOdd);
  Expect.isTrue(odd == 11 || odd == 13);
  Expect.throws(() => set1.lastMatching((x) => false), (e) => e is StateError);
  Expect.equals(null, set1.lastMatching((x) => false, orElse: () => null));
  Expect.equals(499, set1.lastMatching((x) => false, orElse: () => 499));

  Expect.throws(() => set2.lastMatching((x) => false), (e) => e is StateError);
  Expect.throws(() => set2.lastMatching((x) => true), (e) => e is StateError);
  Expect.equals(null, set2.lastMatching((x) => true, orElse: () => null));
  Expect.equals(499, set2.lastMatching((x) => false, orElse: () => 499));
}
