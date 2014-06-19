// The MIT License (MIT)
//
// Copyright (c) 2014 Jeremy Letang
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

package hunit;

import haxe.macro.Expr;
import haxe.macro.Expr.ExprOf;
import haxe.macro.Context;

typedef MethodDatas = {
    name: String,
    exception: String,
    should_fail: Bool,
    is_ignored: Bool
};

typedef ClassDatas = {
    name: String,
    before: String,
    after: String,
    before_class: String,
    after_class: String,
    methods: Array<MethodDatas>
};

class MetaReader {

    private static var static_test_class: Array<ClassDatas> = [];
    private var test_classes: Array<ClassDatas> = [];

    public function new() { this.test_classes = makeTestClass(); }

    public function getTestClasses(): Array<ClassDatas> {
        return this.test_classes;
    }

    macro private static function makeTestClass() : Expr {
        return Context.makeExpr(static_test_class, Context.currentPos());
    }

    macro public static function readMetadata(): Array<Field> {
        var class_fields = Context.getBuildFields();
        var methods: Array<MethodDatas> = [];
        var before: String = "";
        var after: String = "";
        var before_class: String = "";
        var after_class: String = "";
        var should_fail: Bool = false;

        for (f in class_fields) {
            var method_name: String = "";
            var exception: String = "";
            var should_fail: Bool = false;
            var is_ignored: Bool = false;

            for (m in f.meta) {
                switch (m.name) {
                    case "test": { // test metadata
                        switch (f.kind) {
                            case FFun(_): method_name = f.name; // only on methods fields
                            case _: throw new Error("@test must be used on methods", Context.currentPos());
                        }
                    }
                    case "ignore": { // ignore metadata
                        switch (f.kind) {
                            case FFun(_): is_ignored = true; // only on methods fields
                            case _: throw new Error("@ignore must be used on methods", Context.currentPos());
                        }
                    }
                    case "before": { // before metadata
                        switch (f.kind) {
                            case FFun(_): before = f.name; // only on methods fields
                            case _: throw new Error("@before must be used on methods", Context.currentPos());
                        }
                    }
                    case "after": { // after metadata
                        switch (f.kind) {
                            case FFun(_): after = f.name; // only on methods fields
                            case _: throw new Error("@after must be used on methods", Context.currentPos());
                        }
                    }
                    case "before_class": { // before_class metadata
                        switch (f.kind) {
                            case FFun(_): before_class = f.name; // only on methods fields
                            case _: throw new Error("@before_class must be used on methods", Context.currentPos());
                        }
                    }
                    case "after_class": { // after_class metadata
                        switch (f.kind) {
                            case FFun(_): after_class = f.name; // only on methods fields
                            case _: throw new Error("@after_class must be used on methods", Context.currentPos());
                        }
                    }
                    case "should_fail": { // should_fail metadata
                        switch (f.kind) {
                            case FFun(_): should_fail = true; // only on methods fields
                            case _: throw new Error("@should_fail must be used on methods", Context.currentPos());
                        }
                    }
                    case "expect_throw": { // excpect_exception
                        switch (f.kind) {
                            case FFun(_): { // only on methods fields
                                for (p in m.params) { // checks parameters of the metadata
                                    switch (p.expr) {
                                        case EConst(CString(i)): { // check if the expr is a CString
                                            var r = Type.resolveClass(i);
                                            if (Type.resolveClass(i) != null) { // verify that the class exception exist
                                                exception = i;
                                            } else {
                                                throw new Error("@expect_throw must be used with valid exception class, " +
                                                                i + " is not a class.", Context.currentPos());
                                            }
                                        }
                                        case _: new Error("@expect_throw must be used with string literal, ",Context.currentPos());
                                    }
                                }
                            }
                            case _: throw new Error("@expect_throw must be used on methods", Context.currentPos());
                        }
                    }
                    case _: {}
                }
            }
            if (method_name != "") { // push the function name + the exception name
                methods.push({
                    name: method_name,
                    exception: exception,
                    should_fail: should_fail,
                    is_ignored: is_ignored
                });
            }
        }

        static_test_class.push({ // push the new test class
            name: Context.getLocalClass().get().module,
            before: before,
            after: after,
            before_class: before_class,
            after_class: after_class,
            methods: methods
        });

        return class_fields;
    }
}