// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:expect/expect.dart';
import
    '../../../sdk/lib/_internal/compiler/implementation/types/types.dart'
    show ContainerTypeMask, TypeMask;

import 'compiler_helper.dart';
import 'parser_helper.dart';


String generateTest(String listAllocation) {
  return """
int anInt = 42;
double aDouble = 42.5;

class A {
  final field;
  var nonFinalField;

  A(this.field);

  A.bar(list) {
    nonFinalField = list;
  }

  receiveIt(list) {
    list[0] = aDouble;
  }

  returnIt() {
    return listReturnedFromSelector;
  }

  useField() {
    field[0] = aDouble;
  }

  set callSetter(list) {
    list[0] = aDouble;
  }

  operator[](index) {
    index[0] = aDouble;
  }

  operator[]=(index, value) {
    index[0] = anInt;
    if (value == listEscapingTwiceInIndexSet) {
      value[0] = aDouble;
    }
  }
}

class B extends A {
  B(list) : super.bar(list);

  set nonFinalField(value) {
    value[0] = aDouble;
  }
}

var listInField = $listAllocation;
var listPassedToClosure = $listAllocation;
var listReturnedFromClosure = $listAllocation;
var listPassedToMethod = $listAllocation;
var listReturnedFromMethod = $listAllocation;
var listUsedWithCascade = $listAllocation;
var listUsedInClosure = $listAllocation;
var listPassedToSelector = $listAllocation;
var listReturnedFromSelector = $listAllocation;
var listUsedWithAddAndInsert = $listAllocation;
var listUsedWithNonOkSelector = $listAllocation;
var listUsedWithConstraint = $listAllocation;
var listEscapingFromSetter = $listAllocation;
var listUsedInLocal = $listAllocation;
var listUnset = $listAllocation;
var listOnlySetWithConstraint = $listAllocation;
var listEscapingInSetterValue = $listAllocation;
var listEscapingInIndex = $listAllocation;
var listEscapingInIndexSet = $listAllocation;
var listEscapingTwiceInIndexSet = $listAllocation;
var listPassedAsOptionalParameter = $listAllocation;
var listPassedAsNamedParameter = $listAllocation;
var listSetInNonFinalField = $listAllocation;
var listWithChangedLength = $listAllocation;

foo(list) {
  list[0] = aDouble;
}

bar() {
  return listReturnedFromMethod;
}

takeOptional([list]) {
  list[0] = aDouble;
}

takeNamed({list}) {
  list[0] = aDouble;
}

main() {
  listReturnedFromMethod[0] = anInt;
  bar()[0] = aDouble;

  listPassedToMethod[0] = anInt;
  foo(listPassedToMethod);

  listPassedToClosure[0] = anInt;
  ((a) => a[0] = aDouble)(listPassedToClosure);

  listReturnedFromClosure[0] = anInt;
  (() => listReturnedFromClosure)[0] = aDouble;

  listInField[0] = anInt;
  new A(listInField).useField();

  listUsedWithCascade[0] = anInt;
  listUsedWithCascade..[0] = aDouble;

  listUsedInClosure[0] = anInt;
  (() => listUsedInClosure[0] = aDouble)();

  listPassedToSelector[0] = anInt;
  new A(null).receiveIt(listPassedToSelector);

  listReturnedFromSelector[0] = anInt;
  new A(null).returnIt()[0] = aDouble;

  listUsedWithAddAndInsert.add(anInt);
  listUsedWithAddAndInsert.insert(0, aDouble);

  listUsedWithNonOkSelector[0] = anInt;
  listUsedWithNonOkSelector.addAll(listPassedToClosure);

  listUsedWithConstraint[0] = anInt;
  listUsedWithConstraint[0]++;
  listUsedWithConstraint[0] += anInt;

  listEscapingFromSetter[0] = anInt;
  foo(new A(null).field = listEscapingFromSetter);

  listUsedInLocal[0] = anInt;
  var a = listUsedInLocal;
  listUsedInLocal[1] = aDouble;

  // At least use [listUnused] in a local to pretend it's used.
  var b = listUnset;

  listOnlySetWithConstraint[0]++;

  listEscapingInSetterValue[0] = anInt;
  new A().callSetter = listEscapingInSetterValue;

  listEscapingInIndex[0] = anInt;
  new A()[listEscapingInIndex];

  new A()[listEscapingInIndexSet] = 42;

  new A()[listEscapingTwiceInIndexSet] = listEscapingTwiceInIndexSet;

  listPassedAsOptionalParameter[0] = anInt;
  takeOptional(listPassedAsOptionalParameter);

  listPassedAsNamedParameter[0] = anInt;
  takeNamed(list: listPassedAsNamedParameter);

  listSetInNonFinalField[0] = anInt;
  new B(listSetInNonFinalField);

  listWithChangedLength[0] = anInt;
  listWithChangedLength.length = 54;
}
""";
}

void main() {
  doTest('[]', nullify: false); // Test literal list.
  doTest('new List()', nullify: false); // Test growable list.
  doTest('new List(1)', nullify: true); // Test fixed list.
  doTest('new List.filled(1, 0)', nullify: false); // Test List.filled.
  doTest('new List.filled(1, null)', nullify: true); // Test List.filled.
}

void doTest(String allocation, {bool nullify}) {
  Uri uri = new Uri(scheme: 'source');
  var compiler = compilerFor(generateTest(allocation), uri);
  compiler.runCompiler(uri);
  var typesInferrer = compiler.typesTask.typesInferrer;

  checkType(String name, type) {
    var element = findElement(compiler, name);
    ContainerTypeMask mask = typesInferrer.getTypeOfElement(element);
    if (nullify) type = type.nullable();
    Expect.equals(type, mask.elementType.simplify(compiler), name);
  }

  checkType('listInField', typesInferrer.numType);
  checkType('listPassedToMethod', typesInferrer.numType);
  checkType('listReturnedFromMethod', typesInferrer.numType);
  checkType('listUsedWithCascade', typesInferrer.numType);
  checkType('listUsedInClosure', typesInferrer.numType);
  checkType('listPassedToSelector', typesInferrer.numType);
  checkType('listReturnedFromSelector', typesInferrer.numType);
  checkType('listUsedWithAddAndInsert', typesInferrer.numType);
  checkType('listUsedWithConstraint', typesInferrer.numType);
  checkType('listEscapingFromSetter', typesInferrer.numType);
  checkType('listUsedInLocal', typesInferrer.numType);
  checkType('listEscapingInSetterValue', typesInferrer.numType);
  checkType('listEscapingInIndex', typesInferrer.numType);
  checkType('listEscapingInIndexSet', typesInferrer.intType);
  checkType('listEscapingTwiceInIndexSet', typesInferrer.numType);
  checkType('listSetInNonFinalField', typesInferrer.numType);
  checkType('listWithChangedLength', typesInferrer.intType.nullable());

  checkType('listPassedToClosure', typesInferrer.dynamicType);
  checkType('listReturnedFromClosure', typesInferrer.dynamicType);
  checkType('listUsedWithNonOkSelector', typesInferrer.dynamicType);
  checkType('listPassedAsOptionalParameter', typesInferrer.dynamicType);
  checkType('listPassedAsNamedParameter', typesInferrer.dynamicType);

  if (!allocation.contains('filled')) {
    checkType('listUnset', new TypeMask.nonNullEmpty());
    checkType('listOnlySetWithConstraint', new TypeMask.nonNullEmpty());
  }
}
