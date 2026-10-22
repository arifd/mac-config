mod exclude;

use std::{
    env,
    fmt::Write as _,
    io::Write as _,
    path::{Path, PathBuf},
};

use anyhow::{Context, Result};
use arboard::Clipboard;
use bytesize::ByteSize;
use ignore::WalkBuilder;

fn main() -> Result<()> {
    // Optional first argument => root path:
    let root = env::args()
        .nth(1)
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from("."));

    let files = discover_files(&root);
    let output = write_copy_pasta(&files)?;
    let len = output.len();
    copy_to_clipboard(output)?;
    write_summary(&files, len)?;

    Ok(())
}

fn discover_files(root: &Path) -> Vec<PathBuf> {
    WalkBuilder::new(root)
        .hidden(true) // Automatically skip dotfiles
        .git_ignore(true) // Respect .gitignore
        .git_global(true) // respect global gitignore
        .git_exclude(true) // respect .git/info/exclude
        .parents(true) // allow parent .gitignore files
        .sort_by_file_name(|a, b| a.cmp(b))
        .build()
        .filter_map(|e| e.ok())
        .filter(|e| e.file_type().unwrap().is_file())
        .map(|e| e.path().to_path_buf())
        .filter(|e| !exclude::has_excluded_extension(&e))
        .filter(|e| !exclude::has_excluded_pattern(e))
        .collect()
}

fn write_copy_pasta(files: &[PathBuf]) -> Result<String> {
    let mut output = String::new();

    for file in files {
        write!(&mut output, "\n\n===== FILE: {} =====\n\n", file.display())?;
        let Ok(content) = std::fs::read_to_string(file) else {
            continue; // Binary-like content
        };
        output.push_str(&content);
    }

    Ok(output)
}

fn copy_to_clipboard(output: String) -> Result<()> {
    Clipboard::new()
        .context("failed to access clipboard")?
        .set_text(output)
        .context("failed to set clipboard contents")
}

fn write_summary(files: &[PathBuf], len: usize) -> Result<()> {
    let len = ByteSize::b(len as u64);
    let mut stderr = std::io::stderr();

    writeln!(
        &mut stderr,
        "copied {len} across {} files to clipboard",
        files.len()
    )?;
    writeln!(&mut stderr, "────────────────────────────────────")?;
    for file in files {
        writeln!(&mut stderr, "• {}", file.display())?;
    }

    Ok(())
}
