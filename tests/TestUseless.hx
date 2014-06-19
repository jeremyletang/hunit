package tests;

import hunit.Assert;
import hunit.AssertException;
import hunit.HUnitTest;

import php.Lib;

class TestUseless implements HUnitTest {

    public function new() {}

    // should fail
    @test
    @should_fail
    public function ifIDoThisThenThisMakeThis() {
        Assert.eq(1, 2);
    }

    // should fail
    @test
    @should_fail
    @expect_throw("Int")
    public function isWhatWhatWhatTheFuckInt() {
        Assert.isTrue(true);
        throw "this is an exception";
    }

    // should sucess
    @test
    @expect_throw("String")
    public function isWhatWhatWhatTheFuckString() {
        Assert.isTrue(true);
        throw "this is an exception";
    }
}