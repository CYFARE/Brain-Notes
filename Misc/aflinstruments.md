CLASSIC - The default instrumentation mode, providing traditional edge coverage. It tracks transitions between basic blocks.

CTX - Adds context-sensitive edge coverage by tracking not just the current transition but also the history of prior edges. Useful for deeper exploration of complex code paths.

NGRAM-2, NGRAM-3, ..., NGRAM-k - Tracks sequences of 2, 3, or k consecutive edges, enabling higher-order Markov modeling for coverage. Useful for fuzzing applications with context-sensitive logic.

LTO - Uses Link-Time Optimization for instrumentation, enabling whole-program optimization and analysis. Recommended for large, complex programs where precise instrumentation is needed.

PCGUARD - Adds fine-grained instrumentation at every control flow decision (e.g., branches, calls, returns). Provides high-quality coverage but can be slower.

NONE - Disables instrumentation. Useful for testing or building targets without instrumentation for specific purposes.

TRACE-PC - Records the program counter (PC) for each basic block executed. Primarily used for debugging or for generating execution traces.

TRACE-CMP - Focuses on tracking and logging comparisons (e.g., `cmp`, `strcmp`) during execution. Useful for fuzzing inputs that rely on matching specific patterns or values.

REDQUEEN - Implements value tracking and mutation techniques to guide fuzzing based on observed constraints. Useful for fuzzing input-dependent code.

QASAN - Combines AFL++ with AddressSanitizer (ASAN) to find memory corruption bugs. It integrates sanitization into the fuzzing workflow.

COVERAGE_ONLY - Enables lightweight instrumentation for edge coverage without additional tracking features. Good for performance-focused fuzzing.

AUTO_DICT - Automatically extracts and instruments dictionary-like inputs (e.g., strings) from the target code. Useful for fuzzing structured inputs like JSON or XML.

INST_RATIO - Controls the percentage of basic blocks instrumented. Can be used to reduce overhead for extremely large binaries.