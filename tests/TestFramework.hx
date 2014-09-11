package tests;

import hunit.Assert;
import hunit.AssertException;
import hunit.HUnitTest;

// import php.Lib;

class TestFramework implements HUnitTest {
    private var i = 0;

    public function new() {}

    @before
    public function beforeTest() {
    }

    @after
    public function afterTest() {
        this.i = 0;
    }

    @test
    @should_fail
    public function isThisTest() {
        this.i += 1;
        Assert.eq(1, 2);
    }

    @test
    public function isThisASecondeTest() {
        Assert.isTrue(true);
    }
}