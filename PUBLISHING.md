# Publishing Checklist

This repository is the public publication package for the Validated-by-Design whitepaper series.

Each paper is published as a versioned release. Do not publish internal authoring files, working documents, draft architectures, review comments, or other internal material to this repository.

## 1. Complete The External-Publication Gate

Before publishing any new paper or release, record written confirmation that:

- all three authors approve open-internet distribution and CC BY 4.0 licensing;
- required Microsoft and Lonza external-publication, intellectual-property, privacy, brand, and communications reviews are complete;
- every figure, quotation, trademark, and third-party reference can be distributed under the stated terms or is clearly excluded from the license;
- the paper contains no confidential, customer, personal, or internal-only information;
- time-sensitive FDA, EU Annex 11, and EU Annex 22 statements have been reverified as of the public release date;
- the public PDF carries the final author attribution, disclaimer, license notice, publication date, and version.

Do not treat a personal-opinion disclaimer as a substitute for these permissions.

## 2. Publication Structure

The repository contains the Validated-by-Design whitepaper series:

- **Paper 1 — Vision & Operating Model**
- **Paper 2 — Technical Reference Architecture**
- **Paper 3 — Regulatory & Implementation Guide**

Each published version has its own directory under `releases/`.

Current structure:

```text
releases/
├── v1.0.0/
├── v1.0.1/
└── v2.0.0/
```

Each release directory must contain:

```text
RELEASE-NOTES.md
SHA256SUMS.txt
validated-by-design-book-[N]-v[VERSION].pdf
```

The public PDF is the canonical edition of each paper.

## 3. GitHub Pages

GitHub Pages uses `index.html` in the repository root as the public landing page.

For every new paper:

1. Add the canonical PDF to the corresponding release directory.
2. Add a link to the PDF from `index.html`.
3. Add the paper to the whitepaper series overview in `README.md`.
4. Keep previous published papers and their links available.

## 4. Prepare A Release

Before creating a GitHub release:

1. Confirm the final PDF has passed the External-Publication Gate.
2. Give the PDF its final canonical filename.
3. Add the PDF to the appropriate `releases/` directory.
4. Create or update `RELEASE-NOTES.md`.
5. Calculate the SHA-256 digest of the final PDF.
6. Record the digest in `SHA256SUMS.txt`.
7. Update `.zenodo.json` for the publication.
8. Update `CITATION.cff` for the publication.
9. Update `README.md`.
10. Update `index.html`.
11. Run the release verification script.
12. Do not create the public GitHub release unless verification succeeds.

## 5. Verify A Release

Run the repository verification locally before publishing:

```powershell
./scripts/verify-release.ps1
```

Resolve all reported failures before publishing the release.

The GitHub Actions workflow in `.github/workflows/verify-release.yml` provides an additional verification check when changes are pushed to the repository.

## 6. Paper 1

### Current Corrected Release

Tag:

`v1.0.1`

Release directory:

`releases/v1.0.1/`

Canonical PDF:

`validated-by-design-book-1-v1.0.1.pdf`

Release notes:

`releases/v1.0.1/RELEASE-NOTES.md`

Checksum:

`releases/v1.0.1/SHA256SUMS.txt`

Paper 1 remains available as a previously published release and must not be replaced by Paper 2 release assets.

## 7. Paper 2

### Technical Reference Architecture

Tag:

`v2.0.0`

Release directory:

`releases/v2.0.0/`

Canonical PDF:

`validated-by-design-book-2-v2.0.0.pdf`

Release notes:

`releases/v2.0.0/RELEASE-NOTES.md`

Checksum:

`releases/v2.0.0/SHA256SUMS.txt`

### Paper 2 Release Process

1. Confirm the final PDF is named:

   `validated-by-design-book-2-v2.0.0.pdf`

2. Verify its SHA-256 digest against:

   `releases/v2.0.0/SHA256SUMS.txt`

3. Run:

```powershell
./scripts/verify-release.ps1
```

4. Confirm release verification succeeds.

5. Commit the complete publication package to `main`.

6. Confirm the GitHub Actions verification succeeds.

7. Draft the GitHub release using tag:

   `v2.0.0`

8. Use the contents of:

   `releases/v2.0.0/RELEASE-NOTES.md`

   as the GitHub release notes.

9. Attach:

   `validated-by-design-book-2-v2.0.0.pdf`

   as the release asset.

10. Confirm the attached PDF matches the SHA-256 digest recorded in:

    `releases/v2.0.0/SHA256SUMS.txt`

11. Publish the release only after all assets and metadata are present.

## 8. Archive With Zenodo

Ensure the repository is connected to Zenodo before publishing a release that should be archived.

After Zenodo archives the release:

- record the assigned version DOI;
- record the concept DOI where applicable;
- add the DOI information to `README.md`;
- add the DOI and repository URL to `CITATION.cff`;
- add or update the Zenodo DOI badge in `README.md`;
- use the DOI as the durable publication target for external references.

Never invent or pre-allocate a DOI in the repository metadata.

## 9. Post-Publication Verification

After publishing a release:

1. Verify the GitHub release page.
2. Verify the PDF release asset downloads correctly.
3. Verify the GitHub Pages landing page links to the correct canonical PDF.
4. Verify the SHA-256 digest of the published PDF.
5. Verify the Zenodo record and DOI metadata.
6. Verify `README.md` and `CITATION.cff` contain the final publication metadata.

## 10. Social Release

For external communication, use the DOI as the durable publication target once available.

A concise social post should communicate the central message and practical takeaways of the publication.

A longer article should be treated as an adaptation rather than a second authoritative copy and should link back to the DOI.
``