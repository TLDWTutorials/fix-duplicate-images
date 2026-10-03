# Photo Duplicate Finder

A simple Windows tool for finding exact duplicate images, even when the filenames are completely different.

It scans the image files in a folder, calculates a SHA-256 hash for each one, identifies exact duplicates, creates a CSV report, and can optionally create a new folder containing one copy of every unique image.

It does **not automatically delete anything**.

## How to Use It

### 1. Download the two files

You need:

```text
run_dedup.bat
dedup.ps1
```

Keep both files together.

### 2. Put them in the folder with your photos

For example:

```text
D:\Photos\
    run_dedup.bat
    dedup.ps1
    vacation1.jpg
    vacation2.jpg
    IMG_58392741.jpg
    family-photo.jpg
```

The program scans the images in the same folder where the scripts are located.

You do not need to edit any folder paths.

### 3. Double-click `run_dedup.bat`

Run:

```text
run_dedup.bat
```

Do not launch `dedup.ps1` directly.

The batch file starts the PowerShell script for you and avoids the common Windows error:

```text
running scripts is disabled on this system
```

The execution-policy bypass only applies to that one run. It does not permanently change your Windows settings.

### 4. Wait while the images are scanned

You will see each image being processed.

For example:

```text
Hashing vacation1.jpg
Hashing vacation2.jpg
Hashing IMG_58392741.jpg
Hashing family-photo.jpg
```

The time required depends on how many images you have and how large they are.

### 5. Review the results

When the scan finishes, you will see something like:

```text
Total image files: 150
True unique images: 112
Duplicate copies: 38
```

The tool also creates:

```text
image_hash_report.csv
```

in the same folder.

Open this file in Excel, LibreOffice Calc, Google Sheets, or another spreadsheet program.

## What the CSV Shows

The report contains one row for every image.

| Column | Meaning |
|---|---|
| FileName | Name of the image |
| FullPath | Full location of the image |
| SizeBytes | File size |
| SHA256 | SHA-256 hash of the file |
| DuplicateCount | Number of files with the same hash |
| IsDuplicate | Yes if another identical file exists |

Example:

```text
FileName,SizeBytes,SHA256,DuplicateCount,IsDuplicate
vacation.jpg,2847291,ABC123...,2,Yes
IMG_58392741.jpg,2847291,ABC123...,2,Yes
dog.jpg,1938472,DEF456...,1,No
```

In this example:

```text
vacation.jpg
IMG_58392741.jpg
```

have different filenames, but the same SHA-256 hash.

That means they are exact duplicates.

## Create a Folder With Only Unique Images

After the scan, the program asks:

```text
Create a new folder containing ONE COPY of every unique image? (Y/N)
```

If you type:

```text
Y
```

and press Enter, the program creates:

```text
Unique_Images
```

inside the same folder.

Only one file from each unique SHA-256 hash is copied into `Unique_Images`.

Your original files are not deleted or modified.

If you type:

```text
N
```

the program stops after creating the CSV report.

## How It Works

The program does not compare filenames.

Instead, it calculates a SHA-256 hash for the contents of every image.

Think of the hash as a digital fingerprint for the file.

For example:

```text
TurkeyVacation.jpg
IMG_83729482.jpg
BackupPhoto.jpg
```

may look completely unrelated based on their filenames.

But if all three contain exactly the same file data, they will produce the same SHA-256 hash.

Example:

```text
TurkeyVacation.jpg     A8F71C92...
IMG_83729482.jpg       A8F71C92...
BackupPhoto.jpg        A8F71C92...
```

The program sees those matching hashes and knows the files are identical.

It then counts that as:

```text
3 files
1 unique image
2 duplicate copies
```

## What "True Unique Images" Means

Suppose your folder contains:

```text
photoA.jpg
photoA-copy.jpg
photoB.jpg
photoC.jpg
photoC-backup.jpg
```

There are 5 files.

But `photoA.jpg` and `photoA-copy.jpg` are identical, and `photoC.jpg` and `photoC-backup.jpg` are identical.

So you really have only:

```text
3 unique images
```

The tool would report:

```text
Total image files: 5
True unique images: 3
Duplicate copies: 2
```

## Supported Image Types

```text
.jpg
.jpeg
.png
.gif
.bmp
.webp
.tif
.tiff
.heic
```

## What This Does Not Detect

This tool finds **exact duplicates**.

It will not identify images that only look similar.

For example:

- resized versions
- cropped versions
- edited versions
- recompressed JPEGs
- screenshots of the same image
- files with changed metadata
- RAW and JPEG versions of the same photo

Those files can look nearly identical but still have different SHA-256 hashes.

## Safety

This tool does not automatically delete anything.

It only:

- scans image files
- calculates hashes
- creates a CSV report
- optionally copies one file from each unique hash into `Unique_Images`

You should still keep a backup of important photos before doing any large-scale cleanup.

## Files Included

### `run_dedup.bat`

The file most users should run.

It launches the PowerShell script with an execution-policy bypass that applies only to that one run.

### `dedup.ps1`

Contains the duplicate detection logic.

It scans images, calculates SHA-256 hashes, creates the CSV report, and optionally creates the unique-images folder.

## Recommended Workflow

1. Back up important photos
2. Put `run_dedup.bat` and `dedup.ps1` in the photo folder
3. Double-click `run_dedup.bat`
4. Review `image_hash_report.csv`
5. Confirm the duplicate groups
6. Choose whether to create `Unique_Images`
7. Verify the unique collection before manually deleting anything

## Keywords

duplicate photos, duplicate image finder, find duplicate photos, exact duplicate images, SHA-256, photo cleanup, image deduplication, duplicate files, Windows duplicate finder, PowerShell duplicate files, photo organization, duplicate photo scanner, find identical images, external hard drive cleanup
