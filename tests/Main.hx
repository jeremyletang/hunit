package ;

import hunit.HUnitTestRunner;

import tests.TestFramework;
import tests.TestUseless;

class Main {
    static function main(): Int {
        var runner = new HUnitTestRunner();
        runner.run();
    }
}