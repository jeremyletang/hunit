package tests;

import hunit.Assert;
import hunit.AssertException;
import hunit.HUnitTest;

import php.Lib;

class TestUseless implements HUnitTest {

    public function new() {}

    // should fail
    @htest
    public function ifIDoThisThenThisMakeThis() {
        Assert.eq(1, 2);
    }

    // should fail
    @htest
    @hexpect_exception("Int")
    public function isWhatWhatWhatTheFuckInt() {
        Assert.isTrue(true);
        throw "this is an exception";
    }

    // should sucess
    @htest
    @hexpect_exception("String")
    public function isWhatWhatWhatTheFuckString() {
        Assert.isTrue(true);
        throw "this is an exception";
    }
}