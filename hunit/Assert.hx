package hunit;

import hunit.AssertException;

class Assert {
    public static function eq<T>(left_val: T, right_val: T) {
        if (left_val == right_val && right_val == left_val) {
            // nothing to do
        } else {
            throw new AssertException("(left == right) && (right == left)` (left: `"
                                      + left_val + "`, right: `" + right_val + "`)");
        }
    }

    public static function  notEq<T>(left_val: T, right_val: T) {
        if (left_val != right_val && right_val != left_val) {
            // nothing to do
        } else {
            throw new AssertException("(left != right) && (right != left)` (left: `"
                                      + left_val + "`, right: `" + right_val + "`)");
        }

    }

    public static function isTrue(val: Bool) {
        if (val != true) {
            throw new AssertException("expected true but found false");
        }
    }

    public static function isFalse(val: Bool) {
        if (val != false) {
            throw new AssertException("expected false but found true");
        }
    }

    public static function isNull<T>(object: T) {
        if (object != null) {
            throw new AssertException("expected null object but found non-null object");
        }
    }

    public static function notNull<T>(object: T) {
        if (object == null) {
            throw new AssertException("expected non-null object but found null objet");
        }
    }

    // public static function same(left_object: T, right_object: T) {
    //     if ()
    // }

    public static function fail(msg: String) {
        throw new AssertException(msg);
    }

    public static function fail2() {
        throw new AssertException("");
    }
}