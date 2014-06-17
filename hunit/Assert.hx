// The MIT License (MIT)
//
// Copyright (c) 2014 Jeremy Letang
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

package hunit;

import haxe.ds.Option;

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

    public static function isSome<T>(object: Option<T>) {
        switch (object) {
            case Some(o): {};
            case None: throw new AssertException("expected Some(object) but found None");
        }
    }

    public static function isNone<T>(object: Option<T>) {
        switch (object) {
            case Some(o): throw new AssertException("expected None but found Some(object)");
            case None: {};
        }
    }

    public static function fail(msg: String) {
        throw new AssertException(msg);
    }

    public static function fail2() {
        throw new AssertException("");
    }
}