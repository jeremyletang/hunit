package tests;

import hunit.Assert;
import hunit.AssertException;
import hunit.HUnitTest;

import php.Lib;

class TestUseless implements HUnitTest {

    public function new() {}

    // should fail
    @htest
    @hshould_fail
    public function ifIDoThisThenThisMakeThis() {
        Assert.eq(1, 2);
    }

    // should fail
    @htest
    @hshould_fail
    @hexpect_throw("Int")
    public function isWhatWhatWhatTheFuckInt() {
        Assert.isTrue(true);
        throw "this is an exception";
    }

    // should sucess
    @htest
    @hexpect_throw("String")
    public function isWhatWhatWhatTheFuckString() {
        Assert.isTrue(true);
        throw "this is an exception";
    }
}