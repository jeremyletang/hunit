package tests;

import hunit.Assert;
import hunit.AssertException;
import hunit.HUnitTest;

import php.Lib;

class TestFramework implements HUnitTest {
    private var i = 0;

    public function new() {}

    @hbefore
    public function beforeTest() {
        Sys.println("I BEFORE = " + i);
    }

    @hafter
    public function afterTest() {
        Sys.println("I AFTER = " + i);
        this.i = 0;
    }

    @htest
    public function isThisTest() {
        this.i += 1;
        Assert.eq(1, 2);
    }

    @htest
    public function isThisASecondeTest() {
        Assert.isTrue(true);
    }
}