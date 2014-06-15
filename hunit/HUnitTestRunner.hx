package hunit;

import haxe.macro.Expr;
import haxe.macro.Expr.ExprOf;
import haxe.macro.Context;

import hunit.TestResult;

// import haxe.macro.Type;

class HUnitTestRunner {

    private static var static_test_class: Array<{class_name: String, methods: Array<String>}> = [];
    private var test_classes: Array<{class_name: String, methods: Array<String>}> = [];

    public function new() { this.test_classes = makeTestClass(); }

    macro private static function makeTestClass() : Expr {
        return Context.makeExpr(static_test_class, Context.currentPos());
    }

    macro public static function readMetadata(): Array<Field> {
        var class_fields = Context.getBuildFields();
        var methods: Array<String> = [];

        for (f in class_fields) {
            for (m in f.meta) {
                if (m.name == "htest") {
                    switch (f.kind) {
                        case FFun(_): {
                            methods.push(f.name);
                        }
                        case _: throw new Error("@htest must be used on methods", Context.currentPos());
                    }
                }
            }
        }
        static_test_class.push({
            class_name: Context.getLocalClass().get().module,
            methods: methods
        });

        return class_fields;
    }

    public function run() {
        var total_success = 0;
        var total_failure = 0;
        var local_success = 0;
        var local_failure = 0;

        Sys.println("run tests:");
        for (t in this.test_classes) {
            local_failure = 0;
            local_success = 0;
            Sys.println("[hunit] Running " + t.class_name);
            var test_class = Type.resolveClass(t.class_name);
            for (m in t.methods) {
                Sys.print("    [hunit] Test " + m + "... ");
                switch (this.launchTest(test_class, m)) {
                    case Ok: local_success += 1; Sys.println("\x1b[32mOK\x1b[39;49m.");
                    case Fail(str): {
                        local_failure += 1;
                        Sys.println("\x1b[31mFAILED\x1b[39;49m.");
                        Sys.println("        " + str);
                    }
                };
            }
            Sys.println("    [hunit] Results for " + t.class_name +
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
    }

    private function launchTest(test_class: Dynamic, method_name: String): TestResult {
        var return_value = Ok;

        try {
            Reflect.callMethod(test_class, Reflect.field(test_class, method_name), []);
            return_value = Ok;
        } catch (ex: AssertException) {
            return_value = Fail(ex.toStr());
        } catch (e: Dynamic) {
            return_value =  Fail("error");
        }

        return return_value;
    }
}