package tests;

import hunit.Assert;
import hunit.AssertException;
import hunit.HUnitTest;

import php.Lib;

class TestUseless implements HUnitTest {

    public function new() {}

    @htest
    public function ifIDoThisThenThisMakeThis() {
        Assert.eq(1, 2);
    }

    @htest
    public function isWhatWhatWhatTheFuck() {
        Assert.isTrue(true);
    }
}