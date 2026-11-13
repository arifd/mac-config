use std::path::Path;

pub fn has_excluded_pattern(path: &Path) -> bool {
    let file_name = match path.file_name().and_then(|s| s.to_str()) {
        Some(name) => name.to_lowercase(),
        None => return false,
    };

    const EXCLUDED_PATTERNS: &[&str] = &[".min.", ".config.", ".conf"];

    EXCLUDED_PATTERNS
        .iter()
        .any(|pattern| file_name.contains(pattern))
}

#[rustfmt::skip]
pub fn has_excluded_extension(path: &Path) -> bool {
    const EXCLUDED_EXTS: &[&str] = &[
        // Dependency / lock files
        "lock",

        // Configuration/data files
        "json", "toml", "yaml",

        // Build artifacts / compiled output
        "o", "a", "so", "dll", "dylib",
        "class", "jar",
        "exe",
        "wasm",

        // Archives / compressed
        "zip", "tar", "gz", "xz", "bz2", "7z", "rar",

        // Images
        "png", "jpg", "jpeg", "gif", "bmp", "tiff", "webp", "svg", "ico",

        // Video
        "mp4", "mov", "avi", "mkv", "webm", "wmv",

        // Audio
        "mp3", "wav", "ogg", "flac", "aac", "m4a",

        // Fonts
        "ttf", "otf", "woff", "woff2",

        // Databases / data dumps
        "db", "sqlite", "sqlite3",
        "parquet", "avro",
        "bin", "dat",

        // Minified / generated frontend
        "map",
        "min.js",
        "min.css",
        "config.js", "config.ts", "config.cjs",

        // Logs / caches
        "log", "tmp", "cache",

        // OS / editor junk
        "swp", "swo",
        "ds_store",

        // Certificates / keys
        "pem", "crt", "key", "p12", "pfx",

        // Misc binary formats
        "pdf",
        "psd",
    ];

    path.extension()
        .and_then(|e| e.to_str())
        .map(|e| EXCLUDED_EXTS.contains(&e))
        .unwrap_or(false)
}
