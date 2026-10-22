# llmcat

`llmcat` collects eligible text files under a directory, combines them into one document with a header for each file, and copies the result to the system clipboard. It prints the copied size and the list of included files to standard error.

The directory walker skips hidden files and respects repository, global, and local Git ignore rules. It also excludes common binary, generated, configuration, and lock-file formats.
