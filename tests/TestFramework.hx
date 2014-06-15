package tests;

import hunit.Assert;
import hunit.AssertException;
import hunit.HUnitTest;

import php.Lib;

class TestFramework implements HUnitTest {

    public function new() {}

    @htest
    public function isThisTest() {
        Assert.eq(1, 2);
    }

    @htest
    public function isThisASecondeTest() {
        Assert.isTrue(true);
    }
}