package hunit;

class AssertException {

    private var message: String = "";

    public function new(message: String) {
        this.message = message;
    }

    public function toStr(): String {
        return "assertion failed " + message + ".";
    }
}