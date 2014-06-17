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

import hunit.TestResult;

typedef MethodDatas = {
    name: String,
    exception: String,
};

typedef ClassDatas = {
    name: String,
    before: String,
    after: String,
    before_class: String,
    after_class: String,
    methods: Array<MethodDatas>
};

class HUnitTestRunner {

    private static var static_test_class: Array<ClassDatas> = [];
    private var test_classes: Array<ClassDatas> = [];

    public function new() { this.test_classes = makeTestClass(); }

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

        for (f in class_fields) {
            var method_name = "";
            var exception = "";
            for (m in f.meta) {
                switch (m.name) {
                    case "htest": { // htest metadata
                        switch (f.kind) {
                            case FFun(_): method_name = f.name; // only on methods fields
                            case _: throw new Error("@htest must be used on methods", Context.currentPos());
                        }
                    }
                    case "hbefore": { // htest metadata
                        switch (f.kind) {
                            case FFun(_): before = f.name; // only on methods fields
                            case _: throw new Error("@hbefore must be used on methods", Context.currentPos());
                        }
                    }
                    case "hafter": { // htest metadata
                        switch (f.kind) {
                            case FFun(_): after = f.name; // only on methods fields
                            case _: throw new Error("@hafter must be used on methods", Context.currentPos());
                        }
                    }
                    case "hbefore_class": { // htest metadata
                        switch (f.kind) {
                            case FFun(_): before_class = f.name; // only on methods fields
                            case _: throw new Error("@hbefore must be used on methods", Context.currentPos());
                        }
                    }
                    case "hafter_class": { // htest metadata
                        switch (f.kind) {
                            case FFun(_): after_class = f.name; // only on methods fields
                            case _: throw new Error("@hafter must be used on methods", Context.currentPos());
                        }
                    }
                    case "hexpect_throw": { // hexcpect_exception
                        switch (f.kind) {
                            case FFun(_): { // only on methods fields
                                for (p in m.params) { // checks parameters of the metadata
                                    switch (p.expr) {
                                        case EConst(CString(i)): { // check if the expr is a CString
                                            var r = Type.resolveClass(i);
                                            if (Type.resolveClass(i) != null) { // verify that the class exception exist
                                                exception = i;
                                            } else {
                                                throw new Error("@hexpect_throw must be used with valid exception class, " +
                                                                i + " is not a class.", Context.currentPos());
                                            }
                                        }
                                        case _: new Error("@hexpect_throw must be used with string literal, ",Context.currentPos());
                                    }
                                }
                            }
                            case _: throw new Error("@hexpect_throw must be used on methods", Context.currentPos());
                        }
                    }
                    case _: {}
                }
            }
            if (method_name != "") { // push the function name + the exception name
                methods.push({
                    name: method_name,
                    exception: exception
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

    public function run() {
        var total_success = 0;
        var total_failure = 0;
        var local_success = 0;
        var local_failure = 0;

        for (t in this.test_classes) {
            local_failure = 0;
            local_success = 0;
            Sys.println("[hunit] Running " + t.name);

            // get the class
            var test_class = Type.createInstance(Type.resolveClass(t.name), []);

            // init the class
            this.launchTest(test_class, { name: t.before_class, exception: "" });

             // for all methods launch test
            for (m in t.methods) {
                // run before test
                this.launchTest(test_class, { name: t.before, exception: "" });
                // run the test
                switch (this.launchTest(test_class, m)) {
                    case Ok: local_success += 1; printTestSuccess(m.name);
                    case Fail(str): local_failure += 1; printTestFail(m.name, str);
                };
                // run after test
                this.launchTest(test_class, { name: t.after, exception: "" });
            }

            // clean the class
            this.launchTest(test_class, { name: t.after_class, exception: "" });

            // result for the class
            printLocalResult(local_success, local_failure, t.name);
            total_success += local_success;
            total_failure += local_failure;
        }

        // all the results
        this.printTotalResult(total_success, total_failure);

        // exit with total_failure -> no failure == 0 == OK !
        Sys.exit(total_failure);
    }

    private function printTestFail(test_name: String, o: Dynamic) {
        Sys.print("    [hunit] Test " + test_name + "... ");
        Sys.println("\x1b[31mFAILED\x1b[39;49m.");
        Sys.println("        " + o);
    }

    private function printTestSuccess(test_name: String) {
        Sys.print("    [hunit] Test " + test_name + "... ");
        Sys.println("\x1b[32mOK\x1b[39;49m.");
    }

    private function printTotalResult(total_success: Int, total_failure: Int) {
        Sys.println("[hunit] Total results: " +
                    " Runned: " + (total_success + total_failure) +
                    " / Success: " + total_success +
                    " / Failure: " + total_failure + "\n");
    }

    private function printLocalResult(local_success: Int, local_failure: Int, test_name: String) {
        Sys.println("    [hunit] Results for " + test_name +
                    ": Runned: " + (local_success + local_failure) +
                    " / Success: " + local_success +
                    " / Failure: " + local_failure + "\n");
    }

    private function launchTest(test_class: Dynamic, method: MethodDatas): TestResult {
        var return_value = Ok;

        if (method.exception == "") { // launch a simple test
            return_value = this.launchSimpleTest(test_class, method);
        } else { // launch a test wich handle an exception
            return_value = this.launchExceptionTest(test_class, method);
        }

        return return_value;
    }

    private function launchSimpleTest(test_class: Dynamic, method: MethodDatas): TestResult {
        var return_value = Ok;

        try {
            Reflect.callMethod(test_class, Reflect.field(test_class, method.name), []);
            return_value = Ok;
        } catch (ex: AssertException) { // Assert failure
            return_value = Fail(ex.toStr());
        } catch (e: Dynamic) { // unexpected internal method failure
            return_value = Fail("unexpected exception catched: " + e);
        }

        return return_value;
    }

    private function launchExceptionTest(test_class: Dynamic, method: MethodDatas): TestResult {
        var return_value = Ok;
        var type = Type.resolveClass(method.exception);

        try {
            Reflect.callMethod(test_class, Reflect.field(test_class, method.name), []);
            return_value = Fail("expected exception " + method.exception + ", no exception catched.");
        } catch (e: Dynamic) { // An exception should be raised
            if (type == Type.getClass(e)) { // check if the type of the exception is the needed one
                return_value = Ok;
            } else {
                return_value = Fail("Expected exception of type " + type + " but catched " + Type.getClass(e));
            }
        }

        return return_value;
    }
}