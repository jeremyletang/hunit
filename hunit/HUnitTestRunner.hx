package hunit;

import haxe.macro.Expr;
import haxe.macro.Expr.ExprOf;
import haxe.macro.Context;

import hunit.TestResult;

// class ClassDatas {
//     public var name: String;
//     public var methods: Array<MethodDatas> = [];

//     public function new(name: String) {
//         this.name = name;
//     }

//     public function getMethods(): Array<MethodDatas> {
//         return this.methods;
//     }

//     public function addMethod(method: MethodDatas) {
//         this.methods.push(method);
//     }
// }

typedef MethodDatas = {
    name: String,
    exception: String
};

typedef ClassDatas = {
    name: String,
    methods: Array<MethodDatas>
};


// class MethodDatas {
//     public var name: String;
//     public var exception: String;

//     public function new(name: String, exception: String) {
//         this.name = name;
//         this.exception = exception;
//     }
// }

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
                    case "hexpect_exception": { // hexcpect_exception
                        switch (f.kind) {
                            case FFun(_): { // only on methods fields
                                for (p in m.params) { // checks parameters of the metadata
                                    switch (p.expr) {
                                        case EConst(CString(i)): { // check if the expr is a CString
                                            var r = Type.resolveClass(i);
                                            if (Type.resolveClass(i) != null) { // verify that the class exception exist
                                                exception = i;
                                            } else {
                                                throw new Error("@hexpect_exception must be used with valid exception class, " +
                                                                i + " is not a class.", Context.currentPos());
                                            }
                                        }
                                        case _: new Error("@hexpect_exception must be used with string literal, ",Context.currentPos());
                                    }
                                }
                            }
                            case _: throw new Error("@hexpect_exception must be used on methods", Context.currentPos());
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
            var test_class = Type.resolveClass(t.name); // resolve the class
            for (m in t.methods) { // for all methods launch test
                Sys.print("    [hunit] Test " + m.name + "... ");
                switch (this.launchTest(test_class, m)) {
                    case Ok: local_success += 1; Sys.println("\x1b[32mOK\x1b[39;49m.");
                    case Fail(str): {
                        local_failure += 1;
                        Sys.println("\x1b[31mFAILED\x1b[39;49m.");
                        Sys.println("        " + str);
                    }
                };
            }
            Sys.println("    [hunit] Results for " + t.name +
                        ": Runned: " + (local_success + local_failure) +
                        " / Success: " + local_success +
                        " / Failure: " + local_failure + "\n");
            total_success += local_success;
            total_failure += local_failure;
        }

        Sys.println("[hunit] Total results: " +
                    " Runned: " + (total_success + total_failure) +
                    " / Success: " + total_success +
                    " / Failure: " + total_failure + "\n");

        Sys.exit(total_failure);
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