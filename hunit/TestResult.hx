package hunit;

enum TestResult {
    Ok;
    Fail(ex: Dynamic);
}